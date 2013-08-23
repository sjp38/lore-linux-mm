Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8DE8A6B0034
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 12:12:12 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id ij15so560323vcb.16
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 09:12:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <00000140abd66e64-21601d31-3ba2-42bd-8153-9f1d41fcc0d9-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1377161065-30552-6-git-send-email-iamjoonsoo.kim@lge.com>
	<00000140a72870a6-f7c87696-ecbc-432c-9f41-93f414c0c623-000000@email.amazonses.com>
	<20130823065315.GG22605@lge.com>
	<00000140ab69e6be-3b2999b6-93b4-4b22-a91f-8929aee5238f-000000@email.amazonses.com>
	<CAAmzW4NZHXXX08tdQitwapfi8raQ-BTRry92A0jdFQkm0vaqxw@mail.gmail.com>
	<00000140abd66e64-21601d31-3ba2-42bd-8153-9f1d41fcc0d9-000000@email.amazonses.com>
Date: Sat, 24 Aug 2013 01:12:11 +0900
Message-ID: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com>
Subject: Re: [PATCH 05/16] slab: remove cachep in struct slab_rcu
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2013/8/24 Christoph Lameter <cl@linux.com>:
> On Fri, 23 Aug 2013, JoonSoo Kim wrote:
>
>> I don't get it. This patch only affect to the rcu case, because it
>> change the code
>> which is in kmem_rcu_free(). It doesn't touch anything in standard case.
>
> In general this patchset moves struct slab to overlay struct page. The
> design of SLAB was (at least at some point in the past) to avoid struct
> page references. The freelist was kept close to struct slab so that the
> contents are in the same cache line. Moving fields to struct page will add
> another cacheline to be referenced.

I don't think so.
We should touch the struct page in order to get the struct slab, so there is
no additional cacheline reference.

And if the size of the (slab + freelist) decreases due to this patchset,
there is more chance to be on-slab which means that the freelist is in pages
of a slab itself. I think that it also help cache usage.

> The freelist (bufctl_t) was dimensioned in such a way as to be small
> and close cache wise to struct slab.

I think that my patchset don't harm anything related to this.
As I said, we should access the struct page before getting the struct slab,
so the fact that freelist is far from the struct slab doesn't mean additional
cache overhead.

* Before patchset
struct page -> struct slab (far from struct page)
   -> the freelist (near from struct slab)

* After patchset
struct page (overload by struct slab) -> the freelist (far from struct page)

Somewhow bufctl_t grew to
> unsigned int and therefore the table became a bit large. Fundamentally
> these are indexes into the objects in page. They really could be sized
> again to just be single bytes as also explained in the comments in slab.c:
> /*
>  * kmem_bufctl_t:
>  *
>  * Bufctl's are used for linking objs within a slab
>  * linked offsets.
>  *
>  * This implementation relies on "struct page" for locating the cache &
>  * slab an object belongs to.
>  * This allows the bufctl structure to be small (one int), but limits
>  * the number of objects a slab (not a cache) can contain when off-slab
>  * bufctls are used. The limit is the size of the largest general cache
>  * that does not use off-slab slabs.
>  * For 32bit archs with 4 kB pages, is this 56.
>  * This is not serious, as it is only for large objects, when it is unwise
>  * to have too many per slab.
>  * Note: This limit can be raised by introducing a general cache whose size
>  * is less than 512 (PAGE_SIZE<<3), but greater than 256.
>  */
>
> For 56 objects the bufctl_t could really be reduced to an 8 bit integer
> which would shrink the size of the table significantly and improve speed
> by reducing cache footprint.
>

Yes, that's very good. However this is not related to this patchset.
It can be implemented independently :)

Please let me know what I am missing.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
