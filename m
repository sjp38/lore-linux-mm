Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D19E36B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 11:01:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 77so45718491wrb.11
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 08:01:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v81si13967608wmd.107.2017.07.04.08.01.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 08:01:18 -0700 (PDT)
Date: Tue, 4 Jul 2017 08:01:06 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [patch V2 2/2] mm/memory-hotplug: Switch locking to a percpu
 rwsem
Message-ID: <20170704150106.GA11168@linux-80c1.suse>
References: <20170704093232.995040438@linutronix.de>
 <20170704093421.506836322@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170704093421.506836322@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 04 Jul 2017, Thomas Gleixner wrote:

>Andrey reported a potential deadlock with the memory hotplug lock and the
>cpu hotplug lock.
>
>The reason is that memory hotplug takes the memory hotplug lock and then
>calls stop_machine() which calls get_online_cpus(). That's the reverse lock
>order to get_online_cpus(); get_online_mems(); in mm/slub_common.c
>
>The problem has been there forever. The reason why this was never reported
>is that the cpu hotplug locking had this homebrewn recursive reader writer
>semaphore construct which due to the recursion evaded the full lock dep
>coverage. The memory hotplug code copied that construct verbatim and
>therefor has similar issues.
>
>Three steps to fix this:
>
>1) Convert the memory hotplug locking to a per cpu rwsem so the potential
>   issues get reported proper by lockdep.

I particularly like how the mem hotplug is well suited for pcpu-rwsem.
As a side effect you end up optimizing get/put_online_mems() at the cost
of more overhead for the actual hotplug operation, which is rare and of less
performance importance.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
