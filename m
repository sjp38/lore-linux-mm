Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp01.au.ibm.com (8.12.10/8.12.10) with ESMTP id j199xuqI037312
	for <linux-mm@kvack.org>; Wed, 9 Feb 2005 20:59:57 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j19A0PCh231868
	for <linux-mm@kvack.org>; Wed, 9 Feb 2005 21:00:25 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11/8.12.11) with ESMTP id j199wAl4023925
	for <linux-mm@kvack.org>; Wed, 9 Feb 2005 20:58:10 +1100
Date: Wed, 9 Feb 2005 20:58:07 +1100
From: Michael Ellerman <michael@ellerman.id.au>
Subject: [Patch] Fix oops in alloc_zeroed_user_highpage() when page is NULL
Message-Id: <20050209205807.221d4591.michael@ellerman.id.au>
In-Reply-To: <Pine.LNX.4.58.0501211206380.25925@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
	<20050108135636.6796419a.davem@davemloft.net>
	<Pine.LNX.4.58.0501211206380.25925@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: davem@davemloft.net, hugh@veritas.com, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi All,

The generic and IA-64 versions of alloc_zeroed_user_highpage() don't check the return value from alloc_page_vma(). This can lead to an oops if we're OOM.

This fixes my oops on PPC64, but I haven't got an IA-64 machine/compiler handy.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>

diff -rN -p -u oombreakage-old/include/asm-ia64/page.h oombreakage-new/include/asm-ia64/page.h
--- oombreakage-old/include/asm-ia64/page.h	2005-02-04 04:10:37.000000000 +1100
+++ oombreakage-new/include/asm-ia64/page.h	2005-02-09 20:53:37.000000000 +1100
@@ -79,7 +79,8 @@ do {						\
 #define alloc_zeroed_user_highpage(vma, vaddr) \
 ({						\
 	struct page *page = alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr); \
-	flush_dcache_page(page);		\
+	if (page)				\
+ 		flush_dcache_page(page);	\
 	page;					\
 })
 
diff -rN -p -u oombreakage-old/include/linux/highmem.h oombreakage-new/include/linux/highmem.h
--- oombreakage-old/include/linux/highmem.h	2005-02-09 20:22:41.000000000 +1100
+++ oombreakage-new/include/linux/highmem.h	2005-02-09 20:47:01.000000000 +1100
@@ -48,7 +48,9 @@ alloc_zeroed_user_highpage(struct vm_are
 {
 	struct page *page = alloc_page_vma(GFP_HIGHUSER, vma, vaddr);
 
-	clear_user_highpage(page, vaddr);
+	if (page)
+		clear_user_highpage(page, vaddr);
+
 	return page;
 }
 #endif



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
