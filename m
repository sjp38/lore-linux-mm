Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6E6D56B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 23:47:21 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0F4lIsn000973
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 15 Jan 2010 13:47:18 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4374745DE51
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 13:47:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F47B45DE4E
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 13:47:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F40991DB8038
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 13:47:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99E091DB803E
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 13:47:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH] mm: Restore zone->all_unreclaimable to independence word
In-Reply-To: <20100115113035.0acbb3dc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100114151959.2c46ee79.akpm@linux-foundation.org> <20100115113035.0acbb3dc.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20100115134614.6ECF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 Jan 2010 13:47:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 14 Jan 2010 15:19:59 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 14 Jan 2010 16:32:29 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > On Thu, Jan 14, 2010 at 03:14:10PM +0800, KOSAKI Motohiro wrote:
> > > > > On Thu, 14 Jan 2010, KOSAKI Motohiro wrote:
> > > > > 
> > > > > > commit e815af95 (change all_unreclaimable zone member to flags) chage
> > > > > > all_unreclaimable member to bit flag. but It have undesireble side
> > > > > > effect.
> > > > > > free_one_page() is one of most hot path in linux kernel and increasing
> > > > > > atomic ops in it can reduce kernel performance a bit.
> > > > > > 
> > > > > > Thus, this patch revert such commit partially. at least
> > > > > > all_unreclaimable shouldn't share memory word with other zone flags.
> > > > > > 
> > > > > 
> > > > > I still think you need to quantify this; saying you don't have a large 
> > > > > enough of a machine that will benefit from it isn't really a rationale for 
> > > > > the lack of any data supporting your claim.  We should be basing VM 
> > > > > changes on data, not on speculation that there's a measurable impact 
> > > > > here.
> > > > > 
> > > > > Perhaps you could ask a colleague or another hacker to run a benchmark for 
> > > > > you so that the changelog is complete?
> > > > 
> > > > ok, fair. although I dislike current unnecessary atomic-ops.
> > > > I'll pending this patch until get good data.
> > > 
> > > I think it's a reasonable expectation to help large boxes.
> > > 
> > > What we can do now, is to measure if it hurts mainline SMP
> > > boxes. If not, we are set on doing the patch :)
> > 
> > yup, the effects of the change might be hard to measure.  Not that one
> > shouldn't try!
> > 
> > But sometimes we just have to do a best-effort change based upon theory
> > and past experience.
> > 
> > Speaking of which...
> > 
> > : --- a/include/linux/mmzone.h
> > : +++ b/include/linux/mmzone.h
> > : @@ -341,6 +341,7 @@ struct zone {
> > :  
> > :  	unsigned long		pages_scanned;	   /* since last reclaim */
> > :  	unsigned long		flags;		   /* zone flags, see below */
> > : +	int                     all_unreclaimable; /* All pages pinned */
> > :  
> > :  	/* Zone statistics */
> > :  	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
> > 
> > Was that the best place to put the field?  It adds four bytes of
> > padding to the zone, hence is suboptimal from a cache utilisation point
> > of view.
> > 
> > It might also be that we can place this field closed in memory to other
> > fields which are being manipulated at the same time as
> > all_unreclaimable, hm?
> > 
> How about the same line where zone->lock is ?

Sure. page allocator obviously touch zone->lock at first.
Incremental patch is here.


---
 include/linux/mmzone.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4f0c6f1..0df3749 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -314,6 +314,7 @@ struct zone {
 	 * free areas of different sizes
 	 */
 	spinlock_t		lock;
+	int                     all_unreclaimable; /* All pages pinned */
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
@@ -341,7 +342,6 @@ struct zone {
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
-	int                     all_unreclaimable; /* All pages pinned */
 
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
-- 
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
