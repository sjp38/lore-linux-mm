Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31E366B02B4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:15:01 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o85so57915784qkh.15
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:15:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y68si10560856qkc.250.2017.05.22.14.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 14:15:00 -0700 (PDT)
Date: Mon, 22 May 2017 17:14:56 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 08/15] mm/ZONE_DEVICE: special case put_page() for device
 private pages
Message-ID: <20170522211456.GB8168@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-9-jglisse@redhat.com>
 <CAPcyv4hodnCFEy8iyb3jQPJ=TNj-L2uZQKJqb7JTqSv=YE0BDg@mail.gmail.com>
 <20170522201416.GA8168@redhat.com>
 <CAPcyv4ipiDwPB7V72dpzF3FwKRCd8m0JHDLezrUm0=oQ4q2VeA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4ipiDwPB7V72dpzF3FwKRCd8m0JHDLezrUm0=oQ4q2VeA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, May 22, 2017 at 01:19:29PM -0700, Dan Williams wrote:
> On Mon, May 22, 2017 at 1:14 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Mon, May 22, 2017 at 12:29:53PM -0700, Dan Williams wrote:
> >> On Mon, May 22, 2017 at 9:51 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> > A ZONE_DEVICE page that reach a refcount of 1 is free ie no longer
> >> > have any user. For device private pages this is important to catch
> >> > and thus we need to special case put_page() for this.
> >> >
> >> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> >> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> > Cc: Dan Williams <dan.j.williams@intel.com>
> >> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> >> > ---
> >> >  include/linux/mm.h | 30 ++++++++++++++++++++++++++++++
> >> >  kernel/memremap.c  |  1 -
> >> >  2 files changed, 30 insertions(+), 1 deletion(-)
> >> >
> >> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> >> > index a825dab..11f7bac 100644
> >> > --- a/include/linux/mm.h
> >> > +++ b/include/linux/mm.h
> >> > @@ -23,6 +23,7 @@
> >> >  #include <linux/page_ext.h>
> >> >  #include <linux/err.h>
> >> >  #include <linux/page_ref.h>
> >> > +#include <linux/memremap.h>
> >> >
> >> >  struct mempolicy;
> >> >  struct anon_vma;
> >> > @@ -795,6 +796,20 @@ static inline bool is_device_private_page(const struct page *page)
> >> >         return ((page_zonenum(page) == ZONE_DEVICE) &&
> >> >                 (page->pgmap->type == MEMORY_DEVICE_PRIVATE));
> >> >  }
> >> > +
> >> > +static inline void put_zone_device_private_page(struct page *page)
> >> > +{
> >> > +       int count = page_ref_dec_return(page);
> >> > +
> >> > +       /*
> >> > +        * If refcount is 1 then page is freed and refcount is stable as nobody
> >> > +        * holds a reference on the page.
> >> > +        */
> >> > +       if (count == 1)
> >> > +               page->pgmap->page_free(page, page->pgmap->data);
> >> > +       else if (!count)
> >> > +               __put_page(page);
> >> > +}
> >> >  #else
> >> >  static inline bool is_zone_device_page(const struct page *page)
> >> >  {
> >> > @@ -805,6 +820,10 @@ static inline bool is_device_private_page(const struct page *page)
> >> >  {
> >> >         return false;
> >> >  }
> >> > +
> >> > +static inline void put_zone_device_private_page(struct page *page)
> >> > +{
> >> > +}
> >> >  #endif
> >> >
> >> >  static inline void get_page(struct page *page)
> >> > @@ -822,6 +841,17 @@ static inline void put_page(struct page *page)
> >> >  {
> >> >         page = compound_head(page);
> >> >
> >> > +       /*
> >> > +        * For private device pages we need to catch refcount transition from
> >> > +        * 2 to 1, when refcount reach one it means the private device page is
> >> > +        * free and we need to inform the device driver through callback. See
> >> > +        * include/linux/memremap.h and HMM for details.
> >> > +        */
> >> > +       if (unlikely(is_device_private_page(page))) {
> >>
> >> Since I presume HMM is a niche use case can we make this a
> >> "static_branch_unlikely(&hmm_key) && is_device_private_page(page))"?
> >> That way non-hmm platforms see minimal overhead.
> >
> > Like i said in the cover letter i am bit anxious about doing for
> 
> I don't think you copied me on the cover letter.
> 
> > an inline function. I don't see any existing case for inline
> > function and static key. Is that suppose to work ?
> >
> > How widespread HMM use will be is hard to guess. Usual chicken
> > and egg plus adoption thing. If GPGPU compte keeps growing and
> > it seems it does then HMM likely gonna be enable and actively
> > use for large chunk of those computer that have GPGPU workload.
> >
> > I will test a static key of that branch and see if it explodes
> > because put_page() is an inline function.
> 
> memcpy_mcsafe() is an existing example of a static inline with a
> static branch. Hasn't seemed to have caused any problems to date.

Ok i will post a new version of 08 with static keys, i shouldn't
need to repost any other patches for that. Andrew that's fine
with you or do you prefer me to repost a full updated patchset ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
