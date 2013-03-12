Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 5737F6B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 04:32:43 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id h2so5415903oag.24
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 01:32:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <513ECCFE.3070201@huawei.com>
References: <513ECCFE.3070201@huawei.com>
Date: Tue, 12 Mar 2013 16:32:42 +0800
Message-ID: <CAJd=RBB7GVp_Ry30SuZVa-FgOogEZ43UnXOGvVKesV=Qk96UDA@mail.gmail.com>
Subject: Re: [BUG] potential deadlock led by cpu_hotplug lock (memcg involved)
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>, Hillf Danton <dhillf@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 12, 2013 at 2:36 PM, Li Zefan <lizefan@huawei.com> wrote:
> Seems a new bug in 3.9 kernel?
>
Bogus info, perhaps.

>
> [  207.271924] ======================================================
> [  207.271932] [ INFO: possible circular locking dependency detected ]
> [  207.271942] 3.9.0-rc1-0.7-default+ #34 Not tainted
> [  207.271948] -------------------------------------------------------
> [  207.271957] bash/10493 is trying to acquire lock:
> [  207.271963]  (subsys mutex){+.+.+.}, at: [<ffffffff8134af27>] bus_remove_device+0x37/0x1c0
> [  207.271987]
> [  207.271987] but task is already holding lock:
> [  207.271995]  (cpu_hotplug.lock){+.+.+.}, at: [<ffffffff81046ccf>] cpu_hotplug_begin+0x2f/0x60
> [  207.272012]
> [  207.272012] which lock already depends on the new lock.
> [  207.272012]
> [  207.272023]
> [  207.272023] the existing dependency chain (in reverse order) is:
> [  207.272033]
> [  207.272033] -> #4 (cpu_hotplug.lock){+.+.+.}:
> [  207.272044]        [<ffffffff810ae329>] lock_acquire+0xe9/0x120
> [  207.272056]        [<ffffffff814ad807>] mutex_lock_nested+0x37/0x360
> [  207.272069]        [<ffffffff81046ba9>] get_online_cpus+0x29/0x40
> [  207.272082]        [<ffffffff81185210>] drain_all_stock+0x30/0x150
> [  207.272094]        [<ffffffff811853da>] mem_cgroup_reclaim+0xaa/0xe0
> [  207.272104]        [<ffffffff8118775e>] __mem_cgroup_try_charge+0x51e/0xcf0
> [  207.272114]        [<ffffffff81188486>] mem_cgroup_charge_common+0x36/0x60
> [  207.272125]        [<ffffffff811884da>] mem_cgroup_newpage_charge+0x2a/0x30
> [  207.272135]        [<ffffffff81150531>] do_wp_page+0x231/0x830
> [  207.272147]        [<ffffffff8115151e>] handle_pte_fault+0x19e/0x8d0
> [  207.272157]        [<ffffffff81151da8>] handle_mm_fault+0x158/0x1e0
> [  207.272166]        [<ffffffff814b6153>] do_page_fault+0x2a3/0x4e0
> [  207.272178]        [<ffffffff814b2578>] page_fault+0x28/0x30
> [  207.272189]
> [  207.272189] -> #3 (&mm->mmap_sem){++++++}:
> [  207.272199]        [<ffffffff810ae329>] lock_acquire+0xe9/0x120
> [  207.272208]        [<ffffffff8114c5ad>] might_fault+0x6d/0x90
> [  207.272218]        [<ffffffff811a11e3>] filldir64+0xb3/0x120
> [  207.272229]        [<ffffffffa013fc19>] call_filldir+0x89/0x130 [ext3]
> [  207.272248]        [<ffffffffa0140377>] ext3_readdir+0x6b7/0x7e0 [ext3]
> [  207.272263]        [<ffffffff811a1519>] vfs_readdir+0xa9/0xc0
> [  207.272273]        [<ffffffff811a15cb>] sys_getdents64+0x9b/0x110
> [  207.272284]        [<ffffffff814bb599>] system_call_fastpath+0x16/0x1b
> [  207.272296]
> [  207.272296] -> #2 (&type->i_mutex_dir_key#3){+.+.+.}:
> [  207.272309]        [<ffffffff810ae329>] lock_acquire+0xe9/0x120
> [  207.272319]        [<ffffffff814ad807>] mutex_lock_nested+0x37/0x360
> [  207.272329]        [<ffffffff8119c254>] link_path_walk+0x6f4/0x9a0
> [  207.272339]        [<ffffffff8119e7fa>] path_openat+0xba/0x470
> [  207.272349]        [<ffffffff8119ecf8>] do_filp_open+0x48/0xa0
> [  207.272358]        [<ffffffff8118d81c>] file_open_name+0xdc/0x110
> [  207.272369]        [<ffffffff8118d885>] filp_open+0x35/0x40
> [  207.272378]        [<ffffffff8135c76e>] _request_firmware+0x52e/0xb20
> [  207.272389]        [<ffffffff8135cdd6>] request_firmware+0x16/0x20
> [  207.272399]        [<ffffffffa03bdb91>] request_microcode_fw+0x61/0xd0 [microcode]
> [  207.272416]        [<ffffffffa03bd554>] microcode_init_cpu+0x104/0x150 [microcode]
> [  207.272431]        [<ffffffffa03bd61c>] mc_device_add+0x7c/0xb0 [microcode]
> [  207.272444]        [<ffffffff8134a419>] subsys_interface_register+0xc9/0x100
> [  207.272457]        [<ffffffffa04fc0f4>] 0xffffffffa04fc0f4
> [  207.272472]        [<ffffffff81000202>] do_one_initcall+0x42/0x180
> [  207.272485]        [<ffffffff810bbeff>] load_module+0x19df/0x1b70
> [  207.272499]        [<ffffffff810bc376>] sys_init_module+0xe6/0x130
> [  207.272511]        [<ffffffff814bb599>] system_call_fastpath+0x16/0x1b
> [  207.272523]
> [  207.272523] -> #1 (umhelper_sem){++++.+}:
> [  207.272537]        [<ffffffff810ae329>] lock_acquire+0xe9/0x120
> [  207.272548]        [<ffffffff814ae9c4>] down_read+0x34/0x50
> [  207.272559]        [<ffffffff81062bff>] usermodehelper_read_trylock+0x4f/0x100
> [  207.272575]        [<ffffffff8135c7dd>] _request_firmware+0x59d/0xb20
> [  207.272587]        [<ffffffff8135cdd6>] request_firmware+0x16/0x20
> [  207.272599]        [<ffffffffa03bdb91>] request_microcode_fw+0x61/0xd0 [microcode]
> [  207.272613]        [<ffffffffa03bd554>] microcode_init_cpu+0x104/0x150 [microcode]
> [  207.272627]        [<ffffffffa03bd61c>] mc_device_add+0x7c/0xb0 [microcode]
> [  207.272641]        [<ffffffff8134a419>] subsys_interface_register+0xc9/0x100
> [  207.272654]        [<ffffffffa04fc0f4>] 0xffffffffa04fc0f4
> [  207.272666]        [<ffffffff81000202>] do_one_initcall+0x42/0x180
> [  207.272678]        [<ffffffff810bbeff>] load_module+0x19df/0x1b70
> [  207.272690]        [<ffffffff810bc376>] sys_init_module+0xe6/0x130
> [  207.272702]        [<ffffffff814bb599>] system_call_fastpath+0x16/0x1b
> [  207.272715]
> [  207.272715] -> #0 (subsys mutex){+.+.+.}:
> [  207.272729]        [<ffffffff810ae002>] __lock_acquire+0x13b2/0x15f0
> [  207.272740]        [<ffffffff810ae329>] lock_acquire+0xe9/0x120
> [  207.272751]        [<ffffffff814ad807>] mutex_lock_nested+0x37/0x360
> [  207.272763]        [<ffffffff8134af27>] bus_remove_device+0x37/0x1c0
> [  207.272775]        [<ffffffff81349114>] device_del+0x134/0x1f0
> [  207.272786]        [<ffffffff813491f2>] device_unregister+0x22/0x60
> [  207.272798]        [<ffffffff814a24ea>] mce_cpu_callback+0x15e/0x1ad
> [  207.272812]        [<ffffffff814b6402>] notifier_call_chain+0x72/0x130
> [  207.272824]        [<ffffffff81073d6e>] __raw_notifier_call_chain+0xe/0x10
> [  207.272839]        [<ffffffff81498f76>] _cpu_down+0x1d6/0x350
> [  207.272851]        [<ffffffff81499130>] cpu_down+0x40/0x60
> [  207.272862]        [<ffffffff8149cc55>] store_online+0x75/0xe0
> [  207.272874]        [<ffffffff813474a0>] dev_attr_store+0x20/0x30
> [  207.272886]        [<ffffffff812090d9>] sysfs_write_file+0xd9/0x150
> [  207.272900]        [<ffffffff8118e10b>] vfs_write+0xcb/0x130
> [  207.272911]        [<ffffffff8118e924>] sys_write+0x64/0xa0
> [  207.272923]        [<ffffffff814bb599>] system_call_fastpath+0x16/0x1b
> [  207.272936]
> [  207.272936] other info that might help us debug this:
> [  207.272936]
> [  207.272952] Chain exists of:
> [  207.272952]   subsys mutex --> &mm->mmap_sem --> cpu_hotplug.lock
> [  207.272952]
> [  207.272973]  Possible unsafe locking scenario:
> [  207.272973]
> [  207.272984]        CPU0                    CPU1
> [  207.272992]        ----                    ----
> [  207.273000]   lock(cpu_hotplug.lock);
> [  207.273009]                                lock(&mm->mmap_sem);
> [  207.273020]                                lock(cpu_hotplug.lock);
> [  207.273031]   lock(subsys mutex);
> [  207.273040]
> [  207.273040]  *** DEADLOCK ***

cpu_hotplug.lock could avoid deadlock by
checking lock owner:

void get_online_cpus(void)
{
	might_sleep();
	if (cpu_hotplug.active_writer == current)
		return;
	mutex_lock(&cpu_hotplug.lock);
	cpu_hotplug.refcount++;
	mutex_unlock(&cpu_hotplug.lock);

}

> [  207.273040]
> [  207.273055] 5 locks held by bash/10493:
> [  207.273062]  #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff81209049>] sysfs_write_file+0x49/0x150
> [  207.273080]  #1:  (s_active#150){.+.+.+}, at: [<ffffffff812090c2>] sysfs_write_file+0xc2/0x150
> [  207.273099]  #2:  (x86_cpu_hotplug_driver_mutex){+.+.+.}, at: [<ffffffff81027557>] cpu_hotplug_driver_lock+0x17/0x20
> [  207.273121]  #3:  (cpu_add_remove_lock){+.+.+.}, at: [<ffffffff8149911c>] cpu_down+0x2c/0x60
> [  207.273140]  #4:  (cpu_hotplug.lock){+.+.+.}, at: [<ffffffff81046ccf>] cpu_hotplug_begin+0x2f/0x60
> [  207.273158]
> [  207.273158] stack backtrace:
> [  207.273170] Pid: 10493, comm: bash Not tainted 3.9.0-rc1-0.7-default+ #34
> [  207.273180] Call Trace:
> [  207.273192]  [<ffffffff810ab373>] print_circular_bug+0x223/0x310
> [  207.273204]  [<ffffffff810ae002>] __lock_acquire+0x13b2/0x15f0
> [  207.273216]  [<ffffffff812086b0>] ? sysfs_hash_and_remove+0x60/0xc0
> [  207.273227]  [<ffffffff810ae329>] lock_acquire+0xe9/0x120
> [  207.273239]  [<ffffffff8134af27>] ? bus_remove_device+0x37/0x1c0
> [  207.273251]  [<ffffffff814ad807>] mutex_lock_nested+0x37/0x360
> [  207.273263]  [<ffffffff8134af27>] ? bus_remove_device+0x37/0x1c0
> [  207.273274]  [<ffffffff812086b0>] ? sysfs_hash_and_remove+0x60/0xc0
> [  207.273286]  [<ffffffff8134af27>] bus_remove_device+0x37/0x1c0
> [  207.273298]  [<ffffffff81349114>] device_del+0x134/0x1f0
> [  207.273309]  [<ffffffff813491f2>] device_unregister+0x22/0x60
> [  207.273321]  [<ffffffff814a24ea>] mce_cpu_callback+0x15e/0x1ad
> [  207.273332]  [<ffffffff814b6402>] notifier_call_chain+0x72/0x130
> [  207.273344]  [<ffffffff81073d6e>] __raw_notifier_call_chain+0xe/0x10
> [  207.273356]  [<ffffffff81498f76>] _cpu_down+0x1d6/0x350
> [  207.273368]  [<ffffffff81027557>] ? cpu_hotplug_driver_lock+0x17/0x20
> [  207.273380]  [<ffffffff81499130>] cpu_down+0x40/0x60
> [  207.273391]  [<ffffffff8149cc55>] store_online+0x75/0xe0
> [  207.273402]  [<ffffffff813474a0>] dev_attr_store+0x20/0x30
> [  207.273413]  [<ffffffff812090d9>] sysfs_write_file+0xd9/0x150
> [  207.273425]  [<ffffffff8118e10b>] vfs_write+0xcb/0x130
> [  207.273436]  [<ffffffff8118e924>] sys_write+0x64/0xa0
> [  207.273447]  [<ffffffff814bb599>] system_call_fastpath+0x16/0x1b
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
