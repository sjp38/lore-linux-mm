Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CD0A76B005A
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 16:43:26 -0400 (EDT)
Date: Fri, 9 Oct 2009 21:43:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2][v2] mm: add notifier in pageblock isolation for
	balloon drivers
Message-ID: <20091009204326.GH24845@csn.ul.ie>
References: <20091002184458.GC4908@austin.ibm.com> <20091008163449.00dce972.akpm@linux-foundation.org> <20091009202304.GB19114@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091009202304.GB19114@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <geralds@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 09, 2009 at 03:23:04PM -0500, Robert Jennings wrote:
> * Andrew Morton (akpm@linux-foundation.org) wrote:
> > On Fri, 2 Oct 2009 13:44:58 -0500
> > Robert Jennings <rcj@linux.vnet.ibm.com> wrote:
> > 
> > > Memory balloon drivers can allocate a large amount of memory which
> > > is not movable but could be freed to accomodate memory hotplug remove.
> > > 
> > > Prior to calling the memory hotplug notifier chain the memory in the
> > > pageblock is isolated.  If the migrate type is not MIGRATE_MOVABLE the
> > > isolation will not proceed, causing the memory removal for that page
> > > range to fail.
> > > 
> > > Rather than failing pageblock isolation if the the migrateteype is not
> > > MIGRATE_MOVABLE, this patch checks if all of the pages in the pageblock
> > > are owned by a registered balloon driver (or other entity) using a
> > > notifier chain.  If all of the non-movable pages are owned by a balloon,
> > > they can be freed later through the memory notifier chain and the range
> > > can still be isolated in set_migratetype_isolate().
> > 
> > The patch looks sane enough to me.
> > 
> > I expect that if the powerpc and s390 guys want to work on CMM over the
> > next couple of months, they'd like this patch merged into 2.6.32.  It's
> > a bit larger and more involved than one would like, but I guess we can
> > do that if suitable people (Mel?  Kamezawa?) have had a close look and
> > are OK with it.
> >
> > What do people think?
> 
> I'd love to get it in 2.6.32 if that's possible.  I have gone over the 
> comments from Mel and Kamezawa I produced a new patchset.  I just
> finished testing it (and I also tested with
> CONFIG_MEMORY_HOTPLUG_SPARSE=n) and it will be posted shortly.
> 

As you have tested this recently, would you be willing to post the
results? While it's not a requirement of the patch, it would be nice to have
an idea of how the effectiveness of memory hot-remove is improved when used
with the powerpc balloon. This might convince others developers for balloons
to register with the notifier.

Total aside, I'm not overly clear why so much of balloon driver logic is
in drivers and not in the core. At a casual glance, it would appear that
balloon logic could be improved by combining it with similar logic as is
used for lumpy reclaim. This comment is not intended to hurt the patch,
but for the people working on CMM to consider if it hasn't been
considered already.

> > Has it been carefully compile- and run-time tested with
> > CONFIG_MEMORY_HOTPLUG_SPARSE=n?
> 
> Yes, I have compiled the kernel CONFIG_MEMORY_HOTPLUG_SPARSE=n and made
> sure that we didn't have any problems.
> 

The pfn_valid_within() was the biggie as far as the core is concerned. That
sort of mistake causes fairly mad-looking oops. To be perfectly honest,
I didn't review the powerpc-specific portion assuming that people are
testing that and that there are developers more familiar with the area.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
