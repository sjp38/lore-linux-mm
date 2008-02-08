Message-Id: <20080208233738.566954000@polaris-admin.engr.sgi.com>
References: <20080208233738.108449000@polaris-admin.engr.sgi.com>
Date: Fri, 08 Feb 2008 15:37:41 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 3/4] oprofile: change cpu_buffer from array to per_cpu variable
Content-Disposition: inline; filename=nr_cpus-in-cpu_buffer
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Philippe Elie <phil.el@wanadoo.fr>, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

Change cpu_buffer from array to per_cpu variable in
oprofile functions.

Based on linux-2.6.git + x86.git

Cc: Philippe Elie <phil.el@wanadoo.fr>
Cc: oprofile-list@lists.sf.net
Signed-off-by: Mike Travis <travis@sgi.com>
---
 drivers/oprofile/buffer_sync.c    |    2 +-
 drivers/oprofile/cpu_buffer.c     |   16 ++++++++--------
 drivers/oprofile/cpu_buffer.h     |    3 ++-
 drivers/oprofile/oprofile_stats.c |    4 ++--
 4 files changed, 13 insertions(+), 12 deletions(-)

--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -494,7 +494,7 @@ typedef enum {
  */
 void sync_buffer(int cpu)
 {
-	struct oprofile_cpu_buffer * cpu_buf = &cpu_buffer[cpu];
+	struct oprofile_cpu_buffer * cpu_buf = &per_cpu(cpu_buffer, cpu);
 	struct mm_struct *mm = NULL;
 	struct task_struct * new;
 	unsigned long cookie = 0;
--- a/drivers/oprofile/cpu_buffer.c
+++ b/drivers/oprofile/cpu_buffer.c
@@ -27,7 +27,7 @@
 #include "buffer_sync.h"
 #include "oprof.h"
 
-struct oprofile_cpu_buffer cpu_buffer[NR_CPUS] __cacheline_aligned;
+DEFINE_PER_CPU_SHARED_ALIGNED(struct oprofile_cpu_buffer, cpu_buffer);
 
 static void wq_sync_buffer(struct work_struct *work);
 
@@ -39,7 +39,7 @@ void free_cpu_buffers(void)
 	int i;
  
 	for_each_online_cpu(i)
-		vfree(cpu_buffer[i].buffer);
+		vfree(per_cpu(cpu_buffer, i).buffer);
 }
 
 int alloc_cpu_buffers(void)
@@ -49,7 +49,7 @@ int alloc_cpu_buffers(void)
 	unsigned long buffer_size = fs_cpu_buffer_size;
  
 	for_each_online_cpu(i) {
-		struct oprofile_cpu_buffer * b = &cpu_buffer[i];
+		struct oprofile_cpu_buffer * b = &per_cpu(cpu_buffer, i);
  
 		b->buffer = vmalloc_node(sizeof(struct op_sample) * buffer_size,
 			cpu_to_node(i));
@@ -83,7 +83,7 @@ void start_cpu_work(void)
 	work_enabled = 1;
 
 	for_each_online_cpu(i) {
-		struct oprofile_cpu_buffer * b = &cpu_buffer[i];
+		struct oprofile_cpu_buffer * b = &per_cpu(cpu_buffer, i);
 
 		/*
 		 * Spread the work by 1 jiffy per cpu so they dont all
@@ -100,7 +100,7 @@ void end_cpu_work(void)
 	work_enabled = 0;
 
 	for_each_online_cpu(i) {
-		struct oprofile_cpu_buffer * b = &cpu_buffer[i];
+		struct oprofile_cpu_buffer * b = &per_cpu(cpu_buffer, i);
 
 		cancel_delayed_work(&b->work);
 	}
@@ -227,7 +227,7 @@ static void oprofile_end_trace(struct op
 void oprofile_add_ext_sample(unsigned long pc, struct pt_regs * const regs,
 				unsigned long event, int is_kernel)
 {
-	struct oprofile_cpu_buffer * cpu_buf = &cpu_buffer[smp_processor_id()];
+	struct oprofile_cpu_buffer * cpu_buf = &__get_cpu_var(cpu_buffer);
 
 	if (!backtrace_depth) {
 		log_sample(cpu_buf, pc, is_kernel, event);
@@ -254,13 +254,13 @@ void oprofile_add_sample(struct pt_regs 
 
 void oprofile_add_pc(unsigned long pc, int is_kernel, unsigned long event)
 {
-	struct oprofile_cpu_buffer * cpu_buf = &cpu_buffer[smp_processor_id()];
+	struct oprofile_cpu_buffer * cpu_buf = &__get_cpu_var(cpu_buffer);
 	log_sample(cpu_buf, pc, is_kernel, event);
 }
 
 void oprofile_add_trace(unsigned long pc)
 {
-	struct oprofile_cpu_buffer * cpu_buf = &cpu_buffer[smp_processor_id()];
+	struct oprofile_cpu_buffer * cpu_buf = &__get_cpu_var(cpu_buffer);
 
 	if (!cpu_buf->tracing)
 		return;
--- a/drivers/oprofile/cpu_buffer.h
+++ b/drivers/oprofile/cpu_buffer.h
@@ -14,6 +14,7 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/cache.h>
+#include <linux/sched.h>
  
 struct task_struct;
  
@@ -47,7 +48,7 @@ struct oprofile_cpu_buffer {
 	struct delayed_work work;
 } ____cacheline_aligned;
 
-extern struct oprofile_cpu_buffer cpu_buffer[];
+DECLARE_PER_CPU(struct oprofile_cpu_buffer, cpu_buffer);
 
 void cpu_buffer_reset(struct oprofile_cpu_buffer * cpu_buf);
 
--- a/drivers/oprofile/oprofile_stats.c
+++ b/drivers/oprofile/oprofile_stats.c
@@ -23,7 +23,7 @@ void oprofile_reset_stats(void)
 	int i;
  
 	for_each_possible_cpu(i) {
-		cpu_buf = &cpu_buffer[i]; 
+		cpu_buf = &per_cpu(cpu_buffer, i);
 		cpu_buf->sample_received = 0;
 		cpu_buf->sample_lost_overflow = 0;
 		cpu_buf->backtrace_aborted = 0;
@@ -49,7 +49,7 @@ void oprofile_create_stats_files(struct 
 		return;
 
 	for_each_possible_cpu(i) {
-		cpu_buf = &cpu_buffer[i]; 
+		cpu_buf = &per_cpu(cpu_buffer, i);
 		snprintf(buf, 10, "cpu%d", i);
 		cpudir = oprofilefs_mkdir(sb, dir, buf);
  

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
