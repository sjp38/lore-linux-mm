Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E5AF49003C7
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:18:21 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so71518688wid.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:18:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si15217081wiy.106.2015.08.27.02.18.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 02:18:20 -0700 (PDT)
Subject: Re: [PATCH 07/12] mm, page_alloc: Distinguish between being unable to
 sleep, unwilling to sleep and avoiding waking kswapd
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
 <55DC8BD7.602@suse.cz> <20150826144533.GO12432@techsingularity.net>
 <55DDE842.8000103@suse.cz> <20150826181041.GR12432@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DED5D9.8@suse.cz>
Date: Thu, 27 Aug 2015 11:18:17 +0200
MIME-Version: 1.0
In-Reply-To: <20150826181041.GR12432@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/26/2015 08:10 PM, Mel Gorman wrote:
>>
>> I think the most robust check would be to rely on what was already prepared
>> by gfp_to_alloc_flags(), instead of repeating it here. So add alloc_flags
>> parameter to warn_alloc_failed(), and drop the filter when
>> - ALLOC_CPUSET is not set, as that disables the cpuset checks
>> - ALLOC_NO_WATERMARKS is set, as that allows calling
>>    __alloc_pages_high_priority() attempt which ignores cpusets
>>
>
> warn_alloc_failed is used outside of page_alloc.c in a context that does
> not have alloc_flags. It could be extended to take an extra parameter
> that is ALLOC_CPUSET for the other callers or else split it into
> __warn_alloc_failed (takes alloc_flags parameter) and warn_alloc_failed
> (calls __warn_alloc_failed with ALLOC_CPUSET) but is it really worth it?

Probably not. Testing lack of __GFP_DIRECT_RECLAIM is good enough until 
somebody cares more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
