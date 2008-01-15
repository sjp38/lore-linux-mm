Date: Tue, 15 Jan 2008 09:59:12 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 1/5] introduce poll_wait_exclusive() new API 
In-Reply-To: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080115095755.1172.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

There are 2 way of adding item to wait_queue,
  1. add_wait_queue()
  2. add_wait_queue_exclusive()
and add_wait_queue_exclusive() is very useful API.

unforunately, poll_wait_exclusive() against poll_wait() doesn't exist. 
it means there is no way that wake up only 1 process where polled.
wake_up() is wake up all sleeping process by poll_wait(), not 1 process.

this patch introduce poll_wait_exclusive() new API for allow wake up only 1 process.

<example of usage>
unsigned int kosaki_poll(struct file *file,
		         struct poll_table_struct *wait)
{
	poll_wait_exclusive(file, &kosaki_wait_queue, wait);
	if (data_exist)
		return POLLIN | POLLRDNORM;
	return 0;
}


Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 fs/eventpoll.c       |    7 +++++--
 fs/select.c          |    9 ++++++---
 include/linux/poll.h |   11 +++++++++--
 3 files changed, 20 insertions(+), 7 deletions(-)



Index: linux-2.6.24-rc6-memnotify/fs/eventpoll.c
===================================================================
--- linux-2.6.24-rc6-memnotify.orig/fs/eventpoll.c	2007-12-30 02:08:58.000000000 +0900
+++ linux-2.6.24-rc6-memnotify/fs/eventpoll.c	2007-12-30 07:10:46.000000000 +0900
@@ -676,7 +676,7 @@ out_unlock:
  * target file wakeup lists.
  */
 static void ep_ptable_queue_proc(struct file *file, wait_queue_head_t *whead,
-				 poll_table *pt)
+				 poll_table *pt, int exclusive)
 {
 	struct epitem *epi = ep_item_from_epqueue(pt);
 	struct eppoll_entry *pwq;
@@ -685,7 +685,10 @@ static void ep_ptable_queue_proc(struct 
 		init_waitqueue_func_entry(&pwq->wait, ep_poll_callback);
 		pwq->whead = whead;
 		pwq->base = epi;
-		add_wait_queue(whead, &pwq->wait);
+		if (exclusive)
+			add_wait_queue_exclusive(whead, &pwq->wait);
+		else
+			add_wait_queue(whead, &pwq->wait);
 		list_add_tail(&pwq->llink, &epi->pwqlist);
 		epi->nwait++;
 	} else {
Index: linux-2.6.24-rc6-memnotify/fs/select.c
===================================================================
--- linux-2.6.24-rc6-memnotify.orig/fs/select.c	2007-12-30 02:09:00.000000000 +0900
+++ linux-2.6.24-rc6-memnotify/fs/select.c	2007-12-30 02:34:05.000000000 +0900
@@ -48,7 +48,7 @@ struct poll_table_page {
  * poll table.
  */
 static void __pollwait(struct file *filp, wait_queue_head_t *wait_address,
-		       poll_table *p);
+		       poll_table *p, int exclusive);
 
 void poll_initwait(struct poll_wqueues *pwq)
 {
@@ -117,7 +117,7 @@ static struct poll_table_entry *poll_get
 
 /* Add a new entry */
 static void __pollwait(struct file *filp, wait_queue_head_t *wait_address,
-				poll_table *p)
+		       poll_table *p, int exclusive)
 {
 	struct poll_table_entry *entry = poll_get_entry(p);
 	if (!entry)
@@ -126,7 +126,10 @@ static void __pollwait(struct file *filp
 	entry->filp = filp;
 	entry->wait_address = wait_address;
 	init_waitqueue_entry(&entry->wait, current);
-	add_wait_queue(wait_address, &entry->wait);
+	if (exclusive)
+		add_wait_queue_exclusive(wait_address, &entry->wait);
+	else
+		add_wait_queue(wait_address, &entry->wait);
 }
 
 #define FDS_IN(fds, n)		(fds->in + n)
Index: linux-2.6.24-rc6-memnotify/include/linux/poll.h
===================================================================
--- linux-2.6.24-rc6-memnotify.orig/include/linux/poll.h	2007-12-30 02:09:16.000000000 +0900
+++ linux-2.6.24-rc6-memnotify/include/linux/poll.h	2007-12-30 02:41:35.000000000 +0900
@@ -28,7 +28,8 @@ struct poll_table_struct;
 /* 
  * structures and helpers for f_op->poll implementations
  */
-typedef void (*poll_queue_proc)(struct file *, wait_queue_head_t *, struct poll_table_struct *);
+typedef void (*poll_queue_proc)(struct file *, wait_queue_head_t *,
+				struct poll_table_struct *, int);
 
 typedef struct poll_table_struct {
 	poll_queue_proc qproc;
@@ -37,7 +38,13 @@ typedef struct poll_table_struct {
 static inline void poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
 {
 	if (p && wait_address)
-		p->qproc(filp, wait_address, p);
+		p->qproc(filp, wait_address, p, 0);
+}
+
+static inline void poll_wait_exclusive(struct file *filp, wait_queue_head_t *wait_address, poll_table *p)
+{
+	if (p && wait_address)
+		p->qproc(filp, wait_address, p, 1);
 }
 
 static inline void init_poll_funcptr(poll_table *pt, poll_queue_proc qproc)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
