Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 655746B0036
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 13:11:37 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so3060617wib.1
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 10:11:36 -0700 (PDT)
Received: from mail-we0-x22e.google.com (mail-we0-x22e.google.com [2a00:1450:400c:c03::22e])
        by mx.google.com with ESMTPS id ef3si18265884wic.104.2014.06.27.10.11.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 10:11:35 -0700 (PDT)
Received: by mail-we0-f174.google.com with SMTP id u57so5608183wes.19
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 10:11:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140624160857.ebb638c4c69c1d290f64d01f@linux-foundation.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1401747586-11861-1-git-send-email-ddstreet@ieee.org> <1401747586-11861-4-git-send-email-ddstreet@ieee.org>
 <20140623144614.d4549fa0aecb03b7b8044bc7@linux-foundation.org>
 <CALZtONDKmM8nRv3tqZThc8mC3Dmrxqj7if5-yAeivnfCbfwENw@mail.gmail.com> <20140624160857.ebb638c4c69c1d290f64d01f@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 27 Jun 2014 13:11:15 -0400
Message-ID: <CALZtONDab98oHJsPqHVMxS0aEfMBTYdJFx3p-ODr3Dke_x5m0g@mail.gmail.com>
Subject: Re: [PATCHv4 3/6] mm/zpool: implement common zpool api to zbud/zsmalloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jun 24, 2014 at 7:08 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 24 Jun 2014 11:39:12 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> On Mon, Jun 23, 2014 at 5:46 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>> > On Mon,  2 Jun 2014 18:19:43 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>> >
>> >> Add zpool api.
>> >>
>> >> zpool provides an interface for memory storage, typically of compressed
>> >> memory.  Users can select what backend to use; currently the only
>> >> implementations are zbud, a low density implementation with up to
>> >> two compressed pages per storage page, and zsmalloc, a higher density
>> >> implementation with multiple compressed pages per storage page.
>> >>
>> >> ...
>> >>
>> >> +/**
>> >> + * zpool_create_pool() - Create a new zpool
>> >> + * @type     The type of the zpool to create (e.g. zbud, zsmalloc)
>> >> + * @flags    What GFP flags should be used when the zpool allocates memory.
>> >> + * @ops              The optional ops callback.
>> >> + *
>> >> + * This creates a new zpool of the specified type.  The zpool will use the
>> >> + * given flags when allocating any memory.  If the ops param is NULL, then
>> >> + * the created zpool will not be shrinkable.
>> >> + *
>> >> + * Returns: New zpool on success, NULL on failure.
>> >> + */
>> >> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
>> >> +                     struct zpool_ops *ops);
>> >
>> > It is unconventional to document the API in the .h file.  It's better
>> > to put the documentation where people expect to find it.
>> >
>> > It's irritating for me (for example) because this kernel convention has
>> > permitted me to train my tags system to ignore prototypes in headers.
>> > But if I want to find the zpool_create_pool documentation I will need
>> > to jump through hoops.
>>
>> Got it, I will move it to the .c file.
>>
>> I noticed you pulled these into -mm, do you want me to send follow-on
>> patches for these changes, or actually update the origin patches and
>> resend the patch set?
>
> Full resend, I guess.  I often add things which are
> not-quite-fully-baked to give them a bit of testing, check for
> integration with other changes, etc.
>
>> >
>> >>
>> >> ...
>> >>
>> >> +
>> >> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
>> >> +                     struct zpool_ops *ops)
>> >> +{
>> >> +     struct zpool_driver *driver;
>> >> +     struct zpool *zpool;
>> >> +
>> >> +     pr_info("creating pool type %s\n", type);
>> >> +
>> >> +     spin_lock(&drivers_lock);
>> >> +     driver = zpool_get_driver(type);
>> >> +     spin_unlock(&drivers_lock);
>> >
>> > Racy against unregister.  Can be solved with a standard get/put
>> > refcounting implementation.  Or perhaps a big fat mutex.
>
> Was there a decision here?

What I tried to do, with the final patch in the set, was use module
usage counting combined with function documentation - in
zpool_create_pool() the zpool_get_driver() does try_module_get()
before releasing the spinlock, so if the driver *only* calls
unregister from its module exit function, I think we should be good -
once zpool_create_pool() gets the driver module, the driver won't
enter its exit function and thus won't unregister; and if the driver
module has started its exit function, try_module_get() will return
failure and zpool_create_pool() will return failure.

Now, if we remove the restriction that the driver module can only
unregister from its module exit function, then we would need an
additional refcount (we could use module_refcount() but the module may
have refcounts unrelated to us) and unregister would need a return
value, to indicate failure.  I think the problem I had with that is,
in the driver module's exit function it can't abort if unregister
fails; but with the module refcounting, unregister shouldn't ever fail
in the driver's exit function...

So should I remove the unregister function doc asking to only call
unregister from the module exit function, and add a separate refcount
to the driver get/put functions?  I don't think we need to use a kref,
since we don't want to free the driver once kref == 0, we want to be
able to check in the unregister function if there are any refs, so
just an atomic_t should work.  And we would still need to keep the
module get/put, too, so it would be something like:

  spin_lock(&drivers_lock);
...
  bool got = try_module_get(driver->owner);
  if (got)
    atomic_inc(driver->refs);
  spin_unlock(&drivers_lock);
  return got ? driver : NULL;

with the appropriate atomic_dec in zpool_put_driver(), and unregister
would change to:

int zpool_unregister_driver(struct zpool_driver *driver)
{
  spin_lock(&drivers_lock);
  if (atomic_read(driver->refs) > 0) {
    spin_unlock(&drivers_lock);
    return -EBUSY;
  }
  list_del(&driver->list);
  spin_unlock(&drivers_lock);
  return 0;
}


>
>> >> +void zpool_destroy_pool(struct zpool *zpool)
>> >> +{
>> >> +     pr_info("destroying pool type %s\n", zpool->type);
>> >> +
>> >> +     spin_lock(&pools_lock);
>> >> +     list_del(&zpool->list);
>> >> +     spin_unlock(&pools_lock);
>> >> +     zpool->driver->destroy(zpool->pool);
>> >> +     kfree(zpool);
>> >> +}
>> >
>> > What are the lifecycle rules here?  How do we know that nobody else can
>> > be concurrently using this pool?
>>
>> Well I think with zpools, as well as direct use of zsmalloc and zbud
>> pools, whoever creates a pool is responsible for making sure it's no
>> longer in use before destroying it.
>
> Sounds reasonable.  Perhaps there's some convenient WARN_ON we can put
> in here to check that.

Since zpool's just a passthrough, there's no simple way of it telling
if a pool is in use or not, but warnings could be added to
zbud/zsmalloc's destroy functions.  zs_destroy_pool() already does
check and pr_info() if any non-empty pools are destroyed.

>
>>  I think in most use cases, pool
>> creators won't be sharing their pools, so there should be no issue
>> with concurrent use.  In fact, concurrent pool use it probably a bad
>> idea in general - zsmalloc for example relies on per-cpu data during
>> handle mapping, so concurrent use of a single pool might result in the
>> per-cpu data being overwritten if multiple users of a single pool
>> tried to map and use different handles from the same cpu.
>
> That's all a bit waffly.  Either we support concurrent use or we don't!

I think I got offtrack talking about pool creators and pool users.
zpool, and zbud/zsmalloc, really don't care about *who* is calling
each of their functions.  Only concurrency matters, and most of the
functions are safe for concurrent use, protected internally by
spinlocks, etc in each pool driver (zbud/zsmalloc).  The map/unmap
functions are a notable exception, but the function doc for
zpool_map_handle() clarifies the restrictions for how to call it and
what the implementation may do (hold spinlocks, disable preempt/ints)
and that the caller should call unmap quickly after using the mapped
handle.  And whoever creates the pool will need to also destroy the
pool, or at least handle coordinating who and when the pool is
destroyed (beyond warning, i don't think there is much the pool driver
can do when a non-empty pool is destroyed.  Maybe don't destroy the
pool, but that risks leaking memory if nobody ever uses the pool
again).

I'll review zbud and zsmalloc again to make sure each function is
threadsafe, and state that in each zpool function doc, or make sure to
clarify any restrictions.

Since you already mentioned a few changes, let me get an updated patch
set sent, I'll try to send that by Monday, and we can go from there if
more changes are needed.  Thanks for the review!


>
>> Should some use/sharing restrictions be added to the zpool documentation?
>
> Sure.  And the code if possible.  If a second user tries to use a pool
> which is already in use, that attempt should just fail, with WARN,
> printk, return -EBUSY, whatever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
