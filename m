Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6656B6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 04:21:15 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id v63so11444774oia.13
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 01:21:15 -0800 (PST)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id t19si319115oeo.79.2015.01.27.01.21.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 01:21:14 -0800 (PST)
Received: by mail-oi0-f44.google.com with SMTP id a3so11471633oib.3
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 01:21:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150127082301.GD28978@esperanza>
References: <cover.1422275084.git.vdavydov@parallels.com>
	<42d95683e3c7f4bb00be4d777e2b334e8981d552.1422275084.git.vdavydov@parallels.com>
	<20150127080009.GB11358@js1304-P5Q-DELUXE>
	<20150127082301.GD28978@esperanza>
Date: Tue, 27 Jan 2015 18:21:14 +0900
Message-ID: <CAAmzW4N+HVEO7_29QpzW9ezask4FZYVVUdm0eMKv4CdUwLWYxQ@mail.gmail.com>
Subject: Re: [PATCH -mm 3/3] slub: make dead caches discard free slabs immediately
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-01-27 17:23 GMT+09:00 Vladimir Davydov <vdavydov@parallels.com>:
> Hi Joonsoo,
>
> On Tue, Jan 27, 2015 at 05:00:09PM +0900, Joonsoo Kim wrote:
>> On Mon, Jan 26, 2015 at 03:55:29PM +0300, Vladimir Davydov wrote:
>> > @@ -3381,6 +3390,15 @@ void __kmem_cache_shrink(struct kmem_cache *s)
>> >             kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
>> >     unsigned long flags;
>> >
>> > +   if (deactivate) {
>> > +           /*
>> > +            * Disable empty slabs caching. Used to avoid pinning offline
>> > +            * memory cgroups by freeable kmem pages.
>> > +            */
>> > +           s->cpu_partial = 0;
>> > +           s->min_partial = 0;
>> > +   }
>> > +
>>
>> Maybe, kick_all_cpus_sync() is needed here since object would
>> be freed asynchronously so they can't see this updated value.
>
> I thought flush_all() should do the trick, no?

Unfortunately, it doesn't.

flush_all() sends IPI to not all cpus. It only sends IPI to cpus where
some conditions
are met and freeing could occur on the other ones.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
