Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74D416B0266
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:55:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so1986063155pgc.1
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:55:50 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m13si6442061pga.262.2017.01.11.09.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 09:55:49 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v5 6/9] mm/swap: Free swap slots in batch
Date: Wed, 11 Jan 2017 09:55:16 -0800
Message-Id: <c25e0fcdfd237ec4ca7db91631d3b9f6ed23824e.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Add new functions that free unused swap slots in batches without
the need to reacquire swap info lock.  This improves scalability
and reduce lock contention.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Co-developed-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |   1 +
 mm/swapfile.c        | 155 +++++++++++++++++++++++++++++++--------------------
 2 files changed, 95 insertions(+), 61 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 980f159..f0480c3 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -392,6 +392,7 @@ extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free(swp_entry_t);
+extern void swapcache_free_entries(swp_entry_t *entries, int n);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 54fe8dd..50f2688 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -947,35 +947,34 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 	return p;
 }
 
-static unsigned char swap_entry_free(struct swap_info_struct *p,
-				     swp_entry_t entry, unsigned char usage,
-				     bool swap_info_locked)
+static struct swap_info_struct *swap_info_get_cont(swp_entry_t entry,
+					struct swap_info_struct *q)
+{
+	struct swap_info_struct *p;
+
+	p = _swap_info_get(entry);
+
+	if (p != q) {
+		if (q != NULL)
+			spin_unlock(&q->lock);
+		if (p != NULL)
+			spin_lock(&p->lock);
+	}
+	return p;
+}
+
+static unsigned char __swap_entry_free(struct swap_info_struct *p,
+				       swp_entry_t entry, unsigned char usage)
 {
 	struct swap_cluster_info *ci;
 	unsigned long offset = swp_offset(entry);
 	unsigned char count;
 	unsigned char has_cache;
-	bool lock_swap_info = false;
-
-	if (!swap_info_locked) {
-		count = p->swap_map[offset];
-		if (!p->cluster_info || count == usage || count == SWAP_MAP_SHMEM) {
-lock_swap_info:
-			swap_info_locked = true;
-			lock_swap_info = true;
-			spin_lock(&p->lock);
-		}
-	}
 
-	ci = lock_cluster(p, offset);
+	ci = lock_cluster_or_swap_info(p, offset);
 
 	count = p->swap_map[offset];
 
-	if (!swap_info_locked && (count == usage || count == SWAP_MAP_SHMEM)) {
-		unlock_cluster(ci);
-		goto lock_swap_info;
-	}
-
 	has_cache = count & SWAP_HAS_CACHE;
 	count &= ~SWAP_HAS_CACHE;
 
@@ -999,46 +998,52 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 	}
 
 	usage = count | has_cache;
-	p->swap_map[offset] = usage;
+	p->swap_map[offset] = usage ? : SWAP_HAS_CACHE;
+
+	unlock_cluster_or_swap_info(p, ci);
+
+	return usage;
+}
 
+static void swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
+{
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+	unsigned char count;
+
+	ci = lock_cluster(p, offset);
+	count = p->swap_map[offset];
+	VM_BUG_ON(count != SWAP_HAS_CACHE);
+	p->swap_map[offset] = 0;
+	dec_cluster_info_page(p, p->cluster_info, offset);
 	unlock_cluster(ci);
 
-	/* free if no reference */
-	if (!usage) {
-		VM_BUG_ON(!swap_info_locked);
-		mem_cgroup_uncharge_swap(entry);
-		ci = lock_cluster(p, offset);
-		dec_cluster_info_page(p, p->cluster_info, offset);
-		unlock_cluster(ci);
-		if (offset < p->lowest_bit)
-			p->lowest_bit = offset;
-		if (offset > p->highest_bit) {
-			bool was_full = !p->highest_bit;
-			p->highest_bit = offset;
-			if (was_full && (p->flags & SWP_WRITEOK)) {
-				spin_lock(&swap_avail_lock);
-				WARN_ON(!plist_node_empty(&p->avail_list));
-				if (plist_node_empty(&p->avail_list))
-					plist_add(&p->avail_list,
-						  &swap_avail_head);
-				spin_unlock(&swap_avail_lock);
-			}
-		}
-		atomic_long_inc(&nr_swap_pages);
-		p->inuse_pages--;
-		frontswap_invalidate_page(p->type, offset);
-		if (p->flags & SWP_BLKDEV) {
-			struct gendisk *disk = p->bdev->bd_disk;
-			if (disk->fops->swap_slot_free_notify)
-				disk->fops->swap_slot_free_notify(p->bdev,
-								  offset);
+	mem_cgroup_uncharge_swap(entry);
+	if (offset < p->lowest_bit)
+		p->lowest_bit = offset;
+	if (offset > p->highest_bit) {
+		bool was_full = !p->highest_bit;
+
+		p->highest_bit = offset;
+		if (was_full && (p->flags & SWP_WRITEOK)) {
+			spin_lock(&swap_avail_lock);
+			WARN_ON(!plist_node_empty(&p->avail_list));
+			if (plist_node_empty(&p->avail_list))
+				plist_add(&p->avail_list,
+					  &swap_avail_head);
+			spin_unlock(&swap_avail_lock);
 		}
 	}
+	atomic_long_inc(&nr_swap_pages);
+	p->inuse_pages--;
+	frontswap_invalidate_page(p->type, offset);
+	if (p->flags & SWP_BLKDEV) {
+		struct gendisk *disk = p->bdev->bd_disk;
 
-	if (lock_swap_info)
-		spin_unlock(&p->lock);
-
-	return usage;
+		if (disk->fops->swap_slot_free_notify)
+			disk->fops->swap_slot_free_notify(p->bdev,
+							  offset);
+	}
 }
 
 /*
@@ -1050,8 +1055,10 @@ void swap_free(swp_entry_t entry)
 	struct swap_info_struct *p;
 
 	p = _swap_info_get(entry);
-	if (p)
-		swap_entry_free(p, entry, 1, false);
+	if (p) {
+		if (!__swap_entry_free(p, entry, 1))
+			swapcache_free_entries(&entry, 1);
+	}
 }
 
 /*
@@ -1062,8 +1069,32 @@ void swapcache_free(swp_entry_t entry)
 	struct swap_info_struct *p;
 
 	p = _swap_info_get(entry);
+	if (p) {
+		if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
+			swapcache_free_entries(&entry, 1);
+	}
+}
+
+void swapcache_free_entries(swp_entry_t *entries, int n)
+{
+	struct swap_info_struct *p, *prev;
+	int i;
+
+	if (n <= 0)
+		return;
+
+	prev = NULL;
+	p = NULL;
+	for (i = 0; i < n; ++i) {
+		p = swap_info_get_cont(entries[i], prev);
+		if (p)
+			swap_entry_free(p, entries[i]);
+		else
+			break;
+		prev = p;
+	}
 	if (p)
-		swap_entry_free(p, entry, SWAP_HAS_CACHE, false);
+		spin_unlock(&p->lock);
 }
 
 /*
@@ -1232,21 +1263,23 @@ int free_swap_and_cache(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
 	struct page *page = NULL;
+	unsigned char count;
 
 	if (non_swap_entry(entry))
 		return 1;
 
-	p = swap_info_get(entry);
+	p = _swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, entry, 1, true) == SWAP_HAS_CACHE) {
+		count = __swap_entry_free(p, entry, 1);
+		if (count == SWAP_HAS_CACHE) {
 			page = find_get_page(swap_address_space(entry),
 					     swp_offset(entry));
 			if (page && !trylock_page(page)) {
 				put_page(page);
 				page = NULL;
 			}
-		}
-		spin_unlock(&p->lock);
+		} else if (!count)
+			swapcache_free_entries(&entry, 1);
 	}
 	if (page) {
 		/*
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
