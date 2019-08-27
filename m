Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3687C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 05:46:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95ADC20828
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 05:46:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95ADC20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E29D6B000C; Tue, 27 Aug 2019 01:46:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B8FA6B000D; Tue, 27 Aug 2019 01:46:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A6C06B000E; Tue, 27 Aug 2019 01:46:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id EB53C6B000C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:46:40 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 90EA352AB
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 05:46:40 +0000 (UTC)
X-FDA: 75867123360.09.head64_7468ac0d82645
X-HE-Tag: head64_7468ac0d82645
X-Filterd-Recvd-Size: 12402
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 05:46:39 +0000 (UTC)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7R5gOhq021867
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:46:39 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2umuhmnkqt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:46:38 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 27 Aug 2019 06:46:36 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 27 Aug 2019 06:46:25 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7R5kNDT38404272
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 27 Aug 2019 05:46:23 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 452545204F;
	Tue, 27 Aug 2019 05:46:23 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.35.114])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9C8D35204E;
	Tue, 27 Aug 2019 05:46:15 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@kernel.org>,
        Anshuman Khandual <anshuman.khandual@arm.com>,
        Arun KS <arunks@codeaurora.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Borislav Petkov <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Dan Williams <dan.j.williams@intel.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Fenghua Yu <fenghua.yu@intel.com>,
        Gerald Schaefer <gerald.schaefer@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Halil Pasic <pasic@linux.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Jun Yao <yaojun8558363@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        "Matthew Wilcox \(Oracle\)" <willy@infradead.org>,
        Mel Gorman <mgorman@techsingularity.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>,
        Paul Mackerras <paulus@samba.org>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Pavel Tatashin <pavel.tatashin@microsoft.com>,
        Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
        Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
        Steve Capper <steve.capper@arm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>,
        Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>,
        Wei Yang <richardw.yang@linux.intel.com>,
        Will Deacon <will@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v2 0/6] mm/memory_hotplug: Consider all zones when removing memory
In-Reply-To: <f1f5d981-b633-dc39-0b92-3619e4b8f0a5@redhat.com>
References: <20190826101012.10575-1-david@redhat.com> <87pnksm0zx.fsf@linux.ibm.com> <194da076-364e-267d-0d51-64940925e2e4@redhat.com> <a30b7156-7679-a04a-f74a-c5407b922979@linux.ibm.com> <dc850fea-32c1-a7ed-fad1-727a446a67ca@redhat.com> <f1f5d981-b633-dc39-0b92-3619e4b8f0a5@redhat.com>
Date: Tue, 27 Aug 2019 11:16:14 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19082705-4275-0000-0000-0000035DC82F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082705-4276-0000-0000-0000386FF74C
Message-Id: <87mufvma8p.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-26_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908270064
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

David Hildenbrand <david@redhat.com> writes:

> On 26.08.19 18:20, David Hildenbrand wrote:
>> On 26.08.19 18:01, Aneesh Kumar K.V wrote:
>>> On 8/26/19 9:13 PM, David Hildenbrand wrote:
>>>> On 26.08.19 16:53, Aneesh Kumar K.V wrote:
>>>>> David Hildenbrand <david@redhat.com> writes:
>>>>>
>>>>>>
>>>
>>> ....
>>>
>>>>>
>>>>> I did report a variant of the issue at
>>>>>
>>>>> https://lore.kernel.org/linux-mm/20190514025354.9108-1-aneesh.kumar@linux.ibm.com/
>>>>>
>>>>> This patch series still doesn't handle the fact that struct page backing
>>>>> the start_pfn might not be initialized. ie, it results in crash like
>>>>> below
>>>>
>>>> Okay, that's a related but different issue I think.
>>>>
>>>> I can see that current shrink_zone_span() might read-access the
>>>> uninitialized struct page of a PFN if
>>>>
>>>> 1. The zone has holes and we check for "zone all holes". If we get
>>>> pfn_valid(pfn), we check if "page_zone(pfn_to_page(pfn)) != zone".
>>>>
>>>> 2. Via find_smallest_section_pfn() / find_biggest_section_pfn() find a
>>>> spanned pfn_valid(). We check
>>>> - pfn_to_nid(start_pfn) != nid
>>>> - zone != page_zone(pfn_to_page(start_pfn)
>>>>
>>>> So we don't actually use the zone/nid, only use it to sanity check. That
>>>> might result in false-positives (not that bad).
>>>>
>>>> It all boils down to shrink_zone_span() not working only on active
>>>> memory, for which the PFN is not only valid but also initialized
>>>> (something for which we need a new section flag I assume).
>>>>
>>>> Which access triggers the issue you describe? pfn_to_nid()?
>>>>
>>>>>
>>>>>      pc: c0000000004bc1ec: shrink_zone_span+0x1bc/0x290
>>>>>      lr: c0000000004bc1e8: shrink_zone_span+0x1b8/0x290
>>>>>      sp: c0000000dac7f910
>>>>>     msr: 800000000282b033
>>>>>    current = 0xc0000000da2fa000
>>>>>    paca    = 0xc00000000fffb300   irqmask: 0x03   irq_happened: 0x01
>>>>>      pid   = 1224, comm = ndctl
>>>>> kernel BUG at /home/kvaneesh/src/linux/include/linux/mm.h:1088!
>>>>> Linux version 5.3.0-rc6-17495-gc7727d815970-dirty (kvaneesh@ltc-boston123) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #183 SMP Mon Aug 26 09:37:32 CDT 2019
>>>>> enter ? for help
>>>>
>>>> Which exact kernel BUG are you hitting here? (my tree doesn't seem t
>>>> have any BUG statement around  include/linux/mm.h:1088). 
>>>
>>>
>>>
>>> This is against upstream linus with your patches applied.
>> 
>> I'm
>> 
>>>
>>>
>>> static inline int page_to_nid(const struct page *page)
>>> {
>>> 	struct page *p = (struct page *)page;
>>>
>>> 	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
>>> }
>>>
>>>
>>> #define PF_POISONED_CHECK(page) ({					\
>>> 		VM_BUG_ON_PGFLAGS(PagePoisoned(page), page);		\
>>> 		page; })
>>> #
>>>
>>>
>>> It is the node id access.
>> 
>> A right. A temporary hack would be to assume in these functions
>> (shrink_zone_span() and friends) that we might have invalid NIDs /
>> zonenumbers and simply skip these. After all we're only using them for
>> finding zone boundaries. Not what we ultimately want, but I think until
>> we have a proper SECTION_ACTIVE, it might take a while.
>> 
>
> I am talking about something as hacky as this:
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8d1c7313ab3f..57ed3dd76a4f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1099,6 +1099,7 @@ static inline int page_zone_id(struct page *page)
>
>  #ifdef NODE_NOT_IN_PAGE_FLAGS
>  extern int page_to_nid(const struct page *page);
> +#define __page_to_nid page_to_nid
>  #else
>  static inline int page_to_nid(const struct page *page)
>  {
> @@ -1106,6 +1107,10 @@ static inline int page_to_nid(const struct page
> *page)
>
>  	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
>  }
> +static inline int __page_to_nid(const struct page *page)
> +{
> +	return ((page)->flags >> NODES_PGSHIFT) & NODES_MASK;
> +}
>  #endif
>
>  #ifdef CONFIG_NUMA_BALANCING
> @@ -1249,6 +1254,12 @@ static inline struct zone *page_zone(const struct
> page *page)
>  	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
>  }
>
> +static inline struct zone *__page_zone(const struct page *page)
> +{
> +	return &NODE_DATA(__page_to_nid(page))->node_zones[page_zonenum(page)];
> +}

We don't need that. We can always do an explicity __page_to_nid check
and break from the loop before doing a page_zone() ? Also if the struct
page is poisoned, we should not trust the page_zonenum()? 

> +
> +
>  static inline pg_data_t *page_pgdat(const struct page *page)
>  {
>  	return NODE_DATA(page_to_nid(page));
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 49ca3364eb70..378b593d1fe1 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -334,10 +334,10 @@ static unsigned long find_smallest_section_pfn(int
> nid, struct zone *zone,
>  		if (unlikely(!pfn_valid(start_pfn)))
>  			continue;
>
> -		if (unlikely(pfn_to_nid(start_pfn) != nid))
> +		/* We might have uninitialized memmaps */
> +		if (unlikely(__page_to_nid(pfn_to_page(start_pfn)) != nid))
>  			continue;

if we are here we got non poisoned struct page. Hence we don't need the
below change?

> -
> -		if (zone && zone != page_zone(pfn_to_page(start_pfn)))
> +		if (zone && zone != __page_zone(pfn_to_page(start_pfn)))
>  			continue;
>
>  		return start_pfn;
> @@ -359,10 +359,10 @@ static unsigned long find_biggest_section_pfn(int
> nid, struct zone *zone,
>  		if (unlikely(!pfn_valid(pfn)))
>  			continue;
>
> -		if (unlikely(pfn_to_nid(pfn) != nid))
> +		/* We might have uninitialized memmaps */
> +		if (unlikely(__page_to_nid(pfn_to_page(pfn)) != nid))
>  			continue;

same as above

> -
> -		if (zone && zone != page_zone(pfn_to_page(pfn)))
> +		if (zone && zone != __page_zone(pfn_to_page(pfn)))
>  			continue;
>
>  		return pfn;
> @@ -418,7 +418,10 @@ static void shrink_zone_span(struct zone *zone,
> unsigned long start_pfn,
>  		if (unlikely(!pfn_valid(pfn)))
>  			continue;
>
> -		if (page_zone(pfn_to_page(pfn)) != zone)
> +		/* We might have uninitialized memmaps */
> +		if (unlikely(__page_to_nid(pfn_to_page(pfn)) != nid))
> +			continue;

same as above? 

> +		if (__page_zone(pfn_to_page(pfn)) != zone)
>  			continue;
>
>  		/* Skip range to be removed */
> @@ -483,7 +486,8 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
>  		if (unlikely(!pfn_valid(pfn)))
>  			continue;
>
> -		if (pfn_to_nid(pfn) != nid)
> +		/* We might have uninitialized memmaps */
> +		if (unlikely(__page_to_nid(pfn_to_page(pfn)) != nid))
>  			continue;
>
>  		/* Skip range to be removed */
>


But I am not sure whether this is the right approach.

-aneesh


