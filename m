Date: Thu, 30 Jan 2003 01:43:45 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linus rollup
Message-ID: <20030130004344.GH1237@dualathlon.random>
References: <20030128220729.1f61edfe.akpm@digeo.com> <20030129095949.A24161@flint.arm.linux.org.uk> <20030129.015134.19663914.davem@redhat.com> <20030129022617.62800a6e.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030129022617.62800a6e.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "David S. Miller" <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 02:26:17AM -0800, Andrew Morton wrote:
> "David S. Miller" <davem@redhat.com> wrote:
> >
> >    From: Russell King <rmk@arm.linux.org.uk>
> >    Date: Wed, 29 Jan 2003 09:59:49 +0000
> >    
> >    	/* This function must be called with interrupts disabled
> >    
> >    which hasn't been true for some time, and is even less true now that
> >    local IRQs don't get disabled.  Does this matter... for UP?
> > 
> > I disable local IRQs during gettimeofday() on sparc.
> > 
> > These locks definitely need to be taken with IRQs disabled.
> > Why isn't x86 doing that?
> 
> Darned if I know.  Looks like Andrea's kernel will deadlock if
> arch/i386/kernel/time.c:timer_interrupt() takes i8253_lock
> while that cpu is holding the same lock in do_slow_gettimeoffset().

yes thanks! mostly theorical though, 486 SMP boxes aren't that common ;)

This should fix it.

--- 2.4.21pre3aa1/arch/i386/kernel/time.c.~1~	2003-01-21 03:43:59.000000000 +0100
+++ 2.4.21pre3aa1/arch/i386/kernel/time.c	2003-01-30 01:40:37.000000000 +0100
@@ -159,6 +159,7 @@ extern spinlock_t i8259A_lock;
 static unsigned long do_slow_gettimeoffset(void)
 {
 	int count;
+	unsigned long flags;
 
 	static int count_p = LATCH;    /* for the first call after boot */
 	static unsigned long jiffies_p = 0;
@@ -169,7 +170,7 @@ static unsigned long do_slow_gettimeoffs
 	unsigned long jiffies_t;
 
 	/* gets recalled with irq locally disabled */
-	spin_lock(&i8253_lock);
+	spin_lock_irqsave(&i8253_lock, flags);
 	/* timer count may underflow right here */
 	outb_p(0x00, 0x43);	/* latch the count ASAP */
 
@@ -191,7 +192,7 @@ static unsigned long do_slow_gettimeoffs
                 count = LATCH - 1;
         }
 	
-	spin_unlock(&i8253_lock);
+	spin_unlock_irqrestore(&i8253_lock, flags);
 
 	/*
 	 * avoiding timer inconsistencies (they are rare, but they happen)...
@@ -212,13 +213,13 @@ static unsigned long do_slow_gettimeoffs
 
 			int i;
 
-			spin_lock(&i8259A_lock);
+			spin_lock_irqsave(&i8259A_lock, flags);
 			/*
 			 * This is tricky when I/O APICs are used;
 			 * see do_timer_interrupt().
 			 */
 			i = inb(0x20);
-			spin_unlock(&i8259A_lock);
+			spin_unlock_irqrestore(&i8259A_lock, flags);
 
 			/* assumption about timer being IRQ0 */
 			if (i & 0x01) {

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
