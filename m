Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 152626B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 10:08:27 -0400 (EDT)
Date: Tue, 28 Sep 2010 09:08:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20100928135148.GM8187@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009280907110.6360@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009280838540.6360@router.home> <20100928135148.GM8187@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 28 Sep 2010, Mel Gorman wrote:

> On Tue, Sep 28, 2010 at 08:40:15AM -0500, Christoph Lameter wrote:
> > On Tue, 28 Sep 2010, Mel Gorman wrote:
> >
> > > Which of these is better or is there an alternative suggestion on how
> > > this livelock can be avoided?
> >
> > We need to run some experiments to see what is worse. Lets start by
> > cutting both the stats threshold and the drift thing in half?
> >
>
> Ok, I have no problem with that although again, I'm really not in the position
> to roll patches for it right now. I don't want to get side-tracked.

Ok the stat threshold determines the per_cpu_drift_mark.

So changing the threshold should do the trick. Try this:

---
 mm/vmstat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2010-09-28 09:04:48.000000000 -0500
+++ linux-2.6/mm/vmstat.c	2010-09-28 09:05:16.000000000 -0500
@@ -118,7 +118,7 @@ static int calculate_threshold(struct zo

 	mem = zone->present_pages >> (27 - PAGE_SHIFT);

-	threshold = 2 * fls(num_online_cpus()) * (1 + fls(mem));
+	threshold = fls(num_online_cpus()) * (1 + fls(mem));

 	/*
 	 * Maximum threshold is 125

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
