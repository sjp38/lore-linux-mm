Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CF4E56B0253
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 12:00:40 -0400 (EDT)
Received: by pawu10 with SMTP id u10so167074009paw.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:00:40 -0700 (PDT)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id l4si4271946pde.60.2015.08.11.09.00.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 09:00:39 -0700 (PDT)
Received: from kws-ab1.gw.nic.fujitsu.com (kws-ab1.gw.nic.fujitsu.com [133.161.11.10])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id A12B2AC0225
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 01:00:35 +0900 (JST)
Subject: Re: [PATCH 0/3] Make workingset detection logic memcg aware
References: <cover.1438599199.git.vdavydov@parallels.com>
 <55C16842.9040505@jp.fujitsu.com> <20150806085911.GL11971@esperanza>
 <55C40C08.8010706@jp.fujitsu.com> <20150808130501.GA16760@esperanza>
 <55C75FC9.2060803@jp.fujitsu.com> <20150810081414.GB16760@esperanza>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <55CA1BFB.5090408@jp.fujitsu.com>
Date: Wed, 12 Aug 2015 00:59:55 +0900
MIME-Version: 1.0
In-Reply-To: <20150810081414.GB16760@esperanza>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/08/10 17:14, Vladimir Davydov wrote:
> On Sun, Aug 09, 2015 at 11:12:25PM +0900, Kamezawa Hiroyuki wrote:
>> On 2015/08/08 22:05, Vladimir Davydov wrote:
>>> On Fri, Aug 07, 2015 at 10:38:16AM +0900, Kamezawa Hiroyuki wrote:
> ...
>>>> All ? hmm. It seems that mixture of record of global memory pressure and of local memory
>>>> pressure is just wrong.
>>>
>>> What makes you think so? An example of misbehavior caused by this would
>>> be nice to have.
>>>
>>
>> By design, memcg's LRU aging logic is independent from global memory allocation/pressure.
>>
>>
>> Assume there are 4 containers(using much page-cache) with 1GB limit on 4GB server,
>>    # contaienr A  workingset=600M   limit=1G (sleepy)
>>    # contaienr B  workingset=300M   limit=1G (work often)
>>    # container C  workingset=500M   limit=1G (work slowly)
>>    # container D  workingset=1.2G   limit=1G (work hard)
>> container D can drive the zone's distance counter because of local memory reclaim.
>> If active/inactive = 1:1, container D page can be activated.
>> At kswapd(global reclaim) runs, all container's LRU will rotate.
>>
>> Possibility of refault in A, B, C is reduced by conainer D's counter updates.
>
> This does not necessarily mean we have to use different inactive_age
> counter for global and local memory pressure. In your example, having
> inactive_age per lruvec and using it for evictions on both global and
> local memory pressure would work just fine.
>

you're right.

  
>>
>>
>>>>                  if (current memcg == recorded memcg && eviction distance is okay)
>>>>                       activate page.
>>>>                  else
>>>>                       inactivate
>>>> At page-out
>>>>          if (global memory pressure)
>>>>                  record eviction id with using zone's counter.
>>>>          else if (memcg local memory pressure)
>>>>                  record eviction id with memcg's counter.
>>>>
>>>
>>> I don't understand how this is supposed to work when a memory cgroup
>>> experiences both local and global pressure simultaneously.
>>>
>>
>> I think updating global distance counter by local reclaim may update counter too much.
>
> But if the inactive_age counter was per lruvec, then we wouldn't need to
> bother about it.
>
yes.

Anyway, what I understand now is that we need to reduce influence from a memcg's behavior
against other memcgs. Your way is dividing counter completely, my idea was implementing
different counter. Doing it by calculation will be good because we can't have enough record
space.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
