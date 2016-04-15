Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE946B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 18:00:33 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so105860274pad.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 15:00:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ah8si5990120pad.148.2016.04.15.15.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 15:00:27 -0700 (PDT)
Date: Fri, 15 Apr 2016 15:00:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: SLAB freelist randomization
Message-Id: <20160415150026.65abbdd5b2ef741cd070c769@linux-foundation.org>
In-Reply-To: <1460741159-51752-1-git-send-email-thgarnie@google.com>
References: <1460741159-51752-1-git-send-email-thgarnie@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, gthelen@google.com, labbott@fedoraproject.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.orgKees Cook <keescook@chromium.org>

On Fri, 15 Apr 2016 10:25:59 -0700 Thomas Garnier <thgarnie@google.com> wrote:

> Provide an optional config (CONFIG_FREELIST_RANDOM) to randomize the
> SLAB freelist. The list is randomized during initialization of a new set
> of pages. The order on different freelist sizes is pre-computed at boot
> for performance. This security feature reduces the predictability of the
> kernel SLAB allocator against heap overflows rendering attacks much less
> stable.
> 
> For example this attack against SLUB (also applicable against SLAB)
> would be affected:
> https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow/
> 
> Also, since v4.6 the freelist was moved at the end of the SLAB. It means
> a controllable heap is opened to new attacks not yet publicly discussed.
> A kernel heap overflow can be transformed to multiple use-after-free.
> This feature makes this type of attack harder too.
> 
> The config option name is not specific to the SLAB as this approach will
> be extended to other allocators like SLUB.
> 
> Performance results highlighted no major changes:
>
> ...
>
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1229,6 +1229,61 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
>  	}
>  }
>  
> +#ifdef CONFIG_FREELIST_RANDOM
> +/*
> + * Master lists are pre-computed random lists
> + * Lists of different sizes are used to optimize performance on different
> + * SLAB object sizes per pages.

"object sizes per pages" doesn't make sense.  "object-per-page counts"?
"object sizes"?

> + */
> +static freelist_idx_t master_list_2[2];
> +static freelist_idx_t master_list_4[4];
> +static freelist_idx_t master_list_8[8];
> +static freelist_idx_t master_list_16[16];
> +static freelist_idx_t master_list_32[32];
> +static freelist_idx_t master_list_64[64];
> +static freelist_idx_t master_list_128[128];
> +static freelist_idx_t master_list_256[256];
> +static struct m_list {
> +	size_t count;
> +	freelist_idx_t *list;
> +} master_lists[] = {
> +	{ ARRAY_SIZE(master_list_2), master_list_2 },
> +	{ ARRAY_SIZE(master_list_4), master_list_4 },
> +	{ ARRAY_SIZE(master_list_8), master_list_8 },
> +	{ ARRAY_SIZE(master_list_16), master_list_16 },
> +	{ ARRAY_SIZE(master_list_32), master_list_32 },
> +	{ ARRAY_SIZE(master_list_64), master_list_64 },
> +	{ ARRAY_SIZE(master_list_128), master_list_128 },
> +	{ ARRAY_SIZE(master_list_256), master_list_256 },
> +};
> +
> +static void __init freelist_random_init(void)
> +{
> +	unsigned int seed;
> +	size_t z, i, rand;
> +	struct rnd_state slab_rand;
> +
> +	get_random_bytes_arch(&seed, sizeof(seed));

Using get_random_bytes_arch() seems a rather poor decision.  There are
the caveats described at the get_random_bytes_arch() definition site,
and the minor issue that get_random_bytes_arch() only actually works on
x86 and powerpc!

This is run-once __init code, so rather than adding the kernel's very
first get_random_bytes_arch() call site(!), why not stick with good old
get_random_bytes()?

If there's something I'm missing, please at least place a very good
comment here explaining the reasoning.

> +	prandom_seed_state(&slab_rand, seed);
> +
> +	for (z = 0; z < ARRAY_SIZE(master_lists); z++) {
> +		for (i = 0; i < master_lists[z].count; i++)
> +			master_lists[z].list[i] = i;
> +
> +		/* Fisher-Yates shuffle */
> +		for (i = master_lists[z].count - 1; i > 0; i--) {
> +			rand = prandom_u32_state(&slab_rand);
> +			rand %= (i + 1);
> +			swap(master_lists[z].list[i],
> +				master_lists[z].list[rand]);
> +		}
> +	}
> +}
> +#else
> +static inline void __init freelist_random_init(void) { }
> +#endif /* CONFIG_FREELIST_RANDOM */
> +
> +
>  /*
>   * Initialisation.  Called after the page allocator have been initialised and
>   * before smp_init().
>
> ...
>
> @@ -2442,6 +2499,101 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
>  #endif
>  }
>  
> +#ifdef CONFIG_FREELIST_RANDOM
> +enum master_type {
> +	match,
> +	less,
> +	more
> +};
> +
> +struct random_mng {

I can't work out what "mng" means in this code.

> +	unsigned int padding;
> +	unsigned int pos;
> +	unsigned int count;
> +	struct m_list master_list;
> +	unsigned int master_count;
> +	enum master_type type;
> +};

It would be useful to document the above struct.  Skilfully documenting
the data structures is key to making the code understandable.

> +static void random_mng_initialize(struct random_mng *mng, unsigned int count)
> +{
> +	unsigned int idx;
> +	const unsigned int last_idx = ARRAY_SIZE(master_lists) - 1;
> +
> +	memset(mng, 0, sizeof(*mng));
> +	mng->count = count;
> +	mng->pos = 0;
> +	/* count is >= 2 */
> +	idx = ilog2(count) - 1;

slab.c should now include log2.h.

> +	if (idx >= last_idx)
> +		idx = last_idx;
> +	else if (roundup_pow_of_two(idx + 1) != count)
> +		idx++;
> +	mng->master_list = master_lists[idx];
> +	if (mng->master_list.count == mng->count)
> +		mng->type = match;
> +	else if (mng->master_list.count > mng->count)
> +		mng->type = more;
> +	else
> +		mng->type = less;
> +}
> +
> +static freelist_idx_t get_next_entry(struct random_mng *mng)
> +{
> +	if (mng->type == less && mng->pos == mng->master_list.count) {
> +		mng->padding += mng->pos;
> +		mng->pos = 0;
> +	}
> +	BUG_ON(mng->pos >= mng->master_list.count);
> +	return mng->master_list.list[mng->pos++];
> +}
> +
> +static freelist_idx_t next_random_slot(struct random_mng *mng)
> +{
> +	freelist_idx_t cur, entry;
> +
> +	entry = get_next_entry(mng);
> +
> +	if (mng->type != match) {
> +		while ((entry + mng->padding) >= mng->count)
> +			entry = get_next_entry(mng);
> +		cur = entry + mng->padding;
> +		BUG_ON(cur >= mng->count);
> +	} else {
> +		cur = entry;
> +	}
> +
> +	return cur;
> +}
> +
> +static void shuffle_freelist(struct kmem_cache *cachep, struct page *page,
> +			     unsigned int count)
> +{
> +	unsigned int i;
> +	struct random_mng mng;
> +
> +	if (count < 2) {
> +		for (i = 0; i < count; i++)
> +			set_free_obj(page, i, i);
> +		return;
> +	}
> +
> +	/* Last chunk is used already in this case */
> +	if (OBJFREELIST_SLAB(cachep))
> +		count--;
> +
> +	random_mng_initialize(&mng, count);
> +	for (i = 0; i < count; i++)
> +		set_free_obj(page, i, next_random_slot(&mng));
> +
> +	if (OBJFREELIST_SLAB(cachep))
> +		set_free_obj(page, i, i);
> +}

Sorry, but the code is really too light on comments.  Each of the above
functions would benefit from a description of what they do and, most
importantly, why they do it.

Please address these things and let's wait for the slab maintainers
(and perhaps Kees?) to weigh in.

> +#else
> +static inline void shuffle_freelist(struct kmem_cache *cachep,
> +				    struct page *page, unsigned int count) { }
> +#endif /* CONFIG_FREELIST_RANDOM */
> +
>  static void cache_init_objs(struct kmem_cache *cachep,
>  			    struct page *page)
>  {
> @@ -2464,8 +2616,12 @@ static void cache_init_objs(struct kmem_cache *cachep,
>  			kasan_poison_object_data(cachep, objp);
>  		}
>  
> -		set_free_obj(page, i, i);
> +		/* If enabled, initialization is done in shuffle_freelist */
> +		if (!config_enabled(CONFIG_FREELIST_RANDOM))
> +			set_free_obj(page, i, i);
>  	}
> +
> +	shuffle_freelist(cachep, page, cachep->num);
>  }
>  
>  static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
