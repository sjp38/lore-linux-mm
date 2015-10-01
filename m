Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id AF53482F64
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 03:35:55 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so19366484wic.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 00:35:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ph6si2074193wic.113.2015.10.01.00.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 00:35:54 -0700 (PDT)
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-4-git-send-email-mgorman@techsingularity.net>
 <alpine.DEB.2.10.1509301521380.23324@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560CE255.80303@suse.cz>
Date: Thu, 1 Oct 2015 09:35:49 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1509301521380.23324@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/01/2015 12:22 AM, David Rientjes wrote:
> On Mon, 21 Sep 2015, Mel Gorman wrote:
>> @@ -115,6 +118,9 @@ static inline unsigned int read_mems_allowed_begin(void)
>>    */
>>   static inline bool read_mems_allowed_retry(unsigned int seq)
>>   {
>> +	if (!cpusets_enabled())
>> +		return false;
>> +
>>   	return read_seqcount_retry(&current->mems_allowed_seq, seq);
>>   }
>>
>
> I thought this was going to test nr_cpusets() <= 1?

That was another patch in prior iteration of the series, but turns out 
it was unnecessary, because cpusets_enabled() is already only true when 
nr_cpusets() > 1 - see https://lkml.org/lkml/2015/8/25/300

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
