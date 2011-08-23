Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC9516B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 02:48:23 -0400 (EDT)
Message-ID: <4E534D13.5020102@openvz.org>
Date: Tue, 23 Aug 2011 10:47:47 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmscan: fix initial shrinker size handling
References: <20110822101721.19462.63082.stgit@zurg> <20110822143006.60f4b560.akpm@linux-foundation.org>
In-Reply-To: <20110822143006.60f4b560.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>

Andrew Morton wrote:
<snip>
>>   		long new_nr;
>>   		long batch_size = shrinker->batch ? shrinker->batch
>>   						  : SHRINK_BATCH;
>>
>> +		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
>> +		if (max_pass<= 0)
>> +			continue;
>> +
>>   		/*
>>   		 * copy the current shrinker scan count into a local variable
>>   		 * and zero it so that other concurrent shrinker invocations
>> @@ -266,7 +270,6 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>>   		} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
>>
>>   		total_scan = nr;
>> -		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
>>   		delta = (4 * nr_pages_scanned) / shrinker->seeks;
>>   		delta *= max_pass;
>>   		do_div(delta, lru_pages + 1);
>
> Why was the shrinker call moved to before the alteration of shrinker->nr?

I think, if we skip shrinker we shouldn't reset accumulated pressure,
because next reclaimer (for example with less strict gfp) can use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
