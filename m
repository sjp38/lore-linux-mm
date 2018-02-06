Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD676B028D
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 12:38:15 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id e28so2103186qkj.11
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 09:38:15 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z7si470578qkl.343.2018.02.06.09.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 09:38:14 -0800 (PST)
Subject: Re: [RFC PATCH v1 13/13] mm: splice local lists onto the front of the
 LRU
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <20180131230413.27653-14-daniel.m.jordan@oracle.com>
 <20180202052120.GA16272@intel.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <7b9c0aab-354d-c88b-3598-7bf91dd1ef74@oracle.com>
Date: Tue, 6 Feb 2018 12:38:31 -0500
MIME-Version: 1.0
In-Reply-To: <20180202052120.GA16272@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>

On 02/02/2018 12:21 AM, Aaron Lu wrote:
> On Wed, Jan 31, 2018 at 06:04:13PM -0500, daniel.m.jordan@oracle.com wrote:
>> Now that release_pages is scaling better with concurrent removals from
>> the LRU, the performance results (included below) showed increased
>> contention on lru_lock in the add-to-LRU path.
>>
>> To alleviate some of this contention, do more work outside the LRU lock.
>> Prepare a local list of pages to be spliced onto the front of the LRU,
>> including setting PageLRU in each page, before taking lru_lock.  Since
>> other threads use this page flag in certain checks outside lru_lock,
>> ensure each page's LRU links have been properly initialized before
>> setting the flag, and use memory barriers accordingly.
>>
>> Performance Results
>>
>> This is a will-it-scale run of page_fault1 using 4 different kernels.
>>
>>              kernel     kern #
>>
>>            4.15-rc2          1
>>    large-zone-batch          2
>>       lru-lock-base          3
>>     lru-lock-splice          4
>>
>> Each kernel builds on the last.  The first is a baseline, the second
>> makes zone->lock more scalable by increasing an order-0 per-cpu
>> pagelist's 'batch' and 'high' values to 310 and 1860 respectively
> 
> Since the purpose of the patchset is to optimize lru_lock, you may
> consider adjusting pcp->high to be >= 32768(page_fault1's test size is
> 128M = 32768 pages). That should eliminate zone->lock contention
> entirely.

Interesting, hadn't thought about taking zone->lock completely out of 
the equation.  Will try this next time I test this series.


While we're on this topic, it does seem from the performance of kernel 
#2, and the numbers Aaron posted in a previous thread[*], that the 
default 'batch' and 'high' values should be bigger on large systems.

The code to control these two values last changed in 2005[**], so we hit 
the largest values with just a 512M zone:

    zone       4k_pages  batch   high  high/4k_pages
     64M         16,384      3     18       0.10986%
    128M         32,768      7     42       0.12817%
    256M         65,536     15     90       0.13733%
    512M        131,072     31    186       0.14191%
      1G        262,144     31    186       0.07095%
      2G        524,288     31    186       0.03548%
      4G      1,048,576     31    186       0.01774%
      8G      2,097,152     31    186       0.00887%
     16G      4,194,304     31    186       0.00443%
     32G      8,388,608     31    186       0.00222%
     64G     16,777,216     31    186       0.00111%
    128G     33,554,432     31    186       0.00055%
    256G     67,108,864     31    186       0.00028%
    512G    134,217,728     31    186       0.00014%
   1024G    268,435,456     31    186       0.00007%


[*] https://marc.info/?l=linux-netdev&m=150572010919327
[**] ba56e91c9401 ("[PATCH] mm: page_alloc: increase size of per-cpu-pages")

> 
>> (courtesy of Aaron Lu's patch), the third scales lru_lock without
>> splicing pages (the previous patch in this series), and the fourth adds
>> page splicing (this patch).
>>
>> N tasks mmap, fault, and munmap anonymous pages in a loop until the test
>> time has elapsed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
