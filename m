Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 537C26B0123
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:20:30 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5A05D3EE0B5
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:20:28 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BAF745DEB3
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:20:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AAC145DEAD
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:20:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 01717E38008
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:20:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD313E38005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:20:27 +0900 (JST)
Message-ID: <4F73AA5F.5050604@jp.fujitsu.com>
Date: Thu, 29 Mar 2012 09:18:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120328134020.GG20949@tiehlicka.suse.cz>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu) <87y5qk1vat.fsf@skywalker.in.ibm.com>
In-Reply-To: <87y5qk1vat.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/03/29 2:37), Aneesh Kumar K.V wrote:

> Michal Hocko <mhocko@suse.cz> writes:
> 
>> On Fri 16-03-12 23:09:24, Aneesh Kumar K.V wrote:
>> [...]
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 6728a7a..4b36c5e 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>> [...]
>>> @@ -4887,6 +5013,7 @@ err_cleanup:
>>>  static struct cgroup_subsys_state * __ref
>>>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>>>  {
>>> +	int idx;
>>>  	struct mem_cgroup *memcg, *parent;
>>>  	long error = -ENOMEM;
>>>  	int node;
>>> @@ -4929,9 +5056,14 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>>>  		 * mem_cgroup(see mem_cgroup_put).
>>>  		 */
>>>  		mem_cgroup_get(parent);
>>> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
>>> +			res_counter_init(&memcg->hugepage[idx],
>>> +					 &parent->hugepage[idx]);
>>
>> Hmm, I do not think we want to make groups deeper in the hierarchy
>> unlimited as we cannot reclaim. Shouldn't we copy the limit from the parent?
>> Still not ideal but slightly more expected behavior IMO.
> 
> But we should be limiting the child group based on parent's limit only
> when hierarchy is set right ?
> 
>>
>> The hierarchy setups are still interesting and the limitations should be
>> described in the documentation...
>>
> 
> It should behave similar to memcg. ie, if hierarchy is set, then we limit
> using MIN(parent's limit, child's limit). May be I am missing some of
> the details of memcg use_hierarchy config. My goal was to keep it
> similar to memcg. Can you explain why do you think the patch would
> make it any different ?
> 


Maybe this is a different story but....

Tejun(Cgroup Maintainer) asked us to remove 'use_hierarchy' settings because
most of other cgroups are hierarchical(*). I answered that improvement in res_counter 
latency is required. And now, we have some idea to improve res_counter.
(I'd like to try this after page_cgroup diet series..)

If we change and drop use_hierarchy, the usage similar to current use_hierarchy=0
will be..

	/cgroup/memory/			       = unlimited
			level1		       = unlimited
				level2	       = unlimited
					level3 = limit

To do this, after improvement of res_counter, we entry use_hierarchy into
feature-removal-list and wait for 2 versions..So, this will not affect
your developments, anyway.
 
Thanks,
-Kame

(*) AFAIK, blkio cgroup needs tons of work to be hierarchical...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
