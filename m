Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B9DEC6B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 03:20:58 -0400 (EDT)
Date: Tue, 21 Jul 2009 09:21:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] hibernate / memory hotplug: always use for_each_populated_zone()
Message-ID: <20090721072101.GC7816@wotan.suse.de>
References: <1248103551.23961.0.camel@localhost.localdomain> <4A64E1D6.8090102@crca.org.au> <20090721071508.GB12734@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090721071508.GB12734@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 21, 2009 at 09:15:08AM +0200, Heiko Carstens wrote:
> On Tue, Jul 21, 2009 at 07:29:58AM +1000, Nigel Cunningham wrote:
> > Hi.
> > 
> > Gerald Schaefer wrote:
> > > From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > > 
> > > Use for_each_populated_zone() instead of for_each_zone() in hibernation
> > > code. This fixes a bug on s390, where we allow both config options
> > > HIBERNATION and MEMORY_HOTPLUG, so that we also have a ZONE_MOVABLE
> > > here. We only allow hibernation if no memory hotplug operation was
> > > performed, so in fact both features can only be used exclusively, but
> > > this way we don't need 2 differently configured (distribution) kernels.
> > > 
> > > If we have an unpopulated ZONE_MOVABLE, we allow hibernation but run
> > > into a BUG_ON() in memory_bm_test/set/clear_bit() because hibernation
> > > code iterates through all zones, not only the populated zones, in
> > > several places. For example, swsusp_free() does for_each_zone() and
> > > then checks for pfn_valid(), which is true even if the zone is not
> > > populated, resulting in a BUG_ON() later because the pfn cannot be
> > > found in the memory bitmap.
> > 
> > I agree with your logic and patch, but doesn't this also imply that the
> > s390 implementation pfn_valid should be changed to return false for
> > those pages?
> 
> For CONFIG_SPARSEMEM, which s390 uses, there is no architecture specific
> pfn_valid() implementation.
> Also it looks like the semantics of pfn_valid() aren't clear.
> At least for sparsemem it means nothing but "the memmap for the section
> this page belongs to exists". So it just means the struct page for the
> pfn exists.
> We still have pfn_present() for CONFIG_SPARSEMEM. But that just means
> "some pages in the section this pfn belongs to are present."
> So it looks like checking for pfn_valid() and afterwards checking
> for PG_Reserved (?) might give what one would expect.
> Looks all a bit confusing to me.
> Or maybe it's just me who is confused? :)

It would be nice to remove PG_reserved (most architectures also set
it I think for kernel text and IIRC bootmem), it could then be used
as a PG_arch_2 bit, and we could ask architectures to impement
pfn_is_ram (or whatever's going to be most useful).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
