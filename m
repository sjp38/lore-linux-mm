Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m3J8dTqf029854
	for <linux-mm@kvack.org>; Sat, 19 Apr 2008 18:39:29 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3J8doLq4112590
	for <linux-mm@kvack.org>; Sat, 19 Apr 2008 18:39:50 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3J8dsgX023957
	for <linux-mm@kvack.org>; Sat, 19 Apr 2008 18:39:54 +1000
Message-ID: <4809AE78.9030000@linux.vnet.ibm.com>
Date: Sat, 19 Apr 2008 14:04:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Memory controller hierarchy support (v1)
References: <20080419053551.10501.44302.sendpatchset@localhost.localdomain> <20080419065624.9837E5A15@siro.lan>
In-Reply-To: <20080419065624.9837E5A15@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> -int res_counter_charge(struct res_counter *counter, unsigned long val)
>> +int res_counter_charge(struct res_counter *counter, unsigned long val,
>> +			struct res_counter **limit_exceeded_at)
>>  {
>>  	int ret;
>>  	unsigned long flags;
>> +	struct res_counter *c, *unroll_c;
>>  
>> -	spin_lock_irqsave(&counter->lock, flags);
>> -	ret = res_counter_charge_locked(counter, val);
>> -	spin_unlock_irqrestore(&counter->lock, flags);
>> +	*limit_exceeded_at = NULL;
>> +	local_irq_save(flags);
>> +	for (c = counter; c != NULL; c = c->parent) {
>> +		spin_lock(&c->lock);
>> +		ret = res_counter_charge_locked(c, val);
>> +		spin_unlock(&c->lock);
>> +		if (ret < 0) {
>> +			*limit_exceeded_at = c;
>> +			goto unroll;
>> +		}
>> +	}
>> +	local_irq_restore(flags);
>> +	return 0;
>> +
>> +unroll:
>> +	for (unroll_c = counter; unroll_c != c; unroll_c = unroll_c->parent) {
>> +		spin_lock(&unroll_c->lock);
>> +		res_counter_uncharge_locked(unroll_c, val);
>> +		spin_unlock(&unroll_c->lock);
>> +	}
>> +	local_irq_restore(flags);
>>  	return ret;
>>  }
> 
> i wonder how much performance impacts this involves.
> 
> it increases the number of atomic ops per charge/uncharge and
> makes the common case (success) of every charge/uncharge in a system
> touch a global (ie. root cgroup's) cachelines.
> 

Yes, it does. I'll run some tests to see what the overhead looks like. The
multi-hierarchy feature is very useful though and one of the TODOs is to make
the feature user selectable (possibly at run-time)

>> +		/*
>> +		 * Ideally we need to hold cgroup_mutex here
>> +		 */
>> +		list_for_each_entry_safe_from(cgroup, cgrp,
>> +				&curr_cgroup->children, sibling) {
>> +			struct mem_cgroup *mem_child;
>> +
>> +			mem_child = mem_cgroup_from_cont(cgroup);
>> +			ret = try_to_free_mem_cgroup_pages(mem_child,
>> +								gfp_mask);
>> +			mem->last_scanned_child = mem_child;
>> +			if (ret == 0)
>> +				break;
>> +		}
> 
> if i read it correctly, it makes us hit the last child again and again.
> 

Hmm.. it should probably be set at the beginining of the loop. I'll retest


> i think you want to reclaim from all cgroups under the curr_cgroup
> including eg. children's children.
> 

Yes, good point, I should break out the function, so that we can work around the
recursion problem. Charging can cause further recursion, since we check for
last_counter.

> YAMAMOTO Takashi


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
