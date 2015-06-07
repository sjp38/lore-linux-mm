Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 863F76B0071
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:43:36 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so86386949pdb.2
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:43:36 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id gf2si375253pbd.94.2015.06.07.10.43.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:43:35 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:42:57 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-623dffb2a2e059e1ace45b59b3ff21c66c419614@git.kernel.org>
Reply-To: akpm@linux-foundation.org, tglx@linutronix.de, luto@amacapital.net,
        hpa@zytor.com, bp@suse.de, peterz@infradead.org,
        linux-kernel@vger.kernel.org, mingo@kernel.org, toshi.kani@hp.com,
        mcgrof@suse.com, torvalds@linux-foundation.org, linux-mm@kvack.org
In-Reply-To: <1433436928-31903-13-git-send-email-bp@alien8.de>
References: <1433436928-31903-13-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/pat: Add set_memory_wt()
  for Write-Through type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: luto@amacapital.net, hpa@zytor.com, bp@suse.de, akpm@linux-foundation.org, tglx@linutronix.de, linux-mm@kvack.org, peterz@infradead.org, linux-kernel@vger.kernel.org, toshi.kani@hp.com, mingo@kernel.org, torvalds@linux-foundation.org, mcgrof@suse.com

Commit-ID:  623dffb2a2e059e1ace45b59b3ff21c66c419614
Gitweb:     http://git.kernel.org/tip/623dffb2a2e059e1ace45b59b3ff21c66c419614
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:20 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:29:00 +0200

x86/mm/pat: Add set_memory_wt() for Write-Through type

Now that reserve_ram_pages_type() accepts the WT type, add
set_memory_wt(), set_memory_array_wt() and set_pages_array_wt()
in order to be able to set memory to Write-Through page cache
mode.

Also, extend ioremap_change_attr() to accept the WT type.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-13-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 Documentation/x86/pat.txt         |  9 ++++--
 arch/x86/include/asm/cacheflush.h |  6 +++-
 arch/x86/mm/ioremap.c             |  3 ++
 arch/x86/mm/pageattr.c            | 62 +++++++++++++++++++++++++++++++--------
 4 files changed, 63 insertions(+), 17 deletions(-)

diff --git a/Documentation/x86/pat.txt b/Documentation/x86/pat.txt
index db0de6c..54944c7 100644
--- a/Documentation/x86/pat.txt
+++ b/Documentation/x86/pat.txt
@@ -48,6 +48,9 @@ set_memory_uc          |    UC-   |    --      |       --         |
 set_memory_wc          |    WC    |    --      |       --         |
  set_memory_wb         |          |            |                  |
                        |          |            |                  |
+set_memory_wt          |    WT    |    --      |       --         |
+ set_memory_wb         |          |            |                  |
+                       |          |            |                  |
 pci sysfs resource     |    --    |    --      |       UC-        |
                        |          |            |                  |
 pci sysfs resource_wc  |    --    |    --      |       WC         |
@@ -150,8 +153,8 @@ can be more restrictive, in case of any existing aliasing for that address.
 For example: If there is an existing uncached mapping, a new ioremap_wc can
 return uncached mapping in place of write-combine requested.
 
-set_memory_[uc|wc] and set_memory_wb should be used in pairs, where driver will
-first make a region uc or wc and switch it back to wb after use.
+set_memory_[uc|wc|wt] and set_memory_wb should be used in pairs, where driver
+will first make a region uc, wc or wt and switch it back to wb after use.
 
 Over time writes to /proc/mtrr will be deprecated in favor of using PAT based
 interfaces. Users writing to /proc/mtrr are suggested to use above interfaces.
@@ -159,7 +162,7 @@ interfaces. Users writing to /proc/mtrr are suggested to use above interfaces.
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
index 07cd46a..8405c0c 100644
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
index 31b4f3f..727158c 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1503,12 +1503,10 @@ EXPORT_SYMBOL(set_memory_uc);
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
@@ -1516,9 +1514,12 @@ static int _set_memory_array(unsigned long *addr, int addrinarray,
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
@@ -1550,6 +1551,12 @@ int set_memory_array_wc(unsigned long *addr, int addrinarray)
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
@@ -1575,21 +1582,39 @@ int set_memory_wc(unsigned long addr, int numpages)
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 		_PAGE_CACHE_MODE_WC, NULL);
 	if (ret)
-		goto out_err;
+		return ret;
 
 	ret = _set_memory_wc(addr, numpages);
 	if (ret)
-		goto out_free;
+		free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
 
-	return 0;
-
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
@@ -1680,6 +1705,7 @@ static int _set_pages_array(struct page **pages, int addrinarray,
 {
 	unsigned long start;
 	unsigned long end;
+	enum page_cache_mode set_type;
 	int i;
 	int free_idx;
 	int ret;
@@ -1693,8 +1719,12 @@ static int _set_pages_array(struct page **pages, int addrinarray,
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
@@ -1728,6 +1758,12 @@ int set_pages_array_wc(struct page **pages, int addrinarray)
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
