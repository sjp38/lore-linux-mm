Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 72C088D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 07:12:00 -0500 (EST)
Received: by qyk2 with SMTP id 2so5206258qyk.14
        for <linux-mm@kvack.org>; Thu, 10 Mar 2011 04:11:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110309142311.1d8073fe.akpm@linux-foundation.org>
References: <bug-30702-27@https.bugzilla.kernel.org/>
	<20110309142311.1d8073fe.akpm@linux-foundation.org>
Date: Thu, 10 Mar 2011 12:11:56 +0000
Message-ID: <AANLkTinMeuH+HrHj73yo0St6P6y0P+fTqFLOkMwzbE5=@mail.gmail.com>
Subject: Re: [Bug 30702] New: vmalloc(GFP_NOFS) can callback file system
 evict_inode, inducing deadlock.
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

>
> Ricardo has been working on this. =A0See the thread at
> http://marc.info/?l=3Dlinux-mm&m=3D128942194520631&w=3D4
>
> It's tough, and we've been bad, and progress is slow :(
>
>> =A0 =A0 =A0 =A0 =A0 =A0Product: Memory Management

Thanks Andrew,

Hi Richardo,

I too worked on the problem last day, here is a patch which adds a new func=
tion
__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)

The function __pte_alloc_kernel() can use __pte_alloc_one_kernel()
along with the correct GFP flag.

int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
{
    pte_t *new =3D __pte_alloc_one_kernel(&init_mm, address, GFP_KERNEL);
}

I thought of going from bottom to up, passing GFP_KERNEL flag for
testing. If everything works fine then the GFP flag can be changed.

I am planning to run few tests on x86 machine to ensure it works.
BTW, if you are following some other approach, I can test the patch on
my machine.
I hope the browser will not trim the lines at the bottom. This is the patch

---
diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgal=
loc.h
index bc2a0da..a5685aa 100644
--- a/arch/alpha/include/asm/pgalloc.h
+++ b/arch/alpha/include/asm/pgalloc.h
@@ -51,10 +51,15 @@ pmd_free(struct mm_struct *mm, pmd_t *pmd)
 }

 static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addressi,
gfp_t gfp_mask)
+{
+	return (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+}
+
+static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZER=
O);
-	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline void
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.=
h
index 9763be0..a4161c8 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -57,17 +57,24 @@ static inline void clean_pte_table(pte_t *pte)
  *  +------------+
  */
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr,
gfp_t gfp_mask)
 {
 	pte_t *pte;

-	pte =3D (pte_t *)__get_free_page(PGALLOC_GFP);
+	pte =3D (pte_t *)__get_free_page(gfp_mask | __GFP_NOTRACK |
+		__GFP_REPEAT | __GFP_ZERO);
 	if (pte)
 		clean_pte_table(pte);

 	return pte;
 }

+static inline pte_t *
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+{
+	return __pte_alloc_one_kernel(mm, addr, GFP_KERNEL);
+}
+
 static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgal=
loc.h
index bc7e8ae..2eb4824 100644
--- a/arch/avr32/include/asm/pgalloc.h
+++ b/arch/avr32/include/asm/pgalloc.h
@@ -51,10 +51,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	quicklist_free(QUICK_PGD, NULL, pgd);
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address, gfp_t gfp_mask)
+{
+	return quicklist_alloc(QUICK_PT, gfp_mask | __GFP_REPEAT, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/cris/include/asm/pgalloc.h b/arch/cris/include/asm/pgallo=
c.h
index 6da975d..453a388 100644
--- a/arch/cris/include/asm/pgalloc.h
+++ b/arch/cris/include/asm/pgalloc.h
@@ -22,10 +22,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+	gfp_t gfp_mask)
+{
+  	return (pte_t *) __get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
 {
-  	pte_t *pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_Z=
ERO);
- 	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned
long address)
diff --git a/arch/frv/mm/pgalloc.c b/arch/frv/mm/pgalloc.c
index c42c83d..c74ace1 100644
--- a/arch/frv/mm/pgalloc.c
+++ b/arch/frv/mm/pgalloc.c
@@ -20,14 +20,19 @@

 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((aligned(PAGE_SIZE)));

-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long
address, gfp_t gfp_mask)
 {
-	pte_t *pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte =3D (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
 	return pte;
 }

+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *page;
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgallo=
c.h
index 96a8d92..be59452 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -95,10 +95,16 @@ static inline pgtable_t pte_alloc_one(struct
mm_struct *mm, unsigned long addr)
 	return page;
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long addr, gfp_t gfp_mask)
+{
+	return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long addr)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return __pte_alloc_one_kernel(mm, addr, GFP_KERNEL);
 }

 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
diff --git a/arch/m32r/include/asm/pgalloc.h b/arch/m32r/include/asm/pgallo=
c.h
index 0fc7361..fd6650f 100644
--- a/arch/m32r/include/asm/pgalloc.h
+++ b/arch/m32r/include/asm/pgalloc.h
@@ -30,12 +30,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }

+static __inline__ pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+	unsigned long address, gfp_t gfp_mask)
+{
+	return (pte_t *)__get_free_page(gfp_mask|__GFP_ZERO);
+}
+
 static __inline__ pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	unsigned long address)
 {
-	pte_t *pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
-
-	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static __inline__ pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/m68k/include/asm/motorola_pgalloc.h
b/arch/m68k/include/asm/motorola_pgalloc.h
index 2f02f26..c5190f8 100644
--- a/arch/m68k/include/asm/motorola_pgalloc.h
+++ b/arch/m68k/include/asm/motorola_pgalloc.h
@@ -7,11 +7,13 @@
 extern pmd_t *get_pointer_table(void);
 extern int free_pointer_table(pmd_t *);

-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+	gfp_t gfp_mask)
 {
 	pte_t *pte;

-	pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte =3D (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	if (pte) {
 		__flush_page_to_ram(pte);
 		flush_tlb_kernel_page(pte);
@@ -21,6 +23,12 @@ static inline pte_t *pte_alloc_one_kernel(struct
mm_struct *mm, unsigned long ad
 	return pte;
 }

+static inline pte_t *
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	cache_page(pte);
diff --git a/arch/m68k/include/asm/sun3_pgalloc.h
b/arch/m68k/include/asm/sun3_pgalloc.h
index 48d80d5..383a8bf 100644
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -38,10 +38,11 @@ do {							\
 	tlb_remove_page((tlb), pte);			\
 } while (0)

-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
 {
-	unsigned long page =3D __get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	unsigned long page =3D __get_free_page(gfp_mask|__GFP_REPEAT);

 	if (!page)
 		return NULL;
@@ -50,6 +51,12 @@ static inline pte_t *pte_alloc_one_kernel(struct
mm_struct *mm,
 	return (pte_t *) (page);
 }

+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 					unsigned long address)
 {
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 59bf233..7d89c4b 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -240,12 +240,12 @@ unsigned long iopa(unsigned long addr)
 	return pa;
 }

-__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-		unsigned long address)
+__init_refok pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+		unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 	if (mem_init_done) {
-		pte =3D (pte_t *)__get_free_page(GFP_KERNEL |
+		pte =3D (pte_t *)__get_free_page(gfp_mask |
 					__GFP_REPEAT | __GFP_ZERO);
 	} else {
 		pte =3D (pte_t *)early_get_page();
@@ -254,3 +254,9 @@ __init_refok pte_t *pte_alloc_one_kernel(struct
mm_struct *mm,
 	}
 	return pte;
 }
+
+__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+		unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgallo=
c.h
index 881d18b..3521903 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -64,14 +64,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+	unsigned long address, gfp_t gfp_mask)
+{
+	return (pte_t *) __get_free_pages(gfp_mask|__GFP_REPEAT|__GFP_ZERO,
PTE_ORDER);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	unsigned long address)
 {
-	pte_t *pte;
-
-	pte =3D (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO,
PTE_ORDER);
-
-	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline struct page *pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/mn10300/mm/pgtable.c b/arch/mn10300/mm/pgtable.c
index 450f7ba..59fd04d 100644
--- a/arch/mn10300/mm/pgtable.c
+++ b/arch/mn10300/mm/pgtable.c
@@ -62,14 +62,20 @@ void set_pmd_pfn(unsigned long vaddr, unsigned
long pfn, pgprot_t flags)
 	local_flush_tlb_one(vaddr);
 }

-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
 {
-	pte_t *pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte =3D (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
 	return pte;
 }

+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
diff --git a/arch/parisc/include/asm/pgalloc.h
b/arch/parisc/include/asm/pgalloc.h
index fc987a1..e3fbd89 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -127,10 +127,15 @@ pte_alloc_one(struct mm_struct *mm, unsigned long add=
ress)
 }

 static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr,
gfp_t gfp_mask)
+{
+	return (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+}
+
+static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZER=
O);
-	return pte;
+	return __pte_alloc_one_kernel(mm, addr, GFP_KERNEL);
 }

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
diff --git a/arch/powerpc/include/asm/pgalloc-64.h
b/arch/powerpc/include/asm/pgalloc-64.h
index 292725c..ce2ae2f 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -100,10 +100,17 @@ static inline void pmd_free(struct mm_struct
*mm, pmd_t *pmd)
 	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
+{
+        return (pte_t *)__get_free_page(gfp_mask | __GFP_REPEAT | __GFP_ZE=
RO);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT |
__GFP_ZERO);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index 8dc41c0..8e3c0b4 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -95,14 +95,15 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 #endif
 }

-__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
+__init_refok pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
 	pte_t *pte;
 	extern int mem_init_done;
 	extern void *early_get_page(void);

 	if (mem_init_done) {
-		pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+		pte =3D (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	} else {
 		pte =3D (pte_t *)early_get_page();
 		if (pte)
@@ -111,6 +112,11 @@ __init_refok pte_t *pte_alloc_one_kernel(struct
mm_struct *mm, unsigned long add
 	return pte;
 }

+__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *ptepage;
diff --git a/arch/s390/include/asm/pgalloc.h b/arch/s390/include/asm/pgallo=
c.h
index 082eb4e..7c6fd31 100644
--- a/arch/s390/include/asm/pgalloc.h
+++ b/arch/s390/include/asm/pgalloc.h
@@ -172,7 +172,11 @@ static inline void pmd_populate(struct mm_struct *mm,
 /*
  * page table entry allocation/free routines.
  */
-#define pte_alloc_one_kernel(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
+#define __pte_alloc_one_kernel(mm, vmaddr, mask) \
+	((pte_t *) __page_table_alloc((mm), (mask)))
+#define pte_alloc_one_kernel(mm, vmaddr) \
+	((pte_t *) __pte_alloc_one_kernel((mm), (vmaddr), GFP_KERNEL)
+
 #define pte_alloc_one(mm, vmaddr) ((pte_t *) page_table_alloc(mm))

 #define pte_free_kernel(mm, pte) page_table_free(mm, (unsigned long *) pte=
)
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index e1850c2..44cf377 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -267,7 +267,7 @@ void crst_table_downgrade(struct mm_struct *mm,
unsigned long limit)
 /*
  * page table entry allocation/free routines.
  */
-unsigned long *page_table_alloc(struct mm_struct *mm)
+unsigned long *__page_table_alloc(struct mm_struct *mm, gfp_t gfp_mask)
 {
 	struct page *page;
 	unsigned long *table;
@@ -284,7 +284,7 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
 	}
 	if (!page) {
 		spin_unlock_bh(&mm->context.list_lock);
-		page =3D alloc_page(GFP_KERNEL|__GFP_REPEAT);
+		page =3D alloc_page(gfp_mask|__GFP_REPEAT);
 		if (!page)
 			return NULL;
 		pgtable_page_ctor(page);
@@ -309,6 +309,12 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
 	return table;
 }

+
+unsigned long *page_table_alloc(struct mm_struct *mm)
+{
+	return __page_table_alloc(mm, GFP_KERNEL);
+}
+
 static void __page_table_free(struct mm_struct *mm, unsigned long *table)
 {
 	struct page *page;
diff --git a/arch/score/include/asm/pgalloc.h b/arch/score/include/asm/pgal=
loc.h
index 059a61b..5c2a47b 100644
--- a/arch/score/include/asm/pgalloc.h
+++ b/arch/score/include/asm/pgalloc.h
@@ -37,15 +37,17 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }

-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
-	pte_t *pte;
-
-	pte =3D (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO,
+	return (pte_t *) __get_free_pages(gfp_mask|__GFP_REPEAT|__GFP_ZERO,
 					PTE_ORDER);
+}

-	return pte;
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+	unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline struct page *pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index 8c00785..1214abd 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -31,10 +31,16 @@ static inline void pmd_populate(struct mm_struct
*mm, pmd_t *pmd,
 /*
  * Allocate and free page tables.
  */
+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address, gfp_t gfp_mask)
+{
+	return quicklist_alloc(QUICK_PT, gfp_mask | __GFP_REPEAT, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/sparc/include/asm/pgalloc_64.h
b/arch/sparc/include/asm/pgalloc_64.h
index 5bdfa2c..a238412 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -36,10 +36,17 @@ static inline void pmd_free(struct mm_struct *mm,
pmd_t *pmd)
 	quicklist_free(0, NULL, pmd);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
+{
+	return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/tile/include/asm/pgalloc.h b/arch/tile/include/asm/pgallo=
c.h
index cf52791..a457042 100644
--- a/arch/tile/include/asm/pgalloc.h
+++ b/arch/tile/include/asm/pgalloc.h
@@ -74,9 +74,16 @@ extern void pte_free(struct mm_struct *mm, struct page *=
pte);
 #define pmd_pgtable(pmd) pmd_page(pmd)

 static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
+{
+	return pfn_to_kaddr(page_to_pfn(__pte_alloc_one(mm, address, gfp_mask)));
+}
+
+static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return pfn_to_kaddr(page_to_pfn(pte_alloc_one(mm, address)));
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 1f5430c..7875a32 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -218,9 +218,10 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)

 #define L2_USER_PGTABLE_PAGES (1 << L2_USER_PGTABLE_ORDER)

-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+struct page *
+__pte_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mas=
k)
 {
-	gfp_t flags =3D GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO|__GFP_COMP;
+	gfp_t flags =3D gfp_mask|__GFP_REPEAT|__GFP_ZERO|__GFP_COMP;
 	struct page *p;

 #ifdef CONFIG_HIGHPTE
@@ -235,6 +236,11 @@ struct page *pte_alloc_one(struct mm_struct *mm,
unsigned long address)
 	return p;
 }

+struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one(mm, address, GFP_KERNEL);
+}
+
 /*
  * Free page immediately (used in __pte_alloc if we raced with another
  * process).  We have to correct whatever pte_alloc_one() did before
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 8137ccc..d7969b3 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -284,12 +284,15 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long) pgd);
 }

-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
-	pte_t *pte;
+	return (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+}

-	pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-	return pte;
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 500242d..6b61bbd 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -15,9 +15,16 @@

 gfp_t __userpte_alloc_gfp =3D PGALLOC_GFP | PGALLOC_USER_GFP;

+pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
+{
+	return (pte_t *)__get_free_page(gfp_mask | __GFP_NOTRACK |
+				__GFP_REPEAT | __GFP_ZERO);
+}
+
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)__get_free_page(PGALLOC_GFP);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
diff --git a/arch/xtensa/include/asm/pgalloc.h
b/arch/xtensa/include/asm/pgalloc.h
index 40cf9bc..e24c720 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -42,10 +42,17 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)

 extern struct kmem_cache *pgtable_cache;

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
+{
+	return kmem_cache_alloc(pgtable_cache, gfp_mask|__GFP_REPEAT);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					 unsigned long address)
 {
-	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/xtensa/mm/pgtable.c b/arch/xtensa/mm/pgtable.c
index 6979927..1c53abc 100644
--- a/arch/xtensa/mm/pgtable.c
+++ b/arch/xtensa/mm/pgtable.c
@@ -12,13 +12,14 @@

 #if (DCACHE_SIZE > PAGE_SIZE)

-pte_t* pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t*
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
 {
 	pte_t *pte =3D NULL, *p;
 	int color =3D ADDR_COLOR(address);
 	int i;

-	p =3D (pte_t*) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, COLOR_ORDER);
+	p =3D (pte_t*) __get_free_pages(gfp_mask|__GFP_REPEAT, COLOR_ORDER);

 	if (likely(p)) {
 		split_page(virt_to_page(p), COLOR_ORDER);
@@ -35,6 +36,11 @@ pte_t* pte_alloc_one_kernel(struct mm_struct *mm,
unsigned long address)
 	return pte;
 }

+pte_t* pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+}
+
 #ifdef PROFILING

 int mask;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
