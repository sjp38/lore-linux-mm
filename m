Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id DA93A6B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 05:16:06 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id m14so3143687wev.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:16:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bq7si5892914wjb.180.2015.02.12.02.16.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 02:16:05 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH 0/3] memory_hotplug: hyperv: fix deadlock between memory adding and onlining
References: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
	<alpine.DEB.2.10.1502111229500.16711@chino.kir.corp.google.com>
Date: Thu, 12 Feb 2015 11:15:43 +0100
In-Reply-To: <alpine.DEB.2.10.1502111229500.16711@chino.kir.corp.google.com>
	(David Rientjes's message of "Wed, 11 Feb 2015 12:30:30 -0800 (PST)")
Message-ID: <871tlv1lm8.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, linux-mm@kvack.org

David Rientjes <rientjes@google.com> writes:

> On Wed, 11 Feb 2015, Vitaly Kuznetsov wrote:
>
>> If newly added memory is brought online with e.g. udev rule:
>> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}="online"
>> the following deadlock is observed (and easily reproducable):
>> 
>> First participant, worker thread doing add_memory():
>> 
>> [  724.948846] kworker/0:1     D ffff88000412f9c8 13248    27      2 0x00000000
>> [  724.973543] Workqueue: events hot_add_req [hv_balloon]
>> [  724.991736]  ffff88000412f9c8 0000000000000000 ffff88003fa1dc30 00000000000151c0
>> [  725.019725]  0000000000000246 ffff88000412ffd8 00000000000151c0 ffff88003a77a4e0
>> [  725.046486]  ffff88003fa1dc30 00000001032a6000 ffff88003a7ca838 ffff88003a7ca898
>> [  725.072969] Call Trace:
>> [  725.082690]  [<ffffffff81aac0a9>] schedule_preempt_disabled+0x29/0x70
>> [  725.103799]  [<ffffffff81aae33b>] mutex_lock_nested+0x14b/0x470
>> [  725.122367]  [<ffffffff815ed773>] ? device_attach+0x23/0xb0
>> [  725.140992]  [<ffffffff815ed773>] device_attach+0x23/0xb0
>> [  725.159131]  [<ffffffff815ecba0>] bus_probe_device+0xb0/0xe0
>> [  725.177055]  [<ffffffff815ea693>] device_add+0x443/0x650
>> [  725.195558]  [<ffffffff815ea8be>] device_register+0x1e/0x30
>> [  725.213133]  [<ffffffff81601790>] init_memory_block+0xd0/0xf0
>> [  725.231533]  [<ffffffff816018f1>] register_new_memory+0xb1/0xd0
>> [  725.250769]  [<ffffffff81a961cf>] __add_pages+0x13f/0x250
>> [  725.269642]  [<ffffffff81063770>] ? arch_add_memory+0x70/0xf0
>> [  725.288764]  [<ffffffff81063770>] arch_add_memory+0x70/0xf0
>> [  725.306117]  [<ffffffff81a95f8f>] add_memory+0xef/0x1f0
>> [  725.322466]  [<ffffffffa00293af>] hot_add_req+0x33f/0xf90 [hv_balloon]
>> [  725.342777]  [<ffffffff8109509f>] process_one_work+0x1df/0x4e0
>> [  725.361459]  [<ffffffff8109502d>] ? process_one_work+0x16d/0x4e0
>> [  725.380390]  [<ffffffff810954bb>] worker_thread+0x11b/0x450
>> [  725.397684]  [<ffffffff810953a0>] ? process_one_work+0x4e0/0x4e0
>> [  725.416533]  [<ffffffff8109ac33>] kthread+0xf3/0x110
>> [  725.433372]  [<ffffffff8109ab40>] ? kthread_create_on_node+0x240/0x240
>> [  725.453749]  [<ffffffff81ab1dfc>] ret_from_fork+0x7c/0xb0
>> [  725.470994]  [<ffffffff8109ab40>] ? kthread_create_on_node+0x240/0x240
>> [  725.491469] 6 locks held by kworker/0:1/27:
>> [  725.505037]  #0:  ("events"){......}, at: [<ffffffff8109502d>] process_one_work+0x16d/0x4e0
>> [  725.533370]  #1:  ((&dm_device.ha_wrk.wrk)){......}, at: [<ffffffff8109502d>] process_one_work+0x16d/0x4e0
>> [  725.565580]  #2:  (mem_hotplug.lock){......}, at: [<ffffffff811e6525>] mem_hotplug_begin+0x5/0x80
>> [  725.594369]  #3:  (mem_hotplug.lock#2){......}, at: [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80
>> [  725.628554]  #4:  (mem_sysfs_mutex){......}, at: [<ffffffff81601873>] register_new_memory+0x33/0xd0
>> [  725.658519]  #5:  (&dev->mutex){......}, at: [<ffffffff815ed773>] device_attach+0x23/0xb0
>> 
>> Second participant, udev:
>> 
>> [  725.750889] systemd-udevd   D ffff88003b94fc68 14016   888    530 0x00000004
>> [  725.773767]  ffff88003b94fc68 0000000000000000 ffff8800034949c0 00000000000151c0
>> [  725.798332]  ffffffff8210d980 ffff88003b94ffd8 00000000000151c0 ffff880037a69270
>> [  725.822841]  ffff8800034949c0 0000000100000001 ffff8800034949c0 ffffffff81ff2b48
>> [  725.849184] Call Trace:
>> [  725.858987]  [<ffffffff81aac0a9>] schedule_preempt_disabled+0x29/0x70
>> [  725.879231]  [<ffffffff81aae33b>] mutex_lock_nested+0x14b/0x470
>> [  725.897860]  [<ffffffff811e656f>] ? mem_hotplug_begin+0x4f/0x80
>> [  725.916698]  [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80
>> [  725.935064]  [<ffffffff811e6525>] ? mem_hotplug_begin+0x5/0x80
>> [  725.953464]  [<ffffffff81a9631b>] online_pages+0x3b/0x520
>> [  725.971542]  [<ffffffff815eb0b3>] ? device_online+0x23/0xa0
>> [  725.989207]  [<ffffffff81601524>] memory_subsys_online+0x64/0xc0
>> [  726.008513]  [<ffffffff815eb0fd>] device_online+0x6d/0xa0
>> [  726.025579]  [<ffffffff816012eb>] store_mem_state+0x5b/0xe0
>> [  726.043400]  [<ffffffff815e8258>] dev_attr_store+0x18/0x30
>> [  726.060506]  [<ffffffff8127a808>] sysfs_kf_write+0x48/0x60
>> [  726.077940]  [<ffffffff81279d1b>] kernfs_fop_write+0x13b/0x1a0
>> [  726.099416]  [<ffffffff811f9f67>] vfs_write+0xb7/0x1f0
>> [  726.115748]  [<ffffffff811fabf8>] SyS_write+0x58/0xd0
>> [  726.131933]  [<ffffffff81ab1ea9>] system_call_fastpath+0x12/0x17
>> [  726.150691] 7 locks held by systemd-udevd/888:
>> [  726.165044]  #0:  (sb_writers#3){......}, at: [<ffffffff811fa063>] vfs_write+0x1b3/0x1f0
>> [  726.192422]  #1:  (&of->mutex){......}, at: [<ffffffff81279c46>] kernfs_fop_write+0x66/0x1a0
>> [  726.220289]  #2:  (s_active#60){......}, at: [<ffffffff81279c4e>] kernfs_fop_write+0x6e/0x1a0
>> [  726.249382]  #3:  (device_hotplug_lock){......}, at: [<ffffffff815e9c15>] lock_device_hotplug_sysfs+0x15/0x50
>> [  726.281901]  #4:  (&dev->mutex){......}, at: [<ffffffff815eb0b3>] device_online+0x23/0xa0
>> [  726.308619]  #5:  (mem_hotplug.lock){......}, at: [<ffffffff811e6525>] mem_hotplug_begin+0x5/0x80
>> [  726.337994]  #6:  (mem_hotplug.lock#2){......}, at: [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80
>> 
>> In short: onlining grabs device lock and then tries to do mem_hotplug_begin()
>> while add_memory() is between mem_hotplug_begin() and mem_hotplug_done() and it
>> tries grabbing device lock.
>> 
>> To my understanding ACPI memory hotplug doesn't have the same issue as
>> device_hotplug_lock is being grabbed when the ACPI device is added.
>> 
>> Solve the issue by grabbing device_hotplug_lock before doing add_memory(). If
>> we do that, lock_device_hotplug_sysfs() will cause syscall retry which will
>> eventually succeed. To support the change we need to export lock_device_hotplug/
>> unlock_device_hotplug. This approach can be completely wrong though.
>
> Saying the approach could be completely wrong doesn't inspire a lot of 
> confidence.  I assume this output is from the hung task detector, is there 
> any other lockdep output that suggests there's a possible deadlock?

I said 'can be completely wrong' not because I'm not sure about the
cause of the deadlock (see locks #.2,3,5 in worker thread and locks
4,5,6 in systemd-udev) and not because I'm not sure my patch solves the
issue (as you can see lock #3 in systemd-udevd was taken before the
dev->mutex so we should be safe). My testing also showed the issue is
gone. I rather wasn't sure there is no other way to obtain this lock
indirectly or do some other synchronization.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
