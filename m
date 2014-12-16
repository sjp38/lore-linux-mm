Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A27A96B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 02:54:14 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so13393698pdi.37
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 23:54:14 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id so6si17266183pac.164.2014.12.15.23.54.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 23:54:13 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id r10so13481521pdi.9
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 23:54:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141216024210.GB23270@js1304-P5Q-DELUXE>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
	<20141215080338.GE4898@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412150815210.20101@gentwo.org>
	<20141216024210.GB23270@js1304-P5Q-DELUXE>
Date: Tue, 16 Dec 2014 11:54:12 +0400
Message-ID: <CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linuxfoundation.org, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

2014-12-16 5:42 GMT+03:00 Joonsoo Kim <iamjoonsoo.kim@lge.com>:
> On Mon, Dec 15, 2014 at 08:16:00AM -0600, Christoph Lameter wrote:
>> On Mon, 15 Dec 2014, Joonsoo Kim wrote:
>>
>> > > +static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)
>> > > +{
>> > > + long d = p - page->address;
>> > > +
>> > > + return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
>> > > +}
>> > > +
>> >
>> > Somtimes, compound_order() induces one more cacheline access, because
>> > compound_order() access second struct page in order to get order. Is there
>> > any way to remove this?
>>
>> I already have code there to avoid the access if its within a MAX_ORDER
>> page. We could probably go for a smaller setting there. PAGE_COSTLY_ORDER?
>
> That is the solution to avoid compound_order() call when slab of
> object isn't matched with per cpu slab.
>
> What I'm asking is whether there is a way to avoid compound_order() call when slab
> of object is matched with per cpu slab or not.
>

Can we use page->objects for that?

Like this:

        return d > 0 && d < page->objects * s->size;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
