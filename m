Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CF2518D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 20:03:37 -0500 (EST)
Message-ID: <4D6C4652.6030804@cn.fujitsu.com>
Date: Tue, 01 Mar 2011 09:05:22 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cpuset: Add a missing unlock in cpuset_write_resmask()
References: <4D6601B2.1090207@cn.fujitsu.com> <20110228155524.6d7563e0.akpm@linux-foundation.org>
In-Reply-To: <20110228155524.6d7563e0.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

>> @@ -1561,8 +1561,10 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
>>  		return -ENODEV;
>>  
>>  	trialcs = alloc_trial_cpuset(cs);
>> -	if (!trialcs)
>> +	if (!trialcs) {
>> +		cgroup_unlock();
>>  		return -ENOMEM;
>> +	}
>>  
>>  	switch (cft->private) {
>>  	case FILE_CPULIST:
> 
> It would be better to avoid multiple returns - it leads to more
> maintainable code and often shorter code:
> 

I have no strong opinion on this.

> --- a/kernel/cpuset.c~cpuset-add-a-missing-unlock-in-cpuset_write_resmask-fix
> +++ a/kernel/cpuset.c
> @@ -1562,8 +1562,8 @@ static int cpuset_write_resmask(struct c
>  
>  	trialcs = alloc_trial_cpuset(cs);
>  	if (!trialcs) {
> -		cgroup_unlock();
> -		return -ENOMEM;
> +		retval = -ENOMEM;
> +		goto out;
>  	}
>  
>  	switch (cft->private) {
> @@ -1579,6 +1579,7 @@ static int cpuset_write_resmask(struct c
>  	}
>  
>  	free_trial_cpuset(trialcs);
> +out:
>  	cgroup_unlock();
>  	return retval;
>  }
> _
> 
> also, alloc_trial_cpuset() is a fairly slow-looking function. 
> cpuset_write_resmask() could run alloc_trial_cpuset() before running
> cgroup_lock_live_group(), thereby reducing lock hold times.
> 

Nope. alloc_trial_cpuset() will read 'cs', so it must be protected by
the lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
