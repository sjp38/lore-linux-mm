Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBE96B0266
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:54:20 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id o66so11177603vkd.8
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:54:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s2sor1925837uaa.70.2018.04.16.08.54.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 08:54:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180414224419.GA21830@thunk.org>
References: <20180414195921.GA10437@avx2> <20180414224419.GA21830@thunk.org>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 16 Apr 2018 08:54:17 -0700
Message-ID: <CAGXu5j+qQE-MmpB7xq6z_SsXm9AhJe2QQAEVQnenYD=iLzJqWQ@mail.gmail.com>
Subject: Re: repeatable boot randomness inside KVM guest
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Alexey Dobriyan <adobriyan@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Thomas Garnier <thgarnie@google.com>

On Sat, Apr 14, 2018 at 3:44 PM, Theodore Y. Ts'o <tytso@mit.edu> wrote:
> +linux-mm@kvack.org
> kvm@vger.kernel.org, security@kernel.org moved to bcc
>
> On Sat, Apr 14, 2018 at 10:59:21PM +0300, Alexey Dobriyan wrote:
>> SLAB allocators got CONFIG_SLAB_FREELIST_RANDOM option which randomizes
>> allocation pattern inside a slab:
>>
>>       int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count, gfp_t gfp)
>>       {
>>               ...
>>               /* Get best entropy at this stage of boot */
>>               prandom_seed_state(&state, get_random_long());
>>
>> Then I printed actual random sequences for each kmem cache.
>> Turned out they were all the same for most of the caches and
>> they didn't vary across guest reboots.
>
> The problem is at the super-early state of the boot path, kernel code
> can't allocate memory.  This is something most device drivers kinda
> assume they can do.  :-)
>
> So it means we haven't yet initialized the virtio-rng driver, and it's
> before interrupts have been enabled, so we can't harvest any entropy
> from interrupt timing.  So that's why trying to use virtio-rng didn't
> help.
>
>> The only way to get randomness for SLAB is to enable RDRAND inside guest.
>>
>> Is it KVM bug?
>
> No, it's not a KVM bug.  The fundamental issue is in how the
> CONFIG_SLAB_FREELIST_RANDOM is currently implemented.
>
> What needs to happen is freelist should get randomized much later in
> the boot sequence.  Doing it later will require locking; I don't know
> enough about the slab/slub code to know whether the slab_mutex would
> be sufficient, or some other lock might need to be added.
>
> The other thing I would note that is that using prandom_u32_state() doesn't
> really provide much security.  In fact, if the the goal is to protect
> against a malicious attacker trying to guess what addresses will be
> returned by the slab allocator, I suspect it's much like the security
> patdowns done at airports.  It might protect against a really stupid
> attacker, but it's mostly security theater.
>
> The freelist randomization is only being done once; so it's not like
> performance is really an issue.  It would be much better to just use
> get_random_u32() and be done with it.  I'd drop using prandom_*
> functions in slab.c and slubct and slab_common.c, and just use a
> really random number generator, if the goal is real security as
> opposed to security for show....
>
> (Not that there's necessarily any thing wrong with security theater;
> the US spends over 3 billion dollars a year on security theater.  As
> politicians know, symbolism can be important.  :-)

I've added Thomas Garnier to CC (since he wrote this originally). He
can speak to its position in the boot ordering and the effective
entropy.

-Kees

-- 
Kees Cook
Pixel Security
