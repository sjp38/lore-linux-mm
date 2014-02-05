Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3316B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 20:54:41 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so3138958eaj.3
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 17:54:40 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id b7si3268612eez.176.2014.02.04.17.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 17:54:40 -0800 (PST)
Date: Tue, 4 Feb 2014 20:53:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 10/10] mm: keep page cache radix tree nodes in check
Message-ID: <20140205015352.GW6963@cmpxchg.org>
References: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
 <1391475222-1169-11-git-send-email-hannes@cmpxchg.org>
 <20140204150756.d7f46af4385026ce61c89c55@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204150756.d7f46af4385026ce61c89c55@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 04, 2014 at 03:07:56PM -0800, Andrew Morton wrote:
> On Mon,  3 Feb 2014 19:53:42 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Previously, page cache radix tree nodes were freed after reclaim
> > emptied out their page pointers.  But now reclaim stores shadow
> > entries in their place, which are only reclaimed when the inodes
> > themselves are reclaimed.  This is problematic for bigger files that
> > are still in use after they have a significant amount of their cache
> > reclaimed, without any of those pages actually refaulting.  The shadow
> > entries will just sit there and waste memory.  In the worst case, the
> > shadow entries will accumulate until the machine runs out of memory.
> > 
> > To get this under control, the VM will track radix tree nodes
> > exclusively containing shadow entries on a per-NUMA node list.
> > Per-NUMA rather than global because we expect the radix tree nodes
> > themselves to be allocated node-locally and we want to reduce
> > cross-node references of otherwise independent cache workloads.  A
> > simple shrinker will then reclaim these nodes on memory pressure.

    ^^^^^^^^^^^^^^^
> > A few things need to be stored in the radix tree node to implement the
> > shadow node LRU and allow tree deletions coming from the list:
> > 
> > 1. There is no index available that would describe the reverse path
> >    from the node up to the tree root, which is needed to perform a
> >    deletion.  To solve this, encode in each node its offset inside the
> >    parent.  This can be stored in the unused upper bits of the same
> >    member that stores the node's height at no extra space cost.
> > 
> > 2. The number of shadow entries needs to be counted in addition to the
> >    regular entries, to quickly detect when the node is ready to go to
> >    the shadow node LRU list.  The current entry count is an unsigned
> >    int but the maximum number of entries is 64, so a shadow counter
> >    can easily be stored in the unused upper bits.
> > 
> > 3. Tree modification needs tree lock and tree root, which are located
> >    in the address space, so store an address_space backpointer in the
> >    node.  The parent pointer of the node is in a union with the 2-word
> >    rcu_head, so the backpointer comes at no extra cost as well.
> > 
> > 4. The node needs to be linked to an LRU list, which requires a list
> >    head inside the node.  This does increase the size of the node, but
> >    it does not change the number of objects that fit into a slab page.
> 
> changelog forgot to mention that this reclaim is performed via a
> shrinker...

Uhm...  see above? :)

> How expensive is that list walk in scan_shadow_nodes()?  I assume in
> the best case it will bale out after nr_to_scan iterations?

Yes, it scans sc->nr_to_scan radix tree nodes, cleans their pointers,
and frees them.

I ran a worst-case scenario on an 8G machine that creates one 8T
sparse file and faults one page per 64-page radix tree node, i.e. one
node per sparse file fault at CPU speed.  The profile:

     1       9.21%     radixblow  [kernel.kallsyms]   [k] memset
     2       7.23%     radixblow  [kernel.kallsyms]   [k] do_mpage_readpage
     3       4.76%     radixblow  [kernel.kallsyms]   [k] copy_user_generic_string
     4       3.85%     radixblow  [kernel.kallsyms]   [k] __radix_tree_lookup
     5       3.32%       kswapd0  [kernel.kallsyms]   [k] shadow_lru_isolate
     6       2.92%     radixblow  [kernel.kallsyms]   [k] get_page_from_freelist
     7       2.81%       kswapd0  [kernel.kallsyms]   [k] __delete_from_page_cache
     8       2.50%     radixblow  [kernel.kallsyms]   [k] radix_tree_node_ctor
     9       1.79%     radixblow  [kernel.kallsyms]   [k] _raw_spin_lock_irq
    10       1.70%       kswapd0  [kernel.kallsyms]   [k] __mem_cgroup_uncharge_common

Same scenario with 4 pages per 64-page radix tree node:

    13       1.39%       kswapd0  [kernel.kallsyms]   [k] shadow_lru_isolate

16 pages per 64-page node:

    75       0.20%       kswapd0  [kernel.kallsyms]   [k] shadow_lru_isolate

So I doubt this will bother anyone, especially since most use-once
streamers should have a better population density and populate cache
at disk speed, not CPU speed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
