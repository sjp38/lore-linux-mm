Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80BFF6B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 06:29:02 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w9so6609047pfl.2
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 03:29:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x7-v6si10996257pln.666.2018.03.06.03.29.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Mar 2018 03:29:00 -0800 (PST)
Subject: Re: Hangs in balance_dirty_pages with arm-32 LPAE + highmem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <b77a6596-3b35-84fe-b65b-43d2e43950b3@redhat.com>
	<20180226142839.GB16842@dhcp22.suse.cz>
	<4ba43bef-37f0-c21c-23a7-bbf696c926fd@redhat.com>
In-Reply-To: <4ba43bef-37f0-c21c-23a7-bbf696c926fd@redhat.com>
Message-Id: <201803062028.ECG56737.OHOFVFQFtOMSJL@I-love.SAKURA.ne.jp>
Date: Tue, 6 Mar 2018 20:28:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: labbott@redhat.com, mhocko@kernel.org, dchinner@redhat.com
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org

Laura Abbott wrote:
> On 02/26/2018 06:28 AM, Michal Hocko wrote:
> > On Fri 23-02-18 11:51:41, Laura Abbott wrote:
> >> Hi,
> >>
> >> The Fedora arm-32 build VMs have a somewhat long standing problem
> >> of hanging when running mkfs.ext4 with a bunch of processes stuck
> >> in D state. This has been seen as far back as 4.13 but is still
> >> present on 4.14:
> >>
> > [...]
> >> This looks like everything is blocked on the writeback completing but
> >> the writeback has been throttled. According to the infra team, this problem
> >> is _not_ seen without LPAE (i.e. only 4G of RAM). I did see
> >> https://patchwork.kernel.org/patch/10201593/ but that doesn't seem to
> >> quite match since this seems to be completely stuck. Any suggestions to
> >> narrow the problem down?
> > 
> > How much dirtyable memory does the system have? We do allow only lowmem
> > to be dirtyable by default on 32b highmem systems. Maybe you have the
> > lowmem mostly consumed by the kernel memory. Have you tried to enable
> > highmem_is_dirtyable?
> > 
> 
> Setting highmem_is_dirtyable did fix the problem. The infrastructure
> people seemed satisfied enough with this (and are happy to have the
> machines back).

That's good.

>                 I'll see if they are willing to run a few more tests
> to get some more state information.

Well, I'm far from understanding what is happening in your case, but I'm
interested in other threads which were trying to allocate memory. Therefore,
I appreciate if they can take SysRq-m + SysRq-t than SysRq-w (as described
at http://akari.osdn.jp/capturing-kernel-messages.html ).

Code which assumes that kswapd can make progress can get stuck when kswapd
is blocked somewhere. And wbt_wait() seems to change behavior based on
current_is_kswapd(). If everyone is waiting for kswapd but kswapd cannot
make progress, I worry that it leads to hangups like your case.



Below is a totally different case which I got today, but an example of
whether SysRq-m + SysRq-t can give us some clues.

Running below program on CPU 0 (using "taskset -c 0") on 4.16-rc4 against XFS
can trigger OOM lockups (hangup without being able to invoke the OOM killer).

----------
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	static char buffer[4096] = { };
	char *buf = NULL;
	unsigned long size;
	unsigned long i;
	for (i = 0; i < 1024; i++) {
		if (fork() == 0) {
			int fd;
			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
			memset(buffer, 0, sizeof(buffer));
			sleep(1);
			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
			_exit(0);
		}
	}
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sleep(2);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	return 0;
}
----------

MM people love to ignore such kind of problem with "It is a DoS attack", but
only one CPU out of 8 CPUs is occupied by this program, which means that other
threads (including kernel threads doing memory reclaim activities) are free to
use idle CPUs 1-7 as they need. Also, while CPU 0 was really busy processing
hundreds of threads doing direct reclaim, idle CPUs 1-7 should be able to invoke
the OOM killer shortly because there should be already little to reclaim. Also,
writepending: did not decrease (and no disk I/O was observed) during the OOM
lockup. Thus, I don't know whether this is just an overloaded.

[  660.035957] Node 0 Normal free:17056kB min:17320kB low:21648kB high:25976kB active_anon:570132kB inactive_anon:13452kB active_file:15136kB inactive_file:13296kB unevictable:0kB writepending:42320kB present:1048576kB managed:951188kB mlocked:0kB kernel_stack:22448kB pagetables:37304kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  709.498421] Node 0 Normal free:16920kB min:17320kB low:21648kB high:25976kB active_anon:570132kB inactive_anon:13452kB active_file:19180kB inactive_file:17640kB unevictable:0kB writepending:42740kB present:1048576kB managed:951188kB mlocked:0kB kernel_stack:22400kB pagetables:37304kB bounce:0kB free_pcp:248kB local_pcp:0kB free_cma:0kB
[  751.290146] Node 0 Normal free:16920kB min:17320kB low:21648kB high:25976kB active_anon:570132kB inactive_anon:13452kB active_file:14556kB inactive_file:14452kB unevictable:0kB writepending:42740kB present:1048576kB managed:951188kB mlocked:0kB kernel_stack:22400kB pagetables:37304kB bounce:0kB free_pcp:248kB local_pcp:0kB free_cma:0kB
[  783.437211] Node 0 Normal free:16920kB min:17320kB low:21648kB high:25976kB active_anon:570132kB inactive_anon:13452kB active_file:14756kB inactive_file:13888kB unevictable:0kB writepending:42740kB present:1048576kB managed:951188kB mlocked:0kB kernel_stack:22304kB pagetables:37304kB bounce:0kB free_pcp:312kB local_pcp:32kB free_cma:0kB
[ 1242.729271] Node 0 Normal free:16920kB min:17320kB low:21648kB high:25976kB active_anon:570132kB inactive_anon:13452kB active_file:14072kB inactive_file:14304kB unevictable:0kB writepending:42740kB present:1048576kB managed:951188kB mlocked:0kB kernel_stack:22128kB pagetables:37304kB bounce:0kB free_pcp:440kB local_pcp:48kB free_cma:0kB
[ 1412.248884] Node 0 Normal free:16920kB min:17320kB low:21648kB high:25976kB active_anon:570132kB inactive_anon:13452kB active_file:14332kB inactive_file:14280kB unevictable:0kB writepending:42740kB present:1048576kB managed:951188kB mlocked:0kB kernel_stack:22128kB pagetables:37304kB bounce:0kB free_pcp:440kB local_pcp:48kB free_cma:0kB
[ 1549.795514] Node 0 Normal free:16920kB min:17320kB low:21648kB high:25976kB active_anon:570132kB inactive_anon:13452kB active_file:14416kB inactive_file:14272kB unevictable:0kB writepending:42740kB present:1048576kB managed:951188kB mlocked:0kB kernel_stack:22128kB pagetables:37304kB bounce:0kB free_pcp:440kB local_pcp:48kB free_cma:0kB

Complete log is http://I-love.SAKURA.ne.jp/tmp/serial-20180306.txt.xz .
Config is http://I-love.SAKURA.ne.jp/tmp/config-4.16-rc4 .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
