Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BECC16B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 12:33:51 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 10:33:50 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id CDD81C40010
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 10:33:46 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25HXg7k090024
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:43 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25HXf0P032408
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 10:33:42 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/5] staging: zsmalloc: calculate MAX_PHYSMEM_BITS if not defined
Date: Mon,  5 Mar 2012 11:33:22 -0600
Message-Id: <1330968804-8098-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1330968804-8098-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch provides a way to determine or "set a
reasonable value for" MAX_PHYSMEM_BITS in the case that
it is not defined (i.e. !SPARSEMEM)

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/zsmalloc_int.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index 4d66d2d..ffb272f 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -39,7 +39,21 @@
  * Note that object index <obj_idx> is relative to system
  * page <PFN> it is stored in, so for each sub-page belonging
  * to a zspage, obj_idx starts with 0.
+ *
+ * This is made more complicated by various memory models and PAE.
+ */
+
+#ifndef MAX_PHYSMEM_BITS
+#ifdef CONFIG_HIGHMEM64G
+#define MAX_PHYSMEM_BITS 36
+#else /* !CONFIG_HIGHMEM64G */
+/*
+ * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
+ * be PAGE_SHIFT
  */
+#define MAX_PHYSMEM_BITS BITS_PER_LONG
+#endif
+#endif
 #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
 #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
 #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
