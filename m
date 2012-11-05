Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 08D526B005D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 09:50:28 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 05/11] zcache: The last of the atomic reads has now an accessory function.
Date: Mon,  5 Nov 2012 09:37:28 -0500
Message-Id: <1352126254-28933-6-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
References: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, ngupta@vflare.org, minchan@kernel.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
Cc: akpm@linux-foundation.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

And now we can move the code to its own file.
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 29ffbf1..3402acc 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -250,6 +250,14 @@ static inline void dec_zcache_pers_zpages(unsigned zpages)
 {
 	zcache_pers_zpages = atomic_sub_return(zpages, &zcache_pers_zpages_atomic);
 }
+
+static inline unsigned long curr_pageframes_count(void)
+{
+	return zcache_pageframes_alloced -
+		atomic_read(&zcache_pageframes_freed_atomic) -
+		atomic_read(&zcache_eph_pageframes_atomic) -
+		atomic_read(&zcache_pers_pageframes_atomic);
+};
 /* but for the rest of these, counting races are ok */
 static unsigned long zcache_flush_total;
 static unsigned long zcache_flush_found;
@@ -549,10 +557,7 @@ static void zcache_free_page(struct page *page)
 		BUG();
 	__free_page(page);
 	inc_zcache_pageframes_freed();
-	curr_pageframes = zcache_pageframes_alloced -
-			atomic_read(&zcache_pageframes_freed_atomic) -
-			atomic_read(&zcache_eph_pageframes_atomic) -
-			atomic_read(&zcache_pers_pageframes_atomic);
+	curr_pageframes = curr_pageframes_count();
 	if (curr_pageframes > max_pageframes)
 		max_pageframes = curr_pageframes;
 	if (curr_pageframes < min_pageframes)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
