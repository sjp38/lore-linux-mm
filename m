From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023005.7915.10365.sendpatchset@debian>
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
Subject: [PATCH 1/8] Add the __GFP_NOLRU flag
Date: Tue, 31 Jan 2006 11:30:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds the __GFP_NOLRU flag.  This option should be used 
for GFP_USER/GFP_HIGHUSER page allocations that are not maintained
in the zone LRU lists.

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 include/linux/gfp.h |    3 ++-
 mm/shmem.c          |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff -urNp a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h	2006-01-03 12:21:10.000000000 +0900
+++ b/include/linux/gfp.h	2006-01-26 19:14:54.000000000 +0900
@@ -47,6 +47,7 @@ struct vm_area_struct;
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
+#define __GFP_NOLRU      ((__force gfp_t)0x40000u) /* GFP_USER but will not be in LRU lists */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -55,7 +56,7 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_HARDWALL)
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_NOLRU)
 
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
diff -urNp a/mm/shmem.c b/mm/shmem.c
--- a/mm/shmem.c	2006-01-03 12:21:10.000000000 +0900
+++ b/mm/shmem.c	2006-01-26 19:14:54.000000000 +0900
@@ -366,7 +366,7 @@ static swp_entry_t *shmem_swp_alloc(stru
 		}
 
 		spin_unlock(&info->lock);
-		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping) | __GFP_ZERO);
+		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping) | __GFP_ZERO | __GFP_NOLRU);
 		if (page)
 			set_page_private(page, 0);
 		spin_lock(&info->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
