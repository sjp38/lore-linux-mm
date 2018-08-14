Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 401AF6B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 01:10:58 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d9-v6so11283282itf.8
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 22:10:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p82-v6sor4225176itb.99.2018.08.13.22.10.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 22:10:56 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsNAjrwat-Fv6GQXq8uSC6uj=ke87RJt42syrfFi0vQUmg@mail.gmail.com>
 <bd7f3ea4-d9a8-e437-9936-ee4513b47ac1@suse.cz> <50f14cef-9c30-7984-bef3-6da033d91483@suse.cz>
 <20180808113615.qzdzifpkmt5yktbx@pathway.suse.cz>
In-Reply-To: <20180808113615.qzdzifpkmt5yktbx@pathway.suse.cz>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Tue, 14 Aug 2018 10:10:44 +0500
Message-ID: <CABXGCsN7LFX=af0Wi3p7jtHki=9hGbc2wD1jE4gH_ARok8rO-Q@mail.gmail.com>
Subject: Re: lock recursion - was: Re: [4.18 rc7] BUG: sleeping function
 called from invalid context at mm/slab.h:421
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pmladek@suse.com
Cc: vbabka@suse.cz, davem@davemloft.net, marcel@holtmann.org, johan.hedberg@gmail.com, linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, rostedt@goodmis.org, sergey.senozhatsky@gmail.com, peterz@infradead.org

That's all?
Issue happens everytime when I paired computer with bluetooth peripherals.
And this is not dependent on the bluetooth adapter used. I see this on
three different systems.
--
Best Regards,
Mike Gavrilov.

On Wed, 8 Aug 2018 at 16:36, Petr Mladek <pmladek@suse.com> wrote:
>
> On Wed 2018-08-08 11:05:00, Vlastimil Babka wrote:
> > On 08/08/2018 11:01 AM, Vlastimil Babka wrote:
> > > fbcon_startup() calls kzalloc(sizeof(struct fbcon_ops), GFP_KERNEL) so
> > > it tells slab it can sleep. The problem must be higher in the stack,
> > > CCing printk people.
> >
> > Uh just noticed there was also attached dmesg which my reply converted
> > to inline. The first problem there is a lockdep splat.
>
> The lockdep splat might eventually be a valid issue (recursive lock) in the
> networking code. But it seems to be unrelated to the later problems
> with sleeping in fbcon_startup().
>
> Adding networking people into CC. Please, find below the relevant part
> from the dmesg. The full log can be found in the original message at
> https://marc.info/?l=linux-mm&m=153370024009996&w=2
>
> Lock recursion in bluetooth code:
>
> [   32.050660] Bluetooth: RFCOMM TTY layer initialized
> [   32.050675] Bluetooth: RFCOMM socket layer initialized
> [   32.050719] Bluetooth: RFCOMM ver 1.11
> [   34.413359] fuse init (API version 7.27)
> [   40.562871] rfkill: input handler disabled
> [   42.272301] pool (2344) used greatest stack depth: 11320 bytes left
> [   42.701283] ISO 9660 Extensions: Microsoft Joliet Level 3
> [   42.704062] ISO 9660 Extensions: Microsoft Joliet Level 3
> [   42.710375] ISO 9660 Extensions: RRIP_1991A
> [   64.930766] tracker-extract (2229) used greatest stack depth: 11176 bytes left
> [  465.911281] TaskSchedulerFo (3362) used greatest stack depth: 11112 bytes left
> [  491.743600] TaskSchedulerFo (3364) used greatest stack depth: 11032 bytes left
> [  507.733884] nf_conntrack: default automatic helper assignment has been turned off \
> for security reasons and CT-based  firewall rule not found. Use the iptables CT \
> target to attach helpers instead. [  660.384586] kworker/dying (155) used greatest \
> stack depth: 10888 bytes left [  699.910094] device enp2s0 entered promiscuous mode
> [ 1098.658964] kworker/dying (7) used greatest stack depth: 10712 bytes left
> [ 1843.488301] perf: interrupt took too long (2510 > 2500), lowering \
> kernel.perf_event_max_sample_rate to 79000 [ 2819.896469] perf: interrupt took too \
> long (3138 > 3137), lowering kernel.perf_event_max_sample_rate to 63000 [ \
> 6120.247124] perf: interrupt took too long (3923 > 3922), lowering \
> kernel.perf_event_max_sample_rate to 50000
>
> [ 6829.212232] ============================================
> [ 6829.212234] WARNING: possible recursive locking detected
> [ 6829.212236] 4.18.0-0.rc7.git1.1.fc29.x86_64 #1 Not tainted
> [ 6829.212237] --------------------------------------------
> [ 6829.212239] kworker/u17:2/28441 is trying to acquire lock:
> [ 6829.212242] 000000004025b723 (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.}, at: \
> bt_accept_enqueue+0x3c/0xb0 [bluetooth] [ 6829.212260]
>                but task is already holding lock:
> [ 6829.212262] 000000004cb71eef (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.}, at: \
> l2cap_sock_new_connection_cb+0x18/0xa0 [bluetooth] [ 6829.212278]
>                other info that might help us debug this:
> [ 6829.212279]  Possible unsafe locking scenario:
>
> [ 6829.212281]        CPU0
> [ 6829.212282]        ----
> [ 6829.212284]   lock(sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP);
> [ 6829.212286]   lock(sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP);
> [ 6829.212288]
>                 *** DEADLOCK ***
>
> [ 6829.212290]  May be due to missing lock nesting notation
>
> [ 6829.212293] 5 locks held by kworker/u17:2/28441:
> [ 6829.212294]  #0: 000000009af6a4dc ((wq_completion)"%s"hdev->name#2){+.+.}, at: \
> process_one_work+0x1f3/0x650 [ 6829.212301]  #1: 000000006f7488f4 \
> ((work_completion)(&hdev->rx_work)){+.+.}, at: process_one_work+0x1f3/0x650 [ \
> 6829.212306]  #2: 000000003dba8333 (&conn->chan_lock){+.+.}, at: \
> l2cap_connect+0x8f/0x5a0 [bluetooth] [ 6829.212321]  #3: 00000000aaa813b9 \
> (&chan->lock/2){+.+.}, at: l2cap_connect+0xa9/0x5a0 [bluetooth] [ 6829.212335]  #4: \
> 000000004cb71eef (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.}, at: \
> l2cap_sock_new_connection_cb+0x18/0xa0 [bluetooth] [ 6829.212350]
>                stack backtrace:
> [ 6829.212354] CPU: 6 PID: 28441 Comm: kworker/u17:2 Not tainted \
> 4.18.0-0.rc7.git1.1.fc29.x86_64 #1 [ 6829.212355] Hardware name: Gigabyte Technology \
> Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014 [ 6829.212365] Workqueue: hci0 \
> hci_rx_work [bluetooth] [ 6829.212367] Call Trace:
> [ 6829.212373]  dump_stack+0x85/0xc0
> [ 6829.212377]  __lock_acquire.cold.64+0x158/0x227
> [ 6829.212381]  ? mark_held_locks+0x57/0x80
> [ 6829.212384]  lock_acquire+0x9e/0x1b0
> [ 6829.212394]  ? bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.212398]  lock_sock_nested+0x72/0xa0
> [ 6829.212407]  ? bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.212417]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.212429]  l2cap_sock_new_connection_cb+0x5d/0xa0 [bluetooth]
> [ 6829.212441]  l2cap_connect+0x110/0x5a0 [bluetooth]
> [ 6829.212454]  ? l2cap_recv_frame+0x6d0/0x2cb0 [bluetooth]
> [ 6829.212458]  ? __mutex_unlock_slowpath+0x4b/0x2b0
> [ 6829.212470]  l2cap_recv_frame+0x6e8/0x2cb0 [bluetooth]
> [ 6829.212474]  ? __mutex_unlock_slowpath+0x4b/0x2b0
> [ 6829.212484]  hci_rx_work+0x1c6/0x5d0 [bluetooth]
> [ 6829.212488]  process_one_work+0x27d/0x650
> [ 6829.212492]  worker_thread+0x3c/0x390
> [ 6829.212494]  ? process_one_work+0x650/0x650
> [ 6829.212498]  kthread+0x120/0x140
> [ 6829.212501]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 6829.212504]  ret_from_fork+0x3a/0x50
> [ 6829.285343] BUG: sleeping function called from invalid context at \
> net/core/sock.c:2833 [ 6829.285349] in_atomic(): 1, irqs_disabled(): 0, pid: 1743, \
> name: krfcommd [ 6829.285351] INFO: lockdep is turned off.
> [ 6829.285355] CPU: 6 PID: 1743 Comm: krfcommd Not tainted \
> 4.18.0-0.rc7.git1.1.fc29.x86_64 #1 [ 6829.285358] Hardware name: Gigabyte Technology \
> Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014 [ 6829.285360] Call Trace:
> [ 6829.285368]  dump_stack+0x85/0xc0
> [ 6829.285373]  ___might_sleep.cold.72+0xac/0xbc
> [ 6829.285378]  lock_sock_nested+0x29/0xa0
> [ 6829.285394]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 6829.285401]  rfcomm_connect_ind+0x21b/0x260 [rfcomm]
> [ 6829.285406]  rfcomm_run+0x1611/0x1820 [rfcomm]
> [ 6829.285411]  ? do_wait_intr_irq+0xb0/0xb0
> [ 6829.285416]  ? rfcomm_check_accept+0x90/0x90 [rfcomm]
> [ 6829.285419]  kthread+0x120/0x140
> [ 6829.285422]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 6829.285426]  ret_from_fork+0x3a/0x50
> [ 6829.476282] input: 04:5D:4B:5F:34:57 as /devices/virtual/input/input35
> [ 7273.090391] show_signal_msg: 23 callbacks suppressed
> [ 7273.090393] CFileWriterThre[29422]: segfault at 7f078bfe7240 ip 00007f079137843c \
> sp 00007f078bb8dcf0 error 4 in steamclient.so[7f0790880000+14d2000] [ 7273.090404] \
> Code: 89 df ff d2 8b 45 00 83 f8 02 0f 84 9e 00 00 00 83 f8 03 0f 84 55 05 00 00 83 \
> f8 01 74 48 31 ed 4d 85 e4 74 11 48 85 db 74 0c <48> 8b 03 4c 89 e6 48 89 df ff 50 10 \
> 48 8b b4 24 e8 00 00 00 64 48  [ 7755.656023] rfkill: input handler enabled
> [ 7773.439895] rfkill: input handler disabled
> [ 8075.232946] BUG: sleeping function called from invalid context at \
> net/core/sock.c:2833 [ 8075.232951] in_atomic(): 1, irqs_disabled(): 0, pid: 1743, \
> name: krfcommd [ 8075.232952] INFO: lockdep is turned off.
> [ 8075.232956] CPU: 5 PID: 1743 Comm: krfcommd Tainted: G        W         \
> 4.18.0-0.rc7.git1.1.fc29.x86_64 #1 [ 8075.232957] Hardware name: Gigabyte Technology \
> Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014 [ 8075.232959] Call Trace:
> [ 8075.232965]  dump_stack+0x85/0xc0
> [ 8075.232969]  ___might_sleep.cold.72+0xac/0xbc
> [ 8075.232973]  lock_sock_nested+0x29/0xa0
> [ 8075.232987]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [ 8075.232992]  rfcomm_connect_ind+0x21b/0x260 [rfcomm]
> [ 8075.232997]  rfcomm_run+0x1611/0x1820 [rfcomm]
> [ 8075.233001]  ? do_wait_intr_irq+0xb0/0xb0
> [ 8075.233005]  ? rfcomm_check_accept+0x90/0x90 [rfcomm]
> [ 8075.233008]  kthread+0x120/0x140
> [ 8075.233011]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 8075.233014]  ret_from_fork+0x3a/0x50
> [ 8075.413187] input: 04:5D:4B:5F:34:57 as /devices/virtual/input/input36
> [13538.300352] steam[4385]: segfault at 0 ip 00000000eabc32d9 sp 00000000ffdca1b0 \
> error 4 in vgui2_s.so[eab26000+292000] [13538.300365] Code: 74 03 00 00 00 00 00 00 \
> c7 44 24 08 02 00 00 00 c7 44 24 04 10 00 00 00 c7 04 24 44 ac 00 00 e8 1d 40 fb ff \
> 89 86 74 03 00 00 <8b> 00 8b 78 10 e8 3d 1a fb ff 8b 86 74 03 00 00 dd 5c 24 04 89 04 \
>  [14324.004275] pool[443]: segfault at 0 ip 00007f53e2399556 sp 00007f53ceffcc40 \
> error 4 in libnssutil3.so[7f53e2395000+12000] [14324.004286] Code: d8 5b 5d 41 5c c3 \
> 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 f3 0f 1e fa 41 54 41 bc ff ff ff ff 55 53 \
> 48 89 fb e8 7a bc ff ff <48> 8b 3b 48 89 c5 e8 9f c1 ff ff 48 8b 43 38 48 39 c5 75 23 \
> eb 2d  [14324.007764] rfkill: input handler enabled
> [14348.933385] rfkill: input handler disabled
> [15930.680376] DMA-API: debugging out of memory - disabling
> [16087.451698] vaapi-queue:src (10166) used greatest stack depth: 10616 bytes left
> [19689.192082] BUG: sleeping function called from invalid context at \
> net/core/sock.c:2833 [19689.192087] in_atomic(): 1, irqs_disabled(): 0, pid: 1743, \
> name: krfcommd [19689.192089] INFO: lockdep is turned off.
> [19689.192093] CPU: 6 PID: 1743 Comm: krfcommd Tainted: G        W         \
> 4.18.0-0.rc7.git1.1.fc29.x86_64 #1 [19689.192096] Hardware name: Gigabyte Technology \
> Co., Ltd. Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014 [19689.192098] Call Trace:
> [19689.192106]  dump_stack+0x85/0xc0
> [19689.192112]  ___might_sleep.cold.72+0xac/0xbc
> [19689.192117]  lock_sock_nested+0x29/0xa0
> [19689.192142]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
> [19689.192150]  rfcomm_connect_ind+0x21b/0x260 [rfcomm]
> [19689.192157]  rfcomm_run+0x1611/0x1820 [rfcomm]
> [19689.192163]  ? do_wait_intr_irq+0xb0/0xb0
> [19689.192179]  ? rfcomm_check_accept+0x90/0x90 [rfcomm]
> [19689.192183]  kthread+0x120/0x140
> [19689.192186]  ? kthread_create_worker_on_cpu+0x70/0x70
> [19689.192190]  ret_from_fork+0x3a/0x50
> [19689.377451] input: 04:5D:4B:5F:34:57 as /devices/virtual/input/input37
>
>
> Best Regards,
> Petr
