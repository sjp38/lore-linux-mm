Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 182596B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 05:13:26 -0400 (EDT)
Message-ID: <51594FD8.5050002@parallels.com>
Date: Mon, 1 Apr 2013 13:14:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 26/28] memcg: per-memcg kmem shrinking
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-27-git-send-email-glommer@parallels.com> <515945E3.9090809@jp.fujitsu.com> <515949EB.7020400@parallels.com> <51594CED.4050401@jp.fujitsu.com>
In-Reply-To: <51594CED.4050401@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On 04/01/2013 01:01 PM, Kamezawa Hiroyuki wrote:
> (2013/04/01 17:48), Glauber Costa wrote:
>>>> +static int memcg_try_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>>>> +{
>>>> +	int retries = MEM_CGROUP_RECLAIM_RETRIES;
>>>
>>> I'm not sure this retry numbers, for anon/file LRUs is suitable for kmem.
>>>
>> Suggestions ?
>>
> 
> I think you did tests.
> 
Indeed. And in my tests, 2 or 3 retries are already enough to seal the
fate of this.

I though it was safer to go with the same number, though, exactly not to
be too biased by my specific test environments.

I am fine with >= 3.

Michal, you have input here?

>>>> +	struct res_counter *fail_res;
>>>> +	int ret;
>>>> +
>>>> +	do {
>>>> +		ret = res_counter_charge(&memcg->kmem, size, &fail_res);
>>>> +		if (!ret)
>>>> +			return ret;
>>>> +
>>>> +		if (!(gfp & __GFP_WAIT))
>>>> +			return ret;
>>>> +
>>>> +		/*
>>>> +		 * We will try to shrink kernel memory present in caches. We
>>>> +		 * are sure that we can wait, so we will. The duration of our
>>>> +		 * wait is determined by congestion, the same way as vmscan.c
>>>> +		 *
>>>> +		 * If we are in FS context, though, then although we can wait,
>>>> +		 * we cannot call the shrinkers. Most fs shrinkers (which
>>>> +		 * comprises most of our kmem data) will not run without
>>>> +		 * __GFP_FS since they can deadlock. The solution is to
>>>> +		 * synchronously run that in a different context.
>>>> +		 */
>>>> +		if (!(gfp & __GFP_FS)) {
>>>> +			/*
>>>> +			 * we are already short on memory, every queue
>>>> +			 * allocation is likely to fail
>>>> +			 */
>>>> +			memcg_stop_kmem_account();
>>>> +			schedule_work(&memcg->kmemcg_shrink_work);
>>>> +			flush_work(&memcg->kmemcg_shrink_work);
>>>> +			memcg_resume_kmem_account();
>>>> +		} else if (!try_to_free_mem_cgroup_kmem(memcg, gfp))
>>>> +			congestion_wait(BLK_RW_ASYNC, HZ/10);
>>>
>>> Why congestion_wait() ? I think calling congestion_wait() in vmscan.c is
>>> a part of memory-reclaim logic but I don't think the caller should do
>>> this kind of voluteer wait without good reason..
>>>
>>>
>>
>> Although it is not the case with dentries (or inodes, since only
>> non-dirty inodes goes to the lru list), some objects we are freeing may
>> need time to be written back to disk. This is the case for instance with
>> the buffer heads and bio's. They will not be actively shrunk in
>> shrinkers, but it is my understanding that they will be released. Inodes
>> as well, may have time to be written back and become non-dirty.
>>
>> In practice, in my tests, this would almost-always fail after a retry if
>> we don't wait, and almost always succeed in a retry if we do wait.
>>
>> Am I missing something in this interpretation ?
>>
> 
> Ah, sorry. Can't we put this wait into try_to_free_mem_cgroup_kmem().
> 

That I believe we can easily do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
