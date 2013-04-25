Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 982FE6B0033
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 18:40:41 -0400 (EDT)
Date: Thu, 25 Apr 2013 23:40:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: page eviction from the buddy cache
Message-ID: <20130425224035.GG2144@suse.de>
References: <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
 <51730619.3030204@fastmail.fm>
 <20130420235718.GA28789@thunk.org>
 <5176785D.5030707@fastmail.fm>
 <20130423122708.GA31170@thunk.org>
 <alpine.LNX.2.00.1304231230340.12850@eggly.anvils>
 <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org>
 <20130424142650.GA29097@thunk.org>
 <20130425143056.GF2144@suse.de>
 <7398CEE9-AF68-4A2A-82E4-940FADF81F97@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7398CEE9-AF68-4A2A-82E4-940FADF81F97@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Lyahkov <alexey.lyashkov@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Perepechko <anserper@ya.ru>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, Will Huck <will.huckk@gmail.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 25, 2013 at 09:37:07PM +0300, Alexey Lyahkov wrote:
> Mel,
> 
> 
> On Apr 25, 2013, at 17:30, Mel Gorman wrote:
> 
> > On Wed, Apr 24, 2013 at 10:26:50AM -0400, Theodore Ts'o wrote:
> >> On Tue, Apr 23, 2013 at 03:00:08PM -0700, Andrew Morton wrote:
> >>> That should fix things for now.  Although it might be better to just do
> >>> 
> >>> 	mark_page_accessed(page);	/* to SetPageReferenced */
> >>> 	lru_add_drain();		/* to SetPageLRU */
> >>> 
> >>> Because a) this was too early to decide that the page is
> >>> super-important and b) the second touch of this page should have a
> >>> mark_page_accessed() in it already.
> >> 
> >> The question is do we really want to put lru_add_drain() into the ext4
> >> file system code?  That seems to pushing some fairly mm-specific
> >> knowledge into file system code.  I'll do this if I have to do, but
> >> wouldn't be better if this was pushed into mark_page_accessed(), or
> >> some other new API was exported by the mm subsystem?
> >> 
> > 
> > I don't think we want to push lru_add_drain() into the ext4 code. It's
> > too specific of knowledge just to work around pagevecs. Before we rework
> > how pagevecs select what LRU to place a page, can we make sure that fixing
> > that will fix the problem?
> > 
> what is "that"? puting lru_add_drain() in ext4 core? sure that is fixes problem with many small reads during large write.
> originally i have put shake_page() in ext4 code, but that have call lru_add_drain_all() so to exaggerated.
> 

No, I would prefer if this was not fixed within ext4. I need confirmation
that fixing mark_page_accessed() addresses the performance problem you
encounter. The two-line check for PageLRU() followed by a lru_add_drain()
is meant to check that. That is still not my preferred fix because even
if you do not encounter higher LRU contention, other workloads would be
at risk.  The likely fix will involve converting pagevecs to using a single
list and then selecting what LRU to put a page on at drain time but I
want to know that it's worthwhile.

Using shake_page() in ext4 is certainly overkill.

> > Andrew, can you try the following patch please? Also, is there any chance
> > you can describe in more detail what the workload does?
>
> lustre OSS node + IOR with file size twice more then OSS memory.
> 

Ok, no way I'll be reproducing that workload. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
