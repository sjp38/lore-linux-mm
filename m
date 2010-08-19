Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A2EA86B020D
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:22:45 -0400 (EDT)
Received: by pzk33 with SMTP id 33so879820pzk.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 08:22:41 -0700 (PDT)
Date: Fri, 20 Aug 2010 00:22:33 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100819152233.GD6805@barrios-desktop>
References: <20100817142040.GA3884@barrios-desktop>
 <20100818085123.GU19797@csn.ul.ie>
 <20100818145725.GA5744@barrios-desktop>
 <20100819080624.GX19797@csn.ul.ie>
 <AANLkTi=Mtc_7b5WG4nmwbFYg8yijyMSG1AUTzy+QTwoy@mail.gmail.com>
 <20100819103839.GZ19797@csn.ul.ie>
 <20100819140150.GA6805@barrios-desktop>
 <20100819140946.GA19797@csn.ul.ie>
 <20100819143439.GB6805@barrios-desktop>
 <20100819150739.GB19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100819150739.GB19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 04:07:39PM +0100, Mel Gorman wrote:
> On Thu, Aug 19, 2010 at 11:34:39PM +0900, Minchan Kim wrote:
> > On Thu, Aug 19, 2010 at 03:09:46PM +0100, Mel Gorman wrote:
> > > On Thu, Aug 19, 2010 at 11:01:50PM +0900, Minchan Kim wrote:
> > > > On Thu, Aug 19, 2010 at 11:38:39AM +0100, Mel Gorman wrote:
> > > > > On Thu, Aug 19, 2010 at 07:33:57PM +0900, Minchan Kim wrote:
> > > > > > On Thu, Aug 19, 2010 at 5:06 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > > > > > > On Wed, Aug 18, 2010 at 11:57:26PM +0900, Minchan Kim wrote:
> > > > > > >> On Wed, Aug 18, 2010 at 09:51:23AM +0100, Mel Gorman wrote:
> > > > > > >> > > What's a window low and min wmark? Maybe I can miss your point.
> > > > > > >> > >
> > > > > > >> >
> > > > > > >> > The window is due to the fact kswapd is not awake yet. The window is because
> > > > > > >> > kswapd might not be awake as NR_FREE_PAGES is higher than it should be. The
> > > > > > >> > system is really somewhere between the low and min watermark but we are not
> > > > > > >> > taking the accurate measure until kswapd gets woken up. The first allocation
> > > > > > >> > to notice we are below the low watermark (be it due to vmstat refreshing or
> > > > > > >> > that NR_FREE_PAGES happens to report we are below the watermark regardless of
> > > > > > >> > any drift) wakes kswapd and other callers then take an accurate count hence
> > > > > > >> > "we could breach the watermark but I'm expecting it can only happen for at
> > > > > > >> > worst one allocation".
> > > > > > >>
> > > > > > >> Right. I misunderstood your word.
> > > > > > >> One more question.
> > > > > > >>
> > > > > > >> Could you explain live lock scenario?
> > > > > > >>
> > > > > > >
> > > > > > > Lets say
> > > > > > >
> > > > > > > NR_FREE_PAGES     = 256
> > > > > > > Actual free pages = 8
> > > > > > >
> > > > > > > The PCP lists get refilled in patch taking all 8 pages. Now there are
> > > > > > > zero free pages. Reclaim kicks in but to reclaim any pages it needs to
> > > > > > > clean something but all the pages are on a network-backed filesystem. To
> > > > > > > clean them, it must transmit on the network so it tries to allocate some
> > > > > > > buffers.
> > > > > > >
> > > > > > > The livelock is that to free some memory, an allocation must succeed but
> > > > > > > for an allocation to succeed, some memory must be freed. The system
> > > > > > 
> > > > > > Yes. I understood this as livelock but at last VM will kill victim
> > > > > > process then it can allocate free pages.
> > > > > 
> > > > > And if the exit path for the OOM kill needs to allocate a page what
> > > > > should it do?
> > > > 
> > > > Yeah. It might be livelock. 
> > > > Then, let's rethink the problem. 
> > > > 
> > > > The problem is following as. 
> > > > 
> > > > 1. Process A try to allocate the page
> > > > 2. VM try to reclaim the page for process A
> > > > 3. VM reclaims some pages but it remains on PCP so can't allocate pages for A
> > > > 4. VM try to kill process B
> > > > 5. The exit path need new pages for exiting process B
> > > > 6. Livelock happens(I am not sure but we need any warning if it really happens at least)
> > > > 
> > > 
> > > The problem this patch is concerned with is about the vmstat counters, not
> > > the pages on the per-cpu lists. The issue being dealt with is that the page
> > > allocator grants a page going below the min watermark because NR_FREE_PAGES
> > > can be inaccurate. The patch aims to fix that but taking greater care
> > > with NR_FREE_PAGES when memory is low.
> > 
> > Your goal is to protect _min_ pages which is reserved. Right?
> > I thought your final goal is to protect the livelock problem. 
> > Hmm.. Sorry for the noise. :(
> > 
> 
> Emm, it's the same thing. If the min watermark is not properly
> preserved, the system is in danger of being live-locked.

Totally right. 
Maybe I am sleeping.

Let's add follwing as comment about livelock.

"If NR_FREE_PAGES is much higher than number of real free page in buddy,
the VM can allocate pages below min watermark(At worst, buddy is zero). 
Although VM kills some victim for freeing memory, it can't do it if the 
exit path requires new page since buddy have zero page. It can result in
livelock."

At least, it help to not hurt you in future by me who is fool. 

Thanks, Mel. 


> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
