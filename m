Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7221F6B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 19:43:48 -0400 (EDT)
Date: Wed, 7 Jul 2010 19:43:16 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: what is the point of nr_pages information for the flusher thread?
Message-ID: <20100707234316.GA21990@infradead.org>
References: <20100707231611.GA24281@infradead.org>
 <20100707163710.a46173b2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100707163710.a46173b2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, fengguang.wu@intel.com, mel@csn.ul.ie, npiggin@suse.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 07, 2010 at 04:37:10PM -0700, Andrew Morton wrote:
> On Wed, 7 Jul 2010 19:16:11 -0400
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > Currently there's three possible values we pass into the flusher thread
> > for the nr_pages arguments:
> 
> I assume you're referring to wakeup_flusher_threads().

In that context I refer to everything using the per-bdi flusher thread.
That includes wakeup_flusher_threads() and the functions I've mentioned
below.

> There's also free_more_memory() and do_try_to_free_pages().

Indeed.  So we still have some special cases that want a specific
number to be written back globally.

> wakeup_flusher_threads() apepars to have been borked.  It passes
> nr_pages() into *each* bdi hence can write back far more than it was
> asked to.

> > But seriously, how is the _global_ number of dirty and unstable pages
> > a good indicator for the amount of writeback per-bdi or superblock
> > anyway?
> 
> It isn't.  This appears to have been an attempt to transport the
> wakeup_pdflush() functionality into the new wakeup_flusher_threads()
> regime.  Badly.

Unfortunately we don't just use it for wakeup_flusher_threads() but
also for various bits of per-bdi and per-sb writeback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
