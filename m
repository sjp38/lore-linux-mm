Date: Tue, 25 Dec 2007 19:31:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][patch 1/2] mem notifications v3 improvement for large system
In-Reply-To: <20071225164832.D267.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071225164832.D267.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20071225182144.D26D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

I tried resolve too few notification problem.

mem_notify_status global variable mean wakeup 1 process.
it is too few.

improvement step1:
- add read method and wake up all process.

1. run >10000 process test
   console1# LANG=C; while [ 1 ] ;do sleep 1; date; vmstat 1 1 -S M -a; done
   console2# sh m.sh 12500

result:
 - wakeup all unoccur neither thundering herd nor soft lock-up.
 - no swap out occured.
 - but too much free ;-)
   in my test-case, over 5GB freed.


Wed Dec 26 03:19:20 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 7  0      0    605    209  12778    0    0   143    11 1458  183 14 10 76  1  0
Wed Dec 26 03:19:21 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 6  0      0   2687    209  10769    0    0   142    11 1459  188 14 10 75  1  0
Wed Dec 26 03:19:22 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0   4560    209   8968    0    0   142    11 1459  191 14 10 75  1  0
Wed Dec 26 03:19:23 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5857    209   7724    0    0   142    11 1457  192 14 10 75  1  0
Wed Dec 26 03:19:24 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5872    209   7724    0    0   141    11 1454  192 14 10 75  1  0
Wed Dec 26 03:19:25 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5884    209   7724    0    0   141    11 1451  192 14 10 75  1  0
Wed Dec 26 03:19:26 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5895    209   7724    0    0   140    11 1448  191 14 10 75  1  0
Wed Dec 26 03:19:27 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5904    209   7724    0    0   140    11 1445  191 14 10 75  1  0
Wed Dec 26 03:19:28 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5912    209   7724    0    0   140    11 1442  190 13 10 75  1  0
Wed Dec 26 03:19:29 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5920    209   7724    0    0   139    11 1439  190 13 10 75  1  0
Wed Dec 26 03:19:30 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  1      0   5929    209   7724    0    0   139    11 1436  189 13 10 75  1  0
Wed Dec 26 03:19:32 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5935    209   7724    0    0   139    11 1433  189 13 10 75  1  0
Wed Dec 26 03:19:33 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0      0   5940    209   7724    0    0   138    11 1430  188 13 10 75  1  0
Wed Dec 26 03:19:34 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  1      0   5948    209   7725    0    0   138    11 1427  188 13 10 75  1  0
Wed Dec 26 03:19:35 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0      0   5676    209   8005    0    0   138    11 1425  188 13 10 75  1  0
Wed Dec 26 03:19:36 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  1      0   5676    209   8006    0    0   137    11 1422  188 13 10 75  1  0


Index: linux-2.6.23-mem_notify_v3/mm/mem_notify.c
===================================================================
--- linux-2.6.23-mem_notify_v3.orig/mm/mem_notify.c
+++ linux-2.6.23-mem_notify_v3/mm/mem_notify.c
@@ -13,7 +13,11 @@
 #include <linux/percpu.h>
 #include <linux/timer.h>

-static unsigned long mem_notify_status = 0;
+struct mem_notify_file_info {
+        long          last_event;
+};
+
+atomic_t mem_notify_event = ATOMIC_INIT(0);

 static DECLARE_WAIT_QUEUE_HEAD(mem_wait);
 static DEFINE_PER_CPU(unsigned long, last_mem_notify) = INITIAL_JIFFIES;
@@ -28,53 +32,81 @@ void mem_notify_userspace(void)

        if (time_after(now, target)) {
                __get_cpu_var(last_mem_notify) = now;
-               mem_notify_status = 1;
+               atomic_inc(&mem_notify_event);
                wake_up(&mem_wait);
        }
 }

 static int mem_notify_open(struct inode *inode, struct file *file)
 {
-       return 0;
+        struct mem_notify_file_info *ptr;
+        int    err = 0;
+
+        ptr = kmalloc(sizeof(*ptr), GFP_KERNEL);
+        if (!ptr) {
+                err = -ENOMEM;
+                goto out;
+        }
+
+        ptr->last_event = atomic_read(&mem_notify_event);
+        file->private_data = ptr;
+
+out:
+        return err;
 }

 static int mem_notify_release(struct inode *inode, struct file *file)
 {
+        kfree(file->private_data);
+
        return 0;
 }

 static unsigned int mem_notify_poll(struct file *file, poll_table *wait)
 {
        unsigned int val = 0;
+       struct zone *zone;
+       int pages_high, pages_free, pages_reserve;
+        struct mem_notify_file_info *file_info = file->private_data;

        poll_wait(file, &mem_wait, wait);

-       if (mem_notify_status) {
-               struct zone *zone;
-               int pages_high, pages_free, pages_reserve;
-
-               mem_notify_status = 0;
-
-               /* check if its not a spurious/stale notification */
-               pages_high = pages_free = pages_reserve = 0;
-               for_each_zone(zone) {
-                       if (!populated_zone(zone) || is_highmem(zone))
-                               continue;
-                       pages_high += zone->pages_high;
-                       pages_free += zone_page_state(zone, NR_FREE_PAGES);
-                       pages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];
-               }
+        if (file_info->last_event == atomic_read(&mem_notify_event))
+                goto out;

-               if (pages_free < (pages_high+pages_reserve)*2)
-                       val = POLLIN;
+       /* check if its not a spurious/stale notification */
+       pages_high = pages_free = pages_reserve = 0;
+       for_each_zone(zone) {
+               if (!populated_zone(zone) || is_highmem(zone))
+                       continue;
+               pages_high += zone->pages_high;
+               pages_free += zone_page_state(zone, NR_FREE_PAGES);
+               pages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];
        }
-
+
+       if (pages_free < (pages_high+pages_reserve)*2)
+               val = POLLIN;
+
+out:
        return val;
 }

+static ssize_t mem_notify_read(struct file *file, char __user *buf,
+                               size_t count, loff_t *ppos)
+{
+        struct mem_notify_file_info *file_info = file->private_data;
+        if (!file_info)
+                return -EINVAL;
+
+        file_info->last_event = atomic_read(&mem_notify_event);
+
+        return 0;
+}
+
 struct file_operations mem_notify_fops = {
        .open = mem_notify_open,
        .release = mem_notify_release,
        .poll = mem_notify_poll,
+        .read = mem_notify_read,
 };
 EXPORT_SYMBOL(mem_notify_fops);






/kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
