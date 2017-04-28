Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 333226B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:16:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b28so4941508wrb.2
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 23:16:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s80si4691649wme.160.2017.04.27.23.16.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 23:16:41 -0700 (PDT)
Date: Fri, 28 Apr 2017 08:16:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170428061637.GB8143@dhcp22.suse.cz>
References: <20170404151600.GN15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz>
 <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz>
 <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
 <CAGXu5j+vVn02Vsx5TzWPz3MS7Jow1gi+m3ojwMXrL-w6aaZhtw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+vVn02Vsx5TzWPz3MS7Jow1gi+m3ojwMXrL-w6aaZhtw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 27-04-17 18:11:28, Kees Cook wrote:
> On Tue, Apr 11, 2017 at 7:19 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > I would do something like...
> > ---
> > diff --git a/mm/slab.c b/mm/slab.c
> > index bd63450a9b16..87c99a5e9e18 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -393,10 +393,15 @@ static inline void set_store_user_dirty(struct kmem_cache *cachep) {}
> >  static int slab_max_order = SLAB_MAX_ORDER_LO;
> >  static bool slab_max_order_set __initdata;
> >
> > +static inline struct kmem_cache *page_to_cache(struct page *page)
> > +{
> > +       return page->slab_cache;
> > +}
> > +
> >  static inline struct kmem_cache *virt_to_cache(const void *obj)
> >  {
> >         struct page *page = virt_to_head_page(obj);
> > -       return page->slab_cache;
> > +       return page_to_cache(page);
> >  }
> >
> >  static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
> > @@ -3813,14 +3818,18 @@ void kfree(const void *objp)
> >  {
> >         struct kmem_cache *c;
> >         unsigned long flags;
> > +       struct page *page;
> >
> >         trace_kfree(_RET_IP_, objp);
> >
> >         if (unlikely(ZERO_OR_NULL_PTR(objp)))
> >                 return;
> > +       page = virt_to_head_page(obj);
> > +       if (CHECK_DATA_CORRUPTION(!PageSlab(page)))
> > +               return;
> >         local_irq_save(flags);
> >         kfree_debugcheck(objp);
> > -       c = virt_to_cache(objp);
> > +       c = page_to_cache(page);
> >         debug_check_no_locks_freed(objp, c->object_size);
> >
> >         debug_check_no_obj_freed(objp, c->object_size);
> 
> Sorry for the delay, I've finally had time to look at this again.
> 
> So, this only handles the kfree() case, not the kmem_cache_free() nor
> kmem_cache_free_bulk() cases, so it misses all the non-kmalloc
> allocations (and kfree() ultimately calls down to kmem_cache_free()).
> Similarly, my proposed patch missed the kfree() path. :P

yes

> As I work on a replacement, is the goal to avoid the checks while
> under local_irq_save()? (i.e. I can't just put the check in
> virt_to_cache(), etc.)

You would have to check all callers of virt_to_cache. I would simply
replace BUG_ON(!PageSlab()) in cache_from_obj. kmem_cache_free already
handles NULL cache. kmem_cache_free_bulk and build_detached_freelist can
be made to do so.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
