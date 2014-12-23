Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCD26B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:41:47 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so8653573wgh.15
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 01:41:46 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s5si37739208wju.40.2014.12.23.01.41.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Dec 2014 01:41:46 -0800 (PST)
Date: Tue, 23 Dec 2014 04:41:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141223094132.GA12208@phnom.home.cmpxchg.org>
References: <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141221204249.GL15665@dastard>
 <20141222165736.GB2900@dhcp22.suse.cz>
 <20141222213058.GQ15665@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141222213058.GQ15665@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Dec 23, 2014 at 08:30:58AM +1100, Dave Chinner wrote:
> On Mon, Dec 22, 2014 at 05:57:36PM +0100, Michal Hocko wrote:
> > On Mon 22-12-14 07:42:49, Dave Chinner wrote:
> > [...]
> > > "memory reclaim gave up"? So why the hell isn't it returning a
> > > failure to the caller?
> > > 
> > > i.e. We have a perfectly good page cache allocation failure error
> > > path here all the way back to userspace, but we're invoking the
> > > OOM-killer to kill random processes rather than returning ENOMEM to
> > > the processes that are generating the memory demand?
> > > 
> > > Further: when did the oom-killer become the primary method
> > > of handling situations when memory allocation needs to fail?
> > > __GFP_WAIT does *not* mean memory allocation can't fail - that's what
> > > __GFP_NOFAIL means. And none of the page cache allocations use
> > > __GFP_NOFAIL, so why aren't we getting an allocation failure before
> > > the oom-killer is kicked?
> > 
> > Well, it has been an unwritten rule that GFP_KERNEL allocations for
> > low-order (<=PAGE_ALLOC_COSTLY_ORDER) never fail. This is a long ago
> > decision which would be tricky to fix now without silently breaking a
> > lot of code. Sad...
> 
> Wow.
> 
> We have *always* been told memory allocations are not guaranteed to
> succeed, ever, unless __GFP_NOFAIL is set, but that's deprecated and
> nobody is allowed to use it any more.
> 
> Lots of code has dependencies on memory allocation making progress
> or failing for the system to work in low memory situations. The page
> cache is one of them, which means all filesystems have that
> dependency. We don't explicitly ask memory allocations to fail, we
> *expect* the memory allocation failures will occur in low memory
> conditions. We've been designing and writing code with this in mind
> for the past 15 years.
> 
> How did we get so far away from the message of "the memory allocator
> never guarantees success" that it will never fail to allocate memory
> even if it means we livelock the entire system?

I think this isn't as much an allocation guarantee as it is based on
the thought that once we can't satisfy such low orders anymore the
system is so entirely unusable that the only remaining thing to do is
to kill processes one by one until the situation is resolved.

Hard to say, though, because this has been the behavior for longer
than the initial git import of the tree, without any code comment.

And yes, it's flawed, because the allocating task looping might be
what's holding up progress, as we can see here.

> > Nevertheless the caller can prevent from an endless loop by using
> > __GFP_NORETRY so this could be used as a workaround.
> 
> That's just a never-ending game of whack-a-mole that we will
> continually lose. It's not a workable solution.

Agreed.

> > The default should be opposite IMO and only those who really
> > require some guarantee should use a special flag for that purpose.
> 
> Yup, totally agree.

So how about something like the following change?  It restricts the
allocator's endless OOM killing loop to __GFP_NOFAIL contexts, which
are annotated in the callsite and thus easier to review for locks etc.
Otherwise, the allocator tries only as long as page reclaim makes
progress, the idea being that failures are handled gracefully in the
callsites, and page faults restarting automatically anyway.  The OOM
killing in that case is deferred to the end of the exception handler.

Preliminary testing confirms that the system is indeed trying just as
hard before OOM killing in the page fault case.  However, it doesn't
look like all callsites are prepared for failing smaller allocations:

[   55.553822] Out of memory: Kill process 240 (anonstress) score 158 or sacrifice child
[   55.561787] Killed process 240 (anonstress) total-vm:1540044kB, anon-rss:1284068kB, file-rss:468kB
[   55.571083] BUG: unable to handle kernel paging request at 00000000004006bd
[   55.578156] IP: [<00000000004006bd>] 0x4006bd
[   55.582584] PGD c8f3f067 PUD c8f48067 PMD c8f15067 PTE 0
[   55.588016] Oops: 0014 [#1] SMP 
[   55.591337] CPU: 1 PID: 240 Comm: anonstress Not tainted 3.18.0-mm1-00081-gf6137925fc97-dirty #188
[   55.600435] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./H61M-DGS, BIOS P1.30 05/10/2012
[   55.610030] task: ffff8802139b9a10 ti: ffff8800c8f64000 task.ti: ffff8800c8f64000
[   55.617623] RIP: 0033:[<00000000004006bd>]  [<00000000004006bd>] 0x4006bd
[   55.624512] RSP: 002b:00007fffd43b7220  EFLAGS: 00010206
[   55.629901] RAX: 00007f87e6e01000 RBX: 0000000000000000 RCX: 00007f87f64fe25a
[   55.637104] RDX: 00007f879881a000 RSI: 000000005dc00000 RDI: 0000000000000000
[   55.644331] RBP: 00007fffd43b7240 R08: 00000000ffffffff R09: 0000000000000000
[   55.651569] R10: 0000000000000022 R11: 0000000000000283 R12: 0000000000400570
[   55.658796] R13: 00007fffd43b7340 R14: 0000000000000000 R15: 0000000000000000
[   55.666040] FS:  00007f87f69d1700(0000) GS:ffff88021f280000(0000) knlGS:0000000000000000
[   55.674221] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   55.680055] CR2: 00007fdd676ad480 CR3: 00000000c8f3e000 CR4: 00000000000407e0
[   55.687272] 
[   55.688780] RIP  [<00000000004006bd>] 0x4006bd
[   55.693304]  RSP <00007fffd43b7220>
[   55.696850] CR2: 00000000004006bd
[   55.700207] ---[ end trace b9cb4f44f8e47bc3 ]---
[   55.704903] Kernel panic - not syncing: Fatal exception
[   55.710208] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
[   55.720517] Rebooting in 30 seconds..

Obvious bugs aside, though, the thought of failing order-0 allocations
after such a long time is scary...

---
