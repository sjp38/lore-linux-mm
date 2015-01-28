Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE916B006C
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 21:57:34 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so22505247pad.8
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 18:57:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y3si3969925pdi.101.2015.01.27.18.57.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 18:57:33 -0800 (PST)
Date: Tue, 27 Jan 2015 18:57:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] powerpc/mm: fix undefined reference to
 `.__kernel_map_pages' on FSL PPC64
Message-Id: <20150127185711.ee819e4b.akpm@linux-foundation.org>
In-Reply-To: <CAAmzW4M3O81wBFeZ+JEVZnjRwMNwXnPKeL62Zz96xe_6a7WZpg@mail.gmail.com>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
	<20150120230150.GA14475@cloud>
	<20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
	<CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
	<20150122014550.GA21444@js1304-P5Q-DELUXE>
	<20150122144147.019eedc41f189eac44c3c4cd@freescale.com>
	<CAC5umyiF52cykH2_5TD0yzXb+842gywpe-+XZHEwmrDe0nYCPw@mail.gmail.com>
	<20150122212017.4b7032d52a6c75c06d5b4728@freescale.com>
	<1421987091.24984.13.camel@ellerman.id.au>
	<20150126132222.6477257be204a3332601ef11@freescale.com>
	<1422406862.32234.1.camel@ellerman.id.au>
	<CAAmzW4M3O81wBFeZ+JEVZnjRwMNwXnPKeL62Zz96xe_6a7WZpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Kim Phillips <kim.phillips@freescale.com>, Akinobu Mita <akinobu.mita@gmail.com>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, josh@joshtriplett.org, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Minchan Kim <minchan@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Scott Wood <scottwood@freescale.com>

On Wed, 28 Jan 2015 10:33:59 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> 2015-01-28 10:01 GMT+09:00 Michael Ellerman <mpe@ellerman.id.au>:
> > On Mon, 2015-01-26 at 13:22 -0600, Kim Phillips wrote:
> >> arch/powerpc has __kernel_map_pages implementations in mm/pgtable_32.c, and
> >> mm/hash_utils_64.c, of which the former is built for PPC32, and the latter
> >> for PPC64 machines with PPC_STD_MMU.  Fix arch/powerpc/Kconfig to not select
> >> ARCH_SUPPORTS_DEBUG_PAGEALLOC when CONFIG_PPC_STD_MMU_64 isn't defined,
> >> i.e., for 64-bit book3e builds to use the generic __kernel_map_pages()
> >> in mm/debug-pagealloc.c.
> >>
> >>   LD      init/built-in.o
> >> mm/built-in.o: In function `kernel_map_pages':
> >> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> >> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> >> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> >> Makefile:925: recipe for target 'vmlinux' failed
> >> make: *** [vmlinux] Error 1
> >>
> >> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> >> ---
> >> v3:
> >> - fix wording for hash_utils_64.c implementation pointed out by
> >> Michael Ellerman
> >> - changed designation from 'mm:' to 'powerpc/mm:', as I think this
> >> now belongs in ppc-land
> >>
> >> v2:
> >> - corrected SUPPORTS_DEBUG_PAGEALLOC selection to enable
> >> non-STD_MMU_64 builds to use the generic __kernel_map_pages().
> >
> > I'd be happy to take this through the powerpc tree for 3.20, but for this:
> >
> >> depends on:
> >> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> Date: Thu, 22 Jan 2015 10:28:58 +0900
> >> Subject: [PATCH] mm/debug_pagealloc: fix build failure on ppc and some other archs
> >
> > I don't have that patch in my tree.
> >
> > But in what way does this patch depend on that one?
> >
> > It looks to me like it'd be safe to take this on its own, or am I wrong?
> >
> 
> Hello,
> 
> These two patches are merged to Andrew's tree now.

That didn't answer either of Michael's questions ;)

Yes, I think they're independent.  I was holding off on the powerpc
one, waiting to see if it popped up in linux-next via your tree.  I can
merge both if you like?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
