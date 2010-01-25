Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 51BA66B0047
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 10:18:13 -0500 (EST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/8] percpu: add __percpu sparse annotations to core kernel subsystems
Date: Tue, 26 Jan 2010 00:22:08 +0900
Message-Id: <1264432935-10453-2-git-send-email-tj@kernel.org>
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, axboe@kernel.dk, rusty@rustcorp.com.au, akpm@linux-foundation.org, ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com, aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk, davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org, mingo@redhat.com, fweisbec@gmail.com, dan.j.williams@intel.com, borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org, neilb@suse.de, cl@linux-foundation.org
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Dipankar Sarma <dipankar@in.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Add __percpu sparse annotations to core subsystems.

These annotations are to make sparse consider percpu variables to be
in a different address space and warn if accessed without going
through percpu accessors.  This patch doesn't affect normal builds.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: linux-mm@kvack.org
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Dipankar Sarma <dipankar@in.ibm.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Biederman <ebiederm@xmission.com>
---
 include/linux/blktrace_api.h   |    4 ++--
 include/linux/genhd.h          |    2 +-
 include/linux/kexec.h          |    2 +-
 include/linux/mmzone.h         |    2 +-
 include/linux/module.h         |    2 +-
 include/linux/percpu_counter.h |    2 +-
 include/linux/srcu.h           |    2 +-
 kernel/kexec.c                 |    2 +-
 kernel/sched.c                 |    4 ++--
 kernel/stop_machine.c          |    2 +-
 mm/percpu.c                    |   18 ++++++++++--------
 11 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/include/linux/blktrace_api.h b/include/linux/blktrace_api.h
index 3b73b99..416bf62 100644
--- a/include/linux/blktrace_api.h
+++ b/include/linux/blktrace_api.h
@@ -150,8 +150,8 @@ struct blk_user_trace_setup {
 struct blk_trace {
 	int trace_state;
 	struct rchan *rchan;
-	unsigned long *sequence;
-	unsigned char *msg_data;
+	unsigned long __percpu *sequence;
+	unsigned char __percpu *msg_data;
 	u16 act_mask;
 	u64 start_lba;
 	u64 end_lba;
diff --git a/include/linux/genhd.h b/include/linux/genhd.h
index 9717081..56b5051 100644
--- a/include/linux/genhd.h
+++ b/include/linux/genhd.h
@@ -101,7 +101,7 @@ struct hd_struct {
 	unsigned long stamp;
 	int in_flight[2];
 #ifdef	CONFIG_SMP
-	struct disk_stats *dkstats;
+	struct disk_stats __percpu *dkstats;
 #else
 	struct disk_stats dkstats;
 #endif
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index c356b69..03e8e8d 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -199,7 +199,7 @@ extern struct kimage *kexec_crash_image;
  */
 extern struct resource crashk_res;
 typedef u32 note_buf_t[KEXEC_NOTE_BYTES/4];
-extern note_buf_t *crash_notes;
+extern note_buf_t __percpu *crash_notes;
 extern u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
 extern size_t vmcoreinfo_size;
 extern size_t vmcoreinfo_max_size;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7874201..41acd4b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -301,7 +301,7 @@ struct zone {
 	unsigned long		min_unmapped_pages;
 	unsigned long		min_slab_pages;
 #endif
-	struct per_cpu_pageset	*pageset;
+	struct per_cpu_pageset __percpu *pageset;
 	/*
 	 * free areas of different sizes
 	 */
diff --git a/include/linux/module.h b/include/linux/module.h
index 7e74ae0..dd618eb 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -365,7 +365,7 @@ struct module
 
 	struct module_ref {
 		int count;
-	} *refptr;
+	} __percpu *refptr;
 #endif
 
 #ifdef CONFIG_CONSTRUCTORS
diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
index a7684a5..9bd103c 100644
--- a/include/linux/percpu_counter.h
+++ b/include/linux/percpu_counter.h
@@ -21,7 +21,7 @@ struct percpu_counter {
 #ifdef CONFIG_HOTPLUG_CPU
 	struct list_head list;	/* All percpu_counters are on a list */
 #endif
-	s32 *counters;
+	s32 __percpu *counters;
 };
 
 extern int percpu_counter_batch;
diff --git a/include/linux/srcu.h b/include/linux/srcu.h
index 4765d97..41eedcc 100644
--- a/include/linux/srcu.h
+++ b/include/linux/srcu.h
@@ -33,7 +33,7 @@ struct srcu_struct_array {
 
 struct srcu_struct {
 	int completed;
-	struct srcu_struct_array *per_cpu_ref;
+	struct srcu_struct_array __percpu *per_cpu_ref;
 	struct mutex mutex;
 };
 
diff --git a/kernel/kexec.c b/kernel/kexec.c
index a9a93d9..c769613 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -40,7 +40,7 @@
 #include <asm/sections.h>
 
 /* Per cpu memory for storing cpu states in case of system crash. */
-note_buf_t* crash_notes;
+note_buf_t __percpu *crash_notes;
 
 /* vmcoreinfo stuff */
 static unsigned char vmcoreinfo_data[VMCOREINFO_BYTES];
diff --git a/kernel/sched.c b/kernel/sched.c
index 4508fe7..512b10f 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -1566,7 +1566,7 @@ static unsigned long cpu_avg_load_per_task(int cpu)
 
 #ifdef CONFIG_FAIR_GROUP_SCHED
 
-static __read_mostly unsigned long *update_shares_data;
+static __read_mostly unsigned long __percpu *update_shares_data;
 
 static void __set_se_shares(struct sched_entity *se, unsigned long shares);
 
@@ -10668,7 +10668,7 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 struct cpuacct {
 	struct cgroup_subsys_state css;
 	/* cpuusage holds pointer to a u64-type object on every cpu */
-	u64 *cpuusage;
+	u64 __percpu *cpuusage;
 	struct percpu_counter cpustat[CPUACCT_STAT_NSTATS];
 	struct cpuacct *parent;
 };
diff --git a/kernel/stop_machine.c b/kernel/stop_machine.c
index 912823e..9bb9fb1 100644
--- a/kernel/stop_machine.c
+++ b/kernel/stop_machine.c
@@ -45,7 +45,7 @@ static int refcount;
 static struct workqueue_struct *stop_machine_wq;
 static struct stop_machine_data active, idle;
 static const struct cpumask *active_cpus;
-static void *stop_machine_work;
+static void __percpu *stop_machine_work;
 
 static void set_state(enum stopmachine_state newstate)
 {
diff --git a/mm/percpu.c b/mm/percpu.c
index b336638..768419d 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -80,13 +80,15 @@
 /* default addr <-> pcpu_ptr mapping, override in asm/percpu.h if necessary */
 #ifndef __addr_to_pcpu_ptr
 #define __addr_to_pcpu_ptr(addr)					\
-	(void *)((unsigned long)(addr) - (unsigned long)pcpu_base_addr	\
-		 + (unsigned long)__per_cpu_start)
+	(void __percpu *)((unsigned long)(addr) -			\
+			  (unsigned long)pcpu_base_addr	+		\
+			  (unsigned long)__per_cpu_start)
 #endif
 #ifndef __pcpu_ptr_to_addr
 #define __pcpu_ptr_to_addr(ptr)						\
-	(void *)((unsigned long)(ptr) + (unsigned long)pcpu_base_addr	\
-		 - (unsigned long)__per_cpu_start)
+	(void __force *)((unsigned long)(ptr) +				\
+			 (unsigned long)pcpu_base_addr -		\
+			 (unsigned long)__per_cpu_start)
 #endif
 
 struct pcpu_chunk {
@@ -1065,7 +1067,7 @@ static struct pcpu_chunk *alloc_pcpu_chunk(void)
  * RETURNS:
  * Percpu pointer to the allocated area on success, NULL on failure.
  */
-static void *pcpu_alloc(size_t size, size_t align, bool reserved)
+static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 {
 	static int warn_limit = 10;
 	struct pcpu_chunk *chunk;
@@ -1194,7 +1196,7 @@ fail_unlock_mutex:
  * RETURNS:
  * Percpu pointer to the allocated area on success, NULL on failure.
  */
-void *__alloc_percpu(size_t size, size_t align)
+void __percpu *__alloc_percpu(size_t size, size_t align)
 {
 	return pcpu_alloc(size, align, false);
 }
@@ -1215,7 +1217,7 @@ EXPORT_SYMBOL_GPL(__alloc_percpu);
  * RETURNS:
  * Percpu pointer to the allocated area on success, NULL on failure.
  */
-void *__alloc_reserved_percpu(size_t size, size_t align)
+void __percpu *__alloc_reserved_percpu(size_t size, size_t align)
 {
 	return pcpu_alloc(size, align, true);
 }
@@ -1267,7 +1269,7 @@ static void pcpu_reclaim(struct work_struct *work)
  * CONTEXT:
  * Can be called from atomic context.
  */
-void free_percpu(void *ptr)
+void free_percpu(void __percpu *ptr)
 {
 	void *addr;
 	struct pcpu_chunk *chunk;
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
