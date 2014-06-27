Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 776B56B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 15:17:55 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so4730329pde.17
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 12:17:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ek4si15007730pbc.5.2014.06.27.12.17.54
        for <linux-mm@kvack.org>;
        Fri, 27 Jun 2014 12:17:54 -0700 (PDT)
Date: Fri, 27 Jun 2014 12:17:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4 3/6] mm/zpool: implement common zpool api to
 zbud/zsmalloc
Message-Id: <20140627121752.21c559c3404d665adbaa5b23@linux-foundation.org>
In-Reply-To: <CALZtONDab98oHJsPqHVMxS0aEfMBTYdJFx3p-ODr3Dke_x5m0g@mail.gmail.com>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-4-git-send-email-ddstreet@ieee.org>
	<20140623144614.d4549fa0aecb03b7b8044bc7@linux-foundation.org>
	<CALZtONDKmM8nRv3tqZThc8mC3Dmrxqj7if5-yAeivnfCbfwENw@mail.gmail.com>
	<20140624160857.ebb638c4c69c1d290f64d01f@linux-foundation.org>
	<CALZtONDab98oHJsPqHVMxS0aEfMBTYdJFx3p-ODr3Dke_x5m0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, 27 Jun 2014 13:11:15 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> >> >> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
> >> >> +                     struct zpool_ops *ops)
> >> >> +{
> >> >> +     struct zpool_driver *driver;
> >> >> +     struct zpool *zpool;
> >> >> +
> >> >> +     pr_info("creating pool type %s\n", type);
> >> >> +
> >> >> +     spin_lock(&drivers_lock);
> >> >> +     driver = zpool_get_driver(type);
> >> >> +     spin_unlock(&drivers_lock);
> >> >
> >> > Racy against unregister.  Can be solved with a standard get/put
> >> > refcounting implementation.  Or perhaps a big fat mutex.
> >
> > Was there a decision here?
> 
> What I tried to do, with the final patch in the set, was use module
> usage counting combined with function documentation - in
> zpool_create_pool() the zpool_get_driver() does try_module_get()
> before releasing the spinlock, so if the driver *only* calls
> unregister from its module exit function, I think we should be good -
> once zpool_create_pool() gets the driver module, the driver won't
> enter its exit function and thus won't unregister; and if the driver
> module has started its exit function, try_module_get() will return
> failure and zpool_create_pool() will return failure.
> 
> Now, if we remove the restriction that the driver module can only
> unregister from its module exit function, then we would need an
> additional refcount (we could use module_refcount() but the module may
> have refcounts unrelated to us) and unregister would need a return
> value, to indicate failure.  I think the problem I had with that is,
> in the driver module's exit function it can't abort if unregister
> fails; but with the module refcounting, unregister shouldn't ever fail
> in the driver's exit function...
> 
> So should I remove the unregister function doc asking to only call
> unregister from the module exit function, and add a separate refcount
> to the driver get/put functions?  I don't think we need to use a kref,
> since we don't want to free the driver once kref == 0, we want to be
> able to check in the unregister function if there are any refs, so
> just an atomic_t should work.  And we would still need to keep the
> module get/put, too, so it would be something like:

I'm not sure I understood all that.  But I don't want to understand it
in this context!  Readers should be able to gather all this from
looking at the code.

>   spin_lock(&drivers_lock);
> ...
>   bool got = try_module_get(driver->owner);
>   if (got)
>     atomic_inc(driver->refs);
>   spin_unlock(&drivers_lock);
>   return got ? driver : NULL;
> 
> with the appropriate atomic_dec in zpool_put_driver(), and unregister
> would change to:
> 
> int zpool_unregister_driver(struct zpool_driver *driver)
> {
>   spin_lock(&drivers_lock);
>   if (atomic_read(driver->refs) > 0) {
>     spin_unlock(&drivers_lock);
>     return -EBUSY;
>   }
>   list_del(&driver->list);
>   spin_unlock(&drivers_lock);
>   return 0;
> }

It sounds like that will work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
