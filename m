Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F235C6B0559
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 10:45:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d5so18349489pfg.3
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 07:45:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id u59si19225044plb.848.2017.08.01.07.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 07:45:48 -0700 (PDT)
Date: Tue, 1 Aug 2017 17:44:15 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
Message-ID: <20170801144414.rd67k2g2cz46nlow@black.fi.intel.com>
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
 <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
 <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
 <39cb1e36-f94e-32ea-c94a-2daddcbf3408@suse.com>
 <20170726164335.xaajz5ltzhncju26@node.shutemov.name>
 <c450949e-bd79-c9c9-797e-be6b2c7b1e5f@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c450949e-bd79-c9c9-797e-be6b2c7b1e5f@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 01, 2017 at 09:46:56AM +0200, Juergen Gross wrote:
> On 26/07/17 18:43, Kirill A. Shutemov wrote:
> > On Wed, Jul 26, 2017 at 09:28:16AM +0200, Juergen Gross wrote:
> >> On 25/07/17 11:05, Kirill A. Shutemov wrote:
> >>> On Tue, Jul 18, 2017 at 04:24:06PM +0200, Juergen Gross wrote:
> >>>> Xen PV guests will never run with 5-level-paging enabled. So I guess you
> >>>> can drop the complete if (IS_ENABLED(CONFIG_X86_5LEVEL)) {} block.
> >>>
> >>> There is more code to drop from mmu_pv.c.
> >>>
> >>> But while there, I thought if with boot-time 5-level paging switching we
> >>> can allow kernel to compile with XEN_PV and XEN_PVH, so the kernel image
> >>> can be used in these XEN modes with 4-level paging.
> >>>
> >>> Could you check if with the patch below we can boot in XEN_PV and XEN_PVH
> >>> modes?
> >>
> >> We can't. I have used your branch:
> >>
> >> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
> >> la57/boot-switching/v2
> >>
> >> with this patch applied on top.
> >>
> >> Doesn't boot PV guest with X86_5LEVEL configured (very early crash).
> > 
> > Hm. Okay.
> > 
> > Have you tried PVH?
> > 
> >> Doesn't build with X86_5LEVEL not configured:
> >>
> >>   AS      arch/x86/kernel/head_64.o
> > 
> > I've fixed the patch and split the patch into two parts: cleanup and
> > re-enabling XEN_PV and XEN_PVH for X86_5LEVEL.
> > 
> > There's chance that I screw somthing up in clenaup part. Could you check
> > that?
> 
> Build is working with and without X86_5LEVEL configured.
> 
> PV domU boots without X86_5LEVEL configured.
> 
> PV domU crashes with X86_5LEVEL configured:
> 
> xen_start_kernel()
>   x86_64_start_reservations()
>     start_kernel()
>       setup_arch()
>         early_ioremap_init()
>           early_ioremap_pmd()
> 
> In early_ioremap_pmd() there seems to be a call to p4d_val() which is an
> uninitialized paravirt operation in the Xen pv case.

Thanks for testing.

Could you check if patch below makes a difference?

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 8febaa318aa2..37e5ccc3890f 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -604,12 +604,12 @@ static inline p4dval_t p4d_val(p4d_t p4d)
 	return PVOP_CALLEE1(p4dval_t, pv_mmu_ops.p4d_val, p4d.p4d);
 }
 
-static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
-{
-	pgdval_t val = native_pgd_val(pgd);
-
-	PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, val);
-}
+#define set_pgd(pgdp, pgdval) do {						\
+		if (p4d_folded)						\
+			set_p4d((p4d_t *)(pgdp), (p4d_t) { (pgdval).pgd }); \
+		else \
+			PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgdval)); \
+	} while (0)
 
 #define pgd_clear(pgdp) do {				\
                 if (!p4d_folded)			\
@@ -834,6 +834,7 @@ static inline notrace unsigned long arch_local_irq_save(void)
 }
 
 
+#if 0
 /* Make sure as little as possible of this mess escapes. */
 #undef PARAVIRT_CALL
 #undef __PVOP_CALL
@@ -848,6 +849,7 @@ static inline notrace unsigned long arch_local_irq_save(void)
 #undef PVOP_CALL3
 #undef PVOP_VCALL4
 #undef PVOP_CALL4
+#endif
 
 extern void default_banner(void);
 
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 3116649302f2..ab1a4f0c65c5 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -558,6 +558,22 @@ static void xen_set_p4d(p4d_t *ptr, p4d_t val)
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
 }
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+__visible p4dval_t xen_p4d_val(p4d_t p4d)
+{
+	return pte_mfn_to_pfn(p4d.p4d);
+}
+PV_CALLEE_SAVE_REGS_THUNK(xen_p4d_val);
+
+__visible p4d_t xen_make_p4d(p4dval_t p4d)
+{
+	p4d = pte_pfn_to_mfn(p4d);
+
+	return native_make_p4d(p4d);
+}
+PV_CALLEE_SAVE_REGS_THUNK(xen_make_p4d);
+#endif  /* CONFIG_PGTABLE_LEVELS >= 5 */
 #endif	/* CONFIG_X86_64 */
 
 static int xen_pmd_walk(struct mm_struct *mm, pmd_t *pmd,
@@ -2431,6 +2447,11 @@ static const struct pv_mmu_ops xen_mmu_ops __initconst = {
 
 	.alloc_pud = xen_alloc_pmd_init,
 	.release_pud = xen_release_pmd_init,
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+	.p4d_val = PV_CALLEE_SAVE(xen_p4d_val),
+	.make_p4d = PV_CALLEE_SAVE(xen_make_p4d),
+#endif
 #endif	/* CONFIG_X86_64 */
 
 	.activate_mm = xen_activate_mm,
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
