Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E5AE58D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:26:29 -0500 (EST)
Date: Tue, 22 Feb 2011 14:25:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110222142559.GD15652@csn.ul.ie>
References: <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random> <20110214022524.GA18198@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110214022524.GA18198@sli10-conroe.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, alex.shi@intel.com

On Mon, Feb 14, 2011 at 10:25:24AM +0800, Shaohua Li wrote:
> On Thu, Feb 03, 2011 at 10:58:08AM +0800, Andrea Arcangeli wrote:
> > On Thu, Jan 27, 2011 at 04:27:55PM +0100, Andrea Arcangeli wrote:
> > > totally untested... I will test....
> > 
> > The below patch is fixing my problem and working fine for me... as
> > expected it can't possibly lead to any D state, it's pretty much like
> > setting min_free_kbytes lower, and it's not going to alter anything
> > other than the levels of free memory kept by kswapd.
> > 
> > $ while :; do ps xa|grep [k]swapd; sleep 1; done
> >   452 ?        R      1:20 [kswapd0]
> >   452 ?        S      1:20 [kswapd0]
> >   452 ?        S      1:20 [kswapd0]
> >   452 ?        S      1:20 [kswapd0]
> >   452 ?        S      1:20 [kswapd0]
> >   452 ?        R      1:20 [kswapd0]
> >   452 ?        R      1:20 [kswapd0]
> >   452 ?        R      1:20 [kswapd0]
> >   452 ?        R      1:20 [kswapd0]
> >   452 ?        S      1:20 [kswapd0]
> >   452 ?        R      1:20 [kswapd0]
> > $ vmstat 1
> > procs -----------memory---------- ---swap-- -----io---- -system--
> >   ----cpu----
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us
> >   sy id wa
> >  2  1   1784 111040 2393336 807924    0    0    63   992   56   70  1   1 96  2
> >  0  1   1784 108928 2402556 801864    0    0 122624     0 1619 2150  0   5 80 16
> >  0  1   1784 110664 2401244 801140    0    0 122496     0 1602 2081  0   3 81 16
> >  0  1   1784 109796 2410184 792984    0    0 122752     0 1685 2149  0   4 80 16
> >  0  1   1784 110416 2411856 791208    0    0 120448     4 1599 2075  0   4 81 16
> >  1  0   1784 113516 2415344 785336    0    0 122496     0 1636 2125  0   4 81 15
> > 
> > I doubt we'll get any regression because of the below (see also my
> > prev email in this thread), and I would only expect more cache and
> > maybe better lru. Previously the free memory levels were stuck at
> > ~700M now they're stuck at the right level for a 4G system with THP on
> > (I'd still like to try to reduce the requirements only 1 hugepage for
> > each migratetype in the set_min_free_kbytes to reduce the requirements
> > to the minium, but only if possible..). But this saves 600M over 4G so
> > it's the highest prio to address.
> Sorry for the later response, I offlined several weeks.
> The patch is addressing the 8*high_wmark issue, which isn't the original issue
> I reported (sure the 8*wmark issue should be fixed too).
> min_free_kbytes is set higher and cause more pages freed even no the 8*wmark
> issue. wmark:
> before: min      1424
> after:	min      11178

The higher min_free_kbytes is expected as a result of using transparent
hugepages so I don't really consider it a bug. Free memory going up to
about 700M as a result of kswapd is a real bug though.

> in our test, there is about 50M memory free (originally just about 5M, which
> will cause more swap. Should we also reduce the min_free_kbytes?
> 

Either that or boot with transparent hugepages disabled and
min_free_kbytes will be lower.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
