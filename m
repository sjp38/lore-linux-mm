Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E177A440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 10:15:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g46so9177348wrd.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:15:31 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id y21si5466750wmh.132.2017.07.13.07.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 07:15:30 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id p204so5397166wmg.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:15:30 -0700 (PDT)
Date: Thu, 13 Jul 2017 17:15:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
Message-ID: <20170713141528.rwuz5n2p57omq6wi@node.shutemov.name>
References: <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
 <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
 <CALCETrVpNUq3-zEu1Q1O77N8r4kv4kFdefXp7XEs3Hpf-JPAjg@mail.gmail.com>
 <d3caf8c4-4575-c1b5-6b0f-95527efaf2f9@virtuozzo.com>
 <f11d9e07-6b31-1add-7677-6a29d15ab608@virtuozzo.com>
 <20170711170332.wlaudicepkg35dmm@node.shutemov.name>
 <e9a395f4-018e-4c8c-2098-170172e438f3@virtuozzo.com>
 <20170711190554.zxkpjeg2bt65wtir@black.fi.intel.com>
 <20939b37-efd8-2d32-0040-3682fff927c2@virtuozzo.com>
 <20170713135228.vhvpe7mqdcqzpslw@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713135228.vhvpe7mqdcqzpslw@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Thu, Jul 13, 2017 at 04:52:28PM +0300, Kirill A. Shutemov wrote:
> On Thu, Jul 13, 2017 at 03:58:29PM +0300, Andrey Ryabinin wrote:
> > On 07/11/2017 10:05 PM, Kirill A. Shutemov wrote:
> > >>> Can use your Signed-off-by for a [cleaned up version of your] patch?
> > >>
> > >> Sure.
> > > 
> > > Another KASAN-releated issue: dumping page tables for KASAN shadow memory
> > > region takes unreasonable time due to kasan_zero_p?? mapped there.
> > > 
> > > The patch below helps. Any objections?
> > > 
> > 
> > Well, page tables dump doesn't work at all on 5-level paging.
> > E.g. I've got this nonsense: 
> > 
> > ....
> > ---[ Kernel Space ]---
> > 0xffff800000000000-0xffff808000000000         512G                               pud
> > ---[ Low Kernel Mapping ]---
> > 0xffff808000000000-0xffff810000000000         512G                               pud
> > ---[ vmalloc() Area ]---
> > 0xffff810000000000-0xffff818000000000         512G                               pud
> > ---[ Vmemmap ]---
> > 0xffff818000000000-0xffffff0000000000      128512G                               pud
> > ---[ ESPfix Area ]---
> > 0xffffff0000000000-0x0000000000000000           1T                               pud
> > 0x0000000000000000-0x0000000000000000           0E                               pgd
> > 0x0000000000000000-0x0000000000001000           4K     RW     PCD         GLB NX pte
> > 0x0000000000001000-0x0000000000002000           4K                               pte
> > 0x0000000000002000-0x0000000000003000           4K     ro                 GLB NX pte
> > 0x0000000000003000-0x0000000000004000           4K                               pte
> > 0x0000000000004000-0x0000000000007000          12K     RW                 GLB NX pte
> > 0x0000000000007000-0x0000000000008000           4K                               pte
> > 0x0000000000008000-0x0000000000108000           1M     RW                 GLB NX pte
> > 0x0000000000108000-0x0000000000109000           4K                               pte
> > 0x0000000000109000-0x0000000000189000         512K     RW                 GLB NX pte
> > 0x0000000000189000-0x000000000018a000           4K                               pte
> > 0x000000000018a000-0x000000000018e000          16K     RW                 GLB NX pte
> > 0x000000000018e000-0x000000000018f000           4K                               pte
> > 0x000000000018f000-0x0000000000193000          16K     RW                 GLB NX pte
> > 0x0000000000193000-0x0000000000194000           4K                               pte
> > ... 304 entries skipped ... 
> > ---[ EFI Runtime Services ]---
> > 0xffffffef00000000-0xffffffff80000000          66G                               pud
> > ---[ High Kernel Mapping ]---
> > 0xffffffff80000000-0xffffffffc0000000           1G                               pud
> > ...
> 
> Hm. I don't see this:
> 
> ...
> [    0.247532] 0xff9e938000000000-0xff9f000000000000      111104G                               p4d
> [    0.247733] 0xff9f000000000000-0xffff000000000000          24P                               pgd
> [    0.248066] 0xffff000000000000-0xffffff0000000000         255T                               p4d
> [    0.248290] ---[ ESPfix Area ]---
> [    0.248393] 0xffffff0000000000-0xffffff8000000000         512G                               p4d
> [    0.248663] 0xffffff8000000000-0xffffffef00000000         444G                               pud
> [    0.248892] ---[ EFI Runtime Services ]---
> [    0.248996] 0xffffffef00000000-0xfffffffec0000000          63G                               pud
> [    0.249308] 0xfffffffec0000000-0xfffffffefe400000         996M                               pmd
> ...
> 
> Do you have commit "x86/dump_pagetables: Generalize address normalization"
> in your tree?
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git/commit/?h=la57/boot-switching/v2&id=13327fec85ffe95d9c8a3f57ba174bf5d5c1fb01
> 
> > As for KASAN, I think it would be better just to make it work faster,
> > the patch below demonstrates the idea.
> 
> Okay, let me test this.

The patch works for me.

The problem is not exclusive to 5-level paging, so could you prepare and
push proper patch upstream?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
