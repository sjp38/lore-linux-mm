Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id CD6C26B007D
	for <linux-mm@kvack.org>; Wed, 13 May 2015 17:25:39 -0400 (EDT)
Received: by oign205 with SMTP id n205so41777307oig.2
        for <linux-mm@kvack.org>; Wed, 13 May 2015 14:25:39 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id w64si11345977oia.82.2015.05.13.14.25.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 14:25:39 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v9 8/10] x86, mm: Add set_memory_wt() for WT
Date: Wed, 13 May 2015 15:05:49 -0600
Message-Id: <1431551151-19124-9-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

Now that reserve_ram_pages_type() accepts the WT type,
this patch adds set_memory_wt(), set_memory_array_wt() and
set_pages_array_wt() for setting the WT type to the regular
memory.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 Documentation/x86/pat.txt         |    9 ++++-
 arch/x86/include/asm/cacheflush.h |    6 +++-
 arch/x86/mm/pageattr.c            |   61 +++++++++++++++++++++++++++++++++----
 3 files changed, 66 insertions(+), 10 deletions(-)

diff --git a/Documentation/x86/pat.txt b/Documentation/x86/pat.txt
index be7b8c2..bf4339c 100644
--- a/Documentation/x86/pat.txt
+++ b/Documentation/x86/pat.txt
@@ -46,6 +46,9 @@ set_memory_uc          |    UC-   |    --      |       --         |
 set_memory_wc          |    WC    |    --      |       --         |
  set_memory_wb         |          |            |                  |
                        |          |            |                  |
+set_memory_wt          |    WT    |    --      |       --         |
+ set_memory_wb         |          |            |                  |
+                       |          |            |                  |
 pci sysfs resource     |    --    |    --      |       UC-        |
                        |          |            |                  |
 pci sysfs resource_wc  |    --    |    --      |       WC         |
@@ -117,8 +120,8 @@ can be more restrictive, in case of any existing aliasing for that address.
 For example: If there is an existing uncached mapping, a new ioremap_wc can
 return uncached mapping in place of write-combine requested.
 
-set_memory_[uc|wc] and set_memory_wb should be used in pairs, where driver will
-first make a region uc or wc and switch it back to wb after use.
+set_memory_[uc|wc|wt] and set_memory_wb should be used in pairs, where driver
+will first make a region uc, wc or wt and switch it back to wb after use.
 
 Over time writes to /proc/mtrr will be deprecated in favor of using PAT based
 interfaces. Users writing to /proc/mtrr are suggested to use above interfaces.
@@ -126,7 +129,7 @@ interfaces. Users writing to /proc/mtrr are suggested to use above interfaces.
 Drivers should use ioremap_[uc|wc] to access PCI BARs with [uc|wc] access
 types.
 
-Drivers should use set_memory_[uc|wc] to set access type for RAM ranges.
+Drivers should use set_memory_[uc|wc|wt] to set access type for RAM ranges.
 
 
 PAT debugging
diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index 47c8e32..b6f7457 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -8,7 +8,7 @@
 /*
  * The set_memory_* API can be used to change various attributes of a virtual
  * address range. The attributes include:
- * Cachability   : UnCached, WriteCombining, WriteBack
+ * Cachability   : UnCached, WriteCombining, WriteThrough, WriteBack
  * Executability : eXeutable, NoteXecutable
  * Read/Write    : ReadOnly, ReadWrite
  * Presence      : NotPresent
@@ -35,9 +35,11 @@
 
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
@@ -48,10 +50,12 @@ int set_memory_4k(unsigned long addr, int numpages);
 
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
index 89af288..a4d39cc 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1502,12 +1502,10 @@ EXPORT_SYMBOL(set_memory_uc);
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
@@ -1515,9 +1513,12 @@ static int _set_memory_array(unsigned long *addr, int addrinarray,
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
@@ -1549,6 +1550,12 @@ int set_memory_array_wc(unsigned long *addr, int addrinarray)
 }
 EXPORT_SYMBOL(set_memory_array_wc);
 
+int set_memory_array_wt(unsigned long *addr, int addrinarray)
+{
+	return _set_memory_array(addr, addrinarray, _PAGE_CACHE_MODE_WT);
+}
+EXPORT_SYMBOL_GPL(set_memory_array_wt);
+
 int _set_memory_wc(unsigned long addr, int numpages)
 {
 	int ret;
@@ -1592,6 +1599,37 @@ out_err:
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
+EXPORT_SYMBOL_GPL(set_memory_wt);
+
 int _set_memory_wb(unsigned long addr, int numpages)
 {
 	/* WB cache mode is hard wired to all cache attribute bits being 0 */
@@ -1682,6 +1720,7 @@ static int _set_pages_array(struct page **pages, int addrinarray,
 {
 	unsigned long start;
 	unsigned long end;
+	enum page_cache_mode set_type;
 	int i;
 	int free_idx;
 	int ret;
@@ -1695,8 +1734,12 @@ static int _set_pages_array(struct page **pages, int addrinarray,
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
@@ -1730,6 +1773,12 @@ int set_pages_array_wc(struct page **pages, int addrinarray)
 }
 EXPORT_SYMBOL(set_pages_array_wc);
 
+int set_pages_array_wt(struct page **pages, int addrinarray)
+{
+	return _set_pages_array(pages, addrinarray, _PAGE_CACHE_MODE_WT);
+}
+EXPORT_SYMBOL_GPL(set_pages_array_wt);
+
 int set_pages_wb(struct page *page, int numpages)
 {
 	unsigned long addr = (unsigned long)page_address(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
