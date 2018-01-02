Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E562D6B02B6
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 09:58:17 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id b26so34774811qtb.18
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 06:58:17 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id k3si5626745qkd.362.2018.01.02.06.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 06:58:17 -0800 (PST)
Date: Tue, 2 Jan 2018 08:55:45 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 3/8] slub: Add isolate() and migrate() methods
In-Reply-To: <20171230064246.GC27959@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801020853380.14141@nuc-kabylake>
References: <20171227220636.361857279@linux.com> <20171227220652.402842142@linux.com> <20171230064246.GC27959@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Fri, 29 Dec 2017, Matthew Wilcox wrote:

> Is this the right approach?  I could imagine there being more ops in
> the future.  I suspect we should bite the bullet now and do:
>
> struct kmem_cache_operations {
> 	void (*ctor)(void *);
> 	void *(*isolate)(struct kmem_cache *, void **objs, int nr);
> 	void (*migrate)(struct kmem_cache *, void **objs, int nr, int node,
> 			void *private);
> };

Well yes but that would mean converting the existing call sites.

> Not sure how best to convert the existing constructor users to this scheme.
> Perhaps cheat ...

One of the prior releases of slab defragmentation did this. We could do it
at some point. For now the approach avoids changing the API.

> > @@ -4969,6 +4987,20 @@ static ssize_t ops_show(struct kmem_cach
> >
> >  	if (s->ctor)
> >  		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
> > +
> > +	if (s->isolate) {
> > +		x += sprintf(buf + x, "isolate : ");
> > +		x += sprint_symbol(buf + x,
> > +				(unsigned long)s->isolate);
> > +		x += sprintf(buf + x, "\n");
> > +	}
>
> Here you could print the symbol of the ops vector instead of the function
> pointer ...

Well yes if we had it and thne we could avoid printing individual fields.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
