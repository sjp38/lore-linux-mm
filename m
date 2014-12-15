Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 871DE6B0071
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 09:16:04 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id r2so5014179igi.12
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 06:16:04 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id c202si6656123ioe.3.2014.12.15.06.16.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 06:16:03 -0800 (PST)
Date: Mon, 15 Dec 2014 08:16:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
In-Reply-To: <20141215080338.GE4898@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1412150815210.20101@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141210163033.717707217@linux.com> <20141215080338.GE4898@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Mon, 15 Dec 2014, Joonsoo Kim wrote:

> > +static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)
> > +{
> > +	long d = p - page->address;
> > +
> > +	return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
> > +}
> > +
>
> Somtimes, compound_order() induces one more cacheline access, because
> compound_order() access second struct page in order to get order. Is there
> any way to remove this?

I already have code there to avoid the access if its within a MAX_ORDER
page. We could probably go for a smaller setting there. PAGE_COSTLY_ORDER?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
