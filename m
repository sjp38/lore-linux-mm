Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E06B8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 11:32:43 -0500 (EST)
Date: Mon, 17 Jan 2011 17:32:22 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: hunting an IO hang
Message-ID: <20110117163222.GG2212@cmpxchg.org>
References: <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
 <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
 <1295229722-sup-6494@think>
 <20110116183000.cc632557.akpm@linux-foundation.org>
 <1295231547-sup-8036@think>
 <20110117102744.GA27152@csn.ul.ie>
 <1295269009-sup-7646@think>
 <20110117135059.GB27152@csn.ul.ie>
 <1295272970-sup-6500@think>
 <1295276272-sup-1788@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295276272-sup-1788@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 17, 2011 at 10:02:47AM -0500, Chris Mason wrote:
> Excerpts from Chris Mason's message of 2011-01-17 09:07:40 -0500:
> 
> [ various crashes under load with current git ]
> 
> > 
> > I did have CONFIG_COMPACTION off for my latest reproduce.  The last two
> > have been corruption on the page->lru lists, maybe that'll help narrow
> > our bisect pool down.
> 
> I've reverted 744ed1442757767ffede5008bb13e0805085902e, and
> d8505dee1a87b8d41b9c4ee1325cd72258226fbc and the run has lasted longer
> than any runs in the past.
> 
> I'll give this a few hours but they seem the most related to my various
> crashes so far.

I went through the new batched activation code.  Shaohua, can you
explain to me why the following sequence is not possible?

1. CPU A and B schedule activation of a page (PG_lru && !PG_active)
2. CPU A flushes the page to the active list (PG_lru && PG_active)
3. CPU A isolates the page for scanning/migration and
   puts it on private list (!PG_lru && PG_active)
4. CPU B flushes the page to the active list (!PG_lru && PG_active),
   the deferred activation code now assumes putback mode and adds the page
   to the active list, thus corrupting the link to the private list of CPU A
5. CPU A does list_del() from the private list (like unmap_and_move() does)
   and trips up on the corruption

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
