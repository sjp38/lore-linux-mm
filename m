Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C48B56B0253
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:09:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id b6so20873389pff.18
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:09:08 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y68si17054509pfk.100.2017.11.15.06.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:09:07 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 15/16] kcov: convert kcov.refcount to refcount_t
Date: Wed, 15 Nov 2017 16:03:39 +0200
Message-Id: <1510754620-27088-16-git-send-email-elena.reshetova@intel.com>
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

The variable kcov.refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

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

For the kcov.refcount it might make a difference
in following places:
 - kcov_put(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/kcov.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/kcov.c b/kernel/kcov.c
index 15f33fa..343288c 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -20,6 +20,7 @@
 #include <linux/debugfs.h>
 #include <linux/uaccess.h>
 #include <linux/kcov.h>
+#include <linux/refcount.h>
 #include <asm/setup.h>
 
 /* Number of 64-bit words written per one comparison: */
@@ -44,7 +45,7 @@ struct kcov {
 	 *  - opened file descriptor
 	 *  - task with enabled coverage (we can't unwire it from another task)
 	 */
-	atomic_t		refcount;
+	refcount_t		refcount;
 	/* The lock protects mode, size, area and t. */
 	spinlock_t		lock;
 	enum kcov_mode		mode;
@@ -228,12 +229,12 @@ EXPORT_SYMBOL(__sanitizer_cov_trace_switch);
 
 static void kcov_get(struct kcov *kcov)
 {
-	atomic_inc(&kcov->refcount);
+	refcount_inc(&kcov->refcount);
 }
 
 static void kcov_put(struct kcov *kcov)
 {
-	if (atomic_dec_and_test(&kcov->refcount)) {
+	if (refcount_dec_and_test(&kcov->refcount)) {
 		vfree(kcov->area);
 		kfree(kcov);
 	}
@@ -311,7 +312,7 @@ static int kcov_open(struct inode *inode, struct file *filep)
 	if (!kcov)
 		return -ENOMEM;
 	kcov->mode = KCOV_MODE_DISABLED;
-	atomic_set(&kcov->refcount, 1);
+	refcount_set(&kcov->refcount, 1);
 	spin_lock_init(&kcov->lock);
 	filep->private_data = kcov;
 	return nonseekable_open(inode, filep);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
