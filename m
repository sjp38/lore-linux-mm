Date: Mon, 4 Jun 2001 11:45:16 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Some VM tweaks (against 2.4.5)
Message-ID: <20010604114516.C1955@redhat.com>
References: <l03130301b73f486b8acb@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <l03130301b73f486b8acb@[192.168.239.105]>; from chromi@cyberspace.org on Sun, Jun 03, 2001 at 03:06:22AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jun 03, 2001 at 03:06:22AM +0100, Jonathan Morton wrote:

> - Increased PAGE_AGE_MAX and PAGE_AGE_START to help newly-created and
> frequently-accessed pages remain in physical RAM.
 
> - Changed age_page_down() and family to use a decrement instead of divide
> (gives frequently-accessed pages a longer lease of life).

We've tried this and the main problem is that something like "grep
foo /usr/bin/*" causes a whole pile of filesystem data to be
maintained in cache for a long time because it is so recent.  Reducing
the initial age of new pages is essential if you want to allow
read-once data to get flushed out again quickly.

> - In try_to_swap_out(), take page->age into account and age it down rather
> than swapping it out immediately.

Bad for shared pages if you have got some tasks still referencing a
page and other tasks which are pretty much idle.  The point of
ignoring the age is that sleeping tasks can get their working set
paged out even if they use library pages which are still in use by
other processes.  That way, if the only active user of a page dies, we
can reclaim the pages without having to wade through the working set
of every other sleeping task which might ever have used the same
shared library.

> - In swap_out_mm(), don't allow large processes to force out processes
> which have smaller RSS than them.  kswapd can still cause any process to be
> paged out.  This replaces my earlier "enforce minimum RSS" hack.

Good idea.  I'd be interested in seeing the effect of this measured in
isolation.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
