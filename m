Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1D83F6B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 14:23:20 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id ej10so586401bkb.7
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 11:23:19 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pj2si11316089bkb.195.2014.01.23.11.23.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 11:23:18 -0800 (PST)
Date: Thu, 23 Jan 2014 14:22:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140123192212.GW6963@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140113073947.GR1992@bbox>
 <20140122184217.GD4407@cmpxchg.org>
 <20140123052014.GC28732@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140123052014.GC28732@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jan 23, 2014 at 02:20:14PM +0900, Minchan Kim wrote:
> On Wed, Jan 22, 2014 at 01:42:17PM -0500, Johannes Weiner wrote:
> > On Mon, Jan 13, 2014 at 04:39:47PM +0900, Minchan Kim wrote:
> > > On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
> > > > @@ -123,9 +129,39 @@ static void page_cache_tree_delete(struct address_space *mapping,
> > > >  		 * same time and miss a shadow entry.
> > > >  		 */
> > > >  		smp_wmb();
> > > > -	} else
> > > > -		radix_tree_delete(&mapping->page_tree, page->index);
> > > > +	}
> > > >  	mapping->nrpages--;
> > > > +
> > > > +	if (!node) {
> > > > +		/* Clear direct pointer tags in root node */
> > > > +		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
> > > > +		radix_tree_replace_slot(slot, shadow);
> > > > +		return;
> > > > +	}
> > > > +
> > > > +	/* Clear tree tags for the removed page */
> > > > +	index = page->index;
> > > > +	offset = index & RADIX_TREE_MAP_MASK;
> > > > +	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
> > > > +		if (test_bit(offset, node->tags[tag]))
> > > > +			radix_tree_tag_clear(&mapping->page_tree, index, tag);
> > > > +	}
> > > > +
> > > > +	/* Delete page, swap shadow entry */
> > > > +	radix_tree_replace_slot(slot, shadow);
> > > > +	node->count--;
> > > > +	if (shadow)
> > > > +		node->count += 1U << RADIX_TREE_COUNT_SHIFT;
> > > 
> > > Nitpick2:
> > > It should be a function of workingset.c rather than exposing
> > > RADIX_TREE_COUNT_SHIFT?
> > > 
> > > IMO, It would be better to provide some accessor functions here, too.
> > 
> > The shadow maintenance and node lifetime management are pretty
> > interwoven to share branches and reduce instructions as these are
> > common paths.  I don't see how this could result in cleaner code while
> > keeping these advantages.
> 
> What I want is just put a inline accessor in somewhere like workingset.h
> 
> static inline void inc_shadow_entry(struct radix_tree_node *node)
> {
>     node->count += 1U << RADIX_TREE_COUNT_MASK;
> }
> 
> So, anyone don't need to know that node->count upper bits present
> count of shadow entry.

Okay, but then you have to cover lower bits as well, without explicit
higher bit access it would be confusing to use the mask for lower
bits.

Something like the following?

---

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 102e37bc82d5..b33171a3673c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -266,6 +266,36 @@ bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
 extern struct list_lru workingset_shadow_nodes;
 
+static inline unsigned int workingset_node_pages(struct radix_tree_node *node)
+{
+	return node->count & RADIX_TREE_COUNT_MASK;
+}
+
+static inline void workingset_node_pages_inc(struct radix_tree_node *node)
+{
+	return node->count++;
+}
+
+static inline void workingset_node_pages_dec(struct radix_tree_node *node)
+{
+	return node->count--;
+}
+
+static inline unsigned int workingset_node_shadows(struct radix_tree_node *node)
+{
+	return node->count >> RADIX_TREE_COUNT_SHIFT;
+}
+
+static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
+{
+	node->count += 1U << RADIX_TREE_COUNT_SHIFT;
+}
+
+static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
+{
+	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
+}
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/filemap.c b/mm/filemap.c
index a63e89484d18..ac7f62db9ccd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -149,9 +149,9 @@ static void page_cache_tree_delete(struct address_space *mapping,
 
 	/* Delete page, swap shadow entry */
 	radix_tree_replace_slot(slot, shadow);
-	node->count--;
+	workingset_node_pages_dec(node);
 	if (shadow)
-		node->count += 1U << RADIX_TREE_COUNT_SHIFT;
+		workingset_node_shadow_inc(node);
 	else
 		if (__radix_tree_delete_node(&mapping->page_tree, node))
 			return;
@@ -163,7 +163,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	 * list_empty() test is safe as node->private_list is
 	 * protected by mapping->tree_lock.
 	 */
-	if (!(node->count & RADIX_TREE_COUNT_MASK) &&
+	if (!workingset_node_pages(node) &&
 	    list_empty(&node->private_list)) {
 		node->private_data = mapping;
 		list_lru_add(&workingset_shadow_nodes, &node->private_list);
@@ -531,12 +531,12 @@ static int page_cache_tree_insert(struct address_space *mapping,
 			*shadowp = p;
 		mapping->nrshadows--;
 		if (node)
-			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
+			workingset_node_shadows_dec(node);
 	}
 	radix_tree_replace_slot(slot, page);
 	mapping->nrpages++;
 	if (node) {
-		node->count++;
+		workingset_node_pages_inc(node);
 		/*
 		 * Don't track node that contains actual pages.
 		 *
diff --git a/mm/truncate.c b/mm/truncate.c
index c7a0d02a03eb..9cb54b7525dc 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -46,7 +46,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	mapping->nrshadows--;
 	if (!node)
 		goto unlock;
-	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
+	workingset_node_shadows_dec(node);
 	/*
 	 * Don't track node without shadow entries.
 	 *
@@ -54,7 +54,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * The list_empty() test is safe as node->private_list is
 	 * protected by mapping->tree_lock.
 	 */
-	if (!(node->count >> RADIX_TREE_COUNT_SHIFT) &&
+	if (!workingset_node_shadows(node) &&
 	    !list_empty(&node->private_list))
 		list_lru_del(&workingset_shadow_nodes, &node->private_list);
 	__radix_tree_delete_node(&mapping->page_tree, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
