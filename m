Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DFA4F6B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 01:29:36 -0500 (EST)
Date: Tue, 25 Jan 2011 01:29:33 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1028361876.140219.1295936973627.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <AANLkTi=bZ_CsPje30WgHXrkvRVv9yVmVCtufh4m=KjBj@mail.gmail.com>
Subject: Re: ksmd hung tasks
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> Oooh, that is unfair, I put that lru_add_drain_all() into ksmd just
> for you, and now you accuse it of hanging :)
Sorry, I hate to hear that this is just to fix for me which means my
tests too narrow to benefit others. :)

> More seriously, it looks like the draining never gets a chance to run
> on one (or more) of the cpus, presumably something else is keeping
> that cpu unnaturally busy.
> 
> I think this is either another manifestation of the same problem as in
> your "kswapd hung tasks" posting, or an example of kswapd itself too
> busy, as reported by David: see his patch to linux-mm today,
> 
> http://marc.info/?l=linux-mm&m=129582353117092&w=2
> 
> Or perhaps those two cases are themselves related, though kswapd
> appears to be too busy in one case, and prevented from getting busy in
> the other.
It is still hung tasks somewhere else after applied the patch.

INFO: task auditd:3278 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
auditd          D ffff88085af88fe0     0  3278      1 0x00000000
 ffff88085f0b1b08 0000000000000082 ffff88085f0b1ab8 ffffffff00000000
 0000000000014d40 ffff88085af88a80 ffff88085af88fe0 ffff88085f0b1fd8
 ffff88085af88fe8 0000000000014d40 ffff88085f0b0010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff8107fd66>] ? autoremove_wake_function+0x16/0x40
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81185100>] ? sys_epoll_wait+0xa0/0x450
 [<ffffffff810587c0>] ? default_wake_function+0x0/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task irqbalance:3328 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
irqbalance      D ffff88105de3cfe0     0  3328      1 0x00000080
 ffff88105de91b08 0000000000000082 ffff88105de91ab8 ffffffff00000000
 0000000000014d40 ffff88105de3ca80 ffff88105de3cfe0 ffff88105de91fd8
 ffff88105de3cfe8 0000000000014d40 ffff88105de90010 0000000000014d40
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
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff810848d4>] ? hrtimer_nanosleep+0xc4/0x180
 [<ffffffff810836f0>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81084704>] ? hrtimer_start_range_ns+0x14/0x20
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task rpcbind:3342 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
rpcbind         D ffff880c5b0126e0     0  3342      1 0x00000080
 ffff880c5143bb08 0000000000000086 ffff880c5143bab8 ffffffff00000000
 0000000000014d40 ffff880c5b012180 ffff880c5b0126e0 ffff880c5143bfd8
 ffff880c5b0126e8 0000000000014d40 ffff880c5143a010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff8116562f>] ? vfsmount_lock_global_unlock_online+0x4f/0x60
 [<ffffffff8116604c>] ? mntput_no_expire+0x19c/0x1c0
 [<ffffffff81013219>] ? read_tsc+0x9/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8115aecd>] ? poll_select_set_timeout+0x8d/0xa0
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task hald:6507 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
hald            D ffff880c5bdb25a0     0  6507      1 0x00000080
 ffff880c5d3efb08 0000000000000086 ffff880c5d3efab8 ffffffff00000000
 0000000000014d40 ffff880c5bdb2040 ffff880c5bdb25a0 ffff880c5d3effd8
 ffff880c5bdb25a8 0000000000014d40 ffff880c5d3ee010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2a9a>] __wait_on_bit_lock+0x5a/0xc0
 [<ffffffff810f5237>] __lock_page+0x67/0x70
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f551d>] __lock_page_or_retry+0x4d/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81013219>] ? read_tsc+0x9/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8115aecd>] ? poll_select_set_timeout+0x8d/0xa0
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task automount:6568 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
automount       D ffff88085def46e0     0  6568      1 0x00000080
 ffff88085decfb08 0000000000000082 ffff88085decfab8 ffffffff00000000
 0000000000014d40 ffff88085def4180 ffff88085def46e0 ffff88085decffd8
 ffff88085def46e8 0000000000014d40 ffff88085dece010 0000000000014d40
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
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff810933eb>] ? sys_futex+0x7b/0x180
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task automount:6569 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
automount       D ffff88085d387b20     0  6569      1 0x00000080
 ffff88085d27bb08 0000000000000082 ffff88085d27bab8 ffffffff00000000
 0000000000014d40 ffff88085d3875c0 ffff88085d387b20 ffff88085d27bfd8
 ffff88085d387b28 0000000000014d40 ffff88085d27a010 0000000000014d40
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
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff8104c846>] ? enqueue_task+0x66/0x80
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff8105dad0>] ? do_fork+0xe0/0x340
 [<ffffffff810933eb>] ? sys_futex+0x7b/0x180
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task ntpd:6607 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ntpd            D ffff88105d9c9a20     0  6607      1 0x00000080
 ffff88105ea6db08 0000000000000086 ffff88105ea6dab8 ffffffff00000000
 0000000000014d40 ffff88105d9c94c0 ffff88105d9c9a20 ffff88105ea6dfd8
 ffff88105d9c9a28 0000000000014d40 ffff88105ea6c010 0000000000014d40
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
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff8115ba41>] ? poll_select_copy_remaining+0x101/0x150
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task master:6683 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
master          D ffff88105f9eb9a0     0  6683      1 0x00000080
 ffff88105e039b08 0000000000000082 ffff88105e039ab8 ffffffffa00040bc
 0000000000014d40 ffff88105f9eb440 ffff88105f9eb9a0 ffff88105e039fd8
 ffff88105f9eb9a8 0000000000014d40 ffff88105e038010 0000000000014d40
Call Trace:
 [<ffffffffa00040bc>] ? dm_table_unplug_all+0x5c/0x110 [dm_mod]
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81185100>] ? sys_epoll_wait+0xa0/0x450
 [<ffffffff810587c0>] ? default_wake_function+0x0/0x20
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task pickup:6690 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
pickup          D ffff88085e5a6fe0     0  6690   6683 0x00000080
 ffff88085fa2db08 0000000000000086 ffff88085fa2dab8 ffffffffa00040bc
 0000000000014d40 ffff88085e5a6a80 ffff88085e5a6fe0 ffff88085fa2dfd8
 ffff88085e5a6fe8 0000000000014d40 ffff88085fa2c010 0000000000014d40
Call Trace:
 [<ffffffffa00040bc>] ? dm_table_unplug_all+0x5c/0x110 [dm_mod]
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81185100>] ? sys_epoll_wait+0xa0/0x450
 [<ffffffff810587c0>] ? default_wake_function+0x0/0x20
 [<ffffffff814a4b15>] page_fault+0x25/0x30
INFO: task abrtd:6694 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
abrtd           D ffff88045e53c6a0     0  6694      1 0x00000080
 ffff88045cdb9b08 0000000000000082 ffff88045cdb9ab8 ffffffff00000000
 0000000000014d40 ffff88045e53c140 ffff88045e53c6a0 ffff88045cdb9fd8
 ffff88045e53c6a8 0000000000014d40 ffff88045cdb8010 0000000000014d40
Call Trace:
 [<ffffffff810f5260>] ? sync_page+0x0/0x50
 [<ffffffff814a2330>] io_schedule+0x70/0xc0
 [<ffffffff810f52a0>] sync_page+0x40/0x50
 [<ffffffff814a2bef>] __wait_on_bit+0x5f/0x90
 [<ffffffff810f5463>] wait_on_page_bit+0x73/0x80
 [<ffffffff8107fd90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f550a>] __lock_page_or_retry+0x3a/0x60
 [<ffffffff810f6537>] filemap_fault+0x2d7/0x4c0
 [<ffffffff8115b110>] ? pollwake+0x0/0x60
 [<ffffffff81119694>] __do_fault+0x54/0x570
 [<ffffffff81119ca7>] handle_pte_fault+0xf7/0xb20
 [<ffffffff81115727>] ? __pte_alloc+0xd7/0xf0
 [<ffffffff8111a826>] handle_mm_fault+0x156/0x250
 [<ffffffff814a7da3>] do_page_fault+0x143/0x4b0
 [<ffffffff81013219>] ? read_tsc+0x9/0x20
 [<ffffffff810899f3>] ? ktime_get_ts+0xb3/0xf0
 [<ffffffff8115aecd>] ? poll_select_set_timeout+0x8d/0xa0
 [<ffffffff814a4b15>] page_fault+0x25/0x30

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
