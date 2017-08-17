Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8666B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 07:10:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 30so12414802wrk.7
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 04:10:10 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id j59si3133026edc.341.2017.08.17.04.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 04:10:08 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id y67so7820105wrb.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 04:10:08 -0700 (PDT)
Date: Thu, 17 Aug 2017 13:10:05 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 08/14] x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D
 variable
Message-ID: <20170817111005.asebivpywpeyevfq@gmail.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-9-kirill.shutemov@linux.intel.com>
 <20170817090038.lfhmuk7hpuw2zzwo@gmail.com>
 <20170817105418.gpcxazmpmx4aaxyz@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170817105418.gpcxazmpmx4aaxyz@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Aug 17, 2017 at 11:00:38AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > For boot-time switching between 4- and 5-level paging we need to be able
> > > to fold p4d page table level at runtime. It requires variable
> > > PGDIR_SHIFT and PTRS_PER_P4D.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > ---
> > >  arch/x86/boot/compressed/kaslr.c        |  5 +++++
> > >  arch/x86/include/asm/pgtable_32.h       |  2 ++
> > >  arch/x86/include/asm/pgtable_32_types.h |  2 ++
> > >  arch/x86/include/asm/pgtable_64_types.h | 15 +++++++++++++--
> > >  arch/x86/kernel/head64.c                |  9 ++++++++-
> > >  arch/x86/mm/dump_pagetables.c           | 12 +++++-------
> > >  arch/x86/mm/init_64.c                   |  2 +-
> > >  arch/x86/mm/kasan_init_64.c             |  2 +-
> > >  arch/x86/platform/efi/efi_64.c          |  4 ++--
> > >  include/asm-generic/5level-fixup.h      |  1 +
> > >  include/asm-generic/pgtable-nop4d.h     |  1 +
> > >  include/linux/kasan.h                   |  2 +-
> > >  mm/kasan/kasan_init.c                   |  2 +-
> > >  13 files changed, 43 insertions(+), 16 deletions(-)
> > 
> > So I'm wondering what the code generation effect of this is - what's the 
> > before/after vmlinux size?
> > 
> > My guess is that the effect should be very small, as these constants are not 
> > widely used - but I'm only guessing and could be wrong.
> 
> This change increase vmlinux size for defconfig + X86_5LEVEL=y by ~4k or
> 0.01%.

Please add this info to one of the changelogs.

BTW., some of that might be won back via the later optimizations, right?

BTW, I think what matters most is the .text section size, while 'size' would also 
add exceptions/out-of-line sections too.

Here's a way to display the .text section only:

 triton:~/tip> printf "# vmlinux .text size: %d\n" 0x$(echo $(readelf -W -e vmlinux | grep ' \[ 1\] .text ') | cut -d' ' -f7)
 # vmlinux .text size: 9797610

 triton:~/tip> size vmlinux
   text    data     bss     dec     hex filename
 10748306        4875500  876544 16500350         fbc67e vmlinux

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
