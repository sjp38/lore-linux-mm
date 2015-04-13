Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4FC6B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 16:59:54 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so114100195pab.3
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 13:59:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cb9si17451441pdb.197.2015.04.13.13.59.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Apr 2015 13:59:53 -0700 (PDT)
Date: Mon, 13 Apr 2015 13:59:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
Message-Id: <20150413135951.b3d9f431892dbfa7156cc1b0@linux-foundation.org>
In-Reply-To: <20150413140219.GA14480@node.dhcp.inet.fi>
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com>
	<9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com>
	<20150413115811.GA12354@node.dhcp.inet.fi>
	<552BB972.3010704@linux.vnet.ibm.com>
	<20150413131357.GC12354@node.dhcp.inet.fi>
	<552BC2CA.80309@linux.vnet.ibm.com>
	<552BC619.9080603@parallels.com>
	<20150413140219.GA14480@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Pavel Emelyanov <xemul@parallels.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

On Mon, 13 Apr 2015 17:02:19 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > Kirill, if I'm right with it, can you suggest the header where to put
> > the "generic" mremap hook's (empty) body?
> 
> I initially thought it would be enough to put it into
> <asm-generic/mmu_context.h>, expecting it works as
> <asm-generic/pgtable.h>. But that's not the case.
> 
> It probably worth at some point rework all <asm/mmu_context.h> to include
> <asm-generic/mmu_context.h> at the end as we do for <asm/pgtable.h>.
> But that's outside the scope of the patchset, I guess.
> 
> I don't see any better candidate for such dummy header. :-/

Do away with __HAVE_ARCH_REMAP and do it like this:

arch/x/include/asm/y.h:

	extern void arch_remap(...);
	#define arch_remap arch_remap

include/linux/z.h:

	#include <asm/y.h>

	#ifndef arch_remap
	static inline void arch_remap(...) { }
	#define arch_remap arch_remap
	#endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
