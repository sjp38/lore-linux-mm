Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 5AC476B02B5
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 07:05:02 -0400 (EDT)
Date: Sat, 23 Jun 2012 13:04:50 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: consider all swapped back pages in used-once logic
Message-ID: <20120623110450.GP27816@cmpxchg.org>
References: <1337246033-13719-1-git-send-email-mhocko@suse.cz>
 <20120517195342.GB1800@cmpxchg.org>
 <20120521025149.GA32375@gmail.com>
 <20120521073632.GL1406@cmpxchg.org>
 <20120521085951.GA4687@gmail.com>
 <20120521093705.GM1406@cmpxchg.org>
 <20120521110659.GA7143@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120521110659.GA7143@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Mon, May 21, 2012 at 07:07:00PM +0800, Zheng Liu wrote:
> On Mon, May 21, 2012 at 11:37:05AM +0200, Johannes Weiner wrote:
> [snip]
> > > > Is it because the read()/write() IO is high throughput and pushes
> > > > pages through the LRU lists faster than the mmap pages are referenced?
> > > 
> > > Yes, in this application, one query needs to access mapped file page
> > > twice and file page cache twice.  Namely, one query needs to do 4 disk
> > > I/Os.  We have used fadvise(2) to reduce file page cache accessing to
> > > only once.  For mapped file page, in fact them are accessed only once
> > > because in one query the same data is accessed twice.  Thus, one query
> > > causes 2 disk I/Os now.  The size of read/write is quite larger than
> > > mmap/munmap.  So, as you see, if we can keep mmap/munmap file in memory
> > > as much as possible, we will gain the better performance.
> > 
> > You access the same unmapped cache twice, i.e. repeated reads or
> > writes against the same file offset?
> 
> No.  We access the same mapped file twice.
> 
> > 
> > How do you use fadvise?
> 
> We access the header and content of the file respectively using read/write.
> The header and content are sequentially.  So we use fadivse(2) with
> FADV_WILLNEED flag to do a readahead.
> 
> > > In addition, another factor also has some impacts for this application.
> > > In inactive_file_is_low_global(), it is different between 2.6.18 and
> > > upstream kernel.  IMHO, it causes that mapped file pages in active list
> > > are moved into inactive list frequently.
> > > 
> > > Currently, we add a parameter in inactive_file_is_low_global() to adjust
> > > this ratio.  Meanwhile we activate every mapped file pages for the first
> > > time.  Then the performance gets better, but it still doesn't reach the
> > > performance of 2.6.18.
> > 
> > 2.6.18 didn't have the active list protection at all and always
> > forcibly deactivated pages during reclaim.  Have you tried fully
> > reverting to this by making inactive_file_is_low_global() return true
> > unconditionally?
> 
> No, I don't try it.  AFAIK, 2.6.18 didn't protect the active list.  But
> it doesn't always forcibly deactivate the pages.  I remember that in
> 2.6.18 kernel we calculate 'mapped_ratio' in shrink_active_list(), and
> then we get 'swap_tendency' according to 'mapped_ratio', 'distress', and
> 'sc->swappiness'.  If 'swap_tendency' is not greater than 100.  It
> doesn't reclaim mapped file pages.  By this equation, if the sum of the
> anonymous pages and mapped file pages is not greater than the 50% of
> total pages, we don't deactivate these pages.  Am I missing something?

I think we need to go back to protecting mapped pages based on how
much of reclaimable memory they make up, one way or another.

Minchan suggested recently to have a separate LRU list for easily
reclaimable pages.  If we balance the lists according to relative
size, we have pressure on mapped pages dictated by availability of
clean cache that is easier to reclaim.

Rik, Minchan, what do you think?

> > Could it be that by accessing your "used-once" unmapped cache twice in
> > short succession, you accidentally activate it all?
> 
> It could not happen.  Certainly it is possible to access a file twice at
> the same offset in product system.  That is reason why we use buffered
> IO rather than direct IO.  But in testing system we could not access the
> same file twice at the same offset.
> 
> > Thereby having ONLY mapped file pages on the inactive list, adding to
> > the pressure on them?
> > 
> > And, by having the wrong pages on the active list, actually benefit
> > from the active list not being protected from inactive list cycle
> > speed and instead pushed out quickly again?
> 
> Sorry, you mean that in 2.6.18 kernel it benefits from the wrong pages
> on the active list, isn't it?

I meant that at least 2.6.18 wouldn't be so eager to protect active
pages, which a workload with many "false" active pages would benefit
from.  But it's a moot point, as it's not what happens in your case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
