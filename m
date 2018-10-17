Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10E1F6B000E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:07:08 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z8-v6so20179704pgp.20
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 08:07:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b190-v6si15115919pfb.166.2018.10.17.08.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 08:07:06 -0700 (PDT)
Subject: Re: [mm PATCH v3 1/6] mm: Use mm_zero_struct_page from SPARC on all
 64b architectures
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202656.2171.92963.stgit@localhost.localdomain>
 <20181017084744.GH18839@dhcp22.suse.cz>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <9700b00f-a8a4-e318-f6a8-71fd1e7021b3@linux.intel.com>
Date: Wed, 17 Oct 2018 08:07:06 -0700
MIME-Version: 1.0
In-Reply-To: <20181017084744.GH18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 10/17/2018 1:47 AM, Michal Hocko wrote:
> On Mon 15-10-18 13:26:56, Alexander Duyck wrote:
>> This change makes it so that we use the same approach that was already in
>> use on Sparc on all the archtectures that support a 64b long.
>>
>> This is mostly motivated by the fact that 8 to 10 store/move instructions
>> are likely always going to be faster than having to call into a function
>> that is not specialized for handling page init.
>>
>> An added advantage to doing it this way is that the compiler can get away
>> with combining writes in the __init_single_page call. As a result the
>> memset call will be reduced to only about 4 write operations, or at least
>> that is what I am seeing with GCC 6.2 as the flags, LRU poitners, and
>> count/mapcount seem to be cancelling out at least 4 of the 8 assignments on
>> my system.
>>
>> One change I had to make to the function was to reduce the minimum page
>> size to 56 to support some powerpc64 configurations.
> 
> This really begs for numbers. I do not mind the change itself with some
> minor comments below.
> 
> [...]
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index bb0de406f8e7..ec6e57a0c14e 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -102,8 +102,42 @@ static inline void set_max_mapnr(unsigned long limit) { }
>>    * zeroing by defining this macro in <asm/pgtable.h>.
>>    */
>>   #ifndef mm_zero_struct_page
> 
> Do we still need this ifdef? I guess we can wait for an arch which
> doesn't like this change and then add the override. I would rather go
> simple if possible.

We probably don't, but as soon as I remove it somebody will probably 
complain somewhere. I guess I could drop it for now and see if anybody 
screams. Adding it back should be pretty straight forward since it would 
only be 2 lines.

>> +#if BITS_PER_LONG == 64
>> +/* This function must be updated when the size of struct page grows above 80
>> + * or reduces below 64. The idea that compiler optimizes out switch()
>> + * statement, and only leaves move/store instructions
>> + */
>> +#define	mm_zero_struct_page(pp) __mm_zero_struct_page(pp)
>> +static inline void __mm_zero_struct_page(struct page *page)
>> +{
>> +	unsigned long *_pp = (void *)page;
>> +
>> +	 /* Check that struct page is either 56, 64, 72, or 80 bytes */
>> +	BUILD_BUG_ON(sizeof(struct page) & 7);
>> +	BUILD_BUG_ON(sizeof(struct page) < 56);
>> +	BUILD_BUG_ON(sizeof(struct page) > 80);
>> +
>> +	switch (sizeof(struct page)) {
>> +	case 80:
>> +		_pp[9] = 0;	/* fallthrough */
>> +	case 72:
>> +		_pp[8] = 0;	/* fallthrough */
>> +	default:
>> +		_pp[7] = 0;	/* fallthrough */
>> +	case 56:
>> +		_pp[6] = 0;
>> +		_pp[5] = 0;
>> +		_pp[4] = 0;
>> +		_pp[3] = 0;
>> +		_pp[2] = 0;
>> +		_pp[1] = 0;
>> +		_pp[0] = 0;
>> +	}
> 
> This just hit my eyes. I have to confess I have never seen default: to
> be not the last one in the switch. Can we have case 64 instead or does gcc
> complain? I would be surprised with the set of BUILD_BUG_ONs.

I can probably just replace the "default:" with "case 64:". I think I 
have seen other switch statements in the kernel without a default so 
odds are it should be okay.
