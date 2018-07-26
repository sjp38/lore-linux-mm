Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5D36B0010
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:50:38 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w14-v6so1857061qkw.2
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:50:38 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x67-v6si1678712qkc.134.2018.07.26.09.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 09:50:37 -0700 (PDT)
Subject: Re: freepage accounting bug with CMA/migrate isolation
References: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
 <efc17c04-8498-29c8-56bb-9cbad897f0d8@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fb90a412-ead7-0ada-c443-2bd1c41f2614@oracle.com>
Date: Thu, 26 Jul 2018 09:50:32 -0700
MIME-Version: 1.0
In-Reply-To: <efc17c04-8498-29c8-56bb-9cbad897f0d8@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>

On 07/26/2018 05:28 AM, Vlastimil Babka wrote:
> On 07/24/2018 06:24 AM, Mike Kravetz wrote:
>> With v4.17, I can see an issue like those addressed in commits 3c605096d315
>> ("mm/page_alloc: restrict max order of merging on isolated pageblock")
>> and d9dddbf55667 ("mm/page_alloc: prevent merging between isolated and
>> other pageblocks").  After running a CMA stress test for a while, I see:
>>   MemTotal:        8168384 kB
>>   MemFree:         8457232 kB
>>   MemAvailable:    9204844 kB
>> If I let the test run, MemFree and MemAvailable will continue to grow.
>>
>> I am certain the issue is with pageblocks of migratetype ISOLATED.  If
>> I disable all special 'is_migrate_isolate' checks in freepage accounting,
>> the issue goes away.
> 
> That means you count isolated pages as freepages, right?

Yes,  I know it is not correct.  But, just wanted to eliminate the
isolated pageblock special case for experimentation.

>> Further, I am pretty sure the issue has to do with
>> pageblock merging and or page orders spanning pageblocks.  If I make
>> pageblock_order equal MAX_ORDER-1, the issue also goes away.
> 
> Interesting, that should only matter in __free_one_page(). Do you have
> page guards enabled?

Nope, no page guards.
Do note that in this case, I added back all the special 'is_migrate_isolate'
checks.  So, just stock 4.17 with the change to make pageblock_order equal
MAX_ORDER-1.

>> Just looking for suggesting in where/how to debug.  I've been hacking on
>> this without much success.

As mentioned in my reply to Laura, I noticed that move_freepages_block()
can move more than a pageblock of pages.  This is the case where page_order
of the (first) free page is > pageblock_order.  Should only happen in the
set_migratetype_isolate case as unset has that check you added.  This
generally 'works' as alloc_contig_range rounds up to MAX_ORDER(-1).  So,
set and unset migrate isolate tend to balance out.  But, I am wondering
if there might be some kind of race where someone could mess with those
pageblocks (and freepage counts) while we drop the zone lock.  Trying to
put together a quick hack to test this theory, but it is more complicated
that first thought. :)
-- 
Mike Kravetz
