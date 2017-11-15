Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A74656B0069
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:07:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s28so15642500pfg.6
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:07:55 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p9si18452014pls.538.2017.11.15.06.07.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:07:54 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 01/16] futex: convert futex_pi_state.refcount to refcount_t
Date: Wed, 15 Nov 2017 16:03:25 +0200
Message-Id: <1510754620-27088-2-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable futex_pi_state.refcount is used as pure
reference counter. Convert it to refcount_t and fix up
the operations.

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the futex_pi_state.refcount it might make a difference
in following places:
 - get_pi_state() and exit_pi_state_list(): increment in
   refcount_inc_not_zero() only guarantees control dependency
   on success vs. fully ordered atomic counterpart
 - put_pi_state(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/futex.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/kernel/futex.c b/kernel/futex.c
index 76ed592..907055f 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -67,6 +67,7 @@
 #include <linux/freezer.h>
 #include <linux/bootmem.h>
 #include <linux/fault-inject.h>
+#include <linux/refcount.h>
 
 #include <asm/futex.h>
 
@@ -209,7 +210,7 @@ struct futex_pi_state {
 	struct rt_mutex pi_mutex;
 
 	struct task_struct *owner;
-	atomic_t refcount;
+	refcount_t refcount;
 
 	union futex_key key;
 } __randomize_layout;
@@ -795,7 +796,7 @@ static int refill_pi_state_cache(void)
 	INIT_LIST_HEAD(&pi_state->list);
 	/* pi_mutex gets initialized later */
 	pi_state->owner = NULL;
-	atomic_set(&pi_state->refcount, 1);
+	refcount_set(&pi_state->refcount, 1);
 	pi_state->key = FUTEX_KEY_INIT;
 
 	current->pi_state_cache = pi_state;
@@ -815,7 +816,7 @@ static struct futex_pi_state *alloc_pi_state(void)
 
 static void get_pi_state(struct futex_pi_state *pi_state)
 {
-	WARN_ON_ONCE(!atomic_inc_not_zero(&pi_state->refcount));
+	WARN_ON_ONCE(!refcount_inc_not_zero(&pi_state->refcount));
 }
 
 /*
@@ -827,7 +828,7 @@ static void put_pi_state(struct futex_pi_state *pi_state)
 	if (!pi_state)
 		return;
 
-	if (!atomic_dec_and_test(&pi_state->refcount))
+	if (!refcount_dec_and_test(&pi_state->refcount))
 		return;
 
 	/*
@@ -857,7 +858,7 @@ static void put_pi_state(struct futex_pi_state *pi_state)
 		 * refcount is at 0 - put it back to 1.
 		 */
 		pi_state->owner = NULL;
-		atomic_set(&pi_state->refcount, 1);
+		refcount_set(&pi_state->refcount, 1);
 		current->pi_state_cache = pi_state;
 	}
 }
@@ -918,7 +919,7 @@ void exit_pi_state_list(struct task_struct *curr)
 		 * In that case; drop the locks to let put_pi_state() make
 		 * progress and retry the loop.
 		 */
-		if (!atomic_inc_not_zero(&pi_state->refcount)) {
+		if (!refcount_inc_not_zero(&pi_state->refcount)) {
 			raw_spin_unlock_irq(&curr->pi_lock);
 			cpu_relax();
 			raw_spin_lock_irq(&curr->pi_lock);
@@ -1074,7 +1075,7 @@ static int attach_to_pi_state(u32 __user *uaddr, u32 uval,
 	 * and futex_wait_requeue_pi() as it cannot go to 0 and consequently
 	 * free pi_state before we can take a reference ourselves.
 	 */
-	WARN_ON(!atomic_read(&pi_state->refcount));
+	WARN_ON(!refcount_read(&pi_state->refcount));
 
 	/*
 	 * Now that we have a pi_state, we can acquire wait_lock
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
