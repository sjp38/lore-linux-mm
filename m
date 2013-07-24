Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 06BCC6B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 08:47:08 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj3so622470pad.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 05:47:08 -0700 (PDT)
Message-ID: <51EFCCB2.5020806@gmail.com>
Date: Wed, 24 Jul 2013 20:46:42 +0800
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 0/3] mm: improve page aging fairness between zones/nodes
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <51ED6274.3000509@bitsync.net> <51EFB80B.1090302@bitsync.net>
In-Reply-To: <51EFB80B.1090302@bitsync.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

ao? 2013/7/24 19:18, Zlatko Calusic a??e??:
> On 22.07.2013 18:48, Zlatko Calusic wrote:
>> On 19.07.2013 22:55, Johannes Weiner wrote:
>>> The way the page allocator interacts with kswapd creates aging
>>> imbalances, where the amount of time a userspace page gets in memory
>>> under reclaim pressure is dependent on which zone, which node the
>>> allocator took the page frame from.
>>>
>>> #1 fixes missed kswapd wakeups on NUMA systems, which lead to some
>>> nodes falling behind for a full reclaim cycle relative to the other
>>> nodes in the system
>>>
>>> #3 fixes an interaction where kswapd and a continuous stream of page
>>> allocations keep the preferred zone of a task between the high and
>>> low watermark (allocations succeed + kswapd does not go to sleep)
>>> indefinitely, completely underutilizing the lower zones and
>>> thrashing on the preferred zone
>>>
>>> These patches are the aging fairness part of the thrash-detection
>>> based file LRU balancing. Andrea recommended to submit them
>>> separately as they are bugfixes in their own right.
>>>
>>
>> I have the patch applied and under testing. So far, so good. It looks
>> like it could finally fix the bug that I was chasing few months ago
>> (nicely described in your bullet #3). But, few more days of testing will
>> be needed before I can reach a quality verdict.
>>
>
> Well, only 2 days later it's already obvious that the patch is 
> perfect! :)
>
> In the attached image, in the left column are the graphs covering last 
> day and a half. It can be observed that zones are really balanced, and 
> that aging is practically perfect. Graphs on the right column cover 
> last 10 day period, and the left side of the upper graph shows how it 
> would look with the stock kernel after about 20 day uptime (although 
> only a few days is enough to reach such imbalance). File pages in the 
> Normal zone are extinct species (red) and the zone is choke full of 
> anon pages (blue). Having seen a lot of this graphs, I'm certain that 
> it won't happen anymore with your patch applied. The balance is 
> restored! Thank you for your work. Feel free to add:
>
> Tested-by: Zlatko Calusic <zcalusic@bitsync.net>

Thanks for your testing Zlatko, could you tell me which benchmark or 
workload you are using? Btw, which tool is used to draw these nice 
pictures? ;-)

>
> Regards,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
