Date: Mon, 9 Jun 2008 09:44:07 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080609094407.014fdfd4@bree.surriel.com>
In-Reply-To: <20080608231053.31cfcfeb.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
	<20080608162208.a2683a6c.akpm@linux-foundation.org>
	<20080608193420.2a9cc030@bree.surriel.com>
	<20080608165434.67c87e5c.akpm@linux-foundation.org>
	<20080608205629.5b519110@bree.surriel.com>
	<20080608231053.31cfcfeb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 23:10:53 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> Also, it is incumbent upon us to consider the other design proposals,
> such as removing anon pages from the LRUs, removing mlocked pages from
> the LRUs.

That is certainly an option.  We'll still need to keep track of
what kind of page the page is, though, otherwise we won't know
whether or not we can put it back onto the LRU lists at munlock
time.
 
> > After discussing this for a long time with Larry Woodman,
> > Lee Schermerhorn and others, I am convinced that they can
> > not be fixed by putting a bandaid on the current code.
> > 
> > After all, the fundamental problem often is that the file backed
> > and mem/swap backed pages are on the same LRU.
> 
> That actually isn't a fundamental problem.
> 
> It _becomes_ a problem because we try to treat the two types of pages
> differently.
> 
> Stupid question: did anyone try setting swappiness=100?  What happened?

The database shared memory segment got swapped out and the
system crawled to a halt.

Swap IO usually is less efficient than page cache IO, because
page cache IO happens in larger chunks and does not involve
a swap-out first and a swap-in later - the data is just read,
which at least halves the disk IO compared to swap.

Readahead tilts the IO cost even more in favor of evicting
page cache pages, vs. swapping something out.

> > Think of a case that is becoming more and more common: a database
> > server with 128GB of RAM, 2GB of (hardly ever used) swap, 80GB of
> > locked shared memory segment, 30GB of other anonymous memory and
> > 5GB of page cache.
> > 
> > Do you think it is reasonable for the VM to have to scan over
> > 110GB of essentially unevictable memory, just to get at the 5GB
> > of page cache?
> 
> Well for starters that system was grossly misconfigured.

Swapping out the database shared memory segment is not an option,
because it is mlocked.  Even if it was an option, swapping it out
would be a bad idea because swap IO is simply less efficient than
page cache IO (see above).

> Secondly, I expect that removal of mlocked pages from the LRU (as was
> discussed a year or two ago and perhaps implemented by Andrea) along
> with swappiness=100 might be get us towards a fix.  Don't know.

Removing mlocked pages from the LRU can be done, but I suspect
we'll still want to keep track of how many of these pages there
are, right?

> > > Because I guess we should have a think about alternative approaches.
> > 
> > We have.  We failed to come up with anything that avoids the
> > problem without actually fixing the fundamental issues.
> 
> Unless I missed it, none of your patch descriptions even attempt to
> describe these fundamental issues.  It's all buried in 20-deep email
> threads.

I'll add more problem descriptions to the next patch submission.
I'm halfway the patch series making all the cleanups and changes
you suggested.

> One cause of problms is that we attempt to prioritise anon pages over
> file-backed pagecache.  And we prioritise mmapped pages, which your patches
> don't address, do they?  Stopping doing that would, I expect, prevent a
> range of these problems.  It would introduce others, probably.

Try running a database with swappiness=100 and then doing a
backup of the system simultaneously.  The database will end
up being swapped out, which slows down the database, causes
extra IO and ends up slowing down the backup, too.

The backup does not benefit from having its data cached,
since it only reads everything once.

> > Otherwise, please give us a chance to shake things out in -mm.
> 
> -mm isn't a very useful testing place any more, I'm afraid.

That's a problem.  I can run tests on the VM patches, but you know
as well as I do that the code needs to be shaken out by lots of
users before we can be truly confident in it...

> > I will prepare kernel RPMs for Fedora so users in the community can
> > easily test these patches too, and help find scenarios where these
> > patches do not perform as well as what the current kernel has.
> > 
> > I have time to track down and fix any issues that people find.
> 
> That helps.

I sure hope so.

I'll send you a cleaned-up patch series soon.  Hopefully tonight
or tomorrow.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
