Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D19DC8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:07:20 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b17-v6so234137pfo.20
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 05:07:20 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id l6-v6si35877539pfc.298.2018.09.24.05.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 05:07:19 -0700 (PDT)
Date: Mon, 24 Sep 2018 13:07:01 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Warning after memory hotplug then online.
Message-ID: <20180924130701.00006a7b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linuxarm@huawei.com


Hi All,

This is with some additional patches on top of the mm tree to support
arm64 memory hot plug, but this particular issue doesn't (at first glance)
seem to be connected to that.  It's not a recent issue as IIRC I
disabled Kconfig for cgroups when starting to work on this some time ago
as a quick and dirty work around for this.

arm64 defconfig + the bits and pieces needed for the hot plug patchset.

[  125.865690] WARNING: CPU: 13 PID: 294 at kernel/cgroup/cgroup.c:4346 
css_task_iter_start+0xb0/0xb8
[  125.883686] Modules linked in:
[  125.889808] CPU: 13 PID: 294 Comm: kworker/13:1 Not tainted 
4.19.0-rc4-mm1-00209-g70dc260f963a #912
[  125.907978] Hardware name: Huawei Taishan 2280 /D05, BIOS Hisilicon 
D05 IT20 Nemo 2.0 RC0 03/30/2018
[  125.926329] Workqueue: events cpuset_hotplug_workfn
[  125.945728] pc : css_task_iter_start+0xb0/0xb8
[  125.954641] lr : update_tasks_nodemask+0x78/0x128
[  125.964077] sp : ffff00000ae2bc40
[  125.970718] x29: ffff00000ae2bc40 x28: 0000000000000000
[  125.981379] x27: 0000000000000000 x26: ffff0000091579a0
[  125.992040] x25: ffff000009157aa8 x24: 0000000000000000
[  126.002700] x23: ffff0000092c5b58 x22: 0000000000000000
[  126.013361] x21: ffff0000091579a0 x20: ffff0000091579a0
[  126.026018] x19: ffff00000ae2bcc8 x18: 0000000000000400
[  126.036679] x17: 0000000000000000 x16: 0000000000000000
[  126.047339] x15: 0000000000000400 x14: 0000000000000400
[  126.057999] x13: 0000000000000000 x12: 0000000000000001
[  126.068659] x11: 0000000000000001 x10: 0000000000000960
[  126.079319] x9 : ffff00000ae2bd70 x8 : ffff8011f39d6680
[  126.089980] x7 : fefefefefefefeff x6 : 0000000000000000
[  126.100640] x5 : ffff000009139000 x4 : 0000000000000000
[  126.111300] x3 : ffff000009139000 x2 : ffff00000ae2bcc8
[  126.121960] x1 : 0000000000000000 x0 : 0000000000000000
[  126.132621] Call trace:
[  126.137517]  css_task_iter_start+0xb0/0xb8
[  126.145730]  update_tasks_nodemask+0x78/0x128
[  126.154469]  cpuset_hotplug_workfn+0x1b4/0x6b8
[  126.163383]  process_one_work+0x1e0/0x318
[  126.171422]  worker_thread+0x40/0x450
[  126.178763]  kthread+0x128/0x130
[  126.185232]  ret_from_fork+0x10/0x18
[  126.192397] ---[ end trace 08fa9eb01e348a8b ]---

I'm running with an initrd only and very minimal setup indeed.

There superficially doesn't seem to be anything to stop this path being called
after memory hotplug and we clearly shouldn't be doing this.

The cpuset_hotplug_workfn correctly identifies that we have some new memory.

Thoughts? (Or am I doing something stupid?)

Thanks,

Jonathan
