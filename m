Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6C64F6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 06:15:40 -0500 (EST)
Date: Mon, 7 Nov 2011 19:15:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Possible usage of uninitalized task_ratelimit variable in
 mm/page-writeback.c
Message-ID: <20111107111537.GA13453@localhost>
References: <20111107081824.GA18221@smp.if.uj.edu.pl>
 <20111107091704.GA29562@localhost>
 <20111107110558.GD18221@smp.if.uj.edu.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20111107110558.GD18221@smp.if.uj.edu.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Mon, Nov 07, 2011 at 07:05:58PM +0800, Witold Baryluk wrote:
> On 11-07 17:17, Wu Fengguang wrote:
> > On Mon, Nov 07, 2011 at 04:18:24PM +0800, Witold Baryluk wrote:
> > > Hi,
> > > 
> > > I found a minor issue when compiling kernel today
> > > 
> > > 
> > >   CC      mm/page-writeback.o
> > > mm/page-writeback.c: In function a??balance_dirty_pages_ratelimited_nra??:
> > > include/trace/events/writeback.h:281:1: warning: a??task_ratelimita?? may be used uninitialized in this function [-Wuninitialized]
> > > mm/page-writeback.c:1018:16: note: a??task_ratelimita?? was declared here
> > > 
> > > Indeed in balance_dirty_pages a task_ratelimit may be not initialized
> > > (initialization skiped by goto pause;), and then used when calling
> > > tracing hook.
> > 
> > Witold, thanks for the report! This patch should fix the bug.
> > 
> > Thanks,
> > Fengguang
> > ---
> > 
> > writeback: fix uninitialized task_ratelimit
> > 
> > In balance_dirty_pages() task_ratelimit may be not initialized
> > (initialization skiped by goto pause;), and then used when calling
> > tracing hook.
> > 
> > Fix it by moving the task_ratelimit assignment before goto pause.
> > 
> > Reported-by: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/page-writeback.c |    8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > --- linux.orig/mm/page-writeback.c	2011-11-07 17:07:04.080000043 +0800
> > +++ linux/mm/page-writeback.c	2011-11-07 17:08:43.232000031 +0800
> > @@ -1097,13 +1097,13 @@ static void balance_dirty_pages(struct a
> >  		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
> >  					       background_thresh, nr_dirty,
> >  					       bdi_thresh, bdi_dirty);
> > -		if (unlikely(pos_ratio == 0)) {
> > +		task_ratelimit = (u64)dirty_ratelimit *
> > +					pos_ratio >> RATELIMIT_CALC_SHIFT;
> > +		if (unlikely(task_ratelimit == 0)) {
> >  			pause = max_pause;
> >  			goto pause;
> >  		}
> > -		task_ratelimit = (u64)dirty_ratelimit *
> > -					pos_ratio >> RATELIMIT_CALC_SHIFT;
> > -		pause = (HZ * pages_dirtied) / (task_ratelimit | 1);
> > +		pause = (HZ * pages_dirtied) / task_ratelimit;
> >  		if (unlikely(pause <= 0)) {
> >  			trace_balance_dirty_pages(bdi,
> >  						  dirty_thresh,
> 
> Thanks.
> 
> This is very nice patch, fixes warning,
> and simplifies logic. I have no other objections.
> 
> (I do not remember what have bigger priority, * or >>
> - i guess * - but additional paranthesis can help. :D )

Good point! Just added/removed parentheses according to your suggestions :)

Thanks,
Fengguang
---
writeback: fix uninitialized task_ratelimit

In balance_dirty_pages() task_ratelimit may be not initialized
(initialization skiped by goto pause;), and then used when calling
tracing hook.

Fix it by moving the task_ratelimit assignment before goto pause.

Reported-by: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- linux.orig/mm/page-writeback.c	2011-11-07 19:11:39.660000042 +0800
+++ linux/mm/page-writeback.c	2011-11-07 19:12:19.856000041 +0800
@@ -1095,13 +1095,13 @@ static void balance_dirty_pages(struct a
 		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
 					       background_thresh, nr_dirty,
 					       bdi_thresh, bdi_dirty);
-		if (unlikely(pos_ratio == 0)) {
+		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
+							RATELIMIT_CALC_SHIFT;
+		if (unlikely(task_ratelimit == 0)) {
 			pause = max_pause;
 			goto pause;
 		}
-		task_ratelimit = (u64)dirty_ratelimit *
-					pos_ratio >> RATELIMIT_CALC_SHIFT;
-		pause = (HZ * pages_dirtied) / (task_ratelimit | 1);
+		pause = HZ * pages_dirtied / task_ratelimit;
 		if (unlikely(pause <= 0)) {
 			trace_balance_dirty_pages(bdi,
 						  dirty_thresh,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
