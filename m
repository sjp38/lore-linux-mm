Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 787336B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 08:14:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c87so297086088pfl.6
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:14:06 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c17si1627655pgh.23.2017.03.22.05.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 05:14:05 -0700 (PDT)
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
References: <20170317231636.142311-1-timmurray@google.com>
 <20170320055930.GA30167@bbox>
 <3023449c-8012-333d-1da9-81f18d3f8540@codeaurora.org>
 <20170320152315.GA27672@cmpxchg.org>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <6b4f4912-6afa-e6a3-17a9-2c76c9d5ce7b@codeaurora.org>
Date: Wed, 22 Mar 2017 17:43:57 +0530
MIME-Version: 1.0
In-Reply-To: <20170320152315.GA27672@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, surenb@google.com, totte@google.com, kernel-team@android.com

On 3/20/2017 8:53 PM, Johannes Weiner wrote:
> On Mon, Mar 20, 2017 at 07:28:53PM +0530, Vinayak Menon wrote:
>> From the discussions @ https://lkml.org/lkml/2017/3/3/752, I assume you are trying
>> per-app memcg. We were trying to implement per app memory cgroups and were
>> encountering some issues (https://www.spinics.net/lists/linux-mm/msg121665.html) .
>> I am curious if you have seen similar issues and would like to know if the patch also
>> address some of these problems.
>>
>> The major issues were:
>> (1) Because of multiple per-app memcgs, the per memcg LRU size is so small and
>> results in kswapd priority drop. This results in sudden increase in scan at lower priorities.
>> And kswapd ends up consuming around 3 times more time.
> There shouldn't be a connection between those two things.
>
> Yes, priority levels used to dictate aggressiveness of reclaim, and we
> did add a bunch of memcg code to avoid priority drops.
>
> But nowadays the priority level should only set the LRU scan window
> and we bail out once we have reclaimed enough (see the code in
> shrink_node_memcg()).
>
> If kswapd gets stuck on smaller LRUs, we should find out why and then
> address that problem.
Hi Johannes, Thanks for your comments. I will try to explain what I have observed while debugging this
problem.
When there are multiple small LRUs and very few LRUs with considerable size (by considerable size I mean
those sizes which can result in a non-zero scan value in get_scan_count at priorities near to DEF_PRIORITY).
Since I am trying on 4.4 kernel there are more small LRUs per app (per memcg) because of further split due to per zone LRU.
Considering the case where most of the apps in the system are of this small category, the scan calculated by
get_scan_count for these memcg LRUs at around DEF_PRIORITY become zero or very less, either because of
size >> sc->priority is 0 or because of SCAN_FRACT. For these runs around DEF_PRIORITY (say till DEF_PRIORITY/2)
since sc->nr_scanned is < sc->nr_to_reclaim, the kswapd priority drops. Now say at kswapd priority less than
DEF_PRIORITY/2, the scan returned by get_scan_count gets higher slowly for all memcgs. This causes sudden
excessive scanning of most of the memcgs (because this also results in heavy scanning of memcgs which have
considerable size). As I understand, the scan priority in this case results in aggressive reclaim and not just decides the
scan window because, in the following check in shrink_node_memcg, the "nr_to_reclaim" (sc->nr_to_reclaim)
is a high value compared to the memcg LRU size. I have seen that this also causes either nr_file or nr_anon
go zero most of the time (after this check), which as I understand means that proportional scanning does not happen.

if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
             continue;

I had tried making the "nr_to_reclaim" proportional to the lru size and that brings some benefits, but does not
solve the problem. Because when that is done, in some cases, the scanned pages at this priority decreases again,
resulting in further priority drop.

The priority drop and excessive scan/reclaim at lower priorities I have confirmed by keeping scanned and reclaimed
counters for each priority in vmstat. And yes, this results in kswapd being awake and running for longer time.

There was some benefit by prioritizing the memcgs similar to what Tim does in his patch and also by proportionally
reclaiming from the per-task memcgs based on their priority. But still the stats are far bad compared to having
a global LRU. One thing which was commonly seen in all these experiments is the multi fold increase in majfaults,
which I think is partly caused by poor aging of pages when the pages are distributed among a large number of tiny LRUs,
and global reclaim trying to reclaim from all of them.
>> (2) Due to kswapd taking more time in freeing up memory, allocstalls are high and for
>> similar reasons stated above direct reclaim path consumes 2.5 times more time.
>> (3) Because of multiple LRUs, the aging of pages is affected and this results in wrong
>> pages being evicted resulting in higher number of major faults.
>>
>> Since soft reclaim was not of much help in mitigating the problem, I was trying out
>> something similar to memcg priority. But what I have seen is that this aggravates the
>> above mentioned problems. I think this is because, even though the high priority tasks
>> (foreground) are having pages which are used at the moment, there are idle pages too
>> which could be reclaimed. But due to the high priority of foreground memcg, it requires
>> the kswapd priority to drop down much to reclaim these idle pages. This results in excessive
>> reclaim from background apps resulting in increased major faults, pageins and thus increased
>> launch latency when these apps are later brought back to foreground.
> This is what the soft limit *should* do, but unfortunately its
> semantics and implementation in cgroup1 are too broken for this.
>
> Have you tried configuring memory.low for the foreground groups in
> cgroup2? That protects those pages from reclaim as long as there are
> reclaimable idle pages in the memory.low==0 background groups.
I have not yet tried cgroup2. I was trying to understand it sometime back and IIUC it supports only a
single hierarchy and  a process can be part of only one cgroup, which means when we try per-task mem
cgroup, this would mean all other controllers will have to be configured per-task. No ? I would like to try
memory.low that you suggest. Let me check if I have a way to test this without disturbing other controllers,
or will try with memory cgroup alone.
>> One thing which is found to fix the above problems is to have both global LRU and the per-memcg LRU.
>> Global reclaim can use the global LRU thus fixing the above 3 issues. The memcg LRUs can then be used
>> for soft reclaim or a proactive reclaim similar to Minchan's Per process reclaim for the background or
>> low priority tasks. I have been trying this change on 4.4 kernel (yet to try the per-app
>> reclaim/soft reclaim part). One downside is the extra list_head in struct page and the memory it consumes.
> That would be a major step backwards, and I'm not entirely convinced
> that the issues you are seeing cannot be fixed by improving the way we
> do global round-robin reclaim and/or configuring memory.low.
I understand and agree that it would be better to fix the existing design if it is possible.

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
