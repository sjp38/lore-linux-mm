Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEDB6B0390
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:32 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o45so25185664qto.5
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u187si2300016qkc.30.2017.06.12.05.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:31 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 08/20] lib: add errseq_t type and infrastructure for handling it
Date: Mon, 12 Jun 2017 08:23:00 -0400
Message-Id: <20170612122316.13244-9-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

An errseq_t is a way of recording errors in one place, and allowing any
number of "subscribers" to tell whether an error has been set again
since a previous time.

It's implemented as an unsigned 32-bit value that is managed with atomic
operations. The low order bits are designated to hold an error code
(max size of MAX_ERRNO). The upper bits are used as a counter.

The API works with consumers sampling an errseq_t value at a particular
point in time. Later, that value can be used to tell whether new errors
have been set since that time.

Note that there is a 1 in 512k risk of collisions here if new errors
are being recorded frequently, since we have so few bits to use as a
counter. To mitigate this, one bit is used as a flag to tell whether the
value has been sampled since a new value was recorded. That allows
us to avoid bumping the counter if no one has sampled it since it
was last bumped.

Later patches will build on this infrastructure to change how writeback
errors are tracked in the kernel.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: NeilBrown <neilb@suse.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 include/linux/errseq.h |  19 +++++
 lib/Makefile           |   2 +-
 lib/errseq.c           | 200 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 220 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/errseq.h
 create mode 100644 lib/errseq.c

diff --git a/include/linux/errseq.h b/include/linux/errseq.h
new file mode 100644
index 000000000000..0d2555f310cd
--- /dev/null
+++ b/include/linux/errseq.h
@@ -0,0 +1,19 @@
+#ifndef _LINUX_ERRSEQ_H
+#define _LINUX_ERRSEQ_H
+
+/* See lib/errseq.c for more info */
+
+typedef u32	errseq_t;
+
+void __errseq_set(errseq_t *eseq, int err);
+static inline void errseq_set(errseq_t *eseq, int err)
+{
+	/* Optimize for the common case of no error */
+	if (unlikely(err))
+		__errseq_set(eseq, err);
+}
+
+errseq_t errseq_sample(errseq_t *eseq);
+int errseq_check(errseq_t *eseq, errseq_t since);
+int errseq_check_and_advance(errseq_t *eseq, errseq_t *since);
+#endif
diff --git a/lib/Makefile b/lib/Makefile
index 0166fbc0fa81..519782d9ca3f 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -41,7 +41,7 @@ obj-y += bcd.o div64.o sort.o parser.o debug_locks.o random32.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
 	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
 	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o \
-	 once.o refcount.o usercopy.o
+	 once.o refcount.o usercopy.o errseq.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += hexdump.o
diff --git a/lib/errseq.c b/lib/errseq.c
new file mode 100644
index 000000000000..d129c0611c1f
--- /dev/null
+++ b/lib/errseq.c
@@ -0,0 +1,200 @@
+#include <linux/err.h>
+#include <linux/bug.h>
+#include <linux/atomic.h>
+#include <linux/errseq.h>
+
+/*
+ * An errseq_t is a way of recording errors in one place, and allowing any
+ * number of "subscribers" to tell whether it has changed since a previous
+ * point where it was sampled.
+ *
+ * It's implemented as an unsigned 32-bit value. The low order bits are
+ * designated to hold an error code (between 0 and -MAX_ERRNO). The upper bits
+ * are used as a counter. This is done with atomics instead of locking so that
+ * these functions can be called from any context.
+ *
+ * The general idea is for consumers to sample an errseq_t value. That value
+ * can later be used to tell whether any new errors have occurred since that
+ * sampling was done.
+ *
+ * Note that there is a risk of collisions if new errors are being recorded
+ * frequently, since we have so few bits to use as a counter.
+ *
+ * To mitigate this, one bit is used as a flag to tell whether the value has
+ * been sampled since a new value was recorded. That allows us to avoid bumping
+ * the counter if no one has sampled it since the last time an error was
+ * recorded.
+ *
+ * A new errseq_t should always be zeroed out.  A errseq_t value of all zeroes
+ * is the special (but common) case where there has never been an error. An all
+ * zero value thus serves as the "epoch" if one wishes to know whether there
+ * has ever been an error set since it was first initialized.
+ */
+
+/* The low bits are designated for error code (max of MAX_ERRNO) */
+#define ERRSEQ_SHIFT		ilog2(MAX_ERRNO + 1)
+
+/* This bit is used as a flag to indicate whether the value has been seen */
+#define ERRSEQ_SEEN		(1 << ERRSEQ_SHIFT)
+
+/* The lowest bit of the counter */
+#define ERRSEQ_CTR_INC		(1 << (ERRSEQ_SHIFT + 1))
+
+/**
+ * __errseq_set - set a errseq_t for later reporting
+ * @eseq: errseq_t field that should be set
+ * @err: error to set
+ *
+ * This function sets the error in *eseq, and increments the sequence counter
+ * if the last sequence was sampled at some point in the past.
+ *
+ * Any error set will always overwrite an existing error.
+ *
+ * Most callers will want to use the errseq_set inline wrapper to efficiently
+ * handle the common case where err is 0.
+ */
+void __errseq_set(errseq_t *eseq, int err)
+{
+	errseq_t old;
+
+	/* MAX_ERRNO must be able to serve as a mask */
+	BUILD_BUG_ON_NOT_POWER_OF_2(MAX_ERRNO + 1);
+
+	/*
+	 * Ensure the error code actually fits where we want it to go. If it
+	 * doesn't then just throw a warning and don't record anything. We
+	 * also don't accept zero here as that would effectively clear a
+	 * previous error.
+	 */
+	if (WARN(unlikely(err == 0 || (unsigned int)-err > MAX_ERRNO),
+				"err = %d\n", err))
+		return;
+
+	old = READ_ONCE(*eseq);
+	for (;;) {
+		errseq_t new, cur;
+
+		/* Clear out error bits and set new error */
+		new = (old & ~(MAX_ERRNO|ERRSEQ_SEEN)) | -err;
+
+		/* Only increment if someone has looked at it */
+		if (old & ERRSEQ_SEEN)
+			new += ERRSEQ_CTR_INC;
+
+		/* If there would be no change, then call it done */
+		if (new == old)
+			break;
+
+		/* Try to swap the new value into place */
+		cur = cmpxchg(eseq, old, new);
+
+		/*
+		 * Call it success if we did the swap or someone else beat us
+		 * to it for the same value.
+		 */
+		if (likely(cur == old || cur == new))
+			break;
+
+		/* Raced with an update, try again */
+		old = cur;
+	}
+}
+EXPORT_SYMBOL(__errseq_set);
+
+/**
+ * errseq_sample - grab current errseq_t value
+ * @eseq: pointer to errseq_t to be sampled
+ *
+ * This function allows callers to sample an errseq_t value, marking it as
+ * "seen" if required.
+ */
+errseq_t errseq_sample(errseq_t *eseq)
+{
+	errseq_t old = READ_ONCE(*eseq);
+	errseq_t new = old;
+
+	/*
+	 * For the common case of no errors ever having been set, we can skip
+	 * marking the SEEN bit. Once an error has been set, the value will
+	 * never go back to zero.
+	 */
+	if (old != 0) {
+		new |= ERRSEQ_SEEN;
+		if (old != new)
+			cmpxchg(eseq, old, new);
+	}
+	return new;
+}
+EXPORT_SYMBOL(errseq_sample);
+
+/**
+ * errseq_check - has an error occurred since a particular sample point?
+ * @eseq: pointer to errseq_t value to be checked
+ * @since: previously-sampled errseq_t from which to check
+ *
+ * Grab the value that eseq points to, and see if it has changed "since"
+ * the given value was sampled. The "since" value is not advanced, so there
+ * is no need to mark the value as seen.
+ *
+ * Returns the latest error set in the errseq_t or 0 if it hasn't changed.
+ */
+int errseq_check(errseq_t *eseq, errseq_t since)
+{
+	errseq_t cur = READ_ONCE(*eseq);
+
+	if (likely(cur == since))
+		return 0;
+	return -(cur & MAX_ERRNO);
+}
+EXPORT_SYMBOL(errseq_check);
+
+/**
+ * errseq_check_and_advance - check an errseq_t and advance it to the current value
+ * @eseq: pointer to value being checked and reported
+ * @since: pointer to previously-sampled errseq_t to check against and advance
+ *
+ * Grab the eseq value, and see whether it matches the value that "since"
+ * points to. If it does, then just return 0.
+ *
+ * If it doesn't, then the value has changed. Set the "seen" flag, and try to
+ * swap it into place as the new eseq value. Then, set that value as the new
+ * "since" value, and return whatever the error portion is set to.
+ *
+ * Note that no locking is provided here for concurrent updates to the "since"
+ * value. The caller must provide that if necessary. Because of this, callers
+ * may want to do a lockless errseq_check before taking the lock and calling
+ * this.
+ */
+int errseq_check_and_advance(errseq_t *eseq, errseq_t *since)
+{
+	int err = 0;
+	errseq_t old, new;
+
+	/*
+	 * Most callers will want to use the inline wrapper to check this,
+	 * so that the common case of no error is handled without needing
+	 * to take the lock that protects the "since" value.
+	 */
+	old = READ_ONCE(*eseq);
+	if (old != *since) {
+		/*
+		 * Set the flag and try to swap it into place if it has
+		 * changed.
+		 *
+		 * We don't care about the outcome of the swap here. If the
+		 * swap doesn't occur, then it has either been updated by a
+		 * writer who is altering the value in some way (updating
+		 * counter or resetting the error), or another reader who is
+		 * just setting the "seen" flag. Either outcome is OK, and we
+		 * can advance "since" and return an error based on what we
+		 * have.
+		 */
+		new = old | ERRSEQ_SEEN;
+		if (new != old)
+			cmpxchg(eseq, old, new);
+		*since = new;
+		err = -(new & MAX_ERRNO);
+	}
+	return err;
+}
+EXPORT_SYMBOL(errseq_check_and_advance);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
