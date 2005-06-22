Date: Wed, 22 Jun 2005 09:39:15 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050622163915.25515.46440.25758@tomahawk.engr.sgi.com>
In-Reply-To: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
Subject: [PATCH 2.6.12-rc5 1/10] mm: hirokazu-steal_page_from_lru.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi Dave,

Would you apply the following patch right after
AA-PM-01-steal_page_from_lru.patch.

This patch makes steal_page_from_lru() and putback_page_to_lru()
check PageLRU() with zone->lur_lock held. Currently the process
migration code, where Ray is working on, only uses this code.

Thanks,
Hirokazu Takahashi.


Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
---

 linux-2.6.12-rc3-taka/include/linux/mm_inline.h |    8 +++++---
 1 files changed, 5 insertions, 3 deletions

diff -puN include/linux/mm_inline.h~taka-steal_page_from_lru-FIX include/linux/mm_inline.h
--- linux-2.6.12-rc3/include/linux/mm_inline.h~taka-steal_page_from_lru-FIX	Mon May 23 02:26:57 2005
+++ linux-2.6.12-rc3-taka/include/linux/mm_inline.h	Mon May 23 02:26:57 2005
@@ -80,9 +80,10 @@ static inline int
 steal_page_from_lru(struct zone *zone, struct page *page,
 			struct list_head *dst)
 {
-	int ret;
+	int ret = 0;
 	spin_lock_irq(&zone->lru_lock);
-	ret = __steal_page_from_lru(zone, page, dst);
+	if (PageLRU(page))
+		ret = __steal_page_from_lru(zone, page, dst);
 	spin_unlock_irq(&zone->lru_lock);
 	return ret;
 }
@@ -102,7 +103,8 @@ static inline void
 putback_page_to_lru(struct zone *zone, struct page *page)
 {
 	spin_lock_irq(&zone->lru_lock);
-	__putback_page_to_lru(zone, page);
+	if (!PageLRU(page))
+		__putback_page_to_lru(zone, page);
 	spin_unlock_irq(&zone->lru_lock);
 }
 
_


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
Lhms-devel mailing list
Lhms-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/lhms-devel


-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
