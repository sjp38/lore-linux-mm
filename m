Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB1C6B0665
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 02:47:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k82so754350oih.1
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 23:47:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m78si666736oig.439.2017.08.03.23.47.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 23:47:01 -0700 (PDT)
Message-Id: <201708040646.v746kkhC024636@www262.sakura.ne.jp>
Subject: Re: [PATCH] mm, oom: fix potential data corruption when
 =?ISO-2022-JP?B?b29tX3JlYXBlciByYWNlcyB3aXRoIHdyaXRlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 04 Aug 2017 15:46:46 +0900
References: <20170803135902.31977-1-mhocko@kernel.org>
In-Reply-To: <20170803135902.31977-1-mhocko@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, Oleg Nesterov <oleg@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal Hocko wrote:
>                          So there is a race window when some threads
> won't have fatal_signal_pending while the oom_reaper could start
> unmapping the address space. generic_perform_write could then write
> zero page to the page cache and corrupt data.

Oh, simple generic_perform_write() ?

> 
> The race window is rather small and close to impossible to happen but it
> would be better to have it covered.

OK, I confirmed that this problem is easily reproducible using below reproducer.

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>
#include <signal.h>

#define NUMTHREADS 512
#define STACKSIZE 8192

static int pipe_fd[2] = { EOF, EOF };
static int file_writer(void *i)
{
	char buffer[4096] = { };
	int fd;
	snprintf(buffer, sizeof(buffer), "/tmp/file.%lu", (unsigned long) i);
	fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
	memset(buffer, 0xFF, sizeof(buffer));
	read(pipe_fd[0], buffer, 1);
	while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
	return 0;
}

int main(int argc, char *argv[])
{
	char *buf = NULL;
	unsigned long size;
	unsigned long i;
	char *stack;
	if (pipe(pipe_fd))
		return 1;
	stack = malloc(STACKSIZE * NUMTHREADS);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	for (i = 0; i < NUMTHREADS; i++)
                if (clone(file_writer, stack + (i + 1) * STACKSIZE,
			  CLONE_THREAD | CLONE_SIGHAND | CLONE_VM | CLONE_FS |
			  CLONE_FILES, (void *) i) == -1)
                        break;
	close(pipe_fd[1]);
	/* Will cause OOM due to overcommit; if not use SysRq-f */
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	kill(-1, SIGKILL);
	return 0;
}
----------
$ cat /tmp/file.* | od -b | head
0000000 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
307730000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000
*
307740000 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
316600000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000
*
316610000 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377 377
*
----------

Applying your patch seems to avoid this problem, but as far as I tested
your patch seems to trivially trigger something lock related problem.
Is your patch really safe?

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170804.txt.xz 
and config is at http://I-love.SAKURA.ne.jp/tmp/config-20170804 .

----------
[   58.539455] Out of memory: Kill process 1056 (a.out) score 603 or sacrifice child
[   58.543943] Killed process 1056 (a.out) total-vm:4268108kB, anon-rss:2246048kB, file-rss:0kB, shmem-rss:0kB
[   58.544245] a.out (1169) used greatest stack depth: 11664 bytes left
[   58.557471] DEBUG_LOCKS_WARN_ON(depth <= 0)
[   58.557480] ------------[ cut here ]------------
[   58.564407] WARNING: CPU: 6 PID: 1339 at kernel/locking/lockdep.c:3617 lock_release+0x172/0x1e0
[   58.569076] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev pcspkr vmw_balloon vmw_vmci shpchp sg i2c_piix4 parport_pc parport ip_tables xfs libcrc32c sr_mod sd_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ahci e1000 libahci ata_piix mptbase libata
[   58.599401] CPU: 6 PID: 1339 Comm: a.out Not tainted 4.13.0-rc3-next-20170803+ #142
[   58.604126] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   58.609790] task: ffff9d90df888040 task.stack: ffffa07084854000
[   58.613944] RIP: 0010:lock_release+0x172/0x1e0
[   58.617622] RSP: 0000:ffffa07084857e58 EFLAGS: 00010082
[   58.621533] RAX: 000000000000001f RBX: ffff9d90df888040 RCX: 0000000000000000
[   58.626074] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffffa30d4ba4
[   58.630572] RBP: ffffa07084857e98 R08: 0000000000000000 R09: 0000000000000001
[   58.635016] R10: 0000000000000000 R11: 000000000000001f R12: ffffa07084857f58
[   58.639694] R13: ffff9d90f60d6cd0 R14: 0000000000000000 R15: ffffffffa305cb6e
[   58.644200] FS:  00007fb932730740(0000) GS:ffff9d90f9f80000(0000) knlGS:0000000000000000
[   58.648989] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   58.652903] CR2: 000000000040092f CR3: 0000000135229000 CR4: 00000000000606e0
[   58.657280] Call Trace:
[   58.659989]  up_read+0x1a/0x40
[   58.662825]  __do_page_fault+0x28e/0x4c0
[   58.665946]  do_page_fault+0x30/0x80
[   58.668911]  page_fault+0x28/0x30
[   58.671629] RIP: 0033:0x40092f
[   58.674221] RSP: 002b:00007fb931f99ff0 EFLAGS: 00010217
[   58.677556] RAX: 0000000000001000 RBX: 00007fb931f99ff0 RCX: 00007fb93224ec90
[   58.681489] RDX: 0000000000001000 RSI: 00007fb931f99ff0 RDI: 0000000000000117
[   58.685297] RBP: 0000000000000117 R08: 00007fb9321ae938 R09: 000000000000000d
[   58.689123] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000100000000
[   58.692879] R13: 00007fb731f59010 R14: 0000000000000000 R15: 00007fb731f59010
[   58.696588] Code: 5e 41 5f 5d c3 e8 df a7 26 00 85 c0 74 1f 8b 35 2d 2f df 01 85 f6 75 15 48 c7 c6 66 7c a0 a3 48 c7 c7 5b 41 a0 a3 e8 6a 14 01 00 <0f> ff 4c 89 fa 4c 89 ee 48 89 df e8 fe c8 ff ff eb 88 48 c7 c7 
[   58.705635] ---[ end trace 91ff0f99e79ee485 ]---
[   58.831028] oom_reaper: reaped process 1056 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------

----------
[  187.202689] Out of memory: Kill process 2113 (a.out) score 734 or sacrifice child
[  187.208024] Killed process 2113 (a.out) total-vm:4268108kB, anon-rss:2735276kB, file-rss:0kB, shmem-rss:0kB
[  187.463902] oom_reaper: reaped process 2113 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  188.249973] DEBUG_LOCKS_WARN_ON(depth <= 0)
[  188.249983] ------------[ cut here ]------------
[  188.257247] WARNING: CPU: 7 PID: 2313 at kernel/locking/lockdep.c:3617 lock_release+0x172/0x1e0
[  188.263282] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp pcspkr vmw_balloon ppdev i2c_piix4 vmw_vmci shpchp sg parport_pc parport ip_tables xfs libcrc32c sr_mod sd_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ahci mptscsih ata_piix libahci e1000 mptbase libata
[  188.295888] CPU: 7 PID: 2313 Comm: a.out Not tainted 4.13.0-rc3-next-20170803+ #142
[  188.300975] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  188.307049] task: ffff8c4433840040 task.stack: ffff9459c660c000
[  188.311510] RIP: 0010:lock_release+0x172/0x1e0
[  188.315530] RSP: 0000:ffff9459c660fe58 EFLAGS: 00010082
[  188.319895] RAX: 000000000000001f RBX: ffff8c4433840040 RCX: 0000000000000000
[  188.324908] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffff810d4ba4
[  188.329894] RBP: ffff9459c660fe98 R08: 0000000000000000 R09: 0000000000000001
[  188.334724] R10: 0000000000000000 R11: 000000000000001f R12: ffff9459c660ff58
[  188.339707] R13: ffff8c4434644c90 R14: 0000000000000000 R15: ffffffff8105cb6e
[  188.344553] FS:  00007f0e2aca8740(0000) GS:ffff8c4439fc0000(0000) knlGS:0000000000000000
[  188.349616] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  188.353835] CR2: 00007f0e2a665ff0 CR3: 00000001346a5005 CR4: 00000000000606e0
[  188.358604] Call Trace:
[  188.361539]  up_read+0x1a/0x40
[  188.364661]  __do_page_fault+0x28e/0x4c0
[  188.368059]  do_page_fault+0x30/0x80
[  188.371338]  page_fault+0x28/0x30
[  188.374426] RIP: 0033:0x7f0e2a7c6c90
[  188.377543] RSP: 002b:00007f0e2a46bfe8 EFLAGS: 00010246
[  188.381238] RAX: 0000000000001000 RBX: 00007f0e2a46bff0 RCX: 00007f0e2a7c6c90
[  188.385576] RDX: 0000000000001000 RSI: 00007f0e2a46bff0 RDI: 00000000000000fd
[  188.389886] RBP: 00000000000000fd R08: 00007f0e2a726938 R09: 000000000000000d
[  188.394148] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000100000000
[  188.398339] R13: 00007f0c2a4d1010 R14: 0000000000000000 R15: 00007f0c2a4d1010
[  188.402508] Code: 5e 41 5f 5d c3 e8 df a7 26 00 85 c0 74 1f 8b 35 2d 2f df 01 85 f6 75 15 48 c7 c6 66 7c a0 81 48 c7 c7 5b 41 a0 81 e8 6a 14 01 00 <0f> ff 4c 89 fa 4c 89 ee 48 89 df e8 fe c8 ff ff eb 88 48 c7 c7 
[  188.412704] ---[ end trace d42863c48bb12d0a ]---
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
