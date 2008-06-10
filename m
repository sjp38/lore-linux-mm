Date: Tue, 10 Jun 2008 19:48:58 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Message-ID: <20080610194858.695cd7ce@bree.surriel.com>
In-Reply-To: <1213134197.6872.49.camel@lts-notebook>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.522708682@redhat.com>
	<20080606180746.6c2b5288.akpm@linux-foundation.org>
	<20080610033130.GK19404@wotan.suse.de>
	<20080610171400.149886cf@cuia.bos.redhat.com>
	<1213134197.6872.49.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 17:43:17 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Tue, 2008-06-10 at 17:14 -0400, Rik van Riel wrote:
> > On Tue, 10 Jun 2008 05:31:30 +0200
> > Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > If we eventually run out of page flags on 32 bit, then sure this might be
> > > one we could look at geting rid of. Once the code has proven itself.
> > 
> > Yes, after the code has proven stable, we can probably get
> > rid of the PG_mlocked bit and use only PG_unevictable to mark
> > these pages.
> > 
> > Lee, Kosaki-san, do you see any problem with that approach?
> > Is the PG_mlocked bit really necessary for non-debugging
> > purposes?
> 
> Well, it does speed up the check for mlocked pages in page_reclaimable()
> [now page_evictable()?] as we don't have to walk the reverse map to
> determine that a page is mlocked.   In many places where we currently
> test page_reclaimable(), we really don't want to and maybe can't walk
> the reverse map.

There are a few places:
1) the pageout code, which calls page_referenced() anyway; we can
   change page_referenced() to return PAGE_MLOCKED and do the right
   thing from there
2) when the page is moved from a per-cpu pagevec onto an LRU list,
   we may be able to simply skip the check there on the theory that
   the pagevecs are small and the pageout code will eventually catch
   these (few?) pages - actually, setting PG_noreclaim on a page
   that is in a pagevec but not on an LRU list might catch that

Does that seem reasonable/possible?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
