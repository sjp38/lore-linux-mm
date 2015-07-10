Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 25BF56B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 21:33:51 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so174627371pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 18:33:50 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id nu6si11898422pdb.97.2015.07.09.18.33.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 18:33:50 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so174627132pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 18:33:49 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v6 3/4] drivers/video/fbdev/atyfb: Replace MTRR UC hole with strong UC
Date: Thu,  9 Jul 2015 18:24:58 -0700
Message-Id: <1436491499-3289-4-git-send-email-mcgrof@do-not-panic.com>
In-Reply-To: <1436491499-3289-1-git-send-email-mcgrof@do-not-panic.com>
References: <1436491499-3289-1-git-send-email-mcgrof@do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: bp@suse.de, tomi.valkeinen@ti.com, airlied@redhat.com, arnd@arndb.de, dan.j.williams@intel.com, hch@lst.de, luto@amacapital.net, hpa@zytor.com, tglx@linutronix.de, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, benh@kernel.crashing.org, mpe@ellerman.id.au, tj@kernel.org, x86@kernel.org, mst@redhat.com, toshi.kani@hp.com, stefan.bader@canonical.com, syrjala@sci.fi, ville.syrjala@linux.intel.com, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>, Andrzej Hajda <a.hajda@samsung.com>, Antonino Daplas <adaplas@gmail.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Davidlohr Bueso <dbueso@suse.de>, Ingo Molnar <mingo@elte.hu>, Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mathias Krause <minipli@googlemail.com>, Mel Gorman <mgorman@suse.de>, Rob Clark <robdclark@gmail.com>, Suresh Siddha <sbsiddha@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Replace a WC MTRR call followed by a UC MTRR "hole" call with a single
WC MTRR call and use strong UC to protect the MMIO region and account
for the device's architecture and MTRR size requirements.

The atyfb driver relies on two overlapping MTRRs. It does this to
account for the fact that, on some devices, it has the MMIO region
bundled together with the framebuffer on the same PCI BAR and the
hardware requirement on MTRRs on both base and size to be powers
of two.

In the worst case, the PCI BAR is of 16 MiB while the MMIO region is on
the last 4 KiB of the same PCI BAR. If we use just one MTRR for WC, we
can only end up with an 8 MiB or 16 MiB framebuffer. Using a 16 MiB WC
framebuffer area is unacceptable since we need the MMIO region to not be
write-combined. An 8 MiB WC framebuffer option does not let use quite a
bit of framebuffer space, it would reduce the resolution capability of
the device considerably.

An alternative is to use many MTRRs but on some systems that could mean
not having enough MTRRs to cover the framebuffer. The current solution
is to issue a 16 MiB WC MTRR followed by a 4 KiB UC MTRR on the last 4
KiB. Its worth mentioning and documenting that the current ioremap*()
strategy as well: the first ioremap() is used only for the MMIO region,
a second ioremap() call is used for the framebuffer *and* the MMIO
region, the MMIO region then ends up mmapped twice.

Two ioremap() calls are used since in some situations the framebuffer
actually ends up on a separate auxiliary PCI BAR, but this is not always
true. In the worst case, the PCI BAR is shared for both MMIO and the
framebuffer. By allowing overlapping ioremap() calls, the driver enables
two types of devices with one simple ioremap() strategy.

See also:

  2f9e897353fc ("x86/mm/mtrr, pat: Document Write Combining MTRR type effects on PAT / non-PAT pages")

By default, Linux today defaults both pci_mmap_page_range() and
ioremap_nocache() to use _PAGE_CACHE_MODE_UC_MINUS. On x86, ioremap()
aliases ioremap_nocache(). The preferred value for Linux may soon
change, however, the goal is to use _PAGE_CACHE_MODE_UC by default in
the future.

We can use ioremap_uc() to set PCD=1, PWT=1 on non-PAT systems and use
a PAT value of UC for PAT systems. This will ensure the same settings
are in place regardless of what Linux decides to use by default later
and to not regress our MTRR strategy since the effective memory type
will differ depending on the value used. Using a WC MTRR on such an area
will be nullified. This technique can be used to protect the MMIO region
in this driver's case and address the restrictions of the device's
architecture as well as restrictions set upon us by powers of 2 when
using MTRRs.

This allows us to replace the two MTRR calls with a single 16 MiB WC
MTRR and use page-attribute settings for non-PAT and PAT entry values
for PAT systems to ensure the appropriate effective memory type won't
have a write-combining effect on the MMIO region on both non-PAT and PAT
systems. The framebuffer area will be sure to get the write-combined
effective memory type by white-listing it with ioremap_wc().

We ensure the desired effective memory types are set by:

0) Using one ioremap_uc() for the MMIO region alone.
   This will set the page attribute settings for the MMIO
   region to PCD=1, PWT=1 for non-PAT systems while using a
   strong UC value on PAT systems.

1) Fixing the framebuffer ioremapped area to exclude the
   MMIO region and using ioremap_wc() instead to whitelist
   the area we want for write-combining.

In both cases, an implementation defined (as per 2f9e897353fc) effective
memory type of WC is used for the framebuffer for non-PAT systems.

Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
Cc: airlied@redhat.com
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrzej Hajda <a.hajda@samsung.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Antonino Daplas <adaplas@gmail.com>
Cc: benh@kernel.crashing.org
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Davidlohr Bueso <dbueso@suse.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fbdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Cc: Mathias Krause <minipli@googlemail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: mst@redhat.com
Cc: Rob Clark <robdclark@gmail.com>
Cc: Suresh Siddha <sbsiddha@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Ville SyrjA?lA? <syrjala@sci.fi>
Cc: Vlastimil Babka <vbabka@suse.cz>
Link: http://lkml.kernel.org/r/1435196060-27350-3-git-send-email-mcgrof@do-not-panic.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 drivers/video/fbdev/aty/atyfb.h      |  1 -
 drivers/video/fbdev/aty/atyfb_base.c | 36 ++++++++++++++----------------------
 2 files changed, 14 insertions(+), 23 deletions(-)

diff --git a/drivers/video/fbdev/aty/atyfb.h b/drivers/video/fbdev/aty/atyfb.h
index 1f39a62f899b..89ec4398d201 100644
--- a/drivers/video/fbdev/aty/atyfb.h
+++ b/drivers/video/fbdev/aty/atyfb.h
@@ -184,7 +184,6 @@ struct atyfb_par {
 	spinlock_t int_lock;
 #ifdef CONFIG_MTRR
 	int mtrr_aper;
-	int mtrr_reg;
 #endif
 	u32 mem_cntl;
 	struct crtc saved_crtc;
diff --git a/drivers/video/fbdev/aty/atyfb_base.c b/drivers/video/fbdev/aty/atyfb_base.c
index 513e58df9d3f..ea27ba3e5e6d 100644
--- a/drivers/video/fbdev/aty/atyfb_base.c
+++ b/drivers/video/fbdev/aty/atyfb_base.c
@@ -2630,21 +2630,13 @@ static int aty_init(struct fb_info *info)
 
 #ifdef CONFIG_MTRR
 	par->mtrr_aper = -1;
-	par->mtrr_reg = -1;
 	if (!nomtrr) {
-		/* Cover the whole resource. */
+		/*
+		 * Only the ioremap_wc()'d area will get WC here
+		 * since ioremap_uc() was used on the entire PCI BAR.
+		 */
 		par->mtrr_aper = mtrr_add(par->res_start, par->res_size,
 					  MTRR_TYPE_WRCOMB, 1);
-		if (par->mtrr_aper >= 0 && !par->aux_start) {
-			/* Make a hole for mmio. */
-			par->mtrr_reg = mtrr_add(par->res_start + 0x800000 -
-						 GUI_RESERVE, GUI_RESERVE,
-						 MTRR_TYPE_UNCACHABLE, 1);
-			if (par->mtrr_reg < 0) {
-				mtrr_del(par->mtrr_aper, 0, 0);
-				par->mtrr_aper = -1;
-			}
-		}
 	}
 #endif
 
@@ -2776,10 +2768,6 @@ aty_init_exit:
 	par->pll_ops->set_pll(info, &par->saved_pll);
 
 #ifdef CONFIG_MTRR
-	if (par->mtrr_reg >= 0) {
-		mtrr_del(par->mtrr_reg, 0, 0);
-		par->mtrr_reg = -1;
-	}
 	if (par->mtrr_aper >= 0) {
 		mtrr_del(par->mtrr_aper, 0, 0);
 		par->mtrr_aper = -1;
@@ -3466,7 +3454,11 @@ static int atyfb_setup_generic(struct pci_dev *pdev, struct fb_info *info,
 	}
 
 	info->fix.mmio_start = raddr;
-	par->ati_regbase = ioremap(info->fix.mmio_start, 0x1000);
+	/*
+	 * By using strong UC we force the MTRR to never have an
+	 * effect on the MMIO region on both non-PAT and PAT systems.
+	 */
+	par->ati_regbase = ioremap_uc(info->fix.mmio_start, 0x1000);
 	if (par->ati_regbase == NULL)
 		return -ENOMEM;
 
@@ -3503,7 +3495,10 @@ static int atyfb_setup_generic(struct pci_dev *pdev, struct fb_info *info,
 	 */
 	info->fix.smem_len = 0x800000;
 
-	info->screen_base = ioremap(info->fix.smem_start, info->fix.smem_len);
+	aty_fudge_framebuffer_len(info);
+
+	info->screen_base = ioremap_wc(info->fix.smem_start,
+				       info->fix.smem_len);
 	if (info->screen_base == NULL) {
 		ret = -ENOMEM;
 		goto atyfb_setup_generic_fail;
@@ -3575,6 +3570,7 @@ static int atyfb_pci_probe(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 	par = info->par;
+	par->bus_type = PCI;
 	info->fix = atyfb_fix;
 	info->device = &pdev->dev;
 	par->pci_id = pdev->device;
@@ -3744,10 +3740,6 @@ static void atyfb_remove(struct fb_info *info)
 #endif
 
 #ifdef CONFIG_MTRR
-	if (par->mtrr_reg >= 0) {
-		mtrr_del(par->mtrr_reg, 0, 0);
-		par->mtrr_reg = -1;
-	}
 	if (par->mtrr_aper >= 0) {
 		mtrr_del(par->mtrr_aper, 0, 0);
 		par->mtrr_aper = -1;
-- 
2.3.2.209.gd67f9d5.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
