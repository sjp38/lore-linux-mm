Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 799B06B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 09:05:08 -0400 (EDT)
Date: Tue, 12 Mar 2013 14:05:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] device: separate all subsys mutexes (was: Re: [BUG]
 potential deadlock led by cpu_hotplug lock (memcg involved))
Message-ID: <20130312130504.GD30758@dhcp22.suse.cz>
References: <513ECCFE.3070201@huawei.com>
 <20130312101555.GB30758@dhcp22.suse.cz>
 <20130312110750.GC30758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130312110750.GC30758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

[CCing Greg and Kay]
On Tue 12-03-13 12:07:50, Michal Hocko wrote:
> [Let's CC Ingo and Peter]
> 
> On Tue 12-03-13 11:15:55, Michal Hocko wrote:
> > On Tue 12-03-13 14:36:46, Li Zefan wrote:
> > > Seems a new bug in 3.9 kernel?
> > > 
> > > 
> > > [  207.271924] ======================================================
> > > [  207.271932] [ INFO: possible circular locking dependency detected ]
> > > [  207.271942] 3.9.0-rc1-0.7-default+ #34 Not tainted
> > > [  207.271948] -------------------------------------------------------
> > 
> > 1) load_module -> subsys_interface_register -> mc_deveice_add (*) -> subsys->p->mutex -> link_path_walk -> lookup_slow -> i_mutex
> > 2) sys_write -> _cpu_down -> cpu_hotplug_begin -> cpu_hotplug.lock -> mce_cpu_callback -> mce_device_remove(**) -> device_unregister -> bus_remove_device -> subsys mutex
> > 3) vfs_readdir -> i_mutex -> filldir64 -> might_fault -> might_lock_read(mmap_sem) -> page_fault -> mmap_sem -> drain_all_stock -> cpu_hotplug.lock
> > 
> > 1) takes cpu_subsys subsys (*) but 2) takes mce_device subsys (**) so
> > the deadlock is not possible AFAICS.

Thanks to Jiri Kosina, who pointed out that the root cause is
bus_register which uses a static key and both mce and cpu subsys are
registered by subsys_system_register so they use the same key.  Maybe
something like the following (compile tested with both LOCKDEP on/off)
should work:
---
