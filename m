Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 936EE6B01FC
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 07:37:38 -0400 (EDT)
Date: Mon, 26 Apr 2010 12:36:41 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-ID: <20100426113640.GA8459@csn.ul.ie>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com> <20100423095922.GJ30306@csn.ul.ie> <20100423155801.GA14351@csn.ul.ie> <20100424110200.b491ec5f.kamezawa.hiroyu@jp.fujitsu.com> <20100424104324.GD14351@csn.ul.ie> <20100426084901.15c09a29.kamezawa.hiroyu@jp.fujitsu.com> <20100426182838.2cab9844.kamezawa.hiroyu@jp.fujitsu.com> <r2o28c262361004260248s62729484g14a720d37d5916f7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <r2o28c262361004260248s62729484g14a720d37d5916f7@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 26, 2010 at 06:48:42PM +0900, Minchan Kim wrote:
> On Mon, Apr 26, 2010 at 6:28 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 26 Apr 2010 08:49:01 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> >> On Sat, 24 Apr 2010 11:43:24 +0100
> >> Mel Gorman <mel@csn.ul.ie> wrote:
> >
> >> > It looks nice but it still broke after 28 hours of running. The
> >> > seq-counter is still insufficient to catch all changes that are made to
> >> > the list. I'm beginning to wonder if a) this really can be fully safely
> >> > locked with the anon_vma changes and b) if it has to be a spinlock to
> >> > catch the majority of cases but still a lazy cleanup if there happens to
> >> > be a race. It's unsatisfactory and I'm expecting I'll either have some
> >> > insight to the new anon_vma changes that allow it to be locked or Rik
> >> > knows how to restore the original behaviour which as Andrea pointed out
> >> > was safe.
> >> >
> >> Ouch.
> >
> > Ok, reproduced. Here is status in my test + printk().
> >
> >  * A race doesn't seem to happen if swap=off.
> >    I need to swapon to cause the bug
> 
> FYI,
> 
> Do you have a swapon/off bomb test?
> When I saw your mail, I feel it might be culprit.
> 
> http://lkml.org/lkml/2010/4/22/762.
> 
> It is just guessing. I don't have a time to look into, now.
> 

I haven't tried a swapon/off test but that patch is certainly important
and closes an important race. A fork-heavy test will routinely hit the
problem and applying the patch makes it very difficult to reproduce the
problem. I've added it to my stack while I continue trying to pin down
when the VMA-changes make a difference.

I'm relooking at the seq counter approach. It appears to very rare the logic
is actually triggered so reproducing is a problem. I'm still not convinced
that just locking anon_vma is not the answer there. If it locks and as
expand_downwards already locks and with the fork-based patch, I think the
races might be closed but I'm not 100% certain yet.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
