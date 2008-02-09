Received: by py-out-1112.google.com with SMTP id f47so4290012pye.20
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 07:21:57 -0800 (PST)
Message-ID: <2f11576a0802090721l5cd8c89bx7814b2848b419057@mail.gmail.com>
Date: Sun, 10 Feb 2008 00:21:56 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/8][for -mm] mem_notify v6: introduce wake_up_locked_nr() new API
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-fsdevel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Jon Masters <jonathan@jonmasters.org>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

introduce new API wake_up_locked_nr() and wake_up_locked_all().
it it similar as wake_up_nr() and wake_up_all(), but it doesn't lock.

Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/wait.h |   12 ++++++++----
 kernel/sched.c       |    5 +++--
 2 files changed, 11 insertions(+), 6 deletions(-)

Index: b/include/linux/wait.h
===================================================================
--- a/include/linux/wait.h	2008-02-03 20:27:54.000000000 +0900
+++ b/include/linux/wait.h	2008-02-03 20:32:12.000000000 +0900
@@ -142,7 +142,8 @@ static inline void __remove_wait_queue(w
 }

 void FASTCALL(__wake_up(wait_queue_head_t *q, unsigned int mode, int
nr, void *key));
-extern void FASTCALL(__wake_up_locked(wait_queue_head_t *q, unsigned
int mode));
+void FASTCALL(__wake_up_locked(wait_queue_head_t *q, unsigned int mode,
+			       int nr, void *key));
 extern void FASTCALL(__wake_up_sync(wait_queue_head_t *q, unsigned
int mode, int nr));
 void FASTCALL(__wake_up_bit(wait_queue_head_t *, void *, int));
 int FASTCALL(__wait_on_bit(wait_queue_head_t *, struct wait_bit_queue
*, int (*)(void *), unsigned));
@@ -155,10 +156,13 @@ wait_queue_head_t *FASTCALL(bit_waitqueu
 #define wake_up(x)			__wake_up(x, TASK_NORMAL, 1, NULL)
 #define wake_up_nr(x, nr)		__wake_up(x, TASK_NORMAL, nr, NULL)
 #define wake_up_all(x)			__wake_up(x, TASK_NORMAL, 0, NULL)
-#define wake_up_locked(x)		__wake_up_locked((x), TASK_NORMAL)

-#define wake_up_interruptible(x)	__wake_up(x, TASK_INTERRUPTIBLE, 1, NULL)
-#define wake_up_interruptible_nr(x, nr)	__wake_up(x,
TASK_INTERRUPTIBLE, nr, NULL)
+#define wake_up_locked(x)	        __wake_up_locked((x), TASK_NORMAL, 1, NULL)
+#define wake_up_locked_nr(x, nr)        __wake_up_locked((x),
TASK_NORMAL, nr, NULL)
+#define wake_up_locked_all(x)	        __wake_up_locked((x),
TASK_NORMAL, 0, NULL)
+
+#define wake_up_interruptible(x) 	__wake_up(x, TASK_INTERRUPTIBLE, 1, NULL)
+#define wake_up_interruptible_nr(x, nr) __wake_up(x,
TASK_INTERRUPTIBLE, nr, NULL)
 #define wake_up_interruptible_all(x)	__wake_up(x, TASK_INTERRUPTIBLE, 0, NULL)
 #define wake_up_interruptible_sync(x)	__wake_up_sync((x),
TASK_INTERRUPTIBLE, 1)

Index: b/kernel/sched.c
===================================================================
--- a/kernel/sched.c	2008-02-03 20:27:54.000000000 +0900
+++ b/kernel/sched.c	2008-02-03 20:29:09.000000000 +0900
@@ -4115,9 +4115,10 @@ EXPORT_SYMBOL(__wake_up);
 /*
  * Same as __wake_up but called with the spinlock in wait_queue_head_t held.
  */
-void __wake_up_locked(wait_queue_head_t *q, unsigned int mode)
+void __wake_up_locked(wait_queue_head_t *q, unsigned int mode,
+		      int nr_exclusive, void *key)
 {
-	__wake_up_common(q, mode, 1, 0, NULL);
+	__wake_up_common(q, mode, nr_exclusive, 0, key);
 }

 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
