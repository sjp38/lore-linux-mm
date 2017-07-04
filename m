Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1FD86B0311
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 08:52:29 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z1so45410468wrz.10
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:52:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si19392997wmg.100.2017.07.04.05.52.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 05:52:28 -0700 (PDT)
Date: Tue, 4 Jul 2017 14:52:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch V2 1/2] mm: swap: Provide lru_add_drain_all_cpuslocked()
Message-ID: <20170704125226.GP14722@dhcp22.suse.cz>
References: <20170704093232.995040438@linutronix.de>
 <20170704093421.419329357@linutronix.de>
 <20170704105803.GK14722@dhcp22.suse.cz>
 <alpine.DEB.2.20.1707041445350.9000@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1707041445350.9000@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue 04-07-17 14:48:56, Thomas Gleixner wrote:
> On Tue, 4 Jul 2017, Michal Hocko wrote:
> > On Tue 04-07-17 11:32:33, Thomas Gleixner wrote:
> > > The rework of the cpu hotplug locking unearthed potential deadlocks with
> > > the memory hotplug locking code.
> > > 
> > > The solution for these is to rework the memory hotplug locking code as well
> > > and take the cpu hotplug lock before the memory hotplug lock in
> > > mem_hotplug_begin(), but this will cause a recursive locking of the cpu
> > > hotplug lock when the memory hotplug code calls lru_add_drain_all().
> > > 
> > > Split out the inner workings of lru_add_drain_all() into
> > > lru_add_drain_all_cpuslocked() so this function can be invoked from the
> > > memory hotplug code with the cpu hotplug lock held.
> > 
> > You have added callers in the later patch in the series AFAICS which
> > is OK but I think it would be better to have them in this patch
> > already. Nothing earth shattering (maybe a rebase artifact).
> 
> The requirement for changing that comes with the extra hotplug locking in
> mem_hotplug_begin(). That is required to establish the proper lock order
> and then causes the recursive locking in the next patch. Adding the caller
> here would be wrong, because then lru_add_drain_all_cpuslocked() would be
> called unprotected. Hens and eggs as usual :)

Yeah, you are right. My bad I should have noticed that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
