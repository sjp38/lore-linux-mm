Subject: Re: [patch 2/2]: introduce fast_gup
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.1.00.0804170940270.2879@woody.linux-foundation.org>
References: <20080328025455.GA8083@wotan.suse.de>
	 <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins>
	 <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org>
	 <1208448768.7115.30.camel@twins>
	 <alpine.LFD.1.00.0804170916470.2879@woody.linux-foundation.org>
	 <1208450119.7115.36.camel@twins>
	 <alpine.LFD.1.00.0804170940270.2879@woody.linux-foundation.org>
Content-Type: text/plain
Date: Thu, 17 Apr 2008 19:23:34 +0200
Message-Id: <1208453014.7115.39.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-04-17 at 09:40 -0700, Linus Torvalds wrote:
> 
> On Thu, 17 Apr 2008, Peter Zijlstra wrote:
> > 
> > Here you go ;-)
> 
> I think you should _use_ the new functions too ;)

D'0h - clearly not my day today...

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
@@ -36,7 +79,7 @@ static noinline int gup_pte_range(pmd_t 
 		 * function that will do this properly, so it is broken on
 		 * 32-bit 3-level for the moment.
 		 */
-		pte_t pte = *ptep;
+		pte_t pte = native_get_pte(ptep);
 		struct page *page;
 
 		if ((pte_val(pte) & mask) != result)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
