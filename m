Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7B4026B00E7
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 21:02:01 -0500 (EST)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx3-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p0P21xqx003823
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 21:01:59 -0500
Date: Mon, 24 Jan 2011 21:01:59 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <65587733.139133.1295920919846.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <784488145.139125.1295920770779.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: ksmd hung tasks
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is not always reproducible so far but I thought it would send it out anyway in case someone could spot the problem. Running some memory allocation using ksm with swapping workloads (like oom02 in LTP) caused hung tasks in 2.6.38-rc2 kernel.

INFO: task ksmd:278 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ksmd            D ffff88045ddab9e0     0   278      2 0x00000000
 ffff88045ddadc20 0000000000000046 0000000000000000 0000000100000000
 0000000000014d40 ffff88045ddab480 ffff88045ddab9e0 ffff88045ddadfd8
 ffff88045ddab9e8 0000000000014d40 ffff88045ddac010 0000000000014d40
Call Trace:
 [<ffffffff814a290d>] schedule_timeout+0x20d/0x2e0
 [<ffffffff8104d08d>] ? task_rq_lock+0x5d/0xa0
 [<ffffffff81058463>] ? try_to_wake_up+0xc3/0x420
 [<ffffffff814a253d>] wait_for_common+0x11d/0x190
 [<ffffffff810587c0>] ? default_wake_function+0x0/0x20
 [<ffffffff814a268d>] wait_for_completion+0x1d/0x20
 [<ffffffff81079530>] flush_work+0x30/0x40
 [<ffffffff81078230>] ? wq_barrier_func+0x0/0x20
 [<ffffffff81079603>] schedule_on_each_cpu+0xc3/0x110
 [<ffffffff81100ac5>] lru_add_drain_all+0x15/0x20
 [<ffffffff81137e58>] ksm_scan_thread+0x8e8/0xcb0
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81137570>] ? ksm_scan_thread+0x0/0xcb0
 [<ffffffff8107f6c6>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8107f630>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task jbd2/dm-0-8:1179 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
jbd2/dm-0-8     D ffff88045d9a3120     0  1179      2 0x00000000
 ffff88045cd97c20 0000000000000046 ffff88045d4d4fc0 ffff88045de984f8
 0000000000014d40 ffff88045d9a2bc0 ffff88045d9a3120 ffff88045cd97fd8
 ffff88045d9a3128 0000000000014d40 ffff88045cd96010 0000000000014d40
Call Trace:
 [<ffffffff81175fb0>] ? sync_buffer+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff81175ff0>] sync_buffer+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff81175fb0>] ? sync_buffer+0x0/0x50
 [<ffffffff814a2c98>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff81175fae>] __wait_on_buffer+0x2e/0x30
 [<ffffffffa0082fe8>] jbd2_journal_commit_transaction+0x908/0x13f0 [jbd2]
 [<ffffffff8106e2a3>] ? try_to_del_timer_sync+0x83/0xe0
 [<ffffffffa00882c8>] kjournald2+0xb8/0x220 [jbd2]
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffffa0088210>] ? kjournald2+0x0/0x220 [jbd2]
 [<ffffffff8107f6c6>] kthread+0x96/0xa0
 [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8107f630>] ? kthread+0x0/0xa0
 [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
INFO: task irqbalance:3321 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
irqbalance      D ffff880c5d995020     0  3321      1 0x00000080
 ffff880c5d4f7b08 0000000000000082 ffff880c5d4f7ab8 ffffffffffffffff
 0000000000014d40 ffff880c5d994ac0 ffff880c5d995020 ffff880c5d4f7fd8
 ffff880c5d995028 0000000000014d40 ffff880c5d4f6010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81141357>] ? mem_cgroup_uncharge_swap+0x27/0x80
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff810848d4>] ? hrtimer_nanosleep+0xc4/0x180
 [<ffffffff810836f0>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81084704>] ? hrtimer_start_range_ns+0x14/0x20
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task rpcbind:3335 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
rpcbind         D ffff880c5dfc99a0     0  3335      1 0x00000080
 ffff880c7f4ab738 0000000000000082 000000000000001e 0000004000000000
 0000000000014d40 ffff880c5dfc9440 ffff880c5dfc99a0 ffff880c7f4abfd8
 ffff880c5dfc99a8 0000000000014d40 ffff880c7f4aa010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112824f>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111a673>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81083af1>] ? lock_hrtimer_base+0x31/0x60
 [<ffffffff8108474d>] ? hrtimer_try_to_cancel+0x3d/0xd0
 [<ffffffff81084802>] ? hrtimer_cancel+0x22/0x30
 [<ffffffff814a4b15>] page_fault+0x25/0x30
 [<ffffffff8115be47>] ? do_sys_poll+0x357/0x540
 [<ffffffff8115be2f>] ? do_sys_poll+0x33f/0x540
 [<ffffffff8115b020>] ? __pollwait+0x0/0xf0
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8111a826>] ? handle_mm_fault+0x156/0x250
 [<ffffffff814a7e38>] ? do_page_fault+0x1d8/0x4b0
 [<ffffffff8116562f>] ? vfsmount_lock_global_unlock_online+0x4f/0x60
 [<ffffffff8116604c>] ? mntput_no_expire+0x19c/0x1c0
 [<ffffffff81013219>] ? read_tsc+0x9/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8115aecd>] ? poll_select_set_timeout+0x8d/0xa0
 [<ffffffff8115c22c>] sys_poll+0x7c/0x110
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task hald:6503 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
hald            D ffff88105d8f3a20     0  6503      1 0x00000080
 ffff88105d30d738 0000000000000086 000000005d30d698 0000004000000000
 0000000000014d40 ffff88105d8f34c0 ffff88105d8f3a20 ffff88105d30dfd8
 ffff88105d8f3a28 0000000000014d40 ffff88105d30c010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112824f>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111a673>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81083af1>] ? lock_hrtimer_base+0x31/0x60
 [<ffffffff8108474d>] ? hrtimer_try_to_cancel+0x3d/0xd0
 [<ffffffff81084802>] ? hrtimer_cancel+0x22/0x30
 [<ffffffff814a4b15>] page_fault+0x25/0x30
 [<ffffffff8115be47>] ? do_sys_poll+0x357/0x540
 [<ffffffff8115be2f>] ? do_sys_poll+0x33f/0x540
 [<ffffffff8115b020>] ? __pollwait+0x0/0xf0
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff81013219>] ? read_tsc+0x9/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8115aecd>] ? poll_select_set_timeout+0x8d/0xa0
 [<ffffffff8115c22c>] sys_poll+0x7c/0x110
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task ntpd:6604 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ntpd            D ffff8808563085e0     0  6604      1 0x00000080
 ffff88085d9f7958 0000000000000082 000000005df1eb40 00000040ffffffff
 0000000000014d40 ffff880856308080 ffff8808563085e0 ffff88085d9f7fd8
 ffff8808563085e8 0000000000014d40 ffff88085d9f6010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112824f>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111a673>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff814a4b15>] page_fault+0x25/0x30
 [<ffffffff8122405d>] ? copy_user_generic_string+0x2d/0x40
 [<ffffffff8115bad8>] ? set_fd_set+0x48/0x60
 [<ffffffff8115c515>] core_sys_select+0x1f5/0x2f0
 [<ffffffff81079025>] ? queue_work_on+0x25/0x30
 [<ffffffff8107906f>] ? queue_work+0x1f/0x30
 [<ffffffff8107986d>] ? queue_delayed_work+0x2d/0x40
 [<ffffffff8107989b>] ? schedule_delayed_work+0x1b/0x20
 [<ffffffff8108a51b>] ? do_adjtimex+0x1ab/0x670
 [<ffffffff81013219>] ? read_tsc+0x9/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8115c867>] sys_select+0x47/0x110
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task master:6680 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
master          D ffff88085cef2660     0  6680      1 0x00000080
 ffff88085d0abb08 0000000000000086 ffff88085d0abab8 ffffffffffffffff
 0000000000014d40 ffff88085cef2100 ffff88085cef2660 ffff88085d0abfd8
 ffff88085cef2668 0000000000014d40 ffff88085d0aa010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81141357>] ? mem_cgroup_uncharge_swap+0x27/0x80
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81185100>] ? sys_epoll_wait+0xa0/0x450
 [<ffffffff810587c0>] ? default_wake_function+0x0/0x20
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task abrtd:6689 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
abrtd           D ffff88045de2c660     0  6689      1 0x00000080
 ffff88045e1f7738 0000000000000086 000000005e1f7698 0000004000000000
 0000000000014d40 ffff88045de2c100 ffff88045de2c660 ffff88045e1f7fd8
 ffff88045de2c668 0000000000014d40 ffff88045e1f6010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff8112824f>] ? read_swap_cache_async+0x4f/0x140
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff8111a673>] handle_pte_fault+0xac3/0xb20
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81083af1>] ? lock_hrtimer_base+0x31/0x60
 [<ffffffff8108474d>] ? hrtimer_try_to_cancel+0x3d/0xd0
 [<ffffffff81084802>] ? hrtimer_cancel+0x22/0x30
 [<ffffffff814a4b15>] page_fault+0x25/0x30
 [<ffffffff8115be47>] ? do_sys_poll+0x357/0x540
 [<ffffffff8115be2f>] ? do_sys_poll+0x33f/0x540
 [<ffffffff8115b020>] ? __pollwait+0x0/0xf0
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff811d68f1>] ? inode_has_perm+0x51/0xa0
 [<ffffffff8116608d>] ? mntput+0x1d/0x30
 [<ffffffff811539e2>] ? path_put+0x22/0x30
 [<ffffffff811543f7>] ? finish_open+0x117/0x1f0
 [<ffffffff81157566>] ? do_path_lookup+0x76/0x130
 [<ffffffff811d6e2b>] ? dentry_has_perm+0x5b/0x80
 [<ffffffff8114db58>] ? cp_new_stat+0xf8/0x110
 [<ffffffff81013219>] ? read_tsc+0x9/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8115aecd>] ? poll_select_set_timeout+0x8d/0xa0
 [<ffffffff8115c22c>] sys_poll+0x7c/0x110
 [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b
INFO: task qmgr:6691 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
qmgr            D ffff88105f9eb9a0     0  6691   6680 0x00000084
 ffff88105a74db08 0000000000000086 ffff88105a74dab8 ffffffff00000000
 0000000000014d40 ffff88105f9eb440 ffff88105f9eb9a0 ffff88105a74dfd8
 ffff88105f9eb9a8 0000000000014d40 ffff88105a74c010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81141357>] ? mem_cgroup_uncharge_swap+0x27/0x80
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81185100>] ? sys_epoll_wait+0xa0/0x450
 [<ffffffff810587c0>] ? default_wake_function+0x0/0x20
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task oom02:7543 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
oom02           D ffff88085db07ae0     0  7543   7388 0x00000080
 ffff880855de1518 0000000000000082 0000000000011210 ffff880600000000
 0000000000014d40 ffff88085db07580 ffff88085db07ae0 ffff880855de1fd8
 ffff88085db07ae8 0000000000014d40 ffff880855de0010 0000000000014d40
Call Trace:
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff8120463a>] get_request_wait+0xca/0x1a0
 [<ffffffff8107fd50>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811fd197>] ? elv_merge+0x1d7/0x210
 [<ffffffff8120477b>] __make_request+0x6b/0x4d0
 [<ffffffff8120259f>] generic_make_request+0x21f/0x5b0
 [<ffffffff810f7885>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff810f7a23>] ? mempool_alloc+0x63/0x150
 [<ffffffff812029b6>] submit_bio+0x86/0x110
 [<ffffffff810ffb96>] ? test_set_page_writeback+0x106/0x190
 [<ffffffff81127f63>] swap_writepage+0x83/0xd0
 [<ffffffff811048fe>] pageout+0x12e/0x310
 [<ffffffff81104efa>] shrink_page_list+0x41a/0x5a0
 [<ffffffff81105686>] shrink_inactive_list+0x166/0x480
 [<ffffffff81106023>] shrink_zone+0x363/0x4d0
 [<ffffffff8110470e>] ? shrink_slab+0x14e/0x180
 [<ffffffff8110675f>] do_try_to_free_pages+0xaf/0x4a0
 [<ffffffff81106dc2>] try_to_free_pages+0x92/0x130
 [<ffffffff810fbc21>] ? get_page_from_freelist+0x3c1/0x810
 [<ffffffff810fc46b>] __alloc_pages_nodemask+0x3fb/0x760
 [<ffffffff81135313>] alloc_pages_vma+0x93/0x150
 [<ffffffff8111a2e2>] handle_pte_fault+0x732/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff814a1cfe>] ? schedule+0x44e/0xa10
 [<ffffffff814a4b15>] page_fault+0x25/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
