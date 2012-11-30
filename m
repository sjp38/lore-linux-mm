Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 942926B00BF
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:29:48 -0500 (EST)
Message-ID: <50B8D0E3.2080901@parallels.com>
Date: Fri, 30 Nov 2012 19:29:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memcg: prevent changes to move_charge_at_immigrate
 during task attach
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <1354282286-32278-3-git-send-email-glommer@parallels.com> <20121130151922.GC3873@htj.dyndns.org>
In-Reply-To: <20121130151922.GC3873@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

>>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
>> +	int ret = -EAGAIN;
>>  
>>  	if (val >= (1 << NR_MOVE_TYPE))
>>  		return -EINVAL;
>> @@ -4123,10 +4130,13 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
>>  	 * inconsistent.
>>  	 */
>>  	cgroup_lock();
>> +	if (memcg->attach_in_progress)
>> +		goto out;
>>  	memcg->move_charge_at_immigrate = val;
>> +	ret = 0;
>> +out:
>>  	cgroup_unlock();
>> -
>> -	return 0;
>> +	return ret;
> 
> Unsure whether this is a good behavior. 
to be honest, I am not so sure myself. I kinda leaned towards this after
some consideration, because the other solution I saw was basically busy
waiting...

> It's a bit nasty to fail for
> internal temporary reasons like this.  If it ever causes a problem,
> the occurrences are likely to be far and between making it difficult
> to debug.  Can't you determine to immigrate or not in ->can_attach(),
> record whether to do that or not on the css, and finish it in
> ->attach() according to that.  There's no need to consult the config
> multiple times.
> 
Well, yeah... that is an option too, and indeed better. Good call.

I will send it again soon



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
