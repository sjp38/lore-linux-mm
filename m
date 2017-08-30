Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8EE76B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 10:15:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m85so2486064wma.8
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 07:15:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si4313667wrk.547.2017.08.30.07.15.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 07:15:46 -0700 (PDT)
Date: Wed, 30 Aug 2017 16:15:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
Message-ID: <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
 <alpine.DEB.2.20.1708161605050.1987@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1708161605050.1987@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Artem Savkov <asavkov@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Wed 16-08-17 16:07:21, Thomas Gleixner wrote:
> On Mon, 7 Aug 2017, Artem Savkov wrote:
> 
> +Cc mm folks ...

Ups, this has fallen through cracks

> > Hello,
> > 
> > After commit fc8dffd "cpu/hotplug: Convert hotplug locking to percpu rwsem"
> > the following lockdep splat started showing up on some systems while running
> > ltp's madvise06 test (right after first dirty_pages call [1]).
> >
> > [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise06.c#L136
> > 
> > [21002.630252] ======================================================
> > [21002.637148] WARNING: possible circular locking dependency detected
> > [21002.644045] 4.13.0-rc3-next-20170807 #12 Not tainted
> > [21002.649583] ------------------------------------------------------
> > [21002.656492] a.out/4771 is trying to acquire lock:
> > [21002.661742]  (cpu_hotplug_lock.rw_sem){++++++}, at: [<ffffffff812b4668>] drain_all_stock.part.35+0x18/0x140
> > [21002.672629] 
> > [21002.672629] but task is already holding lock:
> > [21002.679137]  (&mm->mmap_sem){++++++}, at: [<ffffffff8106eb35>] __do_page_fault+0x175/0x530
[...]
> > [21002.993812] other info that might help us debug this:
> > [21002.993812] 
> > [21003.002744] Chain exists of:
> > [21003.002744]   cpu_hotplug_lock.rw_sem --> &type->i_mutex_dir_key#3 --> &mm->mmap_sem
> > [21003.002744] 
> > [21003.016238]  Possible unsafe locking scenario:
> > [21003.016238] 
> > [21003.022843]        CPU0                    CPU1
> > [21003.027896]        ----                    ----
> > [21003.032948]   lock(&mm->mmap_sem);
> > [21003.036741]                                lock(&type->i_mutex_dir_key#3);
> > [21003.044419]                                lock(&mm->mmap_sem);
> > [21003.051025]   lock(cpu_hotplug_lock.rw_sem);

OK, this smells like the same thing we had to address for
drain_all_pages by a459eeb7b852 ("mm, page_alloc: do not depend on cpu
hotplug locks inside the allocator"). try_charge might be deep in the
call path so taking cpu_hotplug_lock just calls for troubles.

I have of course forgot all the subtle details about drain_all_pages but
re-reading the changelog it seems that we can get along with droping
{get,put}_online_cpus in because drain_local_stock (which is called from
the WQ context as well) is disabling irqs and _always_ operates on the
local cpu stock. So we cannot possibly race with the memory hotplug
AFAICS.

So what do you think about the following patch?
---
