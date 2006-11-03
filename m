Date: Fri, 3 Nov 2006 13:42:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
 <Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Nov 2006, Mel Gorman wrote:

> > I think we need something like what is done here via anti-frag but I wish
> > it would be more generic and not solely rely on reclaim to get pages freed
> > up.
> > 
> 
> How could it have been made more generic? Fundamentally, all we are doing at
> the moment is using the freelists to cluster types of pages together. We only
> depend on reclaim now. If we get the clustering part done, I can start working
> on the page migration part.

Right lets have a special freelist for unreclaim/unmovable pages. I think 
that we agree on m that. Somehow we need to be able to insure that 
unXXXable pages do not end up in sections of the zone where we allow 
memory hotplug. 

At some later point we would like to have the ability to redirect 
unXXXable allocations to another node if the node is hot pluggable.

> > Also the duplication of the page struct caches worries me because it
> > reduces the hit rate.
> 
> do you mean the per-cpu caches? If so, without clustering in the per-cpu
> caches, unmovable allocations would "leak" into blocks used for movable
> allocations.

I mean the per cpu caches and I think you could just bypass the per cpu 
caches for unXXXable pages. Kernel pages are buffered already in the slab 
allocator and other kernel allocations are probably rare enough.

> > Removing the intermediate type would reduce the page
> > caches to 2.
> 
> And significantly reduce the effectiveness of the clustering in the process.

Are you sure about this? It seems that the intermediate type is 
reclaimable and you already allow "reclaimable" pages to be not reclaimable 
(mlock'ed pages). If you run into trouble with the reclaimable slab pages 
in the reclaimable zone then you could do agressive slab reclaim to remedy 
the situation.

> > And maybe we do not need caches for unreclaimable/unmovable
> > pages? slab already does its own buffering there.
> That is true. If it is a problem, what could be done is have a per-cpu cache
> for movable and unmovable allocations. Then have the __GFP_KERNRCLM
> allocations bypass the per-cpu allocator altogether and go straight to the
> buddy allocator.

Right. Maybe we can get away with leaving the pageset cpu caches 
untouched? On our largest systems with 1k nodes 4k cpus we currently have 
4 zones * 4096 cpus * 1024 nodes = 16 million pagesets. Each of those has 
hot and cold yielding 32 million lists. Now we going triplicate that to 
192 mio lists and we also increase the size of the structure.

With the code currently in 2.6.19 we go from 4 to 2 zones. So we have only 
16 million pagesets. With the optional DMA in mm we got from 16 to 8 
million pagesets. This effectively undoes the optimizations done in .19 
.20.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
