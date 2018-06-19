Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1B86B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 17:54:17 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x16-v6so967292qto.20
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 14:54:17 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id i49-v6si813866qtf.45.2018.06.19.14.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 14:54:15 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id c2dcb276
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 21:48:14 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id ae188b33 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 21:48:14 +0000 (UTC)
Received: by mail-oi0-f42.google.com with SMTP id t133-v6so1153494oif.10
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 14:54:09 -0700 (PDT)
MIME-Version: 1.0
References: <20180619213352.71740-1-shakeelb@google.com>
In-Reply-To: <20180619213352.71740-1-shakeelb@google.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 23:53:57 +0200
Message-ID: <CAHmME9pUoXod3pC4g+HLYUbCafj=1_53qHqu9ScB+NtJ2zpwqA@mail.gmail.com>
Subject: Re: [PATCH] slub: fix __kmem_cache_empty for !CONFIG_SLUB_DEBUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue, Jun 19, 2018 at 11:34 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
> allocated per node for a kmem_cache. Thus, slabs_node() in
> __kmem_cache_empty() will always return 0. So, in such situation, it is
> required to check per-cpu slabs to make sure if a kmem_cache is empty or
> not.
>
> Please note that __kmem_cache_shutdown() and __kmem_cache_shrink() are
> not affected by !CONFIG_SLUB_DEBUG as they call flush_all() to clear
> per-cpu slabs.
>
> Fixes: f9e13c0a5a33 ("slab, slub: skip unnecessary kasan_cache_shutdown()")
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Reported-by: Jason A . Donenfeld <Jason@zx2c4.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <stable@vger.kernel.org>
> ---
>  mm/slub.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index a3b8467c14af..731c02b371ae 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3673,9 +3673,23 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
>
>  bool __kmem_cache_empty(struct kmem_cache *s)
>  {
> -       int node;
> +       int cpu, node;
>         struct kmem_cache_node *n;
>
> +       /*
> +        * slabs_node will always be 0 for !CONFIG_SLUB_DEBUG. So, manually
> +        * check slabs for all cpus.
> +        */
> +       if (!IS_ENABLED(CONFIG_SLUB_DEBUG)) {
> +               for_each_online_cpu(cpu) {
> +                       struct kmem_cache_cpu *c;
> +
> +                       c = per_cpu_ptr(s->cpu_slab, cpu);
> +                       if (c->page || slub_percpu_partial(c))
> +                               return false;
> +               }
> +       }
> +
>         for_each_kmem_cache_node(s, node, n)
>                 if (n->nr_partial || slabs_node(s, node))
>                         return false;
> --
> 2.18.0.rc1.244.gcf134e6275-goog
>

I can confirm that this fixes the test case on build.wireguard.com.
