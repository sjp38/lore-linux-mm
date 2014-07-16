Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id BD4ED6B0073
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 08:01:53 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so6072620wiv.5
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 05:01:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mu3si20207167wic.38.2014.07.16.05.01.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 05:01:51 -0700 (PDT)
Date: Wed, 16 Jul 2014 14:01:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Message-ID: <20140716120146.GI7121@dhcp22.suse.cz>
References: <cover.1404383187.git.vdavydov@parallels.com>
 <20140704121621.GE12466@dhcp22.suse.cz>
 <20140704153853.GA369@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140704153853.GA369@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

On Fri 04-07-14 19:38:53, Vladimir Davydov wrote:
> Hi Michal,
> 
> On Fri, Jul 04, 2014 at 02:16:21PM +0200, Michal Hocko wrote:
[...]
> > Once I get from internal things (which will happen soon hopefully) I
> > will post a series with a new sets of memcg limits. One of them is
> > high_limit which can be used as a trigger for memcg reclaim. Unlike
> > hard_limit there won't be any OOM if the reclaim fails at this stage. So
> > if the high_limit is configured properly the admin will have enough time
> > to make additional steps before OOM happens.
> 
> High/low limits that start reclaim on internal/external pressure are
> definitely a very nice feature (may be even more useful that strict
> limits). However, they won't help us against overcommit inside a
> container. AFAIC,
> 
>  - low limit will allow the container to consume as much as he wants
>    until it triggers global memory pressure, then it will be shrunk back
>    to its limit aggressively;

No, this is not like soft_limit. Any external pressure (e.g. coming from
some of the parents) will exclude memcgs which are below its low_limit.
If there is no way to proceed because all groups in the currently
reclaimed hierarchy are below its low limit then it will ignore the low
limit. So this is an optimistic working set protection.

>  - high limit means allow to breach the limit, but trigger reclaim
>    asynchronously (a kind of kswapd) or synchronously when it happens.

No, we will start with the direct reclaim as we do for the hard limit.
The only change wrt. hard limit is that we do not trigger OOM if the
reclaim fails.

> Right?
> 
> Considering the example I've given above, both of these won't help if
> the system has other active CTs: the container will be forcefully kept
> around its high/low limit and, since it's definitely not enough for it,
> it will be finally killed crossing out the computations it's spent so
> much time on. High limit won't be good for the container even if there's
> no other load on the node - it will be constantly swapping out anon
> memory and evicting file caches. The application won't die quickly then,
> but it will get a heavy slowdown, which is no better than killing I
> guess.

It will get vmpressure notifications though and can help to release
excessive buffers which were allocated optimistically.

> Also, I guess it'd be beneficial to have
> 
>  - mlocked pages accounting per cgroup, because they affect memory
>    reclaim, and how low/high limits work, so it'd be nice to have them
>    limited to a sane value;
> 
>  - shmem areas accounting per cgroup, because the total amount of shmem
>    on the system is limited, and it'll be no good if malicious
>    containers eat it all.
> 
> IMO It wouldn't be a good idea to overwhelm memcg with those limits, the
> VM controller suits much better.

yeah, I do not think adding more to memcg is a good idea. I am still not
sure whether working around bad design decisions in applications is a
good rationale for a new controller.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
