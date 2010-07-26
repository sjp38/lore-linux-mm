Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CFF76600044
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 18:49:09 -0400 (EDT)
Date: Tue, 27 Jul 2010 06:48:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100726224853.GA7229@localhost>
References: <20100723094515.GD5043@localhost>
 <20100723105719.GE5300@csn.ul.ie>
 <20100725192955.40D5.A69D9226@jp.fujitsu.com>
 <20100725120345.GA1817@barrios-desktop>
 <20100726032755.GB7668@localhost>
 <AANLkTinL-K-Ky1NFWQPvH5XASj9MnZJicFtqDYhdje6R@mail.gmail.com>
 <20100726043709.GC7668@localhost>
 <20100726163011.GA23467@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100726163011.GA23467@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 12:30:11AM +0800, Minchan Kim wrote:
> On Mon, Jul 26, 2010 at 12:37:09PM +0800, Wu Fengguang wrote:
> > On Mon, Jul 26, 2010 at 12:11:59PM +0800, Minchan Kim wrote:
> > > On Mon, Jul 26, 2010 at 12:27 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > > On Sun, Jul 25, 2010 at 08:03:45PM +0800, Minchan Kim wrote:
> > > >> On Sun, Jul 25, 2010 at 07:43:20PM +0900, KOSAKI Motohiro wrote:
> > > >> > Hi
> > > >> >
> > > >> > sorry for the delay.
> > > >> >
> > > >> > > Will you be picking it up or should I? The changelog should be more or less
> > > >> > > the same as yours and consider it
> > > >> > >
> > > >> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > >> > >
> > > >> > > It'd be nice if the original tester is still knocking around and willing
> > > >> > > to confirm the patch resolves his/her problem. I am running this patch on
> > > >> > > my desktop at the moment and it does feel a little smoother but it might be
> > > >> > > my imagination. I had trouble with odd stalls that I never pinned down and
> > > >> > > was attributing to the machine being commonly heavily loaded but I haven't
> > > >> > > noticed them today.
> > > >> > >
> > > >> > > It also needs an Acked-by or Reviewed-by from Kosaki Motohiro as it alters
> > > >> > > logic he introduced in commit [78dc583: vmscan: low order lumpy reclaim also
> > > >> > > should use PAGEOUT_IO_SYNC]
> > > >> >
> > > >> > My reviewing doesn't found any bug. however I think original thread have too many guess
> > > >> > and we need to know reproduce way and confirm it.
> > > >> >
> > > >> > At least, we need three confirms.
> > > >> > A o original issue is still there?
> > > >> > A o DEF_PRIORITY/3 is best value?
> > > >>
> > > >> I agree. Wu, how do you determine DEF_PRIORITY/3 of LRU?
> > > >> I guess system has 512M and 22M writeback pages.
> > > >> So you may determine it for skipping max 32M writeback pages.
> > > >> Is right?
> > > >
> > > > For 512M mem, DEF_PRIORITY/3 means 32M dirty _or_ writeback pages.
> > > > Because shrink_inactive_list() first calls
> > > > shrink_page_list(PAGEOUT_IO_ASYNC) then optionally
> > > > shrink_page_list(PAGEOUT_IO_SYNC), so dirty pages will first be
> > > > converted to writeback pages and then optionally be waited on.
> > > >
> > > > The dirty/writeback pages may go up to 512M*20% = 100M. So 32M looks
> > > > a reasonable value.
> > > 
> > > Why do you think it's a reasonable value?
> > > I mean why isn't it good 12.5% or 3.125%? Why do you select 6.25%?
> > > I am not against you. Just out of curiosity and requires more explanation.
> > > It might be thing _only I_ don't know. :(
> > 
> > It's more or less random selected. I'm also OK with 3.125%. It's an
> > threshold to turn on some _last resort_ mechanism, so don't need to be
> > optimal..
> 
> Okay. Why I had a question is that I don't want to add new magic value in 
> VM without detailed comment. 
> While I review the source code, I always suffer form it. :(
> Now we have a great tool called 'git'. 
> Please write down why we select that number detaily when we add new 
> magic value. :)

Good point. I'll do that :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
