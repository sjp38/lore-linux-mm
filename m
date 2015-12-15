Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id EAA906B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 03:30:24 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so1082168pfn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 00:30:24 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ls11si410028pab.92.2015.12.15.00.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 00:30:24 -0800 (PST)
Date: Tue, 15 Dec 2015 11:30:07 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151215083007.GI28521@esperanza>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
 <566F8528.9060205@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <566F8528.9060205@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 15, 2015 at 12:12:40PM +0900, Kamezawa Hiroyuki wrote:
> On 2015/12/15 0:30, Michal Hocko wrote:
> >On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
> >>In the legacy hierarchy we charge memsw, which is dubious, because:
> >>
> >>  - memsw.limit must be >= memory.limit, so it is impossible to limit
> >>    swap usage less than memory usage. Taking into account the fact that
> >>    the primary limiting mechanism in the unified hierarchy is
> >>    memory.high while memory.limit is either left unset or set to a very
> >>    large value, moving memsw.limit knob to the unified hierarchy would
> >>    effectively make it impossible to limit swap usage according to the
> >>    user preference.
> >>
> >>  - memsw.usage != memory.usage + swap.usage, because a page occupying
> >>    both swap entry and a swap cache page is charged only once to memsw
> >>    counter. As a result, it is possible to effectively eat up to
> >>    memory.limit of memory pages *and* memsw.limit of swap entries, which
> >>    looks unexpected.
> >>
> >>That said, we should provide a different swap limiting mechanism for
> >>cgroup2.
> >>This patch adds mem_cgroup->swap counter, which charges the actual
> >>number of swap entries used by a cgroup. It is only charged in the
> >>unified hierarchy, while the legacy hierarchy memsw logic is left
> >>intact.
> >
> >I agree that the previous semantic was awkward. The problem I can see
> >with this approach is that once the swap limit is reached the anon
> >memory pressure might spill over to other and unrelated memcgs during
> >the global memory pressure. I guess this is what Kame referred to as
> >anon would become mlocked basically. This would be even more of an issue
> >with resource delegation to sub-hierarchies because nobody will prevent
> >setting the swap amount to a small value and use that as an anon memory
> >protection.
> >
> >I guess this was the reason why this approach hasn't been chosen before
> 
> Yes. At that age, "never break global VM" was the policy. And "mlock" can be
> used for attacking system.

If we are talking about "attacking system" from inside a container,
there are much easier and disruptive ways, e.g. running a fork-bomb or
creating pipes - such memory can't be reclaimed and global OOM killer
won't help.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
