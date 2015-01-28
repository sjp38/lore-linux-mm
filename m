Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id A517C6B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 15:45:51 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so6110771wib.1
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 12:45:50 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id a20si6372818wiw.25.2015.01.28.12.45.49
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 12:45:49 -0800 (PST)
Date: Wed, 28 Jan 2015 22:45:44 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/4] Introduce <linux/mm_struct.h>
Message-ID: <20150128204544.GA15649@node.dhcp.inet.fi>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150128185052.GA6118@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128185052.GA6118@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 10:50:52AM -0800, Guenter Roeck wrote:
> On Wed, Jan 28, 2015 at 03:17:40PM +0200, Kirill A. Shutemov wrote:
> > This patchset moves definition of mm_struct into separate header file.
> > It allows to get rid of nr_pmds if PMD page table level is folded.
> > We cannot do it with current mm_types.h because we need
> > __PAGETABLE_PMD_FOLDED from <asm/pgtable.h> which creates circular
> > dependencies.
> > 
> > I've done few build tests and looks like it works, but I expect breakage
> > on some configuration. Please test.
> > 
> Doesn't look good.
> 
> Build results:
> 	total: 134 pass: 63 fail: 71
> Failed builds:
> 	arm:s3c2410_defconfig
> 	arm:omap2plus_defconfig
> 	arm:imx_v6_v7_defconfig
> 	arm:ixp4xx_defconfig
> 	arm:u8500_defconfig
> 	arm:multi_v5_defconfig
> 	arm:multi_v7_defconfig
> 	arm:omap1_defconfig
> 	arm:footbridge_defconfig
> 	arm:davinci_all_defconfig
> 	arm:mini2440_defconfig
> 	arm:rpc_defconfig
> 	arm:axm55xx_defconfig
> 	arm:mxs_defconfig
> 	arm:keystone_defconfig
> 	arm:vexpress_defconfig
> 	arm:imx_v4_v5_defconfig
> 	arm:at91_dt_defconfig
> 	arm:s3c6400_defconfig
> 	arm:lpc32xx_defconfig
> 	arm:shmobile_defconfig
> 	arm:nhk8815_defconfig
> 	arm:bcm2835_defconfig
> 	arm:sama5_defconfig
> 	arm:orion5x_defconfig
> 	arm:exynos_defconfig
> 	arm:cm_x2xx_defconfig
> 	arm:s5pv210_defconfig
> 	arm:integrator_defconfig
> 	arm:msm_defconfig
> 	arm:pxa910_defconfig
> 	arm:clps711x_defconfig

Could you try this for arm?

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index f40354198bad..bb4ae035e5e3 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -24,9 +24,6 @@
 #include <asm/memory.h>
 #include <asm/pgtable-hwdef.h>
 
-
-#include <asm/tlbflush.h>
-
 #ifdef CONFIG_ARM_LPAE
 #include <asm/pgtable-3level.h>
 #else
diff --git a/arch/arm/mm/mm.h b/arch/arm/mm/mm.h
index ce727d47275c..b5e764e0d5a8 100644
--- a/arch/arm/mm/mm.h
+++ b/arch/arm/mm/mm.h
@@ -3,6 +3,7 @@
 #include <linux/vmalloc.h>
 
 #include <asm/pgtable.h>
+#include <asm/tlbflush.h>
 
 /* the upper-most page table pointer */
 extern pmd_t *top_pmd;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
