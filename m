Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A3DBD6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 01:21:31 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so6518875pdj.3
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 22:21:31 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id fu1si19240785pbc.254.2014.02.02.22.21.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 02 Feb 2014 22:21:30 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id p10so6528565pdj.29
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 22:21:30 -0800 (PST)
Date: Sun, 2 Feb 2014 22:21:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/8] memcg: export kmemcg cache id via cgroup fs
In-Reply-To: <570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.02.1402022219101.10847@chino.kir.corp.google.com>
References: <cover.1391356789.git.vdavydov@parallels.com> <570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Sun, 2 Feb 2014, Vladimir Davydov wrote:

> Per-memcg kmem caches are named as follows:
> 
>   <global-cache-name>(<cgroup-kmem-id>:<cgroup-name>)
> 
> where <cgroup-kmem-id> is the unique id of the memcg the cache belongs
> to, <cgroup-name> is the relative name of the memcg on the cgroup fs.
> Cache names are exposed to userspace for debugging purposes (e.g. via
> sysfs in case of slub or via dmesg).
> 
> Using relative names makes it impossible in general (in case the cgroup
> hierarchy is not flat) to find out which memcg a particular cache
> belongs to, because <cgroup-kmem-id> is not known to the user. Since
> using absolute cgroup names would be an overkill, let's fix this by
> exporting the id of kmem-active memcg via cgroup fs file
> "memory.kmem.id".
> 

Hmm, I'm not sure exporting additional information is the best way to do 
it only for this purpose.  I do understand the problem in naming 
collisions if the hierarchy isn't flat and we typically work around that 
by ensuring child memcgs still have a unique memcg.  This isn't only a 
problem in slab cache naming, me also avoid printing the entire absolute 
names for things like the oom killer.  So it would be nice to have 
consensus on how people are supposed to identify memcgs with a hierarchy: 
either by exporting information like the id like you do here (but leave 
the oom killer still problematic) or by insisting people name their memcgs 
with unique names if they care to differentiate them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
