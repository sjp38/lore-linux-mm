Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id DFC346B003A
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 03:05:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 17:01:29 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 83886357804A
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:05:42 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2D6qmom8257956
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 17:52:48 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2D75fo6016310
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:05:41 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 4/4] zcache: add pageframes count once compress zero-filled pages twice
Date: Wed, 13 Mar 2013 15:05:21 +0800
Message-Id: <1363158321-20790-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Since zbudpage consist of two zpages, two zero-filled pages compression
contribute to one [eph|pers]pageframe count accumulated.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index dd52975..7860ff0 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -544,6 +544,8 @@ static struct page *zcache_evict_eph_pageframe(void);
 static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 					struct tmem_handle *th)
 {
+	static ssize_t second_eph_zero_page;
+	static atomic_t second_eph_zero_page_atomic = ATOMIC_INIT(0);
 	void *pampd = NULL, *cdata = data;
 	unsigned clen = size;
 	bool zero_filled = false;
@@ -561,7 +563,14 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 		clen = 0;
 		zero_filled = true;
 		zcache_pages_zero++;
-		goto got_pampd;
+		second_eph_zero_page = atomic_inc_return(
+				&second_eph_zero_page_atomic);
+		if (second_eph_zero_page % 2 == 1)
+			goto got_pampd;
+		else {
+			atomic_sub(2, &second_eph_zero_page_atomic);
+			goto count_zero_page;
+		}
 	}
 	kunmap_atomic(user_mem);
 
@@ -597,6 +606,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 create_in_new_page:
 	pampd = (void *)zbud_create_prep(th, true, cdata, clen, newpage);
 	BUG_ON(pampd == NULL);
+count_zero_page:
 	zcache_eph_pageframes =
 		atomic_inc_return(&zcache_eph_pageframes_atomic);
 	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
@@ -621,6 +631,8 @@ out:
 static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 					struct tmem_handle *th)
 {
+	static ssize_t second_pers_zero_page;
+	static atomic_t second_pers_zero_page_atomic = ATOMIC_INIT(0);
 	void *pampd = NULL, *cdata = data;
 	unsigned clen = size, zero_filled = 0;
 	struct page *page = (struct page *)(data), *newpage;
@@ -644,7 +656,15 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 		clen = 0;
 		zero_filled = 1;
 		zcache_pages_zero++;
-		goto got_pampd;
+		second_pers_zero_page = atomic_inc_return(
+				&second_pers_zero_page_atomic);
+		if (second_pers_zero_page % 2 == 1)
+			goto got_pampd;
+		else {
+			atomic_sub(2, &second_pers_zero_page_atomic);
+			goto count_zero_page;
+		}
+
 	}
 	kunmap_atomic(user_mem);
 
@@ -698,6 +718,7 @@ create_pampd:
 create_in_new_page:
 	pampd = (void *)zbud_create_prep(th, false, cdata, clen, newpage);
 	BUG_ON(pampd == NULL);
+count_zero_page:
 	zcache_pers_pageframes =
 		atomic_inc_return(&zcache_pers_pageframes_atomic);
 	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
