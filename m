Subject: Re: [kpreempt-tech] Re: Oops in kernel 2.4.19-pre10-ac2-preempt
From: Robert Love <rml@mvista.com>
In-Reply-To: <20020620172220.GT25360@holomorphy.com>
References: <OF4C1E1763.D4BE6432-ON86256BDE.0055BDB6@hou.us.ray.com>
	<20020620171652.GS25360@holomorphy.com> <1024593564.922.151.camel@sinai>
	<20020620172220.GT25360@holomorphy.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 20 Jun 2002 10:58:21 -0700
Message-Id: <1024595902.1195.169.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Mark_H_Johnson@Raytheon.com, kpreempt-tech@lists.sourceforge.net, linux-mm@kvack.org, Robert_Horton@Raytheon.com, James_P_Cassidy@Raytheon.com, Stanley_R_Allen@Raytheon.com
List-ID: <linux-mm.kvack.org>

On Thu, 2002-06-20 at 10:22, William Lee Irwin III wrote:

> That'd be great, the two places are pte_chain_lock() and pte_chain_unlock().
> They're basically a spin_lock_bit() and spin_unlock_bit(), so they need
> the same kind of disable preempt before the spinloop and re-enable it after
> dropping the lock treatment as spinlocks.

Here is the patch... I will put out an updated -ac patch shortly with
this and some other bits.

Correct?

	Robert Love

diff -urN linux-2.4.19-pre10-ac2/include/linux/mm.h linux/include/linux/mm.h
--- linux-2.4.19-pre10-ac2/include/linux/mm.h	Thu Jun  6 11:16:03 2002
+++ linux/include/linux/mm.h	Thu Jun 20 10:57:01 2002
@@ -340,6 +340,7 @@
 	 * busywait with less bus contention for a good time to
 	 * attempt to acquire the lock bit.
 	 */
+	preempt_disable();
 	while (test_and_set_bit(PG_chainlock, &page->flags)) {
 		while (test_bit(PG_chainlock, &page->flags))
 			cpu_relax();
@@ -349,6 +350,7 @@
 static inline void pte_chain_unlock(struct page *page)
 {
 	clear_bit(PG_chainlock, &page->flags);
+	preempt_enable();
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
