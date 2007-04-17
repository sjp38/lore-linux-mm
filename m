Received: by ug-out-1314.google.com with SMTP id s2so139736uge
        for <linux-mm@kvack.org>; Tue, 17 Apr 2007 06:22:48 -0700 (PDT)
Message-ID: <84144f020704170622h2b16f0f6m47ffdbb3b5686758@mail.gmail.com>
Date: Tue, 17 Apr 2007 16:22:48 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M
In-Reply-To: <4624C3C1.9040709@sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4624C3C1.9040709@sw.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@sw.ru>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 4/17/07, Pavel Emelianov <xemul@sw.ru> wrote:
> The out_of_memory() function and SysRq-M handler call
> show_mem() to show the current memory usage state.
>
> This is also helpful to see which slabs are the largest
> in the system.

Makes sense.

On 4/17/07, Pavel Emelianov <xemul@sw.ru> wrote:
> diff --git a/mm/slab.c b/mm/slab.c
> index 21b3c61..9a5829a 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -749,6 +749,7 @@ static inline void init_lock_keys(void)
>   * 2. Protect sanity of cpu_online_map against cpu hotplug events
>   */
>  static DEFINE_MUTEX(cache_chain_mutex);
> +static DEFINE_SPINLOCK(cache_chain_lock);

So, now we have two locks protecting cache_chain? Please explain why
you can't use the mutex.

> +static unsigned long get_cache_size(struct kmem_cache *cachep)
> +{
> +       unsigned long slabs;
> +       struct kmem_list3 *l3;
> +       struct list_head *lh;
> +       int node;
> +
> +       slabs = 0;
> +
> +       for_each_online_node (node) {
> +               l3 = cachep->nodelists[node];
> +               if (l3 == NULL)
> +                       continue;
> +
> +               spin_lock(&l3->list_lock);
> +               list_for_each (lh, &l3->slabs_full)
> +                       slabs++;
> +               list_for_each (lh, &l3->slabs_partial)
> +                       slabs++;
> +               list_for_each (lh, &l3->slabs_free)
> +                       slabs++;
> +               spin_unlock(&l3->list_lock);
> +       }
> +
> +       return slabs * ((PAGE_SIZE << cachep->gfporder) +
> +               (OFF_SLAB(cachep) ? cachep->slabp_cache->buffer_size : 0));
> +}

Considering you're doing this at out_of_memory() time, wouldn't it
make more sense to add a ->nr_pages to struct kmem_cache and do the
tracking in kmem_getpages/kmem_freepages?

I would also drop the OFF_SLAB bits because it really doesn't matter
that much for your purposes. Besides, you're already per-node and
per-CPU caches here which attribute to much more memory on NUMA setups
for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
