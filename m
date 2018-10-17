Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 531566B000A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:31:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a72-v6so11741424pfj.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:31:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t7-v6si16802518pfb.16.2018.10.17.09.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 09:31:22 -0700 (PDT)
Subject: Re: [mm PATCH v3 1/6] mm: Use mm_zero_struct_page from SPARC on all
 64b architectures
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202656.2171.92963.stgit@localhost.localdomain>
 <20181017084744.GH18839@dhcp22.suse.cz>
 <9700b00f-a8a4-e318-f6a8-71fd1e7021b3@linux.intel.com>
 <8aaa0fa2-5f12-ea3c-a0ca-ded9e1a639e2@gmail.com>
 <7d313318f1234a1eb45b608bd853c17c@AcuMS.aculab.com>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <e7cd1e6f-cc04-31ea-3322-5c8e25a6e58a@linux.intel.com>
Date: Wed, 17 Oct 2018 09:31:12 -0700
MIME-Version: 1.0
In-Reply-To: <7d313318f1234a1eb45b608bd853c17c@AcuMS.aculab.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, 'Pavel Tatashin' <pasha.tatashin@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pavel.tatashin@microsoft.com" <pavel.tatashin@microsoft.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "davem@davemloft.net" <davem@davemloft.net>, "yi.z.zhang@linux.intel.com" <yi.z.zhang@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "ldufour@linux.vnet.ibm.com" <ldufour@linux.vnet.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mingo@kernel.org" <mingo@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On 10/17/2018 8:40 AM, David Laight wrote:
> From: Pavel Tatashin
>> Sent: 17 October 2018 16:12
>> On 10/17/18 11:07 AM, Alexander Duyck wrote:
>>> On 10/17/2018 1:47 AM, Michal Hocko wrote:
>>>> On Mon 15-10-18 13:26:56, Alexander Duyck wrote:
>>>>> This change makes it so that we use the same approach that was
>>>>> already in
>>>>> use on Sparc on all the archtectures that support a 64b long.
>>>>>
>>>>> This is mostly motivated by the fact that 8 to 10 store/move
>>>>> instructions
>>>>> are likely always going to be faster than having to call into a function
>>>>> that is not specialized for handling page init.
>>>>>
>>>>> An added advantage to doing it this way is that the compiler can get
>>>>> away
>>>>> with combining writes in the __init_single_page call. As a result the
>>>>> memset call will be reduced to only about 4 write operations, or at
>>>>> least
>>>>> that is what I am seeing with GCC 6.2 as the flags, LRU poitners, and
>>>>> count/mapcount seem to be cancelling out at least 4 of the 8
>>>>> assignments on
>>>>> my system.
>>>>>
>>>>> One change I had to make to the function was to reduce the minimum page
>>>>> size to 56 to support some powerpc64 configurations.
>>>>
>>>> This really begs for numbers. I do not mind the change itself with some
>>>> minor comments below.
>>>>
>>>> [...]
>>>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>>>> index bb0de406f8e7..ec6e57a0c14e 100644
>>>>> --- a/include/linux/mm.h
>>>>> +++ b/include/linux/mm.h
>>>>> @@ -102,8 +102,42 @@ static inline void set_max_mapnr(unsigned long
>>>>> limit) { }
>>>>>  A A  * zeroing by defining this macro in <asm/pgtable.h>.
>>>>>  A A  */
>>>>>  A  #ifndef mm_zero_struct_page
>>>>
>>>> Do we still need this ifdef? I guess we can wait for an arch which
>>>> doesn't like this change and then add the override. I would rather go
>>>> simple if possible.
>>>
>>> We probably don't, but as soon as I remove it somebody will probably
>>> complain somewhere. I guess I could drop it for now and see if anybody
>>> screams. Adding it back should be pretty straight forward since it would
>>> only be 2 lines.
>>>
>>>>> +#if BITS_PER_LONG == 64
>>>>> +/* This function must be updated when the size of struct page grows
>>>>> above 80
>>>>> + * or reduces below 64. The idea that compiler optimizes out switch()
>>>>> + * statement, and only leaves move/store instructions
>>>>> + */
>>>>> +#defineA A A  mm_zero_struct_page(pp) __mm_zero_struct_page(pp)
>>>>> +static inline void __mm_zero_struct_page(struct page *page)
>>>>> +{
>>>>> +A A A  unsigned long *_pp = (void *)page;
>>>>> +
>>>>> +A A A A  /* Check that struct page is either 56, 64, 72, or 80 bytes */
>>>>> +A A A  BUILD_BUG_ON(sizeof(struct page) & 7);
>>>>> +A A A  BUILD_BUG_ON(sizeof(struct page) < 56);
>>>>> +A A A  BUILD_BUG_ON(sizeof(struct page) > 80);
>>>>> +
>>>>> +A A A  switch (sizeof(struct page)) {
>>>>> +A A A  case 80:
>>>>> +A A A A A A A  _pp[9] = 0;A A A  /* fallthrough */
>>>>> +A A A  case 72:
>>>>> +A A A A A A A  _pp[8] = 0;A A A  /* fallthrough */
>>>>> +A A A  default:
>>>>> +A A A A A A A  _pp[7] = 0;A A A  /* fallthrough */
>>>>> +A A A  case 56:
>>>>> +A A A A A A A  _pp[6] = 0;
>>>>> +A A A A A A A  _pp[5] = 0;
>>>>> +A A A A A A A  _pp[4] = 0;
>>>>> +A A A A A A A  _pp[3] = 0;
>>>>> +A A A A A A A  _pp[2] = 0;
>>>>> +A A A A A A A  _pp[1] = 0;
>>>>> +A A A A A A A  _pp[0] = 0;
>>>>> +A A A  }
>>>>
>>>> This just hit my eyes. I have to confess I have never seen default: to
>>>> be not the last one in the switch. Can we have case 64 instead or does
>>>> gcc
>>>> complain? I would be surprised with the set of BUILD_BUG_ONs.
>>
>> It was me, C does not really care where default is placed, I was trying
>> to keep stores sequential for better cache locality, but "case 64"
>> should be OK, and even better for this purpose.
> 
> You'd need to put memory barriers between them to force sequential stores.
> I'm also surprised that gcc doesn't inline the memset().
> 
> 	David

We don't need them to be sequential. The general idea is we have have to 
fill a given amount of space with 0s. After that we have some calls that 
are initialing the memory that doesn't have to be zero. Ideally the 
compiler is smart enough to realize that since we don't have barriers 
and we are performing assignments after the assignment of zero it can 
just combine the two writes into one and drop the zero assignment.

- Alex
