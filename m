Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 885B96B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 01:34:35 -0500 (EST)
Date: Mon, 24 Jan 2011 22:33:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix build error when CONFIG_SWAP is not set
Message-Id: <20110124223347.ad6072f1.akpm@linux-foundation.org>
In-Reply-To: <AANLkTimdgYVpwbCAL96=1F+EtXyNxz5Swv32GN616mqP@mail.gmail.com>
References: <20110124210813.ba743fc5.yuasa@linux-mips.org>
	<4D3DD366.8000704@mvista.com>
	<20110124124412.69a7c814.akpm@linux-foundation.org>
	<20110124210752.GA10819@merkur.ravnborg.org>
	<AANLkTimdgYVpwbCAL96=1F+EtXyNxz5Swv32GN616mqP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Sergei Shtylyov <sshtylyov@mvista.com>, Yoichi Yuasa <yuasa@linux-mips.org>, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Jan 2011 07:24:09 +0100 Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> > I just checked.
> > sparc32 with a defconfig barfed out like this:
> > __CC __ __ __arch/sparc/kernel/traps_32.o
> > In file included from /home/sam/kernel/linux-2.6.git/include/linux/pagemap.h:7:0,
> > __ __ __ __ __ __ __ __ from /home/sam/kernel/linux-2.6.git/include/linux/swap.h:11,
> > __ __ __ __ __ __ __ __ from /home/sam/kernel/linux-2.6.git/arch/sparc/include/asm/pgtable_32.h:15,
> > __ __ __ __ __ __ __ __ from /home/sam/kernel/linux-2.6.git/arch/sparc/include/asm/pgtable.h:6,
> > __ __ __ __ __ __ __ __ from /home/sam/kernel/linux-2.6.git/arch/sparc/kernel/traps_32.c:23:
> > /home/sam/kernel/linux-2.6.git/include/linux/mm.h: In function 'is_vmalloc_addr':
> > /home/sam/kernel/linux-2.6.git/include/linux/mm.h:301:17: error: 'VMALLOC_START' undeclared (first use in this function)
> > /home/sam/kernel/linux-2.6.git/include/linux/mm.h:301:17: note: each undeclared identifier is reported only once for each function it appears in
> > /home/sam/kernel/linux-2.6.git/include/linux/mm.h:301:41: error: 'VMALLOC_END' undeclared (first use in this function)
> > /home/sam/kernel/linux-2.6.git/include/linux/mm.h: In function 'maybe_mkwrite':
> > /home/sam/kernel/linux-2.6.git/include/linux/mm.h:483:3: error: implicit declaration of function 'pte_mkwrite'
> >
> > When I removed the include it could build again.
> 
> ... and so it is. Good to know, thanks for checking!

meanwhile I suppose someone should fix the error ;)


From: Andrew Morton <akpm@linux-foundation.org>

mips:

In file included from arch/mips/include/asm/tlb.h:21,
                 from mm/pgtable-generic.c:9:
include/asm-generic/tlb.h: In function `tlb_flush_mmu':
include/asm-generic/tlb.h:76: error: implicit declaration of function `release_pages'
include/asm-generic/tlb.h: In function `tlb_remove_page':
include/asm-generic/tlb.h:105: error: implicit declaration of function `page_cache_release'

free_pages_and_swap_cache() and free_page_and_swap_cache() are macros
which call release_pages() and page_cache_release().  The obvious fix is
to include pagemap.h in swap.h, where those macros are defined.  But that
breaks sparc for weird reasons.

So fix it within mm/pgtable-generic.c instead.

Reported-by: Yoichi Yuasa <yuasa@linux-mips.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Sergei Shtylyov <sshtylyov@mvista.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/pgtable-generic.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN mm/pgtable-generic.c~mm-pgtable-genericc-fix-config_swap=n-build mm/pgtable-generic.c
--- a/mm/pgtable-generic.c~mm-pgtable-genericc-fix-config_swap=n-build
+++ a/mm/pgtable-generic.c
@@ -6,6 +6,7 @@
  *  Copyright (C) 2010  Linus Torvalds
  */
 
+#include <linux/pagemap.h>
 #include <asm/tlb.h>
 #include <asm-generic/pgtable.h>
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
