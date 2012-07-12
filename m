Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C38286B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 07:51:33 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4433394pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 04:51:32 -0700 (PDT)
Date: Thu, 12 Jul 2012 19:51:25 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH RFC] mm/memcg: recalculate chargeable space after waiting
 migrating charges
Message-ID: <20120712115125.GA11103@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1342089561-11211-1-git-send-email-liwp.linux@gmail.com>
 <20120712110838.GE21013@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712110838.GE21013@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

On Thu, Jul 12, 2012 at 01:08:38PM +0200, Michal Hocko wrote:
>On Thu 12-07-12 18:39:21, Wanpeng Li wrote:
>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>> 
>> Function mem_cgroup_do_charge will call mem_cgroup_reclaim,
>> there are two break points in mem_cgroup_reclaim:
>> if (total && (flag & MEM_CGROUP_RECLAIM_SHIRINK))
>> 	break;
>> if (mem_cgroup_margin(memcg))
>> 	break;
>> so mem_cgroup_reclaim can't guarantee reclaim enough pages(nr_pages) 
>> which is requested from mem_cgroup_do_charge, if mem_cgroup_margin
>> (mem_over_limit) >= nr_pages is not true, the process will go to
>> mem_cgroup_wait_acct_move to wait doubly charge counted caused by
>> task move. 
>
>I am sorry but I have no idea what you are trying to say. The
>mem_cgroup_wait_acct_move just makes sure that we are waiting until
>charge is moved (which can potentially free some charges) rather than
>OOM which should be the last resort so it makes sense to retry them
>charge.
>
>> But this time still can't guarantee enough pages(nr_pages) is
>> ready, directly return CHARGE_RETRY is incorret. 
>
>So you think it is better to oom? Why? What prevents you from a race
>that your mem_cgroup_margin returns true but another CPU consumes those
>charges right after that. See? The check is pointless. It doesn't

Hmm, if there are a race as you mentioned it can't guarantee enough pages 
is ready. But it also means that available memory is too low if this 
race happen. If available charges still less than nr_pages after 
mem_cgroup_wait_acct_move(which can potentially free some charges) return,
the CHAGE_RETRY will trigged, and then mem_cgroup_do_charge=>meory_cgroup_reclaim
=>mem_cgroup_wait_acct_move, if available charges still less than nr_pages in 
this round, CHAGE_RETRY..... To avoid this infinite retry when available memory 
in this memcg is very low , go to OOM if mem_cgroup_margin(mem_over_limit) 
< nr_pages is a better way I think. Because the codes have already try
its best to reclaim some pages. :-)

>guarantee anything.
>
>> We should add a check to confirm enough pages is ready, otherwise go
>> to oom.
>
>What you are trying to fix? How have you tested it? Why do you think it
>makes any sense at all?
>You are just changing the behavior without any rationale. And that's a
>_no_go_!
>
>> 
>> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>> ---
>>  mm/memcontrol.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>> 
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index f72b5e5..4ae3848 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2210,7 +2210,8 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>  	 * At task move, charge accounts can be doubly counted. So, it's
>>  	 * better to wait until the end of task_move if something is going on.
>>  	 */
>> -	if (mem_cgroup_wait_acct_move(mem_over_limit))
>> +	if (mem_cgroup_wait_acct_move(mem_over_limit)
>> +			&& mem_cgroup_margin(mem_over_limit) >= nr_pages)
>>  		return CHARGE_RETRY;
>>  
>>  	/* If we don't need to call oom-killer at el, return immediately */
>> -- 
>> 1.7.5.4
>> 
>
>-- 
>Michal Hocko
>SUSE Labs
>SUSE LINUX s.r.o.
>Lihovarska 1060/12
>190 00 Praha 9    
>Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
