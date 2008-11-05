From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with =?iso-8859-15?q?memory=09hotplug?=
Date: Wed, 5 Nov 2008 11:58:42 +0100
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz> <1225785224.12673.564.camel@nimitz> <1225876205.6755.55.camel@nigel-laptop>
In-Reply-To: <1225876205.6755.55.camel@nigel-laptop>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811051158.43457.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday, 5 of November 2008, Nigel Cunningham wrote:
> Hi.
> 
> On Mon, 2008-11-03 at 23:53 -0800, Dave Hansen wrote:
> > On Tue, 2008-11-04 at 18:30 +1100, Nigel Cunningham wrote:
> > > One other question, if I may. Would you please explain (or point me to
> > > an explanation) of PHYS_PFN_OFFSET/ARCH_PFN_OFFSET? I've been dealing
> > > occasionally with people wanting to have hibernation on arm, and I don't
> > > really get the concept or the implementation (particularly when it comes
> > > to trying to do the sort of iterating over zones and pfns that was being
> > > discussed in previous messages in this thread.
> > 
> > First of all, I think PHYS_PFN_OFFSET is truly an arch-dependent
> > construct.  It only appears in arm an avr32.  I'll tell you only how
> > ARCH_PFN_OFFSET looks to me.  My guess is that those two arches need to
> > reconcile themselves and start using ARCH_PFN_OFFSET instead.
> > 
> > In the old days, we only had memory that started at physical address 0x0
> > and went up to some larger address.  We allocated a mem_map[] of 'struct
> > pages' in one big chunk, one for each address.  mem_map[0] was for
> > physical address 0x0 and mem_map[1] was for 0x1000, mem_map[2] was for
> > 0x2000 and so on...
> > 
> > If a machine didn't have a physical address 0x0, we allocated mem_map[]
> > for it anyway and just wasted that entry.  What ARCH_PFN_OFFSET does is
> > let us bias the mem_map[] structure so that mem_map[0] does not
> > represent 0x0.
> > 
> > If ARCH_PFN_OFFSET is 1, then mem_map[0] actually represents the
> > physical address 0x1000.  If it is 2, then mem_map[0] represents
> > physical addr 0x2000.  ARCH_PFN_OFFSET means that the first physical
> > address on the machine is at ARCH_PFN_OFFSET*PAGE_SIZE.  We bias all
> > lookups into the mem_map[] so that we don't waste space in it.  There
> > will never be a zone_start_pfn lower than ARCH_PFN_OFFSET, for instance.
> > 
> > What does that mean for walking zones?  Nothing.  It only has meaning
> > for how we allocate and do lookups into the mem_map[].  But, since
> > everyone uses pfn_to_page() and friends, you don't ever see this.
> > 
> > I'm curious why you think you need to be concerned with it.
> 
> Sorry for the delay in replying.
> 
> It's because I'm looking at old patches for arm support for TuxOnIce and
> because of the way TuxOnIce records what pages need attention:
> 
> My method of recording what needs doing is different to Rafael's. I use
> per zone bitmaps (constructed out of order 0 allocations) and therefore
> look at zone_start_pfn in calculating what bit within the zone needs to
> be set/cleared/tested.

Well, the mainline does pretty much the same at the moment, but the bitmaps
are probably different.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
