Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 578336B0003
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 20:03:26 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v6-v6so24478232ywg.10
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 17:03:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10-v6sor3862449ywc.168.2018.08.13.17.03.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 17:03:25 -0700 (PDT)
Received: from mail-yw1-f43.google.com (mail-yw1-f43.google.com. [209.85.161.43])
        by smtp.gmail.com with ESMTPSA id b11-v6sm17029356ywa.46.2018.08.13.17.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 17:03:22 -0700 (PDT)
Received: by mail-yw1-f43.google.com with SMTP id r184-v6so14956516ywg.6
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 17:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180809085245.22448-1-vbabka@suse.cz>
References: <cc93080f-2d22-71fe-a1fb-d55d1fcc2441@suse.cz> <20180809085245.22448-1-vbabka@suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 13 Aug 2018 17:03:20 -0700
Message-ID: <CAGXu5jKbiETGSV+Z6HNJwTMzGWFhFxSzPSrjmbGuhJ701ep2kA@mail.gmail.com>
Subject: Re: [PATCH] mm, slub: restore the original intention of prefetch_freepointer()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>, Alex Deucher <alexander.deucher@amd.com>, Daniel Micay <danielmicay@gmail.com>, Eric Dumazet <edumazet@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Aug 9, 2018 at 1:52 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> In SLUB, prefetch_freepointer() is used when allocating an object from cache's
> freelist, to make sure the next object in the list is cache-hot, since it's
> probable it will be allocated soon.
>
> Commit 2482ddec670f ("mm: add SLUB free list pointer obfuscation") has
> unintentionally changed the prefetch in a way where the prefetch is turned to a
> real fetch, and only the next->next pointer is prefetched. In case there is not
> a stream of allocations that would benefit from prefetching, the extra real
> fetch might add a useless cache miss to the allocation. Restore the previous
> behavior.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Daniel Micay <danielmicay@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
> While I don't expect this to be causing the bug at hand, it's worth fixing.
> For the bug it might mean that the page fault moves elsewhere.
>
>  mm/slub.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 51258eff4178..ce2b9e5cea77 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -271,8 +271,7 @@ static inline void *get_freepointer(struct kmem_cache *s, void *object)
>
>  static void prefetch_freepointer(const struct kmem_cache *s, void *object)
>  {
> -       if (object)
> -               prefetch(freelist_dereference(s, object + s->offset));
> +       prefetch(object + s->offset);

Ah -- gotcha. I think I misunderstood the purpose here. You're not
prefetching what is being pointed at, you're literally prefetching
what is stored there. That wouldn't require dereferencing the freelist
pointer, no.

Thanks!

Acked-by: Kees Cook <keescook@chromium.org>

>  }
>
>  static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
> --
> 2.18.0
>



-- 
Kees Cook
Pixel Security
