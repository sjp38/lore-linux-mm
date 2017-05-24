Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 369316B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 16:43:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h76so161405375pfh.15
        for <linux-mm@kvack.org>; Wed, 24 May 2017 13:43:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s80sor1698831pfk.19.2017.05.24.13.43.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 May 2017 13:43:30 -0700 (PDT)
Date: Wed, 24 May 2017 13:43:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/oom_kill: count global and memory cgroup oom kills
In-Reply-To: <0f67046d-cdf6-1264-26f6-11c82978c621@yandex-team.ru>
Message-ID: <alpine.DEB.2.10.1705241338120.49680@chino.kir.corp.google.com>
References: <149520375057.74196.2843113275800730971.stgit@buzz> <CALo0P1123MROxgveCdX6YFpWDwG4qrAyHu3Xd1F+ckaFBnF4dQ@mail.gmail.com> <ecd4a7ea-06c0-f549-a1bf-6d2d3c0af719@yandex-team.ru> <alpine.DEB.2.10.1705230044590.50796@chino.kir.corp.google.com>
 <0f67046d-cdf6-1264-26f6-11c82978c621@yandex-team.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Roman Guschin <guroan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org

On Tue, 23 May 2017, Konstantin Khlebnikov wrote:

> This is worth addition. Let's call it "oom_victim" for short.
> 
> It allows to locate leaky part if they are spread over sub-containers within
> common limit.
> But doesn't tell which limit caused this kill. For hierarchical limits this
> might be not so easy.
> 
> I think oom_kill better suits for automatic actions - restart affected
> hierarchy, increase limits, e.t.c.
> But oom_victim allows to determine container affected by global oom killer.
> 
> So, probably it's worth to merge them together and increment oom_kill by
> global killer for victim memcg:
> 
> 	if (!is_memcg_oom(oc)) {
> 		count_vm_event(OOM_KILL);
> 		mem_cgroup_count_vm_event(mm, OOM_KILL);
> 	} else
> 		mem_cgroup_event(oc->memcg, OOM_KILL);
> 

Our complete solution is that we have a complementary 
memory.oom_kill_control that allows users to register for eventfd(2) 
notification when the kernel oom killer kills a victim, but this is 
because we have had complete support for userspace oom handling for years.  
When read, it exports three classes of information:

 - the "total" (hierarchical) and "local" (memcg specific) number of oom
   kills for system oom conditions (overcommit),

 - the "total" and "local" number of oom kills for memcg oom conditions, 
   and
 
 - the total number of processes in the hierarchy where an oom victim was
   reaped successfully and unsuccessfully.

One benefit of this is that it prevents us from having to scrape the 
kernel log for oom events which has been troublesome in the past, but 
userspace can easily do so when the eventfd triggers for the kill 
notification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
