Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 44A626B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:01:51 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id u188so98975696wmu.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 03:01:51 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id bi2si37580029wjc.200.2016.01.18.03.01.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jan 2016 03:01:49 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 30DE698EE8
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 11:01:49 +0000 (UTC)
Date: Mon, 18 Jan 2016 11:01:47 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20160118110147.GB10802@techsingularity.net>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, Jan 14, 2016 at 03:36:56PM -0800, Hugh Dickins wrote:
> > but at least for page_migration in
> > the KSM case (used by hard NUMA bindings, compaction and NUMA
> > balancing) it may be inevitable to send lots of IPIs if each
> > rmap_item->mm is active on a different CPU and there are lots of
> > CPUs. Even if we ignore the IPI delivery cost, we've still to walk the
> > whole KSM rmap list, so we can't allow millions or billions (ulimited)
>                                                               (unlimited)
> > number of entries in the KSM stable_node rmap_item lists.
> 
> You've got me fired up.  Mel's recent 72b252aed506 "mm: send one IPI per
> CPU to TLB flush all entries after unmapping pages" and nearby commits
> are very much to the point here; but because his first draft was unsafe
> in the page migration area, he dropped that, and ended up submitting
> for page reclaim alone.
> 

I didn't read too much into the history of this patch or the
implementation so take anything I say with a grain of salt.

In the page-migration case, the obvious beneficiary of reduced IPI counts
is memory compaction and automatic NUMA balancing. For automatic NUMA
balancing, if a page is heavily shared then there is a possibility that
there is no optimal home node for the data and that no balancing should
take place. For compaction, it depends on whether it's for a THP allocation
or not -- heavy amounts of migration work is unlikely to be offset by THP
usage although this is a matter of opinion.

In the case of memory compaction, it would make sense to limit the length
of the walk and abort if it the mapcount is too high particularly if the
compaction is for a THP allocation. In the case of THP, the cost of a long
rmap is not necessarily going to be offset by THP usage.


> That's the first low-hanging fruit: we should apply Mel's batching
> to page migration; and it's become clear enough in my mind, that I'm
> now impatient to try it myself (but maybe Mel will respond if he has
> a patch for it already).  If I can't post a patch for that early next
> week, someone else take over (or preempt me); yes, there's all kinds
> of other things I should be doing instead, but this is too tempting.
> 

I never followed up as I felt the benefit was marginal but I did not take
KSM into account.

That said, it occurs to me that a full rmap walk is not necessary in all
cases and may be a more obvious starting point. For page reclaim, it only
matters if it's mapped once.  page_referenced() does not register a ->done
handle and the callers only care about a positive count. One optimisation
for reclaim would be to return when referenced > 0 and be done with it. That
would limit the length of the walk in *some* cases and still activate the
page as expected.

The full walk will still be necessary if the page is unused and is a reclaim
candidate so there still may be grounds for limiting the length of the rmap
walk so the unmap does not take too long but we'd avoid active pages quickly.

Hugh touched off this point and I mostly agree with him -- in some
instances of page migration, it would be ok to return when referenced >
arbitrary_threshold and just assume it's not worth the cost of migrating
when the mapcount is too high. This would be fine for compaction for THP at
least as the cost large rmap walks for reclaim followed by IPIs is unlikely
to be offset by THP usage even if it succeeds afterwards. It may be ok
for compaction triggered for high-order allocations. One obvious exception
would be page migration due to memory poisoning where it does not matter
what the cost of migrating is if the memory is faulty.  Another obvious
exception would be mbind where it may be better to stop sharing in such
cases that Hugh mentioned already.

There still would be cases where a full walk is necessary so this idea does
not fix all problems of concern but it would help reclaim in the case where
there are many KSM pages that are in use in a relatively obvious manner. More
importantly, such a modification would benefit cases other than KSM.

I recognise that this is side-stepping the problem -- migration cost is
too high and while Andrea's patch may reduce that cost, there is some
grounds for simply not trying to migrate it in the first place.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
