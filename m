Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id EC6BE6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 02:53:24 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id g203so54442631iof.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 23:53:24 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s95si3272554ioe.115.2016.03.03.23.53.23
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 23:53:24 -0800 (PST)
Date: Fri, 4 Mar 2016 16:53:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160304075350.GC13317@js1304-P5Q-DELUXE>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603030039430.23352@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LSU.2.11.1603030039430.23352@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 03, 2016 at 01:54:43AM -0800, Hugh Dickins wrote:
> On Tue, 1 Mar 2016, Michal Hocko wrote:
> > [Adding Vlastimil and Joonsoo for compaction related things - this was a
> > large thread but the more interesting part starts with
> > http://lkml.kernel.org/r/alpine.LSU.2.11.1602241832160.15564@eggly.anvils]
> > 
> > On Mon 29-02-16 23:29:06, Hugh Dickins wrote:
> > > On Mon, 29 Feb 2016, Michal Hocko wrote:
> > > > On Wed 24-02-16 19:47:06, Hugh Dickins wrote:
> > > > [...]
> > > > > Boot with mem=1G (or boot your usual way, and do something to occupy
> > > > > most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
> > > > > way to gobble up most of the memory, though it's not how I've done it).
> > > > > 
> > > > > Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
> > > > > kernel source tree into a tmpfs: size=2G is more than enough.
> > > > > make defconfig there, then make -j20.
> > > > > 
> > > > > On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.
> > > > > 
> > > > > Except that you'll probably need to fiddle around with that j20,
> > > > > it's true for my laptop but not for my workstation.  j20 just happens
> > > > > to be what I've had there for years, that I now see breaking down
> > > > > (I can lower to j6 to proceed, perhaps could go a bit higher,
> > > > > but it still doesn't exercise swap very much).
> > > > 
> > > > I have tried to reproduce and failed in a virtual on my laptop. I
> > > > will try with another host with more CPUs (because my laptop has only
> > > > two). Just for the record I did: boot 1G machine in kvm, I have 2G swap
> 
> I've found that the number of CPUs makes quite a difference - I have 4.
> 
> And another difference between us may be in our configs: on this laptop
> I had lots of debug options on (including DEBUG_VM, DEBUG_SPINLOCK and
> PROVE_LOCKING, though not DEBUG_PAGEALLOC), which approximately doubles
> the size of each shmem_inode (and those of course are not swappable).
> 
> I found that I could avoid the OOM if I ran the "make -j20" on a
> kernel without all those debug options, and booted with nr_cpus=2.
> And currently I'm booting the kernel with the debug options in,
> but with nr_cpus=2, which does still OOM (whereas not if nr_cpus=1).
> 
> Maybe in the OOM rework, threads are cancelling each other's progress
> more destructively, where before they co-operated to some extent?
> 
> (All that is on the laptop.  The G5 is still busy full-time bisecting
> a powerpc issue: I know it was OOMing with the rework, but I have not
> verified the effect of nr_cpus on it.  My x86 workstation has not been
> OOMing with the rework - I think that means that I've not been exerting
> as much memory pressure on it as I'd thought, that it copes with the load
> better, and would only show the difference if I loaded it more heavily.)
> 
> > > > and reserve 800M for hugetlb pages (I got 445 of them). Then I extract
> > > > the kernel source to tmpfs (-o size=2G), make defconfig and make -j20
> > > > (16, 10 no difference really). I was also collecting vmstat in the
> > > > background. The compilation takes ages but the behavior seems consistent
> > > > and stable.
> > > 
> > > Thanks a lot for giving it a go.
> > > 
> > > I'm puzzled.  445 hugetlb pages in 800M surprises me: some of them
> > > are less than 2M big??  But probably that's just a misunderstanding
> > > or typo somewhere.
> > 
> > A typo. 445 was from 900M test which I was doing while writing the
> > email. Sorry about the confusion.
> 
> That makes more sense!  Though I'm still amazed that you got anywhere,
> taking so much of the usable memory out.
> 
> > 
> > > Ignoring that, you're successfully doing a make -20 defconfig build
> > > in tmpfs, with only 224M of RAM available, plus 2G of swap?  I'm not
> > > at all surprised that it takes ages, but I am very surprised that it
> > > does not OOM.  I suppose by rights it ought not to OOM, the built
> > > tree occupies only a little more than 1G, so you do have enough swap;
> > > but I wouldn't get anywhere near that myself without OOMing - I give
> > > myself 1G of RAM (well, minus whatever the booted system takes up)
> > > to do that build in, four times your RAM, yet in my case it OOMs.
> > >
> > > That source tree alone occupies more than 700M, so just copying it
> > > into your tmpfs would take a long time. 
> > 
> > OK, I just found out that I was cheating a bit. I was building
> > linux-3.7-rc5.tar.bz2 which is smaller:
> > $ du -sh /mnt/tmpfs/linux-3.7-rc5/
> > 537M    /mnt/tmpfs/linux-3.7-rc5/
> 
> Right, I have a habit like that too; but my habitual testing still
> uses the 2.6.24 source tree, which is rather too old to ask others
> to reproduce with - but we both find that the kernel source tree
> keeps growing, and prefer to stick with something of a fixed size.
> 
> > 
> > and after the defconfig build:
> > $ free
> >              total       used       free     shared    buffers     cached
> > Mem:       1008460     941904      66556          0       5092     806760
> > -/+ buffers/cache:     130052     878408
> > Swap:      2097148      42648    2054500
> > $ du -sh linux-3.7-rc5/
> > 799M    linux-3.7-rc5/
> > 
> > Sorry about that but this is what my other tests were using and I forgot
> > to check. Now let's try the same with the current linus tree:
> > host $ git archive v4.5-rc6 --prefix=linux-4.5-rc6/ | bzip2 > linux-4.5-rc6.tar.bz2
> > $ du -sh /mnt/tmpfs/linux-4.5-rc6/
> > 707M    /mnt/tmpfs/linux-4.5-rc6/
> > $ free
> >              total       used       free     shared    buffers     cached
> > Mem:       1008460     962976      45484          0       7236     820064
> 
> I guess we have different versions of "free": mine shows Shmem as shared,
> but yours appears to be an older version, just showing 0.
> 
> > -/+ buffers/cache:     135676     872784
> > Swap:      2097148         16    2097132
> > $ time make -j20 > /dev/null
> > drivers/acpi/property.c: In function a??acpi_data_prop_reada??:
> > drivers/acpi/property.c:745:8: warning: a??obja?? may be used uninitialized in this function [-Wmaybe-uninitialized]
> > 
> > real    8m36.621s
> > user    14m1.642s
> > sys     2m45.238s
> > 
> > so I wasn't cheating all that much...
> > 
> > > I'd expect a build in 224M
> > > RAM plus 2G of swap to take so long, that I'd be very grateful to be
> > > OOM killed, even if there is technically enough space.  Unless
> > > perhaps it's some superfast swap that you have?
> > 
> > the swap partition is a standard qcow image stored on my SSD disk. So
> > I guess the IO should be quite fast. This smells like a potential
> > contributor because my reclaim seems to be much faster and that should
> > lead to a more efficient reclaim (in the scanned/reclaimed sense).
> > I realize I might be boring already when blaming compaction but let me
> > try again ;)
> > $ grep compact /proc/vmstat 
> > compact_migrate_scanned 113983
> > compact_free_scanned 1433503
> > compact_isolated 134307
> > compact_stall 128
> > compact_fail 26
> > compact_success 102
> > compact_kcompatd_wake 0
> > 
> > So the whole load has done the direct compaction only 128 times during
> > that test. This doesn't sound much to me
> > $ grep allocstall /proc/vmstat
> > allocstall 1061
> > 
> > we entered the direct reclaim much more but most of the load will be
> > order-0 so this might be still ok. So I've tried the following:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1993894b4219..107d444afdb1 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2910,6 +2910,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  						mode, contended_compaction);
> >  	current->flags &= ~PF_MEMALLOC;
> >  
> > +	if (order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER)
> > +		trace_printk("order:%d gfp_mask:%pGg compact_result:%lu\n", order, &gfp_mask, compact_result);
> > +
> >  	switch (compact_result) {
> >  	case COMPACT_DEFERRED:
> >  		*deferred_compaction = true;
> > 
> > And the result was:
> > $ cat /debug/tracing/trace_pipe | tee ~/trace.log
> >              gcc-8707  [001] ....   137.946370: __alloc_pages_direct_compact: order:2 gfp_mask:GFP_KERNEL_ACCOUNT|__GFP_NOTRACK compact_result:1
> >              gcc-8726  [000] ....   138.528571: __alloc_pages_direct_compact: order:2 gfp_mask:GFP_KERNEL_ACCOUNT|__GFP_NOTRACK compact_result:1
> > 
> > this shows that order-2 memory pressure is not overly high in my
> > setup. Both attempts ended up COMPACT_SKIPPED which is interesting.
> > 
> > So I went back to 800M of hugetlb pages and tried again. It took ages
> > so I have interrupted that after one hour (there was still no OOM). The
> > trace log is quite interesting regardless:
> > $ wc -l ~/trace.log
> > 371 /root/trace.log
> > 
> > $ grep compact_stall /proc/vmstat 
> > compact_stall 190
> > 
> > so the compaction was still ignored more than actually invoked for
> > !costly allocations:
> > sed 's@.*order:\([[:digit:]]\).* compact_result:\([[:digit:]]\)@\1 \2@' ~/trace.log | sort | uniq -c 
> >     190 2 1
> >     122 2 3
> >      59 2 4
> > 
> > #define COMPACT_SKIPPED         1               
> > #define COMPACT_PARTIAL         3
> > #define COMPACT_COMPLETE        4
> > 
> > that means that compaction is even not tried in half cases! This
> > doesn't sounds right to me, especially when we are talking about
> > <= PAGE_ALLOC_COSTLY_ORDER requests which are implicitly nofail, because
> > then we simply rely on the order-0 reclaim to automagically form higher
> > blocks. This might indeed work when we retry many times but I guess this
> > is not a good approach. It leads to a excessive reclaim and the stall
> > for allocation can be really large.
> > 
> > One of the suspicious places is __compaction_suitable which does order-0
> > watermark check (increased by 2<<order). I have put another trace_printk
> > there and it clearly pointed out this was the case.
> > 
> > So I have tried the following:
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 4d99e1f5055c..7364e48cf69a 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1276,6 +1276,9 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
> >  								alloc_flags))
> >  		return COMPACT_PARTIAL;
> >  
> > +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> > +		return COMPACT_CONTINUE;
> > +
> 
> I gave that a try just now, but it didn't help me: OOMed much sooner,
> after doing half as much work.  (FWIW, I have been including your other
> patch, the "Andrew, could you queue this one as well, please" patch.)
> 
> I do agree that compaction appears to have closed down when we OOM:
> taking that along with my nr_cpus remark (and the make -jNumber),
> are parallel compactions interfering with each other destructively,
> in a way that they did not before the rework?
> 
> >  	/*
> >  	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
> >  	 * This is because during migration, copies of pages need to be
> > 
> > and retried the same test (without huge pages):
> > $ time make -j20 > /dev/null
> > 
> > real    8m46.626s
> > user    14m15.823s
> > sys     2m45.471s
> > 
> > the time increased but I haven't checked how stable the result is. 
> 
> But I didn't investigate its stability either, may have judged against
> it too soon.
> 
> > 
> > $ grep compact /proc/vmstat
> > compact_migrate_scanned 139822
> > compact_free_scanned 1661642
> > compact_isolated 139407
> > compact_stall 129
> > compact_fail 58
> > compact_success 71
> > compact_kcompatd_wake 1
> 
> I have not seen any compact_kcompatd_wakes at all:
> perhaps we're too busy compacting directly.
> 
> (Vlastimil, there's a "c" missing from that name, it should be
> "compact_kcompactd_wake" - though "compact_daemon_wake" might be nicer.)
> 
> > 
> > $ grep allocstall /proc/vmstat
> > allocstall 1665
> > 
> > this is worse because we have scanned more pages for migration but the
> > overall success rate was much smaller and the direct reclaim was invoked
> > more. I do not have a good theory for that and will play with this some
> > more. Maybe other changes are needed deeper in the compaction code.
> > 
> > I will play with this some more but I would be really interested to hear
> > whether this helped Hugh with his setup. Vlastimi, Joonsoo does this
> > even make sense to you?
> 
> It didn't help me; but I do suspect you're right to be worrying about
> the treatment of compaction of 0 < order <= PAGE_ALLOC_COSTLY_ORDER.
> 
> > 
> > > I was only suggesting to allocate hugetlb pages, if you preferred
> > > not to reboot with artificially reduced RAM.  Not an issue if you're
> > > booting VMs.
> > 
> > Ohh, I see.
> 
> I've attached vmstats.xz, output from your read_vmstat proggy;
> together with oom.xz, the dmesg for the OOM in question.

Hello, Hugh.

I guess following things from your vmstat.
it could be wrong so please be careful. :)

Before OOM happens,

pgmigrate_success 230007
pgmigrate_fail 94
compact_migrate_scanned 422734
compact_free_scanned 9277915
compact_isolated 469308
compact_stall 370
compact_fail 291
compact_success 79
...
balloon_deflate 0

After OOM happens,

pgmigrate_success 230007                                                                              
pgmigrate_fail 94                                                                                     
compact_migrate_scanned 424920                                                                        
compact_free_scanned 9278408                                                                          
compact_isolated 469472                                                                               
compact_stall 377                                                                                     
compact_fail 297                                                                                      
compact_success 80  
...
balloon_deflate 1

This shows that we tried compaction (compaction stall increases).
Increased compact_isolated tell us that we isolated something for
migration. But, pgmigrate_xxx isn't changed and it means that we
didn't do any actual migration. It could happen when we can't find
freepage. compact_free_scanned changed a little so it seems that
there are many pageblocks with skipbit set and compaction would skip
almost range in this case. This skipbit could be reset when we try more
and reach the reset threshold. How about do test
with MAX_RECLAIM_RETRIES 128 or something larger to see that makes
some difference?

Thanks.

> 
> I hacked out_of_memory() to count_vm_event(BALLOON_DEFLATE),
> that being a count that's always 0 for me: so when you see
> "balloon_deflate 1" towards the end, that's where the OOM
> kill came in, and shortly after I Ctrl-C'ed.
> 
> I hope you can get more out of it than I have - thanks!
> 
> Hugh



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
