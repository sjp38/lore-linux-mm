Date: Thu, 8 Nov 2007 11:12:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/23] Slab defragmentation V6
In-Reply-To: <1194535612.6214.9.camel@localhost>
Message-ID: <Pine.LNX.4.64.0711081103360.8954@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <1194535612.6214.9.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Mel Gorman wrote:

> On Tue, 2007-11-06 at 17:11 -0800, Christoph Lameter wrote:
> > Slab defragmentation is mainly an issue if Linux is used as a fileserver
> 
> Was hoping this would get renamed to SLUB Targetted Reclaim from
> discussions at VM Summit. As no copying is taking place, it's confusing
> to call it defragmentation to me anyway. Not a major deal but it made
> reading the patches a little confusing.

The problem is that people are focusing on one feature here and forget 
about the rest. Targetted reclaim is one feature that was added later when 
lumpy reclaim was added to the kernel. The primary intend of this patchset 
was always to reduce the fragmentation. The name is appropriate and the 
patchset will support copying of objects as soon as support for that is 
added to the kick(). In that case the copying you are looking for will be 
there. The simple implementation for the kick() methods is to simply copy
pieces of the reclaim code. That is what is included here.

> > With lumpy reclaim slab defragmentation can be used to enhance the
> > ability to recover larger contiguous areas of memory. Lumpy reclaim currently
> > cannot do anything if a slab page is encountered. With slab defragmentation
> > that slab page can be removed and a large contiguous page freed. It may
> > be possible to have slab pages also part of ZONE_MOVABLE (Mel's defrag
> > scheme in 2.6.23)
> 
> More terminology nit-pick - ZONE_MOVABLE is not defragmenting anything.
> It's just partitioning memory. The slab pages need to be 100%
> reclaimable or movable for that to happen but even with targetted
> reclaim, some dentries such as the root directory one cannot be
> reclaimed, right?

100%? I am so fond of these categorical statements ....

ZONE_MOVABLE also contains mlocked pages that are also not reclaimable. 
The question is at what level would it be possible to make them MOVABLE? 
It may take some improvements to the kick() methods to make eviction more 
reliable. Allowing the moving of objects in the kick() methods will 
likely get usthere.

> It'd still be valid to leave them as MIGRATE_RECLAIMABLE because that is
> what they are. Arguably, MIGRATE_RECLAIMABLE could be dropped in it's
> entirety but I'd rather not as reclaimable blocks have significantly
> different reclaim costs to pages that are currently marked movable.

Right. That would simplify the antifrag methods. Is there any way to 
measure the reclaim costs?

> > V5->V6
> > - Rediff against 2.6.24-rc2 + mm slub patches.
> > - Add reviewed by lines.
> > - Take out the experimental code to make slab pages movable. That
> >   has to wait until this has been considered by Mel.
> > 
> 
> I still haven't considered them properly. I've been backlogged for I
> don't know how long at this point and this is on the increasingly large
> todo list :( . I don't believe it is massively urgent at the moment
> though and reclaiming to start with is perfectly adequate just as lumpy
> reclaim is fine at the moment.

Right. We can defer this for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
