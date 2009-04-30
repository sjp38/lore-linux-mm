Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 97F616B004D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 03:20:55 -0400 (EDT)
Date: Thu, 30 Apr 2009 00:20:58 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-ID: <20090430072057.GA4663@eskimo.com>
References: <20090428044426.GA5035@eskimo.com> <20090428192907.556f3a34@bree.surriel.com> <1240987349.4512.18.camel@laptop> <20090429114708.66114c03@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090429114708.66114c03@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 11:47:08AM -0400, Rik van Riel wrote:
> When the file LRU lists are dominated by streaming IO pages,
> evict those pages first, before considering evicting other
> pages.
> 
> This should be safe from deadlocks or performance problems
> because only three things can happen to an inactive file page:
> 1) referenced twice and promoted to the active list
> 2) evicted by the pageout code
> 3) under IO, after which it will get evicted or promoted
> 
> The pages freed in this way can either be reused for streaming
> IO, or allocated for something else. If the pages are used for
> streaming IO, this pageout pattern continues. Otherwise, we will
> fall back to the normal pageout pattern.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> On Wed, 29 Apr 2009 08:42:29 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > Isn't there a hole where LRU_*_FILE << LRU_*_ANON and we now stop
> > shrinking INACTIVE_ANON even though it makes sense to.
> 
> Peter, after looking at this again, I believe that the get_scan_ratio
> logic should take care of protecting the anonymous pages, so we can
> get away with this following, less intrusive patch.
> 
> Elladan, does this smaller patch still work as expected?

Rik, since the third patch doesn't work on 2.6.28 (without disabling a lot of
code), I went ahead and tested this patch.

The system does seem relatively responsive with this patch for the most part,
with occasional lag.  I don't see much evidence at least over the course of a
few minutes that it pages out applications significantly.  It seems about
equivalent to the first patch.

Given Andrew Morton's request that I track the Mapped: field in /proc/meminfo,
I went ahead and did that with this patch built into a kernel.  Compared to the
standard Ubuntu kernel, this patch keeps significantly more Mapped memory
around, and it shrinks at a slower rate after the test runs for a while.
Eventually, it seems to reach a steady state.

For example, with your patch, Mapped will often go for 30 seconds without
changing significantly.  Without your patch, it continuously lost about
500-1000K every 5 seconds, and then jumped up again significantly when I
touched Firefox or other applications.  I do see some of that behavior with
your patch too, but it's much less significant.

When I first initiated the background load, Mapped did rapidly decrease from
about 85000K to 47000K.  It seems to have reached a fairly steady state since
then.  I would guess this implies that the VM paged out parts of my executable
set that aren't touched very often, but isn't applying further pressure to my
active pages?  Also for example, after letting the test run for a while, I
scrolled around some tabs in firefox I hadn't used since the test began, and
experienced significant lag.

This seems ok (not disastrous, anyway).  I suspect desktop users would
generally prefer the VM were extremely aggressive about keeping their
executables paged in though, much moreso than this patch provides (and note how
popular swappiness=0 seems to be).  Paging applications back in seems to
introduce a large amount of UI latency, even if the VM keeps it to a sane level
as with this patch.  Also, I don't see many desktop workloads where paging out
applications to grow the data cache is ever helpful -- practically all desktop
workloads where you get a lot of IO involve streaming, not data that might
possibly fit in ram.  If I'm just copying a bunch of files around, I'd prefer
that even "worthless" pages such as eg. parts of Firefox that are only used
during load time or during rare config requests (and would thus not appear to
be part of my working set short-term) stay in cache, so I can get the maximum
interactive performance from my application.

Thank you,
Elladan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
