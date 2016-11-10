Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAC36B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:17:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so246271pfb.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:17:46 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0073.outbound.protection.outlook.com. [104.47.36.73])
        by mx.google.com with ESMTPS id x27si1809214pff.112.2016.11.09.16.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:17:44 -0800 (PST)
Message-ID: <5823BCA3.2020202@caviumnetworks.com>
Date: Wed, 9 Nov 2016 16:17:39 -0800
From: David Daney <ddaney@caviumnetworks.com>
MIME-Version: 1.0
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
In-Reply-To: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

On 11/09/2016 01:27 PM, Jason A. Donenfeld wrote:
> Hi folks,
>
> I do some ECC crypto in a kthread. A fast 32bit implementation usually
> uses around 2k - 3k bytes of stack. Since kernel threads get 8k, I
> figured this would be okay. And for the most part, it is. However,
> everything falls apart on architectures like MIPS, which do not use a
> separate irq stack.

Easiest thing to do would be to select 16K page size in your .config, I 
think that will give you a similar sized stack.

>
>>From what I can tell, on MIPS, the irq handler uses whichever stack
> was in current at the time of interruption. At the end of the irq
> handler, softirqs trigger if preemption hasn't been disabled. When the
> softirq handler runs, it will still use the same interrupted stack. So
> let's take some pathological case of huge softirq stack usage: wifi
> driver inside of l2tp inside of gre inside of ppp. Now, my ECC crypto
> is humming along happily in its kthread, when all of the sudden, a
> wifi packet arrives, triggering the interrupt. Or, perhaps instead,
> TCP sends an ack packet on softirq, using my kthread's stack. The
> interrupt is serviced, and at the end of it, softirq is serviced,
> using my kthread's stack, which was already half full. When this
> softirq is serviced, it goes through our 4 layers of network device
> drivers. Since we started with a half full stack, we very quickly blow
> it up, and everything explodes, and users write angry mailing list
> posts.
>
> It seems to me x86, ARM, SPARC, SH, ParisC, PPC, Metag, and UML all
> concluded that letting the interrupt handler use current's stack was a
> terrible idea, and instead have a per-cpu irq stack that gets used
> when the handler is service. Whew!
>
> But for the remaining platforms, such as MIPS, this is still a
> problem. In an effort to work around this in my code, rather than
> having to invoke kmalloc for what should be stack-based variables, I
> was thinking I'd just disable preemption for those functions that use
> a lot of stack, so that stack-hungry softirq handlers don't crush it.
> This is generally unsatisfactory, so I don't want to do this
> unconditionally. Instead, I'd like to do some cludge such as:
>
>      #ifndef CONFIG_HAVE_SEPARATE_IRQ_STACK
>      preempt_disable();
>      #endif
>
>      some_func_that_uses_lots_of_stack();
>
>      #ifndef CONFIG_HAVE_SEPARATE_IRQ_STACK
>      preempt_enable();
>      #endif
>
> However, for this to work, I actual need that config variable. Would
> you accept a patch that adds this config variable to the relavent
> platforms? If not, do you have a better solution for me (which doesn't
> involve using kmalloc or choosing a different crypto primitive)?
>
> Thanks,
> Jason
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
