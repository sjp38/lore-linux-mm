Date: Fri, 25 May 2007 00:28:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
 a second trip around the LRU
Message-Id: <20070525002829.19deb888.akpm@linux-foundation.org>
In-Reply-To: <1180077810.7348.20.camel@twins>
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
	<1180076565.7348.14.camel@twins>
	<20070525001812.9dfc972e.akpm@linux-foundation.org>
	<1180077810.7348.20.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007 09:23:30 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> > >  		}
> > >  		list_add(&page->lru, &l_inactive);
> > >  	}
> > 
> > That does a bit of extra work in the !PageReferenced && !page_mapped case,
> > but whatever.
> > 
> > The question is: what effect does the change have on page reclaim
> > effectiveness?   And how much more swappy does it become?  And
> > how much more oom-killery?
> 
> All very good questions, of which I'd like to know the answers too :-(

hm.  We've always had this problem.

> I'm sitting on a huge pile of reclaim code, and have no real way of
> answering these questions; I did start writing some synthetic benchmark
> suite, but never really finished it - perhaps I ought to dive into that
> again after OLS.

hm.

> The trouble I had with the previous patch is that it somehow looks to
> PG_referenced but not the PTE state, that seems wrong to me.

		if (page_mapped(page)) {
			if (!reclaim_mapped ||
			    (total_swap_pages == 0 && PageAnon(page)) ||
			    page_referenced(page, 0)) {
				list_add(&page->lru, &l_active);
				continue;
			}
		} else if (TestClearPageReferenced(page)) {
			list_add(&page->lru, &l_active);
			continue;
		}

When we run TestClearPageReferenced() we know that the page isn't
page_mapped(): there aren't any pte's which refer to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
