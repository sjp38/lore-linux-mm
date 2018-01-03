Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 665B46B0370
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 14:39:30 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r6so2155733itr.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 11:39:30 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id n5si1235314ion.169.2018.01.03.11.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 11:39:29 -0800 (PST)
Date: Wed, 3 Jan 2018 13:39:27 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: [RFC] Heuristic for inode/dentry fragmentation prevention
Message-ID: <alpine.DEB.2.20.1801031332230.10522@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, Pekka Enberg <penberg@cs.helsinki.fi>

I was looking at the inode/dentry reclaim code today and I thought there
is an obvious and easy to implement way to avoid fragmentation by checking
the number of objects in a slab page.


Subject: Heuristic for fragmentation prevention for inode and dentry caches

When freeing dentries and inodes we often get to the situation
that a slab page cannot be freed because there is only a single
object left in that slab page.

We add a new function to the slab allocators that returns the
number of objects in the same slab page.

Then the dentry and inode logic can check if such a situation
exits and take measures to try to reclaim that entry sooner.

In this patch the check if an inode or dentry has been referenced
(and thus should be kept) is skipped if the freeing of the object
would result in the slab page becoming available.

That will cause overhead in terms of having to re-allocate and
generate the inoden or dentry but in all likelyhood the inode
or dentry will then be allocated in a slab page that already
contains other inodes or dentries. Thus fragmentation is reduced.

Signed-off-by: Christopher Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -165,6 +165,7 @@ void * __must_check krealloc(const void
 void kfree(const void *);
 void kzfree(const void *);
 size_t ksize(const void *);
+unsigned kobjects_left_in_slab_page(const void *);

 #ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
 const char *__check_heap_object(const void *ptr, unsigned long n,
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c
+++ linux/mm/slab.c
@@ -4446,3 +4446,24 @@ size_t ksize(const void *objp)
 	return size;
 }
 EXPORT_SYMBOL(ksize);
+
+/* How many objects left in slab page */
+unsigned kobjects_left_in_slab_page(const void *object)
+{
+	struct page *page;
+
+	if (unlikely(ZERO_OR_NULL_PTR(object)))
+		return 0;
+
+	page = virt_to_head_page(object);
+
+	if (unlikely(!PageSlab(page))) {
+		WARN_ON(1);
+		return 1;
+	}
+
+	return page->active;
+}
+EXPORT_SYMBOL(kobjects_left_in_slab_page);
+
+
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3879,6 +3879,25 @@ size_t ksize(const void *object)
 }
 EXPORT_SYMBOL(ksize);

+/* How many objects left in slab page */
+unsigned kobjects_left_in_slab_page(const void *object)
+{
+	struct page *page;
+
+	if (unlikely(ZERO_OR_NULL_PTR(object)))
+		return 0;
+
+	page = virt_to_head_page(object);
+
+	if (unlikely(!PageSlab(page))) {
+		WARN_ON(!PageCompound(page));
+		return 1;
+	}
+
+	return page->inuse;
+}
+EXPORT_SYMBOL(kobjects_left_in_slab_page);
+
 void kfree(const void *x)
 {
 	struct page *page;
Index: linux/fs/dcache.c
===================================================================
--- linux.orig/fs/dcache.c
+++ linux/fs/dcache.c
@@ -1074,7 +1074,8 @@ static enum lru_status dentry_lru_isolat
 		return LRU_REMOVED;
 	}

-	if (dentry->d_flags & DCACHE_REFERENCED) {
+	if (dentry->d_flags & DCACHE_REFERENCED &&
+	   kobjects_left_in_slab_page(dentry) > 1) {
 		dentry->d_flags &= ~DCACHE_REFERENCED;
 		spin_unlock(&dentry->d_lock);

Index: linux/fs/inode.c
===================================================================
--- linux.orig/fs/inode.c
+++ linux/fs/inode.c
@@ -725,8 +725,12 @@ static enum lru_status inode_lru_isolate
 		return LRU_REMOVED;
 	}

-	/* recently referenced inodes get one more pass */
-	if (inode->i_state & I_REFERENCED) {
+	/*
+	 * Recently referenced inodes get one more pass
+	 * if they are not the only objects in a slab page
+	 */
+	if (inode->i_state & I_REFERENCED &&
+	    kobjects_left_in_slab_page(inode) > 1) {
 		inode->i_state &= ~I_REFERENCED;
 		spin_unlock(&inode->i_lock);
 		return LRU_ROTATE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
