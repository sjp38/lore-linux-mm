Subject: Re: 2.5.74-mm2 + nvidia (and others)
From: Martin Schlemmer <azarah@gentoo.org>
In-Reply-To: <20030712012130.GB15452@holomorphy.com>
References: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu>
	 <200307071734.01575.schlicht@uni-mannheim.de>
	 <20030707123012.47238055.akpm@osdl.org>
	 <1057647818.5489.385.camel@workshop.saharacpt.lan>
	 <20030712012130.GB15452@holomorphy.com>
Content-Type: text/plain
Message-Id: <1058184576.799.341.camel@workshop.saharacpt.lan>
Mime-Version: 1.0
Date: 14 Jul 2003 14:09:37 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, Thomas Schlichter <schlicht@uni-mannheim.de>, smiler@lanil.mine.nu, KML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2003-07-12 at 03:21, William Lee Irwin III wrote:
> On Tue, Jul 08, 2003 at 09:03:39AM +0200, Martin Schlemmer wrote:
> > +#if defined(NV_PMD_OFFSET_UNMAP)
> > +    pmd_unmap(pg_mid_dir);
> > +#endif
> 
> You could try defining an NV_PMD_OFFSET_UNMAP() which is a nop for
> mainline and DTRT for -mm.
> 

Ok, I basically got the latest minion.de (2003/07/13) to look as
follow:

----------------------------------
diff -urpN NVIDIA_kernel-1.0-4363/nv-linux.h
NVIDIA_kernel-1.0-4363.highpmd-fixup/nv-linux.h
--- NVIDIA_kernel-1.0-4363/nv-linux.h   2003-07-14 12:42:00.000000000
+0200
+++ NVIDIA_kernel-1.0-4363.highpmd-fixup/nv-linux.h     2003-07-14
13:38:02.000000000 +0200
@@ -228,14 +228,14 @@

 #if defined(pmd_offset_map)
 #define NV_PMD_OFFSET(address, pgd, pmd) \
-    { \
-        pmd_t *pmd__ = pmd_offset_map(pgd, address); \
-        pmd = *pmd__; \
-        pmd_unmap(pgd__); \
-    }
+    pmd = pmd_offset_map(pgd, address)
+#define NV_PMD_UNMAP(pmd) \
+    pmd_unmap(pmd)
 #else
 #define NV_PMD_OFFSET(address, pgd, pmd) \
-    pmd = *pmd_offset(pgd, address)
+    pmd = pmd_offset(pgd, address)
+#define NV_PMD_UNMAP(pmd) \
+    nop()
 #endif 

 #define NV_PAGE_ALIGN(addr)             ( ((addr) + PAGE_SIZE - 1) /
PAGE_SIZE)
diff -urpN NVIDIA_kernel-1.0-4363/nv.c
NVIDIA_kernel-1.0-4363.highpmd-fixup/nv.c
--- NVIDIA_kernel-1.0-4363/nv.c 2003-07-14 12:42:00.000000000 +0200
+++ NVIDIA_kernel-1.0-4363.highpmd-fixup/nv.c   2003-07-14
13:38:43.000000000 +0200
@@ -2087,7 +2087,7 @@ unsigned long
 nv_get_phys_address(unsigned long address)
 {
     pgd_t *pgd;
-    pmd_t pmd;
+    pmd_t *pmd;
     pte_t pte;
 
 #if defined(NVCPU_IA64)
@@ -2110,10 +2110,14 @@ nv_get_phys_address(unsigned long addres

     NV_PMD_OFFSET(address, pgd, pmd);
 
-    if (pmd_none(pmd))
+    if (pmd_none(*pmd)) {
+        NV_PMD_UNMAP(pmd);
         goto failed;
+    }
+
+    NV_PTE_OFFSET(address, pmd, pte);
 
-    NV_PTE_OFFSET(address, &pmd, pte);
+    NV_PMD_UNMAP(pmd);

     if (!pte_present(pte))
         goto failed;
----------------------------------

so that it will not use a copy of 'pmd' that was already
unmapped.

Question now - what about:

--------------------- nv-linux.h ----------------------
#if defined(pte_offset_atomic)
#define NV_PTE_OFFSET(addres, pmd, pte) \
    { \
        pte_t *pte__ = pte_offset_atomic(pmd, address); \
        pte = *pte__; \
        pte_kunmap(pte__); \
    } 
#elif defined(pte_offset)
#define NV_PTE_OFFSET(addres, pmd, pte) \
    pte = *pte_offset(pmd, address)
#else
#define NV_PTE_OFFSET(addres, pmd, pte) \
    { \
        pte_t *pte__ = pte_offset_map(pmd, address); \
        pte = *pte__; \
        pte_unmap(pte__); \
    }
#endif
-------------------------------------------------------

I cannot think that it is safe as well to use an copy
of an unmapped pte ??  Should this be fixed as well ?


Thanks,

-- 
Martin Schlemmer


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
