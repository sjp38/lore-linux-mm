Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4BB6B0693
	for <linux-mm@kvack.org>; Fri, 18 May 2018 18:01:35 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w1-v6so6360798iod.1
        for <linux-mm@kvack.org>; Fri, 18 May 2018 15:01:35 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a74-v6si7097506ioj.258.2018.05.18.15.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 15:01:33 -0700 (PDT)
Subject: Re: [PATCH v2 1/4] mm: change type of free_contig_range(nr_pages) to
 unsigned long
References: <20180503232935.22539-1-mike.kravetz@oracle.com>
 <20180503232935.22539-2-mike.kravetz@oracle.com>
 <87d74ce0-b135-064d-a589-64235e44c388@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <87943a21-4465-31bd-ed37-69253879ec47@oracle.com>
Date: Fri, 18 May 2018 15:01:20 -0700
MIME-Version: 1.0
In-Reply-To: <87d74ce0-b135-064d-a589-64235e44c388@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On 05/18/2018 02:12 AM, Vlastimil Babka wrote:
> On 05/04/2018 01:29 AM, Mike Kravetz wrote:
>> free_contig_range() is currently defined as:
>> void free_contig_range(unsigned long pfn, unsigned nr_pages);
>> change to,
>> void free_contig_range(unsigned long pfn, unsigned long nr_pages);
>>
>> Some callers are passing a truncated unsigned long today.  It is
>> highly unlikely that these values will overflow an unsigned int.
>> However, this should be changed to an unsigned long to be consistent
>> with other page counts.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  include/linux/gfp.h | 2 +-
>>  mm/cma.c            | 2 +-
>>  mm/hugetlb.c        | 2 +-
>>  mm/page_alloc.c     | 6 +++---
>>  4 files changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index 1a4582b44d32..86a0d06463ab 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -572,7 +572,7 @@ static inline bool pm_suspended_storage(void)
>>  /* The below functions must be run on a range from a single zone. */
>>  extern int alloc_contig_range(unsigned long start, unsigned long end,
>>  			      unsigned migratetype, gfp_t gfp_mask);
>> -extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>> +extern void free_contig_range(unsigned long pfn, unsigned long nr_pages);
>>  #endif
>>  
>>  #ifdef CONFIG_CMA
>> diff --git a/mm/cma.c b/mm/cma.c
>> index aa40e6c7b042..f473fc2b7cbd 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -563,7 +563,7 @@ bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
>>  
>>  	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
>>  
>> -	free_contig_range(pfn, count);
>> +	free_contig_range(pfn, (unsigned long)count);
> 
> I guess this cast from uint to ulong doesn't need to be explicit? But
> instead, cma_release() signature could be also changed to ulong, because
> some of its callers do pass those?

Correct, that cast is not needed.

I like the idea of changing cma_release() to take ulong.  Until you mentioned
this, I did not realize that some callers were passing in a truncated ulong.
As noted in my commit message, this truncation is unlikely to be an issue.
But, I think we should 'fix' them if we can.

I'll spin another version with this change.

> 
>>  	cma_clear_bitmap(cma, pfn, count);
>>  	trace_cma_release(pfn, pages, count);
>>  
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 218679138255..c81072ce7510 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1055,7 +1055,7 @@ static void destroy_compound_gigantic_page(struct page *page,
>>  
>>  static void free_gigantic_page(struct page *page, unsigned int order)
>>  {
>> -	free_contig_range(page_to_pfn(page), 1 << order);
>> +	free_contig_range(page_to_pfn(page), 1UL << order);
>>  }
>>  
>>  static int __alloc_gigantic_page(unsigned long start_pfn,
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 905db9d7962f..0fd5e8e2456e 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7937,9 +7937,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>>  	return ret;
>>  }
>>  
>> -void free_contig_range(unsigned long pfn, unsigned nr_pages)
>> +void free_contig_range(unsigned long pfn, unsigned long nr_pages)
>>  {
>> -	unsigned int count = 0;
>> +	unsigned long count = 0;
>>  
>>  	for (; nr_pages--; pfn++) {
>>  		struct page *page = pfn_to_page(pfn);
>> @@ -7947,7 +7947,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
>>  		count += page_count(page) != 1;
>>  		__free_page(page);
>>  	}
>> -	WARN(count != 0, "%d pages are still in use!\n", count);
>> +	WARN(count != 0, "%ld pages are still in use!\n", count);
> 
> Maybe change to %lu while at it?

Yes

> BTW, this warning can theoretically produce false positives, because
> page users have to deal with page_count() being incremented by e.g.
> parallel pfn scanners using get_page_unless_zero(). We also don't detect
> refcount leaks in general. Should we remove it or change it to VM_WARN
> if it's still useful for debugging?

Added Marek on Cc: as he is the one who originally added this message (although
it has been a long time).  I do not know what specific issue he was concerned
with.  A search found a few bug reports related to this warning.  In these
cases, it clearly was not a false positive but some other issue.  It 'appears'
the message helped in those cases.

However, I would hate for a support organization to spend a bunch of time
doing investigation for a false positive.  At the very least, I think we
should add a message/comment about the possibility of false positives in the
code.  I would be inclined to change it to VM_WARN, but it would be good
to get input from others who might find it useful as it.

-- 
Mike Kravetz

> 
>>  }
>>  #endif
>>  
>>
> 
