Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DED246B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 09:09:06 -0500 (EST)
Received: by wmdw130 with SMTP id w130so30990960wmd.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 06:09:06 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id pd8si18281691wjb.183.2015.11.09.06.09.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 06:09:04 -0800 (PST)
Received: by wmnn186 with SMTP id n186so105680705wmn.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 06:09:04 -0800 (PST)
Date: Mon, 9 Nov 2015 15:08:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109140832.GE8916@dhcp22.suse.cz>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1446924358.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat 07-11-15 23:07:04, Vladimir Davydov wrote:
> Hi,
> 
> Currently, all kmem allocations (namely every kmem_cache_alloc, kmalloc,
> alloc_kmem_pages call) are accounted to memory cgroup automatically.
> Callers have to explicitly opt out if they don't want/need accounting
> for some reason. Such a design decision leads to several problems:
> 
>  - kmalloc users are highly sensitive to failures, many of them
>    implicitly rely on the fact that kmalloc never fails, while memcg
>    makes failures quite plausible.
> 
>  - A lot of objects are shared among different containers by design.
>    Accounting such objects to one of containers is just unfair.
>    Moreover, it might lead to pinning a dead memcg along with its kmem
>    caches, which aren't tiny, which might result in noticeable increase
>    in memory consumption for no apparent reason in the long run.
> 
>  - There are tons of short-lived objects. Accounting them to memcg will
>    only result in slight noise and won't change the overall picture, but
>    we still have to pay accounting overhead.

Yes, I think we should have gone that path since the very beginning.
Glauber even started with opt-in IIRC (caches were supposed to register
to be accounted). I do not remember what's led to the opt-out switch -
but I guess it has something to do with the user API how to select which
caches to track and also the original version from Google by Suleiman
Souhlal did the opt-out from the very beginning. Also kmem extension was
assumed to be used for "special" workloads.

> For more info, see
> 
>  - https://lkml.org/lkml/2015/11/5/365
>  - https://lkml.org/lkml/2015/11/6/122

Using lkml.org links tend to be quite painful because they quite often
do not work. http://lkml.kernel.org/r/$msg_id tends to work much better
IMO

http://lkml.kernel.org/r/20151105144002.GB15111%40dhcp22.suse.cz
http://lkml.kernel.org/r/20151106090555.GK29259@esperanza

> Therefore this patch switches to the white list policy. Now kmalloc
> users have to explicitly opt in by passing __GFP_ACCOUNT flag.
> 
> Currently, the list of accounted objects is quite limited and only
> includes those allocations that (1) are known to be easily triggered
> from userspace and (2) can fail gracefully (for the full list see patch
> no. 5) and it still misses many object types. However, accounting only
> those objects should be a satisfactory approximation of the behavior we
> used to have for most sane workloads.

I am _all_ for this semantic I am just not sure what to do with the
legacy kmem controller. Can we change its semantic? If we cannot do that
we would have to distinguish legacy and unified hierarchies during
runtime and add the flag automagically for the first one (that would
however require to keep __GFP_NOACCOUNT as well) which is all as clear
as mud. But maybe the workloads which are using kmem legacy API can cope
with that.

Anyway if we go this way then I think the kmem accounting would be safe
to be enabled by default with the cgroup2.

> Thanks,
> 
> Vladimir Davydov (5):
>   Revert "kernfs: do not account ino_ida allocations to memcg"
>   Revert "gfp: add __GFP_NOACCOUNT"

The patch ordering would break the bisectability. I would simply squash
both places into the patch which replaces the flag.

>   memcg: only account kmem allocations marked as __GFP_ACCOUNT
>   vmalloc: allow to account vmalloc to memcg
>   Account certain kmem allocations to memcg

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
