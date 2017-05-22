Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83C376B02B4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:17:29 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 25so54223621qtx.11
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:17:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g46si19318022qtb.268.2017.05.22.14.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 14:17:28 -0700 (PDT)
Date: Mon, 22 May 2017 17:17:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 08/15] mm/ZONE_DEVICE: special case put_page() for device
 private pages
Message-ID: <20170522211724.GC8168@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-9-jglisse@redhat.com>
 <CAPcyv4hodnCFEy8iyb3jQPJ=TNj-L2uZQKJqb7JTqSv=YE0BDg@mail.gmail.com>
 <20170522201416.GA8168@redhat.com>
 <alpine.LSU.2.11.1705221317280.4687@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LSU.2.11.1705221317280.4687@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, May 22, 2017 at 01:22:22PM -0700, Hugh Dickins wrote:
> On Mon, 22 May 2017, Jerome Glisse wrote:
> > On Mon, May 22, 2017 at 12:29:53PM -0700, Dan Williams wrote:
> > > On Mon, May 22, 2017 at 9:51 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > > > A ZONE_DEVICE page that reach a refcount of 1 is free ie no longer
> > > > have any user. For device private pages this is important to catch
> > > > and thus we need to special case put_page() for this.
> > > >
> > > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > > ---
> > > >  include/linux/mm.h | 30 ++++++++++++++++++++++++++++++
> > > >  kernel/memremap.c  |  1 -
> > > >  2 files changed, 30 insertions(+), 1 deletion(-)
> > > >
> > > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > > index a825dab..11f7bac 100644
> > > > --- a/include/linux/mm.h
> > > > +++ b/include/linux/mm.h
> > > > @@ -23,6 +23,7 @@
> > > >  #include <linux/page_ext.h>
> > > >  #include <linux/err.h>
> > > >  #include <linux/page_ref.h>
> > > > +#include <linux/memremap.h>
> > > >
> > > >  struct mempolicy;
> > > >  struct anon_vma;
> > > > @@ -795,6 +796,20 @@ static inline bool is_device_private_page(const struct page *page)
> > > >         return ((page_zonenum(page) == ZONE_DEVICE) &&
> > > >                 (page->pgmap->type == MEMORY_DEVICE_PRIVATE));
> > > >  }
> > > > +
> > > > +static inline void put_zone_device_private_page(struct page *page)
> > > > +{
> > > > +       int count = page_ref_dec_return(page);
> > > > +
> > > > +       /*
> > > > +        * If refcount is 1 then page is freed and refcount is stable as nobody
> > > > +        * holds a reference on the page.
> > > > +        */
> > > > +       if (count == 1)
> > > > +               page->pgmap->page_free(page, page->pgmap->data);
> > > > +       else if (!count)
> > > > +               __put_page(page);
> > > > +}
> 
> Is there something else in this patchset that guarantees
> that get_page_unless_zero() is never used on thse pages?
> We have plenty of code that knows that refcount 0 is special:
> having to know that refcount 1 may be special is worrying.
> 
> Hugh

ZONE_DEVICE pages always had this extra refcount since their
inception. All the place that use get_page_unless_zero() should
be unreachable by a ZONE_DEVICE pages (hwpoison, lru, isolate,
ksm, ...). So if that happens it is a bug.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
