Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id DE9946B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:42:10 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so38609eek.6
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:42:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si1421654eeo.151.2013.12.18.11.42.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:42:10 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/6] mm: Annotate page cache allocations
Date: Wed, 18 Dec 2013 19:42:02 +0000
Message-Id: <1387395723-25391-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1387395723-25391-1-git-send-email-mgorman@suse.de>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The fair zone allocation policy needs to distinguish between anonymous,
slab and file-backed pages. This patch annotates many of the page cache
allocations by adjusting __page_cache_alloc. This does not guarantee
that all page cache allocations are being properly annotated. One case
for special consideration is shmem. sysv shared memory and MAP_SHARED
anonymous pages are backed by this and they should be treated as anon by
the fair allocation policy. It is also used by tmpfs which arguably should
be treated as file by the fair allocation policy.

The primary top-level shmem allocation function is shmem_getpage_gfp
which ultimately uses alloc_pages_vma() and not __page_cache_alloc. This
is correct for sysv and MAP_SHARED but tmpfs is still treated as anonymous.
This patch special cases shmem to annotate tmpfs allocations as files for
the fair zone allocation policy.

Cc: <stable@kernel.org> # 3.12
Cannot-sign-off-without-Johannes
---
 include/linux/gfp.h     |  4 +++-
 include/linux/pagemap.h |  2 +-
 mm/filemap.c            |  3 ++-
 mm/shmem.c              | 14 ++++++++++++++
 4 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 9b4dd49..f69e4cb 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -35,6 +35,7 @@ struct vm_area_struct;
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
+#define ___GFP_PAGECACHE	0x2000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -92,6 +93,7 @@ struct vm_area_struct;
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
 #define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
+#define __GFP_PAGECACHE ((__force gfp_t)___GFP_PAGECACHE)   /* Page cache allocation */
 
 /*
  * This may seem redundant, but it's a way of annotating false positives vs.
@@ -99,7 +101,7 @@ struct vm_area_struct;
  */
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
-#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..bda4845 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -221,7 +221,7 @@ extern struct page *__page_cache_alloc(gfp_t gfp);
 #else
 static inline struct page *__page_cache_alloc(gfp_t gfp)
 {
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp | __GFP_PAGECACHE, 0);
 }
 #endif
 
diff --git a/mm/filemap.c b/mm/filemap.c
index b7749a9..d36d2ba 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -527,7 +527,8 @@ struct page *__page_cache_alloc(gfp_t gfp)
 
 		return page;
 	}
-	return alloc_pages(gfp, 0);
+
+	return alloc_pages(gfp | __GFP_PAGECACHE, 0);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
diff --git a/mm/shmem.c b/mm/shmem.c
index 8297623..02d7a9c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -929,6 +929,17 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 	return page;
 }
 
+/* Fugly method of distinguishing sysv/MAP_SHARED anon from tmpfs */
+static bool shmem_inode_on_tmpfs(struct shmem_inode_info *info)
+{
+	/* If no internal shm_mount then it must be tmpfs */
+	if (IS_ERR(shm_mnt))
+		return true;
+
+	/* Consider it to be tmpfs if the superblock is not the internal mount */
+	return info->vfs_inode.i_sb != shm_mnt->mnt_sb;
+}
+
 static struct page *shmem_alloc_page(gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
@@ -942,6 +953,9 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
+	if (shmem_inode_on_tmpfs(info))
+		gfp |= __GFP_PAGECACHE;
+
 	page = alloc_page_vma(gfp, &pvma, 0);
 
 	/* Drop reference taken by mpol_shared_policy_lookup() */
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
