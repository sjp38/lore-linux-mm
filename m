Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8915E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 15:22:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e39-v6so339099plb.10
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 12:22:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20-v6sor135887pfh.150.2018.06.19.12.21.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 12:21:57 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Date: Tue, 19 Jun 2018 12:21:39 -0700
Message-Id: <20180619192139.31781-1-shakeelb@google.com>
In-Reply-To: <CAHmME9q7aKGNiYauCjyy6Fu+bryPphEoLEMbAObTJgTrTfS2uw@mail.gmail.com>
References: <CAHmME9q7aKGNiYauCjyy6Fu+bryPphEoLEMbAObTJgTrTfS2uw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A . Donenfeld" <Jason@zx2c4.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

On Tue, Jun 19, 2018 at 8:19 AM Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> On Tue, Jun 19, 2018 at 5:08 PM Shakeel Butt <shakeelb@google.com> wrote:
> > > > Are you using SLAB or SLUB? We stress kernel pretty heavily, but with
> > > > SLAB, and I suspect Shakeel may also be using SLAB. So if you are
> > > > using SLUB, there is significant chance that it's a bug in the SLUB
> > > > part of the change.
> > >
> > > Nice intuition; I am indeed using SLUB rather than SLAB...
> > >
> >
> > Can you try once with SLAB? Just to make sure that it is SLUB specific.
>
> Sorry, I meant to mention that earlier. I tried with SLAB; the crash
> does not occur. This appears to be SLUB-specific.

Jason, can you try the following patch?

---
 mm/slub.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index a3b8467c14af..746cfe4515c2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3673,9 +3673,17 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 
 bool __kmem_cache_empty(struct kmem_cache *s)
 {
+	int cpu;
 	int node;
 	struct kmem_cache_node *n;
 
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+
+		if (c->page || slub_percpu_partial(c))
+			return false;
+	}
+
 	for_each_kmem_cache_node(s, node, n)
 		if (n->nr_partial || slabs_node(s, node))
 			return false;
-- 
2.18.0.rc1.244.gcf134e6275-goog
