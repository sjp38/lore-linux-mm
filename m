Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3768C6B01AF
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 02:14:37 -0400 (EDT)
Date: Mon, 21 Jun 2010 23:14:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through waiting
 for flusher thread
Message-Id: <20100621231416.904c50c7.akpm@linux-foundation.org>
In-Reply-To: <20100622054409.GP7869@dastard>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	<20100618060901.GA6590@dastard>
	<20100621233628.GL3828@quack.suse.cz>
	<20100622054409.GP7869@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, peterz@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jun 2010 15:44:09 +1000 Dave Chinner <david@fromorbit.com> wrote:

> > > And so on. This isn't necessarily bad - we'll throttle for longer
> > > than we strictly need to - but the cumulative counter resolution
> > > error gets worse as the number of CPUs doing IO completion grows.
> > > Worst case ends up at for (num cpus * 31) + 1 pages of writeback for
> > > just the first waiter. For an arbitrary FIFO queue of depth d, the
> > > worst case is more like d * (num cpus * 31 + 1).
> >   Hmm, I don't see how the error would depend on the FIFO depth.
> 
> It's the cumulative error that depends on the FIFO depth, not the
> error seen by a single waiter.

Could use the below to basically eliminate the inaccuracies.

Obviously things might get a bit expensive in certain threshold cases
but with some hysteresis that should be manageable.






From: Tim Chen <tim.c.chen@linux.intel.com>

Add percpu_counter_compare that allows for a quick but accurate comparison
of percpu_counter with a given value.

A rough count is provided by the count field in percpu_counter structure,
without accounting for the other values stored in individual cpu counters.
 The actual count is a sum of count and the cpu counters.  However, count
field is never different from the actual value by a factor of
batch*num_online_cpu.  We do not need to get actual count for comparison
if count is different from the given value by this factor and allows for
quick comparison without summing up all the per cpu counters.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/percpu_counter.h |   11 +++++++++++
 lib/percpu_counter.c           |   27 +++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff -puN include/linux/percpu_counter.h~tmpfs-add-accurate-compare-function-to-percpu_counter-library include/linux/percpu_counter.h
--- a/include/linux/percpu_counter.h~tmpfs-add-accurate-compare-function-to-percpu_counter-library
+++ a/include/linux/percpu_counter.h
@@ -40,6 +40,7 @@ void percpu_counter_destroy(struct percp
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
 s64 __percpu_counter_sum(struct percpu_counter *fbc);
+int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs);
 
 static inline void percpu_counter_add(struct percpu_counter *fbc, s64 amount)
 {
@@ -98,6 +99,16 @@ static inline void percpu_counter_set(st
 	fbc->count = amount;
 }
 
+static inline int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs)
+{
+	if (fbc->count > rhs)
+		return 1;
+	else if (fbc->count < rhs)
+		return -1;
+	else
+		return 0;
+}
+
 static inline void
 percpu_counter_add(struct percpu_counter *fbc, s64 amount)
 {
diff -puN lib/percpu_counter.c~tmpfs-add-accurate-compare-function-to-percpu_counter-library lib/percpu_counter.c
--- a/lib/percpu_counter.c~tmpfs-add-accurate-compare-function-to-percpu_counter-library
+++ a/lib/percpu_counter.c
@@ -138,6 +138,33 @@ static int __cpuinit percpu_counter_hotc
 	return NOTIFY_OK;
 }
 
+/*
+ * Compare counter against given value.
+ * Return 1 if greater, 0 if equal and -1 if less
+ */
+int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs)
+{
+	s64	count;
+
+	count = percpu_counter_read(fbc);
+	/* Check to see if rough count will be sufficient for comparison */
+	if (abs(count - rhs) > (percpu_counter_batch*num_online_cpus())) {
+		if (count > rhs)
+			return 1;
+		else
+			return -1;
+	}
+	/* Need to use precise count */
+	count = percpu_counter_sum(fbc);
+	if (count > rhs)
+		return 1;
+	else if (count < rhs)
+		return -1;
+	else
+		return 0;
+}
+EXPORT_SYMBOL(percpu_counter_compare);
+
 static int __init percpu_counter_startup(void)
 {
 	compute_batch_value();
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
