Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <45D4E3B6.8050009@redhat.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	 <45D4DF28.7070409@redhat.com>
	 <Pine.LNX.4.64.0702151439520.32026@schroedinger.engr.sgi.com>
	 <45D4E3B6.8050009@redhat.com>
Content-Type: text/plain
Date: Thu, 15 Feb 2007 18:20:58 -0500
Message-Id: <1171581658.5114.76.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-02-15 at 17:50 -0500, Rik van Riel wrote:
> Christoph Lameter wrote:
> > On Thu, 15 Feb 2007, Rik van Riel wrote:
> > 
> >> Running out of swap is a temporary condition.
> >> You need to have some way for those pages to
> >> make it back onto the LRU list when swap
> >> becomes available.
> > 
> > Yup any ideas how?
> 
> Not really.
> 
> >> For example, we could try to reclaim the swap
> >> space of every page that we scan on the active
> >> list - when swap space starts getting tight.
> > 
> > Good idea.
> 
> I suspect this will be a better approach.  That way
> the least used pages can cycle into swap space, and
> the more used pages can be in RAM.
> 
> The only reason pages are unswappable when we run
> out of swap is that we don't free up the swap space
> used by pages that are in memory.

Many large memory systems [e.g., 64G-128G x86_64] running large database
servers run with little [~2G] to no swap.  Most of physical memory is
allocated to large shared memory areas which are never expected to swap
out [even tho' some db apps may not lock the shmem down :-(].  In these
systems, removing the shared memory pages from reclaim consideration may
alleviate some nasty lockups we've seen when one of these systems gets
pushed into reclaim because, e.g., someone ran a backup that filled the
page cache.   We find all of the cpus walking the LRU list [millions of
pages] to find eligible reclaim candidates.  [Almost] none of the shmem
pages are reclaimable because of insufficient swap, and we don't want
them swapped anyway.

Now one could argue that this is an application error, because it
doesn't lock the shared memory regions that it doesn't want swapped
anyway.  This doesn't help the customers in the short term.  They're
looking for a way to take control outside of the application and make
their needs known to the system.  Needs like, never push out shmem [and
maybe even anon] memory to make room for page cache pages.  This, I
believe, is the motivation behind the "limit the page cache"
patches/requests that we keep seeing.

An idea for handling these:

With the addition of Christoph's patch to move mlock()ed pages out of
the LRU, we could add a mechanism to automagically lock shared memory
regions that either exceed some tunable threshold or that exceed the
available amount of swap.

Larry Woodman at Red Hat has been experimenting with patches to move
shmem [and anon?] pages in excess of swap to a separate "wired list".
This has alleviated part of the problems [apparent system hangs].  There
are other issues, some that have been discussed on the mailing lists
recently, with page cache pages messing up the LRU-ness of the active
and inactive lists; vmscan not being proactive enough in keeping
available memory [limits too low for large systems]; etc.  Those issues
are exacerbated by a long active list with a high fraction of
unreclaimable pages.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
