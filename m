Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 2/4] kernel.h: Add non_block_start/end()
Date: Mon, 10 Dec 2018 11:36:39 +0100
Message-Id: <20181210103641.31259-3-daniel.vetter@ffwll.ch>
In-Reply-To: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: Intel Graphics Development <intel-gfx@lists.freedesktop.org>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>
List-ID: <linux-mm.kvack.org>

In some special cases we must not block, but there's not a
spinlock, preempt-off, irqs-off or similar critical section already
that arms the might_sleep() debug checks. Add a non_block_start/end()
pair to annotate these.

This will be used in the oom paths of mmu-notifiers, where blocking is
not allowed to make sure there's forward progress.

Suggested by Michal Hocko.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/kernel.h | 10 +++++++++-
 include/linux/sched.h  |  4 ++++
 kernel/sched/core.c    |  6 +++---
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index d6aac75b51ba..c2cf31515b3d 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -251,7 +251,9 @@ extern int _cond_resched(void);
  * might_sleep - annotation for functions that can sleep
  *
  * this macro will print a stack trace if it is executed in an atomic
- * context (spinlock, irq-handler, ...).
+ * context (spinlock, irq-handler, ...). Additional sections where blocking is
+ * not allowed can be annotated with non_block_start() and non_block_end()
+ * pairs.
  *
  * This is a useful debugging help to be able to catch problems early and not
  * be bitten later when the calling function happens to sleep when it is not
@@ -260,6 +262,10 @@ extern int _cond_resched(void);
 # define might_sleep() \
 	do { __might_sleep(__FILE__, __LINE__, 0); might_resched(); } while (0)
 # define sched_annotate_sleep()	(current->task_state_change = 0)
+# define non_block_start() \
+	do { current->non_block_count++; } while (0)
+# define non_block_end() \
+	do { WARN_ON(current->non_block_count-- == 0); } while (0)
 #else
   static inline void ___might_sleep(const char *file, int line,
 				   int preempt_offset) { }
@@ -267,6 +273,8 @@ extern int _cond_resched(void);
 				   int preempt_offset) { }
 # define might_sleep() do { might_resched(); } while (0)
 # define sched_annotate_sleep() do { } while (0)
+# define non_block_start() do { } while (0)
+# define non_block_end() do { } while (0)
 #endif
 
 #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ecffd4e37453..41249dbf8f27 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -916,6 +916,10 @@ struct task_struct {
 	struct mutex_waiter		*blocked_on;
 #endif
 
+#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+	int				non_block_count;
+#endif
+
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned int			irq_events;
 	unsigned long			hardirq_enable_ip;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 6fedf3a98581..969d7a71f30c 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6113,7 +6113,7 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
 	rcu_sleep_check();
 
 	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
-	     !is_idle_task(current)) ||
+	     !is_idle_task(current) && !current->non_block_count) ||
 	    system_state == SYSTEM_BOOTING || system_state > SYSTEM_RUNNING ||
 	    oops_in_progress)
 		return;
@@ -6129,8 +6129,8 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
 		"BUG: sleeping function called from invalid context at %s:%d\n",
 			file, line);
 	printk(KERN_ERR
-		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
-			in_atomic(), irqs_disabled(),
+		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name: %s\n",
+			in_atomic(), irqs_disabled(), current->non_block_count,
 			current->pid, current->comm);
 
 	if (task_stack_end_corrupted(current))
-- 
2.20.0.rc1
