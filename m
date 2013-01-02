Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E5EDB6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 03:54:16 -0500 (EST)
Date: Wed, 2 Jan 2013 09:53:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20130102085355.GA22160@dhcp22.suse.cz>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50DAD696.8050400@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50DAD696.8050400@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Li,

On Wed 26-12-12 18:51:02, Li Zefan wrote:
> I reverted 38d7bee9d24adf4c95676a3dc902827c72930ebb ("cpuset: use N_MEMORY instead N_HIGH_MEMORY")
> and applied this patchset against 3.8-rc1.

I didn't find any patch in this email.
Anyway I am wondering how the above patch could cause the stuck you
mention below? The patch just renames N_HIGH_MEMORY -> N_MEMORY which
should map to the very same constant so there are no functional changes
AFAIU.

> I created a cpuset which has cpuset.cpus=1, and I forked a few cpu-hog tasks
> and moved them to this cpuset, and the final operations was offlining cpu1.
> It stucked.
> 
> The only processes in D state are kworker threads:
> 
> # cat /proc/6/stack
> 
> [<ffffffff81062be1>] wait_rcu_gp+0x51/0x60
> [<ffffffff810d18f6>] synchronize_sched+0x36/0x50
> [<ffffffff810b1b84>] cgroup_attach_task+0x144/0x1a0
> [<ffffffff810b737d>] cpuset_do_move_task+0x2d/0x40
> [<ffffffff810b3887>] cgroup_scan_tasks+0x1a7/0x270
> [<ffffffff810b9080>] cpuset_propagate_hotplug_workfn+0x130/0x360
> [<ffffffff8105d9d3>] process_one_work+0x1c3/0x3c0
> [<ffffffff81060e3a>] worker_thread+0x13a/0x400
> [<ffffffff8106613e>] kthread+0xce/0xe0
> [<ffffffff8144166c>] ret_from_fork+0x7c/0xb0
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> # cat /proc/80/stack
> 
> [<ffffffff81060015>] flush_workqueue+0x185/0x460
> [<ffffffff810b8b90>] cpuset_hotplug_workfn+0x2f0/0x5b0
> [<ffffffff8105d9d3>] process_one_work+0x1c3/0x3c0
> [<ffffffff81060e3a>] worker_thread+0x13a/0x400
> [<ffffffff8106613e>] kthread+0xce/0xe0
> [<ffffffff8144166c>] ret_from_fork+0x7c/0xb0
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> 
> After a while. dmesg:
> 
> [  222.290677] smpboot: CPU 1 is now offline
> [  222.292405] smpboot: Booting Node 0 Processor 1 APIC 0x2
> [  229.383324] smpboot: CPU 1 is now offline
> [  229.385415] smpboot: Booting Node 0 Processor 1 APIC 0x2
> [  231.715738] smpboot: CPU 1 is now offline
> [  231.717657] smpboot: Booting Node 0 Processor 1 APIC 0x2
> [  287.773881] smpboot: CPU 1 is now offline
> [  287.789983] smpboot: Booting Node 0 Processor 1 APIC 0x2
> [  343.248988] INFO: rcu_sched self-detected stall on CPU { 4}  (t=5250 jiffies g=1650 c=1649 q=2683)
> [  343.248998] Pid: 7861, comm: test3.sh Not tainted 3.8.0-rc1-0.7-default+ #6
> [  343.249000] Call Trace:
> [  343.249002]  <IRQ>  [<ffffffff810d11b9>] rcu_check_callbacks+0x249/0x770
> [  343.249018]  [<ffffffff8109c150>] ? tick_nohz_handler+0xc0/0xc0
> [  343.249021]  [<ffffffff8109c150>] ? tick_nohz_handler+0xc0/0xc0
> [  343.249028]  [<ffffffff810521f6>] update_process_times+0x46/0x90
> [  343.249031]  [<ffffffff8109bf9f>] tick_sched_handle+0x3f/0x50
> [  343.249034]  [<ffffffff8109c1a4>] tick_sched_timer+0x54/0x90
> [  343.249037]  [<ffffffff8106a99f>] __run_hrtimer+0xcf/0x1d0
> [  343.249040]  [<ffffffff8106ace7>] hrtimer_interrupt+0xe7/0x220
> [  343.249048]  [<ffffffff81443279>] smp_apic_timer_interrupt+0x69/0x99
> [  343.249051]  [<ffffffff81442332>] apic_timer_interrupt+0x72/0x80
> [  343.249053]  <EOI>  [<ffffffff81439320>] ? retint_restore_args+0x13/0x13
> [  343.249062]  [<ffffffff8106fa60>] ? task_nice+0x20/0x20
> [  343.249066]  [<ffffffff814224aa>] ? _cpu_down+0x19a/0x2e0
> [  343.249069]  [<ffffffff8142262e>] cpu_down+0x3e/0x60
> [  343.249072]  [<ffffffff81426635>] store_online+0x75/0xe0
> [  343.249076]  [<ffffffff812fc450>] dev_attr_store+0x20/0x30
> [  343.249082]  [<ffffffff811d6b07>] sysfs_write_file+0xc7/0x140
> [  343.249087]  [<ffffffff811671bb>] vfs_write+0xcb/0x130
> [  343.249090]  [<ffffffff81167a31>] sys_write+0x61/0xa0
> [  343.249093]  [<ffffffff81441719>] system_call_fastpath+0x16/0x1b
> [  406.164733] INFO: rcu_sched self-detected stall on CPU { 4}  (t=21003 jiffies g=1650 c=1649 q=9248)
> [  406.164741] Pid: 7861, comm: test3.sh Not tainted 3.8.0-rc1-0.7-default+ #6
> [  406.164743] Call Trace:
> [  406.164744]  <IRQ>  [<ffffffff810d11b9>] rcu_check_callbacks+0x249/0x770
> [  406.164753]  [<ffffffff8109c150>] ? tick_nohz_handler+0xc0/0xc0
> [  406.164756]  [<ffffffff8109c150>] ? tick_nohz_handler+0xc0/0xc0
> [  406.164760]  [<ffffffff810521f6>] update_process_times+0x46/0x90
> [  406.164763]  [<ffffffff8109bf9f>] tick_sched_handle+0x3f/0x50
> [  406.164766]  [<ffffffff8109c1a4>] tick_sched_timer+0x54/0x90
> [  406.164769]  [<ffffffff8106a99f>] __run_hrtimer+0xcf/0x1d0
> [  406.164771]  [<ffffffff8106ace7>] hrtimer_interrupt+0xe7/0x220
> [  406.164777]  [<ffffffff81443279>] smp_apic_timer_interrupt+0x69/0x99
> [  406.164780]  [<ffffffff81442332>] apic_timer_interrupt+0x72/0x80
> [  406.164781]  <EOI>  [<ffffffff814224aa>] ? _cpu_down+0x19a/0x2e0
> [  406.164787]  [<ffffffff814224aa>] ? _cpu_down+0x19a/0x2e0
> [  406.164790]  [<ffffffff8142262e>] cpu_down+0x3e/0x60
> [  406.164792]  [<ffffffff81426635>] store_online+0x75/0xe0
> [  406.164795]  [<ffffffff812fc450>] dev_attr_store+0x20/0x30
> [  406.164799]  [<ffffffff811d6b07>] sysfs_write_file+0xc7/0x140
> [  406.164802]  [<ffffffff811671bb>] vfs_write+0xcb/0x130
> [  406.164805]  [<ffffffff81167a31>] sys_write+0x61/0xa0
> [  406.164808]  [<ffffffff81441719>] system_call_fastpath+0x16/0x1b
> 
> I did the same thing without this patchset, and everthing's fine.
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
