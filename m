Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id BB1258D0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 07:10:32 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v5 10/14] memory-hotplug: remove memmap of sparse-vmemmap
Date: Mon, 24 Dec 2012 20:09:20 +0800
Message-Id: <1356350964-13437-11-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

This patch introduces a new API vmemmap_free() to free and remove
vmemmap pagetables. Since pagetable implements are different, each
architecture has to provide its own version of vmemmap_free(), just
like vmemmap_populate().

Note:  vmemmap_free() are not implemented for ia64, ppc, s390, and sparc.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/arm64/mm/mmu.c       |    3 +++
 arch/ia64/mm/discontig.c  |    4 ++++
 arch/powerpc/mm/init_64.c |    4 ++++
 arch/s390/mm/vmem.c       |    4 ++++
 arch/sparc/mm/init_64.c   |    4 ++++
 arch/x86/mm/init_64.c     |    8 ++++++++
 include/linux/mm.h        |    1 +
 mm/sparse.c               |    3 ++-
 8 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index a6885d8..9834886 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -392,4 +392,7 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return 0;
 }
 #endif	/* CONFIG_ARM64_64K_PAGES */
+void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+{
+}
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 33943db..882a0fd 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -823,6 +823,10 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return vmemmap_populate_basepages(start_page, size, node);
 }
 
+void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 6466440..2969591 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -298,6 +298,10 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return 0;
 }
 
+void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 2c14bc2..81e6ba3 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -272,6 +272,10 @@ out:
 	return ret;
 }
 
+void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 7e28c9e..9cd1ec0 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2232,6 +2232,10 @@ void __meminit vmemmap_populate_print_last(void)
 	}
 }
 
+void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 4b160d8..029c0b9 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1307,6 +1307,14 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 	return 0;
 }
 
+void __ref vmemmap_free(struct page *memmap, unsigned long nr_pages)
+{
+	unsigned long start = (unsigned long)memmap;
+	unsigned long end = (unsigned long)(memmap + nr_pages);
+
+	remove_pagetable(start, end, false);
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1eca498..31d5e5d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1709,6 +1709,7 @@ int vmemmap_populate_basepages(struct page *start_page,
 						unsigned long pages, int node);
 int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 void vmemmap_populate_print_last(void);
+void vmemmap_free(struct page *memmap, unsigned long nr_pages);
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 05ca73a..cff9796 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -615,10 +615,11 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 }
 static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 {
-	return; /* XXX: Not implemented yet */
+	vmemmap_free(memmap, nr_pages);
 }
 static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
 {
+	vmemmap_free(memmap, nr_pages);
 }
 #else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
