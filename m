Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC078D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 12:42:08 -0500 (EST)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: hunting an IO hang
In-reply-to: <20110117170907.GC27152@csn.ul.ie>
References: <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com> <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com> <1295229722-sup-6494@think> <20110116183000.cc632557.akpm@linux-foundation.org> <1295231547-sup-8036@think> <20110117102744.GA27152@csn.ul.ie> <1295269009-sup-7646@think> <20110117135059.GB27152@csn.ul.ie> <1295272970-sup-6500@think> <1295276272-sup-1788@think> <20110117170907.GC27152@csn.ul.ie>
Date: Mon, 17 Jan 2011 12:40:38 -0500
Message-Id: <1295285676-sup-8962@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Excerpts from Mel Gorman's message of 2011-01-17 12:09:07 -0500:
> On Mon, Jan 17, 2011 at 10:02:47AM -0500, Chris Mason wrote:
> > Excerpts from Chris Mason's message of 2011-01-17 09:07:40 -0500:
> > 
> > [ various crashes under load with current git ]
> > 
> > > 
> > > I did have CONFIG_COMPACTION off for my latest reproduce.  The last two
> > > have been corruption on the page->lru lists, maybe that'll help narrow
> > > our bisect pool down.
> > 
> > I've reverted 744ed1442757767ffede5008bb13e0805085902e, and
> > d8505dee1a87b8d41b9c4ee1325cd72258226fbc and the run has lasted longer
> > than any runs in the past.
> > 
> 
> Confirmed that reverting these patches makes the problem unreproducible
> for the many_dd's + fsmark for at least an hour here.

After 2+ hours I'm still running with those two commits gone.  I'm
confident they are the cause of the crashes.  I also haven't triggered
the cfq stalls without them.

I basically picked them out of a hat:

git log -p v2.6.37..HEAD mm

And looked for anything that messed with page->lru.  The suspects
outside of THP and compaction was pretty short, and Shaohua's changelog
made it easy to guess they were involved.  Thanks for that, it saved
many hours of git rebasing ;)

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
