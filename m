Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 844806B0254
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 17:19:04 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id o11so566839034qge.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 14:19:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 88si33305627qgz.40.2016.01.18.14.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 14:19:03 -0800 (PST)
Date: Mon, 18 Jan 2016 23:19:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20160118221900.GB3181@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
 <20160118110147.GB10802@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160118110147.GB10802@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

Hello Mel,

On Mon, Jan 18, 2016 at 11:01:47AM +0000, Mel Gorman wrote:
> I didn't read too much into the history of this patch or the
> implementation so take anything I say with a grain of salt.
> 
> In the page-migration case, the obvious beneficiary of reduced IPI counts
> is memory compaction and automatic NUMA balancing. For automatic NUMA
> balancing, if a page is heavily shared then there is a possibility that
> there is no optimal home node for the data and that no balancing should
> take place. For compaction, it depends on whether it's for a THP allocation
> or not -- heavy amounts of migration work is unlikely to be offset by THP
> usage although this is a matter of opinion.
> 
> In the case of memory compaction, it would make sense to limit the length
> of the walk and abort if it the mapcount is too high particularly if the
> compaction is for a THP allocation. In the case of THP, the cost of a long
> rmap is not necessarily going to be offset by THP usage.

Agreed that it wouldn't be worth migrating a KSM page with massive
sharing just to allocate one more THP page and that limiting the
length of the rmap_walk would avoid the hangs for compaction.

The real problem is what happens after you stop migrating KSM pages.

If you limit the length of the rmap_walk with a "magical" value (that
I would have no clue how to set), you end up with compaction being
entirely disabled and wasting CPU as well, if you have a bit too many
KSM pages in the system with mapcount above the "magical" value.

If compaction can be disabled all your memblock precious work becomes
useless.

After the memblocks become useless, the movable zone also becomes
useless (as all anonymous movable pages in the system can suddenly
becomes non movable and go above the "magical" rmap_walk limit).

Then the memory offlining stops to work as well (it could take
months in the worst case?).

CMA stops working too so certain drivers will stop working. How can it
be ok if you enable KSM and CMA entirely breaks? Because this is what
happens if you stop migrating KSM pages if the rmap_walk would exceed
the "magical" limit.

Adding a sharing limit in KSM instead allows to keep KSM turned on at
all times at 100% CPU load and it guarantees nothing KSM does could
ever interfere with all other VM features. Everything is just
guaranteed to work at all times.

In fact if we were not to add the sharing limit to KSM, I think we
would be better off to consider KSM pages unmovable like slab caches
and drop the KSM migration entirely. So that KSM pages are restricted
to those unmovable memblocks. At least compaction/memoryofflining/CMA
would still have a slight chance to keep working despite KSM was enabled.

> That said, it occurs to me that a full rmap walk is not necessary in all
> cases and may be a more obvious starting point. For page reclaim, it only
> matters if it's mapped once.  page_referenced() does not register a ->done
> handle and the callers only care about a positive count. One optimisation
> for reclaim would be to return when referenced > 0 and be done with it. That
> would limit the length of the walk in *some* cases and still activate the
> page as expected.

Limiting the page_referenced() rmap walk length was my first idea as
well. We could also try to rotate the rmap_items list so the next loop
starts with a new batch of pagetables and by retrying we would have a
chance to clear all accessed bits for all pagetables eventually. The
rmap_item->hlist is an hlist however, so rotation isn't possible at
this time and we'd waste 8 bytes per stable node metadata if we were
to add it. Still it would be trivial to add the rotation.

However even the most benign change described above, can result in
false positive OOM. By the time you move to the next page the accessed
bits are quickly set again for all other pages you're not scanning. If
just a bit too many pages are like that you won't be clearing young
bits, or establishing swap entries fast enough and you'll trigger the
OOM killer early despite lots of swap is available. And that's in
addition to the compaction/memblock/offlining/CMA issues that also
would have no solution.

> There still would be cases where a full walk is necessary so this idea does
> not fix all problems of concern but it would help reclaim in the case where
> there are many KSM pages that are in use in a relatively obvious manner. More
> importantly, such a modification would benefit cases other than KSM.

What I'm afraid is that it would risk to destabilize the VM if we
limit the rmap_walk length. That would exponentially increase the
chance page_referenced() returns true at all times in turn not really
solving much if too many KSM pages are shared above the "magical" rmap
walk length. I'm not sure if that would benefit other cases either as
they would end up in the same corner case.

If instead we enforce a KSM sharing limit, there's no point in taking
any more risk and sticking to the current model of atomic rmap_walks
that simulates a physical page accessed bit, certainly looks much
safer to me.

I evaluated those possible VM modifications before adding the sharing
limit to KSM and they didn't look definitive to me and there was no
way I could guarantee the VM not to end up in weird corner cases
unless I limited the KSM sharing limit in the first place.

Something that instead I definitely like is the reduction of the IPIs
in the rmap_walks, I mean your work and Hugh's patch that extends it
to page_migration. That looks just great and it has zero risk to
destabilize the VM, but it's also orthogonal to the KSM sharing limit.

Not clearing all accessed bits in page_referenced or failing KSM
migration depending on a magic rmap_walk limit I don't like very much.
They can certainly hide the problem in some case: they would work
absolutely great if there's just 1 KSM page in the system over the
"magical" limit, but I don't think they've drawbacks and it looks
flakey if too many KSM pages are above the "magical" limit. The KSM
sharing limit value is way less magical than that: if it's set too low
you can only lose some memory, you won't risk VM malfunction.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
