Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 8EC666B0039
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 05:26:21 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 19 Mar 2013 19:15:54 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3C2E82BB0023
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:13 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2J9Q90D2031894
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:09 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2J9QCYq012642
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:12 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 7/8] staging: zcache: introduce zero-filled page stat count
Date: Tue, 19 Mar 2013 17:25:49 +0800
Message-Id: <1363685150-18303-8-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Introduce zero-filled page statistics to monitor the number of
zero-filled pages.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/debug.h       |   15 +++++++++++++++
 drivers/staging/zcache/zcache-main.c |    5 +++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/debug.h b/drivers/staging/zcache/debug.h
index 8ec82d4..178bf75 100644
--- a/drivers/staging/zcache/debug.h
+++ b/drivers/staging/zcache/debug.h
@@ -122,6 +122,21 @@ static inline void dec_zcache_pers_zpages(unsigned zpages)
 	zcache_pers_zpages = atomic_sub_return(zpages, &zcache_pers_zpages_atomic);
 }
 
+extern ssize_t zcache_zero_filled_pages;
+static atomic_t zcache_zero_filled_pages_atomic = ATOMIC_INIT(0);
+extern ssize_t zcache_zero_filled_pages_max;
+static inline void inc_zcache_zero_filled_pages(void)
+{
+	zcache_zero_filled_pages = atomic_inc_return(
+					&zcache_zero_filled_pages_atomic);
+	if (zcache_zero_filled_pages > zcache_zero_filled_pages_max)
+		zcache_zero_filled_pages_max = zcache_zero_filled_pages;
+}
+static inline void dec_zcache_zero_filled_pages(void)
+{
+	zcache_zero_filled_pages = atomic_dec_return(
+					&zcache_zero_filled_pages_atomic);
+}
 static inline unsigned long curr_pageframes_count(void)
 {
 	return zcache_pageframes_alloced -
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index d1118f0..f8ba619 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -176,6 +176,8 @@ ssize_t zcache_pers_ate_eph;
 ssize_t zcache_pers_ate_eph_failed;
 ssize_t zcache_evicted_eph_zpages;
 ssize_t zcache_evicted_eph_pageframes;
+ssize_t zcache_zero_filled_pages;
+ssize_t zcache_zero_filled_pages_max;
 
 /* Used by this code. */
 ssize_t zcache_last_active_file_pageframes;
@@ -404,6 +406,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 	if (page_is_zero_filled(page)) {
 		clen = 0;
 		zero_filled = true;
+		inc_zcache_zero_filled_pages();
 		goto got_pampd;
 	}
 
@@ -470,6 +473,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 	if (page_is_zero_filled(page)) {
 		clen = 0;
 		zero_filled = true;
+		inc_zcache_zero_filled_pages();
 		goto got_pampd;
 	}
 
@@ -682,6 +686,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 		zpages = 1;
 		if (!raw)
 			*sizep = PAGE_SIZE;
+		dec_zcache_zero_filled_pages();
 		goto zero_fill;
 	}
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
