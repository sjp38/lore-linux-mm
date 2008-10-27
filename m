Date: Mon, 27 Oct 2008 17:54:55 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: deadlock with latest xfs
Message-ID: <20081027065455.GB4985@disturbed>
References: <4900412A.2050802@sgi.com> <20081023205727.GA28490@infradead.org> <49013C47.4090601@sgi.com> <20081024052418.GO25906@disturbed> <20081024064804.GQ25906@disturbed> <20081026005351.GK18495@disturbed> <20081026025013.GL18495@disturbed> <49051C71.9040404@sgi.com> <20081027053004.GF11948@disturbed> <49055FDE.7040709@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49055FDE.7040709@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lachlan McIlroy <lachlan@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 27, 2008 at 05:29:50PM +1100, Lachlan McIlroy wrote:
> Dave Chinner wrote:
>> On Mon, Oct 27, 2008 at 12:42:09PM +1100, Lachlan McIlroy wrote:
>>> Dave Chinner wrote:
>>>> On Sun, Oct 26, 2008 at 11:53:51AM +1100, Dave Chinner wrote:
>>>>> On Fri, Oct 24, 2008 at 05:48:04PM +1100, Dave Chinner wrote:
>>>>>> OK, I just hung a single-threaded rm -rf after this completed:
>>>>>>
>>>>>> # fsstress -p 1024 -n 100 -d /mnt/xfs2/fsstress
>>>>>>
>>>>>> It has hung with this trace:
>> ....
>>>> Got it now. I can reproduce this in a couple of minutes now that both
>>>> the test fs and the fs hosting the UML fs images are using lazy-count=1
>>>> (and the frequent 10s long host system freezes have gone away, too).
>>>>
>>>> Looks like *another* new memory allocation problem [1]:
>> .....
>>>> We've entered memory reclaim inside the xfsdatad while trying to do
>>>> unwritten extent completion during I/O completion, and that memory
>>>> reclaim is now blocked waiting for I/o completion that cannot make
>>>> progress.
>>>>
>>>> Nasty.
>>>>
>>>> My initial though is to make _xfs_trans_alloc() able to take a KM_NOFS argument
>>>> so we don't re-enter the FS here. If we get an ENOMEM in this case, we should
>>>> then re-queue the I/O completion at the back of the workqueue and let other
>>>> I/o completions progress before retrying this one. That way the I/O that
>>>> is simply cleaning memory will make progress, hence allowing memory
>>>> allocation to occur successfully when we retry this I/O completion...
>>> It could work - unless it's a synchronous I/O in which case the I/O is not
>>> complete until the extent conversion takes place.
>>
>> Right. Pushing unwritten extent conversion onto a different
>> workqueue is probably the only way to handle this easily.
>> That's the same solution Irix has been using for a long time
>> (the xfsc thread)....
>
> Would that be a workqueue specific to one filesystem?  Right now our
> workqueues are per-cpu so they can contain I/O completions for multiple
> filesystems.

I've simply implemented another per-cpu workqueue set.

>>> Could we allocate the memory up front before the I/O is issued?
>>
>> Possibly, but that will create more memory pressure than
>> allocation in I/O completion because now we could need to hold
>> thousands of allocations across an I/O - think of the case where
>> we are running low on memory and have a disk subsystem capable of
>> a few hundred thousand I/Os per second. the allocation failing would
>> prevent the I/os from being issued, and if this is buffered writes
>> into unwritten extents we'd be preventing dirty pages from being
>> cleaned....
>
> The allocation has to be done sometime - if have a few hundred thousand
> I/Os per second then the queue of unwritten extent conversion requests
> is going to grow very quickly.

Sure, but the difference is that in a workqueue we are doing:

	alloc
	free
	alloc
	free
	.....
	alloc
	free

So the instantaneous memory usage is bound by the number of
workqueue threads doing conversions. The "pre-allocate" case is:

	alloc
	alloc
	alloc
	alloc
	......
	<io completes>
	free
	.....
	<io_completes>
	free
	.....

so the allocation is bound by the number of parallel I/Os we have
not completed. Given that the transaction structure is *800* bytes,
they will consume memory very quickly if pre-allocated before the
I/O is dispatched.

> If a separate workqueue will fix this
> then that's a better solution anyway.

I think so. The patch I have been testing is below.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


XFS: Prevent unwritten extent conversion from blocking I/O completion

Unwritten extent conversion can recurse back into the filesystem due
to memory allocation. Memory reclaim requires I/O completions to be
processed to allow the callers to make progress. If the I/O
completion workqueue thread is doing the recursion, then we have a
deadlock situation.

Move unwritten extent completion into it's own workqueue so it
doesn't block I/O completions for normal delayed allocation or
overwrite data.

Signed-off-by: Dave Chinner <david@fromorbit.com>
---
 fs/xfs/linux-2.6/xfs_aops.c |   38 +++++++++++++++++++++-----------------
 fs/xfs/linux-2.6/xfs_aops.h |    1 +
 fs/xfs/linux-2.6/xfs_buf.c  |    9 +++++++++
 3 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_aops.c b/fs/xfs/linux-2.6/xfs_aops.c
index 6f4ebd0..f8fa620 100644
--- a/fs/xfs/linux-2.6/xfs_aops.c
+++ b/fs/xfs/linux-2.6/xfs_aops.c
@@ -119,23 +119,6 @@ xfs_find_bdev_for_inode(
 }
 
 /*
- * Schedule IO completion handling on a xfsdatad if this was
- * the final hold on this ioend. If we are asked to wait,
- * flush the workqueue.
- */
-STATIC void
-xfs_finish_ioend(
-	xfs_ioend_t	*ioend,
-	int		wait)
-{
-	if (atomic_dec_and_test(&ioend->io_remaining)) {
-		queue_work(xfsdatad_workqueue, &ioend->io_work);
-		if (wait)
-			flush_workqueue(xfsdatad_workqueue);
-	}
-}
-
-/*
  * We're now finished for good with this ioend structure.
  * Update the page state via the associated buffer_heads,
  * release holds on the inode and bio, and finally free
@@ -266,6 +249,27 @@ xfs_end_bio_read(
 }
 
 /*
+ * Schedule IO completion handling on a xfsdatad if this was
+ * the final hold on this ioend. If we are asked to wait,
+ * flush the workqueue.
+ */
+STATIC void
+xfs_finish_ioend(
+	xfs_ioend_t	*ioend,
+	int		wait)
+{
+	if (atomic_dec_and_test(&ioend->io_remaining)) {
+		struct workqueue_struct *wq = xfsdatad_workqueue;
+		if (ioend->io_work.func == xfs_end_bio_unwritten)
+			wq = xfsconvertd_workqueue;
+
+		queue_work(wq, &ioend->io_work);
+		if (wait)
+			flush_workqueue(wq);
+	}
+}
+
+/*
  * Allocate and initialise an IO completion structure.
  * We need to track unwritten extent write completion here initially.
  * We'll need to extend this for updating the ondisk inode size later
diff --git a/fs/xfs/linux-2.6/xfs_aops.h b/fs/xfs/linux-2.6/xfs_aops.h
index 3ba0631..7643f82 100644
--- a/fs/xfs/linux-2.6/xfs_aops.h
+++ b/fs/xfs/linux-2.6/xfs_aops.h
@@ -19,6 +19,7 @@
 #define __XFS_AOPS_H__
 
 extern struct workqueue_struct *xfsdatad_workqueue;
+extern struct workqueue_struct *xfsconvertd_workqueue;
 extern mempool_t *xfs_ioend_pool;
 
 typedef void (*xfs_ioend_func_t)(void *);
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index 36d5fcd..c1f55b3 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -45,6 +45,7 @@ static struct shrinker xfs_buf_shake = {
 
 static struct workqueue_struct *xfslogd_workqueue;
 struct workqueue_struct *xfsdatad_workqueue;
+struct workqueue_struct *xfsconvertd_workqueue;
 
 #ifdef XFS_BUF_TRACE
 void
@@ -1756,6 +1757,7 @@ xfs_flush_buftarg(
 	xfs_buf_t	*bp, *n;
 	int		pincount = 0;
 
+	xfs_buf_runall_queues(xfsconvertd_workqueue);
 	xfs_buf_runall_queues(xfsdatad_workqueue);
 	xfs_buf_runall_queues(xfslogd_workqueue);
 
@@ -1812,9 +1814,15 @@ xfs_buf_init(void)
 	if (!xfsdatad_workqueue)
 		goto out_destroy_xfslogd_workqueue;
 
+	xfsconvertd_workqueue = create_workqueue("xfsconvertd");
+	if (!xfsconvertd_workqueue)
+		goto out_destroy_xfsdatad_workqueue;
+
 	register_shrinker(&xfs_buf_shake);
 	return 0;
 
+ out_destroy_xfsdatad_workqueue:
+	destroy_workqueue(xfsdatad_workqueue);
  out_destroy_xfslogd_workqueue:
 	destroy_workqueue(xfslogd_workqueue);
  out_free_buf_zone:
@@ -1830,6 +1838,7 @@ void
 xfs_buf_terminate(void)
 {
 	unregister_shrinker(&xfs_buf_shake);
+	destroy_workqueue(xfsconvertd_workqueue);
 	destroy_workqueue(xfsdatad_workqueue);
 	destroy_workqueue(xfslogd_workqueue);
 	kmem_zone_destroy(xfs_buf_zone);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
