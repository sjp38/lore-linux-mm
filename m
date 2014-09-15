Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2976B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 15:15:25 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id n3so4855348wiv.13
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 12:15:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l1si3674436wjb.113.2014.09.15.12.15.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 12:15:20 -0700 (PDT)
Date: Mon, 15 Sep 2014 15:14:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140915191435.GA8950@cmpxchg.org>
References: <20140904143055.GA20099@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140904143055.GA20099@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi Vladimir,

On Thu, Sep 04, 2014 at 06:30:55PM +0400, Vladimir Davydov wrote:
> To sum it up, the current mem + memsw configuration scheme doesn't allow
> us to limit swap usage if we want to partition the system dynamically
> using soft limits. Actually, it also looks rather confusing to me. We
> have mem limit and mem+swap limit. I bet that from the first glance, an
> average admin will think it's possible to limit swap usage by setting
> the limits so that the difference between memory.memsw.limit and
> memory.limit equals the maximal swap usage, but (surprise!) it isn't
> really so. It holds if there's no global memory pressure, but otherwise
> swap usage is only limited by memory.memsw.limit! IMHO, it isn't
> something obvious.

Agreed, memory+swap accounting & limiting is broken.

>  - Anon memory is handled by the user application, while file caches are
>    all on the kernel. That means the application will *definitely* die
>    w/o anon memory. W/o file caches it usually can survive, but the more
>    caches it has the better it feels.
> 
>  - Anon memory is not that easy to reclaim. Swap out is a really slow
>    process, because data are usually read/written w/o any specific
>    order. Dropping file caches is much easier. Typically we have lots of
>    clean pages there.
> 
>  - Swap space is limited. And today, it's OK to have TBs of RAM and only
>    several GBs of swap. Customers simply don't want to waste their disk
>    space on that.

> Finally, my understanding (may be crazy!) how the things should be
> configured. Just like now, there should be mem_cgroup->res accounting
> and limiting total user memory (cache+anon) usage for processes inside
> cgroups. This is where there's nothing to do. However, mem_cgroup->memsw
> should be reworked to account *only* memory that may be swapped out plus
> memory that has been swapped out (i.e. swap usage).

But anon pages are not a resource, they are a swap space liability.
Think of virtual memory vs. physical pages - the use of one does not
necessarily result in the use of the other.  Without memory pressure,
anonymous pages do not consume swap space.

What we *should* be accounting and limiting here is the actual finite
resource: swap space.  Whenever we try to swap a page, its owner
should be charged for the swap space - or the swapout be rejected.

For hard limit reclaim, the semantics of a swap space limit would be
fairly obvious, because it's clear who the offender is.

However, in an overcommitted machine, the amount of swap space used by
a particular group depends just as much on the behavior of the other
groups in the system, so the per-group swap limit should be enforced
even during global reclaim to feed back pressure on whoever is causing
the swapout.  If reclaim fails, the global OOM killer triggers, which
should then off the group with the biggest soft limit excess.

As far as implementation goes, it should be doable to try-charge from
add_to_swap() and keep the uncharging in swap_entry_free().

We'll also have to extend the global OOM killer to be memcg-aware, but
we've been meaning to do that anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
