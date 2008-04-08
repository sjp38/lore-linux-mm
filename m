Date: Tue, 8 Apr 2008 14:41:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 18/18] dentries: dentry defragmentation
In-Reply-To: <20080408142232.8ac243bc.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804081433210.31620@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230229.922470579@sgi.com>
 <20080407231434.88352977.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081409270.31230@schroedinger.engr.sgi.com>
 <20080408142232.8ac243bc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2008, Andrew Morton wrote:

> We know from hard experience that scanning code tends to have failure
> scenarios where it expends large amounts of CPU time not achieving much.

That is prevented by marking slabs where we were unable to reclaim all 
objects in a special way. Those are exempt from future scans. Another 
reclaim attempt is made on these slabs only after all objects have been 
allocated from a slab.

So the worst case would be:

1. Removal of one object from a slab

2. Reclaim scan fails. Page marked unkickable

3. We allocate the last object. Page marked kickable.

4. goto 1


Note that it is difficult to get below the slab defrag ratio (20%) to 
trigger this. I guess a slab with 5 objects could get there if 4 objects
have been freed.

If one increases the ratio to 60% then one would be able to do that with a 
slab cache that has only 2 objects. Boot with slab_max_order=0 to force 
mininum objects per slab.
 
> What workloads are most likely to trigger that sort of behaviour with these
> changes?  How do we establish such failure scenarios and test them?
> 
> It could be that the non-kickable flag saves us from all such cases, dunno.

The kickable flag exempts slabs from attempt to reclaim but it does not 
take the slab off the partial. If we have a large amount of partial slabs 
then scanning the partials may become expensive. That is why I added the 
timeout to reduce the scans in V11.

If we want to get rid of the timeout then we should key the reclaim 
frequency off the number of objects freed since last reclaim and also 
consider the size of the partial slab list. The larger the partial slab 
list the rarer the scan. slabinfo will show the size of the partial lists. 
Also slabinfo provides counters to verify the operation of slab reclaim.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
