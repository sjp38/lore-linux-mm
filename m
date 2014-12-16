Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7ED6B0032
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 21:37:59 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so13156927pab.30
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:37:58 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id qd7si5554289pdb.124.2014.12.15.18.37.55
        for <linux-mm@kvack.org>;
        Mon, 15 Dec 2014 18:37:57 -0800 (PST)
Date: Tue, 16 Dec 2014 11:42:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
Message-ID: <20141216024210.GB23270@js1304-P5Q-DELUXE>
References: <20141210163017.092096069@linux.com>
 <20141210163033.717707217@linux.com>
 <20141215080338.GE4898@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1412150815210.20101@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1412150815210.20101@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Mon, Dec 15, 2014 at 08:16:00AM -0600, Christoph Lameter wrote:
> On Mon, 15 Dec 2014, Joonsoo Kim wrote:
> 
> > > +static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)
> > > +{
> > > +	long d = p - page->address;
> > > +
> > > +	return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
> > > +}
> > > +
> >
> > Somtimes, compound_order() induces one more cacheline access, because
> > compound_order() access second struct page in order to get order. Is there
> > any way to remove this?
> 
> I already have code there to avoid the access if its within a MAX_ORDER
> page. We could probably go for a smaller setting there. PAGE_COSTLY_ORDER?

That is the solution to avoid compound_order() call when slab of
object isn't matched with per cpu slab.

What I'm asking is whether there is a way to avoid compound_order() call when slab
of object is matched with per cpu slab or not.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
