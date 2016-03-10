Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 312606B0255
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:12:06 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so35247370wml.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 08:12:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x20si5503941wjq.196.2016.03.10.08.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 08:12:05 -0800 (PST)
Date: Thu, 10 Mar 2016 11:12:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm: keep page cache radix tree nodes in check
Message-ID: <20160310161200.GA11651@cmpxchg.org>
References: <20160310125922.GA15269@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310125922.GA15269@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

Hello Dan,

On Thu, Mar 10, 2016 at 03:59:23PM +0300, Dan Carpenter wrote:
> Hello Johannes Weiner,
> 
> The patch 449dd6984d0e: "mm: keep page cache radix tree nodes in
> check" from Apr 3, 2014, leads to the following static checker
> warning:
> 
> 	mm/filemap.c:138 page_cache_tree_delete()
> 	error: potentially using uninitialized 'node'.
> 
> mm/filemap.c
>    113  static void page_cache_tree_delete(struct address_space *mapping,
>    114                                     struct page *page, void *shadow)
>    115  {
>    116          struct radix_tree_node *node;
>                                         ^^^^
>    117          unsigned long index;
>    118          unsigned int offset;
>    119          unsigned int tag;
>    120          void **slot;
>    121  
>    122          VM_BUG_ON(!PageLocked(page));
>    123  
>    124          __radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
>                                                                        ^^^^
>    125  
>    126          if (shadow) {
>    127                  mapping->nrexceptional++;
>    128                  /*
>    129                   * Make sure the nrexceptional update is committed before
>    130                   * the nrpages update so that final truncate racing
>    131                   * with reclaim does not see both counters 0 at the
>    132                   * same time and miss a shadow entry.
>    133                   */
>    134                  smp_wmb();
>    135          }
>    136          mapping->nrpages--;
>    137  
>    138          if (!node) {
>                      ^^^^
> 
>    139                  /* Clear direct pointer tags in root node */
>    140                  mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
>    141                  radix_tree_replace_slot(slot, shadow);
>    142                  return;
>    143          }
> 
> It's obviously simple enough for me to initialize "node" to NULL but I
> suspect there is a reason that it can't be uninitialized...  I'm trying
> to get some feedback for some new Smatch stuff I'm working on.

We know that page->tree[page->index] is present and the tree is
locked, so __radix_tree_lookup() will always return with an entry, as
well as &node and &slot set. I'm not sure how you would annotate this.

Is it also warning about slot? Or can it know that they are always set
together? Could it maybe be linked to the function's return value? I
would prefer not setting node and slot to NULL to suppress the false
positive. However, what we could do is add a BUG_ON() if the function
call returns NULL. Would that be enough of a hint to the checker that
we expect the function to be always successful and set node and slot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
