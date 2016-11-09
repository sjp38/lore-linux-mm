Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99FD56B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:27:19 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id g193so169661030qke.2
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:27:19 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id s5si1005245qkd.293.2016.11.09.13.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Nov 2016 13:27:18 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id aadac379
	for <linux-mm@kvack.org>;
	Wed, 9 Nov 2016 21:25:16 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id d6acedae (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Wed, 9 Nov 2016 21:25:15 +0000 (UTC)
Received: by mail-lf0-f51.google.com with SMTP id c13so174560137lfg.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:27:16 -0800 (PST)
MIME-Version: 1.0
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Wed, 9 Nov 2016 22:27:13 +0100
Message-ID: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
Subject: Proposal: HAVE_SEPARATE_IRQ_STACK?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>
Cc: WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

Hi folks,

I do some ECC crypto in a kthread. A fast 32bit implementation usually
uses around 2k - 3k bytes of stack. Since kernel threads get 8k, I
figured this would be okay. And for the most part, it is. However,
everything falls apart on architectures like MIPS, which do not use a
separate irq stack.

>From what I can tell, on MIPS, the irq handler uses whichever stack
was in current at the time of interruption. At the end of the irq
handler, softirqs trigger if preemption hasn't been disabled. When the
softirq handler runs, it will still use the same interrupted stack. So
let's take some pathological case of huge softirq stack usage: wifi
driver inside of l2tp inside of gre inside of ppp. Now, my ECC crypto
is humming along happily in its kthread, when all of the sudden, a
wifi packet arrives, triggering the interrupt. Or, perhaps instead,
TCP sends an ack packet on softirq, using my kthread's stack. The
interrupt is serviced, and at the end of it, softirq is serviced,
using my kthread's stack, which was already half full. When this
softirq is serviced, it goes through our 4 layers of network device
drivers. Since we started with a half full stack, we very quickly blow
it up, and everything explodes, and users write angry mailing list
posts.

It seems to me x86, ARM, SPARC, SH, ParisC, PPC, Metag, and UML all
concluded that letting the interrupt handler use current's stack was a
terrible idea, and instead have a per-cpu irq stack that gets used
when the handler is service. Whew!

But for the remaining platforms, such as MIPS, this is still a
problem. In an effort to work around this in my code, rather than
having to invoke kmalloc for what should be stack-based variables, I
was thinking I'd just disable preemption for those functions that use
a lot of stack, so that stack-hungry softirq handlers don't crush it.
This is generally unsatisfactory, so I don't want to do this
unconditionally. Instead, I'd like to do some cludge such as:

    #ifndef CONFIG_HAVE_SEPARATE_IRQ_STACK
    preempt_disable();
    #endif

    some_func_that_uses_lots_of_stack();

    #ifndef CONFIG_HAVE_SEPARATE_IRQ_STACK
    preempt_enable();
    #endif

However, for this to work, I actual need that config variable. Would
you accept a patch that adds this config variable to the relavent
platforms? If not, do you have a better solution for me (which doesn't
involve using kmalloc or choosing a different crypto primitive)?

Thanks,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
