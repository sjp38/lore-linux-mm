Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDE46B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 03:21:31 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 10so1990047ykt.5
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 00:21:30 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id t26si14455402yhl.155.2014.01.23.00.21.28
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 00:21:30 -0800 (PST)
Date: Thu, 23 Jan 2014 19:21:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123082121.GN13997@dastard>
References: <20131220093022.GV11295@suse.de>
 <52DF353D.6050300@redhat.com>
 <20140122093435.GS4963@suse.de>
 <52DFD168.8080001@redhat.com>
 <20140122143452.GW4963@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122143452.GW4963@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ric Wheeler <rwheeler@redhat.com>, linux-scsi@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, lsf-pc@lists.linux-foundation.org

On Wed, Jan 22, 2014 at 02:34:52PM +0000, Mel Gorman wrote:
> On Wed, Jan 22, 2014 at 09:10:48AM -0500, Ric Wheeler wrote:
> > On 01/22/2014 04:34 AM, Mel Gorman wrote:
> > >On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler wrote:
> > >>One topic that has been lurking forever at the edges is the current
> > >>4k limitation for file system block sizes. Some devices in
> > >>production today and others coming soon have larger sectors and it
> > >>would be interesting to see if it is time to poke at this topic
> > >>again.
> > >>
> > >Large block support was proposed years ago by Christoph Lameter
> > >(http://lwn.net/Articles/232757/). I think I was just getting started
> > >in the community at the time so I do not recall any of the details. I do
> > >believe it motivated an alternative by Nick Piggin called fsblock though
> > >(http://lwn.net/Articles/321390/). At the very least it would be nice to
> > >know why neither were never merged for those of us that were not around
> > >at the time and who may not have the chance to dive through mailing list
> > >archives between now and March.
> > >
> > >FWIW, I would expect that a show-stopper for any proposal is requiring
> > >high-order allocations to succeed for the system to behave correctly.
> > >
> > 
> > I have a somewhat hazy memory of Andrew warning us that touching
> > this code takes us into dark and scary places.
> > 
> 
> That is a light summary. As Andrew tends to reject patches with poor
> documentation in case we forget the details in 6 months, I'm going to guess
> that he does not remember the details of a discussion from 7ish years ago.
> This is where Andrew swoops in with a dazzling display of his eidetic
> memory just to prove me wrong.
> 
> Ric, are there any storage vendor that is pushing for this right now?
> Is someone working on this right now or planning to? If they are, have they
> looked into the history of fsblock (Nick) and large block support (Christoph)
> to see if they are candidates for forward porting or reimplementation?
> I ask because without that person there is a risk that the discussion
> will go as follows
> 
> Topic leader: Does anyone have an objection to supporting larger block
> 	sizes than the page size?
> Room: Send patches and we'll talk.

So, from someone who was done in the trenches of the large
filesystem block size code wars, the main objection to Christoph
lameter's patchset was that it used high order compound pages in the
page cache so that nothing at filesystem level needed to be changed
to support large block sizes.

The patch to enable XFS to use 64k block sizes with Christoph's
patches was simply removing 5 lines of code that limited the block
size to PAGE_SIZE. And everything just worked.

Given that compound pages are used all over the place now and we
also have page migration, compaction and other MM support that
greatly improves high order memory allocation, perhaps we should
revisit this approach.

As to Nick's fsblock rewrite, he basically rewrote all the
bufferhead head code to handle filesystem blocks larger than a page
whilst leaving the page cache untouched. i.e. the complete opposite
approach. The problem with this approach is that every filesystem
needs to be re-written to use fsblocks rather than bufferheads. For
some filesystems that isn't hard (e.g. ext2) but for filesystems
that use bufferheads in the core of their journalling subsystems
that's a completely different story.

And for filesystems like XFS, it doesn't solve any of the problem
with using bufferheads that we have now, so it simply introduces a
huge amount of IO path rework and validation without providing any
advantage from a feature or performance point of view. i.e. extent
based filesystems mostly negate the impact of filesystem block size
on IO performance...

Realistically, if I'm going to do something in XFS to add block size
> page size support, I'm going to do it wiht somethign XFS can track
through it's own journal so I can add data=journal functionality
with the same filesystem block/extent header structures used to
track the pages in blocks larger than PAGE_SIZE. And given that we
already have such infrastructure in XFS to support directory
blocks larger than filesystem block size....

FWIW, as to the original "large sector size" support question, XFS
already supports sector sizes up to 32k in size. The limitation is
actually a limitation of the journal format, so going larger than
that would take some work...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
