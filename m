Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC2BD2808C6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 06:47:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v66so20565582wrc.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 03:47:21 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id j38si8435287wra.42.2017.03.09.03.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 03:47:20 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id u48so7615220wrc.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 03:47:20 -0800 (PST)
Date: Thu, 9 Mar 2017 14:47:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 6/7] mm: convert generic code to 5-level paging
Message-ID: <20170309114716.e6ll7tsykz5iimnn@node.shutemov.name>
References: <20170306204514.1852-1-kirill.shutemov@linux.intel.com>
 <20170306204514.1852-7-kirill.shutemov@linux.intel.com>
 <20170308135734.GA11034@dhcp22.suse.cz>
 <20170308152129.sknp75d5usdu4vne@black.fi.intel.com>
 <20170309095415.GE11592@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309095415.GE11592@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 09, 2017 at 10:54:15AM +0100, Michal Hocko wrote:
> On Wed 08-03-17 18:21:30, Kirill A. Shutemov wrote:
> > On Wed, Mar 08, 2017 at 02:57:35PM +0100, Michal Hocko wrote:
> > > On Mon 06-03-17 23:45:13, Kirill A. Shutemov wrote:
> > > > Convert all non-architecture-specific code to 5-level paging.
> > > > 
> > > > It's mostly mechanical adding handling one more page table level in
> > > > places where we deal with pud_t.
> > > > 
> > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > 
> > > OK, I haven't spotted anything major. I am just scratching my head about
> > > the __ARCH_HAS_5LEVEL_HACK leak into kasan_init.c (see below). Why do we
> > > need it?  It looks more than ugly but I am not familiar with kasan so
> > > maybe this is really necessary.
> > 
> > Yeah ugly.
> > 
> > kasan_zero_p4d is only defined if we have real page table level. It's okay
> > if the page table level is folded properly -- using pgtable-nop4d.h -- in
> > this case pgd_populate() is nop and we don't reference kasan_zero_p4d.
> > 
> > With 5level-fixup.h, pgd_populate() is not nop, so we would reference
> > kasan_zero_p4d and build breaks. We don't need this as p4d_populate()
> > would do what we really need in this case.
> > 
> > We can drop the hack once all architectures that support kasan would be
> > converted to pgtable-nop4d.h -- amd64 and x86 at the moment.
> 
> But those architectures even do not enable kasan
> $ git grep "select *HAVE_ARCH_KASAN"
> arch/arm64/Kconfig:     select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
> arch/x86/Kconfig:       select HAVE_ARCH_KASAN                  if X86_64 && SPARSEMEM_VMEMMAP
> 
> both arm64 and x86 (64b) do compile fine without the ifdef... So I guess
> we should be fine without it.

Have you build the image to the final linking? lm_alias() hides the error
until later.

x86-64 allmodconfig without the #ifndef:

  MODPOST vmlinux.o
mm/built-in.o: In function `kasan_populate_zero_shadow':
(.init.text+0xb72b): undefined reference to `kasan_zero_p4d'
Makefile:983: recipe for target 'vmlinux' failed
make: *** [vmlinux] Error 1

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
