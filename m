Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 842386B022E
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 18:19:07 -0400 (EDT)
Date: Tue, 30 Mar 2010 00:17:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 36 of 41] remove PG_buddy
Message-ID: <20100329221718.GA5825@random.random>
References: <patchbomb.1269887833@v2.random>
 <27d13ddf7c8f7ca03652.1269887869@v2.random>
 <1269888584.12097.371.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269888584.12097.371.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2010 at 08:49:44PM +0200, Peter Zijlstra wrote:
> On Mon, 2010-03-29 at 20:37 +0200, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > PG_buddy can be converted to page->_count == -1. So the PG_compound_lock can be
> > added to page->flags without overflowing (because of the section bits
> > increasing) with CONFIG_X86_PAE=y.
> 
> This seems to break the assumption that all free pages have a zero page
> count relied upon by things like page_cache_get_speculative().
> 
> What if a page-cache pages gets freed and used as a head in the buddy
> list while a concurrent lockless page-cache lookup tries to get a page
> ref?

I forgot about get_page_unless_zero, still the concept remains the
same, we've just to move from _count to _mapcount or some other field
in the page that we know will never to be some fixed value. Mapcount
is the next candidate as it uses atomic ops and it starts from -1 but
it should only be available on already allocated pages and to be
guaranteed -1 when inside the buddy, so we can set mapcount -2 to
signal the page is in the buddy. Or something like that, to me
mapcount looks ideal but it's likely doubt in other means. The basic
idea is that PG_buddy is a waste of ram.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
