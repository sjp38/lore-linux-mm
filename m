Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 91A3F6B002D
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 00:38:23 -0500 (EST)
From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 52/62] mm: remove the second argument of k[un]map_atomic()
Date: Sun, 27 Nov 2011 13:27:32 +0800
Message-Id: <1322371662-26166-53-git-send-email-amwang@redhat.com>
In-Reply-To: <1322371662-26166-1-git-send-email-amwang@redhat.com>
References: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Cong Wang <amwang@redhat.com>, Hugh Dickins <hughd@google.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, David Vrabel <david.vrabel@citrix.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, Michel Lespinasse <walken@google.com>, Cesar Eduardo Barros <cesarb@cesarb.net>, Eric B Munson <emunson@mgebm.net>, Pekka Enberg <penberg@kernel.org>, Joe Perches <joe@perches.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org


Signed-off-by: Cong Wang <amwang@redhat.com>
---
 mm/bounce.c   |    4 ++--
 mm/filemap.c  |    8 ++++----
 mm/ksm.c      |   12 ++++++------
 mm/memory.c   |    4 ++--
 mm/shmem.c    |    4 ++--
 mm/swapfile.c |   30 +++++++++++++++---------------
 mm/vmalloc.c  |    8 ++++----
 7 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/mm/bounce.c b/mm/bounce.c
index 4e9ae72..d1be02c 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -50,9 +50,9 @@ static void bounce_copy_vec(struct bio_vec *to, unsigned char *vfrom)
 	unsigned char *vto;
 
 	local_irq_save(flags);
-	vto = kmap_atomic(to->bv_page, KM_BOUNCE_READ);
+	vto = kmap_atomic(to->bv_page);
 	memcpy(vto + to->bv_offset, vfrom, to->bv_len);
-	kunmap_atomic(vto, KM_BOUNCE_READ);
+	kunmap_atomic(vto);
 	local_irq_restore(flags);
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index c0018f2..1c5f8f7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1332,10 +1332,10 @@ int file_read_actor(read_descriptor_t *desc, struct page *page,
 	 * taking the kmap.
 	 */
 	if (!fault_in_pages_writeable(desc->arg.buf, size)) {
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		left = __copy_to_user_inatomic(desc->arg.buf,
 						kaddr + offset, size);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		if (left == 0)
 			goto success;
 	}
@@ -2062,7 +2062,7 @@ size_t iov_iter_copy_from_user_atomic(struct page *page,
 	size_t copied;
 
 	BUG_ON(!in_atomic());
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (likely(i->nr_segs == 1)) {
 		int left;
 		char __user *buf = i->iov->iov_base + i->iov_offset;
@@ -2072,7 +2072,7 @@ size_t iov_iter_copy_from_user_atomic(struct page *page,
 		copied = __iovec_copy_from_user_inatomic(kaddr + offset,
 						i->iov, i->iov_offset, bytes);
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	return copied;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 310544a..a6d3fb7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -672,9 +672,9 @@ error:
 static u32 calc_checksum(struct page *page)
 {
 	u32 checksum;
-	void *addr = kmap_atomic(page, KM_USER0);
+	void *addr = kmap_atomic(page);
 	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
-	kunmap_atomic(addr, KM_USER0);
+	kunmap_atomic(addr);
 	return checksum;
 }
 
@@ -683,11 +683,11 @@ static int memcmp_pages(struct page *page1, struct page *page2)
 	char *addr1, *addr2;
 	int ret;
 
-	addr1 = kmap_atomic(page1, KM_USER0);
-	addr2 = kmap_atomic(page2, KM_USER1);
+	addr1 = kmap_atomic(page1);
+	addr2 = kmap_atomic(page2);
 	ret = memcmp(addr1, addr2, PAGE_SIZE);
-	kunmap_atomic(addr2, KM_USER1);
-	kunmap_atomic(addr1, KM_USER0);
+	kunmap_atomic(addr2);
+	kunmap_atomic(addr1);
 	return ret;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 829d437..07ace87 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2428,7 +2428,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 	 * fails, we just zero-fill it. Live with it.
 	 */
 	if (unlikely(!src)) {
-		void *kaddr = kmap_atomic(dst, KM_USER0);
+		void *kaddr = kmap_atomic(dst);
 		void __user *uaddr = (void __user *)(va & PAGE_MASK);
 
 		/*
@@ -2439,7 +2439,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 		 */
 		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
 			clear_page(kaddr);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		flush_dcache_page(dst);
 	} else
 		copy_user_highpage(dst, src, va, vma);
diff --git a/mm/shmem.c b/mm/shmem.c
index d672250..5bc679d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1631,9 +1631,9 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		}
 		inode->i_mapping->a_ops = &shmem_aops;
 		inode->i_op = &shmem_symlink_inode_operations;
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memcpy(kaddr, symname, len);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		set_page_dirty(page);
 		unlock_page(page);
 		page_cache_release(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b1cd120..94d8a62 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2426,9 +2426,9 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 		if (!(count & COUNT_CONTINUED))
 			goto out;
 
-		map = kmap_atomic(list_page, KM_USER0) + offset;
+		map = kmap_atomic(list_page) + offset;
 		count = *map;
-		kunmap_atomic(map, KM_USER0);
+		kunmap_atomic(map);
 
 		/*
 		 * If this continuation count now has some space in it,
@@ -2471,7 +2471,7 @@ static bool swap_count_continued(struct swap_info_struct *si,
 
 	offset &= ~PAGE_MASK;
 	page = list_entry(head->lru.next, struct page, lru);
-	map = kmap_atomic(page, KM_USER0) + offset;
+	map = kmap_atomic(page) + offset;
 
 	if (count == SWAP_MAP_MAX)	/* initial increment from swap_map */
 		goto init_map;		/* jump over SWAP_CONT_MAX checks */
@@ -2481,26 +2481,26 @@ static bool swap_count_continued(struct swap_info_struct *si,
 		 * Think of how you add 1 to 999
 		 */
 		while (*map == (SWAP_CONT_MAX | COUNT_CONTINUED)) {
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.next, struct page, lru);
 			BUG_ON(page == head);
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 		}
 		if (*map == SWAP_CONT_MAX) {
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.next, struct page, lru);
 			if (page == head)
 				return false;	/* add count continuation */
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 init_map:		*map = 0;		/* we didn't zero the page */
 		}
 		*map += 1;
-		kunmap_atomic(map, KM_USER0);
+		kunmap_atomic(map);
 		page = list_entry(page->lru.prev, struct page, lru);
 		while (page != head) {
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 			*map = COUNT_CONTINUED;
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.prev, struct page, lru);
 		}
 		return true;			/* incremented */
@@ -2511,22 +2511,22 @@ init_map:		*map = 0;		/* we didn't zero the page */
 		 */
 		BUG_ON(count != COUNT_CONTINUED);
 		while (*map == COUNT_CONTINUED) {
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.next, struct page, lru);
 			BUG_ON(page == head);
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 		}
 		BUG_ON(*map == 0);
 		*map -= 1;
 		if (*map == 0)
 			count = 0;
-		kunmap_atomic(map, KM_USER0);
+		kunmap_atomic(map);
 		page = list_entry(page->lru.prev, struct page, lru);
 		while (page != head) {
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 			*map = SWAP_CONT_MAX | count;
 			count = COUNT_CONTINUED;
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.prev, struct page, lru);
 		}
 		return count == COUNT_CONTINUED;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3231bf3..1a39dca 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1879,9 +1879,9 @@ static int aligned_vread(char *buf, char *addr, unsigned long count)
 			 * we can expect USER0 is not used (see vread/vwrite's
 			 * function description)
 			 */
-			void *map = kmap_atomic(p, KM_USER0);
+			void *map = kmap_atomic(p);
 			memcpy(buf, map + offset, length);
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 		} else
 			memset(buf, 0, length);
 
@@ -1918,9 +1918,9 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
 			 * we can expect USER0 is not used (see vread/vwrite's
 			 * function description)
 			 */
-			void *map = kmap_atomic(p, KM_USER0);
+			void *map = kmap_atomic(p);
 			memcpy(map + offset, buf, length);
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 		}
 		addr += length;
 		buf += length;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
