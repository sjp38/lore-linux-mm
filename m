Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D70F6B0279
	for <linux-mm@kvack.org>; Mon, 22 May 2017 16:22:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c6so140754614pfj.5
        for <linux-mm@kvack.org>; Mon, 22 May 2017 13:22:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d67sor365854pgc.115.2017.05.22.13.22.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 May 2017 13:22:31 -0700 (PDT)
Date: Mon, 22 May 2017 13:22:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [HMM 08/15] mm/ZONE_DEVICE: special case put_page() for device
 private pages
In-Reply-To: <20170522201416.GA8168@redhat.com>
Message-ID: <alpine.LSU.2.11.1705221317280.4687@eggly.anvils>
References: <20170522165206.6284-1-jglisse@redhat.com> <20170522165206.6284-9-jglisse@redhat.com> <CAPcyv4hodnCFEy8iyb3jQPJ=TNj-L2uZQKJqb7JTqSv=YE0BDg@mail.gmail.com> <20170522201416.GA8168@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, 22 May 2017, Jerome Glisse wrote:
> On Mon, May 22, 2017 at 12:29:53PM -0700, Dan Williams wrote:
> > On Mon, May 22, 2017 at 9:51 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > > A ZONE_DEVICE page that reach a refcount of 1 is free ie no longer
> > > have any user. For device private pages this is important to catch
> > > and thus we need to special case put_page() for this.
> > >
> > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > ---
> > >  include/linux/mm.h | 30 ++++++++++++++++++++++++++++++
> > >  kernel/memremap.c  |  1 -
> > >  2 files changed, 30 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index a825dab..11f7bac 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -23,6 +23,7 @@
> > >  #include <linux/page_ext.h>
> > >  #include <linux/err.h>
> > >  #include <linux/page_ref.h>
> > > +#include <linux/memremap.h>
> > >
> > >  struct mempolicy;
> > >  struct anon_vma;
> > > @@ -795,6 +796,20 @@ static inline bool is_device_private_page(const struct page *page)
> > >         return ((page_zonenum(page) == ZONE_DEVICE) &&
> > >                 (page->pgmap->type == MEMORY_DEVICE_PRIVATE));
> > >  }
> > > +
> > > +static inline void put_zone_device_private_page(struct page *page)
> > > +{
> > > +       int count = page_ref_dec_return(page);
> > > +
> > > +       /*
> > > +        * If refcount is 1 then page is freed and refcount is stable as nobody
> > > +        * holds a reference on the page.
> > > +        */
> > > +       if (count == 1)
> > > +               page->pgmap->page_free(page, page->pgmap->data);
> > > +       else if (!count)
> > > +               __put_page(page);
> > > +}

Is there something else in this patchset that guarantees
that get_page_unless_zero() is never used on thse pages?
We have plenty of code that knows that refcount 0 is special:
having to know that refcount 1 may be special is worrying.

Hugh

> > >  #else
> > >  static inline bool is_zone_device_page(const struct page *page)
> > >  {
> > > @@ -805,6 +820,10 @@ static inline bool is_device_private_page(const struct page *page)
> > >  {
> > >         return false;
> > >  }
> > > +
> > > +static inline void put_zone_device_private_page(struct page *page)
> > > +{
> > > +}
> > >  #endif
> > >
> > >  static inline void get_page(struct page *page)
> > > @@ -822,6 +841,17 @@ static inline void put_page(struct page *page)
> > >  {
> > >         page = compound_head(page);
> > >
> > > +       /*
> > > +        * For private device pages we need to catch refcount transition from
> > > +        * 2 to 1, when refcount reach one it means the private device page is
> > > +        * free and we need to inform the device driver through callback. See
> > > +        * include/linux/memremap.h and HMM for details.
> > > +        */
> > > +       if (unlikely(is_device_private_page(page))) {
> > 
> > Since I presume HMM is a niche use case can we make this a
> > "static_branch_unlikely(&hmm_key) && is_device_private_page(page))"?
> > That way non-hmm platforms see minimal overhead.
> 
> Like i said in the cover letter i am bit anxious about doing for
> an inline function. I don't see any existing case for inline
> function and static key. Is that suppose to work ?
> 
> How widespread HMM use will be is hard to guess. Usual chicken
> and egg plus adoption thing. If GPGPU compte keeps growing and
> it seems it does then HMM likely gonna be enable and actively
> use for large chunk of those computer that have GPGPU workload.
> 
> I will test a static key of that branch and see if it explodes
> because put_page() is an inline function.
> 
> Cheers,
> Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
