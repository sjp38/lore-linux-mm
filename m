Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFE59C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D6CD217F5
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 07:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D6CD217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00E036B000A; Tue, 27 Aug 2019 03:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F26AF6B000C; Tue, 27 Aug 2019 03:06:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E14B76B000D; Tue, 27 Aug 2019 03:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id B70B56B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 03:06:42 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6DB216405
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:06:42 +0000 (UTC)
X-FDA: 75867325044.22.paper61_5782eaaa3360e
X-HE-Tag: paper61_5782eaaa3360e
X-Filterd-Recvd-Size: 15058
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:06:41 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 44BC13060289;
	Tue, 27 Aug 2019 07:06:39 +0000 (UTC)
Received: from [10.36.117.50] (ovpn-117-50.ams2.redhat.com [10.36.117.50])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8BBB05C1D6;
	Tue, 27 Aug 2019 07:06:28 +0000 (UTC)
Subject: Re: [PATCH v2 0/6] mm/memory_hotplug: Consider all zones when
 removing memory
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski
 <luto@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>,
 Arun KS <arunks@codeaurora.org>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Dan Williams <dan.j.williams@intel.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Halil Pasic <pasic@linux.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Johannes Weiner <hannes@cmpxchg.org>,
 Jun Yao <yaojun8558363@gmail.com>, Logan Gunthorpe <logang@deltatee.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Mel Gorman <mgorman@techsingularity.net>,
 Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>,
 Paul Mackerras <paulus@samba.org>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
 Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
 Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Tom Lendacky <thomas.lendacky@amd.com>, Tony Luck <tony.luck@intel.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>,
 Wei Yang <richard.weiyang@gmail.com>,
 Wei Yang <richardw.yang@linux.intel.com>, Will Deacon <will@kernel.org>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Yu Zhao <yuzhao@google.com>
References: <20190826101012.10575-1-david@redhat.com>
 <87pnksm0zx.fsf@linux.ibm.com>
 <194da076-364e-267d-0d51-64940925e2e4@redhat.com>
 <a30b7156-7679-a04a-f74a-c5407b922979@linux.ibm.com>
 <dc850fea-32c1-a7ed-fad1-727a446a67ca@redhat.com>
 <f1f5d981-b633-dc39-0b92-3619e4b8f0a5@redhat.com>
 <87mufvma8p.fsf@linux.ibm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <1dbfc277-73d0-33d7-892c-289ff56d3e9b@redhat.com>
Date: Tue, 27 Aug 2019 09:06:27 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <87mufvma8p.fsf@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 27 Aug 2019 07:06:40 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.08.19 07:46, Aneesh Kumar K.V wrote:
> David Hildenbrand <david@redhat.com> writes:
>=20
>> On 26.08.19 18:20, David Hildenbrand wrote:
>>> On 26.08.19 18:01, Aneesh Kumar K.V wrote:
>>>> On 8/26/19 9:13 PM, David Hildenbrand wrote:
>>>>> On 26.08.19 16:53, Aneesh Kumar K.V wrote:
>>>>>> David Hildenbrand <david@redhat.com> writes:
>>>>>>
>>>>>>>
>>>>
>>>> ....
>>>>
>>>>>>
>>>>>> I did report a variant of the issue at
>>>>>>
>>>>>> https://lore.kernel.org/linux-mm/20190514025354.9108-1-aneesh.kuma=
r@linux.ibm.com/
>>>>>>
>>>>>> This patch series still doesn't handle the fact that struct page b=
acking
>>>>>> the start_pfn might not be initialized. ie, it results in crash li=
ke
>>>>>> below
>>>>>
>>>>> Okay, that's a related but different issue I think.
>>>>>
>>>>> I can see that current shrink_zone_span() might read-access the
>>>>> uninitialized struct page of a PFN if
>>>>>
>>>>> 1. The zone has holes and we check for "zone all holes". If we get
>>>>> pfn_valid(pfn), we check if "page_zone(pfn_to_page(pfn)) !=3D zone"=
.
>>>>>
>>>>> 2. Via find_smallest_section_pfn() / find_biggest_section_pfn() fin=
d a
>>>>> spanned pfn_valid(). We check
>>>>> - pfn_to_nid(start_pfn) !=3D nid
>>>>> - zone !=3D page_zone(pfn_to_page(start_pfn)
>>>>>
>>>>> So we don't actually use the zone/nid, only use it to sanity check.=
 That
>>>>> might result in false-positives (not that bad).
>>>>>
>>>>> It all boils down to shrink_zone_span() not working only on active
>>>>> memory, for which the PFN is not only valid but also initialized
>>>>> (something for which we need a new section flag I assume).
>>>>>
>>>>> Which access triggers the issue you describe? pfn_to_nid()?
>>>>>
>>>>>>
>>>>>>      pc: c0000000004bc1ec: shrink_zone_span+0x1bc/0x290
>>>>>>      lr: c0000000004bc1e8: shrink_zone_span+0x1b8/0x290
>>>>>>      sp: c0000000dac7f910
>>>>>>     msr: 800000000282b033
>>>>>>    current =3D 0xc0000000da2fa000
>>>>>>    paca    =3D 0xc00000000fffb300   irqmask: 0x03   irq_happened: =
0x01
>>>>>>      pid   =3D 1224, comm =3D ndctl
>>>>>> kernel BUG at /home/kvaneesh/src/linux/include/linux/mm.h:1088!
>>>>>> Linux version 5.3.0-rc6-17495-gc7727d815970-dirty (kvaneesh@ltc-bo=
ston123) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #183 SMP Mon=
 Aug 26 09:37:32 CDT 2019
>>>>>> enter ? for help
>>>>>
>>>>> Which exact kernel BUG are you hitting here? (my tree doesn't seem =
t
>>>>> have any BUG statement around  include/linux/mm.h:1088).=20
>>>>
>>>>
>>>>
>>>> This is against upstream linus with your patches applied.
>>>
>>> I'm
>>>
>>>>
>>>>
>>>> static inline int page_to_nid(const struct page *page)
>>>> {
>>>> 	struct page *p =3D (struct page *)page;
>>>>
>>>> 	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
>>>> }
>>>>
>>>>
>>>> #define PF_POISONED_CHECK(page) ({					\
>>>> 		VM_BUG_ON_PGFLAGS(PagePoisoned(page), page);		\
>>>> 		page; })
>>>> #
>>>>
>>>>
>>>> It is the node id access.
>>>
>>> A right. A temporary hack would be to assume in these functions
>>> (shrink_zone_span() and friends) that we might have invalid NIDs /
>>> zonenumbers and simply skip these. After all we're only using them fo=
r
>>> finding zone boundaries. Not what we ultimately want, but I think unt=
il
>>> we have a proper SECTION_ACTIVE, it might take a while.
>>>
>>
>> I am talking about something as hacky as this:
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 8d1c7313ab3f..57ed3dd76a4f 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1099,6 +1099,7 @@ static inline int page_zone_id(struct page *page=
)
>>
>>  #ifdef NODE_NOT_IN_PAGE_FLAGS
>>  extern int page_to_nid(const struct page *page);
>> +#define __page_to_nid page_to_nid
>>  #else
>>  static inline int page_to_nid(const struct page *page)
>>  {
>> @@ -1106,6 +1107,10 @@ static inline int page_to_nid(const struct page
>> *page)
>>
>>  	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
>>  }
>> +static inline int __page_to_nid(const struct page *page)
>> +{
>> +	return ((page)->flags >> NODES_PGSHIFT) & NODES_MASK;
>> +}
>>  #endif
>>
>>  #ifdef CONFIG_NUMA_BALANCING
>> @@ -1249,6 +1254,12 @@ static inline struct zone *page_zone(const stru=
ct
>> page *page)
>>  	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)]=
;
>>  }
>>
>> +static inline struct zone *__page_zone(const struct page *page)
>> +{
>> +	return &NODE_DATA(__page_to_nid(page))->node_zones[page_zonenum(page=
)];
>> +}
>=20
> We don't need that. We can always do an explicity __page_to_nid check
> and break from the loop before doing a page_zone() ? Also if the struct
> page is poisoned, we should not trust the page_zonenum()?=20

Assume __page_to_nid() works on a poisoned page. Then we might return a
garbage NID that by chance matches the NID. If we continue calling
page_zone(), we might trigger the same BUG.

"Also if the struct page is poisoned, we should not trust the
page_zonenum()?"

It's worse, we must not trust these values every. In case pages are not
poisoned when adding the memmap, they just contain random garbage.

>=20
>> +
>> +
>>  static inline pg_data_t *page_pgdat(const struct page *page)
>>  {
>>  	return NODE_DATA(page_to_nid(page));
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 49ca3364eb70..378b593d1fe1 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -334,10 +334,10 @@ static unsigned long find_smallest_section_pfn(i=
nt
>> nid, struct zone *zone,
>>  		if (unlikely(!pfn_valid(start_pfn)))
>>  			continue;
>>
>> -		if (unlikely(pfn_to_nid(start_pfn) !=3D nid))
>> +		/* We might have uninitialized memmaps */
>> +		if (unlikely(__page_to_nid(pfn_to_page(start_pfn)) !=3D nid))
>>  			continue;
>=20
> if we are here we got non poisoned struct page. Hence we don't need the
> below change?

No, we can't check if the values are poisoned. We can only assume we
might read garbage.

>=20
>> -
>> -		if (zone && zone !=3D page_zone(pfn_to_page(start_pfn)))
>> +		if (zone && zone !=3D __page_zone(pfn_to_page(start_pfn)))
>>  			continue;
>>
>>  		return start_pfn;
>> @@ -359,10 +359,10 @@ static unsigned long find_biggest_section_pfn(in=
t
>> nid, struct zone *zone,
>>  		if (unlikely(!pfn_valid(pfn)))
>>  			continue;
>>
>> -		if (unlikely(pfn_to_nid(pfn) !=3D nid))
>> +		/* We might have uninitialized memmaps */
>> +		if (unlikely(__page_to_nid(pfn_to_page(pfn)) !=3D nid))
>>  			continue;
>=20
> same as above
>=20
>> -
>> -		if (zone && zone !=3D page_zone(pfn_to_page(pfn)))
>> +		if (zone && zone !=3D __page_zone(pfn_to_page(pfn)))
>>  			continue;
>>
>>  		return pfn;
>> @@ -418,7 +418,10 @@ static void shrink_zone_span(struct zone *zone,
>> unsigned long start_pfn,
>>  		if (unlikely(!pfn_valid(pfn)))
>>  			continue;
>>
>> -		if (page_zone(pfn_to_page(pfn)) !=3D zone)
>> +		/* We might have uninitialized memmaps */
>> +		if (unlikely(__page_to_nid(pfn_to_page(pfn)) !=3D nid))
>> +			continue;
>=20
> same as above?=20
>=20
>> +		if (__page_zone(pfn_to_page(pfn)) !=3D zone)
>>  			continue;
>>
>>  		/* Skip range to be removed */
>> @@ -483,7 +486,8 @@ static void shrink_pgdat_span(struct pglist_data *=
pgdat,
>>  		if (unlikely(!pfn_valid(pfn)))
>>  			continue;
>>
>> -		if (pfn_to_nid(pfn) !=3D nid)
>> +		/* We might have uninitialized memmaps */
>> +		if (unlikely(__page_to_nid(pfn_to_page(pfn)) !=3D nid))
>>  			continue;
>>
>>  		/* Skip range to be removed */
>>
>=20
>=20
> But I am not sure whether this is the right approach.

It certainly isn't the right approach. It's a temporary hack. (trying
not to rant, ) we did a horribly job moving initialization of the memmap
to onlining of pages. We are now stuck with something that is
fundamentally broken.

Anyhow, I am looking into a proper solution, but it will need a new
bitmap for each section and some other more invasive changes. So that
might take a while.

--=20

Thanks,

David / dhildenb

