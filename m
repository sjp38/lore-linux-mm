Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4C196B02C3
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 08:49:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 62so23847121wmw.13
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:49:00 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o78si14605767wrb.89.2017.07.04.05.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 05:48:59 -0700 (PDT)
Date: Tue, 4 Jul 2017 14:48:56 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 1/2] mm: swap: Provide
 lru_add_drain_all_cpuslocked()
In-Reply-To: <20170704105803.GK14722@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1707041445350.9000@nanos>
References: <20170704093232.995040438@linutronix.de> <20170704093421.419329357@linutronix.de> <20170704105803.GK14722@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 4 Jul 2017, Michal Hocko wrote:
> On Tue 04-07-17 11:32:33, Thomas Gleixner wrote:
> > The rework of the cpu hotplug locking unearthed potential deadlocks with
> > the memory hotplug locking code.
> > 
> > The solution for these is to rework the memory hotplug locking code as well
> > and take the cpu hotplug lock before the memory hotplug lock in
> > mem_hotplug_begin(), but this will cause a recursive locking of the cpu
> > hotplug lock when the memory hotplug code calls lru_add_drain_all().
> > 
> > Split out the inner workings of lru_add_drain_all() into
> > lru_add_drain_all_cpuslocked() so this function can be invoked from the
> > memory hotplug code with the cpu hotplug lock held.
> 
> You have added callers in the later patch in the series AFAICS which
> is OK but I think it would be better to have them in this patch
> already. Nothing earth shattering (maybe a rebase artifact).

The requirement for changing that comes with the extra hotplug locking in
mem_hotplug_begin(). That is required to establish the proper lock order
and then causes the recursive locking in the next patch. Adding the caller
here would be wrong, because then lru_add_drain_all_cpuslocked() would be
called unprotected. Hens and eggs as usual :)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
