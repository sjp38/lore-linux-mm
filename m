Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 539A56B0270
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:51:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y6so37093802lff.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 05:51:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rq15si1737363wjb.112.2016.09.22.05.51.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 05:51:52 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct
 compaction priority
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160906135258.18335-3-vbabka@suse.cz>
 <20160921171348.GF24210@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f1670976-b4da-5d2c-0a85-37f9a87d6868@suse.cz>
Date: Thu, 22 Sep 2016 14:51:48 +0200
MIME-Version: 1.0
In-Reply-To: <20160921171348.GF24210@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 09/21/2016 07:13 PM, Michal Hocko wrote:
> On Tue 06-09-16 15:52:56, Vlastimil Babka wrote:
> [...]
>> @@ -3204,6 +3199,15 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>>  	if (compaction_retries <= max_retries)
>>  		return true;
>>  
>> +	/*
>> +	 * Make sure there is at least one attempt at the highest priority
>> +	 * if we exhausted all retries at the lower priorities
>> +	 */
>> +check_priority:
>> +	if (*compact_priority > MIN_COMPACT_PRIORITY) {
>> +		(*compact_priority)--;
>> +		return true;
> 
> Don't we want to reset compaction_retries here? Otherwise we can consume
> all retries on the lower priorities.

Good point, patch-fix below.

> Other than that it looks good to me. With that you can add
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
 
>> +	}
>>  	return false;
>>  }
>>  #else
> 

----8<----
