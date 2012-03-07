Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E31416B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 04:07:00 -0500 (EST)
Message-ID: <4F5724BC.10207@cn.fujitsu.com>
Date: Wed, 07 Mar 2012 17:05:00 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier related
 damage v2
References: <20120306132735.GA2855@suse.de> <20120306122657.8e5b128d.akpm@linux-foundation.org> <20120306224201.GA17697@suse.de> <20120306145451.8eff82a6.akpm@linux-foundation.org>
In-Reply-To: <20120306145451.8eff82a6.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 6 Mar 2012 14:54:51 -0800, Andrew Morton wrote:
>>>> -static inline void put_mems_allowed(void)
>>>> +/*
>>>> + * If this returns false, the operation that took place after get_mems_allowed
>>>> + * may have failed. It is up to the caller to retry the operation if
>>>> + * appropriate
>>>> + */
>>>> +static inline bool put_mems_allowed(unsigned int seq)
>>>>  {
>>>> -	/*
>>>> -	 * ensure that reading mems_allowed and mempolicy before reducing
>>>> -	 * mems_allowed_change_disable.
>>>> -	 *
>>>> -	 * the write-side task will know that the read-side task is still
>>>> -	 * reading mems_allowed or mempolicy, don't clears old bits in the
>>>> -	 * nodemask.
>>>> -	 */
>>>> -	smp_mb();
>>>> -	--ACCESS_ONCE(current->mems_allowed_change_disable);
>>>> +	return !read_seqcount_retry(&current->mems_allowed_seq, seq);
>>>>  }
>>>>  
>>>>  static inline void set_mems_allowed(nodemask_t nodemask)
>>>
>>> How come set_mems_allowed() still uses task_lock()?
>>>
>>
>> Consistency.
>>
>> The task_lock is taken by kernel/cpuset.c when updating
>> mems_allowed so it is taken here. That said, it is unnecessary to take
>> as the two places where set_mems_allowed is used are not going to be
>> racing. In the unlikely event that set_mems_allowed() gets another user,
>> there is no harm is leaving the task_lock as it is. It's not in a hot
>> path of any description.
> 
> But shouldn't set_mems_allowed() bump mems_allowed_seq?
> 

task_lock is also used to protect mempolicy, so ...

Thanks
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
