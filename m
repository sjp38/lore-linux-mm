Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 5347F6B036D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:42:16 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 12:42:14 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 31CCD38C8216
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:55 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PGEroV34013304
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PGEq4v002991
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:14:52 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
Date: Mon, 25 Jun 2012 11:14:38 -0500
Message-Id: <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch adds support for a local_tlb_flush_kernel_range()
function for the x86 arch.  This function allows for CPU-local
TLB flushing, potentially using invlpg for single entry flushing,
using an arch independent function name.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 arch/x86/include/asm/tlbflush.h |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 36a1a2a..92a280b 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -168,4 +168,25 @@ static inline void flush_tlb_kernel_range(unsigned long start,
 	flush_tlb_all();
 }
 
+#define __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE
+/*
+ * INVLPG_BREAK_EVEN_PAGES is the number of pages after which single tlb
+ * flushing becomes more costly than just doing a complete tlb flush.
+ * While this break even point varies among x86 hardware, tests have shown
+ * that 8 is a good generic value.
+*/
+#define INVLPG_BREAK_EVEN_PAGES 8
+static inline void local_flush_tlb_kernel_range(unsigned long start,
+		unsigned long end)
+{
+	if (cpu_has_invlpg &&
+		(end - start)/PAGE_SIZE <= INVLPG_BREAK_EVEN_PAGES) {
+		while (start < end) {
+			__flush_tlb_single(start);
+			start += PAGE_SIZE;
+		}
+	} else
+		local_flush_tlb();
+}
+
 #endif /* _ASM_X86_TLBFLUSH_H */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
