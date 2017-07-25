Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 634B96B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 10:26:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p43so23965806wrb.6
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:26:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r17si15306321wrc.279.2017.07.25.07.26.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 07:26:29 -0700 (PDT)
Date: Tue, 25 Jul 2017 16:26:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725142626.GJ26723@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="VrqPEDrXMn8OVzN4"
Content-Disposition: inline
In-Reply-To: <20170724161146.GQ25221@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--VrqPEDrXMn8OVzN4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon 24-07-17 18:11:46, Michal Hocko wrote:
> On Mon 24-07-17 17:51:42, Kirill A. Shutemov wrote:
> > On Mon, Jul 24, 2017 at 04:15:26PM +0200, Michal Hocko wrote:
> [...]
> > > What kind of scalability implication you have in mind? There is
> > > basically a zero contention on the mmap_sem that late in the exit path
> > > so this should be pretty much a fast path of the down_write. I agree it
> > > is not 0 cost but the cost of the address space freeing should basically
> > > make it a noise.
> > 
> > Even in fast path case, it adds two atomic operation per-process. If the
> > cache line is not exclusive to the core by the time of exit(2) it can be
> > noticible.
> > 
> > ... but I guess it's not very hot scenario.
> > 
> > I guess I'm just too cautious here. :)
> 
> I definitely did not want to handwave your concern. I just think we can
> rule out the slow path and didn't think about the fast path overhead.
> 
> > > > Should we do performance/scalability evaluation of the patch before
> > > > getting it applied?
> > > 
> > > What kind of test(s) would you be interested in?
> > 
> > Can we at lest check that number of /bin/true we can spawn per second
> > wouldn't be harmed by the patch? ;)
> 
> OK, so measuring a single /bin/true doesn't tell anything so I've done
> root@test1:~# cat a.sh 
> #!/bin/sh
> 
> NR=$1
> for i in $(seq $NR)
> do
>         /bin/true
> done

I wanted to reduce a potential shell side effects so I've come with a
simple program which forks and saves the timestamp before child exit and
right after waitpid (see attached) and then measured it 100k times. Sure
this still measures waitpid overhead and the signal delivery but this
should be more or less constant on an idle system, right? See attached.

before the patch
min: 306300.00 max: 6731916.00 avg: 437962.07 std: 92898.30 nr: 100000

after
min: 303196.00 max: 5728080.00 avg: 436081.87 std: 96165.98 nr: 100000

The results are well withing noise as I would expect.
-- 
Michal Hocko
SUSE Labs

--VrqPEDrXMn8OVzN4
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="exit_time.c"

#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <unistd.h>

#define NR_FORKS 100000

static inline uint64_t get_cycles(void)
{
	uint64_t t;
	volatile int dont_remove __attribute__((unused));
	unsigned tmp;

	__asm volatile ("cpuid" : "=a"(tmp), "=b"(tmp), "=c"(tmp), "=d"(tmp): "a" (0));

	dont_remove = tmp; 
	__asm volatile ("rdtsc" : "=A"(t));
	return t;
}

int main(int argc, char **argv)
{
	void *addr = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, -1, 0);
	int i = NR_FORKS, j = 1;

	assert(addr != MAP_FAILED);

	while (i-- > 0) {
		pid_t child = fork();
		uint64_t before, after;

		assert(child != -1);
		if (!child) {
			*(uint64_t *)addr = get_cycles();
			return 0;
		}
		assert(child == waitpid(child, NULL, 0));
		before = *(uint64_t *)addr;
		after = get_cycles();

		printf("%u\n", (unsigned)(after - before));
		fflush(stdout);
	}

	return 0;
}

--VrqPEDrXMn8OVzN4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
