Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 432B86B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 16:16:54 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so15421443wid.2
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 13:16:53 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id dg2si6362216wib.98.2015.01.28.13.16.52
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 13:16:52 -0800 (PST)
Date: Wed, 28 Jan 2015 23:16:47 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/4] Introduce <linux/mm_struct.h>
Message-ID: <20150128211647.GB15649@node.dhcp.inet.fi>
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
> 	avr32:defconfig
> 	avr32:merisc_defconfig
> 	avr32:atngw100mkii_evklcd101_defconfig

Fixlet for AVR32:

diff --git a/arch/avr32/include/asm/pgtable.h b/arch/avr32/include/asm/pgtable.h
index 35800664076e..3af39532b25b 100644
--- a/arch/avr32/include/asm/pgtable.h
+++ b/arch/avr32/include/asm/pgtable.h
@@ -10,11 +10,6 @@
 
 #include <asm/addrspace.h>
 
-#ifndef __ASSEMBLY__
-#include <linux/sched.h>
-
-#endif /* !__ASSEMBLY__ */
-
 /*
  * Use two-level page tables just as the i386 (without PAE)
  */
diff --git a/arch/avr32/mm/tlb.c b/arch/avr32/mm/tlb.c
index 0da23109f817..964130f8f89d 100644
--- a/arch/avr32/mm/tlb.c
+++ b/arch/avr32/mm/tlb.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 #include <linux/mm.h>
+#include <linux/sched.h>
 
 #include <asm/mmu_context.h>
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
