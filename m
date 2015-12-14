Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCBA6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:43:14 -0500 (EST)
Received: by pfbo64 with SMTP id o64so31803390pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:43:13 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id d1si10268808pas.96.2015.12.14.11.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 11:43:13 -0800 (PST)
Date: Mon, 14 Dec 2015 22:42:58 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151214194258.GH28521@esperanza>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151214153037.GB4339@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 14, 2015 at 04:30:37PM +0100, Michal Hocko wrote:
> On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
> > In the legacy hierarchy we charge memsw, which is dubious, because:
> > 
> >  - memsw.limit must be >= memory.limit, so it is impossible to limit
> >    swap usage less than memory usage. Taking into account the fact that
> >    the primary limiting mechanism in the unified hierarchy is
> >    memory.high while memory.limit is either left unset or set to a very
> >    large value, moving memsw.limit knob to the unified hierarchy would
> >    effectively make it impossible to limit swap usage according to the
> >    user preference.
> > 
> >  - memsw.usage != memory.usage + swap.usage, because a page occupying
> >    both swap entry and a swap cache page is charged only once to memsw
> >    counter. As a result, it is possible to effectively eat up to
> >    memory.limit of memory pages *and* memsw.limit of swap entries, which
> >    looks unexpected.
> > 
> > That said, we should provide a different swap limiting mechanism for
> > cgroup2.
> > This patch adds mem_cgroup->swap counter, which charges the actual
> > number of swap entries used by a cgroup. It is only charged in the
> > unified hierarchy, while the legacy hierarchy memsw logic is left
> > intact.
> 
> I agree that the previous semantic was awkward. The problem I can see
> with this approach is that once the swap limit is reached the anon
> memory pressure might spill over to other and unrelated memcgs during
> the global memory pressure. I guess this is what Kame referred to as
> anon would become mlocked basically. This would be even more of an issue
> with resource delegation to sub-hierarchies because nobody will prevent
> setting the swap amount to a small value and use that as an anon memory
> protection.

AFAICS such anon memory protection has a side-effect: real-life
workloads need page cache to run smoothly (at least for mapping
executables). Disabling swapping would switch pressure to page caches,
resulting in performance degradation. So, I don't think per memcg swap
limit can be abused to boost your workload on an overcommitted system.

If you mean malicious users, well, they already have plenty ways to eat
all available memory up to the hard limit by creating unreclaimable
kernel objects.

Anyway, if you don't trust a container you'd better set the hard memory
limit so that it can't hurt others no matter what it runs and how it
tweaks its sub-tree knobs.

...
> My question now is. Is the knob usable/useful even without additional
> heuristics? Do we want to protect swap space so rigidly that a swap
> limited memcg can cause bigger problems than without the swap limit
> globally?

Hmm, I don't see why problems might get bigger with per memcg swap limit
than w/o it. W/o swap limit, a memcg can eat all swap space on the host
and disable swapping for everyone, not just for itself alone.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
