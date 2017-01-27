Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7449E6B0033
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 06:30:18 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so46136480wjb.7
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 03:30:18 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id j59si5588545wrj.283.2017.01.27.03.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 03:30:17 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id d140so57819676wmd.2
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 03:30:16 -0800 (PST)
Date: Fri, 27 Jan 2017 14:30:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 02/29] asm-generic: introduce 5level-fixup.h
Message-ID: <20170127113014.GA7662@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-3-kirill.shutemov@linux.intel.com>
 <0183120a-5e8b-5da9-0bad-cc0295bb8337@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0183120a-5e8b-5da9-0bad-cc0295bb8337@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 27, 2017 at 12:06:02PM +0100, Vlastimil Babka wrote:
> On 12/27/2016 02:53 AM, Kirill A. Shutemov wrote:
> >We are going to switch core MM to 5-level paging abstraction.
> >
> >This is preparation step which adds <asm-generic/5level-fixup.h>
> >As with 4level-fixup.h, the new header allows quickly make all
> >architectures compatible with 5-level paging in core MM.
> >
> >In long run we would like to switch architectures to properly folded p4d
> >level by using <asm-generic/pgtable-nop4d.h>, but it requires more
> >changes to arch-specific code.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >---
> > include/asm-generic/4level-fixup.h |  3 ++-
> > include/asm-generic/5level-fixup.h | 41 ++++++++++++++++++++++++++++++++++++++
> > include/linux/mm.h                 |  3 +++
> > 3 files changed, 46 insertions(+), 1 deletion(-)
> > create mode 100644 include/asm-generic/5level-fixup.h
> >
> >diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
> >index 5bdab6bffd23..928fd66b1271 100644
> >--- a/include/asm-generic/4level-fixup.h
> >+++ b/include/asm-generic/4level-fixup.h
> >@@ -15,7 +15,6 @@
> > 	((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address))? \
> >  		NULL: pmd_offset(pud, address))
> >
> >-#define pud_alloc(mm, pgd, address)	(pgd)
> 
> This...
> 
> > #define pud_offset(pgd, start)		(pgd)
> > #define pud_none(pud)			0
> > #define pud_bad(pud)			0
> >@@ -35,4 +34,6 @@
> > #undef  pud_addr_end
> > #define pud_addr_end(addr, end)		(end)
> >
> >+#include <asm-generic/5level-fixup.h>
> 
> ... plus this...
> 
> >+
> > #endif
> >diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
> >new file mode 100644
> >index 000000000000..b5ca82dc4175
> >--- /dev/null
> >+++ b/include/asm-generic/5level-fixup.h
> >@@ -0,0 +1,41 @@
> >+#ifndef _5LEVEL_FIXUP_H
> >+#define _5LEVEL_FIXUP_H
> >+
> >+#define __ARCH_HAS_5LEVEL_HACK
> >+#define __PAGETABLE_P4D_FOLDED
> >+
> >+#define P4D_SHIFT			PGDIR_SHIFT
> >+#define P4D_SIZE			PGDIR_SIZE
> >+#define P4D_MASK			PGDIR_MASK
> >+#define PTRS_PER_P4D			1
> >+
> >+#define p4d_t				pgd_t
> >+
> >+#define pud_alloc(mm, p4d, address) \
> >+	((unlikely(pgd_none(*(p4d))) && __pud_alloc(mm, p4d, address)) ? \
> >+		NULL : pud_offset(p4d, address))
> 
> ... and this, makes me wonder if that broke pud_alloc() for architectures
> that use the 4level-fixup.h. Don't those need to continue having pud_alloc()
> as (pgd)?

Okay, that's very hacky, but works:

For 4level-fixup.h case we have __PAGETABLE_PUD_FOLDED set, so
__pud_alloc() will always succeed (see <linux/mm.h>). And pud_offset()
from 4level-fixup.h always returns pgd.

I've tested this on alpha with qemu.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
