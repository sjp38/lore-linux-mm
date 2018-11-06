Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFFEE6B02AF
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 23:36:04 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g24-v6so11515276pfi.23
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 20:36:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l189sor2121689pgd.51.2018.11.05.20.36.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 20:36:03 -0800 (PST)
Date: Mon, 5 Nov 2018 20:36:00 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH -next 0/3] Add support for fast mremap
Message-ID: <20181106043600.GB139199@google.com>
References: <20181103040041.7085-1-joelaf@google.com>
 <6886607.O3ZT5bM3Cy@blindfold>
 <e1d039a5-9c83-b9b9-98b5-d39bc48f04e0@kot-begemot.co.uk>
 <20181103183208.GA56850@google.com>
 <D6FB3C15-A8C1-4694-A434-A7489F590E05@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D6FB3C15-A8C1-4694-A434-A7489F590E05@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>, Richard Weinberger <richard@nod.at>, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, dancol@google.com, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, hughd@google.com, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, "Kirill A. Shutemov" <kirill@shutemov.name>, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vge.kvack.org, r.kernel.org@lithops.sigma-star.at, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, lokeshgidra@google.com, Max Filippov <jcmvbkbc@gmail.com>, Michal Hocko <mhocko@kernel.org>, minchan@kernel.org, nios2-dev@lists.rocketboards.org, pantin@google.com, Peter Zijlstra <peterz@infradead.org>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Sun, Nov 04, 2018 at 12:56:48AM -0600, William Kucharski wrote:
> 
> 
> > On Nov 3, 2018, at 12:32 PM, Joel Fernandes <joel@joelfernandes.org> wrote:
> > 
> > Looks like more architectures don't define set_pmd_at. I am thinking the
> > easiest way forward is to just do the following, instead of defining
> > set_pmd_at for every architecture that doesn't care about it. Thoughts?
> > 
> > diff --git a/mm/mremap.c b/mm/mremap.c
> > index 7cf6b0943090..31ad64dcdae6 100644
> > --- a/mm/mremap.c
> > +++ b/mm/mremap.c
> > @@ -281,7 +281,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
> > 			split_huge_pmd(vma, old_pmd, old_addr);
> > 			if (pmd_trans_unstable(old_pmd))
> > 				continue;
> > -		} else if (extent == PMD_SIZE && IS_ENABLED(CONFIG_HAVE_MOVE_PMD)) {
> > +		} else if (extent == PMD_SIZE) {
> > +#ifdef CONFIG_HAVE_MOVE_PMD
> > 			/*
> > 			 * If the extent is PMD-sized, try to speed the move by
> > 			 * moving at the PMD level if possible.
> > @@ -296,6 +297,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
> > 				drop_rmap_locks(vma);
> > 			if (moved)
> > 				continue;
> > +#endif
> > 		}
> > 
> > 		if (pte_alloc(new_vma->vm_mm, new_pmd))
> > 
> 
> That seems reasonable as there are going to be a lot of architectures that never have
> mappings at the PMD level.

Ok, I will do it like this and resend.

> Have you thought about what might be needed to extend this paradigm to be able to
> perform remaps at the PUD level, given many architectures already support PUD-mapped
> pages?
> 

I have thought about this. I believe it is doable in the future. Off the top
I don't see an issue doing it, and it will also reduce the number of flushes.

thanks,

- Joel
