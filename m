Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBCD6B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 08:41:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b127so27137006lfb.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 05:41:17 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id i3si6145436ljb.104.2017.07.03.05.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 05:41:15 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id z78so2790656lff.2
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 05:41:15 -0700 (PDT)
Date: Mon, 3 Jul 2017 15:41:12 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
Message-ID: <20170703124112.oxaugs37sy2gxhtq@esperanza>
References: <alpine.DEB.2.20.1706291803380.1861@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1706291803380.1861@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jun 29, 2017 at 06:11:15PM +0200, Thomas Gleixner wrote:
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

The only reason I copied get_online_cpus() implementation instead of
using an rw semaphore was that I didn't want to deal with potential
deadlocks caused by calling get_online_mems() from the memory hotplug
code, like the one reported by Andrey below. However, these bugs should
be pretty easy to fix, as you clearly demonstrated in response to
Andrey's report. Apart from that, I don't see any problems with this
patch, and the code simplification does look compelling. FWIW,

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

> 
> Two steps to fix this:
> 
> 1) Convert the memory hotplug locking to a per cpu rwsem so the potential
>    issues get reported proper by lockdep.
> 
> 2) Lock the online cpus in mem_hotplug_begin() before taking the memory
>    hotplug rwsem and use stop_machine_cpuslocked() in the page_alloc code
>    to avoid recursive locking.
> 
> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
