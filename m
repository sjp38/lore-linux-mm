Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 552406B028B
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 00:21:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2F7783EE0BC
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:21:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1660645DEB2
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:21:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F16D045DEA6
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:21:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E36EC1DB8040
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:21:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E1291DB803E
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:21:52 +0900 (JST)
Message-ID: <4FE543D9.2010802@jp.fujitsu.com>
Date: Sat, 23 Jun 2012 13:19:37 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 23/25] memcg: propagate kmem limiting information to
 children
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-24-git-send-email-glommer@parallels.com> <4FDF20ED.4090401@jp.fujitsu.com> <4FDF227B.3080601@parallels.com> <4FDFC4D4.1030303@jp.fujitsu.com> <4FE039B9.3080809@parallels.com> <4FE03E4B.5020809@parallels.com> <4FE19102.6030704@parallels.com>
In-Reply-To: <4FE19102.6030704@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2012/06/20 17:59), Glauber Costa wrote:
> On 06/19/2012 12:54 PM, Glauber Costa wrote:
>> On 06/19/2012 12:35 PM, Glauber Costa wrote:
>>> On 06/19/2012 04:16 AM, Kamezawa Hiroyuki wrote:
>>>> (2012/06/18 21:43), Glauber Costa wrote:
>>>>> On 06/18/2012 04:37 PM, Kamezawa Hiroyuki wrote:
>>>>>> (2012/06/18 19:28), Glauber Costa wrote:
>>>>>>> The current memcg slab cache management fails to present satisfatory hierarchical
>>>>>>> behavior in the following scenario:
>>>>>>>
>>>>>>> ->   /cgroups/memory/A/B/C
>>>>>>>
>>>>>>> * kmem limit set at A
>>>>>>> * A and B empty taskwise
>>>>>>> * bash in C does find /
>>>>>>>
>>>>>>> Because kmem_accounted is a boolean that was not set for C, no accounting
>>>>>>> would be done. This is, however, not what we expect.
>>>>>>>
>>>>>>
>>>>>> Hmm....do we need this new routines even while we have mem_cgroup_iter() ?
>>>>>>
>>>>>> Doesn't this work ?
>>>>>>
>>>>>> 	struct mem_cgroup {
>>>>>> 		.....
>>>>>> 		bool kmem_accounted_this;
>>>>>> 		atomic_t kmem_accounted;
>>>>>> 		....
>>>>>> 	}
>>>>>>
>>>>>> at set limit
>>>>>>
>>>>>> 	....set_limit(memcg) {
>>>>>>
>>>>>> 		if (newly accounted) {
>>>>>> 			mem_cgroup_iter() {
>>>>>> 				atomic_inc(&iter->kmem_accounted)
>>>>>> 			}
>>>>>> 		} else {
>>>>>> 			mem_cgroup_iter() {
>>>>>> 				atomic_dec(&iter->kmem_accounted);
>>>>>> 			}
>>>>>> 	}
>>>>>>
>>>>>>
>>>>>> hm ? Then, you can see kmem is accounted or not by atomic_read(&memcg->kmem_accounted);
>>>>>>
>>>>>
>>>>> Accounted by itself / parent is still useful, and I see no reason to use
>>>>> an atomic + bool if we can use a pair of bits.
>>>>>
>>>>> As for the routine, I guess mem_cgroup_iter will work... It does a lot
>>>>> more than I need, but for the sake of using what's already in there, I
>>>>> can switch to it with no problems.
>>>>>
>>>>
>>>> Hmm. please start from reusing existing routines.
>>>> If it's not enough, some enhancement for generic cgroup  will be welcomed
>>>> rather than completely new one only for memcg.
>>>>
>>>
>>> And now that I am trying to adapt the code to the new function, I
>>> remember clearly why I done this way. Sorry for my failed memory.
>>>
>>> That has to do with the order of the walk. I need to enforce hierarchy,
>>> which means whenever a cgroup has !use_hierarchy, I need to cut out that
>>> branch, but continue scanning the tree for other branches.
>>>
>>> That is a lot easier to do with depth-search tree walks like the one
>>> proposed in this patch. for_each_mem_cgroup() seems to walk the tree in
>>> css-creation order. Which means we need to keep track of parents that
>>> has hierarchy disabled at all times ( can be many ), and always test for
>>> ancestorship - which is expensive, but I don't particularly care.
>>>
>>> But I'll give another shot with this one.
>>>
>>
>> Humm, silly me. I was believing the hierarchical settings to be more
>> flexible than they really are.
>>
>> I thought that it could be possible for a children of a parent with
>> use_hierarchy = 1 to have use_hierarchy = 0.
>>
>> It seems not to be the case. This makes my life a lot easier.
>>
> 
> How about the following patch?
> 
> It is still expensive in the clear_bit case, because I can't just walk
> the whole tree flipping the bit down: I need to stop whenever I see a
> branch whose root is itself accounted - and the ordering of iter forces
> me to always check the tree up (So we got O(n*h) h being height instead
> of O(n)).
> 
> for flipping the bit up, it is easy enough.
> 
> 
Yes. It seems much nicer.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
