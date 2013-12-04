Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B28736B003B
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 11:02:16 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so13944099wgh.21
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:02:16 -0800 (PST)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id 5si32999864wjs.75.2013.12.04.08.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 08:02:15 -0800 (PST)
Received: by mail-wi0-f172.google.com with SMTP id en1so8445593wid.11
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:02:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <00000142be2f1de0-764bb035-adbc-4367-b2b4-bf05498510a6-000000@email.amazonses.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
	<1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
	<20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org>
	<20131204015218.GA19709@lge.com>
	<20131203180717.94c013d1.akpm@linux-foundation.org>
	<00000142be2f1de0-764bb035-adbc-4367-b2b4-bf05498510a6-000000@email.amazonses.com>
Date: Thu, 5 Dec 2013 01:02:15 +0900
Message-ID: <CAAmzW4PwLhMd61ksOktdg=rkj0xHsSGt2Wm_za2Adjh4+tss-g@mail.gmail.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the allocator
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, Linux Memory Management List <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>

2013/12/5 Christoph Lameter <cl@linux.com>:
> On Tue, 3 Dec 2013, Andrew Morton wrote:
>
>> >     page = alloc_slab_page(alloc_gfp, node, oo);
>> >     if (unlikely(!page)) {
>> >             oo = s->min;
>>
>> What is the value of s->min?  Please tell me it's zero.
>
> It usually is.
>
>> > @@ -1349,7 +1350,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>> >             && !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
>> >             int pages = 1 << oo_order(oo);
>> >
>> > -           kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
>> > +           kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
>>
>> That seems reasonable, assuming kmemcheck can handle the allocation
>> failure.
>>
>>
>> Still I dislike this practice of using unnecessarily large allocations.
>> What does it gain us?  Slightly improved object packing density.
>> Anything else?
>
> The fastpath for slub works only within the bounds of a single slab page.
> Therefore a larger frame increases the number of allocation possible from
> the fastpath without having to use the slowpath and also reduces the
> management overhead in the partial lists.

Hello Christoph.

Now we have cpu partial slabs facility, so I think that slowpath isn't really
slow. And it doesn't much increase the management overhead in the node
partial lists, because of cpu partial slabs.

And larger frame may cause more slab_lock contention or cmpxchg contention
if there are parallel freeings.

But, I don't know which one is better. Is larger frame still better? :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
