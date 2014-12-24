Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 117F06B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 20:07:55 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so8917858pab.5
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 17:07:54 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id pk7si20467597pbc.205.2014.12.23.17.07.50
        for <linux-mm@kvack.org>;
        Tue, 23 Dec 2014 17:07:52 -0800 (PST)
Date: Wed, 24 Dec 2014 12:06:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141224010633.GL24183@dastard>
References: <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141221204249.GL15665@dastard>
 <20141222165736.GB2900@dhcp22.suse.cz>
 <20141222213058.GQ15665@dastard>
 <20141223094132.GA12208@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141223094132.GA12208@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Dec 23, 2014 at 04:41:32AM -0500, Johannes Weiner wrote:
> On Tue, Dec 23, 2014 at 08:30:58AM +1100, Dave Chinner wrote:
> > On Mon, Dec 22, 2014 at 05:57:36PM +0100, Michal Hocko wrote:
> > > On Mon 22-12-14 07:42:49, Dave Chinner wrote:
> > > [...]
> > > > "memory reclaim gave up"? So why the hell isn't it returning a
> > > > failure to the caller?
> > > > 
> > > > i.e. We have a perfectly good page cache allocation failure error
> > > > path here all the way back to userspace, but we're invoking the
> > > > OOM-killer to kill random processes rather than returning ENOMEM to
> > > > the processes that are generating the memory demand?
> > > > 
> > > > Further: when did the oom-killer become the primary method
> > > > of handling situations when memory allocation needs to fail?
> > > > __GFP_WAIT does *not* mean memory allocation can't fail - that's what
> > > > __GFP_NOFAIL means. And none of the page cache allocations use
> > > > __GFP_NOFAIL, so why aren't we getting an allocation failure before
> > > > the oom-killer is kicked?
> > > 
> > > Well, it has been an unwritten rule that GFP_KERNEL allocations for
> > > low-order (<=PAGE_ALLOC_COSTLY_ORDER) never fail. This is a long ago
> > > decision which would be tricky to fix now without silently breaking a
> > > lot of code. Sad...
> > 
> > Wow.
> > 
> > We have *always* been told memory allocations are not guaranteed to
> > succeed, ever, unless __GFP_NOFAIL is set, but that's deprecated and
> > nobody is allowed to use it any more.
> > 
> > Lots of code has dependencies on memory allocation making progress
> > or failing for the system to work in low memory situations. The page
> > cache is one of them, which means all filesystems have that
> > dependency. We don't explicitly ask memory allocations to fail, we
> > *expect* the memory allocation failures will occur in low memory
> > conditions. We've been designing and writing code with this in mind
> > for the past 15 years.
> > 
> > How did we get so far away from the message of "the memory allocator
> > never guarantees success" that it will never fail to allocate memory
> > even if it means we livelock the entire system?
> 
> I think this isn't as much an allocation guarantee as it is based on
> the thought that once we can't satisfy such low orders anymore the
> system is so entirely unusable that the only remaining thing to do is
> to kill processes one by one until the situation is resolved.
> 
> Hard to say, though, because this has been the behavior for longer
> than the initial git import of the tree, without any code comment.
> 
> And yes, it's flawed, because the allocating task looping might be
> what's holding up progress, as we can see here.

Worse, it can be the task that is consuming all the memory, as canbe
seen by this failure on xfs/084 on my single CPU. 1GB RAM VM. This
test has been failing like this about 30% of the time since 3.18-rc1:

[ 4083.059309] Mem-Info:
[ 4083.059693] Node 0 DMA per-cpu:
[ 4083.060246] CPU    0: hi:    0, btch:   1 usd:   0
[ 4083.061041] Node 0 DMA32 per-cpu:
[ 4083.061612] CPU    0: hi:  186, btch:  31 usd:  50
[ 4083.062407] active_anon:119604 inactive_anon:119575 isolated_anon:0
[ 4083.062407]  active_file:29 inactive_file:58 isolated_file:0
[ 4083.062407]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 4083.062407]  free:1953 slab_reclaimable:2881 slab_unreclaimable:2484
[ 4083.062407]  mapped:27 shmem:2 pagetables:928 bounce:0
[ 4083.062407]  free_cma:0
[ 4083.067475] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:5612kB inactive_anon:5792kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(as
[ 4083.073986] lowmem_reserve[]: 0 966 966 966
[ 4083.074808] Node 0 DMA32 free:3888kB min:3944kB low:4928kB high:5916kB active_anon:472804kB inactive_anon:472508kB active_file:116kB inactive_file:232kB unevictabls
[ 4083.081570] lowmem_reserve[]: 0 0 0 0
[ 4083.082268] Node 0 DMA: 7*4kB (U) 9*8kB (UM) 7*16kB (UM) 4*32kB (U) 4*64kB (U) 2*128kB (U) 2*256kB (UM) 1*512kB (M) 0*1024kB 1*2048kB (R) 0*4096kB = 3924kB
[ 4083.084829] Node 0 DMA32: 16*4kB (U) 0*8kB 1*16kB (R) 1*32kB (R) 1*64kB (R) 1*128kB (R) 0*256kB 1*512kB (R) 1*1024kB (R) 1*2048kB (R) 0*4096kB = 3888kB
[ 4083.087287] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 4083.088657] 47956 total pagecache pages
[ 4083.089275] 47858 pages in swap cache
[ 4083.089856] Swap cache stats: add 416328, delete 368470, find 818589/929518
[ 4083.090941] Free swap  = 0kB
[ 4083.091398] Total swap = 497976kB
[ 4083.091923] 262044 pages RAM
[ 4083.092405] 0 pages HighMem/MovableOnly
[ 4083.093016] 10167 pages reserved
[ 4083.093528] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[ 4083.094749] [ 1195]     0  1195     5992       24      16      152         -1000 udevd
[ 4083.095981] [ 1326]     0  1326     5991       50      15      128         -1000 udevd
[ 4083.097224] [ 3835]     0  3835     2529        0       6      573         -1000 dhclient
[ 4083.098497] [ 3886]     0  3886    13099        0      27      153         -1000 sshd
[ 4083.099716] [ 3892]     0  3892    25770        1      52      233         -1000 sshd
[ 4083.100939] [ 3970]  1000  3970    25770        8      50      227         -1000 sshd
[ 4083.102164] [ 3971]  1000  3971     5276        1      14      493         -1000 bash
[ 4083.103386] [ 4062]     0  4062    16887        1      36      118         -1000 sudo
[ 4083.104667] [ 4063]     0  4063     3044      192      10      162         -1000 check
[ 4083.105952] [ 6708]     0  6708     5991       35      15      143         -1000 udevd
[ 4083.107244] [18113]     0 18113     2584        1       9      288         -1000 084
[ 4083.108517] [18317]     0 18317   316605   191037     623   121971         -1000 resvtest
[ 4083.109852] [18318]     0 18318     2584        0       9      288         -1000 084
[ 4083.111117] [18319]     0 18319     2584        0       9      288         -1000 084
[ 4083.112431] [18320]     0 18320     3258        0      11       36         -1000 sed
[ 4083.113692] [18321]     0 18321     3258        0      11       36         -1000 sed
[ 4083.114950] Kernel panic - not syncing: Out of memory and no killable processes...
[ 4083.114950]
[ 4083.116420] CPU: 0 PID: 18317 Comm: resvtest Not tainted 3.19.0-rc1-dgc+ #650
[ 4083.116423] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
[ 4083.116423]  ffffffff823357a0 ffff88003d98faa8 ffffffff81d87acb 0000000000008686
[ 4083.116423]  ffffffff8219b348 ffff88003d98fb28 ffffffff81d813c1 000000000000000b
[ 4083.116423]  0000000000000008 ffff88003d98fb38 ffff88003d98fad8 0000000000000000
[ 4083.116423] Call Trace:
[ 4083.116423]  [<ffffffff81d87acb>] dump_stack+0x45/0x57
[ 4083.116423]  [<ffffffff81d813c1>] panic+0xc1/0x1eb
[ 4083.116423]  [<ffffffff81174dea>] out_of_memory+0x4fa/0x500
[ 4083.116423]  [<ffffffff81179969>] __alloc_pages_nodemask+0x7a9/0x8a0
[ 4083.116423]  [<ffffffff811b8c77>] alloc_pages_vma+0x97/0x160
[ 4083.116423]  [<ffffffff8119b0c3>] handle_mm_fault+0x963/0xc20
[ 4083.116423]  [<ffffffff814ec802>] ? xfs_file_buffered_aio_write+0x1e2/0x240
[ 4083.116423]  [<ffffffff8108bf24>] __do_page_fault+0x1b4/0x570
[ 4083.116423]  [<ffffffff8119f5e1>] ? vma_merge+0x211/0x330
[ 4083.116423]  [<ffffffff811a0808>] ? do_brk+0x268/0x350
[ 4083.116423]  [<ffffffff8108c395>] trace_do_page_fault+0x45/0x100
[ 4083.116423]  [<ffffffff8108778e>] do_async_page_fault+0x1e/0xd0
[ 4083.116423]  [<ffffffff81d946f8>] async_page_fault+0x28/0x30
[ 4083.116423] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)

This needs to fail the allocation so that the process consuming all
the memory fails the page fault and SEGVs. Otherwise the OOM-killer
just runs wild killing everything else in the system until there's
nothing left to kill and the system panics.

> > > The default should be opposite IMO and only those who really
> > > require some guarantee should use a special flag for that purpose.
> > 
> > Yup, totally agree.
> 
> So how about something like the following change?  It restricts the
> allocator's endless OOM killing loop to __GFP_NOFAIL contexts, which
> are annotated in the callsite and thus easier to review for locks etc.
> Otherwise, the allocator tries only as long as page reclaim makes
> progress, the idea being that failures are handled gracefully in the
> callsites, and page faults restarting automatically anyway.  The OOM
> killing in that case is deferred to the end of the exception handler.
> 
> Preliminary testing confirms that the system is indeed trying just as
> hard before OOM killing in the page fault case.  However, it doesn't
> look like all callsites are prepared for failing smaller allocations:

Then we need to fix those bugs.

> [   55.553822] Out of memory: Kill process 240 (anonstress) score 158 or sacrifice child
> [   55.561787] Killed process 240 (anonstress) total-vm:1540044kB, anon-rss:1284068kB, file-rss:468kB
> [   55.571083] BUG: unable to handle kernel paging request at 00000000004006bd
> [   55.578156] IP: [<00000000004006bd>] 0x4006bd

That's an offset of >4MB from a null pointer. Doesn't seem likely
that it's caused by a failure of a order 0 allocation. The lack of
a stack trace is worrying, though....

> Obvious bugs aside, though, the thought of failing order-0 allocations
> after such a long time is scary...

The reliance on the OOM-killer to save the system from memory
starvation when users put the page cache under pressure via write(2)
is even scarier, IMO.

> ---
> From 0b204ee379aa5502a1c4dce5df51de96448b5163 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 22 Dec 2014 17:16:43 -0500
> Subject: [patch] mm: page_alloc: avoid page allocation vs. OOM killing
>  deadlock

Remind me to test whatever you've come up with in a couple of weeks
after the xmas break, though it's more likely to be late january
before i'll get to it given LCA will be keeping me busy in the new
year...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
