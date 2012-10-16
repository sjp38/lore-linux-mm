Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 178B46B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:09:35 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so3710399dad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 06:09:34 -0700 (PDT)
Date: Tue, 16 Oct 2012 22:09:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
Message-ID: <20121016130927.GA5603@barrios>
References: <1350278059-14904-1-git-send-email-ming.lei@canonical.com>
 <1350278059-14904-2-git-send-email-ming.lei@canonical.com>
 <20121015154724.GA2840@barrios>
 <CACVXFVM09H=8ZuFSzkcN1NmOCR1pcPUsuUyT9tpR0doVam2BiQ@mail.gmail.com>
 <20121016054946.GA3934@barrios>
 <CACVXFVOdohPprD7N69=Tz2keTbLG7b-s5324OUX-oY84Jszumg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVOdohPprD7N69=Tz2keTbLG7b-s5324OUX-oY84Jszumg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Tue, Oct 16, 2012 at 03:08:41PM +0800, Ming Lei wrote:
> On Tue, Oct 16, 2012 at 1:49 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > Fair enough but it wouldn't be a good idea that add new unlikely branch
> > in allocator's fast path. Please move the check into slow path which could
> > be in __alloc_pages_slowpath.
> 
> Thanks for your comment.
> 
> I have considered to add the branch into gfp_to_alloc_flags() before,
> but didn't do it because I see that get_page_from_freelist() may use
> the GFP_IO or GFP_FS flag at least in zone_reclaim() path.

Good point. You can check it in __zone_reclaim and change gfp_mask of scan_control
because it's never hot path.

> 
> So could you make sure it is safe to move the branch into
> __alloc_pages_slowpath()?  If so, I will add the check into
> gfp_to_alloc_flags().

How about this?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d976957..b3607fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2614,10 +2614,16 @@ retry_cpuset:
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
 			preferred_zone, migratetype);
-	if (unlikely(!page))
+	if (unlikely(!page)) {
+		/*
+		 * Resume path can deadlock because block device
+		 * isn't active yet.
+		 */
+		if (unlikely(tsk_memalloc_no_io(current)))
+			gfp_mask &= ~GFP_IOFS;
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
+	}
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b5e45f4..6c2ccdd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3290,6 +3290,16 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	};
 	unsigned long nr_slab_pages0, nr_slab_pages1;
 
+	if (unlikely(tsk_memalloc_no_io(current))) {
+		sc.gfp_mask &= ~GFP_IOFS;
+		shrink.gfp_mask = sc.gfp_mask;
+		/*
+		 * We allow to reclaim only clean pages.
+		 * It can affect RECLAIM_SWAP and RECLAIM_WRITE mode
+		 * but this is really rare event and allocator can
		 * fallback to other zones.
+		 */
+		sc.may_writepage = 0;
+		sc.may_swap = 0;
+	}
+
 	cond_resched();
 	/*
 	 * We need to be able to allocate from the reserves for RECLAIM_SWAP


> 
> 
> Thanks,
> --
> Ming Lei
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
