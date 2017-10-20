Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9AC6B026C
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:17:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a8so10063828pfc.6
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:17:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e4si700060pfl.603.2017.10.20.05.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:17:15 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 14/15] kcov: convert kcov.refcount to refcount_t
Date: Fri, 20 Oct 2017 15:15:56 +0300
Message-Id: <1508501757-15784-15-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
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

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/kcov.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/kcov.c b/kernel/kcov.c
index 461c55e..03c174c 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -19,6 +19,7 @@
 #include <linux/debugfs.h>
 #include <linux/uaccess.h>
 #include <linux/kcov.h>
+#include <linux/refcount.h>
 #include <asm/setup.h>
 
 /* Number of 64-bit words written per one comparison: */
@@ -43,7 +44,7 @@ struct kcov {
 	 *  - opened file descriptor
 	 *  - task with enabled coverage (we can't unwire it from another task)
 	 */
-	atomic_t		refcount;
+	refcount_t		refcount;
 	/* The lock protects mode, size, area and t. */
 	spinlock_t		lock;
 	enum kcov_mode		mode;
@@ -227,12 +228,12 @@ EXPORT_SYMBOL(__sanitizer_cov_trace_switch);
 
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
@@ -310,7 +311,7 @@ static int kcov_open(struct inode *inode, struct file *filep)
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
