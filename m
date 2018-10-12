Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9CE6B0005
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 15:42:14 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id m3-v6so10269484plt.9
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:42:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24-v6sor2046427pgg.85.2018.10.12.12.42.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 12:42:13 -0700 (PDT)
Date: Fri, 12 Oct 2018 12:42:10 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v2 1/2] treewide: remove unused address argument from
 pte_alloc functions
Message-ID: <20181012194210.GA27630@joelaf.mtv.corp.google.com>
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <03b524f3-5f3a-baa0-2254-9c588103d2d6@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <03b524f3-5f3a-baa0-2254-9c588103d2d6@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com, Michal Hocko <mhocko@kernel.org>, Julia Lawall <Julia.Lawall@lip6.fr>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Daniel Colascione <dancol@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "James E. J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, pantin@google.com, Lokesh Gidra <lokeshgidra@google.com>, Max Filippov <jcmvbkbc@gmail.com>, Minchan Kim <minchan@kernel.org>, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 12, 2018 at 08:51:45PM +0200, SF Markus Elfring wrote:
> > The changes were obtained by applying the following Coccinelle script.
> 
> A bit of clarification happened for its implementation details.
> https://systeme.lip6.fr/pipermail/cocci/2018-October/005374.html
> 
> I have taken also another look at the following SmPL code.
> 
> 
> > identifier fn =~
> > "^(__pte_alloc|pte_alloc_one|pte_alloc|__pte_alloc_kernel|pte_alloc_one_kernel)$";
> 
> I suggest to adjust the regular expression for this constraint
> and in subsequent SmPL rules.
> "^(?:pte_alloc(?:_one(?:_kernel)?)?|__pte_alloc(?:_kernel)?)$";

Sure it looks more clever, but why? Ugh that's harder to read and confusing.

> > (
> > - T3 fn(T1 E1, T2 E2);
> > + T3 fn(T1 E1);
> > |
> > - T3 fn(T1 E1, T2 E2, T4 E4);
> > + T3 fn(T1 E1, T2 E2);
> > )
> 
> I propose to take an other SmPL disjunction into account here.
> 
>  T3 fn(T1 E1,
> (
> -      T2 E2
> |      T2 E2,
> -      T4 E4
> )      );

Again this is confusing. It makes one think that maybe the second argument
can also be removed and requires careful observation that the ");" follows.

> > (
> > - #define fn(a, b, c)@p e
> > + #define fn(a, b) e
> > |
> > - #define fn(a, b)@p e
> > + #define fn(a) e
> > )
> 
> How do you think about to omit the metavariable a??position pa?? here?

Right, I don't need it in this case. But the script works either way.

I like to take more of a problem solving approach that makes sense, than
aiming for perfection, after all this is a useful script that we do not
need to check in once we finish with it.

 - Joel
