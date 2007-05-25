Date: Fri, 25 May 2007 10:20:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
 a second trip around the LRU
Message-Id: <20070525102018.1cba79f0.akpm@linux-foundation.org>
In-Reply-To: <4656F625.30402@redhat.com>
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
	<4656F625.30402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007 10:43:49 -0400 Rik van Riel <riel@redhat.com> wrote:

> akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Martin spotted this.
> > 
> > In the original rmap conversion in 2.5.32 we broke aging of pagecache pages on
> > the active list: we deactivate these pages even if they had PG_referenced set.
> 
> IIRC this is done to make sure that we reclaim page cache pages
> ahead of mapped anonymous pages.

I think it was an accident.  At least, that 2.5.32 change was uncommented
and unchangelogged and was an inappropriate thing to have been bundled into
that patch.

> > We should instead clear PG_referenced and give these pages another trip around
> > the active list.
> 
> A side effect of this is that the page will now need TWO references
> to be promoted back to the active list from the inactive list.
> 
> The current code leaves PG_referenced set, so that the first access
> to a page cache page that was demoted to the inactive list will cause
> that page to be moved back to the active list.

hm, yeah, we should be setting PG-referenced when moving a page from the
active list onto the inactive list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
