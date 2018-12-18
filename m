Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9978E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:18:17 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w18so22772659qts.8
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 14:18:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 54si537323qtm.62.2018.12.18.14.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 14:18:16 -0800 (PST)
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <58509504-4c30-3385-6eda-72c2abad60e7@redhat.com>
 <20181218214956.svedrxevycbgwsuk@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <228bdd64-bce8-5449-77f4-788ffd1ee734@redhat.com>
Date: Tue, 18 Dec 2018 23:18:13 +0100
MIME-Version: 1.0
In-Reply-To: <20181218214956.svedrxevycbgwsuk@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de

On 18.12.18 22:49, Wei Yang wrote:
> On Tue, Dec 18, 2018 at 10:14:25PM +0100, David Hildenbrand wrote:
>> On 18.12.18 21:46, Wei Yang wrote:
>>> Below is a brief call flow for __offline_pages() and
>>> alloc_contig_range():
>>>
>>>   __offline_pages()/alloc_contig_range()
>>>       start_isolate_page_range()
>>>           set_migratetype_isolate()
>>>               drain_all_pages()
>>>       drain_all_pages()
>>>
>>> Current logic is: isolate and drain pcp list for each pageblock and
>>> drain pcp list again. This is not necessary and we could just drain pcp
>>> list once after isolate this whole range.
>>>
>>> The reason is start_isolate_page_range() will set the migrate type of
>>> a range to MIGRATE_ISOLATE. After doing so, this range will never be
>>> allocated from Buddy, neither to a real user nor to pcp list.
>>>
>>> Since drain_all_pages() is zone based, by reduce times of
>>> drain_all_pages() also reduce some contention on this particular zone.
>>>
>>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>>
>> Yes, as far as I can see, when a MIGRATE_ISOLATE page gets freed, it
>> will not go onto the pcp list again.
>>
>> However, start_isolate_page_range() is also called via
>> alloc_contig_range(). Are you sure we can effectively drop the
>> drain_all_pages() for that call path?
>>
> 
> alloc_contig_range() does following now:
> 
>    - isolate page range
>    - do reclaim and migration
>    - drain lru
>    - drain pcp list
> 
> If step 2 fails, it will not drain lru and pcp list.
> 
> I don't see we have to drain pcp list before step 2. And after this
> change, it will save some effort if step 2 fails.

Sorry, I missed that you actually documented the "alloc_contig_range"
scenario in you patch description. My fault!

Acked-by: David Hildenbrand <david@redhat.com>


-- 

Thanks,

David / dhildenb
