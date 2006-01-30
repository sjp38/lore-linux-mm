Date: Mon, 30 Jan 2006 13:59:40 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Zone reclaim: Allow modification of zone reclaim behavior
In-Reply-To: <20060130134554.500b73a3.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0601301350580.5341@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0601301223350.4821@schroedinger.engr.sgi.com>
 <20060130134554.500b73a3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jan 2006, Andrew Morton wrote:

> The proliferating /proc configurability is a worry.  It'll confuse people
> and people just won't know that it's there and it's yet another question
> which maintenance people need to ask end-users during problem resolution.
> 
> Is there not some means by which we can simply get these things right?

I wish I knew some other way to do this. We will have to do significant 
changes to the VM to even have the data available to make the proper 
decisions in these settings. See my zone based counter patches from before 
Christmas. These allow to get rid of the reclaim_interval but are so 
extensive you would not want them for 2.6.16. More brainwork is needed 
after the counters are in to figure out way to make the other knobs 
unnecessary.

> Why wouldn't we want to perform writeback or swapout during zone reclaim?

Because that will reduce performance. If writeback is performed during 
reclaim then a process cannot dirty all of available memory. It will be 
throttled after using up all of a nodes memory. This is a significant 
regression from current performance.

If you do swapout then the process is restricted to a node and will start 
swapping if more memory starts being used than a node has avalable. This 
is going to drastically reduce performance.

zone_reclaim in its default configuration is simply throwing out pages 
that have no references left. These are pagecache pages that may be left 
from a copy operation or from an application that has terminated.

> Why wouldn't we want to reclaim slab during zone reclaim?

Because its too expensive to do and because slab reclaim is not able to 
cleanly reclaim per zone right now. It does a global shrink operation on 
nodes that may still have lots of memory available.

We can skip some of these for 2.6.16 if you do not want the knobs. The 
default behavior without the knobs should be fine for most cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
