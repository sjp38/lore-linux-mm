Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 721996B0039
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 02:46:46 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so11457494pde.6
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 23:46:46 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id w3si6810464pbh.269.2013.11.27.23.46.43
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 23:46:45 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 5/9] mm/rmap: extend rmap_walk_xxx() to cope with different cases
Date: Thu, 28 Nov 2013 16:48:42 +0900
Message-Id: <1385624926-28883-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There are a lot of common parts in traversing functions, but there are
also a little of uncommon parts in it. By assigning proper function
pointer on each rmap_walker_control, we can handle these difference
correctly.

Following are differences we should handle.

1. difference of lock function in anon mapping case
2. nonlinear handling in file mapping case
3. prechecked condition:
	checking memcg in page_referenced(),
	checking VM_SHARE in page_mkclean()
	checking temporary vma in try_to_unmap()
4. exit condition:
	checking page_mapped() in try_to_unmap()

So, in this patch, I introduce 4 function pointers to
handle above differences.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 0f65686..58624b4 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -239,6 +239,12 @@ struct rmap_walk_control {
 	int (*main)(struct page *, struct vm_area_struct *,
 					unsigned long, void *);
 	void *arg;	/* argument to main function */
+	int (*main_done)(struct page *page);	/* check exit condition */
+	int (*file_nonlinear)(struct page *, struct address_space *,
+					struct vm_area_struct *vma);
+	struct anon_vma *(*anon_lock)(struct page *);
+	int (*vma_skip)(struct vm_area_struct *, void *);
+	void *skip_arg;	/* argument to vma_skip function */
 };
 
 /*
diff --git a/mm/ksm.c b/mm/ksm.c
index c42ec30..0aa6e09 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2032,12 +2032,19 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
+			if (rwc->vma_skip && rwc->vma_skip(vma, rwc->skip_arg))
+				continue;
+
 			ret = rwc->main(page, vma,
 					rmap_item->address, rwc->arg);
 			if (ret != SWAP_AGAIN) {
 				anon_vma_unlock_read(anon_vma);
 				goto out;
 			}
+			if (rwc->main_done && rwc->main_done(page)) {
+				anon_vma_unlock_read(anon_vma);
+				goto out;
+			}
 		}
 		anon_vma_unlock_read(anon_vma);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index 5933488..5dad5dd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1683,10 +1683,14 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 }
 
 #ifdef CONFIG_MIGRATION
-static struct anon_vma *rmap_walk_anon_lock(struct page *page)
+static struct anon_vma *rmap_walk_anon_lock(struct page *page,
+					struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
 
+	if (rwc->anon_lock)
+		return rwc->anon_lock(page);
+
 	/*
 	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma_read()
 	 * because that depends on page_mapped(); but not all its usages
@@ -1712,16 +1716,22 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = rmap_walk_anon_lock(page);
+	anon_vma = rmap_walk_anon_lock(page, rwc);
 	if (!anon_vma)
 		return ret;
 
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
+
+		if (rwc->vma_skip && rwc->vma_skip(vma, rwc->skip_arg))
+			continue;
+
 		ret = rwc->main(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
 			break;
+		if (rwc->main_done && rwc->main_done(page))
+			break;
 	}
 	anon_vma_unlock_read(anon_vma);
 	return ret;
@@ -1743,15 +1753,26 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
+
+		if (rwc->vma_skip && rwc->vma_skip(vma, rwc->skip_arg))
+			continue;
+
 		ret = rwc->main(page, vma, address, rwc->arg);
 		if (ret != SWAP_AGAIN)
-			break;
+			goto done;
+		if (rwc->main_done && rwc->main_done(page))
+			goto done;
 	}
-	/*
-	 * No nonlinear handling: being always shared, nonlinear vmas
-	 * never contain migration ptes.  Decide what to do about this
-	 * limitation to linear when we need rmap_walk() on nonlinear.
-	 */
+
+	if (!rwc->file_nonlinear)
+		goto done;
+
+	if (list_empty(&mapping->i_mmap_nonlinear))
+		goto done;
+
+	ret = rwc->file_nonlinear(page, mapping, vma);
+
+done:
 	mutex_unlock(&mapping->i_mmap_mutex);
 	return ret;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
