Date: Sun, 23 Dec 2007 10:14:05 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20071223091405.GA15631@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <20071222232932.590e2b6c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071222232932.590e2b6c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 22, 2007 at 11:29:32PM -0800, Andrew Morton wrote:
> On Sun, 23 Dec 2007 08:15:29 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > That's just speculation.  Please find out why such a small patch caused
> > > such a large code size increase and see if it can be fixed.
> > 
> > It's not actually increasing size by that much here... hmm, do you have
> > CONFIG_X86_PPRO_FENCE defined, by any chance?
> 
> I expect it was just allmodconfig, so: yes
> 
> It's a quite repeatable experiment though.

Yep. I only saw half the text size blot that you did, but it was still quite a bit.

i386 allmodconf: size mm/built-in.o
           text    data     bss     dec     hex         text ratio
vanilla: 163082   20372   40120  223574   36956          100.00%
bugfix : 163509   20372   40120  224001   36b01            0.26%
noppro : 162191   20372   40120  222683   365db         -  0.55%
both   : 162267   20372   40120  222759   36627         -  0.50% (+0.05% vs noppro)

So with the ppro memory ordering bug out of the way, the PG_uptodate fix
only adds 76 bytes of text.


> > It looks like this gets defined by default for i386, and also probably for
> > distro configs. Linus? This is a fairly heavy hammer for such an unlikely bug on
> > such a small number of systems (that admittedly doesn't even fix the bug in all
> > cases anyway). It's not only heavy for my proposed patch, but it also halves the
> > speed of spinlocks. Can we have some special config option for this instead? 
> 
> Sounds worthwhile, if we can't do it via altinstructions.

Altinstructions means we still have code bloat, and sometimes extra branches
etc (an extra 900 bytes of icache in mm/ alone, even before my fix). I'll let
Linus or one of the x86 guys weigh in, though. It's a really sad cost for
distro kernels to carry.

---

Index: linux-2.6/arch/x86/Kconfig.cpu
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig.cpu
+++ linux-2.6/arch/x86/Kconfig.cpu
@@ -322,9 +322,18 @@ config X86_XADD
 	default y
 
 config X86_PPRO_FENCE
-	bool
+	bool "PentiumPro memory ordering errata workaround"
 	depends on M686 || M586MMX || M586TSC || M586 || M486 || M386 || MGEODEGX1
-	default y
+	default n
+	help
+	  Old PentiumPro multiprocessor systems had errata that could cause memory
+	  operations to violate the x86 ordering standard in rare cases. Enabling this
+	  option will attempt to work around some (but not all) occurances of
+	  this problem, at the cost of much heavier spinlock and memory barrier
+	  operations.
+
+	  If unsure, say n here. Even distro kernels should think twice before enabling
+	  this: there are few systems, and an unlikely bug.
 
 config X86_F00F_BUG
 	bool

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
