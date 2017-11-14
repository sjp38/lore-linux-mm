Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8A926B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 09:13:35 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e8so4897115wmc.6
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 06:13:35 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o18si16532307wro.223.2017.11.14.06.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 06:13:33 -0800 (PST)
Date: Tue, 14 Nov 2017 15:13:27 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm: drop hotplug lock from lru_add_drain_all
In-Reply-To: <20171114135348.28704-1-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.20.1711141512180.2044@nanos>
References: <20171114135348.28704-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 14 Nov 2017, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Pulling cpu hotplug locks inside the mm core function like
> lru_add_drain_all just asks for problems and the recent lockdep splat
> [1] just proves this. While the usage in that particular case might
> be wrong we should prevent from locking as lru_add_drain_all is used
> at many places. It seems that this is not all that hard to achieve
> actually.
> 
> We have done the same thing for drain_all_pages which is analogous by
> a459eeb7b852 ("mm, page_alloc: do not depend on cpu hotplug locks inside
> the allocator"). All we have to care about is to handle
>       - the work item might be executed on a different cpu in worker from
>         unbound pool so it doesn't run on pinned on the cpu
> 
>       - we have to make sure that we do not race with page_alloc_cpu_dead
>         calling lru_add_drain_cpu
> 
> the first part is already handled because the worker calls lru_add_drain
> which disables preemption when calling lru_add_drain_cpu on the local
> cpu it is draining. The later is true because page_alloc_cpu_dead
> is called on the controlling CPU after the hotplugged CPU vanished
> completely.
> 
> [1] http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> this has been posted as 2 patch series [1] previously. It turned out
> that the first patch was simply broken and the second one could be
> simplified because the irq disabling is just pointless. There were
> no other objections so I am resending this patch which should remove
> quite a large space of potential lockups as lru_add_drain_all is used
> at many places so removing the hoptlug locking is a good thing in
> general.
> 
> Can we have this merged or there are still some objections?

No objections. The explanation makes sense, but it might be worth to have a
comment at lru_add_drain_all() which explains the protection rules.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
