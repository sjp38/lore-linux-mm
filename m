From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] hibernation should work ok with memory hotplug
Date: Tue, 4 Nov 2008 00:05:11 +0100
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz> <200811032324.02163.rjw@sisk.pl> <1225751665.12673.511.camel@nimitz>
In-Reply-To: <1225751665.12673.511.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811040005.12418.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, pavel@suse.cz, linux-kernel@vger.kernel.org, linux-pm@lists.osdl.org, Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Monday, 3 of November 2008, Dave Hansen wrote:
> On Mon, 2008-11-03 at 23:24 +0100, Rafael J. Wysocki wrote:
> > On Monday, 3 of November 2008, Dave Hansen wrote:
> > > On Mon, 2008-11-03 at 12:51 -0800, Andrew Morton wrote:
> > > > On Wed, 29 Oct 2008 13:25:00 +0100
> > > > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > > > > On Wednesday, 29 of October 2008, Pavel Machek wrote:
> > > > > > 
> > > > > > hibernation + memory hotplug was disabled in kconfig because we could
> > > > > > not handle hibernation + sparse mem at some point. It seems to work
> > > > > > now, so I guess we can enable it.
> > > > > 
> > > > > OK, if "it seems to work now" means that it has been tested and confirmed to
> > > > > work, no objection from me.
> > > > 
> > > > yes, that was not a terribly confidence-inspiring commit message.
> > > > 
> > > > 3947be1969a9ce455ec30f60ef51efb10e4323d1 said "For now, disable memory
> > > > hotplug when swsusp is enabled.  There's a lot of churn there right
> > > > now.  We'll fix it up properly once it calms down." which is also
> > > > rather rubbery.  
> > > > 
> > > > Cough up, guys: what was the issue with memory hotplug and swsusp, and
> > > > is it indeed now fixed?
> > > 
> > > I suck.  That commit message was horrid and I'm racking my brain now to
> > > remember what I meant.  Don't end up like me, kids.
> > > 
> > > I've attached the message that I sent to the swsusp folks.  I never got
> > > a reply from that as far as I can tell.
> > > 
> > > http://sourceforge.net/mailarchive/forum.php?thread_name=1118682535.22631.22.camel%40localhost&forum_name=lhms-devel
> > > 
> > > As I look at it now, it hasn't improved much since 2005.  Take a look at
> > > kernel/power/snapshot.c::copy_data_pages().  It still assumes that the
> > > list of zones that a system has is static.  Memory hotplug needs to be
> > > excluded while that operation is going on.
> > 
> > This operation is carried out on one CPU with interrupts disabled.  Is that
> > not enough?
> 
> If that's true then you don't need any locking for anything at all,
> right?

Yes.

> All of the changes I was talking about occur inside the kernel and code
> has to run for it to happen.  So, if you are saying that absolutely no
> other code on the system can possibly run, then it should be OK.
> 
> > > page_is_saveable() checks for pfn_valid().  But, with memory hotplug,
> > > things can become invalid at any time since no references are held or
> > > taken on the page.  Or, a page that *was* invalid may become valid and
> > > get missed.
> > 
> > Can that really happen given the conditions above?
> 
> Nope.
> 
> But, as I think about it, there is another issue that we need to
> address, CONFIG_NODES_SPAN_OTHER_NODES.
> 
> A node might have a node_start_pfn=0 and a node_end_pfn=100 (and it may
> have only one zone).  But, there may be another node with
> node_start_pfn=10 and a node_end_pfn=20.  This loop:
> 
>         for_each_zone(zone) {
> 		...
>                 for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
>                         if (page_is_saveable(zone, pfn))
>                                 memory_bm_set_bit(orig_bm, pfn);
>         }
> 
> will walk over the smaller node's pfn range multiple times.  Is this OK?

Hm, well, I'm not really sure at the moment.

Does it mean that, in your example, the pfns 10 to 20 from the first node
refer to the same page frames that are referred to by the pfns from the
second node?

> I think all you have to do to fix it is check page_zone(page) == zone
> and skip out if they don't match.

Well, probably.  I need to know exactly what's the relationship between pfns,
pages and physical page frames in that case.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
