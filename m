Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 5A4846B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:32:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 412DA3EE0BD
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 15:32:28 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EAB345DE5D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 15:32:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 010A445DE54
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 15:32:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E47211DB8054
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 15:32:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 97F4C1DB804A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 15:32:27 +0900 (JST)
Message-ID: <4F69757E.5030103@jp.fujitsu.com>
Date: Wed, 21 Mar 2012 15:30:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] page cgroup diet
References: <4F66E6A5.10804@jp.fujitsu.com> <4F679039.6070609@openvz.org> <4F692895.8020908@jp.fujitsu.com> <4F69718E.8010603@openvz.org>
In-Reply-To: <4F69718E.8010603@openvz.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "suleiman@google.com" <suleiman@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, Tejun Heo <tj@kernel.org>

(2012/03/21 15:13), Konstantin Khlebnikov wrote:

> KAMEZAWA Hiroyuki wrote:
>> (2012/03/20 4:59), Konstantin Khlebnikov wrote:
>>
>>> KAMEZAWA Hiroyuki wrote:
>>>> This is just an RFC...test is not enough yet.
>>>>
>>>> I know it's merge window..this post is just for sharing idea.
>>>>
>>>> This patch merges pc->flags and pc->mem_cgroup into a word. Then,
>>>> memcg's overhead will be 8bytes per page(4096bytes?).
>>>>
>>>> Because this patch will affect all memory cgroup developers, I'd like to
>>>> show patches before MM Summit. I think we can agree the direction to
>>>> reduce size of page_cgroup..and finally integrate into 'struct page'
>>>> (and remove cgroup_disable= boot option...)
>>>>
>>>> Patch 1/3 - introduce pc_to_mem_cgroup and hide pc->mem_cgroup
>>>> Patch 2/3 - remove pc->mem_cgroup
>>>> Patch 3/3 - remove memory barriers.
>>>>
>>>> I'm now wondering when this change should be merged....
>>>>
>>>
>>> This is cool, but maybe we should skip this temporary step and merge all this stuff into page->flags.
>>
>>
>> Why we should skip and delay reduction of size of page_cgroup
>> which is considered as very big problem ?
> 
> I think it would be better to solve problem completely and kill page_cgroup in one step.
> 


I like step-by-step rather than a big step. I devided this page_cgroup diet patch set
into 3 steps (2012-Jan, 2012-Feb, and the next one is the last.)

This change may introduce new races as step1 and step2 did (Thanks to Hugh Dickins!).

Finally, IIUC, 'struct page' has 8bytes of padding now. I think we can use that space
if we can be agreed.

Hm. BTW, using lruvec in page->flags implies you add a dynamic table lookup in
free_page() and you need to reset page->flags to point a valid
lruvec at page allocation. Please take care of performance.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
