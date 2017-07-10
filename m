Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4950744084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:32:25 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id o7so138734153ite.13
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 08:32:25 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id u9si7094640itc.13.2017.07.10.08.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 08:32:24 -0700 (PDT)
Date: Mon, 10 Jul 2017 10:32:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
In-Reply-To: <CAG_fn=XGns6jtiD253jMaTH8vLpuYNN=son-4+jDRRvc79ky4Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1707101023390.4065@east.gentwo.org>
References: <20170707083408.40410-1-glider@google.com> <20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org> <alpine.DEB.2.20.1707071816560.20454@east.gentwo.org> <CAG_fn=XGns6jtiD253jMaTH8vLpuYNN=son-4+jDRRvc79ky4Q@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 10 Jul 2017, Alexander Potapenko wrote:

> >> Could the slab maintainers please take a look at these and also have a
> >> think about Alexander's READ_ONCE/WRITE_ONCE question?
> >
> > Was I cced on these?
> I've asked Andrew about READ_ONCE privately.

Please post to a mailing list and cc the maintainers?

> Since unfreeze_partials() sees uninitialized value of n->list_lock, I
> was suspecting there's a data race between unfreeze_partials() and
> init_kmem_cache_nodes().

I have not seen the details but I would suspect that this is related to
early boot issues? The list lock is initialized upon slab creation and at
that time no one can get to the kmem_cache structure.

There are a couple of boot time slabs that will temporarily be available.
and released upon boot completion.

> If so, reads and writes to s->node[node] must be acquire/release
> atomics (not actually READ_ONCE/WRITE_ONCE, but
> smp_load_acquire/smp_store_release).

Can we figure the reason for these out before proposing fixes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
