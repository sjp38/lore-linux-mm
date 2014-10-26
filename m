Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 961726B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 17:09:14 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id f15so1010838lbj.37
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 14:09:13 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id oi5si16985853lbb.135.2014.10.26.14.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Oct 2014 14:09:12 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: CMA: test_pages_isolated failures in alloc_contig_range
Date: Sun, 26 Oct 2014 23:09:16 +0200
Message-ID: <2457604.k03RC2Mv4q@avalon>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Minchan Kim <minchan@kernel.org>

Hello,

I've run into a CMA-related issue while testing a DMA engine driver with 
dmatest on a Renesas R-Car ARM platform. 

When allocating contiguous memory through CMA the kernel prints the following 
messages to the kernel log.

[   99.770000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
[  124.220000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
[  127.550000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
[  132.850000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
[  151.390000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
[  166.490000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
[  181.450000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed

I've stripped the dmatest module down as much as possible to remove any 
hardware dependencies and came up with the following implementation.

-----------------------------------------------------------------------------
/*
 * CMA test module
 *
 * Copyright (C) 2014 Laurent Pinchart
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/delay.h>
#include <linux/dma-mapping.h>
#include <linux/freezer.h>
#include <linux/kthread.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>
#include <linux/wait.h>

static unsigned int num_threads = 4;
module_param(num_threads, uint, S_IRUGO | S_IWUSR);

static unsigned int iterations = 100000;
module_param(iterations, uint, S_IRUGO | S_IWUSR);

struct cma_test_thread {
	struct list_head node;
	struct task_struct *task;
	bool done;
};

static DECLARE_WAIT_QUEUE_HEAD(thread_wait);
static LIST_HEAD(threads);

static int cma_test_thread(void *data)
{
	struct cma_test_thread *thread = data;
	unsigned int i = 0;

	set_freezable();

	while (!kthread_should_stop() && i < iterations) {
		dma_addr_t dma;
		void *mem;

		mem = dma_alloc_coherent(NULL, 32, &dma, GFP_KERNEL);
		usleep_range(1000, 2000);
		if (mem)
			dma_free_coherent(NULL, 32, mem, dma);
		else
			printk(KERN_INFO "allocation error @%u\n", i);
		++i;
	}

	thread->done = true;
	wake_up(&thread_wait);

	return 0;
}

static bool cma_test_threads_done(void)
{
	struct cma_test_thread *thread;

	list_for_each_entry(thread, &threads, node) {
		if (!thread->done)
			return false;
	}

	return true;
}

static int cma_test_init(void)
{
	struct cma_test_thread *thread, *_thread;
	unsigned int i;

	for (i = 0; i < num_threads; ++i) {
		thread = kzalloc(sizeof(*thread), GFP_KERNEL);
		if (!thread) {
			pr_warn("No memory for thread %u\n", i);
			break;
		}

		thread->task = kthread_create(cma_test_thread, thread,
					      "cmatest-%u", i);
		if (IS_ERR(thread->task)) {
			pr_warn("Failed to create thread %u\n", i);
			kfree(thread);
			break;
		}

		get_task_struct(thread->task);
		list_add_tail(&thread->node, &threads);
		wake_up_process(thread->task);
	}

	wait_event(thread_wait, cma_test_threads_done());

	list_for_each_entry_safe(thread, _thread, &threads, node) {
		kthread_stop(thread->task);
		put_task_struct(thread->task);
		list_del(&thread->node);
		kfree(thread);
	}

	return 0;
}
module_init(cma_test_init);

static void cma_test_exit(void)
{
}
module_exit(cma_test_exit);

MODULE_AUTHOR("Laurent Pinchart");
MODULE_LICENSE("GPL v2");
-----------------------------------------------------------------------------

Loading the module will start 4 threads that will allocate and free DMA 
coherent memory in a tight loop and eventually produce the error. It seems 
like the probability of occurrence grows with the number of threads, which 
could indicate a race condition.

The tests have been run on 3.18-rc1, but previous tests on 3.16 did exhibit 
the same behaviour.

I'm not that familiar with the CMA internals, help would be appreciated to 
debug the problem.

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
