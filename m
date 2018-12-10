Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: [PATCH] ksm: React on changing "sleep_millisecs" parameter faster
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 10 Dec 2018 19:06:18 +0300
Message-ID: <154445792450.3178.16241744401215933502.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, mhocko@suse.com, ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com
List-ID: <linux-mm.kvack.org>

ksm thread unconditionally sleeps in ksm_scan_thread()
after each iteration:

	schedule_timeout_interruptible(
		msecs_to_jiffies(ksm_thread_sleep_millisecs))

The timeout is configured in /sys/kernel/mm/ksm/sleep_millisecs.

In case of user writes a big value by a mistake, and the thread
enters into schedule_timeout_interruptible(), it's not possible
to cancel the sleep by writing a new smaler value; the thread
is just sleeping till timeout expires.

The patch fixes the problem by waking the thread each time
after the value is updated.

This also may be useful for debug purposes; and also for userspace
daemons, which change sleep_millisecs value in dependence of
system load.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/ksm.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 723bd32d4dd0..31452122e52b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -294,6 +294,7 @@ static int ksm_nr_node_ids = 1;
 #define KSM_RUN_OFFLINE	4
 static unsigned long ksm_run = KSM_RUN_STOP;
 static void wait_while_offlining(void);
+static struct task_struct *ksm_task = NULL;
 
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
@@ -2435,8 +2436,9 @@ static int ksm_scan_thread(void *nothing)
 	set_freezable();
 	set_user_nice(current, 5);
 
+	mutex_lock(&ksm_thread_mutex);
+	ksm_task = current;
 	while (!kthread_should_stop()) {
-		mutex_lock(&ksm_thread_mutex);
 		wait_while_offlining();
 		if (ksmd_should_run())
 			ksm_do_scan(ksm_thread_pages_to_scan);
@@ -2451,7 +2453,10 @@ static int ksm_scan_thread(void *nothing)
 			wait_event_freezable(ksm_thread_wait,
 				ksmd_should_run() || kthread_should_stop());
 		}
+		mutex_lock(&ksm_thread_mutex);
 	}
+	ksm_task = NULL;
+	mutex_unlock(&ksm_thread_mutex);
 	return 0;
 }
 
@@ -2864,7 +2869,11 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
 	if (err || msecs > UINT_MAX)
 		return -EINVAL;
 
+	mutex_lock(&ksm_thread_mutex);
+	if (ksm_task)
+		wake_up_state(ksm_task, TASK_INTERRUPTIBLE);
 	ksm_thread_sleep_millisecs = msecs;
+	mutex_unlock(&ksm_thread_mutex);
 
 	return count;
 }
