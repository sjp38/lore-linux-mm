Date: Thu, 24 Jan 2008 13:26:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 8/8] mem_notify v5: support fasync feature
In-Reply-To: <20080124130348.1760.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080124130348.1760.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080124132452.1778.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

implement FASYNC capability to /dev/mem_notify.

<usage example>
        fd = open("/dev/mem_notify", O_RDONLY);

	fcntl(fd, F_SETOWN, getpid());

	flags = fcntl(fd, F_GETFL);
	fcntl(fd, F_SETFL, flags|FASYNC);  /* when low memory, receive SIGIO */
</usage example>


ChangeLog
	v5: new



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/mem_notify.c |   95 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 90 insertions(+), 5 deletions(-)

Index: b/mm/mem_notify.c
===================================================================
--- a/mm/mem_notify.c	2008-01-23 23:09:08.000000000 +0900
+++ b/mm/mem_notify.c	2008-01-23 23:09:27.000000000 +0900
@@ -23,18 +23,58 @@
 #define PROC_WAKEUP_GUARD  (10*HZ)
 
 struct mem_notify_file_info {
-	unsigned long last_proc_notify;
+	unsigned long     last_proc_notify;
+	struct file      *file;
+
+	struct list_head  fa_list;
+	int	          fa_fd;
 };
 
 static DECLARE_WAIT_QUEUE_HEAD(mem_wait);
 static atomic_long_t nr_under_memory_pressure_zones = ATOMIC_LONG_INIT(0);
 static atomic_t nr_watcher_task = ATOMIC_INIT(0);
+static LIST_HEAD(mem_notify_fasync_list);
+static DEFINE_SPINLOCK(mem_notify_fasync_lock);
+static atomic_t nr_fasync_task = ATOMIC_INIT(0);
 
 atomic_long_t last_mem_notify = ATOMIC_LONG_INIT(INITIAL_JIFFIES);
 
+
+static void mem_notify_kill_fasync_nr(int sig, int band, int nr)
+{
+	struct mem_notify_file_info *iter, *saved_iter;
+	LIST_HEAD(l_fired);
+
+	if (!nr)
+		return;
+
+	spin_lock(&mem_notify_fasync_lock);
+
+	list_for_each_entry_safe_reverse(iter, saved_iter, &mem_notify_fasync_list, fa_list) {
+		struct fown_struct * fown;
+
+		fown = &iter->file->f_owner;
+		if (!(sig == SIGURG && fown->signum == 0))
+			send_sigio(fown, iter->fa_fd, band);
+
+		list_del(&iter->fa_list);
+		list_add(&iter->fa_list, &l_fired);
+		if(!--nr)
+			break;
+	}
+
+	/* rotate moving for FIFO wakeup */
+	list_splice(&l_fired, &mem_notify_fasync_list);
+
+	spin_unlock(&mem_notify_fasync_lock);
+}
+
+
 void __memory_pressure_notify(struct zone* zone, int pressure)
 {
 	int nr_wakeup;
+	int nr_poll_wakeup = 0;
+	int nr_fasync_wakeup = 0;
 	int flags;
 
 	spin_lock_irqsave(&mem_wait.lock, flags);
@@ -47,13 +87,18 @@ void __memory_pressure_notify(struct zon
 
 	if (pressure) {
 		int nr_watcher = atomic_read(&nr_watcher_task);
+		int nr_fasync = atomic_read(&nr_fasync_task);
 
 		nr_wakeup = (nr_watcher >> 4) + 1;
 		if (unlikely(nr_wakeup > 100))
 			nr_wakeup = 100;
 
+ 		nr_fasync_wakeup = nr_wakeup * nr_fasync/nr_watcher;
+ 		nr_poll_wakeup = nr_wakeup - nr_fasync_wakeup;
+
 		atomic_long_set(&last_mem_notify, jiffies);
-		wake_up_locked_nr(&mem_wait, nr_wakeup);
+		wake_up_locked_nr(&mem_wait, nr_poll_wakeup);
+ 		mem_notify_kill_fasync_nr(SIGIO, POLL_IN, nr_fasync_wakeup);
 	}
 
 	spin_unlock_irqrestore(&mem_wait.lock, flags);
@@ -71,6 +116,9 @@ static int mem_notify_open(struct inode 
 	}
 
 	info->last_proc_notify = INITIAL_JIFFIES;
+	INIT_LIST_HEAD(&info->fa_list);
+	info->file = file;
+	info->fa_fd = -1;
 	file->private_data = info;
 	atomic_inc(&nr_watcher_task);
 out:
@@ -79,7 +127,16 @@ out:
 
 static int mem_notify_release(struct inode *inode, struct file *file)
 {
-	kfree(file->private_data);
+	struct mem_notify_file_info *info = file->private_data;
+
+	spin_lock(&mem_notify_fasync_lock);
+	if (!list_empty(&info->fa_list)) {
+		list_del(&info->fa_list);
+		atomic_dec(&nr_fasync_task);
+	}
+	spin_unlock(&mem_notify_fasync_lock);
+
+	kfree(info);
 	atomic_dec(&nr_watcher_task);
 	return 0;
 }
@@ -106,9 +163,37 @@ out:
 	return retval;
 }
 
+static int mem_notify_fasync(int fd, struct file *filp, int on)
+{
+	struct mem_notify_file_info *info = filp->private_data;
+	int result = 0;
+
+	spin_lock(&mem_notify_fasync_lock);
+	if (on) {
+		if (list_empty(&info->fa_list)) {
+			info->fa_fd = fd;
+			list_add(&info->fa_list, &mem_notify_fasync_list);
+			result = 1;
+		} else {
+			info->fa_fd = fd;
+		}
+	} else {
+		if (!list_empty(&info->fa_list)) {
+			list_del_init(&info->fa_list);
+			info->fa_fd = -1;
+			result = -1;
+		}
+	}
+	if (result != 0)
+		atomic_add(result, &nr_fasync_task);
+	spin_unlock(&mem_notify_fasync_lock);
+	return abs(result);
+}
+
 struct file_operations mem_notify_fops = {
-	.open = mem_notify_open,
+	.open    = mem_notify_open,
 	.release = mem_notify_release,
-	.poll = mem_notify_poll,
+	.poll    = mem_notify_poll,
+	.fasync  = mem_notify_fasync,
 };
 EXPORT_SYMBOL(mem_notify_fops);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
