Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7239B6B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 19:09:00 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so936601iec.37
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 16:09:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id v8si2878006icb.3.2014.06.24.16.08.59
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 16:08:59 -0700 (PDT)
Date: Tue, 24 Jun 2014 16:08:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4 3/6] mm/zpool: implement common zpool api to
 zbud/zsmalloc
Message-Id: <20140624160857.ebb638c4c69c1d290f64d01f@linux-foundation.org>
In-Reply-To: <CALZtONDKmM8nRv3tqZThc8mC3Dmrxqj7if5-yAeivnfCbfwENw@mail.gmail.com>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-4-git-send-email-ddstreet@ieee.org>
	<20140623144614.d4549fa0aecb03b7b8044bc7@linux-foundation.org>
	<CALZtONDKmM8nRv3tqZThc8mC3Dmrxqj7if5-yAeivnfCbfwENw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, 24 Jun 2014 11:39:12 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> On Mon, Jun 23, 2014 at 5:46 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Mon,  2 Jun 2014 18:19:43 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
> >
> >> Add zpool api.
> >>
> >> zpool provides an interface for memory storage, typically of compressed
> >> memory.  Users can select what backend to use; currently the only
> >> implementations are zbud, a low density implementation with up to
> >> two compressed pages per storage page, and zsmalloc, a higher density
> >> implementation with multiple compressed pages per storage page.
> >>
> >> ...
> >>
> >> +/**
> >> + * zpool_create_pool() - Create a new zpool
> >> + * @type     The type of the zpool to create (e.g. zbud, zsmalloc)
> >> + * @flags    What GFP flags should be used when the zpool allocates memory.
> >> + * @ops              The optional ops callback.
> >> + *
> >> + * This creates a new zpool of the specified type.  The zpool will use the
> >> + * given flags when allocating any memory.  If the ops param is NULL, then
> >> + * the created zpool will not be shrinkable.
> >> + *
> >> + * Returns: New zpool on success, NULL on failure.
> >> + */
> >> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
> >> +                     struct zpool_ops *ops);
> >
> > It is unconventional to document the API in the .h file.  It's better
> > to put the documentation where people expect to find it.
> >
> > It's irritating for me (for example) because this kernel convention has
> > permitted me to train my tags system to ignore prototypes in headers.
> > But if I want to find the zpool_create_pool documentation I will need
> > to jump through hoops.
> 
> Got it, I will move it to the .c file.
> 
> I noticed you pulled these into -mm, do you want me to send follow-on
> patches for these changes, or actually update the origin patches and
> resend the patch set?

Full resend, I guess.  I often add things which are
not-quite-fully-baked to give them a bit of testing, check for
integration with other changes, etc.

> >
> >>
> >> ...
> >>
> >> +
> >> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
> >> +                     struct zpool_ops *ops)
> >> +{
> >> +     struct zpool_driver *driver;
> >> +     struct zpool *zpool;
> >> +
> >> +     pr_info("creating pool type %s\n", type);
> >> +
> >> +     spin_lock(&drivers_lock);
> >> +     driver = zpool_get_driver(type);
> >> +     spin_unlock(&drivers_lock);
> >
> > Racy against unregister.  Can be solved with a standard get/put
> > refcounting implementation.  Or perhaps a big fat mutex.

Was there a decision here?

> >> +void zpool_destroy_pool(struct zpool *zpool)
> >> +{
> >> +     pr_info("destroying pool type %s\n", zpool->type);
> >> +
> >> +     spin_lock(&pools_lock);
> >> +     list_del(&zpool->list);
> >> +     spin_unlock(&pools_lock);
> >> +     zpool->driver->destroy(zpool->pool);
> >> +     kfree(zpool);
> >> +}
> >
> > What are the lifecycle rules here?  How do we know that nobody else can
> > be concurrently using this pool?
> 
> Well I think with zpools, as well as direct use of zsmalloc and zbud
> pools, whoever creates a pool is responsible for making sure it's no
> longer in use before destroying it.

Sounds reasonable.  Perhaps there's some convenient WARN_ON we can put
in here to check that.

>  I think in most use cases, pool
> creators won't be sharing their pools, so there should be no issue
> with concurrent use.  In fact, concurrent pool use it probably a bad
> idea in general - zsmalloc for example relies on per-cpu data during
> handle mapping, so concurrent use of a single pool might result in the
> per-cpu data being overwritten if multiple users of a single pool
> tried to map and use different handles from the same cpu.

That's all a bit waffly.  Either we support concurrent use or we don't!

> Should some use/sharing restrictions be added to the zpool documentation?

Sure.  And the code if possible.  If a second user tries to use a pool
which is already in use, that attempt should just fail, with WARN,
printk, return -EBUSY, whatever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
