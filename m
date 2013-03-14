Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 1AE9E6B0037
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 06:09:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 20:02:25 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 58FF82CE804C
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:08:58 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2E9u3HN63373328
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 20:56:03 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EA8vbe026004
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 21:08:57 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 1/4] introduce zero filled pages handler
Date: Thu, 14 Mar 2013 18:08:14 +0800
Message-Id: <1363255697-19674-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
index 328898e..b71e033 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -460,6 +460,32 @@ static void zcache_obj_free(struct tmem_obj *obj, struct tmem_pool *pool)
 	kmem_cache_free(zcache_obj_cache, obj);
 }
 
+static bool page_zero_filled(void *ptr)
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
+static void handle_zero_page(void *page)
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
