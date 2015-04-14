Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D4E176B0038
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 15:38:56 -0400 (EDT)
Received: by pdea3 with SMTP id a3so23194923pde.3
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 12:38:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gq8si3194393pbc.83.2015.04.14.12.38.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 12:38:55 -0700 (PDT)
Date: Tue, 14 Apr 2015 12:38:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
Message-Id: <20150414123853.a3e61b7fa95b6c634e0fcce0@linux-foundation.org>
In-Reply-To: <552CDD35.2030901@linux.vnet.ibm.com>
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com>
	<9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com>
	<20150413115811.GA12354@node.dhcp.inet.fi>
	<552BB972.3010704@linux.vnet.ibm.com>
	<20150413131357.GC12354@node.dhcp.inet.fi>
	<552BC2CA.80309@linux.vnet.ibm.com>
	<552BC619.9080603@parallels.com>
	<20150413140219.GA14480@node.dhcp.inet.fi>
	<20150413135951.b3d9f431892dbfa7156cc1b0@linux-foundation.org>
	<552CDD35.2030901@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

On Tue, 14 Apr 2015 11:26:13 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> > Do away with __HAVE_ARCH_REMAP and do it like this:
> > 
> > arch/x/include/asm/y.h:
> > 
> > 	extern void arch_remap(...);
> > 	#define arch_remap arch_remap
> > 
> > include/linux/z.h:
> > 
> > 	#include <asm/y.h>
> > 
> > 	#ifndef arch_remap
> > 	static inline void arch_remap(...) { }
> > 	#define arch_remap arch_remap
> > 	#endif
> 
> Hi Andrew,
> 
> I like your idea, but I can't find any good candidate for <asm/y.h> and
> <linux/z.h>.
> 
> I tried with <linux/mm.h> and <asm/mmu_context.h> but
> <asm/mmu_context.h> is already including <linux/mm.h>.
> 
> Do you have any suggestion ?
> 
> Another option could be to do it like the actual arch_unmap() in
> <asm-generic/mm_hooks.h> but this is the opposite of your idea, and Ingo
> was not comfortable with this idea due to the impact of the other
> architectures.

I don't see any appropriate header files for this.  mman.h is kinda
close.

So we create new header files, that's not a problem.  I'm torn between

a) include/linux/mm-arch-hooks.h (and 31
   arch/X/include/asm/mm-arch-hooks.h).  Mandate: mm stuff which can be
   overridded by arch

versus

b) include/linux/mremap.h (+31), with a narrower mandate.


This comes up fairly regularly so I suspect a) is better.  We'll add
things to it over time, and various bits of existing ad-hackery can be
moved over as cleanups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
