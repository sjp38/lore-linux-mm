Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD666B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 05:30:36 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so103608430wib.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 02:30:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si1525099wjt.113.2015.07.27.02.30.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 02:30:34 -0700 (PDT)
Subject: Re: [RFC v2 0/4] Outsourcing compaction for THP allocations to
 kcompactd
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
 <55B24A1D.1030400@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B5FA31.6050301@suse.cz>
Date: Mon, 27 Jul 2015 11:30:25 +0200
MIME-Version: 1.0
In-Reply-To: <55B24A1D.1030400@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/24/2015 04:22 PM, Rik van Riel wrote:
> On 07/02/2015 04:46 AM, Vlastimil Babka wrote:
>> This RFC series is another evolution of the attempt to deal with THP
>> allocations latencies. Please see the motivation in the previous version [1]
>>
>> The main difference here is that I've bitten the bullet and implemented
>> per-node kcompactd kthreads - see Patch 1 for the details of why and how.
>> Trying to fit everything into khugepaged was getting too clumsy, and kcompactd
>> could have more benefits, see e.g. the ideas here [2]. Not everything is
>> implemented yet, though, I would welcome some feedback first.
>
> This leads to a few questions, one of which has an obvious answer.
>
> 1) Why should this functionality not be folded into kswapd?
>
>      (because kswapd can get stuck on IO for long periods of time)

Hm, my main concern was somewhat opposite - kswapd primarily serves to 
avoid direct reclaim (also for) order-0 allocations, so we don't want to 
make it busy compacting for high-order allocations and then fail to 
reclaim quickly enough.
Also the waking up of kswapd for all the distinct tasks would become 
more complex.

Also does kswapd really get stuck on IO? Doesn't it just issue writeback 
and go on? Again it would be the opposite concern, as sync compaction 
may have to wait for writeback before migrating a page and blocking 
kswapd on that wouldn't be nice.

> 2) Given that kswapd can get stuck on IO for long periods of
>      time, are there other tasks we may want to break out of
>      kswapd, in order to reduce page reclaim latencies for things
>      like network allocations?
>
>      (freeing clean inactive pages?)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
