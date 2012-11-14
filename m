Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id DFF7A6B00BA
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:12:44 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 03/11] zcache: The last of the atomic reads has now an accessory function.
Date: Wed, 14 Nov 2012 14:12:11 -0500
Message-Id: <1352920339-10183-4-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
References: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

And now we can move the code to its own file.

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 99dc045..9e6b6d3 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -252,6 +252,14 @@ static inline void dec_zcache_pers_zpages(unsigned zpages)
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
@@ -551,10 +559,7 @@ static void zcache_free_page(struct page *page)
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
