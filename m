Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD886B0005
	for <linux-mm@kvack.org>; Sun,  5 Jun 2016 14:42:00 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id lp2so80074711igb.3
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 11:42:00 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id v66si3640559oig.116.2016.06.05.11.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jun 2016 11:41:59 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id r4so1857255oib.1
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 11:41:59 -0700 (PDT)
Date: Sun, 5 Jun 2016 13:41:57 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] mm: Introduce dedicated WQ_MEM_RECLAIM workqueue to
 do lru_add_drain_all
Message-ID: <20160605184157.GT31708@htj.duckdns.org>
References: <1464917521-9775-1-git-send-email-shhuiw@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464917521-9775-1-git-send-email-shhuiw@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@foxmail.com>
Cc: keith.busch@intel.com, peterz@infradead.org, treding@nvidia.com, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Jun 03, 2016 at 09:32:01AM +0800, Wang Sheng-Hui wrote:
> This patch is based on https://patchwork.ozlabs.org/patch/574623/.
> 
> Tejun submitted commit 23d11a58a9a6 ("workqueue: skip flush dependency
> checks for legacy workqueues") for the legacy create*_workqueue()
> interface. But some workq created by alloc_workqueue still reports
> warning on memory reclaim, e.g nvme_workq with flag WQ_MEM_RECLAIM set:
> 
> [    0.153902] workqueue: WQ_MEM_RECLAIM nvme:nvme_reset_work is
> flushing !WQ_MEM_RECLAIM events:lru_add_drain_per_cpu
> [    0.153907] ------------[ cut here ]------------
> [    0.153912] WARNING: CPU: 0 PID: 6 at
> SoC/linux/kernel/workqueue.c:2448
> check_flush_dependency+0xb4/0x10c
> ...
> [    0.154083] [<fffffc00080d6de0>] check_flush_dependency+0xb4/0x10c
> [    0.154088] [<fffffc00080d8e80>] flush_work+0x54/0x140
> [    0.154092] [<fffffc0008166a0c>] lru_add_drain_all+0x138/0x188
> [    0.154097] [<fffffc00081ab2dc>] migrate_prep+0xc/0x18
> [    0.154101] [<fffffc0008160e88>] alloc_contig_range+0xf4/0x350
> [    0.154105] [<fffffc00081bcef8>] cma_alloc+0xec/0x1e4
> [    0.154110] [<fffffc0008446ad0>] dma_alloc_from_contiguous+0x38/0x40
> [    0.154114] [<fffffc00080a093c>] __dma_alloc+0x74/0x25c
> [    0.154119] [<fffffc00084828d8>] nvme_alloc_queue+0xcc/0x36c
> [    0.154123] [<fffffc0008484b2c>] nvme_reset_work+0x5c4/0xda8
> [    0.154128] [<fffffc00080d9528>] process_one_work+0x128/0x2ec
> [    0.154132] [<fffffc00080d9744>] worker_thread+0x58/0x434
> [    0.154136] [<fffffc00080df0ec>] kthread+0xd4/0xe8
> [    0.154141] [<fffffc0008093ac0>] ret_from_fork+0x10/0x50
> 
> That's because lru_add_drain_all() will schedule the drain work on
> system_wq, whose flag is set to 0, !WQ_MEM_RECLAIM.
> 
> Introduce a dedicated WQ_MEM_RECLAIM workqueue to do lru_add_drain_all(),
> aiding in getting memory freed.
> 
> Compared with v1:
> 	* The key flag is WQ_MEM_RECLAIM. Drop the flag WQ_UNBOUND.
> 	* Reserve the warn in lru_init as init code during bootup ignore
> 	  return code from early_initcall functions.
> 	* Instead of falling back to system_wq, crash directly if the wq
> 	  is used in lru_add_drain_all but was not created in lru_init
> 	  at init stage.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@foxmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
