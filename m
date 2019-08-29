Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0817C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:55:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72A6120828
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:55:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72A6120828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC3E76B0005; Thu, 29 Aug 2019 12:55:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4C606B0006; Thu, 29 Aug 2019 12:55:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CED236B0008; Thu, 29 Aug 2019 12:55:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0013.hostedemail.com [216.40.44.13])
	by kanga.kvack.org (Postfix) with ESMTP id A36186B0005
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:55:52 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 52191181AC9AE
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:55:52 +0000 (UTC)
X-FDA: 75876067344.04.soda76_6d539de466912
X-HE-Tag: soda76_6d539de466912
X-Filterd-Recvd-Size: 13755
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:55:51 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CA98D31752B1;
	Thu, 29 Aug 2019 16:55:49 +0000 (UTC)
Received: from [10.36.117.243] (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7C88219C4F;
	Thu, 29 Aug 2019 16:55:43 +0000 (UTC)
Subject: Re: [PATCH v3 01/11] mm/memremap: Get rid of
 memmap_init_zone_device()
To: Alexander Duyck <alexander.duyck@gmail.com>,
 Dan Williams <dan.j.williams@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>, Dave Airlie <airlied@redhat.com>,
 Andrey Konovalov <andreyknvl@google.com>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Ira Weiny <ira.weiny@intel.com>, John Hubbard <jhubbard@nvidia.com>,
 Arun KS <arunks@codeaurora.org>, Souptick Joarder <jrdr.linux@gmail.com>,
 Robin Murphy <robin.murphy@arm.com>, Yang Shi <yang.shi@linux.alibaba.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Logan Gunthorpe <logang@deltatee.com>,
 Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Alexander Potapenko <glider@google.com>
References: <20190829070019.12714-1-david@redhat.com>
 <20190829070019.12714-2-david@redhat.com>
 <CAKgT0UdKwYhF++=b=vN_Kw_SORtgJ3ehCAn8a9kp8tb79HknyQ@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <46b8e215-97d4-9097-9941-58e050c5efcc@redhat.com>
Date: Thu, 29 Aug 2019 18:55:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdKwYhF++=b=vN_Kw_SORtgJ3ehCAn8a9kp8tb79HknyQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 29 Aug 2019 16:55:50 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.08.19 18:39, Alexander Duyck wrote:
> On Thu, Aug 29, 2019 at 12:00 AM David Hildenbrand <david@redhat.com> w=
rote:
>>
>> As far as I can see, the original split wanted to speed up a duplicate
>> initialization. We now only initialize once - and we really should
>> initialize under the lock, when resizing the zones.
>=20
> What do you mean by duplicate initialization? Basically the issue was
> that we can have systems with massive memory footprints and I was just
> trying to get the initialization time under a minute. The compromise I
> made was to split the initialization so that we only initialized the
> pages in the altmap and defer the rest so that they can be initialized
> in parallel.
>=20
> What this patch does is serialize the initialization so it will likely
> take 2 to 4 minutes or more to initialize memory on a system where I
> had brought the init time under about 30 seconds.
>=20
>> As soon as we drop the lock we might have memory unplug running, tryin=
g
>> to shrink the zone again. In case the memmap was not properly initiali=
zed,
>> the zone/node shrinking code might get false negatives when search for
>> the new zone/node boundaries - bad. We suddenly could no longer span t=
he
>> memory we just added.
>=20
> The issue as I see it is that we can have systems with multiple nodes
> and each node can populate a fairly significant amount of data. By
> pushing this all back under the hotplug lock you are serializing the
> initialization for each node resulting in a 4x or 8x increase in
> initialization time on some of these bigger systems.
>=20
>> Also, once we want to fix set_zone_contiguous(zone) inside
>> move_pfn_range_to_zone() to actually work with ZONE_DEVICE (instead of
>> always immediately stopping and never setting zone->contiguous) we hav=
e
>> to have the whole memmap initialized at that point. (not sure if we
>> want that in the future, just a note)
>>
>> Let's just keep things simple and initialize the memmap when resizing
>> the zones under the lock.
>>
>> If this is a real performance issue, we have to watch out for
>> alternatives.
>=20
> My concern is that this is going to become a performance issue, but I
> don't have access to the hardware at the moment to test how much of
> one. I'll have to check to see if I can get access to a system to test
> this patch set.
>=20

Thanks for having a look - I already dropped this patch again. We will
rather stop shrinking the ZONE_DEVICE. So assume this patch is gone.

[...]

> So if you are moving this all under the lock then this is going to
> serialize initialization and it is going to be quite expensive on bit
> systems. I was only ever able to get the init time down to something
> like ~20s with the optimized function. Since that has been torn apart
> and you are back to doing things with memmap_init_zone we are probably
> looking at more like 25-30s for each node, and on a 4 node system we
> are looking at 2 minutes or so which may lead to issues if people are
> mounting this.
>=20
> Instead of forcing this all to be done under the hotplug lock is there
> some way we could do this under the zone span_seqlock instead to
> achieve the same result?

I guess the right approach really is as Michal suggest to not shrink at
all (at least ZONE_DEVICE) :)

>=20
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index c5d62f1c2851..44038665fe8e 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5845,7 +5845,7 @@ overlap_memmap_init(unsigned long zone, unsigned=
 long *pfn)
>>   */
>>  void __meminit memmap_init_zone(unsigned long size, int nid, unsigned=
 long zone,
>>                 unsigned long start_pfn, enum memmap_context context,
>> -               struct vmem_altmap *altmap)
>> +               struct dev_pagemap *pgmap)
>>  {
>>         unsigned long pfn, end_pfn =3D start_pfn + size;
>>         struct page *page;
>> @@ -5853,24 +5853,6 @@ void __meminit memmap_init_zone(unsigned long s=
ize, int nid, unsigned long zone,
>>         if (highest_memmap_pfn < end_pfn - 1)
>>                 highest_memmap_pfn =3D end_pfn - 1;
>>
>> -#ifdef CONFIG_ZONE_DEVICE
>> -       /*
>> -        * Honor reservation requested by the driver for this ZONE_DEV=
ICE
>> -        * memory. We limit the total number of pages to initialize to=
 just
>> -        * those that might contain the memory mapping. We will defer =
the
>> -        * ZONE_DEVICE page initialization until after we have release=
d
>> -        * the hotplug lock.
>> -        */
>> -       if (zone =3D=3D ZONE_DEVICE) {
>> -               if (!altmap)
>> -                       return;
>> -
>> -               if (start_pfn =3D=3D altmap->base_pfn)
>> -                       start_pfn +=3D altmap->reserve;
>> -               end_pfn =3D altmap->base_pfn + vmem_altmap_offset(altm=
ap);
>> -       }
>> -#endif
>> -
>>         for (pfn =3D start_pfn; pfn < end_pfn; pfn++) {
>>                 /*
>>                  * There can be holes in boot-time mem_map[]s handed t=
o this
>> @@ -5892,6 +5874,20 @@ void __meminit memmap_init_zone(unsigned long s=
ize, int nid, unsigned long zone,
>>                 if (context =3D=3D MEMMAP_HOTPLUG)
>>                         __SetPageReserved(page);
>>
>> +#ifdef CONFIG_ZONE_DEVICE
>> +               if (zone =3D=3D ZONE_DEVICE) {
>> +                       WARN_ON_ONCE(!pgmap);
>> +                       /*
>> +                        * ZONE_DEVICE pages union ->lru with a ->pgma=
p back
>> +                        * pointer and zone_device_data. It is a bug i=
f a
>> +                        * ZONE_DEVICE page is ever freed or placed on=
 a driver
>> +                        * private list.
>> +                        */
>> +                       page->pgmap =3D pgmap;
>> +                       page->zone_device_data =3D NULL;
>> +               }
>> +#endif
>> +
>=20
> So I am not sure this is right. Part of the reason for the split is
> that the pages that were a part of the altmap had an LRU setup, not
> the pgmap/zone_device_data setup. This is changing that.

Yeah, you might be right, we would have to handle the altmap part
separately.

>=20
> Also, I am more a fan of just testing pgmap and if it is present then
> assign page->pgmap and reset zone_device_data. Then you can avoid the
> test for zone on every iteration and the WARN_ON_ONCE check, or at
> least you could move it outside the loop so we don't incur the cost
> with each page. Are there situations where you would have pgmap but
> not a ZONE_DEVICE page?

Don't think so. But I am definitely not a ZONE_DEVICE expert.

>=20
>>                 /*
>>                  * Mark the block movable so that blocks are reserved =
for
>>                  * movable at startup. This will force kernel allocati=
ons
>> @@ -5951,14 +5947,6 @@ void __ref memmap_init_zone_device(struct zone =
*zone,
>>                  */
>>                 __SetPageReserved(page);
>>
>> -               /*
>> -                * ZONE_DEVICE pages union ->lru with a ->pgmap back p=
ointer
>> -                * and zone_device_data.  It is a bug if a ZONE_DEVICE=
 page is
>> -                * ever freed or placed on a driver-private list.
>> -                */
>> -               page->pgmap =3D pgmap;
>> -               page->zone_device_data =3D NULL;
>> -
>>                 /*
>>                  * Mark the block movable so that blocks are reserved =
for
>>                  * movable at startup. This will force kernel allocati=
ons
>=20
> Shouldn't you be removing this function instead of just gutting it?
> I'm kind of surprised you aren't getting warnings about unused code
> since you also pulled the declaration for it from the header.
>=20

Don't ask me what went wrong here, I guess I messed this up while rebasin=
g.

--=20

Thanks,

David / dhildenb

