Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBD36B0105
	for <linux-mm@kvack.org>; Wed, 27 May 2015 11:39:08 -0400 (EDT)
Received: by paza2 with SMTP id a2so573217paz.3
        for <linux-mm@kvack.org>; Wed, 27 May 2015 08:39:07 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id rr7si26398301pbc.173.2015.05.27.08.39.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 08:39:07 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v10 9/12] x86, mm: Add set_memory_wt() for WT
Date: Wed, 27 May 2015 09:19:01 -0600
Message-Id: <1432739944-22633-10-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

Now that reserve_ram_pages_type() accepts the WT type, this
patch adds set_memory_wt(), set_memory_array_wt() and
set_pages_array_wt() for setting the WT type to the regular
memory.

ioremap_change_attr() is also extended to accept the WT type.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 Documentation/x86/pat.txt         |    9 +++--
 arch/x86/include/asm/cacheflush.h |    6 +++
 arch/x86/mm/ioremap.c             |    3 ++
 arch/x86/mm/pageattr.c            |   65 ++++++++++++++++++++++++++++++-------
 4 files changed, 66 insertions(+), 17 deletions(-)

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
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index ae8c284..7e702dc 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -42,6 +42,9 @@ int ioremap_change_attr(unsigned long vaddr, unsigned long size,
 	case _PAGE_CACHE_MODE_WC:
 		err = _set_memory_wc(vaddr, nrpages);
 		break;
+	case _PAGE_CACHE_MODE_WT:
+		err = _set_memory_wt(vaddr, nrpages);
+		break;
 	case _PAGE_CACHE_MODE_WB:
 		err = _set_memory_wb(vaddr, nrpages);
 		break;
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 89af288..6427273 100644
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
@@ -1577,21 +1584,42 @@ int set_memory_wc(unsigned long addr, int numpages)
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 		_PAGE_CACHE_MODE_WC, NULL);
 	if (ret)
-		goto out_err;
+		return ret;
 
 	ret = _set_memory_wc(addr, numpages);
 	if (ret)
-		goto out_free;
-
-	return 0;
+		free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
 
-out_free:
-	free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
-out_err:
 	return ret;
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
+		return ret;
+
+	ret = _set_memory_wt(addr, numpages);
+	if (ret)
+		free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(set_memory_wt);
+
 int _set_memory_wb(unsigned long addr, int numpages)
 {
 	/* WB cache mode is hard wired to all cache attribute bits being 0 */
@@ -1682,6 +1710,7 @@ static int _set_pages_array(struct page **pages, int addrinarray,
 {
 	unsigned long start;
 	unsigned long end;
+	enum page_cache_mode set_type;
 	int i;
 	int free_idx;
 	int ret;
@@ -1695,8 +1724,12 @@ static int _set_pages_array(struct page **pages, int addrinarray,
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
@@ -1730,6 +1763,12 @@ int set_pages_array_wc(struct page **pages, int addrinarray)
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
