Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 51BB96B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 03:51:06 -0500 (EST)
Received: by mail-la0-f54.google.com with SMTP id y1so2287682lam.13
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 00:51:05 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a4si4114591laf.83.2014.01.16.00.51.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 00:51:04 -0800 (PST)
Message-ID: <52D79D6B.10304@parallels.com>
Date: Thu, 16 Jan 2014 12:50:51 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm: vmscan: shrink all slab objects if tight on memory
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com> <20140113150502.4505f661589a4a2d30e6f11d@linux-foundation.org> <52D4E5F2.5080205@parallels.com> <20140114141453.374bd18e5290876177140085@linux-foundation.org> <52D64B27.30604@parallels.com> <20140115012541.ad302526.akpm@linux-foundation.org> <52D6AF5F.2040102@parallels.com> <20140115145327.6aae2e13a9a8bba619923ac9@linux-foundation.org>
In-Reply-To: <20140115145327.6aae2e13a9a8bba619923ac9@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On 01/16/2014 02:53 AM, Andrew Morton wrote:
> On Wed, 15 Jan 2014 19:55:11 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>>> We could avoid the "scan 32 then scan just 1" issue with something like
>>>
>>> 	if (total_scan > batch_size)
>>> 		total_scan %= batch_size;
>>>
>>> before the loop.  But I expect the effects of that will be unmeasurable
>>> - on average the number of objects which are scanned in the final pass
>>> of the loop will be batch_size/2, yes?  That's still a decent amount.
>> Let me try to summarize. We want to scan batch_size objects in one pass,
>> not more (to keep latency low) and not less (to avoid cpu cache
>> pollution due to too frequent calls); if the calculated value of
>> nr_to_scan is less than the batch_size we should accumulate it in
>> nr_deferred instead of calling ->scan() and add nr_deferred to
>> nr_to_scan on the next pass, i.e. in pseudo-code:
>>
>>     /* calculate current nr_to_scan */
>>     max_pass = shrinker->count();
>>     delta = max_pass * nr_user_pages_scanned / nr_user_pages;
>>
>>     /* add nr_deferred */
>>     total_scan = delta + nr_deferred;
>>
>>     while (total_scan >= batch_size) {
>>         shrinker->scan(batch_size);
>>         total_scan -= batch_size;
>>     }
>>
>>     /* save the remainder to nr_deferred  */
>>     nr_deferred = total_scan;
>>
>> That would work, but if max_pass is < batch_size, it would not scan the
>> objects immediately even if prio is high (we want to scan all objects).
> Yes, that's a problem.
>
>> For example, dropping caches would not work on the first attempt - the
>> user would have to call it batch_size / max_pass times.
> And we do want drop_caches to work immediately.
>
>> This could be
>> fixed by making the code proceed to ->scan() not only if total_scan is
>>> = batch_size, but also if max_pass is < batch_size and total_scan is >=
>> max_pass, i.e.
>>
>>     while (total_scan >= batch_size ||
>>             (max_pass < batch_size && total_scan >= max_pass)) ...
>>
>> which is equivalent to
>>
>>     while (total_scan >= batch_size ||
>>                 total_scan >= max_pass) ...
>>
>> The latter is the loop condition from the current patch, i.e. this patch
>> would make the trick if shrink_slab() followed the pseudo-code above. In
>> real life, it does not actually - we have to bias total_scan before the
>> while loop in order to avoid dropping fs meta caches on light memory
>> pressure due to a large number being built in nr_deferred:
>>
>>     if (delta < max_pass / 4)
>>         total_scan = min(total_scan, max_pass / 2);
> Oh, is that what's it's for.  Where did you discover this gem?
