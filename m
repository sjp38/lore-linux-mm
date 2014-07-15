Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id A12C76B003D
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:45:02 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 9so2718687ykp.40
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:45:02 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id i46si26060298yhf.104.2014.07.15.12.45.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:45:02 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 7/11] x86, mm: Keep _set_memory_<type>() slot-independent
Date: Tue, 15 Jul 2014 13:34:40 -0600
Message-Id: <1405452884-25688-8-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, konrad.wilk@oracle.com, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de, Toshi Kani <toshi.kani@hp.com>

The _set_memory_<type>() interfaces assume how each memory type is
assigned to PAT slots in the PAT MSTR.  For instance, _set_memory_wb()
assumes that WB is assigned to the PA0/4 slot by calling
change_page_attr_clear().

This patch changes the _set_memory_<type>() interfaces to call
change_page_attr_set_clr() directly for all memory types, and keep
them independent from the PAT slot assignment.

It also introduces pgprot_set_cache() for setting a specified page
cache value to a pgprot_t value.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/mm/pageattr.c |   36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a2a1e70..da597d0 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1444,8 +1444,10 @@ int _set_memory_uc(unsigned long addr, int numpages)
 	/*
 	 * for now UC MINUS. see comments in ioremap_nocache()
 	 */
-	return change_page_attr_set(&addr, numpages,
-				    __pgprot(_PAGE_CACHE_UC_MINUS), 0);
+	return change_page_attr_set_clr(&addr, numpages,
+					__pgprot(_PAGE_CACHE_UC_MINUS),
+					__pgprot(_PAGE_CACHE_MASK),
+					0, 0, NULL);
 }
 
 int set_memory_uc(unsigned long addr, int numpages)
@@ -1489,8 +1491,10 @@ static int _set_memory_array(unsigned long *addr, int addrinarray,
 			goto out_free;
 	}
 
-	ret = change_page_attr_set(addr, addrinarray,
-				    __pgprot(_PAGE_CACHE_UC_MINUS), 1);
+	ret = change_page_attr_set_clr(addr, addrinarray,
+				       __pgprot(_PAGE_CACHE_UC_MINUS),
+				       __pgprot(_PAGE_CACHE_MASK),
+				       0, CPA_ARRAY, NULL);
 
 	if (!ret && new_type == _PAGE_CACHE_WC)
 		ret = change_page_attr_set_clr(addr, addrinarray,
@@ -1526,8 +1530,10 @@ int _set_memory_wc(unsigned long addr, int numpages)
 	int ret;
 	unsigned long addr_copy = addr;
 
-	ret = change_page_attr_set(&addr, numpages,
-				    __pgprot(_PAGE_CACHE_UC_MINUS), 0);
+	ret = change_page_attr_set_clr(&addr, numpages,
+				       __pgprot(_PAGE_CACHE_UC_MINUS),
+				       __pgprot(_PAGE_CACHE_MASK),
+				       0, 0, NULL);
 	if (!ret) {
 		ret = change_page_attr_set_clr(&addr_copy, numpages,
 					       __pgprot(_PAGE_CACHE_WC),
@@ -1570,8 +1576,10 @@ EXPORT_SYMBOL(set_memory_array_wt);
 
 int _set_memory_wt(unsigned long addr, int numpages)
 {
-	return change_page_attr_set(&addr, numpages,
-				    __pgprot(_PAGE_CACHE_WT), 0);
+	return change_page_attr_set_clr(&addr, numpages,
+					__pgprot(_PAGE_CACHE_WT),
+					__pgprot(_PAGE_CACHE_MASK),
+					0, 0, NULL);
 }
 
 int set_memory_wt(unsigned long addr, int numpages)
@@ -1601,8 +1609,10 @@ EXPORT_SYMBOL(set_memory_wt);
 
 int _set_memory_wb(unsigned long addr, int numpages)
 {
-	return change_page_attr_clear(&addr, numpages,
-				      __pgprot(_PAGE_CACHE_MASK), 0);
+	return change_page_attr_set_clr(&addr, numpages,
+					__pgprot(_PAGE_CACHE_WB),
+					__pgprot(_PAGE_CACHE_MASK),
+					0, 0, NULL);
 }
 
 int set_memory_wb(unsigned long addr, int numpages)
@@ -1623,8 +1633,10 @@ int set_memory_array_wb(unsigned long *addr, int addrinarray)
 	int i;
 	int ret;
 
-	ret = change_page_attr_clear(addr, addrinarray,
-				      __pgprot(_PAGE_CACHE_MASK), 1);
+	ret = change_page_attr_set_clr(addr, addrinarray,
+				       __pgprot(_PAGE_CACHE_WB),
+				       __pgprot(_PAGE_CACHE_MASK),
+				       0, CPA_ARRAY, NULL);
 	if (ret)
 		return ret;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
