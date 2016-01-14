Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A5FF76B0257
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 18:37:09 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id n128so107382196pfn.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 15:37:09 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id f6si12210038pfj.104.2016.01.14.15.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 15:37:08 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id 65so107388399pff.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 15:37:08 -0800 (PST)
Date: Thu, 14 Jan 2016 15:36:56 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
In-Reply-To: <1447181081-30056-2-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com> <1447181081-30056-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>

Hi Andrea,

I'm sorry, I've only now got around to looking at this, forced by
merge window to contemplate whether it should go forward or not.

While there's lots of careful and ingenious work gone into it, and
I've seen no actual problem in the source, nor when running with it,
I cannot really get to grips with the review, because I cannot shake
off the feeling that it's all a wrong direction, at least for now.

On Tue, 10 Nov 2015, Andrea Arcangeli wrote:

> Without a max deduplication limit for each KSM page, the list of the
> rmap_items associated to each stable_node can grow infinitely
> large.

Okay, yes, I can see that unlimited growth of the rmap list is a problem
which we need to address; and I can see that successful deduplication
tends towards this state much more than anon rmap or even file rmap.

But it's not entirely a problem with deduplication, and I'd rather see
it dealt with in a more general way, not by a max deduplication limit
in KSM.

I don't think you should throw away this work; but I do think there
are several other improvements, outside of ksm.c, which we should
make first; and then come back to this if those are not enough.

> 
> During the rmap walk each entry can take up to ~10usec to process
> because of IPIs for the TLB flushing (both for the primary MMU and the
> secondary MMUs with the MMU notifier). With only 16GB of address space
> shared in the same KSM page, that would amount to dozens of seconds of
> kernel runtime.

Right, IPIs and MMU notifiers: more below.

> 
> A ~256 max deduplication factor will reduce the latencies of the rmap
> walks on KSM pages to order of a few msec. Just doing the
> cond_resched() during the rmap walks is not enough, the list size must
> have a limit too, otherwise the caller could get blocked in (schedule
> friendly) kernel computations for seconds, unexpectedly.

Schedule-friendly: you make an important point there: with the rmap
mutexes and your recent cond_resched()s, I don't think we need to worry
about a task doing explicit work for itself (memory hotremove, for example),
that will take as long as it has to; but, as usual, we do need to worry
about compaction serving THP, and the high mapcounts it might encounter.

> 
> There's room for optimization to significantly reduce the IPI delivery
> cost during the page_referenced(),

You're missing that Shaohua removed x86's TLB flush from page_referenced()
a couple of years ago: b13b1d2d8692 "x86/mm: In the PTE swapout page
reclaim case clear the accessed bit instead of flushing the TLB".
Yes, it is confusing that "flush" remains in the names now there
isn't a flush.  I assume x86 is your main concern?

> but at least for page_migration in
> the KSM case (used by hard NUMA bindings, compaction and NUMA
> balancing) it may be inevitable to send lots of IPIs if each
> rmap_item->mm is active on a different CPU and there are lots of
> CPUs. Even if we ignore the IPI delivery cost, we've still to walk the
> whole KSM rmap list, so we can't allow millions or billions (ulimited)
                                                              (unlimited)
> number of entries in the KSM stable_node rmap_item lists.

You've got me fired up.  Mel's recent 72b252aed506 "mm: send one IPI per
CPU to TLB flush all entries after unmapping pages" and nearby commits
are very much to the point here; but because his first draft was unsafe
in the page migration area, he dropped that, and ended up submitting
for page reclaim alone.

That's the first low-hanging fruit: we should apply Mel's batching
to page migration; and it's become clear enough in my mind, that I'm
now impatient to try it myself (but maybe Mel will respond if he has
a patch for it already).  If I can't post a patch for that early next
week, someone else take over (or preempt me); yes, there's all kinds
of other things I should be doing instead, but this is too tempting.

That can help, not just KSM's long chains, but most other migration of
mapped pages too.  (The KSM case is particularly easy, because those
pages are known to be mapped write-protected, and its long chains can
benefit just from batching on the single page; but in general, I
believe we want to batch across pages there too, when we can.)

But MMU notifiers: there I'm out of my element, and you are right at
home.  I don't know how much of an issue the MMU notification per pte
clear is for you, but I assume it's nasty.  Is there any way those
can be batched too, across mms, at least for the single page?

Let me be a little rude: I think that is the problem you should be
working on, which also would benefit way beyond KSM.  (But I may be
naive to suppose that there's even a prospect of batching there.)

> 
> The limit is enforced efficiently by adding a second dimension to the
> stable rbtree. So there are three types of stable_nodes: the regular
> ones (identical as before, living in the first flat dimension of the
> stable rbtree), the "chains" and the "dups".

Okay, now you get into the implementation details (it's a very helpful
outline, thank you); but I don't agree that KSM should enforce such a
limit, I think it should continue to do as it does today.

Using dup pages does provide a "clean" way to break up the rmap
operations, and would be great if those operations were O(N^2).
But they're O(N), so I think the dup pages actually add a little
overhead, rather than solving anything.  Instead of having 1000
maps served by 1 page of mapcount 1000, they're served by 4 pages
of mapcount 250.  That lowers the max amount of work in unmapping
one page, but what about when all four of those pages have to be
unmapped in the same operation?  That will be a less common case,
sure, but it still has to be acknowledged in worst latency.  And
when considering page reclaim: we're starting out from a deficit
of 3 pages when compared with before.

Yes, there should be a limit (though I suspect not one hard limit,
but something that is adjusted according to pressure), and maybe
a tunable for it.  But this limit or limits imposed by rmap_walk
callers: first approximation, just don't bother to call rmap_walk
if page_mapcount is higher than limit, assume the page is referenced
and not to be unmapped - the higher its mapcount, the more likely
that is to be true, and the walks just a waste of time.  (But we'd
prefer that a page not be effectively mlocked by many mappings.)

I'm thinking there of the page reclaim case.  Page migration callers
will have different needs.  Memory hotremove will want to try as hard
as it must.  Compaction (but I'm unfamiliar with its different modes)
might want to avoid pages with high mapcount, until there's indication
that they must be attacked, preferably in the background.  mbind():
well, to consider just the KSM case, isn't it silly to be migrating
KSM pages - shouldn't it COW them instead?

> 
> Every "chain" and all "dups" linked into a "chain" enforce the
> invariant that they represent the same write protected memory content,
> even if each "dup" will be pointed by a different KSM page copy of
> that content. This way the stable rbtree lookup computational
> complexity is unaffected if compared to an unlimited
> max_sharing_limit. It is still enforced that there cannot be KSM page
> content duplicates in the stable rbtree itself.
> 
> Adding the second dimension to the stable rbtree only after the
> max_page_sharing limit hits, provides for a zero memory footprint
> increase on 64bit archs. The memory overhead of the per-KSM page
> stable_tree and per virtual mapping rmap_item is unchanged. Only after
> the max_page_sharing limit hits, we need to allocate a stable_tree
> "chain" and rb_replace() the "regular" stable_node with the newly
> allocated stable_node "chain". After that we simply add the "regular"
> stable_node to the chain as a stable_node "dup" by linking hlist_dup
> in the stable_node_chain->hlist. This way the "regular" (flat)
> stable_node is converted to a stable_node "dup" living in the second
> dimension of the stable rbtree.
> 
> During stable rbtree lookups the stable_node "chain" is identified as
> stable_node->rmap_hlist_len == STABLE_NODE_CHAIN (aka
> is_stable_node_chain()).
> 
> When dropping stable_nodes, the stable_node "dup" is identified as
> stable_node->head == STABLE_NODE_DUP_HEAD (aka is_stable_node_dup()).
> 
> The STABLE_NODE_DUP_HEAD must be an unique valid pointer never used
> elsewhere in any stable_node->head/node to avoid a clashes with the
> stable_node->node.rb_parent_color pointer, and different from
> &migrate_nodes. So the second field of &migrate_nodes is picked and
> verified as always safe with a BUILD_BUG_ON in case the list_head
> implementation changes in the future.
> 
> The STABLE_NODE_DUP is picked as a random negative value in
> stable_node->rmap_hlist_len. rmap_hlist_len cannot become negative
> when it's a "regular" stable_node or a stable_node "dup".
> 
> The stable_node_chain->nid is irrelevant. The stable_node_chain->kpfn
> is aliased in a union with a time field used to rate limit the
> stable_node_chain->hlist prunes.
> 
> The garbage collection of the stable_node_chain happens lazily during
> stable rbtree lookups (as for all other kind of stable_nodes), or
> while disabling KSM with "echo 2 >/sys/kernel/mm/ksm/run" while
> collecting the entire stable rbtree.

I'd like your design much better if there didn't have to be this
garbage collection, and the related possibility of fragmentation.
But I don't see how to avoid it in a seamless way.

> 
> While the "regular" stable_nodes and the stable_node "dups" must wait
> for their underlying tree_page to be freed before they can be freed
> themselves, the stable_node "chains" can be freed immediately if the
> stable_node->hlist turns empty. This is because the "chains" are never
> pointed by any page->mapping and they're effectively stable rbtree KSM
> self contained metadata.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  Documentation/vm/ksm.txt |  63 ++++
>  mm/ksm.c                 | 731 ++++++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 728 insertions(+), 66 deletions(-)

Nicely self-contained, but I think we should go beyond KSM.
And all those +s did put me off a bit :(

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
