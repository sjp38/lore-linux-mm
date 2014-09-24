Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 33AFA6B0037
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 22:03:15 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id gb8so245762lab.16
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:03:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t9si20841333lae.103.2014.09.23.19.03.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 19:03:13 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 24 Sep 2014 11:28:32 +1000
Subject: [PATCH 1/5] SCHED: add some "wait..on_bit...timeout()" interfaces.
Message-ID: <20140924012832.4838.59410.stgit@notabene.brown>
In-Reply-To: <20140924012422.4838.29188.stgit@notabene.brown>
References: <20140924012422.4838.29188.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

In commit c1221321b7c25b53204447cff9949a6d5a7ddddc
   sched: Allow wait_on_bit_action() functions to support a timeout

I suggested that a "wait_on_bit_timeout()" interface would not meet my
need.  This isn't true - I was just over-engineering.

Including a 'private' field in wait_bit_key instead of a focused
"timeout" field was just premature generalization.  If some other
use is ever found, it can be generalized or added later.

So this patch renames "private" to "timeout" with a meaning "stop
waiting when "jiffies" reaches or passes "timeout",
and adds two of the many possible wait..bit..timeout() interfaces:

wait_on_page_bit_killable_timeout(), which is the one I want to use,
and out_of_line_wait_on_bit_timeout() which is a reasonably general
example.  Others can be added as needed.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/pagemap.h |    2 ++
 include/linux/wait.h    |    5 ++++-
 kernel/sched/wait.c     |   36 ++++++++++++++++++++++++++++++++++++
 mm/filemap.c            |   13 +++++++++++++
 4 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3df8c7db7a4e..87f9e4230d3a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -502,6 +502,8 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 extern void wait_on_page_bit(struct page *page, int bit_nr);
 
 extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
+extern int wait_on_page_bit_killable_timeout(struct page *page,
+					     int bit_nr, unsigned long timeout);
 
 static inline int wait_on_page_locked_killable(struct page *page)
 {
diff --git a/include/linux/wait.h b/include/linux/wait.h
index 6fb1ba5f9b2f..80115bf88671 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -25,7 +25,7 @@ struct wait_bit_key {
 	void			*flags;
 	int			bit_nr;
 #define WAIT_ATOMIC_T_BIT_NR	-1
-	unsigned long		private;
+	unsigned long		timeout;
 };
 
 struct wait_bit_queue {
@@ -154,6 +154,7 @@ int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, wait_bit_ac
 void wake_up_bit(void *, int);
 void wake_up_atomic_t(atomic_t *);
 int out_of_line_wait_on_bit(void *, int, wait_bit_action_f *, unsigned);
+int out_of_line_wait_on_bit_timeout(void *, int, wait_bit_action_f *, unsigned, unsigned long);
 int out_of_line_wait_on_bit_lock(void *, int, wait_bit_action_f *, unsigned);
 int out_of_line_wait_on_atomic_t(atomic_t *, int (*)(atomic_t *), unsigned);
 wait_queue_head_t *bit_waitqueue(void *, int);
@@ -859,6 +860,8 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 
 extern int bit_wait(struct wait_bit_key *);
 extern int bit_wait_io(struct wait_bit_key *);
+extern int bit_wait_timeout(struct wait_bit_key *);
+extern int bit_wait_io_timeout(struct wait_bit_key *);
 
 /**
  * wait_on_bit - wait for a bit to be cleared
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 15cab1a4f84e..380678b3cba4 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -343,6 +343,18 @@ int __sched out_of_line_wait_on_bit(void *word, int bit,
 }
 EXPORT_SYMBOL(out_of_line_wait_on_bit);
 
+int __sched out_of_line_wait_on_bit_timeout(
+	void *word, int bit, wait_bit_action_f *action,
+	unsigned mode, unsigned long timeout)
+{
+	wait_queue_head_t *wq = bit_waitqueue(word, bit);
+	DEFINE_WAIT_BIT(wait, word, bit);
+
+	wait.key.timeout = jiffies + timeout;
+	return __wait_on_bit(wq, &wait, action, mode);
+}
+EXPORT_SYMBOL(out_of_line_wait_on_bit_timeout);
+
 int __sched
 __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
 			wait_bit_action_f *action, unsigned mode)
@@ -520,3 +532,27 @@ __sched int bit_wait_io(struct wait_bit_key *word)
 	return 0;
 }
 EXPORT_SYMBOL(bit_wait_io);
+
+__sched int bit_wait_timeout(struct wait_bit_key *word)
+{
+	unsigned long now = ACCESS_ONCE(jiffies);
+	if (signal_pending_state(current->state, current))
+		return 1;
+	if (time_after_eq(now, word->timeout))
+		return -EAGAIN;
+	schedule_timeout(word->timeout - now);
+	return 0;
+}
+EXPORT_SYMBOL(bit_wait_timeout);
+
+__sched int bit_wait_io_timeout(struct wait_bit_key *word)
+{
+	unsigned long now = ACCESS_ONCE(jiffies);
+	if (signal_pending_state(current->state, current))
+		return 1;
+	if (time_after_eq(now, word->timeout))
+		return -EAGAIN;
+	io_schedule_timeout(word->timeout - now);
+	return 0;
+}
+EXPORT_SYMBOL(bit_wait_io_timeout);
diff --git a/mm/filemap.c b/mm/filemap.c
index 90effcdf948d..4a19c084bdb1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -703,6 +703,19 @@ int wait_on_page_bit_killable(struct page *page, int bit_nr)
 			     bit_wait_io, TASK_KILLABLE);
 }
 
+int wait_on_page_bit_killable_timeout(struct page *page,
+				       int bit_nr, unsigned long timeout)
+{
+	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+
+	wait.key.timeout = jiffies + timeout;
+	if (!test_bit(bit_nr, &page->flags))
+		return 0;
+	return __wait_on_bit(page_waitqueue(page), &wait,
+			     bit_wait_io_timeout, TASK_KILLABLE);
+}
+EXPORT_SYMBOL(wait_on_page_bit_killable_timeout);
+
 /**
  * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
  * @page: Page defining the wait queue of interest


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
