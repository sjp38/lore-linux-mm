Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 48C726B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 00:52:33 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id g201so877379oib.4
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 21:52:33 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id cn3si1829885oeb.91.2015.01.23.21.52.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 21:52:32 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YEte3-003zSd-2L
	for linux-mm@kvack.org; Sat, 24 Jan 2015 05:52:31 +0000
Date: Fri, 23 Jan 2015 21:52:07 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2015-01-22-15-04: qemu failures due to 'mm: account pmd
 page tables to the process'
Message-ID: <20150124055207.GA8926@roeck-us.net>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050445.GA22751@roeck-us.net>
 <20150123111304.GA5975@node.dhcp.inet.fi>
 <54C263CC.1060904@roeck-us.net>
 <20150123135519.9f1061caf875f41f89298d59@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150123135519.9f1061caf875f41f89298d59@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Jan 23, 2015 at 01:55:19PM -0800, Andrew Morton wrote:
> On Fri, 23 Jan 2015 07:07:56 -0800 Guenter Roeck <linux@roeck-us.net> wrote:
> 
> > >>
> > >> qemu:microblaze generates warnings to the console.
> > >>
> > >> WARNING: CPU: 0 PID: 32 at mm/mmap.c:2858 exit_mmap+0x184/0x1a4()
> > >>
> > >> with various call stacks. See
> > >> http://server.roeck-us.net:8010/builders/qemu-microblaze-mmotm/builds/15/steps/qemubuildcommand/logs/stdio
> > >> for details.
> > >
> > > Could you try patch below? Completely untested.
> > >
> > >>From b584bb8d493794f67484c0b57c161d61c02599bc Mon Sep 17 00:00:00 2001
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Date: Fri, 23 Jan 2015 13:08:26 +0200
> > > Subject: [PATCH] microblaze: define __PAGETABLE_PMD_FOLDED
> > >
> > > Microblaze uses custom implementation of PMD folding, but doesn't define
> > > __PAGETABLE_PMD_FOLDED, which generic code expects to see. Let's fix it.
> > >
> > > Defining __PAGETABLE_PMD_FOLDED will drop out unused __pmd_alloc().
> > > It also fixes problems with recently-introduced pmd accounting.
> > >
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Reported-by: Guenter Roeck <linux@roeck-us.net>
> > 
> > Tested working.
> > 
> > Tested-by: Guenter Roeck <linux@roeck-us.net>
> > 
> > Any idea how to fix the sh problem ?
> 
> Can you tell us more about it?  All I'm seeing is "qemu:sh fails to
> shut down", which isn't very clear.

Turns out that the include file defining __PAGETABLE_PMD_FOLDED
was not always included where used, resulting in a messed up mm_struct.

The patch below fixes the problem for the sh architecture.
No idea if the patch is correct/acceptable for other architectures.

Guenter

---
>From 2a11491a5d0642c924db1d78f2b8f21985459062 Mon Sep 17 00:00:00 2001
From: Guenter Roeck <linux@roeck-us.net>
Date: Fri, 23 Jan 2015 21:44:06 -0800
Subject: [PATCH] mm_types: include asm/pgtable.h

Commit 22310c209483 ("mm: account pmd page tables to the process") starts using
__PAGETABLE_PMD_FOLDED in mm_types.h. This define is usually declared in
pgtable.h, so pgtable.h neeeds to be included.

Fixes runtime error with sh targets.

Fixes: 22310c209483 ("mm: account pmd page tables to the process")
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 include/linux/mm_types.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 79cdf6f..65db573 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <asm/page.h>
+#include <asm/pgtable.h>
 #include <asm/mmu.h>
 
 #ifndef AT_VECTOR_SIZE_ARCH
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
