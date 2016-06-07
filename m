Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D22EC6B025E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 08:48:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so33147465wme.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:48:22 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id r75si25007634wmg.31.2016.06.07.05.48.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Jun 2016 05:48:21 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Tue, 07 Jun 2016 14:19:14 +0200
MIME-Version: 1.0
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/3] Add the latent_entropy gcc plugin
Reply-to: pageexec@freemail.hu
Message-ID: <5756BBC2.3735.D63200E@pageexec.freemail.hu>
In-reply-to: <20160606231319.GC7057@thunk.org>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>, <5755CF44.24670.9C7568D@pageexec.freemail.hu>, <20160606231319.GC7057@thunk.org>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: kernel-hardening@lists.openwall.com, David Brown <david.brown@linaro.org>, emese Revfy <re.emese@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

On 6 Jun 2016 at 19:13, Theodore Ts'o wrote:

> On Mon, Jun 06, 2016 at 09:30:12PM +0200, PaX Team wrote:
> > 
> > what matters for latent entropy is not the actual values fed into the entropy
> > pool (they're effectively compile time constants save for runtime data dependent
> > computations) but the precise sequence of them. interrupts stir this sequence
> > and thus extract entropy. perhaps as a small example imagine that an uninterrupted
> > kernel boot sequence feeds these values into the entropy pool:
> >   A B C
> > 
> > now imagine that a single interrupt can occur around any one of these values:
> >   I A B C
> >   A I B C
> >   A B I C
> >   A B C I
> > 
> > this way we can obtain 4 different final pool states that translate into up
> > to 2 bits of latent entropy (depends on how probable each sequence is). note
> > that this works regardless whether the underlying hardware has a high resolution
> > timer whose values the interrupt handler would feed into the pool.
> 
> Right, but if it's only about interrupts,

(i believe that) latent entropy is found in more than just interrupt timing, there're
also data dependent computations that can have entropy, either on a single system or
across a population of them.

> we're doing this already inside modern Linux kernels.  On every single
> interrupt we are mixing into a per-CPU "fast mix" pool the IP from the
> interrupt registers. 

i agree that sampling the kernel register state can have entropy (the plugin
already extracts the current stack pointer) but i'm much less sure about
userland (at least i see no dependence on !user_mode(...)) since an attacker
could feed no entropy into the pool but still get it credited.

cheers,
 PaX Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
