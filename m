Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9EA6B01A2
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 12:13:10 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id w10so2402700pde.3
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 09:13:09 -0800 (PST)
Received: from psmtp.com ([74.125.245.179])
        by mx.google.com with SMTP id gw3si7547806pac.288.2013.11.08.09.13.07
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 09:13:08 -0800 (PST)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Fri, 8 Nov 2013 17:13:04 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0A2892190059
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 17:13:01 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA8HCmmi64946292
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 17:12:48 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rA8HD068032602
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 10:13:00 -0700
Date: Fri, 8 Nov 2013 18:12:59 +0100 (CET)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: mm/dmapool.c: possible circular locking dependency detected
Message-ID: <alpine.LFD.2.03.1311081758410.1811@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthieu Castet <matthieu.castet@parrot.com>, Marek Szyprowski <m.szyprowski@samsung.com>

During pci hotplug tests I received this one:

[   34.735836] ======================================================
[   34.735838] [ INFO: possible circular locking dependency detected ]
[   34.735840] 3.12.0-01915-g6c86ae2-dirty #125 Not tainted
[   34.735842] -------------------------------------------------------
[   34.735843] kworker/u128:3/49 is trying to acquire lock:
[   34.735845]  (s_active#27){++++.+}, at: [<00000000003048c2>] sysfs_addrm_finish+0x52/0x8c
[   34.735854] 
[   34.735854] but task is already holding lock:
[   34.735856]  (pools_lock){+.+.+.}, at: [<0000000000262e22>] dma_pool_destroy+0x32/0x1a4
[   34.735862] 
[   34.735862] which lock already depends on the new lock.
[   34.735862] 
[   34.735864] 
[   34.735864] the existing dependency chain (in reverse order) is:
[   34.735866] 
[   34.735866] -> #1 (pools_lock){+.+.+.}:
[   34.735869]        [<00000000001aa4c0>] __lock_acquire+0xf24/0x1698
[   34.735874]        [<00000000001ab360>] lock_acquire+0xb8/0x1f8
[   34.735876]        [<0000000000610a66>] mutex_lock_nested+0x7a/0x3a4
[   34.735880]        [<0000000000262cfa>] show_pools+0x5a/0x150
[   34.735883]        [<0000000000476e80>] dev_attr_show+0x38/0x78
[   34.735886]        [<00000000003027f8>] sysfs_seq_show+0x108/0x1b4
[   34.735888]        [<00000000002a3f46>] seq_read+0x136/0x550
[   34.735891]        [<0000000000279c9e>] vfs_read+0x8e/0x160
[   34.735894]        [<0000000000279f6a>] SyS_read+0x5e/0xb0
[   34.735896]        [<00000000006158ec>] sysc_nr_ok+0x22/0x28
[   34.735900]        [<0000004963071e98>] 0x4963071e98
[   34.735902] 
[   34.735902] -> #0 (s_active#27){++++.+}:
[   34.735906]        [<00000000001a68f8>] check_prev_add+0x748/0x74c
[   34.735908]        [<00000000001aa4c0>] __lock_acquire+0xf24/0x1698
[   34.735910]        [<00000000001ab360>] lock_acquire+0xb8/0x1f8
[   34.735913]        [<0000000000303bf4>] sysfs_deactivate+0xa4/0x124
[   34.735915]        [<00000000003048c2>] sysfs_addrm_finish+0x52/0x8c
[   34.735917]        [<0000000000304ea6>] sysfs_hash_and_remove+0x66/0xb0
[   34.735919]        [<0000000000262f70>] dma_pool_destroy+0x180/0x1a4
[   34.735922]        [<000003ff805cc0b2>] mlx4_cmd_cleanup+0x2e/0xa0 [mlx4_core]
[   34.735938]        [<000003ff805d7e58>] mlx4_remove_one+0x170/0x34c [mlx4_core]
[   34.735947]        [<00000000004425be>] pci_device_remove+0x42/0x7c
[   34.735950]        [<000000000047ad96>] __device_release_driver+0x6e/0xe0
[   34.735953]        [<000000000047ae46>] device_release_driver+0x3e/0x50
[   34.735956]        [<000000000047a7a0>] bus_remove_device+0x128/0x198
[   34.735958]        [<000000000047771c>] device_del+0x13c/0x1c8
[   34.735960]        [<000000000043bd40>] pci_stop_bus_device+0xb4/0xd8
[   34.735963]        [<000000000043beec>] pci_stop_and_remove_bus_device+0x28/0x38
[   34.735965]        [<000000000044410e>] remove_callback+0x3e/0x50
[   34.735968]        [<00000000003028d4>] sysfs_schedule_callback_work+0x30/0x84
[   34.735970]        [<000000000014eea8>] process_one_work+0x200/0x614
[   34.735975]        [<0000000000150674>] worker_thread+0x11c/0x308
[   34.735977]        [<000000000015903a>] kthread+0xd2/0xdc
[   34.735981]        [<0000000000615a72>] kernel_thread_starter+0x6/0xc
[   34.735983]        [<0000000000615a6c>] kernel_thread_starter+0x0/0xc
[   34.735986] 
[   34.735986] other info that might help us debug this:
[   34.735986] 
[   34.736001]  Possible unsafe locking scenario:
[   34.736001] 
[   34.736003]        CPU0                    CPU1
[   34.736005]        ----                    ----
[   34.736006]   lock(pools_lock);
[   34.736008]                                lock(s_active#27);
[   34.736010]                                lock(pools_lock);
[   34.736013]   lock(s_active#27);
[   34.736015] 
[   34.736015]  *** DEADLOCK ***
[   34.736015] 
[   34.736018] 5 locks held by kworker/u128:3/49:
[   34.736020]  #0:  (%s#5){.+.+.+}, at: [<000000000014ee22>] process_one_work+0x17a/0x614
[   34.736025]  #1:  ((&ss->work)){+.+.+.}, at: [<000000000014ee22>] process_one_work+0x17a/0x614
[   34.736030]  #2:  (pci_remove_rescan_mutex){+.+.+.}, at: [<0000000000444102>] remove_callback+0x32/0x50
[   34.736034]  #3:  (&__lockdep_no_validate__){......}, at: [<000000000047ae3c>] device_release_driver+0x34/0x50
[   34.736039]  #4:  (pools_lock){+.+.+.}, at: [<0000000000262e22>] dma_pool_destroy+0x32/0x1a4
[   34.736043] 
[   34.736043] stack backtrace:
[   34.736046] CPU: 0 PID: 49 Comm: kworker/u128:3 Not tainted 3.12.0-01915-g6c86ae2-dirty #125
[   34.736049] Workqueue: sysfsd sysfs_schedule_callback_work
[   34.736051]        000000007c827620 000000007c827630 0000000000000002 0000000000000000 
[   34.736051]        000000007c8276c0 000000007c827638 000000007c827638 000000000011157c 
[   34.736051]        0000000000000000 000000000078a13e 00000000007a4b50 000000000000000b 
[   34.736051]        000000007c827680 000000007c827620 0000000000000000 0000000000000000 
[   34.736051]        0000000000000000 000000000011157c 000000007c827620 000000007c827680 
[   34.736067] Call Trace:
[   34.736070] ([<0000000000111464>] show_trace+0xf8/0x158)
[   34.736072]  [<000000000011152e>] show_stack+0x6a/0xe8
[   34.736074]  [<000000000060d0a6>] dump_stack+0x82/0xac
[   34.736076]  [<00000000006071bc>] print_circular_bug+0x304/0x318
[   34.736078]  [<00000000001a68f8>] check_prev_add+0x748/0x74c
[   34.736080]  [<00000000001aa4c0>] __lock_acquire+0xf24/0x1698
[   34.736082]  [<00000000001ab360>] lock_acquire+0xb8/0x1f8
[   34.736084]  [<0000000000303bf4>] sysfs_deactivate+0xa4/0x124
[   34.736086]  [<00000000003048c2>] sysfs_addrm_finish+0x52/0x8c
[   34.736088]  [<0000000000304ea6>] sysfs_hash_and_remove+0x66/0xb0
[   34.736090]  [<0000000000262f70>] dma_pool_destroy+0x180/0x1a4
[   34.736097]  [<000003ff805cc0b2>] mlx4_cmd_cleanup+0x2e/0xa0 [mlx4_core]
[   34.736105]  [<000003ff805d7e58>] mlx4_remove_one+0x170/0x34c [mlx4_core]
[   34.736107]  [<00000000004425be>] pci_device_remove+0x42/0x7c
[   34.736109]  [<000000000047ad96>] __device_release_driver+0x6e/0xe0
[   34.736111]  [<000000000047ae46>] device_release_driver+0x3e/0x50
[   34.736113]  [<000000000047a7a0>] bus_remove_device+0x128/0x198
[   34.736115]  [<000000000047771c>] device_del+0x13c/0x1c8
[   34.736117]  [<000000000043bd40>] pci_stop_bus_device+0xb4/0xd8
[   34.736119]  [<000000000043beec>] pci_stop_and_remove_bus_device+0x28/0x38
[   34.736121]  [<000000000044410e>] remove_callback+0x3e/0x50
[   34.736123]  [<00000000003028d4>] sysfs_schedule_callback_work+0x30/0x84
[   34.736125]  [<000000000014eea8>] process_one_work+0x200/0x614
[   34.736127]  [<0000000000150674>] worker_thread+0x11c/0x308
[   34.736129]  [<000000000015903a>] kthread+0xd2/0xdc
[   34.736131]  [<0000000000615a72>] kernel_thread_starter+0x6/0xc
[   34.736133]  [<0000000000615a6c>] kernel_thread_starter+0x0/0xc
[   34.736135] INFO: lockdep is turned off.

The following patch fixes this for me - but maybe someone has a better
idea to handle this.

Regards,
Sebastian
--

mm/dmapool: fix a possible deadlock

Reading from $DEV/pools could result in a deadlock when the last
dmapool is removed from this device at the same time:

[   34.735836] ======================================================
[   34.735838] [ INFO: possible circular locking dependency detected ]
[   34.735840] 3.12.0-01915-g6c86ae2-dirty #125 Not tainted
[   34.735842] -------------------------------------------------------
[   34.735843] kworker/u128:3/49 is trying to acquire lock:
[   34.735845]  (s_active#27){++++.+}, at: [<00000000003048c2>] sysfs_addrm_finish+0x52/0x8c
[   34.735854] 
[   34.735854] but task is already holding lock:
[   34.735856]  (pools_lock){+.+.+.}, at: [<0000000000262e22>] dma_pool_destroy+0x32/0x1a4
[   34.735862] 
[   34.735862] which lock already depends on the new lock.
...
[   34.736001]  Possible unsafe locking scenario:
[   34.736001] 
[   34.736003]        CPU0                    CPU1
[   34.736005]        ----                    ----
[   34.736006]   lock(pools_lock);
[   34.736008]                                lock(s_active#27);
[   34.736010]                                lock(pools_lock);
[   34.736013]   lock(s_active#27);
[   34.736015] 
[   34.736015]  *** DEADLOCK ***

Fix this by moving the pools attribute creation and removal outside
the pools_lock (which is used to protect access to the dma_pools
list). And add a new lock to serialize the pools attribute
creation/removal.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 mm/dmapool.c |   39 ++++++++++++++++++++++++---------------
 1 file changed, 24 insertions(+), 15 deletions(-)

--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -61,7 +61,8 @@ struct dma_page {		/* cacheable header f
 	unsigned int offset;
 };
 
-static DEFINE_MUTEX(pools_lock);
+static DEFINE_MUTEX(pools_lock);     /* protect dev->dma_pools access */
+static DEFINE_MUTEX(pools_attr_lock);/* serialize pools attr creation/removal */
 
 static ssize_t
 show_pools(struct device *dev, struct device_attribute *attr, char *buf)
@@ -171,21 +172,24 @@ struct dma_pool *dma_pool_create(const c
 	retval->allocation = allocation;
 
 	if (dev) {
-		int ret;
+		bool empty;
 
+		mutex_lock(&pools_attr_lock);
 		mutex_lock(&pools_lock);
-		if (list_empty(&dev->dma_pools))
-			ret = device_create_file(dev, &dev_attr_pools);
-		else
-			ret = 0;
-		/* note:  not currently insisting "name" be unique */
-		if (!ret)
-			list_add(&retval->pools, &dev->dma_pools);
-		else {
-			kfree(retval);
-			retval = NULL;
-		}
+		empty = list_empty(&dev->dma_pools);
+		list_add(&retval->pools, &dev->dma_pools);
 		mutex_unlock(&pools_lock);
+		if (empty) {
+			if (device_create_file(dev, &dev_attr_pools)) {
+				mutex_lock(&pools_lock);
+				list_del(&retval->pools);
+				mutex_unlock(&pools_lock);
+
+				kfree(retval);
+				retval = NULL;
+			}
+		}
+		mutex_unlock(&pools_attr_lock);
 	} else
 		INIT_LIST_HEAD(&retval->pools);
 
@@ -259,11 +263,16 @@ static void pool_free_page(struct dma_po
  */
 void dma_pool_destroy(struct dma_pool *pool)
 {
+	bool empty;
+
+	mutex_lock(&pools_attr_lock);
 	mutex_lock(&pools_lock);
 	list_del(&pool->pools);
-	if (pool->dev && list_empty(&pool->dev->dma_pools))
-		device_remove_file(pool->dev, &dev_attr_pools);
+	empty = pool->dev && list_empty(&pool->dev->dma_pools);
 	mutex_unlock(&pools_lock);
+	if (empty)
+		device_remove_file(pool->dev, &dev_attr_pools);
+	mutex_unlock(&pools_attr_lock);
 
 	while (!list_empty(&pool->page_list)) {
 		struct dma_page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
