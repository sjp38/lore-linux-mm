Received: from parasite.irisa.fr (parasite.irisa.fr [131.254.12.47])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA04399
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 13:18:25 -0500
Subject: Re: 4M kernel pages
References: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home> <364FE29E.2CF14EEA@varel.bg> <wd8emr3yfeu.fsf@parate.irisa.fr> <36503F86.FC08594@varel.bg> <wd8zp9rwtc7.fsf@parate.irisa.fr> <365057C8.50B31465@varel.bg>
From: "David Mentr\\'e" <David.Mentre@irisa.fr>
Date: 16 Nov 1998 19:18:12 +0100
In-Reply-To: Petko Manolov's message of "Mon, 16 Nov 1998 18:50:16 +0200"
Message-ID: <wd8u2zzwlgb.fsf@parate.irisa.fr>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Petko Manolov <petkan@varel.bg>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



Petko Manolov <petkan@varel.bg> writes:

> David Mentr\'e wrote:
> > 
> > Look at arch/i386/kernel/head.S:
> 
> This is only for SMP machines.

You are right. Shame on me (the #define is so BIG :).

> ;-) I got sure by other way.

To much brute force. :)

> In kernel mode i red the whole page directory. All kernel page dir
> entries ended with LSB == 0xe3.  7th bit on means 4M pages. 1 and 0
> bits means respectively r/w and present.

So, know we are sure this bit is set. But when (in the source) ?


[ in your first mail ]
> I took a look at linux/arch/i386/mm/init.c - paging_init().  Yes we
> rise PSE bit in cr4 but don't rise the PS bit in the pade directory
> entry for the kernel - which means the kernel is in 4K pages.

BTW, I think I've found when the PS bit is set. In fact, I you may have
overlooked arch/i386/mm/init.c. Around line 325, you have :

		/*
		 * If we're running on a Pentium CPU, we can use the 4MB
		 * page tables. 
		 *
		 * The page tables we create span up to the next 4MB
		 * virtual memory boundary, but that's OK as we won't
		 * use that memory anyway.
		 */
		if (boot_cpu_data.x86_capability & X86_FEATURE_PSE) {
			unsigned long __pe;

			set_in_cr4(X86_CR4_PSE);
			boot_cpu_data.wp_works_ok = 1;
			__pe = _KERNPG_TABLE + _PAGE_4M + __pa(address); <----
			/* Make it "global" too if supported */
			if (boot_cpu_data.x86_capability & X86_FEATURE_PGE) {
				set_in_cr4(X86_CR4_PGE);
				__pe += _PAGE_GLOBAL;
			}
			pgd_val(*pg_dir) = __pe;
			pg_dir++;
			address += 4*1024*1024;
			continue;
		}

At the line marked '<---', the macro _PAGE_4M set the PS bit (macro
defined in include/asm-i386/pgtable.h).  The code then setup the page
directory with __pe ('pgd_val(*pg_dir) = __pe;').

Is it right ? Or you where looking at another page directory ? (I'm far
from an expert in both kernel and i386 asm)

> The point is that 6th bit is also 1 when it supposed to be 0
> acording to Intel docs.

Yes. But, as it is reserved, it may be a hiden feature of intel procs. ;)

> Excuse me all for this boring mails!

No. It's interesting to know how things are done. And while trying to
explain this, I'm learning the Linux kernel. :)

Best regards,
d.
-- 
 David.Mentre@irisa.fr -- http://www.irisa.fr/prive/dmentre/
 Opinions expressed here are only mine.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
