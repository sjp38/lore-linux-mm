Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 797406B051D
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 10:35:59 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d16-v6so15243534wre.11
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 07:35:59 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id y12-v6si800317wrs.372.2018.11.07.07.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 07:35:57 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20181106101211.d2e4857aa36ea8ffbd870d2f@linux-foundation.org>
References: <20181106093100.71829-1-vovoy@chromium.org>
 <20181106132324.17390-1-chris@chris-wilson.co.uk>
 <20181106101211.d2e4857aa36ea8ffbd870d2f@linux-foundation.org>
Message-ID: <154160489128.4321.4951578054574913878@skylake-alporthouse-com>
Subject: Re: [PATCH v7] mm, drm/i915: mark pinned shmemfs pages as unevictable
Date: Wed, 07 Nov 2018 15:34:51 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kuo-Hsin Yang <vovoy@chromium.org>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>

Quoting Andrew Morton (2018-11-06 18:12:11)
> On Tue,  6 Nov 2018 13:23:24 +0000 Chris Wilson <chris@chris-wilson.co.uk=
> wrote:
> =

> > From: Kuo-Hsin Yang <vovoy@chromium.org>
> > =

> > The i915 driver uses shmemfs to allocate backing storage for gem
> > objects. These shmemfs pages can be pinned (increased ref count) by
> > shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> > wastes a lot of time scanning these pinned pages. In some extreme case,
> > all pages in the inactive anon lru are pinned, and only the inactive
> > anon lru is scanned due to inactive_ratio, the system cannot swap and
> > invokes the oom-killer. Mark these pinned pages as unevictable to speed
> > up vmscan.
> > =

> > Export pagevec API check_move_unevictable_pages().
> > =

> > This patch was inspired by Chris Wilson's change [1].
> > =

> > [1]: https://patchwork.kernel.org/patch/9768741/
> > =

> > ...
> >
> > --- a/drivers/gpu/drm/i915/i915_gem.c
> > +++ b/drivers/gpu/drm/i915/i915_gem.c
> > @@ -2382,12 +2382,26 @@ void __i915_gem_object_invalidate(struct drm_i9=
15_gem_object *obj)
> >       invalidate_mapping_pages(mapping, 0, (loff_t)-1);
> >  }
> >  =

> > +/**
> =

> This token is used to introduce a kerneldoc comment.
> =

> > + * Move pages to appropriate lru and release the pagevec. Decrement th=
e ref
> > + * count of these pages.
> > + */
> =

> But this isn't a kerneldoc comment.
> =

> At least, I don't think it is.  Maybe the parser got smarter when I
> wasn't looking.
> =

> > +static inline void check_release_pagevec(struct pagevec *pvec)
> > +{
> > +     if (pagevec_count(pvec)) {
> > +             check_move_unevictable_pages(pvec);
> > +             __pagevec_release(pvec);
> > +             cond_resched();
> > +     }
> > +}
> =

> This looks too large to be inlined and the compiler will ignore the
> `inline' anyway.

Applied both corrections.

> Otherwise, Acked-by: Andrew Morton <akpm@linux-foundation.org>.  Please
> go ahead and merge via the appropriate drm tree.

Thank you, pushed to drm-intel, expected to arrive around 4.21.
-Chris
