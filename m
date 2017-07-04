Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BAC946B0292
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 08:10:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 79so2809928wmg.4
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:10:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k35si13916266wrc.368.2017.07.04.05.10.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 05:10:50 -0700 (PDT)
Subject: Re: [patch V2 2/2] mm/memory-hotplug: Switch locking to a percpu
 rwsem
References: <20170704093232.995040438@linutronix.de>
 <20170704093421.506836322@linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cec30e21-c407-9ffa-c10b-0aa2ea64de2a@suse.cz>
Date: Tue, 4 Jul 2017 14:10:49 +0200
MIME-Version: 1.0
In-Reply-To: <20170704093421.506836322@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On 07/04/2017 11:32 AM, Thomas Gleixner wrote:
> Andrey reported a potential deadlock with the memory hotplug lock and the
> cpu hotplug lock.
> 
> The reason is that memory hotplug takes the memory hotplug lock and then
> calls stop_machine() which calls get_online_cpus(). That's the reverse lock
> order to get_online_cpus(); get_online_mems(); in mm/slub_common.c
> 
> The problem has been there forever. The reason why this was never reported
> is that the cpu hotplug locking had this homebrewn recursive reader writer
> semaphore construct which due to the recursion evaded the full lock dep
> coverage. The memory hotplug code copied that construct verbatim and
> therefor has similar issues.
> 
> Three steps to fix this:
> 
> 1) Convert the memory hotplug locking to a per cpu rwsem so the potential
>    issues get reported proper by lockdep.
> 
> 2) Lock the online cpus in mem_hotplug_begin() before taking the memory
>    hotplug rwsem and use stop_machine_cpuslocked() in the page_alloc code
>    and use to avoid recursive locking.

     ^ s/and use // ?

> 
> 3) The cpu hotpluck locking in #2 causes a recursive locking of the cpu
>    hotplug lock via __offline_pages() -> lru_add_drain_all(). Solve this by
>    invoking lru_add_drain_all_cpuslocked() instead.
> 
> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/memory_hotplug.c |   89 ++++++++--------------------------------------------
>  mm/page_alloc.c     |    2 -
>  2 files changed, 16 insertions(+), 75 deletions(-)

Nice! Glad to see the crazy code go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
