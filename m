Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5F89F6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 21:29:26 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so160817786pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 18:29:26 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ca1si11144883pbb.169.2015.07.09.18.29.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 18:29:25 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so159077966pab.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 18:29:25 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v6 1/4] drivers/video/fbdev/atyfb: Carve out framebuffer length fudging into a helper
Date: Thu,  9 Jul 2015 18:24:56 -0700
Message-Id: <1436491499-3289-2-git-send-email-mcgrof@do-not-panic.com>
In-Reply-To: <1436491499-3289-1-git-send-email-mcgrof@do-not-panic.com>
References: <1436491499-3289-1-git-send-email-mcgrof@do-not-panic.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: bp@suse.de, tomi.valkeinen@ti.com, airlied@redhat.com, arnd@arndb.de, dan.j.williams@intel.com, hch@lst.de, luto@amacapital.net, hpa@zytor.com, tglx@linutronix.de, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, benh@kernel.crashing.org, mpe@ellerman.id.au, tj@kernel.org, x86@kernel.org, mst@redhat.com, toshi.kani@hp.com, stefan.bader@canonical.com, syrjala@sci.fi, ville.syrjala@linux.intel.com, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>, Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>, Mathias Krause <minipli@googlemail.com>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

The size of the framebuffer to be used needs to be fudged to account for
the different type of devices that are out there. This captures what is
required to do well, we'll reuse this later.

This has no functional changes.

Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Cc: Mathias Krause <minipli@googlemail.com>
Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: linux-fbdev@vger.kernel.org
Link: http://lkml.kernel.org/r/1435251019-32421-1-git-send-email-mcgrof@do-not-panic.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 drivers/video/fbdev/aty/atyfb_base.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/video/fbdev/aty/atyfb_base.c b/drivers/video/fbdev/aty/atyfb_base.c
index 8789e487b96e..16936bb1f865 100644
--- a/drivers/video/fbdev/aty/atyfb_base.c
+++ b/drivers/video/fbdev/aty/atyfb_base.c
@@ -427,6 +427,20 @@ static struct {
 #endif /* CONFIG_FB_ATY_CT */
 };
 
+/*
+ * Last page of 8 MB (4 MB on ISA) aperture is MMIO,
+ * unless the auxiliary register aperture is used.
+ */
+static void aty_fudge_framebuffer_len(struct fb_info *info)
+{
+	struct atyfb_par *par = (struct atyfb_par *) info->par;
+
+	if (!par->aux_start &&
+	    (info->fix.smem_len == 0x800000 ||
+	     (par->bus_type == ISA && info->fix.smem_len == 0x400000)))
+		info->fix.smem_len -= GUI_RESERVE;
+}
+
 static int correct_chipset(struct atyfb_par *par)
 {
 	u8 rev;
@@ -2603,14 +2617,7 @@ static int aty_init(struct fb_info *info)
 	if (par->pll_ops->resume_pll)
 		par->pll_ops->resume_pll(info, &par->pll);
 
-	/*
-	 * Last page of 8 MB (4 MB on ISA) aperture is MMIO,
-	 * unless the auxiliary register aperture is used.
-	 */
-	if (!par->aux_start &&
-	    (info->fix.smem_len == 0x800000 ||
-	     (par->bus_type == ISA && info->fix.smem_len == 0x400000)))
-		info->fix.smem_len -= GUI_RESERVE;
+	aty_fudge_framebuffer_len(info);
 
 	/*
 	 * Disable register access through the linear aperture
-- 
2.3.2.209.gd67f9d5.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
