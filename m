Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEE16B02F4
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 08:49:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r103so45385298wrb.0
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:49:50 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d67si13507608wmi.79.2017.07.04.05.49.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 05:49:49 -0700 (PDT)
Date: Tue, 4 Jul 2017 14:49:47 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 2/2] mm/memory-hotplug: Switch locking to a percpu
 rwsem
In-Reply-To: <cec30e21-c407-9ffa-c10b-0aa2ea64de2a@suse.cz>
Message-ID: <alpine.DEB.2.20.1707041449220.9000@nanos>
References: <20170704093232.995040438@linutronix.de> <20170704093421.506836322@linutronix.de> <cec30e21-c407-9ffa-c10b-0aa2ea64de2a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 4 Jul 2017, Vlastimil Babka wrote:

> On 07/04/2017 11:32 AM, Thomas Gleixner wrote:
> > Andrey reported a potential deadlock with the memory hotplug lock and the
> > cpu hotplug lock.
> > 
> > The reason is that memory hotplug takes the memory hotplug lock and then
> > calls stop_machine() which calls get_online_cpus(). That's the reverse lock
> > order to get_online_cpus(); get_online_mems(); in mm/slub_common.c
> > 
> > The problem has been there forever. The reason why this was never reported
> > is that the cpu hotplug locking had this homebrewn recursive reader writer
> > semaphore construct which due to the recursion evaded the full lock dep
> > coverage. The memory hotplug code copied that construct verbatim and
> > therefor has similar issues.
> > 
> > Three steps to fix this:
> > 
> > 1) Convert the memory hotplug locking to a per cpu rwsem so the potential
> >    issues get reported proper by lockdep.
> > 
> > 2) Lock the online cpus in mem_hotplug_begin() before taking the memory
> >    hotplug rwsem and use stop_machine_cpuslocked() in the page_alloc code
> >    and use to avoid recursive locking.
> 
>      ^ s/and use // ?

Ooops, yes.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
