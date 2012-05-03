Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A011E6B0092
	for <linux-mm@kvack.org>; Thu,  3 May 2012 02:41:16 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
Date: Thu,  3 May 2012 15:40:42 +0900
Message-Id: <1336027242-372-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1336027242-372-1-git-send-email-minchan@kernel.org>
References: <1336027242-372-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

It's a overkill to align pool size with PAGE_SIZE to avoid
false-sharing. This patch aligns it with just cache line size.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 51074fa..3991b03 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -489,14 +489,14 @@ fail:
 
 struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 {
-	int i, error, ovhd_size;
+	int i, error;
 	struct zs_pool *pool;
 
 	if (!name)
 		return NULL;
 
-	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
-	pool = kzalloc(ovhd_size, GFP_KERNEL);
+	pool = kzalloc(ALIGN(sizeof(*pool), cache_line_size()),
+				GFP_KERNEL);
 	if (!pool)
 		return NULL;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
