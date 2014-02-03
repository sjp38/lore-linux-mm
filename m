Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 008876B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 02:19:58 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id z5so4958003lbh.22
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 23:19:58 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ov7si3252925lbb.70.2014.02.02.23.19.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Feb 2014 23:19:39 -0800 (PST)
Message-ID: <52EF4309.2040103@parallels.com>
Date: Mon, 3 Feb 2014 11:19:37 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] memcg: export kmemcg cache id via cgroup fs
References: <cover.1391356789.git.vdavydov@parallels.com> <570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com> <alpine.DEB.2.02.1402022219101.10847@chino.kir.corp.google.com> <52EF3DBF.3000404@parallels.com>
In-Reply-To: <52EF3DBF.3000404@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, mhocko@suse.cz, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

[adding Johannes Weiner and Hugh Dickins to cc in case they have
something to object against this]

On 02/03/2014 10:57 AM, Vladimir Davydov wrote:
> On 02/03/2014 10:21 AM, David Rientjes wrote:
>> On Sun, 2 Feb 2014, Vladimir Davydov wrote:
>>
>>> Per-memcg kmem caches are named as follows:
>>>
>>>   <global-cache-name>(<cgroup-kmem-id>:<cgroup-name>)
>>>
>>> where <cgroup-kmem-id> is the unique id of the memcg the cache belongs
>>> to, <cgroup-name> is the relative name of the memcg on the cgroup fs.
>>> Cache names are exposed to userspace for debugging purposes (e.g. via
>>> sysfs in case of slub or via dmesg).
>>>
>>> Using relative names makes it impossible in general (in case the cgroup
>>> hierarchy is not flat) to find out which memcg a particular cache
>>> belongs to, because <cgroup-kmem-id> is not known to the user. Since
>>> using absolute cgroup names would be an overkill, let's fix this by
>>> exporting the id of kmem-active memcg via cgroup fs file
>>> "memory.kmem.id".
>>>
>> Hmm, I'm not sure exporting additional information is the best way to do 
>> it only for this purpose.  I do understand the problem in naming 
>> collisions if the hierarchy isn't flat and we typically work around that 
>> by ensuring child memcgs still have a unique memcg.  This isn't only a 
>> problem in slab cache naming, me also avoid printing the entire absolute 
>> names for things like the oom killer.
> AFAIU, cgroup identifiers dumped on oom (cgroup paths, currently) and
> memcg slab cache names serve for different purposes. The point is oom is
> a perfectly normal situation for the kernel, and info dumped to dmesg is
> for admin to find out the cause of the problem (a greedy user or
> cgroup). On the other hand, slab cache names are dumped to dmesg only on
> extraordinary situations - like bugs in slab implementation, or double
> free, or detected memory leaks - where we usually do not need the name
> of the memcg that triggered the problem, because the bug is likely to be
> in the kernel subsys using the cache. Plus, the names are exported to
> sysfs in case of slub, again for debugging purposes, AFAIK. So IMO the
> use cases for oom vs slab names are completely different - information
> vs debugging - and I want to export kmem.id only for the ability of
> debugging kmemcg and slab subsystems.
>
>> So it would be nice to have 
>> consensus on how people are supposed to identify memcgs with a hierarchy: 
>> either by exporting information like the id like you do here (but leave 
>> the oom killer still problematic) or by insisting people name their memcgs 
>> with unique names if they care to differentiate them.
> Anyway, I agree with you that this needs a consensus, because this is a
> functional change.
>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
