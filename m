Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82C336B69A4
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 10:20:45 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q63so9896190pfi.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 07:20:45 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id u21si12078681pgm.21.2018.12.03.07.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 07:20:44 -0800 (PST)
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH 2/3] mm/vmscan: Enable kswapd to reclaim low-protected
 memory
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203080119.18989-2-xlpang@linux.alibaba.com>
 <20181203115646.GP31738@dhcp22.suse.cz>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <54a3f0a6-6e7d-c620-97f2-ac567c057bc2@linux.alibaba.com>
Date: Mon, 3 Dec 2018 23:20:31 +0800
MIME-Version: 1.0
In-Reply-To: <20181203115646.GP31738@dhcp22.suse.cz>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/12/3 ����7:56, Michal Hocko wrote:
> On Mon 03-12-18 16:01:18, Xunlei Pang wrote:
>> There may be cgroup memory overcommitment, it will become
>> even common in the future.
>>
>> Let's enable kswapd to reclaim low-protected memory in case
>> of memory pressure, to mitigate the global direct reclaim
>> pressures which could cause jitters to the response time of
>> lantency-sensitive groups.
> 
> Please be more descriptive about the problem you are trying to handle
> here. I haven't actually read the patch but let me emphasise that the
> low limit protection is important isolation tool. And allowing kswapd to
> reclaim protected memcgs is going to break the semantic as it has been
> introduced and designed.

We have two types of memcgs: online groups(important business)
and offline groups(unimportant business). Online groups are
all configured with MAX low protection, while offline groups
are not at all protected(with default 0 low).

When offline groups are overcommitted, the global memory pressure
suffers. This will cause the memory allocations from online groups
constantly go to the slow global direct reclaim in order to reclaim
online's page caches, as kswap is not able to reclaim low-protection
memory. low is not hard limit, it's reasonable to be reclaimed by
kswapd if there's no other reclaimable memory.

> 
>>
>> Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
>> ---
>>  mm/vmscan.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 62ac0c488624..3d412eb91f73 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3531,6 +3531,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>>  
>>  	count_vm_event(PAGEOUTRUN);
>>  
>> +retry:
>>  	do {
>>  		unsigned long nr_reclaimed = sc.nr_reclaimed;
>>  		bool raise_priority = true;
>> @@ -3622,6 +3623,13 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>>  			sc.priority--;
>>  	} while (sc.priority >= 1);
>>  
>> +	if (!sc.nr_reclaimed && sc.memcg_low_skipped) {
>> +		sc.priority = DEF_PRIORITY;
>> +		sc.memcg_low_reclaim = 1;
>> +		sc.memcg_low_skipped = 0;
>> +		goto retry;
>> +	}
>> +
>>  	if (!sc.nr_reclaimed)
>>  		pgdat->kswapd_failures++;
>>  
>> -- 
>> 2.13.5 (Apple Git-94)
>>
> 
