Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id A18E56B00EA
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 02:57:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B2AD73EE0BC
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:57:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9418545DE5A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:57:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C0EA45DE54
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:57:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F3B5E38001
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:57:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A811E38003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 15:57:22 +0900 (JST)
Message-ID: <4F83D965.4040506@jp.fujitsu.com>
Date: Tue, 10 Apr 2012 15:55:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V5 12/14] memcg: move HugeTLB resource count to parent
 cgroup on memcg removal
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1333738260-1329-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F827EAD.9080300@jp.fujitsu.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu) <87ty0tcjhx.fsf@skywalker.in.ibm.com>
In-Reply-To: <87ty0tcjhx.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/04/09 19:00), Aneesh Kumar K.V wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
>> (2012/04/07 3:50), Aneesh Kumar K.V wrote:
>>
>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>>
>>> This add support for memcg removal with HugeTLB resource usage.
>>>
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>>
>>
>> Hmm 
>>
>>
> 
> ....
> ...
> 
>>> +	csize = PAGE_SIZE << compound_order(page);
>>> +	/*
>>> +	 * uncharge from child and charge the parent. If we have
>>> +	 * use_hierarchy set, we can never fail here. In-order to make
>>> +	 * sure we don't get -ENOMEM on parent charge, we first uncharge
>>> +	 * the child and then charge the parent.
>>> +	 */
>>> +	if (parent->use_hierarchy) {
>>
>>
>>> +		res_counter_uncharge(&memcg->hugepage[idx], csize);
>>> +		if (!mem_cgroup_is_root(parent))
>>> +			ret = res_counter_charge(&parent->hugepage[idx],
>>> +						 csize, &fail_res);
>>
>>
>> Ah, why is !mem_cgroup_is_root() checked ? no res_counter update for
>> root cgroup ?
> 
> My mistake. Earlier version of the patch series didn't charge/uncharge the root
> cgroup during different operations. Later as per your review I updated
> the charge/uncharge path to charge root cgroup. I missed to update this code.
> 
>>
>> I think it's better to have res_counter_move_parent()...to do ops in atomic.
>> (I'll post a patch for that for my purpose). OR, just ignore res->usage if
>> parent->use_hierarchy == 1.
>>
>> uncharge->charge will have a race.
> 
> 
> 
> How about the below
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7b6e79a..5b4bc98 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3351,24 +3351,24 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
>  
>  	csize = PAGE_SIZE << compound_order(page);
>  	/*
> -	 * uncharge from child and charge the parent. If we have
> -	 * use_hierarchy set, we can never fail here. In-order to make
> -	 * sure we don't get -ENOMEM on parent charge, we first uncharge
> -	 * the child and then charge the parent.
> +	 * If we have use_hierarchy set we can never fail here. So instead of
> +	 * using res_counter_uncharge use the open-coded variant which just
> +	 * uncharge the child res_counter. The parent will retain the charge.
>  	 */
>  	if (parent->use_hierarchy) {
> -		res_counter_uncharge(&memcg->hugepage[idx], csize);
> -		if (!mem_cgroup_is_root(parent))
> -			ret = res_counter_charge(&parent->hugepage[idx],
> -						 csize, &fail_res);
> +		unsigned long flags;
> +		struct res_counter *counter;
> +
> +		counter = &memcg->hugepage[idx];
> +		spin_lock_irqsave(&counter->lock, flags);
> +		res_counter_uncharge_locked(counter, csize);


Hm, uncharge_locked is not propagated to parent, I see.
Ok, it seems to work...but please add enough comment here. Or define
res_counter_move_parent().

> +		spin_unlock_irqrestore(&counter->lock, flags);
>  	} else {
> -		if (!mem_cgroup_is_root(parent)) {
> -			ret = res_counter_charge(&parent->hugepage[idx],
> -						 csize, &fail_res);
> -			if (ret) {
> -				ret = -EBUSY;
> -				goto err_out;
> -			}
> +		ret = res_counter_charge(&parent->hugepage[idx],
> +					 csize, &fail_res);
> +		if (ret) {
> +			ret = -EBUSY;
> +			goto err_out;
>  		}
>  		res_counter_uncharge(&memcg->hugepage[idx], csize);
>  	}
> 
> 
>>
>>> +	} else {
>>> +		if (!mem_cgroup_is_root(parent)) {
>>> +			ret = res_counter_charge(&parent->hugepage[idx],
>>> +						 csize, &fail_res);
>>> +			if (ret) {
>>> +				ret = -EBUSY;
>>> +				goto err_out;
>>> +			}
>>> +		}
>>> +		res_counter_uncharge(&memcg->hugepage[idx], csize);
>>> +	}
>>
>>
>> Just a notice. Recently, Tejun changed failure of pre_destory() to show WARNING.
>> Then, I'd like to move the usage to the root cgroup if use_hierarchy=0.
>> Will it work for you ?
> 
> That should work.
> 

ok, I'll go ahead in that way.

> 
>>
>>> +	/*
>>> +	 * caller should have done css_get
>>> +	 */
>>
>>
>> Could you explain meaning of this comment ?
>>
> 
> inherited from mem_cgroup_move_account. I guess it means css cannot go
> away at this point. We have done a css_get on the child. For a generic
> move_account function may be the comment is needed. I guess in our case
> the comment is redundant ?
> 


Ah, IIUC, this code is hugetlb version of mem_cgroup_move_parent().
At move_parent(), we don't need to take care of css counting because we're
moving from an exisiting cgroup to an cgroup which cannot be destroyed.
(move_account() is function to move account between arbitrary cgroup.)

So, yes, please remove comment.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
