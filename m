Date: Mon, 6 Mar 2006 16:10:15 -0800
From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: [PATCH] avoid atomic op on page free
Message-ID: <20060307001015.GG32565@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Andrew et al,

The patch below adds a fast path that avoids the atomic dec and test 
operation and spinlock acquire/release on page free.  This is especially 
important to the network stack which uses put_page() to free user 
buffers.  Removing these atomic ops helps improve netperf on the P4 
from ~8126Mbit/s to ~8199Mbit/s (although that number fluctuates quite a 
bit with some runs getting 8243Mbit/s).  There are probably better 
workloads to see an improvement from this on, but removing 3 atomics and 
an irq save/restore is good.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.

Signed-off-by: Benjamin LaHaise <bcrl@linux.intel.com>
diff --git a/mm/swap.c b/mm/swap.c
index cce3dda..d6934cf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -49,7 +49,10 @@ void put_page(struct page *page)
 {
 	if (unlikely(PageCompound(page)))
 		put_compound_page(page);
-	else if (put_page_testzero(page))
+	else if (page_count(page) == 1 && !PageLRU(page)) {
+		set_page_count(page, 0);
+		free_hot_page(page);
+	} else if (put_page_testzero(page))
 		__page_cache_release(page);
 }
 EXPORT_SYMBOL(put_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
