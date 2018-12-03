Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A54D6B699D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 09:49:24 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so6945659pgb.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 06:49:24 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 23si14434525pfz.20.2018.12.03.06.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 06:49:23 -0800 (PST)
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH 1/3] mm/memcg: Fix min/low usage in
 propagate_protected_usage()
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203115453.GO31738@dhcp22.suse.cz>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <1c62ec71-52de-3597-ec87-3dd8d81c4d2a@linux.alibaba.com>
Date: Mon, 3 Dec 2018 22:49:18 +0800
MIME-Version: 1.0
In-Reply-To: <20181203115453.GO31738@dhcp22.suse.cz>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/12/3 ����7:54, Michal Hocko wrote:
> On Mon 03-12-18 16:01:17, Xunlei Pang wrote:
>> When usage exceeds min, min usage should be min other than 0.
>> Apply the same for low.
> 
> Why? What is the actual problem.

children_min_usage tracks the total children usages under min,
it's natural that min should be added into children_min_usage
when above min, I can't image why 0 is added, is there special
history I missed?

See mem_cgroup_protected(), when usage exceeds min, emin is
calculated as "parent_emin*min/children_min_usage".

> 
>> Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
>> ---
>>  mm/page_counter.c | 12 ++----------
>>  1 file changed, 2 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/page_counter.c b/mm/page_counter.c
>> index de31470655f6..75d53f15f040 100644
>> --- a/mm/page_counter.c
>> +++ b/mm/page_counter.c
>> @@ -23,11 +23,7 @@ static void propagate_protected_usage(struct page_counter *c,
>>  		return;
>>  
>>  	if (c->min || atomic_long_read(&c->min_usage)) {
>> -		if (usage <= c->min)
>> -			protected = usage;
>> -		else
>> -			protected = 0;
>> -
>> +		protected = min(usage, c->min);
>>  		old_protected = atomic_long_xchg(&c->min_usage, protected);
>>  		delta = protected - old_protected;
>>  		if (delta)
>> @@ -35,11 +31,7 @@ static void propagate_protected_usage(struct page_counter *c,
>>  	}
>>  
>>  	if (c->low || atomic_long_read(&c->low_usage)) {
>> -		if (usage <= c->low)
>> -			protected = usage;
>> -		else
>> -			protected = 0;
>> -
>> +		protected = min(usage, c->low);
>>  		old_protected = atomic_long_xchg(&c->low_usage, protected);
>>  		delta = protected - old_protected;
>>  		if (delta)
>> -- 
>> 2.13.5 (Apple Git-94)
>>
> 
