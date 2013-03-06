Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9CD6B6B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 05:55:02 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 326CA3EE0BB
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:55:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19FA245DE54
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:55:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F384645DE60
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:55:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB6B61DB8052
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:55:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52723E08005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:55:00 +0900 (JST)
Message-ID: <51372069.7070607@jp.fujitsu.com>
Date: Wed, 06 Mar 2013 19:54:33 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/5] memcg: make it suck faster
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-4-git-send-email-glommer@parallels.com> <513691CD.3070806@jp.fujitsu.com> <5137007E.7030004@parallels.com>
In-Reply-To: <5137007E.7030004@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

(2013/03/06 17:38), Glauber Costa wrote:
> 
>>
>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>> CC: Michal Hocko <mhocko@suse.cz>
>>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>> CC: Mel Gorman <mgorman@suse.de>
>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>
>> After quick look, it seems most parts are good. But I have a concern.
>>
>> At memcg enablement, you move the numbers from vm_stat[] to res_counters.
>>
> Not only to res_counters. Mostly to mem_cgroup_stat_cpu, but I do move
> to res_counters as well.
> 
>> Why you need it ? It's not explained.
> 
> Because at this point, the bypass will no longer be in effect and we
> need accurate figures in root cgroup about what happened so far.
> 
> If we always have root-level hierarchy, then the bypass could go on
> forever. But if we have not, we'll need to rely on whatever was in there.
> 
>> And if it's necessary, uncharge will leak because page_cgroup is not marked
>> as PCG_USED, pc->mem_cgroup == NULL. So, res.usage will not be decreased.
>>
> 
> The same problem happen when deriving an mz from a page. Since
> pc->mem_cgroup will be NULL. I am interpreting that as "root mem cgroup".
> 
yes.

> Maybe even better would be to scan page cgroup writing a magic. Then if
> we see that magic we are sure it is an uninitialized pc.
> 
>> Could you fix it if you need to move numbers to res_counter ?
>>
> 
> At least for the pages in LRUs, I can scan them all, and update their
> page information. I am just wondering if this isn't a *very* expensive
> operation. Fine that we do it once, but still, is potentially scanning
> *all* pages in the system.
> 
> So I've basically decided it is better to interpret pc->mem_cgroup =
> NULL as this uninitialized state. (and can change to a magic)
> 

I think it can work. 

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
