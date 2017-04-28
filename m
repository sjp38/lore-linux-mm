Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61E4E6B02F2
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 21:11:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s69so22410671ioi.11
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 18:11:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 62sor130385ioh.47.2017.04.27.18.11.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Apr 2017 18:11:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170411141956.GP6729@dhcp22.suse.cz>
References: <20170404113022.GC15490@dhcp22.suse.cz> <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
 <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz> <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 27 Apr 2017 18:11:28 -0700
Message-ID: <CAGXu5j+vVn02Vsx5TzWPz3MS7Jow1gi+m3ojwMXrL-w6aaZhtw@mail.gmail.com>
Subject: Re: [PATCH] mm: Add additional consistency check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 11, 2017 at 7:19 AM, Michal Hocko <mhocko@kernel.org> wrote:
> I would do something like...
> ---
> diff --git a/mm/slab.c b/mm/slab.c
> index bd63450a9b16..87c99a5e9e18 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -393,10 +393,15 @@ static inline void set_store_user_dirty(struct kmem_cache *cachep) {}
>  static int slab_max_order = SLAB_MAX_ORDER_LO;
>  static bool slab_max_order_set __initdata;
>
> +static inline struct kmem_cache *page_to_cache(struct page *page)
> +{
> +       return page->slab_cache;
> +}
> +
>  static inline struct kmem_cache *virt_to_cache(const void *obj)
>  {
>         struct page *page = virt_to_head_page(obj);
> -       return page->slab_cache;
> +       return page_to_cache(page);
>  }
>
>  static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
> @@ -3813,14 +3818,18 @@ void kfree(const void *objp)
>  {
>         struct kmem_cache *c;
>         unsigned long flags;
> +       struct page *page;
>
>         trace_kfree(_RET_IP_, objp);
>
>         if (unlikely(ZERO_OR_NULL_PTR(objp)))
>                 return;
> +       page = virt_to_head_page(obj);
> +       if (CHECK_DATA_CORRUPTION(!PageSlab(page)))
> +               return;
>         local_irq_save(flags);
>         kfree_debugcheck(objp);
> -       c = virt_to_cache(objp);
> +       c = page_to_cache(page);
>         debug_check_no_locks_freed(objp, c->object_size);
>
>         debug_check_no_obj_freed(objp, c->object_size);

Sorry for the delay, I've finally had time to look at this again.

So, this only handles the kfree() case, not the kmem_cache_free() nor
kmem_cache_free_bulk() cases, so it misses all the non-kmalloc
allocations (and kfree() ultimately calls down to kmem_cache_free()).
Similarly, my proposed patch missed the kfree() path. :P

As I work on a replacement, is the goal to avoid the checks while
under local_irq_save()? (i.e. I can't just put the check in
virt_to_cache(), etc.)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
