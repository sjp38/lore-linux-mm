Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2D66B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:34:28 -0400 (EDT)
Received: by wijp15 with SMTP id p15so68484601wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:34:27 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id i10si19923089wix.56.2015.08.24.00.34.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 00:34:26 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so63069221wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:34:26 -0700 (PDT)
Date: Mon, 24 Aug 2015 09:34:22 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 3/3 v4] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150824073422.GC13082@gmail.com>
References: <20150823081750.GA28349@gmail.com>
 <20150824010403.27903.qmail@ns.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824010403.27903.qmail@ns.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


* George Spelvin <linux@horizon.com> wrote:

> First, an actual, albeit minor, bug: initializing both vmap_info_gen
> and vmap_info_cache_gen to 0 marks the cache as valid, which it's not.

Ha! :-) Fixed.

> vmap_info_gen should be initialized to 1 to force an initial
> cache update.

Yeah.

> Second, I don't see why you need a 64-bit counter.  Seqlocks consider
> 32 bits (31 bits, actually, the lsbit means "update in progress") quite
> a strong enough guarantee.

Just out of general paranoia - but you are right, and this would lower the 
overhead on 32-bit SMP platforms a bit, plus it avoids 64-bit word tearing 
artifacts on 32 bit platforms as well.

I modified it to u32.

> Third, it seems as though vmap_info_cache_gen is basically a duplicate
> of vmap_info_lock.sequence.  It should be possible to make one variable
> serve both purposes.

Correct, I alluded to that in my description:

> > Note that there's an even simpler variant possible I think: we could use just 
> > the two generation counters and barriers to remove the seqlock.

> You just need a kludge to handle the case of multiple vamp_info updates
> between cache updates.
> 
> There are two simple ones:
> 
> 1) Avoid bumping vmap_info_gen unnecessarily.  In vmap_unlock(), do
> 	vmap_info_gen = (vmap_info_lock.sequence | 1) + 1;
> 2) - Make vmap_info_gen a seqcount_t
>    - In vmap_unlock(), do write_seqcount_barrier(&vmap_info_gen)
>    - In get_vmalloc_info, inside the seqlock critical section, do
>      vmap_info_lock.seqcount.sequence = vmap_info_gen.sequence - 1;
>      (Using the vmap_info_gen.sequence read while validating the
>      cache in the first place.)
> 
> I should try to write an actual patch illustrating this.

So I think something like the patch below is even simpler than trying to kludge 
generation counter semantics into seqcounts.

I used two generation counters and a spinlock. The fast path is completely 
lockless and lightweight on modern SMP platforms. (where smp_rmb() is a no-op or 
very cheap.)

There's not even a seqlock retry loop, instead an invalid cache causes us to fall 
back to the old behavior - and the freshest result is guaranteed to end up in the 
cache.

The linecount got a bit larger: but half of it is comments.

Note that the generation counters are signed integers so that this comparison can 
be done:

+       if (gen-vmap_info_cache_gen > 0) {

Thanks,

	Ingo

======================>
