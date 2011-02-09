Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E31EF8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:06:28 -0500 (EST)
Date: Wed, 9 Feb 2011 12:05:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-Id: <20110209120550.2bd18590.akpm@linux-foundation.org>
In-Reply-To: <20110209182846.GN3347@random.random>
References: <20110209154606.GJ27110@cmpxchg.org>
	<20110209164656.GA1063@csn.ul.ie>
	<20110209182846.GN3347@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 9 Feb 2011 19:28:46 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Feb 09, 2011 at 04:46:56PM +0000, Mel Gorman wrote:
> > On Wed, Feb 09, 2011 at 04:46:06PM +0100, Johannes Weiner wrote:
> > > Hi,
> > > 
> > > I think this should fix the problem of processes getting stuck in
> > > reclaim that has been reported several times.
> > 
> > I don't think it's the only source but I'm basing this on seeing
> > constant looping in balance_pgdat() and calling congestion_wait() a few
> > weeks ago that I haven't rechecked since. However, this looks like a
> > real fix for a real problem.
> 
> Agreed. Just yesterday I spent some time on the lumpy compaction
> changes after wondering about Michal's khugepaged 100% report, and I
> expected some fix was needed in this area (as I couldn't find any bug
> in khugepaged yet, so the lumpy compaction looked the next candidate
> for bugs).
> 
> I've also been wondering about the !nr_scanned check in
> should_continue_reclaim too but I didn't look too much into the caller
> (I was tempted to remove it all together). I don't see how checking
> nr_scanned can be safe even after we fix the caller to avoid passing
> non-zero values if "goto restart".
> 
> nr_scanned is incremented even for !page_evictable... so it's not
> really useful to insist, just because we scanned something, in my
> view. It looks bogus... So my proposal would be below.
> 
> ====
> Subject: mm: stop checking nr_scanned in should_continue_reclaim
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> nr_scanned is incremented even for !page_evictable... so it's not
> really useful to insist, just because we scanned something.

So if reclaim has scanned 100% !page_evictable pages,
should_continue_reclaim() can return true and we keep on scanning?

That sounds like it's both good and bad :( Is this actually a problem? 
What sort of behaviour could it cause and under what circumstances?

Johannes's patch is an obvious bugfix and I'll run with it for now, but
please let's have a further think abut the impact of the
!page_evictable pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
