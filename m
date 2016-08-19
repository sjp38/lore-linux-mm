Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB0086B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 19:43:39 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so102030779pab.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 16:43:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id e17si10586989pag.66.2016.08.19.16.43.38
        for <linux-mm@kvack.org>;
        Fri, 19 Aug 2016 16:43:38 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
	<20160817005905.GA5372@bbox>
	<87inv0kv3r.fsf@yhuang-mobile.sh.intel.com>
	<20160817050743.GB5372@bbox>
	<1471454696.2888.94.camel@linux.intel.com>
	<20160818083955.GA12296@bbox>
	<8760qyq9jv.fsf@yhuang-mobile.sh.intel.com>
	<20160819004908.GC12296@bbox>
	<87vayxpgmq.fsf@yhuang-mobile.sh.intel.com>
	<20160819064426.GA15064@bbox>
Date: Fri, 19 Aug 2016 16:43:35 -0700
In-Reply-To: <20160819064426.GA15064@bbox> (Minchan Kim's message of "Fri, 19
	Aug 2016 15:44:26 +0900")
Message-ID: <87r39kpbo8.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Minchan Kim <minchan@kernel.org> writes:

> On Thu, Aug 18, 2016 at 08:44:13PM -0700, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > Hi Huang,
>> >
>> > On Thu, Aug 18, 2016 at 10:19:32AM -0700, Huang, Ying wrote:
>> >> Minchan Kim <minchan@kernel.org> writes:
>> >> 
>> >> > Hi Tim,
>> >> >
>> >> > On Wed, Aug 17, 2016 at 10:24:56AM -0700, Tim Chen wrote:
>> >> >> On Wed, 2016-08-17 at 14:07 +0900, Minchan Kim wrote:
>> >> >> > On Tue, Aug 16, 2016 at 07:06:00PM -0700, Huang, Ying wrote:
>> >> >> > > 
>> >> >> > >
>> >> >> > > > 
>> >> >> > > > I think Tim and me discussed about that a few weeks ago.
>> >> >> > > I work closely with Tim on swap optimization.?This patchset is the part
>> >> >> > > of our swap optimization plan.
>> >> >> > > 
>> >> >> > > > 
>> >> >> > > > Please search below topics.
>> >> >> > > > 
>> >> >> > > > [1] mm: Batch page reclamation under shink_page_list
>> >> >> > > > [2] mm: Cleanup - Reorganize the shrink_page_list code into smaller functions
>> >> >> > > > 
>> >> >> > > > It's different with yours which focused on THP swapping while the suggestion
>> >> >> > > > would be more general if we can do so it's worth to try it, I think.
>> >> >> > > I think the general optimization above will benefit both normal pages
>> >> >> > > and THP at least for now.?And I think there are no hard conflict
>> >> >> > > between those two patchsets.
>> >> >> > If we could do general optimzation, I guess THP swap without splitting
>> >> >> > would be more straight forward.
>> >> >> > 
>> >> >> > If we can reclaim batch a certain of pages all at once, it helps we can
>> >> >> > do scan_swap_map(si, SWAP_HAS_CACHE, nr_pages). The nr_pages could be
>> >> >> > greater or less than 512 pages. With that, scan_swap_map effectively
>> >> >> > search empty swap slots from scan_map or free cluser list.
>> >> >> > Then, needed part from your patchset is to just delay splitting of THP.
>> >> >> > 
>> >> >> > > 
>> >> >> > > 
>> >> >> > > The THP swap has more opportunity to be optimized, because we can batch
>> >> >> > > 512 operations together more easily.?For full THP swap support, unmap a
>> >> >> > > THP could be more efficient with only one swap count operation instead
>> >> >> > > of 512, so do many other operations, such as add/remove from swap cache
>> >> >> > > with multi-order radix tree etc.?And it will help memory fragmentation.
>> >> >> > > THP can be kept after swapping out/in, need not to rebuild THP via
>> >> >> > > khugepaged.
>> >> >> > It seems you increased cluster size to 512 and search a empty cluster
>> >> >> > for a THP swap. With that approach, I have a concern that once clusters
>> >> >> > will be fragmented, THP swap support doesn't take benefit at all.
>> >> >> > 
>> >> >> > Why do we need a empty cluster for swapping out 512 pages?
>> >> >> > IOW, below case could work for the goal.
>> >> >> > 
>> >> >> > A : Allocated slot
>> >> >> > F : Free slot
>> >> >> > 
>> >> >> > cluster A?cluster B
>> >> >> > AAAAFFFF?-?FFFFAAAA
>> >> >> > 
>> >> >> > That's one of the reason I suggested batch reclaim work first and
>> >> >> > support THP swap based on it. With that, scan_swap_map can be aware of nr_pages
>> >> >> > and selects right clusters.
>> >> >> > 
>> >> >> > With the approach, justfication of THP swap support would be easier, too.
>> >> >> > IOW, I'm not sure how only THP swap support is valuable in real workload.
>> >> >> > 
>> >> >> > Anyways, that's just my two cents.
>> >> >> 
>> >> >> Minchan,
>> >> >> 
>> >> >> Scanning for contiguous slots that span clusters may take quite a
>> >> >> long time under fragmentation, and may eventually fail. In that case the addition scan
>> >> >> time overhead may go to waste and defeat the purpose of fast swapping of large page.
>> >> >> 
>> >> >> The empty cluster lookup on the other hand is very fast.
>> >> >> We treat the empty cluster available case as an opportunity for fast path
>> >> >> swap out of large page. Otherwise, we'll revert to the current
>> >> >> slow path behavior of breaking into normal pages so there's no
>> >> >> regression, and we may get speed up. We can be considerably faster when a lot of large
>> >> >> pages are used. 
>> >> >
>> >> > I didn't mean we should search scan_swap_map firstly without peeking
>> >> > free cluster but what I wanted was we might abstract it into
>> >> > scan_swap_map.
>> >> >
>> >> > For example, if nr_pages is greather than the size of cluster, we can
>> >> > get empty cluster first and nr_pages - sizeof(cluster) for other free
>> >> > cluster or scanning of current CPU per-cpu cluster. If we cannot find
>> >> > used slot during scanning, we can bail out simply. Then, although we
>> >> > fail to get all* contiguous slots, we get a certain of contiguous slots
>> >> > so it would be benefit for seq write and lock batching point of view
>> >> > at the cost of a little scanning. And it's not specific to THP algorighm.
>> >> 
>> >> Firstly, if my understanding were correct, to batch the normal pages
>> >> swapping out, the swap slots need not to be continuous.  But for the THP
>> >> swap support, we need the continuous swap slots.  So I think the
>> >> requirements are quite different between them.
>> >
>> > Hmm, I don't understand.
>> >
>> > Let's think about swap slot management layer point of view.
>> > It doesn't need to take care of that a amount of batch request is caused
>> > by a thp page or multiple normal pages.
>> >
>> > A matter is just that VM now asks multiple swap slots for seveal LRU-order
>> > pages so swap slot management tries to allocate several slots in a lock.
>> > Sure, it would be great if slots are consecutive fully because it means
>> > it's fast big sequential write as well as readahead together ideally.
>> > However, it would be better even if we didn't get consecutive slots because
>> > we get muliple slots all at once by batch.
>> >
>> > It's not a THP specific requirement, I think.
>> > Currenlty, SWAP_CLUSTER_MAX might be too small to get a benefit by
>> > normal page batch but it could be changed later once we implement batching
>> > logic nicely.
>> 
>> Consecutive or not may influence the performance of the swap slots
>> allocation function greatly.  For example, there is some non-consecutive
>> swap slots at the begin of the swap space, and some consecutive swap
>> slots at the end of the swap space.  If the consecutive swap slots are
>> needed, the function may need to scan from the begin to the end.  If
>> non-consecutive swap slots are required, just return the swap slots at
>> the begin of the swap space.
>
> Don't get me wrong. I never said consecutive swap slot allocation is
> not important and should scan swap_map fully for searching consecutive
> swap slot.

Sorry, I am confused.  For multiple normal page swapping,
Non-consecutive allocation is important or not?  If both consecutive and
non-consecutive allocation are important, how to balance between them?
Restrict the scanning number?

For the THP swap, consecutive is mandatory.  We need to add a parameter
to specify that at least so that the allocator can try harder and use
free cluster directly?

For multiple normal pages swapping, exactly consecutive swap slots
allocation isn't so important.  Just nearby enough should be OK for
them.  For example in the same swap cluster, so that it can be processed
in lower level disk hardware with high efficiency (same disk segment
etc.).

> Both multiple normal page swap and a THP swap, consecutive swap slot
> allocation is important so that it's a same requirement so I want to
> abstract it regardless of THP swap.
>
>> 
>> >> And with the current design of the swap space management, it is quite
>> >> hard to implement allocating nr_pages continuous free swap slots.  To
>> >> reduce the contention of sis->lock, even to scan one free swap slot, the
>> >> sis->lock is unlocked during scanning.  When we scan nr_pages free swap
>> >> slots, and there are no nr_pages continuous free swap slots, we need to
>> >> scan from sis->lowest_bit to sis->highest_bit, and record the largest
>> >> continuous free swap slots.  But when we lock sis->lock again to check,
>> >> some swap slot inside the largest continuous free swap slots we found
>> >> may be allocated by other processes.  So we may end up with a much
>> >> smaller number of swap slots or we need to startover again.  So I think
>> >> the simpler solution is to
>> >> 
>> >> - When a whole cluster is requested (for the THP), try to allocate a
>> >>   free cluster.  Give up if there are no free clusters.
>> >
>> > One thing I'm afraid that it would consume free clusters very fast
>> > if adjacent pages around a faulted one doesn't have same hottness/
>> > lifetime. Once it happens, we can't get benefit any more.
>> > IMO, it's too conservative and might be worse for the fragment point
>> > of view.
>> 
>> It is possible.  But I think we should start from the simple solution
>> firstly.  Instead of jumping to the perfect solution directly.
>> Especially when the simple solution is a subset of the perfect solution.
>> Do you agree?
>
> If simple solution works well and is hard to prove it's not bad than as-is,
> I agree. But my concern is about that it would consume free clusters so fast
> that it can affect badly for other workload.

If we allocate consecutive swap slots other than free clusters for the
THP, the free clusters will be consumed quickly too.  Because not all
sub-pages may be freed together.  The swap space will become fragmented
anyway.  The situation may be better a little, but I don't think there
will be huge difference here.  There may be situations that 2
consecutive non-free clusters to have 512 consecutive swap slots, but I
don't think that will be many.

I think we need some other ways to deal with fragmented swap problem.
For example, one way is to have a list for not fully used cluster list
and use that for per_cpu cluster too.  Another way is starting to
reclaim swap space during swapping in if the swap space becomes
fragmented.  And swapping in 2M page together and free the cluster
backing it could be a good way to help fragmentation.

And I think, my change here will not trigger regression.  For swapping
out the THP, current code has almost the same behavior as for free
clusters with my code.  The percpu cluster will be used up, then next
free cluster is used.  So for each THP, one free cluster will be
consumed.

>> There are some other difficulties not to use the swap cluster to hold
>> the THP swapped out for the full THP swap support (without splitting).
>> 
>> The THP could be mapped in both PMD and PTE.  After the THP is swapped
>> out.  There may be swap entry in PMD and PTE too.  If a non-head PTE is
>> accessed, how do we know where is the first swap slot for the THP, so
>> that we can swap in the whole THP?
>
> You mean you want to swapin 2M pages all at once? Hmm, I'm not sure
> it's a good idea. We don't have any evidence 512 pages have same time
> locality. They were just LRU in-order due to split implementation,
> not time locality. A thing we can bet is any processes sharing the THP
> doesn't touch a subpage in 512 pages so it's really *cold*.
> For such cold 512 page swap-in, I am really not sure.

On a system with /sys/kernel/mm/transparent_hugepage/enabled set to
always, most anonymous pages could be THP.  It could be helpful to swap
out/in THP together.  Do you think so?  And because it is 2M sequential
read, the performance is good.  Only more memory may be needed, but you
use more memory if you use THP anyway.

My point is, this depends on the workload.  Swapping out/in THP could
benefit quite some workloads.  We may provide a choice for the users to
turn off it when necessary.  But I don't think we should make it
impossible at all.  Do you agree?
 
>> We can have a flag in cluster_info->flag to mark whether the swap
>> cluster backing a THP.  So swap in readahead can avoid to read ahead the
>> THP, or it can read ahead the whole THP instead of just several
>> sub-pages of the THP.
>> 
>> And if we use one swap cluster for each THP, we can use cluster_info->data
>> to hold compound map number.  That is very convenient.
>
> Huang,
>
> If you think my points are enough valid, just continue your work
> regardless of my comment. I don't want to waste your time if it helps
> your workload really. And I will defer the decision to other MM people.

I think your comments are good for me.  Thanks a lot for your comments.
We may have some different idea about requirement.  But I think the
discussion is good.  If I give up swapping in 2M THP as a whole.  You
solution looks good for me now.  We can use cluster_info->data to
accelerate scanning, and we can give up scanning after some trying to
avoid too much lock contention.

> What I just wanted is to make swap batch for normal pages first and
> then support THP swap based upon it because normal page batching would
> more general optimization for us and I thought it will make your work
> more simple.

The problem is that swapping in 2M THP requirement makes it hard for the
THP swap support to use the swap allocation mechanism for normal pages
swapping batching.  But there may be some other places that the THP swap
can take advantage of.  So I think it may be more reasonable for the
normal pages swapping optimization go firstly.  But we can discuss the
basic design of the THP swapping.  Do you agree?  For example, whether
supporting swapping in 2M THP as a whole?  If so, how to do it?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
