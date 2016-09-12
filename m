Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD4C6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 05:56:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b187so8526421wme.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:56:15 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id ea4si14549562wjb.234.2016.09.12.02.56.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 02:56:14 -0700 (PDT)
Message-ID: <57D67A8A.7070500@huawei.com>
Date: Mon, 12 Sep 2016 17:51:06 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com> <20160909114410.GG4844@dhcp22.suse.cz>
In-Reply-To: <20160909114410.GG4844@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On 2016/9/9 19:44, Michal Hocko wrote:
> On Tue 06-09-16 22:47:06, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> Some hungtask come up when I run the trinity, and OOM occurs
>> frequently.
>> A task hold lock to allocate memory, due to the low memory,
>> it will lead to oom. at the some time , it will retry because
>> it find that oom is in progress. but it always allocate fails,
>> the freed memory was taken away quickly.
>> The patch fix it by limit times to avoid hungtask and livelock
>> come up.
> Which kernel has shown this issue? Since 4.6 IIRC we have oom reaper
> responsible for the async memory reclaim from the oom victim and later
> changes should help to reduce oom lockups even further.
>
> That being said this is not a right approach. It is even incorrect
> because it allows __GFP_NOFAIL to fail now. So NAK to this patch.
>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/page_alloc.c | 8 +++++++-
>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a178b1d..0dcf08b 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3457,6 +3457,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  	enum compact_result compact_result;
>>  	int compaction_retries = 0;
>>  	int no_progress_loops = 0;
>> +	int oom_failed = 0;
>>  
>>  	/*
>>  	 * In the slowpath, we sanity check order to avoid ever trying to
>> @@ -3645,8 +3646,13 @@ retry:
>>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>>  	if (page)
>>  		goto got_pg;
>> +	else
>> +		oom_failed++;
>> +
>> +	/* more than limited times will drop out */
>> +	if (oom_failed > MAX_RECLAIM_RETRIES)
>> +		goto nopage;
>>  
>> -	/* Retry as long as the OOM killer is making progress */
>>  	if (did_some_progress) {
>>  		no_progress_loops = 0;
>>  		goto retry;
>> -- 
>> 1.8.3.1
 hi,  Michal
 oom reaper indeed can accelerate the recovery of memory,  but the patch solve the extreme scenario,
 I hit it by runing trinity. I think the scenario can happen whether  oom reaper  or not.
 
The __GFP_NOFAIL should be considered. Thank you for reminding. The following patch is updated.

Thanks
zhongjiang

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a178b1d..47804c1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3457,6 +3457,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
        enum compact_result compact_result;
        int compaction_retries = 0;
        int no_progress_loops = 0;
+       int oom_failed = 0;

        /*
         * In the slowpath, we sanity check order to avoid ever trying to
@@ -3645,8 +3646,15 @@ retry:
        page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
        if (page)
                goto got_pg;
+       else
+               oom_failed++;
+
+       /* more than limited times will drop out */
+       if (oom_failed > MAX_RECLAIM_RETRIES) {
+               WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
+               goto nopage;
+       }

-       /* Retry as long as the OOM killer is making progress */
        if (did_some_progress) {
                no_progress_loops = 0;
                goto retry;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
