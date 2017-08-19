Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 73D1F2802FE
	for <linux-mm@kvack.org>; Sat, 19 Aug 2017 09:16:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w14so879313wrc.3
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 06:16:56 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id l15si1256180wmd.75.2017.08.19.06.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Aug 2017 06:16:54 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170606121418.GM1189@dhcp22.suse.cz>
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
Message-ID: <150314853540.7354.10275185301153477504@mail.alporthouse.com>
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
Date: Sat, 19 Aug 2017 14:15:35 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

Quoting Michal Hocko (2017-06-06 13:14:18)
> On Tue 06-06-17 13:04:36, Chris Wilson wrote:
> > Similar in principle to the treatment of get_user_pages, pages that
> > i915.ko acquires from shmemfs are not immediately reclaimable and so
> > should be excluded from the mm accounting and vmscan until they have
> > been returned to the system via shrink_slab/i915_gem_shrink. By moving
> > the unreclaimable pages off the inactive anon lru, not only should
> > vmscan be improved by avoiding walking unreclaimable pages, but the
> > system should also have a better idea of how much memory it can reclaim
> > at that moment in time.
> =

> That is certainly desirable. Peter has proposed a generic pin_page (or
> similar) API. What happened with it? I think it would be a better
> approach than (ab)using mlock API. I am also not familiar with the i915
> code to be sure that using lock_page is really safe here. I think that
> all we need is to simply move those pages in/out to/from unevictable LRU
> list on pin/unpining.

I just had the opportunity to try this mlock_vma_page() hack on a
borderline swapping system (i.e. lots of vmpressure between i915 buffers
and the buffercache), and marking the i915 pages as unevictable makes a
huge difference in avoiding stalls in direct reclaim across the system.

Reading back over the thread, it seems that the simplest approach going
forward is a small api for managing the pages on the unevictable LRU?

> > Note, however, the interaction with shrink_slab which will move some
> > mlocked pages back to the inactive anon lru.
> > =

> > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> > Cc: Matthew Auld <matthew.auld@intel.com>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > ---
> >  drivers/gpu/drm/i915/i915_gem.c | 17 ++++++++++++++++-
> >  mm/mlock.c                      |  2 ++
> >  2 files changed, 18 insertions(+), 1 deletion(-)
> > =

> > diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i91=
5_gem.c
> > index 8cb811519db1..37a98fbc6a12 100644
> > --- a/drivers/gpu/drm/i915/i915_gem.c
> > +++ b/drivers/gpu/drm/i915/i915_gem.c
> > @@ -2193,6 +2193,9 @@ void __i915_gem_object_truncate(struct drm_i915_g=
em_object *obj)
> >       obj->mm.pages =3D ERR_PTR(-EFAULT);
> >  }
> >  =

> > +extern void mlock_vma_page(struct page *page);
> > +extern unsigned int munlock_vma_page(struct page *page);
> > +
> >  static void
> >  i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
> >                             struct sg_table *pages)
> > @@ -2214,6 +2217,10 @@ i915_gem_object_put_pages_gtt(struct drm_i915_ge=
m_object *obj,
> >               if (obj->mm.madv =3D=3D I915_MADV_WILLNEED)
> >                       mark_page_accessed(page);
> >  =

> > +             lock_page(page);
> > +             munlock_vma_page(page);
> > +             unlock_page(page);
> > +
> >               put_page(page);
> >       }
> >       obj->mm.dirty =3D false;
> > @@ -2412,6 +2419,10 @@ i915_gem_object_get_pages_gtt(struct drm_i915_ge=
m_object *obj)
> >               }
> >               last_pfn =3D page_to_pfn(page);
> >  =

> > +             lock_page(page);
> > +             mlock_vma_page(page);
> > +             unlock_page(page);
> > +
> >               /* Check that the i965g/gm workaround works. */
> >               WARN_ON((gfp & __GFP_DMA32) && (last_pfn >=3D 0x00100000U=
L));
> >       }
> > @@ -2450,8 +2461,12 @@ i915_gem_object_get_pages_gtt(struct drm_i915_ge=
m_object *obj)
> >  err_sg:
> >       sg_mark_end(sg);
> >  err_pages:
> > -     for_each_sgt_page(page, sgt_iter, st)
> > +     for_each_sgt_page(page, sgt_iter, st) {
> > +             lock_page(page);
> > +             munlock_vma_page(page);
> > +             unlock_page(page);
> >               put_page(page);
> > +     }
> >       sg_free_table(st);
> >       kfree(st);
> >  =

> > diff --git a/mm/mlock.c b/mm/mlock.c
> > index b562b5523a65..531d9f8fd033 100644
> > --- a/mm/mlock.c
> > +++ b/mm/mlock.c
> > @@ -94,6 +94,7 @@ void mlock_vma_page(struct page *page)
> >                       putback_lru_page(page);
> >       }
> >  }
> > +EXPORT_SYMBOL_GPL(mlock_vma_page);
> >  =

> >  /*
> >   * Isolate a page from LRU with optional get_page() pin.
> > @@ -211,6 +212,7 @@ unsigned int munlock_vma_page(struct page *page)
> >  out:
> >       return nr_pages - 1;
> >  }
> > +EXPORT_SYMBOL_GPL(munlock_vma_page);
> >  =

> >  /*
> >   * convert get_user_pages() return value to posix mlock() error
> > -- =

> > 2.11.0
> > =

> =

> -- =

> Michal Hocko
> SUSE Labs
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
