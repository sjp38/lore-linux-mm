Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB576B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 13:48:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h68so20562018lfh.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 10:48:26 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id cn6si9076012wjb.181.2016.06.09.10.48.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 10:48:24 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Thu, 09 Jun 2016 19:22:29 +0200
MIME-Version: 1.0
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/3] Add the latent_entropy gcc plugin
Reply-to: pageexec@freemail.hu
Message-ID: <5759A5D5.7023.18C58969@pageexec.freemail.hu>
In-reply-to: <20160607135857.GF7057@thunk.org>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>, <5756BBC2.3735.D63200E@pageexec.freemail.hu>, <20160607135857.GF7057@thunk.org>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: kernel-hardening@lists.openwall.com, David Brown <david.brown@linaro.org>, emese Revfy <re.emese@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

On 7 Jun 2016 at 9:58, Theodore Ts'o wrote:

> On Tue, Jun 07, 2016 at 02:19:14PM +0200, PaX Team wrote:
> > (i believe that) latent entropy is found in more than just interrupt timing, there're
> > also data dependent computations that can have entropy, either on a single system or
> > across a population of them.
> 
> It's not clear how much data dependent computations you would have in
> kernel space that's not introduced by interrupts, but there would
> some, I'm sure.

there's plenty of such computations both during boot and later as well. starting
with kernel command line options through parsing firmware provided data to hardware
configurations to processing various queues, lists, trees, file systems, network
packets, etc. as for interrupts specifically, latent entropy can be extracted from
polled devices as well (e.g., i think even modern NICs can be turned into polling
mode under sufficient load as processing packets that way is more efficient).

> > i agree that sampling the kernel register state can have entropy (the plugin
> > already extracts the current stack pointer) but i'm much less sure about
> > userland (at least i see no dependence on !user_mode(...)) since an attacker
> > could feed no entropy into the pool but still get it credited.
> 
> Well, the attacker can't control when the interrupts happen, but it
> could try to burn power by simply having a thread spin in an infinite
> loop ("0: jmp 0"), sure.

yes, that's one obvious way to accomplish it but even normal applications can
behave in a similar way, think about spinning event loops, media decoding, etc
whose sampled insn ptrs may provide less entropy than they get credited for.

> All of this goes into the question of how much entropy we can assume
> can be gathered per interrupt (or in the case of basic block
> instrumentation, per basic block).  IIRC, in the latent_entropy
> patches, the assumption is that zero entropy should be credited,
> correct?

yes, no entropy is credited since i don't know how much there is and i tend to err
on the side of safety which means crediting 0 entropy for latent entropy. of course
the expectation is that it's not actually 0 but to prove any specific value or limit
is beyond my skills at least.

> In the case Linux's current get_interrupt_randomness(), there's a
> reason I'm using a very conservative 1/64th of a bit per interrupt.

i think it's not just per 64 interrupts but also after each elapsed second (i.e.,
whichever condition occurs first), so on an idle system (which i believe is more
likely to occur on exactly those small systems that the referenced paper was concerned
about) the credited entropy could be overestimated.

> In practice, on most modern CPU where we have a cycle counter,

a quick check for get_cycles shows that at least these archs seem to return 0:
arc, avr32, cris, frv, m32r, m68k, xtensa. now you may not think of them as modern,
but they're still used in real life devices. i think that latent entropy is still
an option on them.

cheers,
 PaX Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
