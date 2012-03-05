Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id E7FBC6B007E
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 12:34:00 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 10:33:59 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2BCF63E4004E
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 10:33:57 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25HXevu064116
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:40 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25HXeDS032218
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:40 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/5] staging: zsmalloc: add ZS_MAX_PAGES_PER_ZSPAGE
Date: Mon,  5 Mar 2012 11:33:21 -0600
Message-Id: <1330968804-8098-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch moves where max_zspage_order is declared and
changes its meaning.  "Order" typically implies 2^order
of something; however, it is currently being used as the
"maximum number of single pages in a zspage".  To add clarity,
ZS_MAX_ZSPAGE_ORDER is now used to calculate ZS_MAX_PAGES_PER_ZSPAGE,
which is 2^ZS_MAX_ZSPAGE_ORDER and is the upper bound on the number
of pages in a zspage.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |    2 +-
 drivers/staging/zsmalloc/zsmalloc_int.h  |   13 +++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 240bcbf..09caa4f 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -186,7 +186,7 @@ static int get_zspage_order(int class_size)
 	/* zspage order which gives maximum used size per KB */
 	int max_usedpc_order = 1;
 
-	for (i = 1; i <= max_zspage_order; i++) {
+	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
 		int zspage_size;
 		int waste, usedpc;
 
diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index e06e142..4d66d2d 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -26,6 +26,13 @@
 #define ZS_ALIGN		8
 
 /*
+ * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
+ * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
+ */
+#define ZS_MAX_ZSPAGE_ORDER 2
+#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
+
+/*
  * Object location (<PFN>, <obj_idx>) is encoded as
  * as single (void *) handle value.
  *
@@ -59,12 +66,6 @@
 					ZS_SIZE_CLASS_DELTA + 1)
 
 /*
- * A single 'zspage' is composed of N discontiguous 0-order (single) pages.
- * This defines upper limit on N.
- */
-static const int max_zspage_order = 4;
-
-/*
  * We do not maintain any list for completely empty or full pages
  */
 enum fullness_group {
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
