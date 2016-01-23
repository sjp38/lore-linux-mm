Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id E1467828DF
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 01:30:36 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id z14so5374921igp.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 22:30:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y20si10113703igr.26.2016.01.22.22.30.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jan 2016 22:30:35 -0800 (PST)
Subject: Re: [BUG] oom hangs the system, NMI backtrace shows most CPUs in shrink_slab
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <569D06F8.4040209@redhat.com>
	<569E1010.2070806@I-love.SAKURA.ne.jp>
	<56A24760.5020503@redhat.com>
In-Reply-To: <56A24760.5020503@redhat.com>
Message-Id: <201601231530.ICI52671.JVMFQLtOSOOHFF@I-love.SAKURA.ne.jp>
Date: Sat, 23 Jan 2016 15:30:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jstancek@redhat.com, linux-mm@kvack.org
Cc: ltp@lists.linux.it

Jan Stancek wrote:
> On 01/19/2016 11:29 AM, Tetsuo Handa wrote:
> > although I
> > couldn't find evidence that mlock() and madvice() are related with this hangup,
> 
> I simplified reproducer by having only single thread allocating
> memory when OOM triggers:
>   http://jan.stancek.eu/tmp/oom_hangs/console.log.3-v4.4-8606-with-memalloc.txt
> 
> In this instance it was mmap + mlock, as you can see from oom call trace.
> It made it to do_exit(), but couldn't complete it:

Thank you for retaking.

Comparing console.log.2-v4.4-8606-with-memalloc_wc.txt.bz2 and
console.log.3-v4.4-8606-with-memalloc.txt :

  different things

    Free swap  = 0kB for the former
    Free swap  = 7556632kB for the latter

  common things

    All stalling allocations are order 0.
    Swap cache stats: stopped increasing
    Node 0 Normal free: remained below min:
    A kworker got stuck inside 0x2400000 (GFP_NOIO) allocation within 1 second
    after other allocations (0x24280ca (GFP_HIGHUSER_MOVABLE) or 0x24201ca
    (GFP_HIGHUSER_MOVABLE | __GFP_COLD)) got stuck.

----------
[ 6904.555880] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 6904.563387] MemAlloc: oom01(22011) seq=5135 gfp=0x24280ca order=0 delay=10001
[ 6904.571353] MemAlloc: oom01(22013) seq=5101 gfp=0x24280ca order=0 delay=10001
[ 6915.195869] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
[ 6915.203458] MemAlloc: systemd-journal(592) seq=33409 gfp=0x24201ca order=0 delay=20495
[ 6915.212300] MemAlloc: NetworkManager(807) seq=42042 gfp=0x24200ca order=0 delay=12030
[ 6915.221042] MemAlloc: gssproxy(815) seq=1551 gfp=0x24201ca order=0 delay=19414
[ 6915.229104] MemAlloc: irqbalance(825) seq=6763 gfp=0x24201ca order=0 delay=11234
[ 6915.237363] MemAlloc: tuned(1339) seq=74664 gfp=0x24201ca order=0 delay=20354
[ 6915.245329] MemAlloc: top(10485) seq=486624 gfp=0x24201ca order=0 delay=20124
[ 6915.253288] MemAlloc: kworker/1:1(20708) seq=48 gfp=0x2400000 order=0 delay=20248
[ 6915.261640] MemAlloc: sendmail(21855) seq=207 gfp=0x24201ca order=0 delay=19977
[ 6915.269800] MemAlloc: oom01(22007) seq=2 gfp=0x24201ca order=0 delay=20269
[ 6915.277466] MemAlloc: oom01(22008) seq=5659 gfp=0x24280ca order=0 delay=20502
[ 6915.285432] MemAlloc: oom01(22009) seq=5189 gfp=0x24280ca order=0 delay=20502
[ 6915.293389] MemAlloc: oom01(22010) seq=4795 gfp=0x24280ca order=0 delay=20502
[ 6915.301353] MemAlloc: oom01(22011) seq=5135 gfp=0x24280ca order=0 delay=20641
[ 6915.309316] MemAlloc: oom01(22012) seq=3828 gfp=0x24280ca order=0 delay=20502
[ 6915.317280] MemAlloc: oom01(22013) seq=5101 gfp=0x24280ca order=0 delay=20641
[ 6915.325244] MemAlloc: oom01(22014) seq=3633 gfp=0x24280ca order=0 delay=20502
----------
[19394.048063] MemAlloc-Info: 1 stalling task, 0 dying task, 0 victim task.
[19394.055562] MemAlloc: systemd-journal(22961) seq=151917 gfp=0x24201ca order=0 delay=10001
[19404.625516] MemAlloc-Info: 10 stalling task, 0 dying task, 0 victim task.
[19404.633107] MemAlloc: auditd(783) seq=615 gfp=0x24201ca order=0 delay=15101
[19404.640877] MemAlloc: irqbalance(806) seq=8107 gfp=0x24201ca order=0 delay=18440
[19404.649135] MemAlloc: NetworkManager(820) seq=10854 gfp=0x24200ca order=0 delay=19527
[19404.657874] MemAlloc: gssproxy(826) seq=586 gfp=0x24201ca order=0 delay=18487
[19404.665841] MemAlloc: tuned(1337) seq=40098 gfp=0x24201ca order=0 delay=19900
[19404.673805] MemAlloc: crond(2242) seq=5612 gfp=0x24201ca order=0 delay=15329
[19404.681674] MemAlloc: systemd-journal(22961) seq=151917 gfp=0x24201ca order=0 delay=20579
[19404.690796] MemAlloc: sendmail(31908) seq=7256 gfp=0x24200ca order=0 delay=17633
[19404.699051] MemAlloc: kworker/2:2(32161) seq=9 gfp=0x2400000 order=0 delay=19889
[19404.707306] MemAlloc: oom01(32704) seq=6391 gfp=0x24200ca order=0 delay=19164 exiting
----------

Does somebody know whether GFP_HIGHUSER_MOVABLE depend on workqueue status?

   * GFP_HIGHUSER_MOVABLE is for userspace allocations that the kernel does not
   *   need direct access to but can use kmap() when access is required. They
   *   are expected to be movable via page reclaim or page migration. Typically,
   *   pages on the LRU would also be allocated with GFP_HIGHUSER_MOVABLE.

I don't have reproducer environment. But if this problem involves workqueue,
running kernel module below which requests GFP_NOIO allocation more frequently
than disk_check_events() does might help reproducing this problem.

---------- test/wq_test.c ----------
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/kthread.h>
#include <linux/delay.h>

static void wq_test_fn(struct work_struct *work);
static struct task_struct *task;
static bool pending;
static DECLARE_WORK(wq_test_work, wq_test_fn);

static void wq_test_fn(struct work_struct *unused)
{
	kfree(kmalloc(PAGE_SIZE, GFP_NOIO));
	pending = false;
}

static int wq_test_thread(void *unused)
{
	while (!kthread_should_stop()) {
		msleep(HZ / 10);
		pending = true;
		queue_work(system_freezable_power_efficient_wq, &wq_test_work);
		while (pending)
			msleep(1);
	}
	return 0;
}

static int __init wq_test_init(void)
{
	task = kthread_run(wq_test_thread, NULL, "wq_test");
	return IS_ERR(task) ? -ENOMEM : 0;
}

static void __exit wq_test_exit(void)
{
	kthread_stop(task);
	ssleep(1);
}

module_init(wq_test_init);
module_exit(wq_test_exit);
MODULE_LICENSE("GPL");
---------- test/wq_test.c ----------
---------- test/Makefile ----------
obj-m += wq_test.o
---------- test/Makefile ----------

$ make SUBDIRS=$PWD/test
# insmod test/wq_test.ko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
