Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 410756B003D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 06:09:46 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 20:03:07 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 3B7EE357804E
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:09:32 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2E9uFdc54001768
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 20:56:16 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EA91lx009052
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:09:01 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 3/4] introduce zero-filled page stat count
Date: Thu, 14 Mar 2013 18:08:16 +0800
Message-Id: <1363255697-19674-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Introduce zero-filled page statistics to monitor the number of
zero-filled pages.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index db200b4..2091a4d 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -196,6 +196,7 @@ static ssize_t zcache_eph_nonactive_puts_ignored;
 static ssize_t zcache_pers_nonactive_puts_ignored;
 static ssize_t zcache_writtenback_pages;
 static ssize_t zcache_outstanding_writeback_pages;
+static ssize_t zcache_pages_zero;
 
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
@@ -257,6 +258,7 @@ static int zcache_debugfs_init(void)
 	zdfs("outstanding_writeback_pages", S_IRUGO, root,
 				&zcache_outstanding_writeback_pages);
 	zdfs("writtenback_pages", S_IRUGO, root, &zcache_writtenback_pages);
+	zdfs("pages_zero", S_IRUGO, root, &zcache_pages_zero);
 	return 0;
 }
 #undef	zdebugfs
@@ -326,6 +328,7 @@ void zcache_dump(void)
 	pr_info("zcache: outstanding_writeback_pages=%zd\n",
 				zcache_outstanding_writeback_pages);
 	pr_info("zcache: writtenback_pages=%zd\n", zcache_writtenback_pages);
+	pr_info("zcache: pages_zero=%zd\n", zcache_pages_zero);
 }
 #endif
 
@@ -562,6 +565,7 @@ static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
 		kunmap_atomic(user_mem);
 		clen = 0;
 		zero_filled = true;
+		zcache_pages_zero++;
 		goto got_pampd;
 	}
 	kunmap_atomic(user_mem);
@@ -645,6 +649,7 @@ static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
 		kunmap_atomic(user_mem);
 		clen = 0;
 		zero_filled = true;
+		zcache_pages_zero++;
 		goto got_pampd;
 	}
 	kunmap_atomic(user_mem);
@@ -866,6 +871,7 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 		zpages = 0;
 		if (!raw)
 			*sizep = PAGE_SIZE;
+		zcache_pages_zero--;
 		goto zero_fill;
 	}
 
@@ -922,6 +928,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		zero_filled = true;
 		zsize = 0;
 		zpages = 0;
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
