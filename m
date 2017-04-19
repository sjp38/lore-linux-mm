Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 138612806DB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:45:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g31so1568820wrg.15
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:45:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b204si1184482wmc.11.2017.04.19.00.45.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 00:45:33 -0700 (PDT)
Date: Wed, 19 Apr 2017 09:45:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke
 resume from s2ram
Message-ID: <20170419074530.GA29789@dhcp22.suse.cz>
References: <CAMuHMdUJSfrZ=2zy88_zojDek3CHEWKhv_qoJAVgDpPWz8V=Ew@mail.gmail.com>
 <20170418201907.GC20671@dhcp22.suse.cz>
 <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
 <CAMuHMdVJ1ewJW4VFxeLEtOd8o_TtVZMSj0OYHdjRf4ykZYUFhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdVJ1ewJW4VFxeLEtOd8o_TtVZMSj0OYHdjRf4ykZYUFhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Wed 19-04-17 09:16:42, Geert Uytterhoeven wrote:
> Hi Tetsuo,
> 
> On Wed, Apr 19, 2017 at 7:41 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
[...]
> > Somebody is waiting forever with cpu_hotplug.lock held?
> > I think that full dmesg with SysRq-t output is appreciated.
> 
> As SysRq doesn't work with my serial console, I added calls to show_state()
> and show_workqueue_state() to check_hung_task().
> 
> Result with current linus/master attached.
[   47.165412] Enabling non-boot CPUs ...
[   47.205615] CPU1 is up
[   47.382002] PM: noirq resume of devices complete after 174.017 msecs
[   47.390181] PM: early resume of devices complete after 1.468 msecs

OK, so this is still the early resume path AFAIU which means that the
userspace is still in the fridge... Is it possible that new workers
cannot be spawned?

[  243.691979] INFO: task kworker/u4:0:5 blocked for more than 120 seconds.
[  243.698684]       Not tainted 4.11.0-rc7-koelsch-00029-g005882e53d62f25d-dirty #3476
[  243.706439] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  243.714276] kworker/u4:0    D    0     5      2 0x00000000
[  243.719780] Workqueue: events_unbound async_run_entry_fn
[  243.725118] [<c0700c20>] (__schedule) from [<c0700f44>] (schedule+0xb0/0xcc)
[  243.732181] [<c0700f44>] (schedule) from [<c0705108>] (schedule_timeout+0x18/0x1f4)
[  243.739840] [<c0705108>] (schedule_timeout) from [<c07019c0>] (wait_for_common+0x100/0x19c)
[  243.748207] [<c07019c0>] (wait_for_common) from [<c04d2008>] (dpm_wait_for_superior+0x14/0x5c)
[  243.756836] [<c04d2008>] (dpm_wait_for_superior) from [<c04d2624>] (device_resume+0x40/0x1a0)
[  243.765380] [<c04d2624>] (device_resume) from [<c04d279c>] (async_resume+0x18/0x44)
[  243.773055] [<c04d279c>] (async_resume) from [<c023db24>] (async_run_entry_fn+0x44/0x114)
[  243.781245] [<c023db24>] (async_run_entry_fn) from [<c0236534>] (process_one_work+0x1cc/0x31c)
[  243.789876] [<c0236534>] (process_one_work) from [<c0236c90>] (worker_thread+0x2b8/0x3f0)
[  243.798080] [<c0236c90>] (worker_thread) from [<c023b230>] (kthread+0x120/0x140)
[  243.805500] [<c023b230>] (kthread) from [<c0206d68>] (ret_from_fork+0x14/0x2c)
[...]
[  249.441198] bash            D    0  1703   1694 0x00000000
[  249.446702] [<c0700c20>] (__schedule) from [<c0700f44>] (schedule+0xb0/0xcc)
[  249.453764] [<c0700f44>] (schedule) from [<c0705108>] (schedule_timeout+0x18/0x1f4)
[  249.461427] [<c0705108>] (schedule_timeout) from [<c07019c0>] (wait_for_common+0x100/0x19c)
[  249.469797] [<c07019c0>] (wait_for_common) from [<c0234e44>] (flush_work+0x128/0x158)
[  249.477650] [<c0234e44>] (flush_work) from [<c02ab488>] (drain_all_pages+0x198/0x1f0)
[  249.485503] [<c02ab488>] (drain_all_pages) from [<c02e1a1c>] (start_isolate_page_range+0xd8/0x1ac)
[  249.494484] [<c02e1a1c>] (start_isolate_page_range) from [<c02ae464>] (alloc_contig_range+0xc4/0x304)
[  249.503724] [<c02ae464>] (alloc_contig_range) from [<c02e1e78>] (cma_alloc+0x134/0x1bc)
[  249.511739] [<c02e1e78>] (cma_alloc) from [<c021308c>] (__alloc_from_contiguous+0x30/0xa0)
[  249.520023] [<c021308c>] (__alloc_from_contiguous) from [<c021313c>] (cma_allocator_alloc+0x40/0x48)
[  249.529173] [<c021313c>] (cma_allocator_alloc) from [<c0213318>] (__dma_alloc+0x1d4/0x2e8)
[  249.537455] [<c0213318>] (__dma_alloc) from [<c02134a8>] (arm_dma_alloc+0x40/0x4c)
[  249.545047] [<c02134a8>] (arm_dma_alloc) from [<c0534548>] (sh_eth_ring_init+0xec/0x1b8)
[  249.553160] [<c0534548>] (sh_eth_ring_init) from [<c0536df0>] (sh_eth_open+0x88/0x1e0)
[  249.561086] [<c0536df0>] (sh_eth_open) from [<c0536fc4>] (sh_eth_resume+0x7c/0xc0)
[  249.568678] [<c0536fc4>] (sh_eth_resume) from [<c04d2240>] (dpm_run_callback+0x48/0xc8)
[  249.576702] [<c04d2240>] (dpm_run_callback) from [<c04d2740>] (device_resume+0x15c/0x1a0)
[  249.584898] [<c04d2740>] (device_resume) from [<c04d3644>] (dpm_resume+0xe4/0x244)
[  249.592485] [<c04d3644>] (dpm_resume) from [<c04d3968>] (dpm_resume_end+0xc/0x18)
[  249.599977] [<c04d3968>] (dpm_resume_end) from [<c0261010>] (suspend_devices_and_enter+0x3c8/0x490)
[  249.609042] [<c0261010>] (suspend_devices_and_enter) from [<c0261300>] (pm_suspend+0x228/0x280)
[  249.617759] [<c0261300>] (pm_suspend) from [<c025fecc>] (state_store+0xac/0xcc)
[  249.625089] [<c025fecc>] (state_store) from [<c0343b04>] (kernfs_fop_write+0x164/0x1a0)
[  249.633116] [<c0343b04>] (kernfs_fop_write) from [<c02e5838>] (__vfs_write+0x20/0x108)
[  249.641043] [<c02e5838>] (__vfs_write) from [<c02e6c08>] (vfs_write+0xb8/0x144)
[  249.648373] [<c02e6c08>] (vfs_write) from [<c02e788c>] (SyS_write+0x40/0x80)
[  249.655437] [<c02e788c>] (SyS_write) from [<c0206cc0>] (ret_fast_syscall+0x0/0x34)
[...]
[  254.753928] Showing busy workqueues and worker pools:
[...]
[  254.854225] workqueue mm_percpu_wq: flags=0xc
[  254.858583]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=0/0
[  254.864428]     delayed: drain_local_pages_wq, vmstat_update
[  254.870111]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=0/0
[  254.875957]     delayed: drain_local_pages_wq BAR(1703), vmstat_update

I got lost in the indirection here. But is it possible that the
allocating context will wake up the workqeue context? Anyway the patch
you have bisected to doesn't change a lot in this scenario as I've said
before. If anything the change to using WQ for the draining rather than
smp_function_call would change the behavior. Does the below help by any
chance?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5fca73c7881a..a9a1ab7ea4c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2417,6 +2417,14 @@ void drain_all_pages(struct zone *zone)
 	static cpumask_t cpus_with_pcps;
 
 	/*
+	 * This is an uggly hack but let's back off in the early PM suspend/resume
+	 * paths because the whole infrastructure might not be available yet for
+	 * us - namely kworkers might be still frozen
+	 */
+	if (pm_suspended_storage())
+		return;
+
+	/*
 	 * Make sure nobody triggers this path before mm_percpu_wq is fully
 	 * initialized.
 	 */
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
