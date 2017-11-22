Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 819FE6B02BC
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 12:46:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 70so16832976pgf.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 09:46:50 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i3si14250884pli.199.2017.11.22.09.46.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 09:46:49 -0800 (PST)
Subject: Re: [PATCH 1/1] mm/cma: fix alloc_contig_range ret code/potential
 leak
References: <20171120193930.23428-1-mike.kravetz@oracle.com>
 <20171120193930.23428-2-mike.kravetz@oracle.com>
 <20171122120002.GA27270@cmpxchg.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <15cf0f39-43f9-8287-fcfe-f2502af59e8a@oracle.com>
Date: Wed, 22 Nov 2017 09:46:35 -0800
MIME-Version: 1.0
In-Reply-To: <20171122120002.GA27270@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 11/22/2017 04:00 AM, Johannes Weiner wrote:
> On Mon, Nov 20, 2017 at 11:39:30AM -0800, Mike Kravetz wrote:
>> If the call __alloc_contig_migrate_range() in alloc_contig_range
>> returns -EBUSY, processing continues so that test_pages_isolated()
>> is called where there is a tracepoint to identify the busy pages.
>> However, it is possible for busy pages to become available between
>> the calls to these two routines.  In this case, the range of pages
>> may be allocated.   Unfortunately, the original return code (ret
>> == -EBUSY) is still set and returned to the caller.  Therefore,
>> the caller believes the pages were not allocated and they are leaked.
>>
>> Update the return code with the value from test_pages_isolated().
>>
>> Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation failure")
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Wow, good catch.
> 
>> ---
>>  mm/page_alloc.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 77e4d3c5c57b..3605ca82fd29 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7632,10 +7632,10 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>>  	}
>>  
>>  	/* Make sure the range is really isolated. */
>> -	if (test_pages_isolated(outer_start, end, false)) {
>> +	ret = test_pages_isolated(outer_start, end, false);
>> +	if (ret) {
>>  		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>>  			__func__, outer_start, end);
>> -		ret = -EBUSY;
>>  		goto done;
> 
> Essentially, an -EBUSY from __alloc_contig_migrate_range() doesn't
> mean anything, and we return 0 if the rest of the operations succeed.
> 
> Since we never plan on returning that particular -EBUSY, would it be
> more robust to reset it right then and there, rather than letting it
> run on in ret for more than a screenful?
> 
> It would also be good to note in that fall-through comment that the
> pages becoming free on their own is a distinct possibility.
> 
> As Michal points out, this is really subtle. It makes sense to make it
> as explicit as possible.

Ok, I thought about zero'ing ret right after the call to
__alloc_contig_migrate_range and return of -EBUSY.  It just didn't look
right to me.  But, you are correct.  We should make this as explicit as
possible.  I will respin the patch as suggested and be sure to include an
explicit comment when setting ret = 0.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
