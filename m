Date: Wed, 19 Jun 2002 15:44:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
Message-ID: <20020619224441.GP22961@holomorphy.com>
References: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2002 at 04:18:00AM -0700, Craig Kulesa wrote:
> Where:  http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/
> This patch implements Rik van Riel's patches for a reverse mapping VM 
> atop the 2.5.23 kernel infrastructure.  The principal sticky bits in 

There is a small bit of trouble here: pte_chain_lock() needs to
preempt_disable() and pte_chain_unlock() needs to preempt_enable(),
as they are meant to protect critical sections.


Cheers,
Bill


On Wed, Jun 19, 2002 at 04:18:00AM -0700, Craig Kulesa wrote:
+static inline void pte_chain_lock(struct page *page)
+{
+   /*
+    * Assuming the lock is uncontended, this never enters
+    * the body of the outer loop. If it is contended, then
+    * within the inner loop a non-atomic test is used to
+    * busywait with less bus contention for a good time to
+    * attempt to acquire the lock bit.
+    */
+   while (test_and_set_bit(PG_chainlock, &page->flags)) {
+       while (test_bit(PG_chainlock, &page->flags))
+           cpu_relax();
+   }
+}
+
+static inline void pte_chain_unlock(struct page *page)
+{
+   clear_bit(PG_chainlock, &page->flags);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
