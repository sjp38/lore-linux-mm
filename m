Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 900776B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 22:48:28 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e21-v6so4298289itc.5
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:48:28 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h5-v6si9407443jad.11.2018.07.24.19.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 19:48:27 -0700 (PDT)
Subject: Re: freepage accounting bug with CMA/migrate isolation
References: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
 <92636e32-c71b-0092-02bf-a802065075ef@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <1384e612-e664-6278-af22-9113c12f76d8@oracle.com>
Date: Tue, 24 Jul 2018 17:46:11 -0700
MIME-Version: 1.0
In-Reply-To: <92636e32-c71b-0092-02bf-a802065075ef@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>

On 07/24/2018 03:38 PM, Laura Abbott wrote:
> On 07/23/2018 09:24 PM, Mike Kravetz wrote:
>> With v4.17, I can see an issue like those addressed in commits 3c605096d315
>> ("mm/page_alloc: restrict max order of merging on isolated pageblock")
>> and d9dddbf55667 ("mm/page_alloc: prevent merging between isolated and
>> other pageblocks").  After running a CMA stress test for a while, I see:
>>    MemTotal:        8168384 kB
>>    MemFree:         8457232 kB
>>    MemAvailable:    9204844 kB
>> If I let the test run, MemFree and MemAvailable will continue to grow.
>>
>> I am certain the issue is with pageblocks of migratetype ISOLATED.  If
>> I disable all special 'is_migrate_isolate' checks in freepage accounting,
>> the issue goes away.  Further, I am pretty sure the issue has to do with
>> pageblock merging and or page orders spanning pageblocks.  If I make
>> pageblock_order equal MAX_ORDER-1, the issue also goes away.
>>
>> Just looking for suggesting in where/how to debug.  I've been hacking on
>> this without much success.
>> -- 
>> Mike Kravetz
>>
> 
> If you revert d883c6cf3b39 ("Revert "mm/cma: manage the memory of the CMA
> area by using the ZONE_MOVABLE"") do you still see the issue? I thought
> there was another isolation edge case which was fixed by that series.
> 

Thanks Laura,

Reverting that patch certainly seems to help.  Although, I'm guessing there
is still some accounting issue even with the patch reverted.

Right after boot,
MemTotal:        8168380 kB
MemFree:         7233360 kB
MemAvailable:    7317704 kB

After stress testing for a couple hours,
MemTotal:        8168380 kB
MemFree:         7848468 kB
MemAvailable:    7634856 kB

While looking at the code, I did not like the way set_migratetype_isolate
may 'isolate' more than pageblock_nr_pages if there is a > pageblock_order
sized free page.  This seems to work because alloc_contig_range always
aligns to MAX_ORDER-1.  But, I'd like to change this and see if it helps.

-- 
Mike Kravetz
