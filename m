Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 583F66B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:06:39 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id l192so350916312oih.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:06:39 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id s1si30630522ots.35.2016.11.30.00.06.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 00:06:38 -0800 (PST)
Message-ID: <583E8864.9000305@huawei.com>
Date: Wed, 30 Nov 2016 16:05:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] kasan: is it a wrong report from kasan?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linaro.org, rostedt@goodmis.org
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, wangwei <bessel.wang@huawei.com>

The kernel version is v4.1, and I find some error reports from kasan.
I'm not sure whether it is a wrong report.

11-29 07:57:26.513 <3>[12507.758056s][pid:0,cpu3,swapper/3]BUG: KASAN: stack-out-of-bounds in trace_event_buffer_lock_reserve+0x50/0x170 at addr ffffffc035903bf0
11-29 07:57:26.513 <3>[12507.758087s][pid:0,cpu3,swapper/3]Write of size 8 by task swapper/3/0
11-29 07:57:26.513 <0>[12507.758117s][pid:0,cpu3,swapper/3]page:ffffffbdc0d740c0 count:0 mapcount:0 mapping:          (null) index:0x0
11-29 07:57:26.513 <0>[12507.758117s][pid:0,cpu3,swapper/3]flags: 0x0()
11-29 07:57:26.513 <1>[12507.758148s][pid:0,cpu3,swapper/3]page dumped because: kasan: bad access detected
11-29 07:57:26.513 <4>[12507.758178s][pid:0,cpu3,swapper/3]CPU: 3 PID: 0 Comm: swapper/3 Tainted: G    B           4.1.18-gd8679e8 #1
11-29 07:57:26.513 <4>[12507.758209s][pid:0,cpu3,swapper/3]TGID: 0 Comm: swapper/3
11-29 07:57:26.513 <4>[12507.758239s][pid:0,cpu3,swapper/3]Hardware name: hi6250 (DT)
11-29 07:57:26.514 <0>[12507.758239s][pid:0,cpu3,swapper/3]Call trace:
11-29 07:57:26.514 <4>[12507.758270s][pid:0,cpu3,swapper/3][<ffffffc00008cf9c>] dump_backtrace+0x0/0x1f4
11-29 07:57:26.515 <4>[12507.758300s][pid:0,cpu3,swapper/3][<ffffffc00008d1b0>] show_stack+0x20/0x28
11-29 07:57:26.516 <4>[12507.758331s][pid:0,cpu3,swapper/3][<ffffffc001558010>] dump_stack+0x84/0xa8
11-29 07:57:26.516 <4>[12507.758361s][pid:0,cpu3,swapper/3][<ffffffc000261d88>] kasan_report+0x54c/0x574
11-29 07:57:26.517 <4>[12507.758361s][pid:0,cpu3,swapper/3][<ffffffc000260948>] __asan_store8+0x6c/0x84
11-29 07:57:26.517 <4>[12507.758392s][pid:0,cpu3,swapper/3][<ffffffc0001b4910>] trace_event_buffer_lock_reserve+0x50/0x170
11-29 07:57:26.517 <4>[12507.758422s][pid:0,cpu3,swapper/3][<ffffffc0001c2174>] ftrace_event_buffer_reserve+0x8c/0xd8
11-29 07:57:26.517 <4>[12507.758453s][pid:0,cpu3,swapper/3][<ffffffc0000e8690>] ftrace_raw_event_sched_wakeup_template+0xe0/0x194
11-29 07:57:26.517 <4>[12507.758483s][pid:0,cpu3,swapper/3][<ffffffc0000f0bc4>] ttwu_do_wakeup+0x19c/0x200
11-29 07:57:26.517 <4>[12507.758514s][pid:0,cpu3,swapper/3][<ffffffc0000f52ec>] try_to_wake_up+0x558/0x638
11-29 07:57:26.517 <4>[12507.758514s][pid:0,cpu3,swapper/3][<ffffffc0000f5408>] wake_up_process+0x3c/0x78
11-29 07:57:26.517 <4>[12507.758544s][pid:0,cpu3,swapper/3][<ffffffc0000b3644>] raise_softirq+0xa0/0xb4
11-29 07:57:26.517 <4>[12507.758575s][pid:0,cpu3,swapper/3][<ffffffc00013c040>] invoke_rcu_core+0x5c/0x6c
11-29 07:57:26.518 <4>[12507.758605s][pid:0,cpu3,swapper/3][<ffffffc000143cd8>] rcu_needs_cpu+0x190/0x198
11-29 07:57:26.518 <4>[12507.758636s][pid:0,cpu3,swapper/3][<ffffffc000164bac>] __tick_nohz_idle_enter+0x220/0x814
11-29 07:57:26.518 <4>[12507.758666s][pid:0,cpu3,swapper/3][<ffffffc0001658d4>] tick_nohz_idle_enter+0x68/0xa8
11-29 07:57:26.518 <4>[12507.758697s][pid:0,cpu3,swapper/3][<ffffffc00011b750>] cpu_startup_entry+0x88/0x51c
11-29 07:57:26.518 <4>[12507.758697s][pid:0,cpu3,swapper/3][<ffffffc000091fb4>] secondary_start_kernel+0x1d8/0x22c
11-29 07:57:26.518 <3>[12507.758728s][pid:0,cpu3,swapper/3]Memory state around the buggy address:
11-29 07:57:26.518 <3>[12507.758758s][pid:0,cpu3,swapper/3] ffffffc035903a80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
11-29 07:57:26.518 <3>[12507.758758s][pid:0,cpu3,swapper/3] ffffffc035903b00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
11-29 07:57:26.518 <3>[12507.758789s][pid:0,cpu3,swapper/3]>ffffffc035903b80: 00 00 00 00 f1 f1 f1 f1 00 00 f1 f1 f1 f1 f3 f3
11-29 07:57:26.518 <3>[12507.758819s][pid:0,cpu3,swapper/3]                                                             ^
11-29 07:57:26.519 <3>[12507.758850s][pid:0,cpu3,swapper/3] ffffffc035903c00: 00 00 00 00 f4 f4 00 00 00 00 00 00 00 00 00 00
11-29 07:57:26.519 <3>[12507.758850s][pid:0,cpu3,swapper/3] ffffffc035903c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


11-29 07:57:26.523 <3>[12507.759735s][pid:0,cpu3,swapper/3]BUG: KASAN: stack-out-of-bounds in ftrace_event_buffer_reserve+0x98/0xd8 at addr ffffffc035903bf8
11-29 07:57:26.523 <3>[12507.759765s][pid:0,cpu3,swapper/3]Write of size 8 by task swapper/3/0
11-29 07:57:26.523 <0>[12507.759765s][pid:0,cpu3,swapper/3]page:ffffffbdc0d740c0 count:0 mapcount:0 mapping:          (null) index:0x0
11-29 07:57:26.523 <0>[12507.759796s][pid:0,cpu3,swapper/3]flags: 0x0()
11-29 07:57:26.523 <1>[12507.759826s][pid:0,cpu3,swapper/3]page dumped because: kasan: bad access detected
11-29 07:57:26.523 <4>[12507.759857s][pid:0,cpu3,swapper/3]CPU: 3 PID: 0 Comm: swapper/3 Tainted: G    B           4.1.18-gd8679e8 #1
11-29 07:57:26.524 <4>[12507.759857s][pid:0,cpu3,swapper/3]TGID: 0 Comm: swapper/3
11-29 07:57:26.524 <4>[12507.759887s][pid:0,cpu3,swapper/3]Hardware name: hi6250 (DT)
11-29 07:57:26.524 <0>[12507.759887s][pid:0,cpu3,swapper/3]Call trace:
11-29 07:57:26.524 <4>[12507.759918s][pid:0,cpu3,swapper/3][<ffffffc00008cf9c>] dump_backtrace+0x0/0x1f4
11-29 07:57:26.524 <4>[12507.759948s][pid:0,cpu3,swapper/3][<ffffffc00008d1b0>] show_stack+0x20/0x28
11-29 07:57:26.524 <4>[12507.759979s][pid:0,cpu3,swapper/3][<ffffffc001558010>] dump_stack+0x84/0xa8
11-29 07:57:26.524 <4>[12507.760009s][pid:0,cpu3,swapper/3][<ffffffc000261d88>] kasan_report+0x54c/0x574
11-29 07:57:26.524 <4>[12507.760009s][pid:0,cpu3,swapper/3][<ffffffc000260948>] __asan_store8+0x6c/0x84
11-29 07:57:26.524 <4>[12507.760040s][pid:0,cpu3,swapper/3][<ffffffc0001c2180>] ftrace_event_buffer_reserve+0x98/0xd8
11-29 07:57:26.525 <4>[12507.760070s][pid:0,cpu3,swapper/3][<ffffffc0000e8690>] ftrace_raw_event_sched_wakeup_template+0xe0/0x194
11-29 07:57:26.525 <4>[12507.760101s][pid:0,cpu3,swapper/3][<ffffffc0000f0bc4>] ttwu_do_wakeup+0x19c/0x200
11-29 07:57:26.525 <4>[12507.760131s][pid:0,cpu3,swapper/3][<ffffffc0000f52ec>] try_to_wake_up+0x558/0x638
11-29 07:57:26.525 <4>[12507.760131s][pid:0,cpu3,swapper/3][<ffffffc0000f5408>] wake_up_process+0x3c/0x78
11-29 07:57:26.525 <4>[12507.760162s][pid:0,cpu3,swapper/3][<ffffffc0000b3644>] raise_softirq+0xa0/0xb4
11-29 07:57:26.525 <4>[12507.760192s][pid:0,cpu3,swapper/3][<ffffffc00013c040>] invoke_rcu_core+0x5c/0x6c
11-29 07:57:26.525 <4>[12507.760223s][pid:0,cpu3,swapper/3][<ffffffc000143cd8>] rcu_needs_cpu+0x190/0x198
11-29 07:57:26.525 <4>[12507.760253s][pid:0,cpu3,swapper/3][<ffffffc000164bac>] __tick_nohz_idle_enter+0x220/0x814
11-29 07:57:26.525 <4>[12507.760253s][pid:0,cpu3,swapper/3][<ffffffc0001658d4>] tick_nohz_idle_enter+0x68/0xa8
11-29 07:57:26.526 <4>[12507.760284s][pid:0,cpu3,swapper/3][<ffffffc00011b750>] cpu_startup_entry+0x88/0x51c
11-29 07:57:26.526 <4>[12507.760314s][pid:0,cpu3,swapper/3][<ffffffc000091fb4>] secondary_start_kernel+0x1d8/0x22c
11-29 07:57:26.526 <3>[12507.760345s][pid:0,cpu3,swapper/3]Memory state around the buggy address:
11-29 07:57:26.526 <3>[12507.760345s][pid:0,cpu3,swapper/3] ffffffc035903a80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
11-29 07:57:26.526 <3>[12507.760375s][pid:0,cpu3,swapper/3] ffffffc035903b00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
11-29 07:57:26.526 <3>[12507.760406s][pid:0,cpu3,swapper/3]>ffffffc035903b80: 00 00 00 00 f1 f1 f1 f1 00 00 f1 f1 f1 f1 f3 f3
11-29 07:57:26.526 <3>[12507.760406s][pid:0,cpu3,swapper/3]                                                                ^
11-29 07:57:26.526 <3>[12507.760437s][pid:0,cpu3,swapper/3] ffffffc035903c00: 00 00 00 00 f4 f4 00 00 00 00 00 00 00 00 00 00
11-29 07:57:26.526 <3>[12507.760467s][pid:0,cpu3,swapper/3] ffffffc035903c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
