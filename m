Date: Wed, 10 Jul 2002 16:26:56 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <167170000.1026343616@flay>
In-Reply-To: <3D2CBE6A.53A720A0@zip.com.au>
References: <3D2BC6DB.B60E010D@zip.com.au> <91460000.1026341000@flay> <3D2CBE6A.53A720A0@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Yes, I've seen the in-kernel profiler doing odd things.  If 
> you're not using the local APIC timer then I think the new
> IRQ balancing code will break the profiler by steering the
> clock interrupts away from busy CPUs (!).

The first patch we apply is this

diff -Nur linux-2.5.23-vanilla/arch/i386/kernel/io_apic.c linux-2.5.23-patched/arch/i386/kernel/io_apic.c
--- linux-2.5.23-vanilla/arch/i386/kernel/io_apic.c	Tue Jun 18 19:11:52 2002
+++ linux-2.5.23-patched/arch/i386/kernel/io_apic.c	Thu Jun 27 14:28:51 2002
@@ -247,7 +247,7 @@
 
 static inline void balance_irq(int irq)
 {
-#if CONFIG_SMP
+#if (CONFIG_SMP && !CONFIG_MULTIQUAD)
 	irq_balance_t *entry = irq_balance + irq;
 	unsigned long now = jiffies;

Which should turn of IRQ balancing completely, I think ...

> But ISTR that the profiler has gone whacky even with CONFIG_X86_LOCAL_APIC,
> which shouldn't be affected by the IRQ steering.

Interrupt 0 will only ever go the first quad (well, it should do
if I actually fixed the timers), but CONFIG_X86_LOCAL_APIC=y
is on. Wierd ...

> But NMI-based oprofile is bang-on target so I recommend you use that.
> I'll publish my oprofile-for-2.5 asap.

That'd be good, but I'm not sure my box likes NMIs too much ;-)
We'll see ....

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
