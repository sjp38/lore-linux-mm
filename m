Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: [PATCH v2] ksm: React on changing "sleep_millisecs" parameter faster
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 11 Dec 2018 13:26:59 +0300
Message-ID: <154452399396.4921.3418365102240528000.stgit@localhost.localdomain>
In-Reply-To: <20181211100346.GE2342@uranus.lan>
References: <20181211100346.GE2342@uranus.lan>
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

v2: Use wait_event_interruptible_timeout() instead of unconditional
    schedule_timeout().
---
 mm/ksm.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index daa14db01e4d..b8e0b8413d51 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -296,6 +296,7 @@ static unsigned long ksm_run = KSM_RUN_STOP;
 static void wait_while_offlining(void);
 
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
+static DECLARE_WAIT_QUEUE_HEAD(ksm_iter_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
 static DEFINE_SPINLOCK(ksm_mmlist_lock);
 
@@ -2412,6 +2413,8 @@ static int ksmd_should_run(void)
 
 static int ksm_scan_thread(void *nothing)
 {
+	unsigned int sleep_ms;
+
 	set_freezable();
 	set_user_nice(current, 5);
 
@@ -2420,13 +2423,15 @@ static int ksm_scan_thread(void *nothing)
 		wait_while_offlining();
 		if (ksmd_should_run())
 			ksm_do_scan(ksm_thread_pages_to_scan);
+		sleep_ms = ksm_thread_sleep_millisecs;
 		mutex_unlock(&ksm_thread_mutex);
 
 		try_to_freeze();
 
 		if (ksmd_should_run()) {
-			schedule_timeout_interruptible(
-				msecs_to_jiffies(ksm_thread_sleep_millisecs));
+			wait_event_interruptible_timeout(ksm_iter_wait,
+					sleep_ms != ksm_thread_sleep_millisecs,
+					msecs_to_jiffies(sleep_ms));
 		} else {
 			wait_event_freezable(ksm_thread_wait,
 				ksmd_should_run() || kthread_should_stop());
@@ -2844,7 +2849,10 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
 	if (err || msecs > UINT_MAX)
 		return -EINVAL;
 
+	mutex_lock(&ksm_thread_mutex);
 	ksm_thread_sleep_millisecs = msecs;
+	mutex_unlock(&ksm_thread_mutex);
+	wake_up_interruptible(&ksm_iter_wait);
 
 	return count;
 }
