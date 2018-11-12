Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5B06B028D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:12:52 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w19-v6so7437791plq.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:12:52 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 9si15202459pgm.112.2018.11.12.07.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:12:22 -0800 (PST)
Subject: Re: [mm PATCH v5 7/7] mm: Use common iterator for deferred_init_pages
 and deferred_free_pages
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
 <154145280115.30046.13334106887516645119.stgit@ahduyck-desk1.jf.intel.com>
 <20181110041338.7ttram7po7a2ssz7@xakep.localdomain>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <ce8504f0-5963-7415-8e8d-7454b0e68fe5@linux.intel.com>
Date: Mon, 12 Nov 2018 07:12:13 -0800
MIME-Version: 1.0
In-Reply-To: <20181110041338.7ttram7po7a2ssz7@xakep.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On 11/9/2018 8:13 PM, Pavel Tatashin wrote:
> On 18-11-05 13:20:01, Alexander Duyck wrote:
>> +static unsigned long __next_pfn_valid_range(unsigned long *i,
>> +					    unsigned long end_pfn)
>>   {
>> -	if (!pfn_valid_within(pfn))
>> -		return false;
>> -	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
>> -		return false;
>> -	return true;
>> +	unsigned long pfn = *i;
>> +	unsigned long count;
>> +
>> +	while (pfn < end_pfn) {
>> +		unsigned long t = ALIGN(pfn + 1, pageblock_nr_pages);
>> +		unsigned long pageblock_pfn = min(t, end_pfn);
>> +
>> +#ifndef CONFIG_HOLES_IN_ZONE
>> +		count = pageblock_pfn - pfn;
>> +		pfn = pageblock_pfn;
>> +		if (!pfn_valid(pfn))
>> +			continue;
>> +#else
>> +		for (count = 0; pfn < pageblock_pfn; pfn++) {
>> +			if (pfn_valid_within(pfn)) {
>> +				count++;
>> +				continue;
>> +			}
>> +
>> +			if (count)
>> +				break;
>> +		}
>> +
>> +		if (!count)
>> +			continue;
>> +#endif
>> +		*i = pfn;
>> +		return count;
>> +	}
>> +
>> +	return 0;
>>   }
>>   
>> +#define for_each_deferred_pfn_valid_range(i, start_pfn, end_pfn, pfn, count) \
>> +	for (i = (start_pfn),						     \
>> +	     count = __next_pfn_valid_range(&i, (end_pfn));		     \
>> +	     count && ({ pfn = i - count; 1; });			     \
>> +	     count = __next_pfn_valid_range(&i, (end_pfn)))
> 
> Can this be improved somehow? It took me a while to understand this
> piece of code. i is actually end of block, and not an index by PFN, ({pfn = i - count; 1;}) is
> simply hard to parse. Why can't we make __next_pfn_valid_range() to
> return both end and a start of a block?

One thing I could do is flip the direction and work from the end to the 
start. If I did that then 'i' and 'pfn' would be the same value and I 
wouldn't have to do the subtraction. If that works for you I could 
probably do that and it may actually be more efficient.

Otherwise I could probably pass pfn as a reference, and compute it in 
the case where count is non-zero.

> The rest is good:
> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> 
> Thank you,
> Pasha
> 
