Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D6C6E6B00E4
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 06:16:38 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 3 Apr 2013 15:42:24 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 28A503940053
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 15:46:33 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r33AGQWj63701246
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 15:46:26 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r33AGUrT025927
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 21:16:30 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v6 2/3] staging: zcache: introduce zero-filled page stat count
Date: Wed,  3 Apr 2013 18:16:22 +0800
Message-Id: <1364984183-9711-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Introduce zero-filled page statistics to monitor the number of
zero-filled pages.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/debug.c       |    3 +++
 drivers/staging/zcache/debug.h       |   17 +++++++++++++++++
 drivers/staging/zcache/zcache-main.c |    4 ++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/debug.c b/drivers/staging/zcache/debug.c
index faab2a9..daa2691 100644
--- a/drivers/staging/zcache/debug.c
+++ b/drivers/staging/zcache/debug.c
@@ -35,6 +35,8 @@ ssize_t zcache_pers_ate_eph;
 ssize_t zcache_pers_ate_eph_failed;
 ssize_t zcache_evicted_eph_zpages;
 ssize_t zcache_evicted_eph_pageframes;
+ssize_t zcache_zero_filled_pages;
+ssize_t zcache_zero_filled_pages_max;
 
 #define ATTR(x)  { .name = #x, .val = &zcache_##x, }
 static struct debug_entry {
@@ -62,6 +64,7 @@ static struct debug_entry {
 	ATTR(last_inactive_anon_pageframes),
 	ATTR(eph_nonactive_puts_ignored),
 	ATTR(pers_nonactive_puts_ignored),
+	ATTR(zero_filled_pages),
 #ifdef CONFIG_ZCACHE_WRITEBACK
 	ATTR(outstanding_writeback_pages),
 	ATTR(writtenback_pages),
diff --git a/drivers/staging/zcache/debug.h b/drivers/staging/zcache/debug.h
index 8ec82d4..ddad92f 100644
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
@@ -200,6 +215,8 @@ static inline void inc_zcache_eph_zpages(void) { };
 static inline void dec_zcache_eph_zpages(unsigned zpages) { };
 static inline void inc_zcache_pers_zpages(void) { };
 static inline void dec_zcache_pers_zpages(unsigned zpages) { };
+static inline void inc_zcache_zero_filled_pages(void) { };
+static inline void dec_zcache_zero_filled_pages(void) { };
 static inline unsigned long curr_pageframes_count(void)
 {
 	return 0;
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 1994cab..f3de76d 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -374,6 +374,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 	if (page_is_zero_filled(page)) {
 		clen = 0;
 		zero_filled = true;
+		inc_zcache_zero_filled_pages();
 		goto got_pampd;
 	}
 
@@ -440,6 +441,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 	if (page_is_zero_filled(page)) {
 		clen = 0;
 		zero_filled = true;
+		inc_zcache_zero_filled_pages();
 		goto got_pampd;
 	}
 
@@ -652,6 +654,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 		zpages = 1;
 		if (!raw)
 			*sizep = PAGE_SIZE;
+		dec_zcache_zero_filled_pages();
 		goto zero_fill;
 	}
 
@@ -702,6 +705,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		zero_filled = true;
 		zsize = 0;
 		zpages = 1;
+		dec_zcache_zero_filled_pages();
 	}
 
 	if (pampd_is_remote(pampd) && !zero_filled) {
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
