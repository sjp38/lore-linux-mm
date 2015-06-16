Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7F16C6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:00:41 -0400 (EDT)
Received: by obctg8 with SMTP id tg8so9616543obc.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:00:41 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id f4si485826oeu.54.2015.06.16.05.00.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 05:00:40 -0700 (PDT)
Received: by oiax193 with SMTP id x193so9569023oia.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:00:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150616112033.0b8bafb8@redhat.com>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155256.18824.42651.stgit@devil>
	<20150616072328.GB13125@js1304-P5Q-DELUXE>
	<20150616112033.0b8bafb8@redhat.com>
Date: Tue, 16 Jun 2015 21:00:39 +0900
Message-ID: <CAAmzW4P4kHW4NJv=BFXye4bENv1L7Tdyhuwio3rm5j-3y-tE-g@mail.gmail.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Netdev <netdev@vger.kernel.org>, Alexander Duyck <alexander.duyck@gmail.com>

2015-06-16 18:20 GMT+09:00 Jesper Dangaard Brouer <brouer@redhat.com>:
> On Tue, 16 Jun 2015 16:23:28 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>
>> On Mon, Jun 15, 2015 at 05:52:56PM +0200, Jesper Dangaard Brouer wrote:
>> > This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
>> > now both have bulk alloc and free implemented.
>> >
>> > Play nice and reenable local IRQs while calling slowpath.
>> >
>> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> > ---
>> >  mm/slub.c |   32 +++++++++++++++++++++++++++++++-
>> >  1 file changed, 31 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/mm/slub.c b/mm/slub.c
>> > index 98d0e6f73ec1..cc4f870677bb 100644
>> > --- a/mm/slub.c
>> > +++ b/mm/slub.c
>> > @@ -2752,7 +2752,37 @@ EXPORT_SYMBOL(kmem_cache_free);
>> >
>> >  void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>> >  {
>> > -   __kmem_cache_free_bulk(s, size, p);
>> > +   struct kmem_cache_cpu *c;
>> > +   struct page *page;
>> > +   int i;
>> > +
>> > +   local_irq_disable();
>> > +   c = this_cpu_ptr(s->cpu_slab);
>> > +
>> > +   for (i = 0; i < size; i++) {
>> > +           void *object = p[i];
>> > +
>> > +           if (unlikely(!object))
>> > +                   continue; // HOW ABOUT BUG_ON()???
>> > +
>> > +           page = virt_to_head_page(object);
>> > +           BUG_ON(s != page->slab_cache); /* Check if valid slab page */
>>
>> You need to use cache_from_objt() to support kmemcg accounting.
>> And, slab_free_hook() should be called before free.
>
> Okay, but Christoph choose to not support kmem_cache_debug() in patch2/7.
>
> Should we/I try to add kmem cache debugging support?

kmem_cache_debug() is the check for slab internal debugging feature.
slab_free_hook() and others mentioned from me are also related to external
debugging features like as kasan and kmemleak. So, even if
debugged kmem_cache isn't supported by bulk API, external debugging
feature should be supported.

> If adding these, then I would also need to add those on alloc path...

Yes, please.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
