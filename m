Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: What if a TLB flush needed to sleep?
Date: Wed, 26 Mar 2008 13:29:58 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843ECE9EB1C@orsmsx424.amr.corp.intel.com>
In-reply-to: <20080326123239.GG16721@parisc-linux.org>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <20080326123239.GG16721@parisc-linux.org>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Of course, someone who wrote it could do better ;-)

Here is Willy's code in patch format (against linux-next
tree tag next-20080326 which includes his re-write of the
semaphore code).

This looks a lot cleaner than my ia64 specific code that
used cmpxchg() for the down() operation and fetchadd for
the up() ... using a brand new semaphore_spin data type.

It appears to work ... I tried to do some timing comparisons
of this generic version against my arch specific one, but the
hackbench test case has a run to run variation of a factor of
three (from 1min9sec to 3min44sec) so it is hopeless to try
and see some small percentage difference.

commit 0359fbb64297d44328f26ec5fda3a3c26f1c5ba7
Author: Matthew Wilcox <matthew@wil.cx>
Date:   Wed Mar 26 11:08:18 2008 -0700

    Add "down_spin()" API for semaphores
    
    For those places that need semaphore semantics but cannot sleep
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/linux/semaphore.h b/include/linux/semaphore.h
index a7125da..3404ce5 100644
--- a/include/linux/semaphore.h
+++ b/include/linux/semaphore.h
@@ -53,6 +53,12 @@ static inline void sema_init(struct semaphore *sem, int val)
 extern void down(struct semaphore *sem);
 
 /*
+ * Attempt to acquire the semaphore.  If another task is already holding the
+ * semaphore, spin until the semaphore is released.
+ */
+extern void down_spin(struct semaphore *sem);
+
+/*
  * As down(), except the sleep may be interrupted by a signal.  If it is,
  * this function will return -EINTR.
  */
diff --git a/kernel/semaphore.c b/kernel/semaphore.c
index bef977b..d3eb559 100644
--- a/kernel/semaphore.c
+++ b/kernel/semaphore.c
@@ -23,6 +23,7 @@
  */
 
 static noinline void __down(struct semaphore *sem);
+static noinline void __down_spin(struct semaphore *sem);
 static noinline int __down_interruptible(struct semaphore *sem);
 static noinline int __down_killable(struct semaphore *sem);
 static noinline int __down_timeout(struct semaphore *sem, long jiffies);
@@ -41,6 +42,21 @@ void down(struct semaphore *sem)
 }
 EXPORT_SYMBOL(down);
 
+void down_spin(struct semaphore *sem)
+{
+	unsigned long flags;
+	int count;
+
+	spin_lock_irqsave(&sem->lock, flags);
+	count = sem->count - 1;
+	if (likely(count >= 0))
+		sem->count = count;
+	else
+		__down_spin(sem);
+	spin_unlock_irqrestore(&sem->lock, flags);
+}
+EXPORT_SYMBOL(down_spin);
+
 int down_interruptible(struct semaphore *sem)
 {
 	unsigned long flags;
@@ -197,6 +213,20 @@ static noinline int __sched __down_timeout(struct semaphore *sem, long jiffies)
 	return __down_common(sem, TASK_UNINTERRUPTIBLE, jiffies);
 }
 
+static noinline void __sched __down_spin(struct semaphore *sem)
+{
+	struct semaphore_waiter waiter;
+
+	list_add_tail(&waiter.list, &sem->wait_list);
+	waiter.task = current;
+	waiter.up = 0;
+
+	spin_unlock_irq(&sem->lock);
+	while (!waiter.up)
+		cpu_relax();
+	spin_lock_irq(&sem->lock);
+}
+
 static noinline void __sched __up(struct semaphore *sem)
 {
 	struct semaphore_waiter *waiter = list_first_entry(&sem->wait_list,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
