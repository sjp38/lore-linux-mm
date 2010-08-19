Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3FA766B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 21:42:53 -0400 (EDT)
Date: Thu, 19 Aug 2010 09:42:49 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [TESTCASE] Clean pages clogging the VM
Message-ID: <20100819014249.GA22092@sli10-desk.sh.intel.com>
References: <20100809133000.GB6981@wil.cx>
 <20100817195001.GA18817@linux.intel.com>
 <20100818141308.GD1779@cmpxchg.org>
 <20100818160613.GE9431@localhost>
 <20100818160731.GA15002@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818160731.GA15002@localhost>
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 12:07:31AM +0800, Wu, Fengguang wrote:
> On Thu, Aug 19, 2010 at 12:06:13AM +0800, Wu Fengguang wrote:
> > On Wed, Aug 18, 2010 at 04:13:08PM +0200, Johannes Weiner wrote:
> > > Hi Matthew,
> > > 
> > > On Tue, Aug 17, 2010 at 03:50:01PM -0400, Matthew Wilcox wrote:
> > > > 
> > > > No comment on this?  Was it just that I posted it during the VM summit?
> > > 
> > > I have not forgotten about it.  I just have a hard time reproducing
> > > those extreme stalls you observed.
> > > 
> > > Running that test on a 2.5GHz machine with 2G of memory gives me
> > > stalls of up to half a second.  The patchset I am experimenting with
> > > gets me down to peaks of 70ms, but it needs further work.
> > > 
> > > Mapped file pages get two rounds on the LRU list, so once the VM
> > > starts scanning, it has to go through all of them twice and can only
> > > reclaim them on the second encounter.
> > > 
> > > At that point, since we scan without making progress, we start waiting
> > > for IO, which is not happening in this case, so we sit there until a
> > > timeout expires.
> > 
> > Right, this could lead to some 1s stall. Shaohua and me also noticed
> > this when investigating the responsiveness issues. And we are wondering
> > if it makes sense to do congestion_wait() only when the bdi is really
> > congested? There are no IO underway anyway in this case.
> > 
> > > This stupid-waiting can be improved, and I am working on that.  But
> > 
> > Yeah, stupid waiting :)
How about this one?


Subject: mm: check device is really congested before sleep in direct page reclaim

congestion_wait() blindly sleep without checking if device is really congested.
In a workload without any write, it can cause direct page reclaim sleep 100ms
and hasn't any help for page reclaim.
There might be other places calling congestion_wait() and need check if
device is really congested, but I can't audit all, so this just changes the
direct page reclaim code path. The new congestion_wait_check() will make sure
at least one device is congested before going into sleep.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 include/linux/backing-dev.h |    1 +
 mm/backing-dev.c            |   14 ++++++++++++--
 mm/vmscan.c                 |    2 +-
 3 files changed, 14 insertions(+), 3 deletions(-)

Index: linux/mm/backing-dev.c
===================================================================
--- linux.orig/mm/backing-dev.c	2010-08-18 16:41:04.000000000 +0800
+++ linux/mm/backing-dev.c	2010-08-19 08:59:14.000000000 +0800
@@ -725,13 +725,16 @@ static wait_queue_head_t congestion_wqh[
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
 	};
 
+static atomic_t nr_congested_bdi[2];
+
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
 {
 	enum bdi_state bit;
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
 	bit = sync ? BDI_sync_congested : BDI_async_congested;
-	clear_bit(bit, &bdi->state);
+	if (test_and_clear_bit(bit, &bdi->state))
+		atomic_dec(&nr_congested_bdi[sync]);
 	smp_mb__after_clear_bit();
 	if (waitqueue_active(wqh))
 		wake_up(wqh);
@@ -743,7 +746,8 @@ void set_bdi_congested(struct backing_de
 	enum bdi_state bit;
 
 	bit = sync ? BDI_sync_congested : BDI_async_congested;
-	set_bit(bit, &bdi->state);
+	if (!test_and_set_bit(bit, &bdi->state))
+		atomic_inc(&nr_congested_bdi[sync]);
 }
 EXPORT_SYMBOL(set_bdi_congested);
 
@@ -769,3 +773,9 @@ long congestion_wait(int sync, long time
 }
 EXPORT_SYMBOL(congestion_wait);
 
+long congestion_wait_check(int sync, long timeout)
+{
+	if (atomic_read(&nr_congested_bdi[sync]) == 0)
+		return 0;
+	return congestion_wait(sync, timeout);
+}
Index: linux/include/linux/backing-dev.h
===================================================================
--- linux.orig/include/linux/backing-dev.h	2010-08-18 16:41:04.000000000 +0800
+++ linux/include/linux/backing-dev.h	2010-08-18 16:41:23.000000000 +0800
@@ -285,6 +285,7 @@ enum {
 void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
 void set_bdi_congested(struct backing_dev_info *bdi, int sync);
 long congestion_wait(int sync, long timeout);
+long congestion_wait_check(int sync, long timeout);
 
 
 static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2010-08-18 16:41:04.000000000 +0800
+++ linux/mm/vmscan.c	2010-08-18 16:41:23.000000000 +0800
@@ -1910,7 +1910,7 @@ static unsigned long do_try_to_free_page
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
 		    priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			congestion_wait_check(BLK_RW_ASYNC, HZ/10);
 	}
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
