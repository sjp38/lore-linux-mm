Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0639F6B0253
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 05:43:21 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l65so132484552wmf.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 02:43:20 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id cf10si45302928wjc.167.2016.01.19.02.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 02:43:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 5A2F21C1866
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 10:43:19 +0000 (GMT)
Date: Tue, 19 Jan 2016 10:43:17 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20160119104317.GE10802@techsingularity.net>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
 <20160118110147.GB10802@techsingularity.net>
 <20160118221900.GB3181@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160118221900.GB3181@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

On Mon, Jan 18, 2016 at 11:19:00PM +0100, Andrea Arcangeli wrote:
> Hello Mel,
> 
> On Mon, Jan 18, 2016 at 11:01:47AM +0000, Mel Gorman wrote:
> > I didn't read too much into the history of this patch or the
> > implementation so take anything I say with a grain of salt.
> > 
> > In the page-migration case, the obvious beneficiary of reduced IPI counts
> > is memory compaction and automatic NUMA balancing. For automatic NUMA
> > balancing, if a page is heavily shared then there is a possibility that
> > there is no optimal home node for the data and that no balancing should
> > take place. For compaction, it depends on whether it's for a THP allocation
> > or not -- heavy amounts of migration work is unlikely to be offset by THP
> > usage although this is a matter of opinion.
> > 
> > In the case of memory compaction, it would make sense to limit the length
> > of the walk and abort if it the mapcount is too high particularly if the
> > compaction is for a THP allocation. In the case of THP, the cost of a long
> > rmap is not necessarily going to be offset by THP usage.
> 
> Agreed that it wouldn't be worth migrating a KSM page with massive
> sharing just to allocate one more THP page and that limiting the
> length of the rmap_walk would avoid the hangs for compaction.
> 
> The real problem is what happens after you stop migrating KSM pages.
> 
> If you limit the length of the rmap_walk with a "magical" value (that
> I would have no clue how to set), you end up with compaction being
> entirely disabled and wasting CPU as well, if you have a bit too many
> KSM pages in the system with mapcount above the "magical" value.
> 
> If compaction can be disabled all your memblock precious work becomes
> useless.
> 
> After the memblocks become useless, the movable zone also becomes
> useless (as all anonymous movable pages in the system can suddenly
> becomes non movable and go above the "magical" rmap_walk limit).
> 
> Then the memory offlining stops to work as well (it could take
> months in the worst case?).
> 

The focus was primarily on reclaim. It was expected that memory offline
and memory poisoning would continue using the full rmap walk as it has
no option.

> CMA stops working too so certain drivers will stop working. How can it
> be ok if you enable KSM and CMA entirely breaks? Because this is what
> happens if you stop migrating KSM pages if the rmap_walk would exceed
> the "magical" limit.
> 
> Adding a sharing limit in KSM instead allows to keep KSM turned on at
> all times at 100% CPU load and it guarantees nothing KSM does could
> ever interfere with all other VM features. Everything is just
> guaranteed to work at all times.
> 

I'm not disagreeing with you. However, limiting the rmap walk for reclaim
also benefits any workload with large amounts of shared pages.

> In fact if we were not to add the sharing limit to KSM, I think we
> would be better off to consider KSM pages unmovable like slab caches
> and drop the KSM migration entirely. So that KSM pages are restricted
> to those unmovable memblocks. At least compaction/memoryofflining/CMA
> would still have a slight chance to keep working despite KSM was enabled.
> 
> > That said, it occurs to me that a full rmap walk is not necessary in all
> > cases and may be a more obvious starting point. For page reclaim, it only
> > matters if it's mapped once.  page_referenced() does not register a ->done
> > handle and the callers only care about a positive count. One optimisation
> > for reclaim would be to return when referenced > 0 and be done with it. That
> > would limit the length of the walk in *some* cases and still activate the
> > page as expected.
> 
> Limiting the page_referenced() rmap walk length was my first idea as
> well. We could also try to rotate the rmap_items list so the next loop
> starts with a new batch of pagetables and by retrying we would have a
> chance to clear all accessed bits for all pagetables eventually. The
> rmap_item->hlist is an hlist however, so rotation isn't possible at
> this time and we'd waste 8 bytes per stable node metadata if we were
> to add it. Still it would be trivial to add the rotation.
> 
> However even the most benign change described above, can result in
> false positive OOM.

Scanning at max priority could force a full rmap walk to avoid premature OOM.
At this point, the idea would fallback to the full cost we have today.
It does not completely solve the problem you are worried about, it mitigates
it and for cases other than KSM.

> > There still would be cases where a full walk is necessary so this idea does
> > not fix all problems of concern but it would help reclaim in the case where
> > there are many KSM pages that are in use in a relatively obvious manner. More
> > importantly, such a modification would benefit cases other than KSM.
> 
> What I'm afraid is that it would risk to destabilize the VM if we
> limit the rmap_walk length. That would exponentially increase the
> chance page_referenced() returns true at all times in turn not really
> solving much if too many KSM pages are shared above the "magical" rmap
> walk length. I'm not sure if that would benefit other cases either as
> they would end up in the same corner case.
> 

Eventually yes albeit it gets deferred until near OOM time and also
covers the heavily shared pages cases instead of just KSM.

> If instead we enforce a KSM sharing limit, there's no point in taking
> any more risk and sticking to the current model of atomic rmap_walks
> that simulates a physical page accessed bit, certainly looks much
> safer to me.
> 
> I evaluated those possible VM modifications before adding the sharing
> limit to KSM and they didn't look definitive to me and there was no
> way I could guarantee the VM not to end up in weird corner cases
> unless I limited the KSM sharing limit in the first place.
> 

By all means ignore the suggestion. It was intended to mitigate the problem
to see if enforcing a KSM sharing limit is always necessary or if it's
just necessary to handle the case where the system is near OOM or the
migration is absolutly required.

> Something that instead I definitely like is the reduction of the IPIs
> in the rmap_walks, I mean your work and Hugh's patch that extends it
> to page_migration. That looks just great and it has zero risk to
> destabilize the VM, but it's also orthogonal to the KSM sharing limit.
> 

Agreed. Fewer IPIs on a system that still works properly is an
unconditional win.

> Not clearing all accessed bits in page_referenced or failing KSM
> migration depending on a magic rmap_walk limit I don't like very much.
> They can certainly hide the problem in some case: they would work
> absolutely great if there's just 1 KSM page in the system over the
> "magical" limit, but I don't think they've drawbacks and it looks
> flakey if too many KSM pages are above the "magical" limit. The KSM
> sharing limit value is way less magical than that: if it's set too low
> you can only lose some memory, you won't risk VM malfunction.
> 

Ok.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
