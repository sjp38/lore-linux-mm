Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF6AD6B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 14:28:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m8-v6so479673pgq.9
        for <linux-mm@kvack.org>; Thu, 03 May 2018 11:28:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o9si14270759pfk.276.2018.05.03.11.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 May 2018 11:28:26 -0700 (PDT)
Date: Thu, 3 May 2018 11:28:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
Message-ID: <20180503182823.GB1562@bombadil.infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
 <20180430202247.25220-8-willy@infradead.org>
 <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake>
 <20180502172639.GC2737@bombadil.infradead.org>
 <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
 <20180503005223.GB21199@bombadil.infradead.org>
 <alpine.DEB.2.21.1805031001510.6701@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1805031001510.6701@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, May 03, 2018 at 10:03:10AM -0500, Christopher Lameter wrote:
> On Wed, 2 May 2018, Matthew Wilcox wrote:
> 
> > > > Option 2:
> > > > +                       union {
> > > > +                               unsigned long counters;
> > > > +                               struct {
> > > > +                                       unsigned inuse:16;
> > > > +                                       unsigned objects:15;
> > > > +                                       unsigned frozen:1;
> > > > +                               };
> > > > +                       };
> > > >
> > > > Pro: Expresses exactly what we do.
> > > > Con: Back to five levels of indentation in struct page
> 
> I like that better. Improves readability of the code using struct page. I
> think that is more important than the actual definition of struct page.

OK.  Do you want the conversion of slub to using slub_freelist and slub_list
as part of this patch series as well, then?

The end result looks like this, btw:

                struct {        /* slub */ 
                        union {
                                struct list_head slub_list;
                                struct {
                                        struct page *next; /* Next partial */
#ifdef CONFIG_64BIT
                                        int pages;      /* Nr of pages left */
                                        int pobjects;   /* Apprx # of objects */
#else
                                        short int pages;
                                        short int pobjects;
#endif
                                };
                        };
                        struct kmem_cache *slub_cache;  /* shared with slab */
                        /* Double-word boundary */
                        void *slub_freelist;            /* shared with slab */
                        union {
                                unsigned long counters;
                                struct {
                                        unsigned inuse:16;
                                        unsigned objects:15;
                                        unsigned frozen:1;
                                };
                        };
                };

Oh, and what do you want to do about cache_from_obj() in mm/slab.h?
That relies on having slab_cache be in the same location in struct
page as slub_cache.  Maybe something like this?

        page = virt_to_head_page(x);
#ifdef CONFIG_SLUB
        cachep = page->slub_cache;
#else
        cachep = page->slab_cache;
#endif
        if (slab_equal_or_root(cachep, s))
                return cachep;

> Given the overloaded overload situation this will require some deep
> throught for newbies anyways. ;-)

Yes, it's all quite entangled.
