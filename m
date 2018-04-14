Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08A116B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 18:44:23 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id k32so1670572ywh.21
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 15:44:22 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id b6si1058940ywl.250.2018.04.14.15.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 15:44:21 -0700 (PDT)
Date: Sat, 14 Apr 2018 18:44:19 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: repeatable boot randomness inside KVM guest
Message-ID: <20180414224419.GA21830@thunk.org>
References: <20180414195921.GA10437@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414195921.GA10437@avx2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

+linux-mm@kvack.org
kvm@vger.kernel.org, security@kernel.org moved to bcc

On Sat, Apr 14, 2018 at 10:59:21PM +0300, Alexey Dobriyan wrote:
> SLAB allocators got CONFIG_SLAB_FREELIST_RANDOM option which randomizes
> allocation pattern inside a slab:
> 
> 	int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count, gfp_t gfp)
> 	{
> 		...
> 		/* Get best entropy at this stage of boot */
> 	        prandom_seed_state(&state, get_random_long());
>
> Then I printed actual random sequences for each kmem cache.
> Turned out they were all the same for most of the caches and
> they didn't vary across guest reboots.

The problem is at the super-early state of the boot path, kernel code
can't allocate memory.  This is something most device drivers kinda
assume they can do.  :-)

So it means we haven't yet initialized the virtio-rng driver, and it's
before interrupts have been enabled, so we can't harvest any entropy
from interrupt timing.  So that's why trying to use virtio-rng didn't
help.

> The only way to get randomness for SLAB is to enable RDRAND inside guest.
> 
> Is it KVM bug?

No, it's not a KVM bug.  The fundamental issue is in how the
CONFIG_SLAB_FREELIST_RANDOM is currently implemented.

What needs to happen is freelist should get randomized much later in
the boot sequence.  Doing it later will require locking; I don't know
enough about the slab/slub code to know whether the slab_mutex would
be sufficient, or some other lock might need to be added.

The other thing I would note that is that using prandom_u32_state() doesn't
really provide much security.  In fact, if the the goal is to protect
against a malicious attacker trying to guess what addresses will be
returned by the slab allocator, I suspect it's much like the security
patdowns done at airports.  It might protect against a really stupid
attacker, but it's mostly security theater.

The freelist randomization is only being done once; so it's not like
performance is really an issue.  It would be much better to just use
get_random_u32() and be done with it.  I'd drop using prandom_*
functions in slab.c and slubct and slab_common.c, and just use a
really random number generator, if the goal is real security as
opposed to security for show....

(Not that there's necessarily any thing wrong with security theater;
the US spends over 3 billion dollars a year on security theater.  As
politicians know, symbolism can be important.  :-)

Cheers,

					- Ted
