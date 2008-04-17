Subject: Re: [patch 2/2]: introduce fast_gup
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.1.00.0804170916470.2879@woody.linux-foundation.org>
References: <20080328025455.GA8083@wotan.suse.de>
	 <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins>
	 <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org>
	 <1208448768.7115.30.camel@twins>
	 <alpine.LFD.1.00.0804170916470.2879@woody.linux-foundation.org>
Content-Type: text/plain
Date: Thu, 17 Apr 2008 18:35:19 +0200
Message-Id: <1208450119.7115.36.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-04-17 at 09:18 -0700, Linus Torvalds wrote:
> 
> On Thu, 17 Apr 2008, Peter Zijlstra wrote:
> > 
> > Jeremy, did I get the paravirt stuff right?

Still wanting to know if I got it right.

> I don't think this is worth it to virtualize.
> 
> We access the page tables directly in any number of places, having a 
> "get_pte()" indirection here is not going to help anything.
> 
> Just make it an x86-only inline function. In fact, you can keep it inside 
> arch/x86/mm/gup.c, because nobody else is likely to ever even need it, 
> since normal accesses are all supposed to be done under the page table 
> spinlock, so they do not have this issue at all.
> 
> The indirection and virtualization thing is just going to complicate 
> matters for no good reason.

Here you go ;-)

Index: linux-2.6/arch/x86/mm/gup.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/gup.c
+++ linux-2.6/arch/x86/mm/gup.c
@@ -9,6 +9,49 @@
 #include <linux/vmstat.h>
 #include <asm/pgtable.h>
 
+#ifdef CONFIG_X86_PAE
+
+/*
+ * Companion to native_set_pte_present(); normal access takes the pte_lock
+ * and thus doesn't need it.
+ *
+ * This closes the race:
+ *
+ *  CPU#1                   CPU#2
+ *  =====                   =====
+ *
+ *  fast_gup:
+ *   - read low word
+ *
+ *                          native_set_pte_present:
+ *                           - set low word to 0
+ *                           - set high word to new value
+ *
+ *   - read high word
+ *
+ *                          - set low word to new value
+ *
+ */
+static inline pte_t native_get_pte(pte_t *ptep)
+{
+	pte_t pte;
+
+retry:
+	pte.pte_low = ptep->pte_low;
+	smp_rmb();
+	pte.pte_high = ptep->pte_high;
+	smp_rmb();
+	if (unlikely(pte.pte_low != ptep->pte_low))
+		goto retry;
+	return pte;
+}
+
+#else
+
+#define native_get_pte(ptep) (*(ptep))
+
+#endif
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
