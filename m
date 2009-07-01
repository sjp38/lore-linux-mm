Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 474D36B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 23:52:40 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so171191rvb.26
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 20:54:19 -0700 (PDT)
Date: Wed, 1 Jul 2009 11:54:15 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090701035415.GA22364@localhost>
References: <20090701021645.GA6356@localhost> <20090701022644.GA7510@localhost> <20090701114959.85D3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090701114959.85D3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 01, 2009 at 11:51:54AM +0900, KOSAKI Motohiro wrote:
> > > > What is "hidden" anon pages?
> > > > each shrink_{in}active_list isolate 32 pages from lru. it mean anon or file lru
> > > > accounting decrease temporary.
> > > > 
> > > > if system have plenty thread or process, heavy memory pressure makes 
> > > > #-of-thread x 32pages isolation.
> > > > 
> > > > msgctl11 makes >10K processes.
> > > 
> > > More exactly, ~16K processes:
> > > 
> > >         msgctl11    0  INFO  :  Using upto 16298 pids
> > > 
> > > So the maximum number of isolated pages is 16K * 32 = 512K, or 2GiB.
> > > 
> > > > I have debugging patch for this case.
> > > > Wu, Can you please try this patch?
> > > 
> > > OK. But the OOM is not quite reproducible. Sometimes it produces these
> > > messages:
> > 
> > This time I got the OOM: there are 69817 isolated pages (just as expected)!
> > 
> (snip)
> 
> > [ 1522.019259] Active_anon:11 active_file:6 inactive_anon:0
> > [ 1522.019260]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
> > [ 1522.019261]  free:1985 slab:44399 mapped:132 pagetables:61830 bounce:0
> > [ 1522.019262]  isolate:69817
> 
> OK. thanks.
> I plan to submit this patch after small more tests. it is useful for OOM analysis.

Other counters to consider are NR_ANON_PAGES/NR_FILE_PAGES.

If they were showed in the oom message, this problem could be found
much earlier.  In this case, we'll find that the total file+anon pages
outnumbered the active+inactive file/anon pages.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
