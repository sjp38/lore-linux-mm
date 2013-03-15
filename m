Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2C3896B0036
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:35:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 15 Mar 2013 12:28:56 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 39E03357804A
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 13:35:33 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2F2M74X61407356
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 13:22:07 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2F2Z1EU012769
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 13:35:02 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 1/5] introduce zero filled pages handler
Date: Fri, 15 Mar 2013 10:34:16 +0800
Message-Id: <1363314860-22731-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Introduce zero-filled pages handler to capture and handle zero pages.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 328898e..d73dd4b 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -460,6 +460,32 @@ static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
 	kmem_cache_free(zcache_obj_cache, obj);
 }
 
+static bool page_is_zero_filled(void *ptr)
+{
+	unsigned int pos;
+	unsigned long *page;
+
+	page = (unsigned long *)ptr;
+
+	for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++) {
+		if (page[pos])
+			return false;
+	}
+
+	return true;
+}
+
+static void handle_zero_filled_page(void *page)
+{
+	void *user_mem;
+
+	user_mem = kmap_atomic(page);
+	memset(user_mem, 0, PAGE_SIZE);
+	kunmap_atomic(user_mem);
+
+	flush_dcache_page(page);
+}
+
 static struct tmem_hostops zcache_hostops = {
 	.obj_alloc = zcache_obj_alloc,
 	.obj_free = zcache_obj_free,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
