Message-Id: <200405222211.i4MMBkr14112@mail.osdl.org>
Subject: [patch 41/57] rmap 23 empty flush_dcache_mmap_lock
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:11:16 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Most architectures (like i386) do nothing in flush_dcache_page, or don't scan
i_mmap in flush_dcache_page, so don't need flush_dcache_mmap_lock to do
anything: define it and flush_dcache_mmap_unlock away.  Noticed arm26, cris,
h8300 still defining flush_page_to_ram: delete it again.


---

 25-akpm/include/asm-alpha/cacheflush.h      |    2 ++
 25-akpm/include/asm-arm26/cacheflush.h      |    3 ++-
 25-akpm/include/asm-cris/cacheflush.h       |    3 ++-
 25-akpm/include/asm-h8300/cacheflush.h      |    3 ++-
 25-akpm/include/asm-ia64/cacheflush.h       |    3 +++
 25-akpm/include/asm-m68k/cacheflush.h       |    2 ++
 25-akpm/include/asm-m68knommu/cacheflush.h  |    2 ++
 25-akpm/include/asm-mips/cacheflush.h       |    3 +++
 25-akpm/include/asm-ppc/cacheflush.h        |    3 +++
 25-akpm/include/asm-ppc64/cacheflush.h      |    3 +++
 25-akpm/include/asm-s390/cacheflush.h       |    2 ++
 25-akpm/include/asm-sh/cpu-sh2/cacheflush.h |    2 ++
 25-akpm/include/asm-sh/cpu-sh3/cacheflush.h |    2 ++
 25-akpm/include/asm-sh/cpu-sh4/cacheflush.h |    4 ++++
 25-akpm/include/asm-sparc/cacheflush.h      |    2 ++
 25-akpm/include/asm-sparc64/cacheflush.h    |    2 ++
 25-akpm/include/asm-v850/cacheflush.h       |    2 ++
 25-akpm/include/asm-x86_64/cacheflush.h     |    2 ++
 18 files changed, 42 insertions(+), 3 deletions(-)

diff -puN include/asm-alpha/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-alpha/cacheflush.h
--- 25/include/asm-alpha/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.049827304 -0700
+++ 25-akpm/include/asm-alpha/cacheflush.h	2004-05-22 14:56:28.074823504 -0700
@@ -10,6 +10,8 @@
 #define flush_cache_range(vma, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
 
diff -puN include/asm-arm26/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-arm26/cacheflush.h
--- 25/include/asm-arm26/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.050827152 -0700
+++ 25-akpm/include/asm-arm26/cacheflush.h	2004-05-22 14:56:28.074823504 -0700
@@ -24,7 +24,6 @@
 #define flush_cache_mm(mm)                      do { } while (0)
 #define flush_cache_range(vma,start,end)        do { } while (0)
 #define flush_cache_page(vma,vmaddr)            do { } while (0)
-#define flush_page_to_ram(page)                 do { } while (0)
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
 
@@ -32,6 +31,8 @@
 #define clean_dcache_range(start,end)           do { } while (0)
 #define flush_dcache_range(start,end)           do { } while (0)
 #define flush_dcache_page(page)                 do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define clean_dcache_entry(_s)                  do { } while (0)
 #define clean_cache_entry(_start)               do { } while (0)
 
diff -puN include/asm-cris/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-cris/cacheflush.h
--- 25/include/asm-cris/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.051827000 -0700
+++ 25-akpm/include/asm-cris/cacheflush.h	2004-05-22 14:56:28.074823504 -0700
@@ -11,8 +11,9 @@
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
-#define flush_page_to_ram(page)			do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_range(start, end)		do { } while (0)
 #define flush_icache_page(vma,pg)		do { } while (0)
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
diff -puN include/asm-h8300/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-h8300/cacheflush.h
--- 25/include/asm-h8300/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.053826696 -0700
+++ 25-akpm/include/asm-h8300/cacheflush.h	2004-05-22 14:56:28.075823352 -0700
@@ -14,8 +14,9 @@
 #define	flush_cache_mm(mm)
 #define	flush_cache_range(vma,a,b)
 #define	flush_cache_page(vma,p)
-#define	flush_page_to_ram(page)
 #define	flush_dcache_page(page)
+#define	flush_dcache_mmap_lock(mapping)
+#define	flush_dcache_mmap_unlock(mapping)
 #define	flush_icache()
 #define	flush_icache_page(vma,page)
 #define	flush_icache_range(start,len)
diff -puN include/asm-ia64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-ia64/cacheflush.h
--- 25/include/asm-ia64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.054826544 -0700
+++ 25-akpm/include/asm-ia64/cacheflush.h	2004-05-22 14:56:28.075823352 -0700
@@ -29,6 +29,9 @@ do {						\
 	clear_bit(PG_arch_1, &(page)->flags);	\
 } while (0)
 
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
+
 extern void flush_icache_range (unsigned long start, unsigned long end);
 
 #define flush_icache_user_range(vma, page, user_addr, len)					\
diff -puN include/asm-m68k/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-m68k/cacheflush.h
--- 25/include/asm-m68k/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.056826240 -0700
+++ 25-akpm/include/asm-m68k/cacheflush.h	2004-05-22 14:56:28.075823352 -0700
@@ -128,6 +128,8 @@ static inline void __flush_page_to_ram(v
 }
 
 #define flush_dcache_page(page)		__flush_page_to_ram(page_address(page))
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_page(vma, page)	__flush_page_to_ram(page_address(page))
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
diff -puN include/asm-m68knommu/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-m68knommu/cacheflush.h
--- 25/include/asm-m68knommu/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.057826088 -0700
+++ 25-akpm/include/asm-m68knommu/cacheflush.h	2004-05-22 14:56:28.076823200 -0700
@@ -12,6 +12,8 @@
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_dcache_range(start,len)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_range(start,len)		__flush_cache_all()
 #define flush_icache_page(vma,pg)		do { } while (0)
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
diff -puN include/asm-mips/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-mips/cacheflush.h
--- 25/include/asm-mips/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.058825936 -0700
+++ 25-akpm/include/asm-mips/cacheflush.h	2004-05-22 14:56:28.076823200 -0700
@@ -45,6 +45,9 @@ static inline void flush_dcache_page(str
 
 }
 
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
+
 extern void (*flush_icache_page)(struct vm_area_struct *vma,
 	struct page *page);
 extern void (*flush_icache_range)(unsigned long start, unsigned long end);
diff -puN include/asm-ppc64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-ppc64/cacheflush.h
--- 25/include/asm-ppc64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.059825784 -0700
+++ 25-akpm/include/asm-ppc64/cacheflush.h	2004-05-22 14:56:28.076823200 -0700
@@ -18,6 +18,9 @@
 #define flush_cache_vunmap(start, end)		do { } while (0)
 
 extern void flush_dcache_page(struct page *page);
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
+
 extern void __flush_icache_range(unsigned long, unsigned long);
 extern void flush_icache_user_range(struct vm_area_struct *vma,
 				    struct page *page, unsigned long addr,
diff -puN include/asm-ppc/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-ppc/cacheflush.h
--- 25/include/asm-ppc/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.061825480 -0700
+++ 25-akpm/include/asm-ppc/cacheflush.h	2004-05-22 14:56:28.077823048 -0700
@@ -28,6 +28,9 @@
 #define flush_cache_vunmap(start, end)	do { } while (0)
 
 extern void flush_dcache_page(struct page *page);
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
+
 extern void flush_icache_range(unsigned long, unsigned long);
 extern void flush_icache_user_range(struct vm_area_struct *vma,
 		struct page *page, unsigned long addr, int len);
diff -puN include/asm-s390/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-s390/cacheflush.h
--- 25/include/asm-s390/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.062825328 -0700
+++ 25-akpm/include/asm-s390/cacheflush.h	2004-05-22 14:56:28.077823048 -0700
@@ -10,6 +10,8 @@
 #define flush_cache_range(vma, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_range(start, end)		do { } while (0)
 #define flush_icache_page(vma,pg)		do { } while (0)
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
diff -puN include/asm-sh/cpu-sh2/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-sh/cpu-sh2/cacheflush.h
--- 25/include/asm-sh/cpu-sh2/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.063825176 -0700
+++ 25-akpm/include/asm-sh/cpu-sh2/cacheflush.h	2004-05-22 14:56:28.077823048 -0700
@@ -30,6 +30,8 @@
 #define flush_cache_range(vma, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_range(start, end)		do { } while (0)
 #define flush_icache_page(vma,pg)		do { } while (0)
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
diff -puN include/asm-sh/cpu-sh3/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-sh/cpu-sh3/cacheflush.h
--- 25/include/asm-sh/cpu-sh3/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.064825024 -0700
+++ 25-akpm/include/asm-sh/cpu-sh3/cacheflush.h	2004-05-22 14:56:28.078822896 -0700
@@ -30,6 +30,8 @@
 #define flush_cache_range(vma, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_range(start, end)		do { } while (0)
 #define flush_icache_page(vma,pg)		do { } while (0)
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
diff -puN include/asm-sh/cpu-sh4/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-sh/cpu-sh4/cacheflush.h
--- 25/include/asm-sh/cpu-sh4/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.066824720 -0700
+++ 25-akpm/include/asm-sh/cpu-sh4/cacheflush.h	2004-05-22 14:56:28.078822896 -0700
@@ -30,6 +30,10 @@ extern void flush_cache_range(struct vm_
 			      unsigned long end);
 extern void flush_cache_page(struct vm_area_struct *vma, unsigned long addr);
 extern void flush_dcache_page(struct page *pg);
+
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
+
 extern void flush_icache_range(unsigned long start, unsigned long end);
 extern void flush_cache_sigtramp(unsigned long addr);
 extern void flush_icache_user_range(struct vm_area_struct *vma,
diff -puN include/asm-sparc64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-sparc64/cacheflush.h
--- 25/include/asm-sparc64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.067824568 -0700
+++ 25-akpm/include/asm-sparc64/cacheflush.h	2004-05-22 14:56:28.078822896 -0700
@@ -42,6 +42,8 @@ extern void __flush_dcache_range(unsigne
 	memcpy(dst, src, len)
 
 extern void flush_dcache_page(struct page *page);
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
diff -puN include/asm-sparc/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-sparc/cacheflush.h
--- 25/include/asm-sparc/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.068824416 -0700
+++ 25-akpm/include/asm-sparc/cacheflush.h	2004-05-22 14:56:28.079822744 -0700
@@ -70,6 +70,8 @@ BTFIXUPDEF_CALL(void, flush_sig_insns, s
 extern void sparc_flush_page_to_ram(struct page *page);
 
 #define flush_dcache_page(page)			sparc_flush_page_to_ram(page)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 
 #define flush_cache_vmap(start, end)		flush_cache_all()
 #define flush_cache_vunmap(start, end)		flush_cache_all()
diff -puN include/asm-v850/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-v850/cacheflush.h
--- 25/include/asm-v850/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.069824264 -0700
+++ 25-akpm/include/asm-v850/cacheflush.h	2004-05-22 14:56:28.079822744 -0700
@@ -27,6 +27,8 @@
 #define flush_cache_range(vma, start, end)	((void)0)
 #define flush_cache_page(vma, vmaddr)		((void)0)
 #define flush_dcache_page(page)			((void)0)
+#define flush_dcache_mmap_lock(mapping)		((void)0)
+#define flush_dcache_mmap_unlock(mapping)	((void)0)
 #define flush_cache_vmap(start, end)		((void)0)
 #define flush_cache_vunmap(start, end)		((void)0)
 
diff -puN include/asm-x86_64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock include/asm-x86_64/cacheflush.h
--- 25/include/asm-x86_64/cacheflush.h~rmap-23-empty-flush_dcache_mmap_lock	2004-05-22 14:56:28.071823960 -0700
+++ 25-akpm/include/asm-x86_64/cacheflush.h	2004-05-22 14:56:28.079822744 -0700
@@ -10,6 +10,8 @@
 #define flush_cache_range(vma, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_range(start, end)		do { } while (0)
 #define flush_icache_page(vma,pg)		do { } while (0)
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
