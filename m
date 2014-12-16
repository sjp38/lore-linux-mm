Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id BF1B46B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 09:05:51 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id c9so10141166qcz.24
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 06:05:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 37si935810qgo.41.2014.12.16.06.05.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 06:05:50 -0800 (PST)
Date: Tue, 16 Dec 2014 15:05:37 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
Message-ID: <20141216150537.25c72553@redhat.com>
In-Reply-To: <CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
	<20141215080338.GE4898@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412150815210.20101@gentwo.org>
	<20141216024210.GB23270@js1304-P5Q-DELUXE>
	<CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, akpm@linuxfoundation.org, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, brouer@redhat.com

On Tue, 16 Dec 2014 11:54:12 +0400
Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:

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

I gave this change a quick micro benchmark spin (with Christoph's
tool), the results are below.

Notice, the "2. Kmalloc: alloc/free test" for small obj sizes improves,
which is more "back-to-normal" as before this patchset.

Before (with curr patchset):
============================

 Single thread testing
 =====================
 1. Kmalloc: Repeatedly allocate then free test
 10000 times kmalloc(8) -> 50 cycles kfree -> 60 cycles
 10000 times kmalloc(16) -> 52 cycles kfree -> 60 cycles
 10000 times kmalloc(32) -> 56 cycles kfree -> 64 cycles
 10000 times kmalloc(64) -> 67 cycles kfree -> 72 cycles
 10000 times kmalloc(128) -> 86 cycles kfree -> 79 cycles
 10000 times kmalloc(256) -> 97 cycles kfree -> 110 cycles
 10000 times kmalloc(512) -> 88 cycles kfree -> 114 cycles
 10000 times kmalloc(1024) -> 91 cycles kfree -> 115 cycles
 10000 times kmalloc(2048) -> 119 cycles kfree -> 131 cycles
 10000 times kmalloc(4096) -> 159 cycles kfree -> 163 cycles
 10000 times kmalloc(8192) -> 269 cycles kfree -> 226 cycles
 10000 times kmalloc(16384) -> 498 cycles kfree -> 291 cycles
 2. Kmalloc: alloc/free test
 10000 times kmalloc(8)/kfree -> 112 cycles
 10000 times kmalloc(16)/kfree -> 118 cycles
 10000 times kmalloc(32)/kfree -> 117 cycles
 10000 times kmalloc(64)/kfree -> 122 cycles
 10000 times kmalloc(128)/kfree -> 133 cycles
 10000 times kmalloc(256)/kfree -> 79 cycles
 10000 times kmalloc(512)/kfree -> 79 cycles
 10000 times kmalloc(1024)/kfree -> 79 cycles
 10000 times kmalloc(2048)/kfree -> 72 cycles
 10000 times kmalloc(4096)/kfree -> 78 cycles
 10000 times kmalloc(8192)/kfree -> 78 cycles
 10000 times kmalloc(16384)/kfree -> 596 cycles

After (with proposed change):
=============================
 Single thread testing
 =====================
 1. Kmalloc: Repeatedly allocate then free test
 10000 times kmalloc(8) -> 53 cycles kfree -> 62 cycles
 10000 times kmalloc(16) -> 53 cycles kfree -> 64 cycles
 10000 times kmalloc(32) -> 57 cycles kfree -> 66 cycles
 10000 times kmalloc(64) -> 68 cycles kfree -> 72 cycles
 10000 times kmalloc(128) -> 77 cycles kfree -> 80 cycles
 10000 times kmalloc(256) -> 98 cycles kfree -> 110 cycles
 10000 times kmalloc(512) -> 87 cycles kfree -> 113 cycles
 10000 times kmalloc(1024) -> 90 cycles kfree -> 116 cycles
 10000 times kmalloc(2048) -> 116 cycles kfree -> 131 cycles
 10000 times kmalloc(4096) -> 160 cycles kfree -> 164 cycles
 10000 times kmalloc(8192) -> 269 cycles kfree -> 226 cycles
 10000 times kmalloc(16384) -> 499 cycles kfree -> 295 cycles
 2. Kmalloc: alloc/free test
 10000 times kmalloc(8)/kfree -> 74 cycles
 10000 times kmalloc(16)/kfree -> 73 cycles
 10000 times kmalloc(32)/kfree -> 73 cycles
 10000 times kmalloc(64)/kfree -> 74 cycles
 10000 times kmalloc(128)/kfree -> 73 cycles
 10000 times kmalloc(256)/kfree -> 72 cycles
 10000 times kmalloc(512)/kfree -> 73 cycles
 10000 times kmalloc(1024)/kfree -> 72 cycles
 10000 times kmalloc(2048)/kfree -> 73 cycles
 10000 times kmalloc(4096)/kfree -> 72 cycles
 10000 times kmalloc(8192)/kfree -> 72 cycles
 10000 times kmalloc(16384)/kfree -> 556 cycles


(kernel 3.18.0-net-next+ SMP PREEMPT on top of f96fe225677)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
