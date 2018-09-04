Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDB156B6E22
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 11:17:58 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z44-v6so4382535qtg.5
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 08:17:58 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id k30-v6si571948qvk.74.2018.09.04.08.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Sep 2018 08:17:57 -0700 (PDT)
Date: Tue, 4 Sep 2018 15:17:56 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v6 08/18] khwasan: preassign tags to objects with ctors
 or SLAB_TYPESAFE_BY_RCU
In-Reply-To: <95b5beb7ec13b7e998efe84c9a7a5c1fa49a9fe3.1535462971.git.andreyknvl@google.com>
Message-ID: <01000165a5296020-a205757f-480d-49af-b157-bf5ebb6cf84e-000000@email.amazonses.com>
References: <cover.1535462971.git.andreyknvl@google.com> <95b5beb7ec13b7e998efe84c9a7a5c1fa49a9fe3.1535462971.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-mm@kvack.org

For the slab pieces

Reviewed-by: Christoph Lameter <cl@linux.com>



On Wed, 29 Aug 2018, Andrey Konovalov wrote:

> An object constructor can initialize pointers within this objects based on
> the address of the object. Since the object address might be tagged, we
> need to assign a tag before calling constructor.
>
> The implemented approach is to assign tags to objects with constructors
> when a slab is allocated and call constructors once as usual. The
> downside is that such object would always have the same tag when it is
> reallocated, so we won't catch use-after-frees on it.
>
> Also pressign tags for objects from SLAB_TYPESAFE_BY_RCU caches, since
> they can be validy accessed after having been freed.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/slab.c | 6 +++++-
>  mm/slub.c | 4 ++++
>  2 files changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 6fdca9ec2ea4..3b4227059f2e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -403,7 +403,11 @@ static inline struct kmem_cache *virt_to_cache(const void *obj)
>  static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
>  				 unsigned int idx)
>  {
> -	return page->s_mem + cache->size * idx;
> +	void *obj;
> +
> +	obj = page->s_mem + cache->size * idx;
> +	obj = khwasan_preset_slab_tag(cache, idx, obj);
> +	return obj;
>  }
>
>  /*
> diff --git a/mm/slub.c b/mm/slub.c
> index 4206e1b616e7..086d6558a6b6 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1531,12 +1531,14 @@ static bool shuffle_freelist(struct kmem_cache *s, struct page *page)
>  	/* First entry is used as the base of the freelist */
>  	cur = next_freelist_entry(s, page, &pos, start, page_limit,
>  				freelist_count);
> +	cur = khwasan_preset_slub_tag(s, cur);
>  	page->freelist = cur;
>
>  	for (idx = 1; idx < page->objects; idx++) {
>  		setup_object(s, page, cur);
>  		next = next_freelist_entry(s, page, &pos, start, page_limit,
>  			freelist_count);
> +		next = khwasan_preset_slub_tag(s, next);
>  		set_freepointer(s, cur, next);
>  		cur = next;
>  	}
> @@ -1613,8 +1615,10 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	shuffle = shuffle_freelist(s, page);
>
>  	if (!shuffle) {
> +		start = khwasan_preset_slub_tag(s, start);
>  		for_each_object_idx(p, idx, s, start, page->objects) {
>  			setup_object(s, page, p);
> +			p = khwasan_preset_slub_tag(s, p);
>  			if (likely(idx < page->objects))
>  				set_freepointer(s, p, p + s->size);
>  			else
>
