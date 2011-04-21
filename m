Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 92B788D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:33:36 -0400 (EDT)
Date: Thu, 21 Apr 2011 11:33:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110421033325.GA13764@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
 <20110420075053.GB30672@localhost>
 <20110420152211.GC4991@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <20110420152211.GC4991@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 20, 2011 at 11:22:11PM +0800, Jan Kara wrote:
> On Wed 20-04-11 15:50:53, Wu Fengguang wrote:
> > > > >   Let me understand your concern here: You are afraid that if we do
> > > > > for_background or for_kupdate writeback and we write less than
> > > > > MAX_WRITEBACK_PAGES, we stop doing writeback although there could be more
> > > > > inodes to write at the time we are stopping writeback - the two realistic
> > > > 
> > > > Yes.
> > > > 
> > > > > cases I can think of are:
> > > > > a) when inodes just freshly expired during writeback
> > > > > b) when bdi has less than MAX_WRITEBACK_PAGES of dirty data but we are over
> > > > >   background threshold due to data on some other bdi. And then while we are
> > > > >   doing writeback someone does dirtying at our bdi.
> > > > > Or do you see some other case as well?
> > > > > 
> > > > > The a) case does not seem like a big issue to me after your changes to
> > > > 
> > > > Yeah (a) is not an issue with kupdate writeback.
> > > > 
> > > > > move_expired_inodes(). The b) case maybe but do you think it will make any
> > > > > difference? 
> > > > 
> > > > (b) seems also weird. What in my mind is this for_background case.
> > > > Imagine 100 inodes
> > > > 
> > > >         i0, i1, i2, ..., i90, i91, i99
> > > > 
> > > > At queue_io() time, i90-i99 happen to be expired and moved to s_io for
> > > > IO. When finished successfully, if their total size is less than
> > > > MAX_WRITEBACK_PAGES, nr_to_write will be > 0. Then wb_writeback() will
> > > > quit the background work (w/o this patch) while it's still over
> > > > background threshold.
> > > > 
> > > > This will be a fairly normal/frequent case I guess.
> > >   Ah OK, I see. I missed this case your patch set has added. Also your
> > > changes of
> > >         if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > > to
> > > 	if (list_empty(&wb->b_io))
> > > are going to cause more cases when we'd hit nr_to_write > 0 (e.g. when one
> > > pass of b_io does not write all the inodes so some are left in b_io list
> > > and then next call to writeback finds these inodes there but there's less
> > > than MAX_WRITEBACK_PAGES in them).
> > 
> > Yes. It's exactly the more aggressive retry logic in wb_writeback()
> > that allows me to comfortably kill that !wbc->for_kupdate test :)
> > 
> > > Frankly, it makes me like the above change even less. I'd rather see
> > > writeback_inodes_wb / __writeback_inodes_sb always work on a fresh
> > > set of inodes which is initialized whenever we enter these
> > > functions. It just seems less surprising to me...
> > 
> > The old aggressive enqueue policy is an ad-hoc workaround to prevent
> > background work to miss some inodes and quit early. Now that we have
> > the complete solution, why not killing it for more consistent code and
> > behavior? And get better performance numbers :)
>   BTW, have you understood why do you get better numbers? What are we doing
> better with this changed logic?

Good question. I'm also puzzled to find it run consistently better on
4MB, 32MB and 128MB write chunk sizes, with/without the IO-less and
larger chunk size patches.

It's not about pageout(), because I see "nr_vmscan_write 0" in
/proc/vmstat in the tests.

It's not about the full vs. remained chunk size -- it may helped the
vanilla kernel, but the "writeback: make nr_to_write a per-file limit"
as part of the large chunk size patches already guarantee each file
will get the full chunk size.

I collected the writeback_single_inode() traces (patch attached for
your reference) each for several test runs, and find much more
I_DIRTY_PAGES after patchset. Dave, do you know why there are so many
I_DIRTY_PAGES (or radix tag) remained after the XFS ->writepages() call,
even for small files?

wfg /tmp% g -c I_DIRTY_PAGES trace-*
trace-moving-expire-1:28213
trace-no-moving-expire:6684

wfg /tmp% g -c I_DIRTY_DATASYNC trace-*
trace-moving-expire-1:179
trace-no-moving-expire:193

wfg /tmp% g -c I_DIRTY_SYNC trace-* 
trace-moving-expire-1:29394
trace-no-moving-expire:31593

wfg /tmp% wc -l trace-*
   81108 trace-moving-expire-1
   68562 trace-no-moving-expire

wfg /tmp% head trace-*
==> trace-moving-expire-1 <==
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
           <...>-2982  [000]   633.671746: writeback_single_inode: bdi 8:0: ino=131 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=1177 wrote=1025 to_write=-1 index=21525
           <...>-2982  [000]   633.672704: writeback_single_inode: bdi 8:0: ino=131 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=1178 wrote=1025 to_write=-1 index=22550
           <...>-2982  [000]   633.673638: writeback_single_inode: bdi 8:0: ino=131 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=1179 wrote=1025 to_write=-1 index=23575
           <...>-2982  [000]   633.674573: writeback_single_inode: bdi 8:0: ino=131 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=1180 wrote=1025 to_write=-1 index=24600
           <...>-2982  [000]   633.880621: writeback_single_inode: bdi 8:0: ino=131 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=1387 wrote=1025 to_write=-1 index=25625
           <...>-2982  [000]   633.881345: writeback_single_inode: bdi 8:0: ino=131 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=1388 wrote=1025 to_write=-1 index=26650

==> trace-no-moving-expire <==
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
           <...>-2233  [006]   311.175491: writeback_single_inode: bdi 0:15: ino=1574019 state=I_DIRTY_DATASYNC|I_REFERENCED age=0 wrote=0 to_write=1024 index=0
           <...>-2233  [006]   311.175495: writeback_single_inode: bdi 0:15: ino=1536569 state=I_DIRTY_DATASYNC|I_REFERENCED age=0 wrote=0 to_write=1024 index=0
           <...>-2233  [006]   311.175498: writeback_single_inode: bdi 0:15: ino=1534002 state=I_DIRTY_DATASYNC|I_REFERENCED age=0 wrote=0 to_write=1024 index=0
           <...>-2233  [006]   311.175515: writeback_single_inode: bdi 0:15: ino=1574042 state=I_DIRTY_DATASYNC age=25000 wrote=1 to_write=1023 index=0
           <...>-2233  [006]   311.175522: writeback_single_inode: bdi 0:15: ino=1574028 state=I_DIRTY_DATASYNC age=25000 wrote=1 to_write=1022 index=137685
           <...>-2233  [006]   311.175524: writeback_single_inode: bdi 0:15: ino=1574024 state=I_DIRTY_DATASYNC age=25000 wrote=0 to_write=1022 index=0

> I've though about it and also about Dave's analysis. Now I think it's OK to
> not add new inodes to b_io when it's not empty. But what I still don't like
> is that the emptiness / non-emptiness of b_io carries hidden internal
> state - callers of writeback_inodes_wb() shouldn't have to know or care
> about such subtleties (__writeback_inodes_sb() is an internal function so I
> don't care about that one too much).

That's why we liked the v1 implementation :)

> So I'd prefer writeback_inodes_wb() (and also __writeback_inodes_sb() but
> that's not too important) to do something like:
> 	int requeued = 0;
> requeue:
> 	if (list_empty(&wb->b_io)) {
> 		queue_io(wb, wbc->older_than_this);
> 		requeued = 1;
> 	}
> 	while (!list_empty(&wb->b_io)) {
> 		... do stuff ...
> 	}
> 	if (wbc->nr_to_write > 0 && !requeued)
> 		goto requeue;

But that change must be coupled with older_than_this switch,
and doing it here you both lose the wbc visibility and scatters
the policy around..

> Because if you don't do this, you have to do similar change to all the
> callers of writeback_inodes_wb() (Ok, there are just three but still).

I find only one more caller: bdi_flush_io() and it sets
older_than_this to NULL. In fact wb_writeback() is the only user of
older_than_this, originally for kupdate work and now also for
background work.

Basically we only need the retry when did policy switch, so
it makes sense to do it either completely in wb_writeback() or
in move_expired_inodes()?

Thanks,
Fengguang

--BOKacYhQ+x31HxR3
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-trace-writeback_single_inode.patch"

Subject: writeback: trace writeback_single_inode
Date: Wed Dec 01 17:33:37 CST 2010

It is valuable to know how the dirty inodes are iterated and their IO size.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |   12 +++---
 include/trace/events/writeback.h |   56 +++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-04-13 17:18:19.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-13 17:18:20.000000000 +0800
@@ -347,7 +347,7 @@ writeback_single_inode(struct inode *ino
 {
 	struct address_space *mapping = inode->i_mapping;
 	long per_file_limit = wbc->per_file_limit;
-	long uninitialized_var(nr_to_write);
+	long nr_to_write = wbc->nr_to_write;
 	unsigned dirty;
 	int ret;
 
@@ -370,7 +370,8 @@ writeback_single_inode(struct inode *ino
 		 */
 		if (wbc->sync_mode != WB_SYNC_ALL) {
 			requeue_io(inode);
-			return 0;
+			ret = 0;
+			goto out;
 		}
 
 		/*
@@ -387,10 +388,8 @@ writeback_single_inode(struct inode *ino
 	spin_unlock(&inode->i_lock);
 	spin_unlock(&inode_wb_list_lock);
 
-	if (per_file_limit) {
-		nr_to_write = wbc->nr_to_write;
+	if (per_file_limit)
 		wbc->nr_to_write = per_file_limit;
-	}
 
 	ret = do_writepages(mapping, wbc);
 
@@ -467,6 +466,9 @@ writeback_single_inode(struct inode *ino
 		}
 	}
 	inode_sync_complete(inode);
+out:
+	trace_writeback_single_inode(inode, wbc,
+				     nr_to_write - wbc->nr_to_write);
 	return ret;
 }
 
--- linux-next.orig/include/trace/events/writeback.h	2011-04-13 17:18:18.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-04-13 17:18:20.000000000 +0800
@@ -10,6 +10,19 @@
 
 struct wb_writeback_work;
 
+#define show_inode_state(state)					\
+	__print_flags(state, "|",				\
+		{I_DIRTY_SYNC,		"I_DIRTY_SYNC"},	\
+		{I_DIRTY_DATASYNC,	"I_DIRTY_DATASYNC"},	\
+		{I_DIRTY_PAGES,		"I_DIRTY_PAGES"},	\
+		{I_NEW,			"I_NEW"},		\
+		{I_WILL_FREE,		"I_WILL_FREE"},		\
+		{I_FREEING,		"I_FREEING"},		\
+		{I_CLEAR,		"I_CLEAR"},		\
+		{I_SYNC,		"I_SYNC"},		\
+		{I_REFERENCED,		"I_REFERENCED"}		\
+		)
+
 DECLARE_EVENT_CLASS(writeback_work_class,
 	TP_PROTO(struct backing_dev_info *bdi, struct wb_writeback_work *work),
 	TP_ARGS(bdi, work),
@@ -149,6 +162,49 @@ DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+TRACE_EVENT(writeback_single_inode,
+
+	TP_PROTO(struct inode *inode,
+		 struct writeback_control *wbc,
+		 unsigned long wrote
+	),
+
+	TP_ARGS(inode, wbc, wrote),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long, ino)
+		__field(unsigned long, state)
+		__field(unsigned long, age)
+		__field(unsigned long, wrote)
+		__field(long, nr_to_write)
+		__field(unsigned long, writeback_index)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->state		= inode->i_state;
+		__entry->age		= (jiffies - inode->dirtied_when) *
+								1000 / HZ;
+		__entry->wrote		= wrote;
+		__entry->nr_to_write	= wbc->nr_to_write;
+		__entry->writeback_index = inode->i_mapping->writeback_index;
+	),
+
+	TP_printk("bdi %s: ino=%lu state=%s age=%lu "
+		  "wrote=%lu to_write=%ld index=%lu",
+		  __entry->name,
+		  __entry->ino,
+		  show_inode_state(__entry->state),
+		  __entry->age,
+		  __entry->wrote,
+		  __entry->nr_to_write,
+		  __entry->writeback_index
+	)
+);
+
 #define KBps(x)			((x) << (PAGE_SHIFT - 10))
 
 TRACE_EVENT(dirty_ratelimit,

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
