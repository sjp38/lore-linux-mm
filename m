Date: Thu, 28 Jun 2007 16:29:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-Id: <20070628162936.9e78168d.akpm@linux-foundation.org>
In-Reply-To: <4684415D.1060700@redhat.com>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	<466C36AE.3000101@redhat.com>
	<20070610181700.GC7443@v2.random>
	<46814829.8090808@redhat.com>
	<20070626105541.cd82c940.akpm@linux-foundation.org>
	<468439E8.4040606@redhat.com>
	<20070628155715.49d051c9.akpm@linux-foundation.org>
	<46843E65.3020008@redhat.com>
	<20070628161350.5ce20202.akpm@linux-foundation.org>
	<4684415D.1060700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007 19:16:45 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Thu, 28 Jun 2007 19:04:05 -0400
> > Rik van Riel <riel@redhat.com> wrote:
> > 
> >>> Sigh.  We had a workload (forget which, still unfixed) in which things
> >>> would basically melt down in that linear anon_vma walk, walking 10,000 or
> >>> more vma's.  I wonder if that's what's happening here?
> >> That would be a large multi-threaded application that fills up
> >> memory.  Customers are reproducing this with JVMs on some very
> >> large systems.
> > 
> > So.... does that mean "yes, it's scanning a lot of vmas"?
> 
> Not necessarily.
> 
> The problem can also be reproduced if you have many
> threads, from "enough" CPUs, all scanning pages in
> the same huge VMA.

I wouldn't have expected the anon_vma lock to be the main problem for a
single vma.

If it _is_ the problem then significant improvements could probably be
obtained by passing the whole isolate_lru_pages() pile of pages into the
rmap code rather than doing them one-at-a-time.

> > If so, I expect there will still be failure modes, whatever we do outside
> > of this.  A locked, linear walk of a list whose length is
> > application-controlled is going to be a problem.  Could be that we'll need
> > an O(n) -> O(log(n)) conversion, which will be tricky in there.
> 
> Scanning fewer pages in the pageout path is probably
> the way to go.

I don't see why that would help.  The bottom-line steady-state case is that
we need to reclaim N pages per second, and we need to scan N*M vmas per
second to do so.  How we chunk that up won't affect the aggregate amount of
work which needs to be done.

Or maybe you're referring to the ongoing LRU balancing thing.  Or to something
else.

> No matter how efficient we make the scanning of one
> individual page, we simply cannot scan through 1TB
> worth of anonymous pages (which are all referenced
> because they've been there for a week) in order to
> deactivate something.

Sure.  And we could avoid that sudden transition by balancing the LRU prior
to hitting the great pages_high wall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
