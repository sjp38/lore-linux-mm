Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9EE566B0038
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 20:26:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 05:51:07 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E666E3940058
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:56:06 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A0Q2Tm7209364
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:56:03 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A0Q5xV002583
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 00:26:05 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 01/10] staging: zcache: fix account foregin counters against zero-filled pages
Date: Wed, 10 Apr 2013 08:25:51 +0800
Message-Id: <1365553560-32258-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

zero-filled pages won't be compressed and sent to remote system. Monitor
the number ephemeral and persistent pages that Ramster has sent make no
sense. This patch skip account foregin counters against zero-filled pages.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index f3de76d..e23d814 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -415,7 +415,7 @@ create_in_new_page:
 got_pampd:
 	inc_zcache_eph_zbytes(clen);
 	inc_zcache_eph_zpages();
-	if (ramster_enabled && raw)
+	if (ramster_enabled && raw && !zero_filled)
 		ramster_count_foreign_pages(true, 1);
 	if (zero_filled)
 		pampd = (void *)ZERO_FILLED;
@@ -500,7 +500,7 @@ create_in_new_page:
 got_pampd:
 	inc_zcache_pers_zpages();
 	inc_zcache_pers_zbytes(clen);
-	if (ramster_enabled && raw)
+	if (ramster_enabled && raw && !zero_filled)
 		ramster_count_foreign_pages(false, 1);
 	if (zero_filled)
 		pampd = (void *)ZERO_FILLED;
@@ -681,7 +681,7 @@ zero_fill:
 		dec_zcache_pers_zpages(zpages);
 		dec_zcache_pers_zbytes(zsize);
 	}
-	if (!is_local_client(pool->client))
+	if (!is_local_client(pool->client) && !zero_filled)
 		ramster_count_foreign_pages(eph, -1);
 	if (page && !zero_filled)
 		zcache_free_page(page);
@@ -732,7 +732,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		dec_zcache_pers_zpages(zpages);
 		dec_zcache_pers_zbytes(zsize);
 	}
-	if (!is_local_client(pool->client))
+	if (!is_local_client(pool->client) && !zero_filled)
 		ramster_count_foreign_pages(is_ephemeral(pool), -1);
 	if (page && !zero_filled)
 		zcache_free_page(page);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
