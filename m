Date: Wed, 14 Jul 2004 23:04:37 +0900 (JST)
Message-Id: <20040714.230437.128870242.taka@valinux.co.jp>
Subject: [PATCH] memory hotremoval for linux-2.6.7 [7/16]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040714.224138.95803956.taka@valinux.co.jp>
References: <20040714.224138.95803956.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

$Id: va-shmem.patch,v 1.5 2004/04/14 06:36:05 iwamoto Exp $

--- linux-2.6.5.ORG/mm/shmem.c	Fri Apr  2 14:05:11 2032
+++ linux-2.6.5/mm/shmem.c	Fri Apr  2 14:43:37 2032
@@ -80,7 +80,13 @@ static inline struct page *shmem_dir_all
 	 * BLOCKS_PER_PAGE on indirect pages, assume PAGE_CACHE_SIZE:
 	 * might be reconsidered if it ever diverges from PAGE_SIZE.
 	 */
+#ifdef CONFIG_MEMHOTPLUG
+	return alloc_pages((gfp_mask & GFP_ZONEMASK) == __GFP_HOTREMOVABLE ? 
+	 	(gfp_mask & ~GFP_ZONEMASK) | __GFP_HIGHMEM : gfp_mask, 
+		    PAGE_CACHE_SHIFT-PAGE_SHIFT);
+#else
 	return alloc_pages(gfp_mask, PAGE_CACHE_SHIFT-PAGE_SHIFT);
+#endif
 }
 
 static inline void shmem_dir_free(struct page *page)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
