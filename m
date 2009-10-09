Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA056B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 16:23:12 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n99KS2AM004332
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 16:28:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n99KN5Cd219876
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 16:23:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n99KJe1P013729
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 16:19:41 -0400
Date: Fri, 9 Oct 2009 15:23:04 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2][v2] mm: add notifier in pageblock isolation for
	balloon drivers
Message-ID: <20091009202304.GB19114@austin.ibm.com>
References: <20091002184458.GC4908@austin.ibm.com> <20091008163449.00dce972.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091008163449.00dce972.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <geralds@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Andrew Morton (akpm@linux-foundation.org) wrote:
> On Fri, 2 Oct 2009 13:44:58 -0500
> Robert Jennings <rcj@linux.vnet.ibm.com> wrote:
> 
> > Memory balloon drivers can allocate a large amount of memory which
> > is not movable but could be freed to accomodate memory hotplug remove.
> > 
> > Prior to calling the memory hotplug notifier chain the memory in the
> > pageblock is isolated.  If the migrate type is not MIGRATE_MOVABLE the
> > isolation will not proceed, causing the memory removal for that page
> > range to fail.
> > 
> > Rather than failing pageblock isolation if the the migrateteype is not
> > MIGRATE_MOVABLE, this patch checks if all of the pages in the pageblock
> > are owned by a registered balloon driver (or other entity) using a
> > notifier chain.  If all of the non-movable pages are owned by a balloon,
> > they can be freed later through the memory notifier chain and the range
> > can still be isolated in set_migratetype_isolate().
> 
> The patch looks sane enough to me.
> 
> I expect that if the powerpc and s390 guys want to work on CMM over the
> next couple of months, they'd like this patch merged into 2.6.32.  It's
> a bit larger and more involved than one would like, but I guess we can
> do that if suitable people (Mel?  Kamezawa?) have had a close look and
> are OK with it.
>
> What do people think?

I'd love to get it in 2.6.32 if that's possible.  I have gone over the 
comments from Mel and Kamezawa I produced a new patchset.  I just
finished testing it (and I also tested with
CONFIG_MEMORY_HOTPLUG_SPARSE=n) and it will be posted shortly.

> 
> Has it been carefully compile- and run-time tested with
> CONFIG_MEMORY_HOTPLUG_SPARSE=n?

Yes, I have compiled the kernel CONFIG_MEMORY_HOTPLUG_SPARSE=n and made
sure that we didn't have any problems.

--Robert Jennings

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
