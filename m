Date: Tue, 21 Nov 2006 18:40:25 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: drain_node_page(): Drain pages in batch units
In-Reply-To: <20061121175228.14eaf35b.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0611211826080.588@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611211255270.31032@schroedinger.engr.sgi.com>
 <20061121175228.14eaf35b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006, Andrew Morton wrote:

> This will reduce the reaping rate.  Potentially vastly.

It will fully drain in 6 reap cycles instead of in one. For a 32 node/ 64p 
system this would mean 32* 2 <cache_reap time> * 6 ~ 6 minutes. Currently 
we need one minute.
 
> Is that a good change?  If so, why?

The reaping is only needed so that pages are not staying forever on 
pagesets that are rarely used. The bigger the system the more numerous 
those will become. Rarely used pagesets typically contain less than 
"batch" pages on them anyways.

I'd be interested in alternative ideas on how to do this draining 
(especialy since the slabifier does not need cache_reap() anymore). I 
tinkered around with scheduling draining separarely via a workqueue. We 
cannot add a workqueue for each pageset since we have about a million of 
those on large system. Maybe add one per cpu and then do the draining 
from there?

The slabifier has a workqueue per slab that is activated and running every 
2 seconds but only if per cpu slabs for this slab cache active.

One of the key issues is that we still need to access off node data in 
remote zones to get to this cpus pageset for that remote zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
