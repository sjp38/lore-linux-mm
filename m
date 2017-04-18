Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0036B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 16:19:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 6so375435wra.23
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 13:19:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si272274wrc.80.2017.04.18.13.19.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 13:19:22 -0700 (PDT)
Date: Tue, 18 Apr 2017 22:19:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: "mm: move pcp and lru-pcp draining into single wq" broke resume
 from s2ram
Message-ID: <20170418201907.GC20671@dhcp22.suse.cz>
References: <CAMuHMdUJSfrZ=2zy88_zojDek3CHEWKhv_qoJAVgDpPWz8V=Ew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdUJSfrZ=2zy88_zojDek3CHEWKhv_qoJAVgDpPWz8V=Ew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue 18-04-17 21:56:56, Geert Uytterhoeven wrote:
> Hi all,
> 
> On Sat, Apr 8, 2017 at 10:48 AM, Linux Kernel Mailing List
> <linux-kernel@vger.kernel.org> wrote:
> > Web:        https://git.kernel.org/torvalds/c/ce612879ddc78ea7e4de4be80cba4ebf9caa07ee
> > Commit:     ce612879ddc78ea7e4de4be80cba4ebf9caa07ee
> > Parent:     cdcf4330d5660998d06fcd899b443693ab3d652f
> > Refname:    refs/heads/master
> > Author:     Michal Hocko <mhocko@suse.com>
> > AuthorDate: Fri Apr 7 16:05:05 2017 -0700
> > Committer:  Linus Torvalds <torvalds@linux-foundation.org>
> > CommitDate: Sat Apr 8 00:47:49 2017 -0700
> >
> >     mm: move pcp and lru-pcp draining into single wq
> >
> >     We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
> >     vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
> >     per cpu lru caches.  This seems more than necessary because both can run
> >     on a single WQ.  Both do not block on locks requiring a memory
> >     allocation nor perform any allocations themselves.  We will save one
> >     rescuer thread this way.
> >
> >     On the other hand drain_all_pages() queues work on the system wq which
> >     doesn't have rescuer and so this depend on memory allocation (when all
> >     workers are stuck allocating and new ones cannot be created).
> >
> >     Initially we thought this would be more of a theoretical problem but
> >     Hugh Dickins has reported:
> >
> >     : 4.11-rc has been giving me hangs after hours of swapping load.  At
> >     : first they looked like memory leaks ("fork: Cannot allocate memory");
> >     : but for no good reason I happened to do "cat /proc/sys/vm/stat_refresh"
> >     : before looking at /proc/meminfo one time, and the stat_refresh stuck
> >     : in D state, waiting for completion of flush_work like many kworkers.
> >     : kthreadd waiting for completion of flush_work in drain_all_pages().
> >
> >     This worker should be using WQ_RECLAIM as well in order to guarantee a
> >     forward progress.  We can reuse the same one as for lru draining and
> >     vmstat.
> >
> >     Link: http://lkml.kernel.org/r/20170307131751.24936-1-mhocko@kernel.org
> >     Signed-off-by: Michal Hocko <mhocko@suse.com>
> >     Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >     Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >     Acked-by: Mel Gorman <mgorman@suse.de>
> >     Tested-by: Yang Li <pku.leo@gmail.com>
> >     Tested-by: Hugh Dickins <hughd@google.com>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> This commit broke resume from s2ram on some of my Renesas ARM boards.
> On some boards the hang is 100% reproducible, on others it's intermittent
> (which was a PITA, as I had to bisect another independent s2ram bug as well).

Hmm, I am rather confused, how the above commit could change anything
here. Your lockup detector is hitting
dpm_wait_for_superior
        dpm_wait(dev->parent, async);
	dpm_wait_for_suppliers(dev, async);

which in turn waits wait_for_completion(&dev->power.completion)

the above commit has reduced the load on the system WQ. It also removed
one WQ and reused the existing one. The work done on the mm_percpu_wq
doesn't block so I suspect that what you are seeing is just showing a
real bug somewhere else. I will have a look tomorrow. Let's add Tejun,
maybe I have introduced some subtle dependency, which is not clear to
me.

> 
> On r8a7791/koelsch:
> 
> --- /tmp/good   2017-04-18 21:47:04.457156167 +0200
> +++ /tmp/bad    2017-04-18 21:43:26.215240325 +0200
> @@ -13,11 +13,178 @@ Enabling non-boot CPUs ...
>  CPU1 is up
>  PM: noirq resume of devices complete after N.N msecs
>  PM: early resume of devices complete after N.N msecs
> -Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver
> [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01,
> irq=-1)
> -PM: resume of devices complete after N.N msecs
> -PM: resume devices took N.N seconds
> -PM: Finishing wakeup.
> -Restarting tasks ... done.
> -ata1: link resume succeeded after 1 retries
> -ata1: SATA link down (SStatus 0 SControl 300)
> -sh-eth ee700000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
> +INFO: task kworker/u4:0:5 blocked for more than 120 seconds.
> +      Not tainted 4.11.0-rc7-koelsch-00426-g70412b99f7936b37 #3470
> +"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> +kworker/u4:0    D    0     5      2 0x00000000
> +Workqueue: events_unbound async_run_entry_fn
> +[<c0712c58>] (__schedule) from [<c0712f7c>] (schedule+0xb0/0xcc)
> +[<c0712f7c>] (schedule) from [<c0717140>] (schedule_timeout+0x18/0x1f4)
> +[<c0717140>] (schedule_timeout) from [<c07139f8>] (wait_for_common+0x100/0x19c)
> +[<c07139f8>] (wait_for_common) from [<c04d8488>]
> (dpm_wait_for_superior+0x14/0x5c)
> +[<c04d8488>] (dpm_wait_for_superior) from [<c04d8aa4>]
> (device_resume+0x40/0x1a0)
> +[<c04d8aa4>] (device_resume) from [<c04d8c1c>] (async_resume+0x18/0x44)
> +[<c04d8c1c>] (async_resume) from [<c023db34>] (async_run_entry_fn+0x44/0x114)
> +[<c023db34>] (async_run_entry_fn) from [<c0236544>]
> (process_one_work+0x1cc/0x31c)
> +[<c0236544>] (process_one_work) from [<c0236ca0>] (worker_thread+0x2b8/0x3f0)
> +[<c0236ca0>] (worker_thread) from [<c023b240>] (kthread+0x120/0x140)
> +[<c023b240>] (kthread) from [<c0206d68>] (ret_from_fork+0x14/0x2c)
> +INFO: task kworker/u4:1:125 blocked for more than 120 seconds.
> +      Not tainted 4.11.0-rc7-koelsch-00426-g70412b99f7936b37 #3470
> +"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> +kworker/u4:1    D    0   125      2 0x00000000
> +Workqueue: events_unbound async_run_entry_fn
> +[<c0712c58>] (__schedule) from [<c0712f7c>] (schedule+0xb0/0xcc)
> +[<c0712f7c>] (schedule) from [<c0717140>] (schedule_timeout+0x18/0x1f4)
> +[<c0717140>] (schedule_timeout) from [<c07139f8>] (wait_for_common+0x100/0x19c)
> +[<c07139f8>] (wait_for_common) from [<c04d8488>]
> (dpm_wait_for_superior+0x14/0x5c)
> +[<c04d8488>] (dpm_wait_for_superior) from [<c04d8aa4>]
> (device_resume+0x40/0x1a0)
> +[<c04d8aa4>] (device_resume) from [<c04d8c1c>] (async_resume+0x18/0x44)
> +[<c04d8c1c>] (async_resume) from [<c023db34>] (async_run_entry_fn+0x44/0x114)
> +[<c023db34>] (async_run_entry_fn) from [<c0236544>]
> (process_one_work+0x1cc/0x31c)
> +[<c0236544>] (process_one_work) from [<c0236ca0>] (worker_thread+0x2b8/0x3f0)
> +[<c0236ca0>] (worker_thread) from [<c023b240>] (kthread+0x120/0x140)
> +[<c023b240>] (kthread) from [<c0206d68>] (ret_from_fork+0x14/0x2c)
> ...
> 
> On r8a7795/salvator-x, where I have working lockdep:
> 
> PM: noirq resume of devices complete after 131.415 msecs
> PM: early resume of devices complete after 8.894 msecs
> INFO: task kworker/u16:2:276 blocked for more than 120 seconds.
>       Not tainted 4.11.0-rc7-salvator-x-06706-g70412b99f7936b37 #1220
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> kworker/u16:2   D    0   276      2 0x00000000
> Workqueue: events_unbound async_run_entry_fn
> Call trace:
> [<ffffff800808612c>] __switch_to+0xa0/0xac
> [<ffffff800866df14>] __schedule+0x70c/0xb88
> [<ffffff800866e414>] schedule+0x84/0xa4
> [<ffffff800867287c>] schedule_timeout+0x30/0x400
> [<ffffff800866ee94>] wait_for_common+0x164/0x1a8
> [<ffffff800866eeec>] wait_for_completion+0x14/0x1c
> [<ffffff80083d3f84>] dpm_wait+0x30/0x38
> [<ffffff80083d3ff8>] dpm_wait_for_superior+0x28/0x7c
> [<ffffff80083d490c>] device_resume+0x44/0x190
> [<ffffff80083d4a7c>] async_resume+0x24/0x54
> [<ffffff80080d5360>] async_run_entry_fn+0x4c/0x12c
> [<ffffff80080cb59c>] process_one_work+0x340/0x66c
> [<ffffff80080cc9ec>] worker_thread+0x274/0x39c
> [<ffffff80080d2004>] kthread+0x120/0x128
> [<ffffff8008083090>] ret_from_fork+0x10/0x40
> 
> Showing all locks held in the system:
> 2 locks held by khungtaskd/52:
>  #0:  (rcu_read_lock){......}, at: [<ffffff80081436cc>] watchdog+0xc0/0x618
>  #1:  (tasklist_lock){.+.+..}, at: [<ffffff80080fb5f0>]
> debug_show_all_locks+0x68/0x18c
> 2 locks held by kworker/u16:2/276:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:3/291:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 8 locks held by s2ram/1899:
>  #0:  (sb_writers#7){.+.+.+}, at: [<ffffff80081ca1a4>] vfs_write+0xa8/0x15c
>  #1:  (&of->mutex){+.+.+.}, at: [<ffffff8008245964>] kernfs_fop_write+0xf0/0x194
>  #2:  (s_active#48){.+.+.+}, at: [<ffffff800824596c>]
> kernfs_fop_write+0xf8/0x194
>  #3:  (pm_mutex){+.+.+.}, at: [<ffffff80081059a4>] pm_suspend+0x16c/0xabc
>  #4:  (&dev->mutex){......}, at: [<ffffff80083d4920>] device_resume+0x58/0x190
>  #5:  (cma_mutex){+.+...}, at: [<ffffff80081c516c>] cma_alloc+0x150/0x374
>  #6:  (lock){+.+...}, at: [<ffffff800818b8ec>] lru_add_drain_all+0x4c/0x1b4
>  #7:  (cpu_hotplug.dep_map){++++++}, at: [<ffffff80080ab8f4>]
> get_online_cpus+0x3c/0x9c
> 2 locks held by kworker/u16:1/1918:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:4/1919:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:5/1920:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:7/1922:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:9/1924:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:10/1925:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:11/1926:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:12/1927:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:13/1928:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:14/1929:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 2 locks held by kworker/u16:16/1931:
>  #0:  ("events_unbound"){.+.+.+}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
>  #1:  ((&entry->work)){+.+...}, at: [<ffffff80080cb424>]
> process_one_work+0x1c8/0x66c
> 
> Thanks for your comments!
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
