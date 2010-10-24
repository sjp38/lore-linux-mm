Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 58BDE6B0087
	for <linux-mm@kvack.org>; Sat, 23 Oct 2010 21:37:35 -0400 (EDT)
Date: Sun, 24 Oct 2010 12:37:32 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-ID: <20101024013732.GC3168@amd>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <20101022103620.53A9.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1010220859080.19498@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010220859080.19498@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 09:06:48AM -0500, Christoph Lameter wrote:
> On Fri, 22 Oct 2010, KOSAKI Motohiro wrote:
> 
> > I think this series has the same target with Nick's per-zone shrinker.
> > So, Do you dislike Nick's approach? can you please elaborate your intention?
> 
> Sorry. I have not seen Nicks approach.

Latest was posted to linux-mm a few days ago.

 
> The per zone approach seems to be at variance with how objects are tracked
> at the slab layer. There is no per zone accounting there. So attempts to
> do expiration of caches etc at that layer would not work right.

It is not a "slab shrinker", despite the convention to call it that.
It is a "did you allocate memory that you might be nice and be able
to give some back if we have a memory shortage" callback.

The pagecache is all totally driven (calculated, accounted, scanned)
 per-zone, and pagecache reclaim progress drives shrinker reclaim.
Making it per-node adds an unneccesary complicated coupling.

If a particular subsystem only tracks things on a per-node basis, they
can easily to zone_to_nid(zone) in the callback or something like that.

But really, doing LRUs in the zones makes much more sense than in the
nodes. Slab layer doesn't have huge amounts of critical reclaimable
objects like dcache or inode layers, so it is probably fine just to
kick off slab reapers for the node when it gets a request.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
