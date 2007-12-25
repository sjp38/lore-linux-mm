Date: Tue, 25 Dec 2007 19:31:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][patch 2/2] mem notifications v3 improvement for large system
In-Reply-To: <20071225164832.D267.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071225164832.D267.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20071225192625.D273.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2nd improvement
  - add wakeup rate control

1. run >10000 process test
   console1# LANG=C; while [ 1 ] ;do sleep 1; date; vmstat 1 1 -S M -a; done
   console2# sh m.sh 12500

result
   - swap out unoccured.
   - time leap unoccured.
   - max runqueue shrink about 1/10.
   - too much freed unoccured.

very good.





Wed Dec 26 04:23:10 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 4  0      0   4122    190   9890    0    0   207    15  297  113 17  6 75  2  0
Wed Dec 26 04:23:11 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 3  0      0   3038    190  10809    0    0   206    15  299  117 17  7 75  2  0
Wed Dec 26 04:23:12 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0   2004    190  11687    0    0   206    15  301  120 17  7 75  2  0
Wed Dec 26 04:23:13 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0   1009    190  12530    0    0   205    15  303  124 17  7 74  2  0
Wed Dec 26 04:23:14 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0     69    190  13327    0    0   204    15  305  127 17  7 74  2  0
Wed Dec 26 04:23:15 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
1109  0      0     88    199  13294    0    0   203    15  404  297 17  7 74  2  0
Wed Dec 26 04:23:16 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
285  0      0     86    199  13295    0    0   203    15  404  541 17  7 74  2  0
Wed Dec 26 04:23:17 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
258  0      0     88    199  13294    0    0   202    15  404  779 17  7 74  2  0
Wed Dec 26 04:23:18 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
185  0      0     88    199  13294    0    0   201    15  403 1012 17  7 74  2  0
Wed Dec 26 04:23:19 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
454  0      0     87    199  13296    0    0   200    15  403 1240 17  7 74  2  0
Wed Dec 26 04:23:21 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
216  0      0     87    199  13295    0    0   200    15  403 1463 17  7 74  2  0
Wed Dec 26 04:23:22 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
402  0      0     87    199  13297    0    0   199    15  403 1681 17  7 74  2  0
Wed Dec 26 04:23:23 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
716  0      0     86    199  13293    0    0   198    15  403 1893 17  7 74  2  0
Wed Dec 26 04:23:24 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
131  0      0     86    199  13294    0    0   197    15  402 2101 17  7 74  2  0
Wed Dec 26 04:23:25 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
417  0      0     87    199  13294    0    0   197    14  402 2301 17  8 74  2  0
Wed Dec 26 04:23:26 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
42  0      0     87    199  13294    0    0   196    14  402 2502 17  8 74  2  0
Wed Dec 26 04:23:27 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
968  0      0     88    199  13291    0    0   195    14  402 2697 17  8 74  2  0
Wed Dec 26 04:23:28 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
335  0      0     86    199  13295    0    0   195    14  402 2887 17  8 74  2  0
Wed Dec 26 04:23:29 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
386  0      0     87    199  13293    0    0   194    14  401 3071 17  8 74  2  0
Wed Dec 26 04:23:30 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
658  0      0     89    199  13292    0    0   193    14  401 3254 17  8 74  2  0
Wed Dec 26 04:23:31 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
72  0      0     87    199  13295    0    0   192    14  401 3439 16  8 74  2  0
Wed Dec 26 04:23:32 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
697  0      0     86    199  13295    0    0   192    14  401 3612 16  8 74  2  0
Wed Dec 26 04:23:33 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
289  0      0     87    199  13293    0    0   191    14  400 3780 16  8 74  2  0
Wed Dec 26 04:23:34 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
633  0      0     87    199  13294    0    0   190    14  400 3944 16  8 74  2  0
Wed Dec 26 04:23:35 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0     86    199  13295    0    0   190    14  400 4101 16  8 74  2  0
Wed Dec 26 04:23:36 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
94  1      0     88    199  13293    0    0   189    14  400 4253 16  8 74  2  0
Wed Dec 26 04:23:37 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
384  0      0     88    199  13293    0    0   188    14  400 4402 16  8 74  2  0
Wed Dec 26 04:23:38 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
256  0      0     86    199  13293    0    0   188    14  399 4546 16  8 74  2  0
Wed Dec 26 04:23:39 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     90    199  13288    0    0   187    14  399 4686 16  8 74  2  0
Wed Dec 26 04:23:40 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     90    199  13288    0    0   187    14  398 4822 16  8 74  2  0
Wed Dec 26 04:23:41 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  1      0     90    199  13288    0    0   186    14  398 4953 16  8 74  2  0
Wed Dec 26 04:23:42 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
289  0      0     91    199  13288    0    0   185    14  397 5077 16  8 74  2  0



$ quilt diff
Index: linux-2.6.23-mem_notify_v3/mm/mem_notify.c
===================================================================
--- linux-2.6.23-mem_notify_v3.orig/mm/mem_notify.c
+++ linux-2.6.23-mem_notify_v3/mm/mem_notify.c
@@ -12,6 +12,9 @@
 #include <linux/vmstat.h>
 #include <linux/percpu.h>
 #include <linux/timer.h>
+#include <linux/delay.h>
+
+#define MSLEEP_BONUS_SHIFT 4

 struct mem_notify_file_info {
         long          last_event;
@@ -20,7 +23,9 @@ struct mem_notify_file_info {
 atomic_t mem_notify_event = ATOMIC_INIT(0);

 static DECLARE_WAIT_QUEUE_HEAD(mem_wait);
-static DEFINE_PER_CPU(unsigned long, last_mem_notify) = INITIAL_JIFFIES;
+static atomic_long_t last_mem_notify = ATOMIC_LONG_INIT(INITIAL_JIFFIES);
+static atomic_long_t last_task_wakeup = ATOMIC_LONG_INIT(INITIAL_JIFFIES);
+static atomic_t mem_notify_timeout_bonus = ATOMIC_INIT(0);

 /* maximum 5 notifications per second per cpu */
 void mem_notify_userspace(void)
@@ -28,10 +33,10 @@ void mem_notify_userspace(void)
        unsigned long target;
        unsigned long now = jiffies;

-       target = __get_cpu_var(last_mem_notify) + (HZ/5);
+       target = atomic_long_read(&last_mem_notify) + (HZ/5);

        if (time_after(now, target)) {
-               __get_cpu_var(last_mem_notify) = now;
+               atomic_long_set(&last_mem_notify, now);
                atomic_inc(&mem_notify_event);
                wake_up(&mem_wait);
        }
@@ -68,12 +73,35 @@ static unsigned int mem_notify_poll(stru
        struct zone *zone;
        int pages_high, pages_free, pages_reserve;
         struct mem_notify_file_info *file_info = file->private_data;
+       unsigned long bonus;
+       unsigned long now;
+       unsigned long last;

        poll_wait(file, &mem_wait, wait);

         if (file_info->last_event == atomic_read(&mem_notify_event))
                 goto out;

+retry:
+       /* Ugly trick:
+          when too many task wakeup,
+          control function exit rate for prevent too much freed.
+       */
+       now = jiffies;
+       last = (unsigned long)atomic_long_read(&last_task_wakeup);
+        if (time_before_eq(now, last)) {
+               bonus = atomic_read(&mem_notify_timeout_bonus) >>
+                       MSLEEP_BONUS_SHIFT;
+                msleep_interruptible(1 + bonus);
+               set_current_state(TASK_INTERRUPTIBLE);
+                if (signal_pending(current))
+                        goto out;
+                atomic_inc(&mem_notify_timeout_bonus);
+                goto retry;
+        }
+        atomic_set(&mem_notify_timeout_bonus, 0);
+        atomic_long_set(&last_task_wakeup, now);
+
        /* check if its not a spurious/stale notification */
        pages_high = pages_free = pages_reserve = 0;
        for_each_zone(zone) {


/kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
