Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 887AC6B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 13:22:16 -0400 (EDT)
Received: by mail-oi0-f41.google.com with SMTP id u20so11157520oif.0
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 10:22:16 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id 1si10926990oia.139.2014.10.12.10.22.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 12 Oct 2014 10:22:15 -0700 (PDT)
Received: by mail-oi0-f47.google.com with SMTP id a141so11301576oig.6
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 10:22:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141011.221510.1574777235900788349.davem@davemloft.net>
References: <20141011.221510.1574777235900788349.davem@davemloft.net>
Date: Mon, 13 Oct 2014 02:22:15 +0900
Message-ID: <CAAmzW4Nrzp8TKurmevqmAV5kVRP2af1wZKqYcYH9RXroTZavpw@mail.gmail.com>
Subject: Re: unaligned accesses in SLAB etc.
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

2014-10-12 11:15 GMT+09:00 David Miller <davem@davemloft.net>:
>
> I'm getting tons of the following on sparc64:
>
> [603965.383447] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> [603965.396987] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
> [603965.410523] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> [603965.424061] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
> [603965.437617] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> [603970.554394] log_unaligned: 333 callbacks suppressed
> [603970.564041] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> [603970.577576] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
> [603970.591122] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> [603970.604669] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
> [603970.618216] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> [603976.515633] log_unaligned: 31 callbacks suppressed
> [603976.525092] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603976.540196] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603976.555308] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603976.570411] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603976.585526] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603982.476424] log_unaligned: 43 callbacks suppressed
> [603982.485881] Kernel unaligned access at TPC[549378] kmem_cache_alloc+0xd8/0x1e0
> [603982.501590] Kernel unaligned access at TPC[5470a8] kmem_cache_free+0xc8/0x200
> [603982.501605] Kernel unaligned access at TPC[549378] kmem_cache_alloc+0xd8/0x1e0
> [603982.530382] Kernel unaligned access at TPC[5470a8] kmem_cache_free+0xc8/0x200
> [603982.544820] Kernel unaligned access at TPC[549378] kmem_cache_alloc+0xd8/0x1e0
> [603987.567130] log_unaligned: 11 callbacks suppressed
> [603987.576582] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603987.591696] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603987.606811] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603987.621904] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
> [603987.637017] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0

Hello,

Could you test below patch?
If it fixes your problem, I will send it with proper description.

Thanks.

---------->8----------------
diff --git a/mm/slab.c b/mm/slab.c
index 154aac8..eb2b2ea 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1992,7 +1992,7 @@ static struct array_cache __percpu *alloc_kmem_cache_cpus(
        struct array_cache __percpu *cpu_cache;

        size = sizeof(void *) * entries + sizeof(struct array_cache);
-       cpu_cache = __alloc_percpu(size, 0);
+       cpu_cache = __alloc_percpu(size, sizeof(void *));

        if (!cpu_cache)
                return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
