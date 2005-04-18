From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16995.56808.736732.384860@gargle.gargle.HOWL>
Date: Mon, 18 Apr 2005 20:18:48 +0400
Subject: Re: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
In-Reply-To: <1113786837.5124.7.camel@npiggin-nld.site>
References: <16994.40728.397980.431164@gargle.gargle.HOWL>
	<1113786837.5124.7.camel@npiggin-nld.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin writes:
 > On Sun, 2005-04-17 at 21:38 +0400, Nikita Danilov wrote:
 > > set PG_reclaimed bit on pages that are under writeback when shrink_list()
 > > looks at them: these pages are at end of the inactive list, and it only makes
 > > sense to reclaim them as soon as possible when writeout finishes.
 > > 
 > 
 > I agree it makes sense, but this is racy I think. It will leave
 > PG_reclaim set in some cases and hit bad_page. The trivial fix is

Good catch, thanks. By the way, bad_page() doesn't clear PG_reclaim that
free_pages_check() checks for. Is there some deep meaning in this?

 > to remove the PG_reclaim check from bad_page. It looks a bit more
 > tricky to do it "nicely".
 > 

I think "trivial fix" makes more sense, if we redefine PG_reclaim to
mean "page has been seen at end of the inactive list". This bit will be
set at the very beginning of shrink_list() (every for locked pages), and
cleared either by end-io handler, or when page is moved to the active
list. Idea being that if page made its way to end of the inactive list,
but VM failed to reclaim it due to some race, page should be reclaimed
as soon as possible (to get better LRU approximation).

Does this make sense?

 > 
 > -- 
 > SUSE Labs, Novell Inc.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
