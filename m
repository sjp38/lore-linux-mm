Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF6C76B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 10:52:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f17-v6so21280346plr.1
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 07:52:18 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id x32-v6si17693282pld.323.2018.10.17.07.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 07:52:17 -0700 (PDT)
Subject: Re: [mm PATCH v3 1/6] mm: Use mm_zero_struct_page from SPARC on all
 64b architectures
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202656.2171.92963.stgit@localhost.localdomain>
 <57c559f6-4858-7a52-7fbb-979caa08f240@gmail.com>
 <20181017073045.GA20004@rapoport-lnx>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <debbf05a-5ab8-3886-f199-0bbdede7f50e@linux.intel.com>
Date: Wed, 17 Oct 2018 07:52:16 -0700
MIME-Version: 1.0
In-Reply-To: <20181017073045.GA20004@rapoport-lnx>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Pavel Tatashin <pasha.tatashin@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 10/17/2018 12:30 AM, Mike Rapoport wrote:
> On Tue, Oct 16, 2018 at 03:01:11PM -0400, Pavel Tatashin wrote:
>>
>>
>> On 10/15/18 4:26 PM, Alexander Duyck wrote:
>>> This change makes it so that we use the same approach that was already in
>>> use on Sparc on all the archtectures that support a 64b long.
>>>
>>> This is mostly motivated by the fact that 8 to 10 store/move instructions
>>> are likely always going to be faster than having to call into a function
>>> that is not specialized for handling page init.
>>>
>>> An added advantage to doing it this way is that the compiler can get away
>>> with combining writes in the __init_single_page call. As a result the
>>> memset call will be reduced to only about 4 write operations, or at least
>>> that is what I am seeing with GCC 6.2 as the flags, LRU poitners, and
>>> count/mapcount seem to be cancelling out at least 4 of the 8 assignments on
>>> my system.
>>>
>>> One change I had to make to the function was to reduce the minimum page
>>> size to 56 to support some powerpc64 configurations.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>
>>
>> I have tested on Broadcom's Stingray cpu with 48G RAM:
>> __init_single_page() takes 19.30ns / 64-byte struct page
>> Wit the change it takes 17.33ns / 64-byte struct page
>   
> I gave it a run on an OpenPower (S812LC 8348-21C) with Power8 processor and
> with 128G of RAM. My results for 64-byte struct page were:
> 
> before: 4.6788ns
> after: 4.5882ns
> 
> My two cents :)

Thanks. I will add this and Pavel's data to the patch description.

- Alex
