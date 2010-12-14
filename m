Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4F5226B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 08:00:27 -0500 (EST)
Date: Tue, 14 Dec 2010 21:00:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 12/35] writeback: scale down max throttle bandwidth on
 concurrent dirtiers
Message-ID: <20101214130018.GA19424@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150327.809762057@intel.com>
 <AANLkTim_4v9D3uj9McRWo8nAJW=NT8dRPe4nbTiDbvn_@mail.gmail.com>
 <20101214070005.GB6940@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101214070005.GB6940@localhost>
Sender: owner-linux-mm@kvack.org
To: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 03:00:05PM +0800, Wu Fengguang wrote:
> On Tue, Dec 14, 2010 at 09:21:19AM +0800, Yan Zheng wrote:
> > On Mon, Dec 13, 2010 at 10:46 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > This will noticeably reduce the fluctuaions of pause time when there are
> > > 100+ concurrent dirtiers.
> > >
> > > The more parallel dirtiers (1 dirtier => 4 dirtiers), the smaller
> > > bandwidth each dirtier will share (bdi_bandwidth => bdi_bandwidth/4),
> > > the less gap to the dirty limit ((C-A) => (C-B)), the less stable the
> > > pause time will be (given the same fluctuation of bdi_dirty).
> > >
> > > For example, if A drifts to A', its pause time may drift from 5ms to
> > > 6ms, while B to B' may drift from 50ms to 90ms. A It's much larger
> > > fluctuations in relative ratio as well as absolute time.
> > >
> > > Fig.1 before patch, gap (C-B) is too low to get smooth pause time
> > >
> > > throttle_bandwidth_A = bdi_bandwidth .........o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | o <= A'
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  A  o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  A  A  o
> > > throttle_bandwidth_B = bdi_bandwidth / 4 .....|...........o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  A  A  A  | o <= B'
> > > ----------------------------------------------+-----------+---o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A A A  A  A  A  A  B A  C
> > >
> > > The solution is to lower the slope of the throttle line accordingly,
> > > which makes B stabilize at some point more far away from C.
> > >
> > > Fig.2 after patch
> > >
> > > throttle_bandwidth_A = bdi_bandwidth .........o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | o <= A'
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  o
> > > A  A lowered max throttle bandwidth for B ===> * A  A  A  o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  * A  A  o
> > > throttle_bandwidth_B = bdi_bandwidth / 4 .............* A  o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  A  | A  * o
> > > ----------------------------------------------+-------+-------o
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A A A  A  A  B A  A  A  C
> > >
> > > Note that C is actually different points for 1-dirty and 4-dirtiers
> > > cases, but for easy graphing, we move them together.
> > >
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > > A mm/page-writeback.c | A  16 +++++++++++++---
> > > A 1 file changed, 13 insertions(+), 3 deletions(-)
> > >
> > > --- linux-next.orig/mm/page-writeback.c 2010-12-13 21:46:14.000000000 +0800
> > > +++ linux-next/mm/page-writeback.c A  A  A 2010-12-13 21:46:15.000000000 +0800
> > > @@ -587,6 +587,7 @@ static void balance_dirty_pages(struct a
> > > A  A  A  A unsigned long background_thresh;
> > > A  A  A  A unsigned long dirty_thresh;
> > > A  A  A  A unsigned long bdi_thresh;
> > > + A  A  A  unsigned long task_thresh;
> > > A  A  A  A unsigned long long bw;
> > > A  A  A  A unsigned long period;
> > > A  A  A  A unsigned long pause = 0;
> > > @@ -616,7 +617,7 @@ static void balance_dirty_pages(struct a
> > > A  A  A  A  A  A  A  A  A  A  A  A break;
> > >
> > > A  A  A  A  A  A  A  A bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, nr_dirty);
> > > - A  A  A  A  A  A  A  bdi_thresh = task_dirty_limit(current, bdi_thresh);
> > > + A  A  A  A  A  A  A  task_thresh = task_dirty_limit(current, bdi_thresh);
> > >
> > > A  A  A  A  A  A  A  A /*
> > > A  A  A  A  A  A  A  A  * In order to avoid the stacked BDI deadlock we need
> > > @@ -638,14 +639,23 @@ static void balance_dirty_pages(struct a
> > >
> > > A  A  A  A  A  A  A  A bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
> > >
> > > - A  A  A  A  A  A  A  if (bdi_dirty >= bdi_thresh || nr_dirty > dirty_thresh) {
> > > + A  A  A  A  A  A  A  if (bdi_dirty >= task_thresh || nr_dirty > dirty_thresh) {
> > > A  A  A  A  A  A  A  A  A  A  A  A pause = MAX_PAUSE;
> > > A  A  A  A  A  A  A  A  A  A  A  A goto pause;
> > > A  A  A  A  A  A  A  A }
> > >
> > > + A  A  A  A  A  A  A  /*
> > > + A  A  A  A  A  A  A  A * When bdi_dirty grows closer to bdi_thresh, it indicates more
> > > + A  A  A  A  A  A  A  A * concurrent dirtiers. Proportionally lower the max throttle
> > > + A  A  A  A  A  A  A  A * bandwidth. This will resist bdi_dirty from approaching to
> > > + A  A  A  A  A  A  A  A * close to task_thresh, and help reduce fluctuations of pause
> > > + A  A  A  A  A  A  A  A * time when there are lots of dirtiers.
> > > + A  A  A  A  A  A  A  A */
> > > A  A  A  A  A  A  A  A bw = bdi->write_bandwidth;
> > > -
> > > A  A  A  A  A  A  A  A bw = bw * (bdi_thresh - bdi_dirty);
> > > + A  A  A  A  A  A  A  do_div(bw, bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
> > > +
> > > + A  A  A  A  A  A  A  bw = bw * (task_thresh - bdi_dirty);
> > > A  A  A  A  A  A  A  A do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
> > 
> > Maybe changing this line to "do_div(bw, task_thresh /
> > TASK_SOFT_DIRTY_LIMIT + 1);"
> > is more consistent.
> 
> I'll show you another consistency of "shape" :)
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/light-dirtier-control-line.svg
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/heavy-dirtier-control-line.svg
> 
> In the above two figures, the overall control lines for light/heavy
> dirtier tasks have exactly the same shape -- it's merely shifted in
> the X axis direction. So the current form is actually more simple.

Sorry it's not the overall control lines that's simply shifted, but
the task control line.

bdi control line:
> > > A  A  A  A  A  A  A  A bw = bw * (bdi_thresh - bdi_dirty);
> > > + A  A  A  A  A  A  A  do_div(bw, bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);

task control line:
> > > + A  A  A  A  A  A  A  bw = bw * (task_thresh - bdi_dirty);
> > > A  A  A  A  A  A  A  A do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);

The use of bdi_thresh in the last line makes sure all task control
lines are of the same slope.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
