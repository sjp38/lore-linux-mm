Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 4612F6B0037
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 03:06:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 17:01:03 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id AA53D2BB0053
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:05:40 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2D6qtBt10813858
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 17:52:56 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2D75dLt005985
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:05:39 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/4] zcache: introduce zero-filled pages stat count
Date: Wed, 13 Mar 2013 15:05:20 +0800
Message-Id: <1363158321-20790-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Introduce zero-filled page statistics to monitor the number of
zero-filled pages.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index ed5ef26..dd52975 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -191,6 +191,7 @@ static ssize_t zcache_eph_nonactive_puts_ignored;
 static ssize_t zcache_pers_nonactive_puts_ignored;
 static ssize_t zcache_writtenback_pages;
 static ssize_t zcache_outstanding_writeback_pages;
+static ssize_t zcache_pages_zero;
 
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
@@ -252,6 +253,7 @@ static int zcache_debugfs_init(void)
 	zdfs("outstanding_writeback_pages", S_IRUGO, root,
 				&zcache_outstanding_writeback_pages);
 	zdfs("writtenback_pages", S_IRUGO, root, &zcache_writtenback_pages);
+	zdfs("pages_zero", S_IRUGO, root, &zcache_pages_zero);
 	return 0;
 }
 #undef	zdebugfs
@@ -321,6 +323,7 @@ void zcache_dump(void)
 	pr_info("zcache: outstanding_writeback_pages=%zd\n",
 				zcache_outstanding_writeback_pages);
 	pr_info("zcache: writtenback_pages=%zd\n", zcache_writtenback_pages);
+	pr_info("zcache: pages_zero=%zd\n", zcache_pages_zero);
 }
 #endif
 
@@ -557,6 +560,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 		kunmap_atomic(user_mem);
 		clen = 0;
 		zero_filled = true;
+		zcache_pages_zero++;
 		goto got_pampd;
 	}
 	kunmap_atomic(user_mem);
@@ -639,6 +643,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 		kunmap_atomic(user_mem);
 		clen = 0;
 		zero_filled = 1;
+		zcache_pages_zero++;
 		goto got_pampd;
 	}
 	kunmap_atomic(user_mem);
@@ -859,6 +864,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 		zpages = 1;
 		if (!raw)
 			*sizep = PAGE_SIZE;
+		zcache_pages_zero--;
 		goto zero_fill;
 	}
 
@@ -915,6 +921,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		zero_filled = true;
 		zsize = 0;
 		zpages = 1;
+		zcache_pages_zero--;
 	}
 
 	if (pampd_is_remote(pampd) && !zero_filled) {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
