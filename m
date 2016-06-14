Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1666B025E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 18:14:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so3549352wmr.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:14:53 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id ul13si37463094wjb.63.2016.06.14.15.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 15:14:52 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id n184so1662429wmn.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:14:52 -0700 (PDT)
Date: Wed, 15 Jun 2016 00:21:39 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v3 3/4] Mark functions with the latent_entropy attribute
Message-Id: <20160615002139.c17793b44a7bee49fe69495c@gmail.com>
In-Reply-To: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

The latent_entropy gcc attribute can be only on functions and variables.
If it is on a function then the plugin will instrument it. If the attribute
is on a variable then the plugin will initialize it with a random value.
The variable must be an integer, an integer array type or a structure with integer fields.

These functions have been selected because they are init functions or
are called at random times or they have variable loops.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 block/blk-softirq.c          | 2 +-
 drivers/char/random.c        | 6 +++---
 fs/namespace.c               | 2 +-
 include/linux/compiler-gcc.h | 7 +++++++
 include/linux/compiler.h     | 4 ++++
 include/linux/fdtable.h      | 2 +-
 include/linux/genhd.h        | 2 +-
 include/linux/init.h         | 4 ++--
 include/linux/random.h       | 4 ++--
 kernel/fork.c                | 4 ++--
 kernel/rcu/tiny.c            | 2 +-
 kernel/rcu/tree.c            | 2 +-
 kernel/sched/fair.c          | 2 +-
 kernel/softirq.c             | 4 ++--
 kernel/time/timer.c          | 2 +-
 lib/irq_poll.c               | 2 +-
 lib/random32.c               | 2 +-
 mm/page_alloc.c              | 2 +-
 net/core/dev.c               | 4 ++--
 19 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/block/blk-softirq.c b/block/blk-softirq.c
index 53b1737..489eab8 100644
--- a/block/blk-softirq.c
+++ b/block/blk-softirq.c
@@ -18,7 +18,7 @@ static DEFINE_PER_CPU(struct list_head, blk_cpu_done);
  * Softirq action handler - move entries to local list and loop over them
  * while passing them to the queue registered handler.
  */
-static void blk_done_softirq(struct softirq_action *h)
+static __latent_entropy void blk_done_softirq(struct softirq_action *h)
 {
 	struct list_head *cpu_list, local_list;
 
diff --git a/drivers/char/random.c b/drivers/char/random.c
index 0158d3b..6cca3ed 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -443,9 +443,9 @@ struct entropy_store {
 };
 
 static void push_to_pool(struct work_struct *work);
-static __u32 input_pool_data[INPUT_POOL_WORDS];
-static __u32 blocking_pool_data[OUTPUT_POOL_WORDS];
-static __u32 nonblocking_pool_data[OUTPUT_POOL_WORDS];
+static __u32 input_pool_data[INPUT_POOL_WORDS] __latent_entropy;
+static __u32 blocking_pool_data[OUTPUT_POOL_WORDS] __latent_entropy;
+static __u32 nonblocking_pool_data[OUTPUT_POOL_WORDS] __latent_entropy;
 
 static struct entropy_store input_pool = {
 	.poolinfo = &poolinfo_table[0],
diff --git a/fs/namespace.c b/fs/namespace.c
index 4fb1691..eed930c 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2778,7 +2778,7 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
 	return new_ns;
 }
 
-struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
+__latent_entropy struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 		struct user_namespace *user_ns, struct fs_struct *new_fs)
 {
 	struct mnt_namespace *new_ns;
diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index e294939..0ef8329 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -188,6 +188,13 @@
 #endif /* GCC_VERSION >= 40300 */
 
 #if GCC_VERSION >= 40500
+
+#ifndef __CHECKER__
+#ifdef LATENT_ENTROPY_PLUGIN
+#define __latent_entropy __attribute__((latent_entropy))
+#endif
+#endif
+
 /*
  * Mark a position in code as unreachable.  This can be used to
  * suppress control flow warnings after asm blocks that transfer
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index 793c082..c65327b 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -425,6 +425,10 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
 # define __attribute_const__	/* unimplemented */
 #endif
 
+#ifndef __latent_entropy
+# define __latent_entropy
+#endif
+
 /*
  * Tell gcc if a function is cold. The compiler will assume any path
  * directly leading to the call is unlikely.
diff --git a/include/linux/fdtable.h b/include/linux/fdtable.h
index 5295535..9852c7e 100644
--- a/include/linux/fdtable.h
+++ b/include/linux/fdtable.h
@@ -105,7 +105,7 @@ struct files_struct *get_files_struct(struct task_struct *);
 void put_files_struct(struct files_struct *fs);
 void reset_files_struct(struct files_struct *);
 int unshare_files(struct files_struct **);
-struct files_struct *dup_fd(struct files_struct *, int *);
+struct files_struct *dup_fd(struct files_struct *, int *) __latent_entropy;
 void do_close_on_exec(struct files_struct *);
 int iterate_fd(struct files_struct *, unsigned,
 		int (*)(const void *, struct file *, unsigned),
diff --git a/include/linux/genhd.h b/include/linux/genhd.h
index 359a8e4..8736c1f 100644
--- a/include/linux/genhd.h
+++ b/include/linux/genhd.h
@@ -433,7 +433,7 @@ extern void disk_flush_events(struct gendisk *disk, unsigned int mask);
 extern unsigned int disk_clear_events(struct gendisk *disk, unsigned int mask);
 
 /* drivers/char/random.c */
-extern void add_disk_randomness(struct gendisk *disk);
+extern void add_disk_randomness(struct gendisk *disk) __latent_entropy;
 extern void rand_initialize_disk(struct gendisk *disk);
 
 static inline sector_t get_start_sect(struct block_device *bdev)
diff --git a/include/linux/init.h b/include/linux/init.h
index aedb254..8bbc9f4 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -39,7 +39,7 @@
 
 /* These are for everybody (although not all archs will actually
    discard it in modules) */
-#define __init		__section(.init.text) __cold notrace
+#define __init		__section(.init.text) __cold notrace __latent_entropy
 #define __initdata	__section(.init.data)
 #define __initconst	__constsection(.init.rodata)
 #define __exitdata	__section(.exit.data)
@@ -92,7 +92,7 @@
 #define __exit          __section(.exit.text) __exitused __cold notrace
 
 /* Used for MEMORY_HOTPLUG */
-#define __meminit        __section(.meminit.text) __cold notrace
+#define __meminit        __section(.meminit.text) __cold notrace __latent_entropy
 #define __meminitdata    __section(.meminit.data)
 #define __meminitconst   __constsection(.meminit.rodata)
 #define __memexit        __section(.memexit.text) __exitused __cold notrace
diff --git a/include/linux/random.h b/include/linux/random.h
index 752e7df..d286d51 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -29,8 +29,8 @@ static inline void add_latent_entropy(void) {}
 #endif
 
 extern void add_input_randomness(unsigned int type, unsigned int code,
-				 unsigned int value);
-extern void add_interrupt_randomness(int irq, int irq_flags);
+				 unsigned int value) __latent_entropy;
+extern void add_interrupt_randomness(int irq, int irq_flags) __latent_entropy;
 
 extern void get_random_bytes(void *buf, int nbytes);
 extern int add_random_ready_callback(struct random_ready_callback *rdy);
diff --git a/kernel/fork.c b/kernel/fork.c
index d07d5a6..9fba65c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -406,7 +406,7 @@ free_tsk:
 }
 
 #ifdef CONFIG_MMU
-static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
+static __latent_entropy int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
 	struct vm_area_struct *mpnt, *tmp, *prev, **pprev;
 	struct rb_node **rb_link, *rb_parent;
@@ -1281,7 +1281,7 @@ init_task_pid(struct task_struct *task, enum pid_type type, struct pid *pid)
  * parts of the process environment (as per the clone
  * flags). The actual kick-off is left to the caller.
  */
-static struct task_struct *copy_process(unsigned long clone_flags,
+static __latent_entropy struct task_struct *copy_process(unsigned long clone_flags,
 					unsigned long stack_start,
 					unsigned long stack_size,
 					int __user *child_tidptr,
diff --git a/kernel/rcu/tiny.c b/kernel/rcu/tiny.c
index 944b1b4..1898559 100644
--- a/kernel/rcu/tiny.c
+++ b/kernel/rcu/tiny.c
@@ -170,7 +170,7 @@ static void __rcu_process_callbacks(struct rcu_ctrlblk *rcp)
 				      false));
 }
 
-static void rcu_process_callbacks(struct softirq_action *unused)
+static __latent_entropy void rcu_process_callbacks(struct softirq_action *unused)
 {
 	__rcu_process_callbacks(&rcu_sched_ctrlblk);
 	__rcu_process_callbacks(&rcu_bh_ctrlblk);
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index c7f1bc4..8821fce 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3004,7 +3004,7 @@ __rcu_process_callbacks(struct rcu_state *rsp)
 /*
  * Do RCU core processing for the current CPU.
  */
-static void rcu_process_callbacks(struct softirq_action *unused)
+static __latent_entropy void rcu_process_callbacks(struct softirq_action *unused)
 {
 	struct rcu_state *rsp;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 218f8e8..cd745c2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -8205,7 +8205,7 @@ static void nohz_idle_balance(struct rq *this_rq, enum cpu_idle_type idle) { }
  * run_rebalance_domains is triggered when needed from the scheduler tick.
  * Also triggered for nohz idle balancing (with nohz_balancing_kick set).
  */
-static void run_rebalance_domains(struct softirq_action *h)
+static __latent_entropy void run_rebalance_domains(struct softirq_action *h)
 {
 	struct rq *this_rq = this_rq();
 	enum cpu_idle_type idle = this_rq->idle_balance ?
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 17caf4b..34033fd 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -482,7 +482,7 @@ void __tasklet_hi_schedule_first(struct tasklet_struct *t)
 }
 EXPORT_SYMBOL(__tasklet_hi_schedule_first);
 
-static void tasklet_action(struct softirq_action *a)
+static __latent_entropy void tasklet_action(struct softirq_action *a)
 {
 	struct tasklet_struct *list;
 
@@ -518,7 +518,7 @@ static void tasklet_action(struct softirq_action *a)
 	}
 }
 
-static void tasklet_hi_action(struct softirq_action *a)
+static __latent_entropy void tasklet_hi_action(struct softirq_action *a)
 {
 	struct tasklet_struct *list;
 
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 3a95f97..6008e7ae 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1414,7 +1414,7 @@ void update_process_times(int user_tick)
 /*
  * This function runs timers and the timer-tq in bottom half context.
  */
-static void run_timer_softirq(struct softirq_action *h)
+static __latent_entropy void run_timer_softirq(struct softirq_action *h)
 {
 	struct tvec_base *base = this_cpu_ptr(&tvec_bases);
 
diff --git a/lib/irq_poll.c b/lib/irq_poll.c
index 836f7db..63be749 100644
--- a/lib/irq_poll.c
+++ b/lib/irq_poll.c
@@ -74,7 +74,7 @@ void irq_poll_complete(struct irq_poll *iop)
 }
 EXPORT_SYMBOL(irq_poll_complete);
 
-static void irq_poll_softirq(struct softirq_action *h)
+static void __latent_entropy irq_poll_softirq(struct softirq_action *h)
 {
 	struct list_head *list = this_cpu_ptr(&blk_cpu_iopoll);
 	int rearm = 0, budget = irq_poll_budget;
diff --git a/lib/random32.c b/lib/random32.c
index 510d1ce..722d2b6 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -47,7 +47,7 @@ static inline void prandom_state_selftest(void)
 }
 #endif
 
-static DEFINE_PER_CPU(struct rnd_state, net_rand_state);
+static DEFINE_PER_CPU(struct rnd_state, net_rand_state) __latent_entropy;
 
 /**
  *	prandom_u32_state - seeded pseudo-random number generator.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d10324e..ffc4f4a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1235,7 +1235,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 }
 
 #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
-volatile u64 latent_entropy;
+volatile u64 latent_entropy __latent_entropy;
 EXPORT_SYMBOL(latent_entropy);
 #endif
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff43..723d3af 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3851,7 +3851,7 @@ int netif_rx_ni(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_rx_ni);
 
-static void net_tx_action(struct softirq_action *h)
+static __latent_entropy void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 
@@ -5175,7 +5175,7 @@ out_unlock:
 	return work;
 }
 
-static void net_rx_action(struct softirq_action *h)
+static __latent_entropy void net_rx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	unsigned long time_limit = jiffies + 2;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
