Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6EB956B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:33:42 -0400 (EDT)
Message-ID: <51F8D9F3.4040108@bitsync.net>
Date: Wed, 31 Jul 2013 11:33:39 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [patch 0/3] mm: improve page aging fairness between zones/nodes
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <51ED6274.3000509@bitsync.net> <51EFB80B.1090302@bitsync.net>
In-Reply-To: <51EFB80B.1090302@bitsync.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 24.07.2013 13:18, Zlatko Calusic wrote:
> On 22.07.2013 18:48, Zlatko Calusic wrote:
>> On 19.07.2013 22:55, Johannes Weiner wrote:
>>> The way the page allocator interacts with kswapd creates aging
>>> imbalances, where the amount of time a userspace page gets in memory
>>> under reclaim pressure is dependent on which zone, which node the
>>> allocator took the page frame from.
>>>
>>> #1 fixes missed kswapd wakeups on NUMA systems, which lead to some
>>>     nodes falling behind for a full reclaim cycle relative to the other
>>>     nodes in the system
>>>
>>> #3 fixes an interaction where kswapd and a continuous stream of page
>>>     allocations keep the preferred zone of a task between the high and
>>>     low watermark (allocations succeed + kswapd does not go to sleep)
>>>     indefinitely, completely underutilizing the lower zones and
>>>     thrashing on the preferred zone
>>>
>>> These patches are the aging fairness part of the thrash-detection
>>> based file LRU balancing.  Andrea recommended to submit them
>>> separately as they are bugfixes in their own right.
>>>
>>
>> I have the patch applied and under testing. So far, so good. It looks
>> like it could finally fix the bug that I was chasing few months ago
>> (nicely described in your bullet #3). But, few more days of testing will
>> be needed before I can reach a quality verdict.
>>
>
> Well, only 2 days later it's already obvious that the patch is perfect! :)
>

Additionaly, on the patched kernel, kswapd burns 30% less CPU cycles. 
Nice to see that restored balance also eases kswapd's job, but that was 
to be expected. Measured on the real workload, twice, to be sure.

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
