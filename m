Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DDC8E6B0256
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 13:28:50 -0500 (EST)
Received: by pasz6 with SMTP id z6so212864158pas.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:28:50 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ms6si23853554pbb.247.2015.11.09.10.28.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:28:50 -0800 (PST)
Date: Mon, 9 Nov 2015 21:28:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109182840.GJ31308@esperanza>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109140832.GE8916@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 09, 2015 at 03:08:32PM +0100, Michal Hocko wrote:
...
> > Therefore this patch switches to the white list policy. Now kmalloc
> > users have to explicitly opt in by passing __GFP_ACCOUNT flag.
> > 
> > Currently, the list of accounted objects is quite limited and only
> > includes those allocations that (1) are known to be easily triggered
> > from userspace and (2) can fail gracefully (for the full list see patch
> > no. 5) and it still misses many object types. However, accounting only
> > those objects should be a satisfactory approximation of the behavior we
> > used to have for most sane workloads.
> 
> I am _all_ for this semantic I am just not sure what to do with the
> legacy kmem controller. Can we change its semantic? If we cannot do that

I think we can. If somebody reports a "bug" caused by this change, i.e.
basically notices that something that used to be accounted is not any
longer, it will be trivial to fix by adding __GFP_ACCOUNT where
appropriate. If it is not, e.g. if accounting of objects of a particular
type leads to intense false-sharing, we would end up disabling
accounting for it anyway.

> we would have to distinguish legacy and unified hierarchies during
> runtime and add the flag automagically for the first one (that would
> however require to keep __GFP_NOACCOUNT as well) which is all as clear
> as mud. But maybe the workloads which are using kmem legacy API can cope
> with that.
> 
> Anyway if we go this way then I think the kmem accounting would be safe
> to be enabled by default with the cgroup2.
> 
> > Thanks,
> > 
> > Vladimir Davydov (5):
> >   Revert "kernfs: do not account ino_ida allocations to memcg"
> >   Revert "gfp: add __GFP_NOACCOUNT"
> 
> The patch ordering would break the bisectability. I would simply squash

How's that? AFAICS the kernel should compile after any first N=1..5
patches of the series applied.

> both places into the patch which replaces the flag.
> 

IMO it is more readable the way it is, but I don't insist.

Thanks,
Vladimir

> >   memcg: only account kmem allocations marked as __GFP_ACCOUNT
> >   vmalloc: allow to account vmalloc to memcg
> >   Account certain kmem allocations to memcg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
