Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB986B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 05:05:51 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so6682994pde.13
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 02:05:51 -0800 (PST)
Received: from mail-pb0-x229.google.com (mail-pb0-x229.google.com [2607:f8b0:400e:c01::229])
        by mx.google.com with ESMTPS id sz7si19985059pab.87.2014.02.03.02.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 02:05:50 -0800 (PST)
Received: by mail-pb0-f41.google.com with SMTP id up15so6881102pbc.14
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 02:05:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52EF3DBF.3000404@parallels.com>
References: <cover.1391356789.git.vdavydov@parallels.com>
	<570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com>
	<alpine.DEB.2.02.1402022219101.10847@chino.kir.corp.google.com>
	<52EF3DBF.3000404@parallels.com>
Date: Mon, 3 Feb 2014 14:05:50 +0400
Message-ID: <CAA6-i6p5V4SvmtABw6xC7M4M86tUrAFEVyHaOP8uqse3Az1iHg@mail.gmail.com>
Subject: Re: [PATCH 1/8] memcg: export kmemcg cache id via cgroup fs
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, devel@openvz.org

On Mon, Feb 3, 2014 at 10:57 AM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
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
>
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

Then maybe it is better to wrap it into some kind of CONFIG_DEBUG wrap.
We already have other files like that.

>> So it would be nice to have
>> consensus on how people are supposed to identify memcgs with a hierarchy:
>> either by exporting information like the id like you do here (but leave
>> the oom killer still problematic) or by insisting people name their memcgs
>> with unique names if they care to differentiate them.
>
> Anyway, I agree with you that this needs a consensus, because this is a
> functional change.
>
> Thanks.



-- 
E Mare, Libertas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
