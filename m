Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 094386B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:50:50 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:10:02 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 1/12] ksm: rename kernel_pages_allocated
In-Reply-To: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
Message-ID: <Pine.LNX.4.64.0908031308590.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We're not implementing swapping of KSM pages in its first release;
but when that follows, "kernel_pages_allocated" will be a very poor
name for the sysfs file showing number of nodes in the stable tree:
rename that to "pages_shared" throughout.

But we already have a "pages_shared", counting those page slots
sharing the shared pages: first rename that to... "pages_sharing".

What will become of "max_kernel_pages" when the pages shared can
be swapped?  I guess it will just be removed, so keep that name.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   57 ++++++++++++++++++++++++++---------------------------
 1 file changed, 28 insertions(+), 29 deletions(-)

--- ksm0/mm/ksm.c	2009-08-01 05:02:09.000000000 +0100
+++ ksm1/mm/ksm.c	2009-08-02 13:49:36.000000000 +0100
@@ -150,10 +150,10 @@ static struct kmem_cache *rmap_item_cach
 static struct kmem_cache *mm_slot_cache;
 
 /* The number of nodes in the stable tree */
-static unsigned long ksm_kernel_pages_allocated;
+static unsigned long ksm_pages_shared;
 
 /* The number of page slots sharing those nodes */
-static unsigned long ksm_pages_shared;
+static unsigned long ksm_pages_sharing;
 
 /* Limit on the number of unswappable pages used */
 static unsigned long ksm_max_kernel_pages;
@@ -384,7 +384,7 @@ static void remove_rmap_item_from_tree(s
 				next_item->address |= NODE_FLAG;
 			} else {
 				rb_erase(&rmap_item->node, &root_stable_tree);
-				ksm_kernel_pages_allocated--;
+				ksm_pages_shared--;
 			}
 		} else {
 			struct rmap_item *prev_item = rmap_item->prev;
@@ -398,7 +398,7 @@ static void remove_rmap_item_from_tree(s
 		}
 
 		rmap_item->next = NULL;
-		ksm_pages_shared--;
+		ksm_pages_sharing--;
 
 	} else if (rmap_item->address & NODE_FLAG) {
 		unsigned char age;
@@ -748,7 +748,7 @@ static int try_to_merge_two_pages(struct
 	 * is the number of kernel pages that we hold.
 	 */
 	if (ksm_max_kernel_pages &&
-	    ksm_max_kernel_pages <= ksm_kernel_pages_allocated)
+	    ksm_max_kernel_pages <= ksm_pages_shared)
 		return err;
 
 	kpage = alloc_page(GFP_HIGHUSER);
@@ -787,7 +787,7 @@ static int try_to_merge_two_pages(struct
 		if (err)
 			break_cow(mm1, addr1);
 		else
-			ksm_pages_shared += 2;
+			ksm_pages_sharing += 2;
 	}
 
 	put_page(kpage);
@@ -817,7 +817,7 @@ static int try_to_merge_with_ksm_page(st
 	up_read(&mm1->mmap_sem);
 
 	if (!err)
-		ksm_pages_shared++;
+		ksm_pages_sharing++;
 
 	return err;
 }
@@ -935,7 +935,7 @@ static struct rmap_item *stable_tree_ins
 		}
 	}
 
-	ksm_kernel_pages_allocated++;
+	ksm_pages_shared++;
 
 	rmap_item->address |= NODE_FLAG | STABLE_FLAG;
 	rmap_item->next = NULL;
@@ -1051,7 +1051,7 @@ static void cmp_and_merge_page(struct pa
 	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
 	if (tree_rmap_item) {
 		if (page == page2[0]) {			/* forked */
-			ksm_pages_shared++;
+			ksm_pages_sharing++;
 			err = 0;
 		} else
 			err = try_to_merge_with_ksm_page(rmap_item->mm,
@@ -1114,7 +1114,7 @@ static void cmp_and_merge_page(struct pa
 				break_cow(tree_rmap_item->mm,
 						tree_rmap_item->address);
 				break_cow(rmap_item->mm, rmap_item->address);
-				ksm_pages_shared -= 2;
+				ksm_pages_sharing -= 2;
 			}
 		}
 
@@ -1430,7 +1430,7 @@ static ssize_t run_store(struct kobject
 	/*
 	 * KSM_RUN_MERGE sets ksmd running, and 0 stops it running.
 	 * KSM_RUN_UNMERGE stops it running and unmerges all rmap_items,
-	 * breaking COW to free the kernel_pages_allocated (but leaves
+	 * breaking COW to free the unswappable pages_shared (but leaves
 	 * mm_slots on the list for when ksmd may be set running again).
 	 */
 
@@ -1449,22 +1449,6 @@ static ssize_t run_store(struct kobject
 }
 KSM_ATTR(run);
 
-static ssize_t pages_shared_show(struct kobject *kobj,
-				 struct kobj_attribute *attr, char *buf)
-{
-	return sprintf(buf, "%lu\n",
-			ksm_pages_shared - ksm_kernel_pages_allocated);
-}
-KSM_ATTR_RO(pages_shared);
-
-static ssize_t kernel_pages_allocated_show(struct kobject *kobj,
-					   struct kobj_attribute *attr,
-					   char *buf)
-{
-	return sprintf(buf, "%lu\n", ksm_kernel_pages_allocated);
-}
-KSM_ATTR_RO(kernel_pages_allocated);
-
 static ssize_t max_kernel_pages_store(struct kobject *kobj,
 				      struct kobj_attribute *attr,
 				      const char *buf, size_t count)
@@ -1488,13 +1472,28 @@ static ssize_t max_kernel_pages_show(str
 }
 KSM_ATTR(max_kernel_pages);
 
+static ssize_t pages_shared_show(struct kobject *kobj,
+				 struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", ksm_pages_shared);
+}
+KSM_ATTR_RO(pages_shared);
+
+static ssize_t pages_sharing_show(struct kobject *kobj,
+				  struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n",
+			ksm_pages_sharing - ksm_pages_shared);
+}
+KSM_ATTR_RO(pages_sharing);
+
 static struct attribute *ksm_attrs[] = {
 	&sleep_millisecs_attr.attr,
 	&pages_to_scan_attr.attr,
 	&run_attr.attr,
-	&pages_shared_attr.attr,
-	&kernel_pages_allocated_attr.attr,
 	&max_kernel_pages_attr.attr,
+	&pages_shared_attr.attr,
+	&pages_sharing_attr.attr,
 	NULL,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
