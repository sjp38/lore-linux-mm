Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D29076B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 03:21:44 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so13676358pab.28
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 00:21:44 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id tj5si91644pab.88.2014.12.16.00.21.41
        for <linux-mm@kvack.org>;
        Tue, 16 Dec 2014 00:21:43 -0800 (PST)
Date: Tue, 16 Dec 2014 17:25:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
Message-ID: <20141216082555.GA6088@js1304-P5Q-DELUXE>
References: <20141210163017.092096069@linux.com>
 <20141210163033.717707217@linux.com>
 <20141215080338.GE4898@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1412150815210.20101@gentwo.org>
 <20141216024210.GB23270@js1304-P5Q-DELUXE>
 <CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linuxfoundation.org, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, Dec 16, 2014 at 11:54:12AM +0400, Andrey Ryabinin wrote:
> 2014-12-16 5:42 GMT+03:00 Joonsoo Kim <iamjoonsoo.kim@lge.com>:
> > On Mon, Dec 15, 2014 at 08:16:00AM -0600, Christoph Lameter wrote:
> >> On Mon, 15 Dec 2014, Joonsoo Kim wrote:
> >>
> >> > > +static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)
> >> > > +{
> >> > > + long d = p - page->address;
> >> > > +
> >> > > + return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
> >> > > +}
> >> > > +
> >> >
> >> > Somtimes, compound_order() induces one more cacheline access, because
> >> > compound_order() access second struct page in order to get order. Is there
> >> > any way to remove this?
> >>
> >> I already have code there to avoid the access if its within a MAX_ORDER
> >> page. We could probably go for a smaller setting there. PAGE_COSTLY_ORDER?
> >
> > That is the solution to avoid compound_order() call when slab of
> > object isn't matched with per cpu slab.
> >
> > What I'm asking is whether there is a way to avoid compound_order() call when slab
> > of object is matched with per cpu slab or not.
> >
> 
> Can we use page->objects for that?
> 
> Like this:
> 
>         return d > 0 && d < page->objects * s->size;
> 

Yes! That's what I'm looking for.
Christoph, how about above change?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
