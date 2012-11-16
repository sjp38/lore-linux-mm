Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 0021F6B0078
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:50:57 -0500 (EST)
Message-ID: <50A660D1.7020001@parallels.com>
Date: Fri, 16 Nov 2012 19:50:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] memcg: get rid of once-per-second cache shrinking
 for dead memcgs
References: <1352948093-2315-1-git-send-email-glommer@parallels.com> <1352948093-2315-6-git-send-email-glommer@parallels.com> <50A4B8C8.6020202@jp.fujitsu.com> <50A4F289.1090807@parallels.com> <50A5CA16.7070603@jp.fujitsu.com> <50A5E73F.8030201@parallels.com> <50A5E997.6060002@jp.fujitsu.com> <20121116145508.GC2006@dhcp22.suse.cz>
In-Reply-To: <20121116145508.GC2006@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

On 11/16/2012 06:55 PM, Michal Hocko wrote:
> On Fri 16-11-12 16:21:59, KAMEZAWA Hiroyuki wrote:
>> (2012/11/16 16:11), Glauber Costa wrote:
>>> On 11/16/2012 09:07 AM, Kamezawa Hiroyuki wrote:
>>>> (2012/11/15 22:47), Glauber Costa wrote:
>>>>> On 11/15/2012 01:41 PM, Kamezawa Hiroyuki wrote:
>>>>>> (2012/11/15 11:54), Glauber Costa wrote:
>>>>>>> The idea is to synchronously do it, leaving it up to the shrinking
>>>>>>> facilities in vmscan.c and/or others. Not actively retrying shrinking
>>>>>>> may leave the caches alive for more time, but it will remove the ugly
>>>>>>> wakeups. One would argue that if the caches have free objects but are
>>>>>>> not being shrunk, it is because we don't need that memory yet.
>>>>>>>
>>>>>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>>>>>> CC: Michal Hocko <mhocko@suse.cz>
>>>>>>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>>>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>>>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>>>>
>>>>>> I agree this patch but can we have a way to see the number of unaccounted
>>>>>> zombie cache usage for debugging ?
>>>>>>
>>>>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>>>>
>>>>> Any particular interface in mind ?
>>>>>
>>>>
>>>> Hmm, it's debug interface and having cgroup file may be bad.....
>>>> If it can be seen in bytes or some, /proc/vmstat ?
>>>>
>>>> out_of_track_slabs  xxxxxxx. hm ?
>>>>
>>>
>>> I particularly think that, being this a debug interface, it is also
>>> useful to have an indication of which caches are still in place. This is
>>> because the cache itself, is the best indication we have about the
>>> specific workload that may be keeping it in memory.
>>>
>>> I first thought debugfs could help us probing useful information out of
>>> it, but given all the abuse people inflicted in debugfs... maybe we
>>> could have a file in the root memcg with that information for all
>>> removed memcgs? If we do that, we can go further and list the memcgs
>>> that are pending due to memsw as well. memory.dangling_memcgs ?
>>>
>>
>> Hm, I'm ok with it... others ?
> 
> What about memory.kmem.dangling_caches?
> 
If that is what it does, sure.

But as I said, kmem is not the only thing that can keep caches in
memory. If we're going for this, maybe we should be more comprehensive
and show it all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
