Date: Wed, 7 Jun 2000 06:40:24 -0700 (PDT)
From: Chris Mason <mason@suse.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <20000607121555.G29432@redhat.com>
Message-ID: <Pine.LNX.4.10.10006070629590.9710-100000@home.suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <hans@reiser.to>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>


On Wed, 7 Jun 2000, Stephen C. Tweedie wrote:

> Hi,
> 
> On Tue, Jun 06, 2000 at 08:45:08PM -0700, Hans Reiser wrote:
> > > 
> > > This is the reason because of what I think that one operation in the
> > > address space makes no sense.  No sense because it can't be called
> > > from the page.
> > 
> > What do you think of my argument that each of the subcaches should register
> > currently_consuming counters which are the number of pages that subcache
> > currently takes up in memory,
> 
> There is no need for subcaches at all if all of the pages can be
> represented on the page cache LRU lists.  That would certainly make
> balancing between caches easier.  However, there may be caches which
> don't fit that model --- how would it work for ReiserFS if the cache 
> balancing was all done through the page cache?  

Right now, almost of the pinned pages will be buffer cache pages, and only
metadata is logged.  But, sometimes a data block must be flushed before
transaction commit, and those pages are pinned, but can be written at any
time.  I'm not sure I fully understand the issues with doing all the
balancing through the page cache...

Allocate on flush will be different, and the address_space->pressure()
method makes even more sense there.  Those pages will be on the LRU lists,
and you want the pressure function to be called on each page.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
