Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCB76B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 19:11:47 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id bs8so6457638wib.3
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 16:11:47 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id hj2si23717431wjb.93.2015.01.30.16.11.45
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 16:11:45 -0800 (PST)
Date: Sat, 31 Jan 2015 02:11:41 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/19] expose page table levels on Kconfig leve
Message-ID: <20150131001141.GA31680@node.dhcp.inet.fi>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150130172613.GA12367@roeck-us.net>
 <20150130185052.GA30401@node.dhcp.inet.fi>
 <20150130191435.GA16823@roeck-us.net>
 <20150130200956.GB30401@node.dhcp.inet.fi>
 <20150130205958.GA1124@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130205958.GA1124@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 12:59:58PM -0800, Guenter Roeck wrote:
> On Fri, Jan 30, 2015 at 10:09:56PM +0200, Kirill A. Shutemov wrote:
> > On Fri, Jan 30, 2015 at 11:14:35AM -0800, Guenter Roeck wrote:
> > > On Fri, Jan 30, 2015 at 08:50:52PM +0200, Kirill A. Shutemov wrote:
> > > > On Fri, Jan 30, 2015 at 09:26:13AM -0800, Guenter Roeck wrote:
> > > > > On Fri, Jan 30, 2015 at 04:43:09PM +0200, Kirill A. Shutemov wrote:
> > > > > > I've failed my attempt on split up mm_struct into separate header file to
> > > > > > be able to use defines from <asm/pgtable.h> to define mm_struct: it causes
> > > > > > too much breakage and requires massive de-inlining of some architectures
> > > > > > (notably ARM and S390 with PGSTE).
> > > > > > 
> > > > > > This is other approach: expose number of page table levels on Kconfig
> > > > > > level and use it to get rid of nr_pmds in mm_struct.
> > > > > > 
> > > > > Hi Kirill,
> > > > > 
> > > > > Can I pull this series from somewhere ?
> > > > 
> > > > Just pushed:
> > > > 
> > > > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git config_pgtable_levels
> > > > 
> > > 
> > > Great. Pushed into my 'testing' branch. I'll let you know how it goes.
> > 
> > 0-DAY kernel testing has already reported few issues on blackfin, ia64 and
> > x86 with xen.
> > 
> Here is the final verdict:
> 	total: 134 pass: 114 fail: 20
> Failed builds:
> 	arc:defconfig (inherited from mainline)
> 	arc:tb10x_defconfig (inherited from mainline)
> 	arm:efm32_defconfig
> 	blackfin:defconfig
> 	c6x:dsk6455_defconfig
> 	c6x:evmc6457_defconfig
> 	c6x:evmc6678_defconfig
> 	ia64:defconfig
> 	m68k:m5272c3_defconfig
> 	m68k:m5307c3_defconfig
> 	m68k:m5249evb_defconfig
> 	m68k:m5407c3_defconfig
> 	microblaze:nommu_defconfig
> 	mips:allmodconfig (inherited from -next)
> 	powerpc:cell_defconfig (binutils 2.23)
> 	powerpc:cell_defconfig (binutils 2.24)
> 	sparc64:allmodconfig (inherited from -next)
> 	x86_64:allyesconfig
> 	x86_64:allmodconfig
> 	xtensa:allmodconfig (inherited from -next)

The patch below should fix all regressions from -next.
Please test.

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 56313dfd9685..4f9a6661491b 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -1,7 +1,7 @@
 config PGTABLE_LEVELS
 	int "Page Table Levels" if !IA64_PAGE_SIZE_64KB
 	range 3 4 if !IA64_PAGE_SIZE_64KB
-	default 4
+	default 3
 
 source "init/Kconfig"
 
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 4c0c744fa297..91ad76f30d18 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -300,7 +300,7 @@ config ZONE_DMA32
 config PGTABLE_LEVELS
 	int
 	default 2 if !PPC64
-	default 3 if 64K_PAGES
+	default 3 if PPC_64K_PAGES
 	default 4
 
 source "init/Kconfig"
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d782617c11de..a09837f3f4b7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1454,13 +1454,15 @@ static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
 int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
 #endif
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if defined(__PAGETABLE_PMD_FOLDED) || !defined(CONFIG_MMU)
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
 						unsigned long address)
 {
 	return 0;
 }
 
+static inline void mm_nr_pmds_init(struct mm_struct *mm) {}
+
 static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
 {
 	return 0;
@@ -1472,6 +1474,11 @@ static inline void mm_dec_nr_pmds(struct mm_struct *mm) {}
 #else
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
 
+static inline void mm_nr_pmds_init(struct mm_struct *mm)
+{
+	atomic_long_set(&mm->nr_pmds, 0);
+}
+
 static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
 {
 	return atomic_long_read(&mm->nr_pmds);
diff --git a/include/trace/events/xen.h b/include/trace/events/xen.h
index d06b6da5c1e3..bce990f5a35d 100644
--- a/include/trace/events/xen.h
+++ b/include/trace/events/xen.h
@@ -224,7 +224,7 @@ TRACE_EVENT(xen_mmu_pmd_clear,
 	    TP_printk("pmdp %p", __entry->pmdp)
 	);
 
-#if PAGETABLE_LEVELS >= 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 
 TRACE_EVENT(xen_mmu_set_pud,
 	    TP_PROTO(pud_t *pudp, pud_t pudval),
diff --git a/kernel/fork.c b/kernel/fork.c
index 76d6f292274c..56b82deb6457 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -555,9 +555,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
 	atomic_long_set(&mm->nr_ptes, 0);
-#ifndef __PAGETABLE_PMD_FOLDED
-	atomic_long_set(&mm->nr_pmds, 0);
-#endif
+	mm_nr_pmds_init(mm);
 	mm->map_count = 0;
 	mm->locked_vm = 0;
 	mm->pinned_vm = 0;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
