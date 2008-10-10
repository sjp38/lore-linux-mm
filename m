Date: Fri, 10 Oct 2008 15:17:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re:
 vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
Message-Id: <20081010151701.e9e50bdb.akpm@linux-foundation.org>
In-Reply-To: <20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <200810081655.06698.nickpiggin@yahoo.com.au>
	<20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  8 Oct 2008 19:03:07 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> Nick, Andrew, very thanks for good advice.
> your helpful increase my investigate speed.
> 
> 
> > This patch, like I said when it was first merged, has the problem that
> > it can cause large stalls when reclaiming pages.
> > 
> > I actually myself tried a similar thing a long time ago. The problem is
> > that after a long period of no reclaiming, your file pages can all end
> > up being active and referenced. When the first guy wants to reclaim a
> > page, it might have to scan through gigabytes of file pages before being
> > able to reclaim a single one.
> 
> I perfectly agree this opinion.
> all pages stay on active list is awful.
> 
> In addition, my mesurement tell me this patch cause latency degression on really heavy io workload.
> 
> 2.6.27-rc8: Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
>  + patch  : Throughput 12.0953 MB/sec  4000 clients  4000 procs  max_latency=1731244.847 ms
> 
> 
> > While it would be really nice to be able to just lazily set PageReferenced
> > and nothing else in mark_page_accessed, and then do file page aging based
> > on the referenced bit, the fact is that we virtually have O(1) reclaim
> > for file pages now, and this can make it much more like O(n) (in worst case,
> > especially).
> > 
> > I don't think it is right to say "we broke aging and this patch fixes it".
> > It's all a big crazy heuristic. Who's to say that the previous behaviour
> > wasn't better and this patch breaks it? :)
> > 
> > Anyway, I don't think it is exactly productive to keep patches like this in
> > the tree (that doesn't seem ever intended to be merged) while there are
> > other big changes to reclaim there.

Well yes.  I've been hanging onto these in the hope that someone would
work out whether they are changes which we should make.


> > Same for vm-dont-run-touch_buffer-during-buffercache-lookups.patch
> 
> I mesured it too,
> 
> 2.6.27-rc8: Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
>  + patch  : Throughput 11.8494 MB/sec  4000 clients  4000 procs  max_latency=3463217.227 ms
> 
> dbench latency increased about x2.5
> 
> So, the patch desctiption already descibe this risk. 
> metadata dropping can decrease performance largely.
> that just appeared, imho.

Oh well, that'll suffice, thanks - I'll drop them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
