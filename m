MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18375.5642.424239.215806@stoffel.org>
Date: Thu, 28 Feb 2008 15:14:02 -0500
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [patch 00/21] VM pageout scalability improvements
In-Reply-To: <20080228192908.126720629@redhat.com>
References: <20080228192908.126720629@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik> On large memory systems, the VM can spend way too much time
Rik> scanning through pages that it cannot (or should not) evict from
Rik> memory. Not only does it use up CPU time, but it also provokes
Rik> lock contention and can leave large systems under memory presure
Rik> in a catatonic state.

Nitpicky, but what is a large memory system?  I read your web page and
you talk about large memory being greater than several Gb, and about
huge systems (> 128gb).  So which is this patch addressing?  

I ask because I've got a new system with 4Gb of RAM and my motherboard
can goto 8Gb.  Should this be a large memory system or not?  I've also
only got a single dual core CPU, how does that affect things?

You talk about the Inactive list in the Anonymous memory section, and
about limiting it.  You say 30% on a 1Gb system, but 1% on a 1Tb
system, which is interesting numbers but it's not clear where they
come from.

Should the IO limits (raised lower down in the document) be a more
core feature?  I.e. if you only have 20MBytes/sec bandwidth to disk
for swap, should you be limiting the inactive list to 5seconds of
bandwidth in terms of size?  Or 10s, or 60s?  

Should we be more aggresive in pre-swapping Anonymous memory to swap,
but keeping it cached in memory for use?  If there's pressure, it
seems like it would be easy to just dump pre-swapped pages from the
inactive list, without having to spend time writing them out.

Also, how does having more CPUs/IO bandwidth change things?  Do we
need an exponential backoff algorithm in terms of how much memory is
allocated to the various lists?  As memory gets bigger and bigger, do
we allocated fewer and fewer pages since we can't swap them out fast
enough?  

I dunno... I honestly don't have the time or the knowledge to do more
than poke sticks into things and see what happens.  And to ask
annoying questions.  

I do appreciate your work on this.

John


Rik> Against 2.6.24-rc6-mm1

Rik> This patch series improves VM scalability by:

Rik> 1) making the locking a little more scalable

Rik> 2) putting filesystem backed, swap backed and non-reclaimable pages
Rik>    onto their own LRUs, so the system only scans the pages that it
Rik>    can/should evict from memory

Rik> 3) switching to SEQ replacement for the anonymous LRUs, so the
Rik>    number of pages that need to be scanned when the system
Rik>    starts swapping is bound to a reasonable number

Rik> More info on the overall design can be found at:

Rik> 	http://linux-mm.org/PageReplacementDesign


Rik> Changelog:
Rik> - pull the memcontrol lru arrayification earlier into the patch series
Rik> - use a pagevec array similar to the lru array
Rik> - clean up the code in various places
Rik> - improved pageout balancing and reduced pageout cpu use

Rik> - fix compilation on PPC and without memcontrol
Rik> - make page_is_pagecache more readable
Rik> - replace get_scan_ratio with correct version

Rik> - merge memcontroller split LRU code into the main split LRU patch,
Rik>   since it is not functionally different (it was split up only to help
Rik>   people who had seen the last version of the patch series review it)
Rik> - drop the page_file_cache debugging patch, since it never triggered
Rik> - reintroduce code to not scan anon list if swap is full
Rik> - add code to scan anon list if page cache is very small already
Rik> - use lumpy reclaim more aggressively for smaller order > 1 allocations

Rik> -- 
Rik> All Rights Reversed

Rik> --
Rik> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
Rik> the body of a message to majordomo@vger.kernel.org
Rik> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Rik> Please read the FAQ at  http://www.tux.org/lkml/


Rik> !DSPAM:47c70f4e50261498712856!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
