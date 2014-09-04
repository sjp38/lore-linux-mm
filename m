Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED816B0039
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 14:47:40 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 131so6290850ykp.40
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 11:47:40 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id r42si13548743yho.178.2014.09.04.11.47.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 11:47:40 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
Date: Thu,  4 Sep 2014 12:35:38 -0600
Message-Id: <1409855739-8985-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch adds set_memory_wt(), set_memory_array_wt(), and
set_pages_array_wt() for setting range(s) of memory to WT.

Note that reserve_memtype() only supports WT for non-RAM ranges
at this point.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/cacheflush.h |    6 +++
 arch/x86/mm/pageattr.c            |   73 ++++++++++++++++++++++++++++++++++---
 2 files changed, 72 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index c912680..5bfd5d0 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -81,7 +81,7 @@ static inline void set_page_memtype(struct page *pg,
 /*
  * The set_memory_* API can be used to change various attributes of a virtual
  * address range. The attributes include:
- * Cachability   : UnCached, WriteCombining, WriteBack
+ * Cachability   : UnCached, WriteCombining, WriteThrough, WriteBack
  * Executability : eXeutable, NoteXecutable
  * Read/Write    : ReadOnly, ReadWrite
  * Presence      : NotPresent
@@ -108,9 +108,11 @@ static inline void set_page_memtype(struct page *pg,
 
 int _set_memory_uc(unsigned long addr, int numpages);
 int _set_memory_wc(unsigned long addr, int numpages);
+int _set_memory_wt(unsigned long addr, int numpages);
 int _set_memory_wb(unsigned long addr, int numpages);
 int set_memory_uc(unsigned long addr, int numpages);
 int set_memory_wc(unsigned long addr, int numpages);
+int set_memory_wt(unsigned long addr, int numpages);
 int set_memory_wb(unsigned long addr, int numpages);
 int set_memory_x(unsigned long addr, int numpages);
 int set_memory_nx(unsigned long addr, int numpages);
@@ -121,10 +123,12 @@ int set_memory_4k(unsigned long addr, int numpages);
 
 int set_memory_array_uc(unsigned long *addr, int addrinarray);
 int set_memory_array_wc(unsigned long *addr, int addrinarray);
+int set_memory_array_wt(unsigned long *addr, int addrinarray);
 int set_memory_array_wb(unsigned long *addr, int addrinarray);
 
 int set_pages_array_uc(struct page **pages, int addrinarray);
 int set_pages_array_wc(struct page **pages, int addrinarray);
+int set_pages_array_wt(struct page **pages, int addrinarray);
 int set_pages_array_wb(struct page **pages, int addrinarray);
 
 /*
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 6917b39..2dda151 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1484,12 +1484,10 @@ EXPORT_SYMBOL(set_memory_uc);
 static int _set_memory_array(unsigned long *addr, int addrinarray,
 		enum page_cache_mode new_type)
 {
+	enum page_cache_mode set_type;
 	int i, j;
 	int ret;
 
-	/*
-	 * for now UC MINUS. see comments in ioremap_nocache()
-	 */
 	for (i = 0; i < addrinarray; i++) {
 		ret = reserve_memtype(__pa(addr[i]), __pa(addr[i]) + PAGE_SIZE,
 					new_type, NULL);
@@ -1497,9 +1495,12 @@ static int _set_memory_array(unsigned long *addr, int addrinarray,
 			goto out_free;
 	}
 
+	/* If WC, set to UC- first and then WC */
+	set_type = (new_type == _PAGE_CACHE_MODE_WC) ?
+				_PAGE_CACHE_MODE_UC_MINUS : new_type;
+
 	ret = change_page_attr_set(addr, addrinarray,
-				   cachemode2pgprot(_PAGE_CACHE_MODE_UC_MINUS),
-				   1);
+				   cachemode2pgprot(set_type), 1);
 
 	if (!ret && new_type == _PAGE_CACHE_MODE_WC)
 		ret = change_page_attr_set_clr(addr, addrinarray,
@@ -1527,10 +1528,22 @@ EXPORT_SYMBOL(set_memory_array_uc);
 
 int set_memory_array_wc(unsigned long *addr, int addrinarray)
 {
+	if (!pat_enabled)
+		return set_memory_array_uc(addr, addrinarray);
+
 	return _set_memory_array(addr, addrinarray, _PAGE_CACHE_MODE_WC);
 }
 EXPORT_SYMBOL(set_memory_array_wc);
 
+int set_memory_array_wt(unsigned long *addr, int addrinarray)
+{
+	if (!pat_enabled)
+		return set_memory_array_uc(addr, addrinarray);
+
+	return _set_memory_array(addr, addrinarray, _PAGE_CACHE_MODE_WT);
+}
+EXPORT_SYMBOL(set_memory_array_wt);
+
 int _set_memory_wc(unsigned long addr, int numpages)
 {
 	int ret;
@@ -1574,6 +1587,37 @@ out_err:
 }
 EXPORT_SYMBOL(set_memory_wc);
 
+int _set_memory_wt(unsigned long addr, int numpages)
+{
+	return change_page_attr_set(&addr, numpages,
+				    cachemode2pgprot(_PAGE_CACHE_MODE_WT), 0);
+}
+
+int set_memory_wt(unsigned long addr, int numpages)
+{
+	int ret;
+
+	if (!pat_enabled)
+		return set_memory_uc(addr, numpages);
+
+	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
+			      _PAGE_CACHE_MODE_WT, NULL);
+	if (ret)
+		goto out_err;
+
+	ret = _set_memory_wt(addr, numpages);
+	if (ret)
+		goto out_free;
+
+	return 0;
+
+out_free:
+	free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
+out_err:
+	return ret;
+}
+EXPORT_SYMBOL(set_memory_wt);
+
 int _set_memory_wb(unsigned long addr, int numpages)
 {
 	/* WB cache mode is hard wired to all cache attribute bits being 0 */
@@ -1666,6 +1710,7 @@ static int _set_pages_array(struct page **pages, int addrinarray,
 {
 	unsigned long start;
 	unsigned long end;
+	enum page_cache_mode set_type;
 	int i;
 	int free_idx;
 	int ret;
@@ -1679,8 +1724,12 @@ static int _set_pages_array(struct page **pages, int addrinarray,
 			goto err_out;
 	}
 
+	/* If WC, set to UC- first and then WC */
+	set_type = (new_type == _PAGE_CACHE_MODE_WC) ?
+				_PAGE_CACHE_MODE_UC_MINUS : new_type;
+
 	ret = cpa_set_pages_array(pages, addrinarray,
-			cachemode2pgprot(_PAGE_CACHE_MODE_UC_MINUS));
+				  cachemode2pgprot(set_type));
 	if (!ret && new_type == _PAGE_CACHE_MODE_WC)
 		ret = change_page_attr_set_clr(NULL, addrinarray,
 					       cachemode2pgprot(
@@ -1710,10 +1759,22 @@ EXPORT_SYMBOL(set_pages_array_uc);
 
 int set_pages_array_wc(struct page **pages, int addrinarray)
 {
+	if (!pat_enabled)
+		return set_pages_array_uc(pages, addrinarray);
+
 	return _set_pages_array(pages, addrinarray, _PAGE_CACHE_MODE_WC);
 }
 EXPORT_SYMBOL(set_pages_array_wc);
 
+int set_pages_array_wt(struct page **pages, int addrinarray)
+{
+	if (!pat_enabled)
+		return set_pages_array_uc(pages, addrinarray);
+
+	return _set_pages_array(pages, addrinarray, _PAGE_CACHE_MODE_WT);
+}
+EXPORT_SYMBOL(set_pages_array_wt);
+
 int set_pages_wb(struct page *page, int numpages)
 {
 	unsigned long addr = (unsigned long)page_address(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
