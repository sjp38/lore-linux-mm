From: Keith Owens <kaos@sgi.com>
Subject: Re: [RFC 1/3] LVHPT - Fault handler modifications 
In-reply-to: Your message of "Tue, 02 May 2006 15:25:51 +1000."
             <20060502052551.8990.16410.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 02 May 2006 18:04:08 +1000
Message-ID: <9614.1146557048@kao2.melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ian Wienand <ianw@gelato.unsw.edu.au>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ian Wienand (on Tue, 02 May 2006 15:25:51 +1000) wrote:
>Firstly, we have stripped out common code in ivt.S into assembler
>macros in ivt-macro.S.  The comments before the macros should explain
>what each is doing.

Make that ivt.h to match the existing codebase, entry.S has entry.h.
ivt-macro.S is not standalone assembler.

These patches contain trailing whitespace on at least 15 lines.

>The main changes are
>
>vhpt_miss can no longer happen.  This fault is only raised when the
>walker does not have a mapping for the hashed address; with lvhpt the
>hash table is pinned with a single entry.

ia64_do_tlb_purge() purges the fxed TR entries on an MCA caused by
invalid TLB entries, ia64_reload_tr() then reloads the fixed TR
entries.  IA64_TR_LONG_VHPT must be added to both ia64_do_tlb_purge()
and ia64_reload_tr().

compute_vhpt_size_numa() has the comment

 /* In the NUMA case, we evaluate how much memory each node has
  * and then try to size it to three times the physical memory
  * of the node (as this gives us the best coverage.  As we pin
  * this with a TLB entry, we need to make sure the size we
  * choose is however suitable for the architecture.
  */

How will this work with cpu and memory hotplug?

>+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
>+	LOAD_PTE_MISS r16, r17, r18, r22, page_fault
>...
>+#else
>+	LOAD_PTE_MISS r17, r18, page_fault
>+#endif

I do not like LOAD_PTE_MISS being defined with different numbers and
order of parameters depending on the config.  Use one LOAD_PTE_MISS
macro that always takes ppte, pte, failfn, va and hpte (in that order).
Then ignore va and hpte for the short form VHPT, hidden inside the
macro definition.

BTW, load_pte_miss claims to take an hpte parameter, but it is not
used.

It is difficult to see what has really changed in ivt.S because of the
change to macros and the addition of LONG_FORMAT_VHPT at the same time.
Could you split the first patch in two?  One patch to add the macros
and a second one to add LONG_FORMAT_VHPT would be much easier to
understand.

The macros use hardcoded work registers like r18, r19 and r21.  That is
going to make it really awkward to maintain, I hate macros with hidden
side effects.  Either pass the work registers to the macros or document
what registers these macros clobber.

arch/ia64/kernel/setup.c:+    extern int lvhpt_bits_clamp_setup(char *s);
arch/ia64/kernel/setup.c:+    extern void __devinit ia64_tlb_early_init(void);
arch/ia64/kernel/setup.c:+            extern void compute_vhpt_size(void);
arch/ia64/kernel/smpboot.c:+extern unsigned int alloc_vhpt(int cpu);
arch/ia64/mm/tlb.c:+          extern unsigned long vhpt_base[];

Adding more extern to C files, yuck!  That's what headers are for.

Could you explain how VHPT_PURGE works with LONG_FORMAT_VHPT=n?  I am
puzzled why the patch has VHPT_PURGE not protected by #ifdef
CONFIG_LONG_FORMAT_VHPT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
