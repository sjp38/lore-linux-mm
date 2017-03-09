Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF9112808A4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 08:59:37 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id h188so20693053wma.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 05:59:37 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id h13si4356903wme.149.2017.03.09.05.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 05:59:36 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id u108so8020690wrb.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 05:59:36 -0800 (PST)
Date: Thu, 9 Mar 2017 16:59:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 6/7] mm: convert generic code to 5-level paging
Message-ID: <20170309135932.fqlvus4zvipkpuh2@node.shutemov.name>
References: <20170306204514.1852-1-kirill.shutemov@linux.intel.com>
 <20170306204514.1852-7-kirill.shutemov@linux.intel.com>
 <20170308135734.GA11034@dhcp22.suse.cz>
 <20170308152129.sknp75d5usdu4vne@black.fi.intel.com>
 <20170309095415.GE11592@dhcp22.suse.cz>
 <20170309114716.e6ll7tsykz5iimnn@node.shutemov.name>
 <20170309122030.GH11592@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309122030.GH11592@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 09, 2017 at 01:20:30PM +0100, Michal Hocko wrote:
> On Thu 09-03-17 14:47:16, Kirill A. Shutemov wrote:
> > On Thu, Mar 09, 2017 at 10:54:15AM +0100, Michal Hocko wrote:
> > > On Wed 08-03-17 18:21:30, Kirill A. Shutemov wrote:
> [...]
> > > > We can drop the hack once all architectures that support kasan would be
> > > > converted to pgtable-nop4d.h -- amd64 and x86 at the moment.
> > > 
> > > But those architectures even do not enable kasan
> > > $ git grep "select *HAVE_ARCH_KASAN"
> > > arch/arm64/Kconfig:     select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
> > > arch/x86/Kconfig:       select HAVE_ARCH_KASAN                  if X86_64 && SPARSEMEM_VMEMMAP
> > > 
> > > both arm64 and x86 (64b) do compile fine without the ifdef... So I guess
> > > we should be fine without it.
> > 
> > Have you build the image to the final linking? lm_alias() hides the error
> > until later.
> > 
> > x86-64 allmodconfig without the #ifndef:
> > 
> >   MODPOST vmlinux.o
> > mm/built-in.o: In function `kasan_populate_zero_shadow':
> > (.init.text+0xb72b): undefined reference to `kasan_zero_p4d'
> > Makefile:983: recipe for target 'vmlinux' failed
> > make: *** [vmlinux] Error 1
> 
> Interesting
> arm64 cross compile:
> $ grep CONFIG_KASAN .config
> CONFIG_KASAN=y
> CONFIG_KASAN_OUTLINE=y
> # CONFIG_KASAN_INLINE is not set
> 
> Compiling for arm64 with aarch64-linux using gcc 4.9.0
> [...]
>   LD      vmlinux.o
>   MODPOST vmlinux.o
>   KSYM    .tmp_kallsyms1.o
>   KSYM    .tmp_kallsyms2.o
>   LD      vmlinux
>   SORTEX  vmlinux
>   SYSMAP  System.map
> 
> x86_64 crosscompile with the same version to rule out gcc version
> changes
> 
> $ grep CONFIG_KASAN .config
> CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
> CONFIG_KASAN=y
> CONFIG_KASAN_OUTLINE=y
> # CONFIG_KASAN_INLINE is not set
> 
> [...]
>   LD      init/built-in.o
>   LD      vmlinux.o
>   MODPOST vmlinux.o
> mm/built-in.o: In function `kasan_populate_zero_shadow':
> (.init.text+0x84e5): undefined reference to `kasan_zero_p4d'
> Makefile:983: recipe for target 'vmlinux' failed
> 
> no idea why arm64 build was OK.

allmodconfig on amd64 enables 3-level paging, whcih produces nop
pgd_populate().

defconfig + enabling CONFIG_KASAN would trigger the issue:

mm/built-in.o: In function `kasan_populate_zero_shadow':
/home/kas/linux/la57/mm/kasan/kasan_init.c:161: undefined reference to `kasan_zero_p4d'
/home/kas/linux/la57/mm/kasan/kasan_init.c:161: undefined reference to `kasan_zero_p4d'
Makefile:983: recipe for target 'vmlinux' failed
make: *** [vmlinux] Error 1

> Anyway I am not insisting on removing this ifdef it is just too ugly to
> spread __ARCH_HAS_5LEVEL_HACK outside of the arch code. We have few more
> in the mm code but those look much more understandable. Maybe a short
> comment explaining the ifdef would be better.

Sure.

Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
