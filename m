Date: Tue, 25 Dec 2007 13:56:24 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC] add poll_wait_exclusive() API
In-Reply-To: <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20071224203250.GA23149@dmt> <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20071225135102.D25F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

add item to wait queue exist 2 way, add_wait_queue() and add_wait_queue_exclusive().
but unfortunately, we only able to use poll_wait in poll method.

poll_wait_exclusive() works similar as add_wait_queue_exclusive()


caution:
  this patch is compile test only.
  my purpose is discussion only.


/kosaki


Index: b/fs/eventpoll.c
===================================================================
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -677,7 +677,7 @@ out_unlock:
  * target file wakeup lists.
  */
 static void ep_ptable_queue_proc(struct file *file, wait_queue_head_t *whead,
-				 poll_table *pt)
+				 poll_table *pt, int exclusive)
 {
 	struct epitem *epi = ep_item_from_epqueue(pt);
 	struct eppoll_entry *pwq;
@@ -686,7 +686,10 @@ static void ep_ptable_queue_proc(struct 
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
Index: b/fs/select.c
===================================================================
--- a/fs/select.c
+++ b/fs/select.c
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
Index: b/include/linux/poll.h
===================================================================
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -28,18 +28,26 @@ struct poll_table_struct;
 /* 
  * structures and helpers for f_op->poll implementations
  */
-typedef void (*poll_queue_proc)(struct file *, wait_queue_head_t *, struct poll_table_struct *);
+typedef void (*poll_queue_proc)(struct file *, wait_queue_head_t *,
+				struct poll_table_struct *, int exclusive);
 
 typedef struct poll_table_struct {
 	poll_queue_proc qproc;
 } poll_table;
 
-static inline void poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
+static inline void poll_wait(struct file *filp, wait_queue_head_t *wait_address, poll_table *p)
 {
 	if (p && wait_address)
-		p->qproc(filp, wait_address, p);
+		p->qproc(filp, wait_address, p, 0);
 }
 
+static inline void poll_wait_exclusive(struct file *filp, wait_queue_head_t *wait_address, poll_table *p)
+{
+	if (p && wait_address)
+		p->qproc(filp, wait_address, p, 1);
+}
+
+
 static inline void init_poll_funcptr(poll_table *pt, poll_queue_proc qproc)
 {
 	pt->qproc = qproc;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
