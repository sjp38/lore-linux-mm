Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id F27E06B0074
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 06:19:27 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 10:12:32 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6JAJHQG4194774
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 20:19:17 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6JAJGv4016966
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 20:19:17 +1000
Date: Thu, 19 Jul 2012 18:19:14 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memcg: wrap mem_cgroup_from_css function
Message-ID: <20120719101914.GA13612@kernel>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <a>
 <1342580730-25703-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20120719091420.GA2549@shutemov.name>
 <20120719092309.GA12409@kernel>
 <20120719093835.GA3776@shangw.(null)>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Content-Disposition: inline
In-Reply-To: <20120719093835.GA3776@shangw.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 19, 2012 at 05:38:35PM +0800, Gavin Shan wrote:
>On Thu, Jul 19, 2012 at 05:23:09PM +0800, Wanpeng Li wrote:
>>On Thu, Jul 19, 2012 at 12:14:20PM +0300, Kirill A. Shutemov wrote:
>>>On Wed, Jul 18, 2012 at 11:05:30AM +0800, Wanpeng Li wrote:
>>>> wrap mem_cgroup_from_css function to clarify get mem cgroup
>>>> from cgroup_subsys_state.
>>>> 
>>>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>>> Cc: Michal Hocko <mhocko@suse.cz>
>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>> Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
>>>> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>>> Cc: linux-kernel@vger.kernel.org
>>>> ---
>>>>  mm/memcontrol.c |   14 ++++++++++----
>>>>  1 files changed, 10 insertions(+), 4 deletions(-)
>>>> 
>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>> index 58a08fc..20f6a15 100644
>>>> --- a/mm/memcontrol.c
>>>> +++ b/mm/memcontrol.c
>>>> @@ -396,6 +396,12 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
>>>>  #include <net/sock.h>
>>>>  #include <net/ip.h>
>>>>  
>>>> +static inline
>>>> +struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>>>> +{
>>>> +	return container_of(s, struct mem_cgroup, css);
>>>> +}
>>>> +
>>>>  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>>>>  void sock_update_memcg(struct sock *sk)
>>>>  {
>>>> @@ -820,7 +826,7 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>>>>  
>>>>  struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
>>>>  {
>>>> -	return container_of(cgroup_subsys_state(cont,
>>>> +	return mem_cgroup_from_css(cgroup_subsys_state(cont,
>>>>  				mem_cgroup_subsys_id), struct mem_cgroup,
>>>>  				css);
>>>
>>>Hm?.. Here and below too many args to mem_cgroup_from_css().
>>>Have you tested the code?
>>
>>Hi, what's the meaning of "two many"?
>>
>
>It might be the typo for "two" here. I think it would be
>"too". However, it seems that you had pass "two" more arguments
>here to mem_cgroup_from_css() since the function only takes "one"
>parameter as you implemented before.
>
>+struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>
>+   return mem_cgroup_from_css(cgroup_subsys_state(cont,
>+		mem_cgroup_subsys_id), struct mem_cgroup,
>+		css);
>

Hi Andrew, 

Sorry for make a mistake. Please drop this patch from linux-mm 
and merged the new one. BTW, thanks Gavin and Kirill.

Best Regards,
Wanpeng Li


>Thanks,
>Gavin
>
>>cgroup_subsys_state(cont, mem_cgroup_subsys_id) and 
>>task_subsys_state(p, mem_cgroup_subsys_id) both are 
>>just one arg in mem_cgroup_from_css. :-)
>>
>>>
>>>>  }
>>>> @@ -835,7 +841,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>>>  	if (unlikely(!p))
>>>>  		return NULL;
>>>>  
>>>> -	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>>>> +	return mem_cgroup_from_css(task_subsys_state(p, mem_cgroup_subsys_id),
>>>>  				struct mem_cgroup, css);
>>>>  }
>>>>  
>>>> @@ -922,7 +928,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>>>>  		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
>>>>  		if (css) {
>>>>  			if (css == &root->css || css_tryget(css))
>>>> -				memcg = container_of(css,
>>>> +				memcg = mem_cgroup_from_css(css,
>>>>  						     struct mem_cgroup, css);
>>>>  		} else
>>>>  			id = 0;
>>>> @@ -2406,7 +2412,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>>>>  	css = css_lookup(&mem_cgroup_subsys, id);
>>>>  	if (!css)
>>>>  		return NULL;
>>>> -	return container_of(css, struct mem_cgroup, css);
>>>> +	return mem_cgroup_from_css(css, struct mem_cgroup, css);
>>>>  }
>>>>  
>>>>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>>>> -- 
>>>> 1.7.5.4
>>>> 
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>>-- 
>>> Kirill A. Shutemov
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--J/dobhs11T7y2rNN
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-memcg-add-mem_cgroup_from_css-helper.patch"


--J/dobhs11T7y2rNN--
