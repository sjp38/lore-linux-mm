Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B65D66B0005
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 15:43:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r81-v6so24570272pfk.11
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 12:43:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i90-v6sor5037049pli.26.2018.10.16.12.43.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 12:43:17 -0700 (PDT)
Date: Tue, 16 Oct 2018 12:43:13 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH 2/4] mm: speed up mremap by 500x on large regions (v2)
Message-ID: <20181016194313.GA247930@joelaf.mtv.corp.google.com>
References: <20181013013200.206928-1-joel@joelfernandes.org>
 <20181013013200.206928-3-joel@joelfernandes.org>
 <20181015094209.GA31999@infradead.org>
 <20181015223303.GA164293@joelaf.mtv.corp.google.com>
 <35b9c85a-b366-9ca3-5647-c2568c811961@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35b9c85a-b366-9ca3-5647-c2568c811961@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, linux-mm@kvack.org, lokeshgidra@google.com, linux-riscv@lists.infradead.org, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, kvmarm@lists.cs.columbia.edu, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com, anton.ivanov@kot-begemot.co.uk, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-snps-arc@lists.infradead.org, kernel-team@android.com, Sam Creasey <sammy@sammy.net>, Fenghua Yu <fenghua.yu@intel.com>, linux-s390@vger.kernel.org, Jeff Dike <jdike@addtoit.com>, linux-um@lists.infradead.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Julia Lawall <Julia.Lawall@lip6.fr>, linux-m68k@lists.linux-m68k.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, nios2-dev@lists.rocketboards.org, kirill@shutemov.name, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>, linux-parisc@vger.kernel.org, pantin@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-alpha@vger.kernel.org, Ley Foon Tan <lftan@altera.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Tue, Oct 16, 2018 at 01:29:52PM +0200, Vlastimil Babka wrote:
> On 10/16/18 12:33 AM, Joel Fernandes wrote:
> > On Mon, Oct 15, 2018 at 02:42:09AM -0700, Christoph Hellwig wrote:
> >> On Fri, Oct 12, 2018 at 06:31:58PM -0700, Joel Fernandes (Google) wrote:
> >>> Android needs to mremap large regions of memory during memory management
> >>> related operations.
> >>
> >> Just curious: why?
> > 
> > In Android we have a requirement of moving a large (up to a GB now, but may
> > grow bigger in future) memory range from one location to another.
> 
> I think Christoph's "why?" was about the requirement, not why it hurts
> applications. I admit I'm now also curious :)

This issue was discovered when we wanted to be able to move the physical
pages of a memory range to another location quickly so that, after the
application threads are resumed, UFFDIO_REGISTER_MODE_MISSING userfaultfd
faults can be received on the original memory range. The actual operations
performed on the memory range are beyond the scope of this discussion. The
user threads continue to refer to the old address which will now fault. The
reason we want retain the old memory range and receives faults there is to
avoid the need to fix the addresses all over the address space of the threads
after we finish with performing operations on them in the fault handlers, so
we mremap it and receive faults at the old addresses.

Does that answer your question?

thanks,

- Joel
