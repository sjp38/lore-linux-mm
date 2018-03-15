Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 539866B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:58:17 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f3-v6so3109402plf.1
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 04:58:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l14si3309368pgn.188.2018.03.15.04.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Mar 2018 04:58:16 -0700 (PDT)
Date: Thu, 15 Mar 2018 04:58:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] Improve mutex documentation
Message-ID: <20180315115812.GA9949@bombadil.infradead.org>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Mauro Carvalho Chehab <mchehab@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>

On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
> My memory is weak and our documentation is awful.  What does
> mutex_lock_killable() actually do and how does it differ from
> mutex_lock_interruptible()?

From: Matthew Wilcox <mawilcox@microsoft.com>

Add kernel-doc for mutex_lock_killable() and mutex_lock_io().  Reword the
kernel-doc for mutex_lock_interruptible().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
index 858a07590e39..2048359f33d2 100644
--- a/kernel/locking/mutex.c
+++ b/kernel/locking/mutex.c
@@ -1082,15 +1082,16 @@ static noinline int __sched
 __mutex_lock_interruptible_slowpath(struct mutex *lock);
 
 /**
- * mutex_lock_interruptible - acquire the mutex, interruptible
- * @lock: the mutex to be acquired
+ * mutex_lock_interruptible() - Acquire the mutex, interruptible by signals.
+ * @lock: The mutex to be acquired.
  *
- * Lock the mutex like mutex_lock(), and return 0 if the mutex has
- * been acquired or sleep until the mutex becomes available. If a
- * signal arrives while waiting for the lock then this function
- * returns -EINTR.
+ * Lock the mutex like mutex_lock().  If a signal is delivered while the
+ * process is sleeping, this function will return without acquiring the
+ * mutex.
  *
- * This function is similar to (but not equivalent to) down_interruptible().
+ * Context: Process context.
+ * Return: 0 if the lock was successfully acquired or %-EINTR if a
+ * signal arrived.
  */
 int __sched mutex_lock_interruptible(struct mutex *lock)
 {
@@ -1104,6 +1105,18 @@ int __sched mutex_lock_interruptible(struct mutex *lock)
 
 EXPORT_SYMBOL(mutex_lock_interruptible);
 
+/**
+ * mutex_lock_killable() - Acquire the mutex, interruptible by fatal signals.
+ * @lock: The mutex to be acquired.
+ *
+ * Lock the mutex like mutex_lock().  If a signal which will be fatal to
+ * the current process is delivered while the process is sleeping, this
+ * function will return without acquiring the mutex.
+ *
+ * Context: Process context.
+ * Return: 0 if the lock was successfully acquired or %-EINTR if a
+ * fatal signal arrived.
+ */
 int __sched mutex_lock_killable(struct mutex *lock)
 {
 	might_sleep();
@@ -1115,6 +1128,16 @@ int __sched mutex_lock_killable(struct mutex *lock)
 }
 EXPORT_SYMBOL(mutex_lock_killable);
 
+/**
+ * mutex_lock_io() - Acquire the mutex and mark the process as waiting for I/O
+ * @lock: The mutex to be acquired.
+ *
+ * Lock the mutex like mutex_lock().  While the task is waiting for this
+ * mutex, it will be accounted as being in the IO wait state by the
+ * scheduler.
+ *
+ * Context: Process context.
+ */
 void __sched mutex_lock_io(struct mutex *lock)
 {
 	int token;
