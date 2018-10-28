Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37B816B0352
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 18:40:09 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c28-v6so5858411pfe.4
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 15:40:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9-v6sor16730514pgs.2.2018.10.28.15.40.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Oct 2018 15:40:08 -0700 (PDT)
Date: Mon, 29 Oct 2018 09:40:02 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 2/4] mm: speed up mremap by 500x on large regions (v2)
Message-ID: <20181028224002.GA16399@350D>
References: <20181013013200.206928-1-joel@joelfernandes.org>
 <20181013013200.206928-3-joel@joelfernandes.org>
 <20181024101255.it4lptrjogalxbey@kshutemo-mobl1>
 <20181024115733.GN8537@350D>
 <20181025021350.GB13560@joelaf.mtv.corp.google.com>
 <20181027102102.GO8537@350D>
 <20181027193917.GA51131@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181027193917.GA51131@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, kernel-team@android.com, minchan@kernel.org, pantin@google.com, hughd@google.com, lokeshgidra@google.com, dancol@google.com, mhocko@kernel.org, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, anton.ivanov@kot-begemot.co.uk, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Max Filippov <jcmvbkbc@gmail.com>, nios2-dev@lists.rocketboards.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Sat, Oct 27, 2018 at 12:39:17PM -0700, Joel Fernandes wrote:
> Hi Balbir,
> 
> On Sat, Oct 27, 2018 at 09:21:02PM +1100, Balbir Singh wrote:
> > On Wed, Oct 24, 2018 at 07:13:50PM -0700, Joel Fernandes wrote:
> > > On Wed, Oct 24, 2018 at 10:57:33PM +1100, Balbir Singh wrote:
> > > [...]
> > > > > > +		pmd_t pmd;
> > > > > > +
> > > > > > +		new_ptl = pmd_lockptr(mm, new_pmd);
> > > > 
> > > > 
> > > > Looks like this is largely inspired by move_huge_pmd(), I guess a lot of
> > > > the code applies, why not just reuse as much as possible? The same comments
> > > > w.r.t mmap_sem helping protect against lock order issues applies as well.
> > > 
> > > I thought about this and when I looked into it, it seemed there are subtle
> > > differences that make such sharing not worth it (or not possible).
> > >
> > 
> > Could you elaborate on them?
> 
> The move_huge_page function is defined only for CONFIG_TRANSPARENT_HUGEPAGE
> so we cannot reuse it to begin with, since we have it disabled on our
> systems. I am not sure if it is a good idea to split that out and refactor it
> for reuse especially since our case is quite simple compared to huge pages.
> 
> There are also a couple of subtle differences between the move_normal_pmd and
> the move_huge_pmd. Atleast 2 of them are:
> 
> 1. We don't concern ourself with the PMD dirty bit, since the pages being
> moved are normal pages and at the soft-dirty bit accounting is at the PTE
> level, since we are not moving PTEs, we don't need to do that.
> 
> 2. The locking is simpler as Kirill pointed, pmd_lock cannot fail however
> __pmd_trans_huge_lock can.
> 
> I feel it is not super useful to refactor move_huge_pmd to support our case
> especially since move_normal_pmd is quite small, so IMHO the benefit of code
> reuse isn't there very much.
>

My big concern is that any bug fixes will need to monitor both paths.
Do you see a big overhead in checking the soft dirty bit? The locking is
a little different. Having said that, I am not strictly opposed to the
extra code, just concerned about missing fixes/updates as we find them.
 
> Do let me know your thoughts and thanks for your interest in this.
> 
>

Balbir Singh. 
