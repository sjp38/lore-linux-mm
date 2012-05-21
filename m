Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0C6676B0083
	for <linux-mm@kvack.org>; Mon, 21 May 2012 05:37:16 -0400 (EDT)
Date: Mon, 21 May 2012 11:37:05 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: consider all swapped back pages in used-once logic
Message-ID: <20120521093705.GM1406@cmpxchg.org>
References: <1337246033-13719-1-git-send-email-mhocko@suse.cz>
 <20120517195342.GB1800@cmpxchg.org>
 <20120521025149.GA32375@gmail.com>
 <20120521073632.GL1406@cmpxchg.org>
 <20120521085951.GA4687@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120521085951.GA4687@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Mon, May 21, 2012 at 04:59:52PM +0800, Zheng Liu wrote:
> On Mon, May 21, 2012 at 09:36:32AM +0200, Johannes Weiner wrote:
> > On Mon, May 21, 2012 at 10:51:49AM +0800, Zheng Liu wrote:
> > > On Thu, May 17, 2012 at 09:54:25PM +0200, Johannes Weiner wrote:
> > > > On Thu, May 17, 2012 at 11:13:53AM +0200, Michal Hocko wrote:
> > > > > [64574746 vmscan: detect mapped file pages used only once] made mapped pages
> > > > > have another round in inactive list because they might be just short
> > > > > lived and so we could consider them again next time. This heuristic
> > > > > helps to reduce pressure on the active list with a streaming IO
> > > > > worklods.
> > > > > This patch fixes a regression introduced by this commit for heavy shmem
> > > > > based workloads because unlike Anon pages, which are excluded from this
> > > > > heuristic because they are usually long lived, shmem pages are handled
> > > > > as a regular page cache.
> > > > > This doesn't work quite well, unfortunately, if the workload is mostly
> > > > > backed by shmem (in memory database sitting on 80% of memory) with a
> > > > > streaming IO in the background (backup - up to 20% of memory). Anon
> > > > > inactive list is full of (dirty) shmem pages when watermarks are
> > > > > hit. Shmem pages are kept in the inactive list (they are referenced)
> > > > > in the first round and it is hard to reclaim anything else so we reach
> > > > > lower scanning priorities very quickly which leads to an excessive swap
> > > > > out.
> > > > > 
> > > > > Let's fix this by excluding all swap backed pages (they tend to be long
> > > > > lived wrt. the regular page cache anyway) from used-once heuristic and
> > > > > rather activate them if they are referenced.
> > > > 
> > > > Yes, the algorithm only makes sense for file cache, which is easy to
> > > > reclaim.  Thanks for the fix!
> > > 
> > > Hi Johannes,
> > > 
> > > Out of curiosity, I notice that, in this patch (64574746), the commit log
> > > said that this patch aims to reduce the impact of pages used only once.
> > > Could you please tell why you think these pages will flood the active
> > > list?  How do you find this problem?
> > 
> > Applications that use mmap for large, linear used-once IO.  Reclaim
> > used to just activate every mapped file page it encountered for the
> > first time (activate referenced ones, but they all start referenced) .
> > This resulted in horrible reclaim latency as most pages in memory
> > where active.
> 
> Thanks for your explanation. :-)
> 
> > 
> > > Actually, we met a huge regression in our product system.  This
> > > application uses mmap/munmap and read/write simultaneously.  Meanwhile
> > > it wants to keep mapped file pages in memory as much as possible.  But
> > > this patch causes that mapped file pages are reclaimed frequently.  So I
> > > want to know whether or not this patch consider this situation.  Thank
> > > you.
> > 
> > Is it because the read()/write() IO is high throughput and pushes
> > pages through the LRU lists faster than the mmap pages are referenced?
> 
> Yes, in this application, one query needs to access mapped file page
> twice and file page cache twice.  Namely, one query needs to do 4 disk
> I/Os.  We have used fadvise(2) to reduce file page cache accessing to
> only once.  For mapped file page, in fact them are accessed only once
> because in one query the same data is accessed twice.  Thus, one query
> causes 2 disk I/Os now.  The size of read/write is quite larger than
> mmap/munmap.  So, as you see, if we can keep mmap/munmap file in memory
> as much as possible, we will gain the better performance.

You access the same unmapped cache twice, i.e. repeated reads or
writes against the same file offset?

How do you use fadvise?

> > Are the mmap pages executable or shared between tasks?  If so, does
> > the kernel you are using include '34dbc67 vmscan: promote shared file
> > mapped pages' and 'c909e99 vmscan: activate executable pages after
> > first usage'?
> 
> Thanks for your advice.  Our application has only one process.  So I
> think that 34dbc67 is not useful for this application.  We have tried to
> mmap file with PROT_EXEC flag to use this patch (c909e99).  But it seems
> that the result is not good as we expected.

Used-once detection should not apply to executably mapped pages at all
and just activate the page as before.  So I think there must be more
going on.

> In addition, another factor also has some impacts for this application.
> In inactive_file_is_low_global(), it is different between 2.6.18 and
> upstream kernel.  IMHO, it causes that mapped file pages in active list
> are moved into inactive list frequently.
> 
> Currently, we add a parameter in inactive_file_is_low_global() to adjust
> this ratio.  Meanwhile we activate every mapped file pages for the first
> time.  Then the performance gets better, but it still doesn't reach the
> performance of 2.6.18.

2.6.18 didn't have the active list protection at all and always
forcibly deactivated pages during reclaim.  Have you tried fully
reverting to this by making inactive_file_is_low_global() return true
unconditionally?

Could it be that by accessing your "used-once" unmapped cache twice in
short succession, you accidentally activate it all?

Thereby having ONLY mapped file pages on the inactive list, adding to
the pressure on them?

And, by having the wrong pages on the active list, actually benefit
from the active list not being protected from inactive list cycle
speed and instead pushed out quickly again?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
