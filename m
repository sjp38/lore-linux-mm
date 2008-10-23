Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9NF0J9q012628
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Oct 2008 00:00:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EB5EC2AC02C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 00:00:18 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B282712C048
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 00:00:18 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 71BAA1DB8040
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 00:00:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B1E1DB803B
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 00:00:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com> <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
Message-Id: <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Oct 2008 00:00:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Heiko,

> >> I think the following part of your patch:
> >>
> >>> diff --git a/mm/swap.c b/mm/swap.c
> >>> index fee6b97..bc58c13 100644
> >>> --- a/mm/swap.c
> >>> +++ b/mm/swap.c
> >>> @@ -278,7 +278,7 @@ void lru_add_drain(void)
> >>>       put_cpu();
> >>>  }
> >>>
> >>> -#ifdef CONFIG_NUMA
> >>> +#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
> >>>  static void lru_add_drain_per_cpu(struct work_struct *dummy)
> >>>  {
> >>>       lru_add_drain();
> >>
> >> causes this (allyesconfig on s390):
> >
> > hm,
> >
> > I don't think so.
> >
> > Actually, this patch has
> >   mmap_sem -> lru_add_drain_all() dependency.
> >
> > but its dependency already exist in another place.
> > example,
> >
> >  sys_move_pages()
> >      do_move_pages()  <- down_read(mmap_sem)
> >          migrate_prep()
> >               lru_add_drain_all()
> >
> > Thought?
> 
> ok. maybe I understand this issue.
> 
> This bug is caused by folloing dependencys.
> 
> some VM place has
>       mmap_sem -> kevent_wq
> 
> net/core/dev.c::dev_ioctl()  has
>      rtnl_lock  ->  mmap_sem        (*) almost ioctl has
> copy_from_user() and it cause page fault.
> 
> linkwatch_event has
>     kevent_wq -> rtnl_lock
> 
> 
> So, I think VM subsystem shouldn't use kevent_wq because many driver
> use ioctl and work queue combination.
> then drivers fixing isn't easy.
> 
> I'll make the patch soon.

My box can't reproduce this issue.
Could you please test on following patch?



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Heiko reported following lockdep warnings.


=================================================================================
causes this (allyesconfig on s390):

[17179587.988810] =======================================================
[17179587.988819] [ INFO: possible circular locking dependency detected ]
[17179587.988824] 2.6.27-06509-g2515ddc-dirty #190
[17179587.988827] -------------------------------------------------------
[17179587.988831] multipathd/3868 is trying to acquire lock:
[17179587.988834]  (events){--..}, at: [<0000000000157f82>] flush_work+0x42/0x124
[17179587.988850] 
[17179587.988851] but task is already holding lock:
[17179587.988854]  (&mm->mmap_sem){----}, at: [<00000000001c0be4>] sys_mlockall+0x5c/0xe0
[17179587.988865] 
[17179587.988866] which lock already depends on the new lock.
[17179587.988867] 
[17179587.988871] 
[17179587.988871] the existing dependency chain (in reverse order) is:
[17179587.988875] 
[17179587.988876] -> #3 (&mm->mmap_sem){----}:
[17179587.988883]        [<0000000000171a42>] __lock_acquire+0x143e/0x17c4
[17179587.988891]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.988896]        [<0000000000b2a532>] down_read+0x62/0xd8
[17179587.988905]        [<0000000000b2cc40>] do_dat_exception+0x14c/0x390
[17179587.988910]        [<0000000000114d36>] sysc_return+0x0/0x8
[17179587.988917]        [<00000000006c694a>] copy_from_user_mvcos+0x12/0x84
[17179587.988926]        [<00000000007335f0>] eql_ioctl+0x3e8/0x590
[17179587.988935]        [<00000000008b6230>] dev_ifsioc+0x29c/0x2c8
[17179587.988942]        [<00000000008b6874>] dev_ioctl+0x618/0x680
[17179587.988946]        [<00000000008a1a8c>] sock_ioctl+0x2b4/0x2c8
[17179587.988953]        [<00000000001f99a8>] vfs_ioctl+0x50/0xbc
[17179587.988960]        [<00000000001f9ee2>] do_vfs_ioctl+0x4ce/0x510
[17179587.988965]        [<00000000001f9f94>] sys_ioctl+0x70/0x98
[17179587.988970]        [<0000000000114d30>] sysc_noemu+0x10/0x16
[17179587.988975]        [<0000020000131286>] 0x20000131286
[17179587.988980] 
[17179587.988981] -> #2 (rtnl_mutex){--..}:
[17179587.988987]        [<0000000000171a42>] __lock_acquire+0x143e/0x17c4
[17179587.988993]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.988998]        [<0000000000b29ae8>] mutex_lock_nested+0x11c/0x31c
[17179587.989003]        [<00000000008bff1c>] rtnl_lock+0x30/0x40
[17179587.989009]        [<00000000008c144e>] linkwatch_event+0x26/0x6c
[17179587.989015]        [<0000000000157356>] run_workqueue+0x146/0x240
[17179587.989020]        [<000000000015756e>] worker_thread+0x11e/0x134
[17179587.989025]        [<000000000015cd8e>] kthread+0x6e/0xa4
[17179587.989030]        [<000000000010ad9a>] kernel_thread_starter+0x6/0xc
[17179587.989036]        [<000000000010ad94>] kernel_thread_starter+0x0/0xc
[17179587.989042] 
[17179587.989042] -> #1 ((linkwatch_work).work){--..}:
[17179587.989049]        [<0000000000171a42>] __lock_acquire+0x143e/0x17c4
[17179587.989054]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.989059]        [<0000000000157350>] run_workqueue+0x140/0x240
[17179587.989064]        [<000000000015756e>] worker_thread+0x11e/0x134
[17179587.989069]        [<000000000015cd8e>] kthread+0x6e/0xa4
[17179587.989074]        [<000000000010ad9a>] kernel_thread_starter+0x6/0xc
[17179587.989079]        [<000000000010ad94>] kernel_thread_starter+0x0/0xc
[17179587.989084] 
[17179587.989085] -> #0 (events){--..}:
[17179587.989091]        [<00000000001716ca>] __lock_acquire+0x10c6/0x17c4
[17179587.989096]        [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.989101]        [<0000000000157fb4>] flush_work+0x74/0x124
[17179587.989107]        [<0000000000158620>] schedule_on_each_cpu+0xec/0x138
[17179587.989112]        [<00000000001b0ab4>] lru_add_drain_all+0x2c/0x40
[17179587.989117]        [<00000000001c05ac>] __mlock_vma_pages_range+0xcc/0x2e8
[17179587.989123]        [<00000000001c0970>] mlock_fixup+0x1a8/0x280
[17179587.989128]        [<00000000001c0aec>] do_mlockall+0xa4/0xd4
[17179587.989133]        [<00000000001c0c36>] sys_mlockall+0xae/0xe0
[17179587.989138]        [<0000000000114d30>] sysc_noemu+0x10/0x16
[17179587.989142]        [<000002000025a466>] 0x2000025a466
[17179587.989147] 
[17179587.989148] other info that might help us debug this:
[17179587.989149] 
[17179587.989154] 1 lock held by multipathd/3868:
[17179587.989156]  #0:  (&mm->mmap_sem){----}, at: [<00000000001c0be4>] sys_mlockall+0x5c/0xe0
[17179587.989165] 
[17179587.989166] stack backtrace:
[17179587.989170] CPU: 0 Not tainted 2.6.27-06509-g2515ddc-dirty #190
[17179587.989174] Process multipathd (pid: 3868, task: 000000003978a298, ksp: 0000000039b23eb8)
[17179587.989178] 000000003978aa00 0000000039b238b8 0000000000000002 0000000000000000 
[17179587.989184]        0000000039b23958 0000000039b238d0 0000000039b238d0 00000000001060ee 
[17179587.989192]        0000000000000003 0000000000000000 0000000000000000 000000000000000b 
[17179587.989199]        0000000000000060 0000000000000008 0000000039b238b8 0000000039b23928 
[17179587.989207]        0000000000b30b50 00000000001060ee 0000000039b238b8 0000000039b23910 
[17179587.989216] Call Trace:
[17179587.989219] ([<0000000000106036>] show_trace+0xb2/0xd0)
[17179587.989225]  [<000000000010610c>] show_stack+0xb8/0xc8
[17179587.989230]  [<0000000000b27a96>] dump_stack+0xae/0xbc
[17179587.989234]  [<000000000017019e>] print_circular_bug_tail+0xee/0x100
[17179587.989240]  [<00000000001716ca>] __lock_acquire+0x10c6/0x17c4
[17179587.989245]  [<0000000000171e5c>] lock_acquire+0x94/0xbc
[17179587.989250]  [<0000000000157fb4>] flush_work+0x74/0x124
[17179587.989256]  [<0000000000158620>] schedule_on_each_cpu+0xec/0x138
[17179587.989261]  [<00000000001b0ab4>] lru_add_drain_all+0x2c/0x40
[17179587.989266]  [<00000000001c05ac>] __mlock_vma_pages_range+0xcc/0x2e8
[17179587.989271]  [<00000000001c0970>] mlock_fixup+0x1a8/0x280
[17179587.989276]  [<00000000001c0aec>] do_mlockall+0xa4/0xd4
[17179587.989281]  [<00000000001c0c36>] sys_mlockall+0xae/0xe0
[17179587.989286]  [<0000000000114d30>] sysc_noemu+0x10/0x16
[17179587.989290]  [<000002000025a466>] 0x2000025a466
[17179587.989294] INFO: lockdep is turned off.
=======================================================================================

It because following three circular locking dependency.

Some VM place has
      mmap_sem -> kevent_wq via lru_add_drain_all()

net/core/dev.c::dev_ioctl()  has
     rtnl_lock  ->  mmap_sem        (*) the ioctl has copy_from_user() and it can do page fault.

linkwatch_event has
     kevent_wq -> rtnl_lock


Actually, schedule_on_each_cpu() is very problematic function.
it introduce the dependency of all worker on keventd_wq, 
but we can't know what lock held by worker in kevend_wq because
keventd_wq is widely used out of kernel drivers too.

So, the task of any lock held shouldn't wait on keventd_wq.
Its task should use own special purpose work queue.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Nick Piggin <npiggin@suse.de>
CC: Hugh Dickins <hugh@veritas.com>,
CC: Andrew Morton <akpm@linux-foundation.org>,
CC: Linus Torvalds <torvalds@linux-foundation.org>,
CC: Rik van Riel <riel@redhat.com>,
CC: Lee Schermerhorn <lee.schermerhorn@hp.com>,

 linux-2.6.27-git10-vm_wq/include/linux/workqueue.h |    1 
 linux-2.6.27-git10-vm_wq/kernel/workqueue.c        |   37 +++++++++++++++++++++
 linux-2.6.27-git10-vm_wq/mm/swap.c                 |    8 +++-
 3 files changed, 45 insertions(+), 1 deletion(-)

Index: linux-2.6.27-git10-vm_wq/include/linux/workqueue.h
===================================================================
--- linux-2.6.27-git10-vm_wq.orig/include/linux/workqueue.h	2008-10-23 21:01:38.000000000 +0900
+++ linux-2.6.27-git10-vm_wq/include/linux/workqueue.h	2008-10-23 22:34:20.000000000 +0900
@@ -195,6 +195,7 @@ extern int schedule_delayed_work(struct 
 extern int schedule_delayed_work_on(int cpu, struct delayed_work *work,
 					unsigned long delay);
 extern int schedule_on_each_cpu(work_func_t func);
+int queue_work_on_each_cpu(struct workqueue_struct *wq, work_func_t func);
 extern int current_is_keventd(void);
 extern int keventd_up(void);
 
Index: linux-2.6.27-git10-vm_wq/kernel/workqueue.c
===================================================================
--- linux-2.6.27-git10-vm_wq.orig/kernel/workqueue.c	2008-10-23 21:01:38.000000000 +0900
+++ linux-2.6.27-git10-vm_wq/kernel/workqueue.c	2008-10-23 22:34:20.000000000 +0900
@@ -674,6 +674,8 @@ EXPORT_SYMBOL(schedule_delayed_work_on);
  * Returns -ve errno on failure.
  *
  * schedule_on_each_cpu() is very slow.
+ * caller should NOT held any lock, otherwise flush_work(keventd_wq) can
+ * cause dead-lock.
  */
 int schedule_on_each_cpu(work_func_t func)
 {
@@ -698,6 +700,41 @@ int schedule_on_each_cpu(work_func_t fun
 	return 0;
 }
 
+/**
+ * queue_work_on_each_cpu - call a function on each online CPU
+ *
+ * @wq:   the workqueue
+ * @func: the function to call
+ *
+ * Returns zero on success.
+ * Returns -ve errno on failure.
+ *
+ * similar to schedule_on_each_cpu(), but wq argument is there.
+ * queue_work_on_each_cpu() is very slow.
+ */
+int queue_work_on_each_cpu(struct workqueue_struct *wq, work_func_t func)
+{
+	int cpu;
+	struct work_struct *works;
+
+	works = alloc_percpu(struct work_struct);
+	if (!works)
+		return -ENOMEM;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct work_struct *work = per_cpu_ptr(works, cpu);
+
+		INIT_WORK(work, func);
+		queue_work_on(cpu, wq, work);
+	}
+	for_each_online_cpu(cpu)
+		flush_work(per_cpu_ptr(works, cpu));
+	put_online_cpus();
+	free_percpu(works);
+	return 0;
+}
+
 void flush_scheduled_work(void)
 {
 	flush_workqueue(keventd_wq);
Index: linux-2.6.27-git10-vm_wq/mm/swap.c
===================================================================
--- linux-2.6.27-git10-vm_wq.orig/mm/swap.c	2008-10-23 21:01:38.000000000 +0900
+++ linux-2.6.27-git10-vm_wq/mm/swap.c	2008-10-23 22:53:27.000000000 +0900
@@ -39,6 +39,8 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 
+static struct workqueue_struct *vm_wq __read_mostly;
+
 /*
  * This path almost never happens for VM activity - pages are normally
  * freed via pagevecs.  But it gets used by networking.
@@ -310,7 +312,7 @@ static void lru_add_drain_per_cpu(struct
  */
 int lru_add_drain_all(void)
 {
-	return schedule_on_each_cpu(lru_add_drain_per_cpu);
+	return queue_work_on_each_cpu(vm_wq, lru_add_drain_per_cpu);
 }
 
 #else
@@ -611,4 +613,8 @@ void __init swap_setup(void)
 #ifdef CONFIG_HOTPLUG_CPU
 	hotcpu_notifier(cpu_swap_callback, 0);
 #endif
+
+	vm_wq = create_workqueue("vm_work");
+	BUG_ON(!vm_wq);
+
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
