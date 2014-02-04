Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id E0EE66B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 09:44:06 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id t61so4235698wes.36
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 06:44:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si12133787wjy.130.2014.02.04.06.44.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 06:44:05 -0800 (PST)
Date: Tue, 4 Feb 2014 15:44:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/8] memcg: export kmemcg cache id via cgroup fs
Message-ID: <20140204144404.GF4890@dhcp22.suse.cz>
References: <cover.1391356789.git.vdavydov@parallels.com>
 <570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com>
 <alpine.DEB.2.02.1402022219101.10847@chino.kir.corp.google.com>
 <52EF3DBF.3000404@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52EF3DBF.3000404@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Mon 03-02-14 10:57:03, Vladimir Davydov wrote:
> On 02/03/2014 10:21 AM, David Rientjes wrote:
> > On Sun, 2 Feb 2014, Vladimir Davydov wrote:
> >
> >> Per-memcg kmem caches are named as follows:
> >>
> >>   <global-cache-name>(<cgroup-kmem-id>:<cgroup-name>)
> >>
> >> where <cgroup-kmem-id> is the unique id of the memcg the cache belongs
> >> to, <cgroup-name> is the relative name of the memcg on the cgroup fs.
> >> Cache names are exposed to userspace for debugging purposes (e.g. via
> >> sysfs in case of slub or via dmesg).
> >>
> >> Using relative names makes it impossible in general (in case the cgroup
> >> hierarchy is not flat) to find out which memcg a particular cache
> >> belongs to, because <cgroup-kmem-id> is not known to the user. Since
> >> using absolute cgroup names would be an overkill, let's fix this by
> >> exporting the id of kmem-active memcg via cgroup fs file
> >> "memory.kmem.id".
> >>
> > Hmm, I'm not sure exporting additional information is the best way to do 
> > it only for this purpose.  I do understand the problem in naming 
> > collisions if the hierarchy isn't flat and we typically work around that 
> > by ensuring child memcgs still have a unique memcg.  This isn't only a 
> > problem in slab cache naming, me also avoid printing the entire absolute 
> > names for things like the oom killer.
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

I am really puzzled now. Why do you want to export the id/name then? If
the source memcg is not relevant? I would understand if you tried to
reduce your bug search place by the load which runs in the particular
memcg.

> > So it would be nice to have 
> > consensus on how people are supposed to identify memcgs with a hierarchy: 
> > either by exporting information like the id like you do here (but leave 
> > the oom killer still problematic) or by insisting people name their memcgs 
> > with unique names if they care to differentiate them.
> 
> Anyway, I agree with you that this needs a consensus, because this is a
> functional change.

I am for the full path same as we do when we dump oom information. This
is much easier to consume.

> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
