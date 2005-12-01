Date: Thu, 1 Dec 2005 13:16:56 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Better pagecache statistics ?
In-Reply-To: <20051201160044.GB14499@dmt.cnet>
Message-ID: <Pine.LNX.4.62.0512011310030.25135@schroedinger.engr.sgi.com>
References: <1133377029.27824.90.camel@localhost.localdomain>
 <20051201152029.GA14499@dmt.cnet> <20051201160044.GB14499@dmt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

We are actually looking at have better pagecache statistics and I have 
been trying out a series of approaches. The direct need right now is to 
have some statistics on the size of the pagecache and the number of 
unmapped file backed pages per node.

With those numbers one would be able to do a local page eviction if memory 
on a node runs low. Per cpu counters exist for some of these but these are 
only meaningful if they are summed up (despite drivers/base/node.c 
seemingly allowing access to per node information).

One pathological case that we frequently encounter is that an application 
does lots of file I/O that saturates a node and then terminates. At that 
point a high number of unmapped pagecache pages exist that are not 
reclaimed because other nodes still have enough free memory. If a counter 
would be available per node then we could check if the numer of unmapped 
pagecache pages is high and if that is the case run kswapd on one specific 
node.

In my various attempts to get some form of statistics for that purpose I 
encountered the problem that I need to modify critical code paths in the 
VM.

One solution would be to add an atomic counter to the zone for the 
number of mapped and the number pagecache pages. However, this would mean 
that these counters have to be incremented and decremented for everypage 
removed and added to the pagecache.

Another one would be to have a node based per cpu array that is summed up 
in regular intervals to create true per node statistics. However, numbers 
are then not current and its not feasable to add them up for every check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
