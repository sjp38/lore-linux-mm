Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 33EA96B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 23:30:51 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id q126so42922885iof.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 20:30:51 -0800 (PST)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id t4si853635igh.77.2015.12.16.20.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 20:30:50 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id A27F0AC01C7
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 13:30:45 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz> <20151214194258.GH28521@esperanza>
 <566F8781.80108@jp.fujitsu.com> <20151215145011.GA20355@cmpxchg.org>
 <5670D806.60408@jp.fujitsu.com> <20151216110912.GA29816@cmpxchg.org>
 <56722203.5030604@jp.fujitsu.com> <20151217033204.GA29735@cmpxchg.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56723A46.2050900@jp.fujitsu.com>
Date: Thu, 17 Dec 2015 13:29:58 +0900
MIME-Version: 1.0
In-Reply-To: <20151217033204.GA29735@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/17 12:32, Johannes Weiner wrote:
> On Thu, Dec 17, 2015 at 11:46:27AM +0900, Kamezawa Hiroyuki wrote:
>> On 2015/12/16 20:09, Johannes Weiner wrote:
>>> On Wed, Dec 16, 2015 at 12:18:30PM +0900, Kamezawa Hiroyuki wrote:
>>>>   - swap-full notification via vmpressure or something mechanism.
>>>
>>> Why?
>>>
>>
>> I think it's a sign of unhealthy condition, starting file cache drop rate to rise.
>> But I forgot that there are resource threshold notifier already. Does the notifier work
>> for swap.usage ?
>
> That will be reflected in vmpressure or other distress mechanisms. I'm
> not convinced "ran out of swap space" needs special casing in any way.
>
Most users checks swap space shortage as "system alarm" in enterprise systems.
At least, our customers checks swap-full.

>>>>   - force swap-in at reducing swap.limit
>>>
>>> Why?
>>>
>> If full, swap.limit cannot be reduced even if there are available memory in a cgroup.
>> Another cgroup cannot make use of the swap resource while it's occupied by other cgroup.
>> The job scheduler should have a chance to fix the situation.
>
> I don't see why swap space allowance would need to be as dynamically
> adjustable as the memory allowance. There is usually no need to be as
> tight with swap space as with memory, and the performance penalty of
> swapping, even with flash drives, is high enough that swap space acts
> as an overflow vessel rather than be part of the regularly backing of
> the anonymous/shmem working set. It really is NOT obvious that swap
> space would need to be adjusted on the fly, and that it's important
> that reducing the limit will be reflected in consumption right away.
>

With my OS support experience, some customers consider swap-space as a resource.


> We shouldn't be adding hundreds of lines of likely terrible heuristics
> code* on speculation that somebody MIGHT find this useful in real life.
> We should wait until we are presented with a real usecase that applies
> to a whole class of users, and then see what the true requirements are.
>
ok, we should wait.  I'm just guessing (japanese) HPC people will want the
feature for their job control. I hear many programs relies on swap.

> * If a group has 200M swapped out and the swap limit is reduced by 10M
> below the current consumption, which pages would you swap in? There is
> no LRU list for swap space.
>
If a rotation can happen when a swap-in-by-real-pagefault, random swap-in
at reducing swap.limit will work enough.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
