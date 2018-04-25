Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFBC96B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 08:51:38 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 11-v6so15041643otj.1
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 05:51:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f2-v6si4987425oic.450.2018.04.25.05.51.37
        for <linux-mm@kvack.org>;
        Wed, 25 Apr 2018 05:51:37 -0700 (PDT)
Date: Wed, 25 Apr 2018 13:51:55 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
Message-ID: <20180425125154.GA29722@MBP.local>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
 <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
 <20180422125141.GF17484@dhcp22.suse.cz>
 <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
 <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
 <20180424132057.GE17484@dhcp22.suse.cz>
 <20180424134148.qkvqqa4c37l6irvg@armageddon.cambridge.arm.com>
 <482146467.19754107.1524649841393.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <482146467.19754107.1524649841393.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Chunyu Hu <chuhu.ncepu@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Apr 25, 2018 at 05:50:41AM -0400, Chunyu Hu wrote:
> ----- Original Message -----
> > From: "Catalin Marinas" <catalin.marinas@arm.com>
> > On Tue, Apr 24, 2018 at 07:20:57AM -0600, Michal Hocko wrote:
> > > On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
> > > [...]
> > > > So if there is a new flag, it would be the 25th bits.
> > > 
> > > No new flags please. Can you simply store a simple bool into
> > > fail_page_alloc
> > > and have save/restore api for that?
> > 
> > For kmemleak, we probably first hit failslab. Something like below may
> > do the trick:
> > 
> > diff --git a/mm/failslab.c b/mm/failslab.c
> > index 1f2f248e3601..63f13da5cb47 100644
> > --- a/mm/failslab.c
> > +++ b/mm/failslab.c
> > @@ -29,6 +29,9 @@ bool __should_failslab(struct kmem_cache *s, gfp_t
> > gfpflags)
> >  	if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
> >  		return false;
> >  
> > +	if (s->flags & SLAB_NOLEAKTRACE)
> > +		return false;
> > +
> >  	return should_fail(&failslab.attr, s->object_size);
> >  }
> 
> This maybe is the easy enough way for skipping fault injection for
> kmemleak slab object. 

This was added to avoid kmemleak tracing itself, so could be used for
other kmemleak-related cases.

> > Can we get a second should_fail() via should_fail_alloc_page() if a new
> > slab page is allocated?
> 
> looking at code path below, what do you mean by getting a second
> should_fail() via fail_alloc_page?

Kmemleak calls kmem_cache_alloc() on a cache with SLAB_LEAKNOTRACE, so the
first point of failure injection is __should_failslab() which we can
handle with the slab flag. The slab allocator itself ends up calling
alloc_pages() to allocate a slab page (and __GFP_NOFAIL is explicitly
cleared). Here we have the second potential failure injection via
fail_alloc_page(). That's unless the order < fail_page_alloc.min_order
which I think is the default case (min_order = 1 while the slab page
allocation for kmemleak would need an order of 0. It's not ideal but we
may get away with it.

> Seems we need to insert the flag between alloc_slab_page and
> alloc_pages()? Without GFP flag, it's difficult to pass info to
> should_fail_alloc_page and keep simple at same time. 

Indeed.

> Or as Michal suggested, completely disabling page alloc fail injection
> when kmemleak enabled. And enable it again when kmemleak off. 

Dmitry's point was that kmemleak is still useful to detect leaks on the
error path where errors are actually introduced by the fault injection.
Kmemleak cannot cope with allocation failures as it needs a pretty
precise tracking of the allocated objects.

An alternative could be to not free the early_log buffer in kmemleak and
use that memory in an emergency when allocation fails (though I don't
particularly like this).

Yet another option is to use NOFAIL and remove NORETRY in kmemleak when
fault injection is enabled.

-- 
Catalin
