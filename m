From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory hotplug
Date: Wed, 5 Nov 2008 12:08:25 +0100
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz> <1225817945.12673.602.camel@nimitz> <20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811051208.26628.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday, 5 of November 2008, KAMEZAWA Hiroyuki wrote:
> On Tue, 04 Nov 2008 08:59:05 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Tue, 2008-11-04 at 17:34 +0100, Rafael J. Wysocki wrote:
> > > Now, I need to do one more thing, which is to check how much memory has to be
> > > freed before creating the image.  For this purpose I need to lock memory
> > > hotplug temporarily, count pages to free and unlock it.  What interface should
> > > I use for this purpose? 
> > > 
> > > [I'll also need to lock memory hotplug temporarily during resume.]
> > 
> > We currently don't have any big switch to disable memory hotplug, like
> > lock_memory_hotplug() or something. :)
> > 
> > If you are simply scanning and counting pages, I think the best thing to
> > use would be the zone_span_seq*() seqlock stuff.  Do your count inside
> > the seqlock's while loop.  That covers detecting a zone changing while
> > it is being scanned.
> > 
> > The other case to detect is when a new zone gets added.  These are
> > really rare.  Rare enough that we actually use a stop_machine() call in
> > build_all_zonelists() to do it.  All you would have to do is detect when
> > one of these calls gets made.  I think that's a good application for a
> > new seq_lock.
> > 
> > I've attached an utterly untested patch that should do the trick.
> > Yasunori and KAME should probably take a look at it since the node
> > addition code is theirs.
> > 
> 
> Hmm ? I think there is no real requirement for doing hibernation while
> memory is under hotplug.
> 
> Assume following.
>  - memory hotplug can be triggerred by
>     1. interrupt from system.
>     2. "probe" interface in sysfs.
>  - ONLINE/OFFLINE is only trigerred by sysfs interface.
> 
> I believe we can't block "1", but "1" cannot be raised while hibernation.
> (If it happens, it's mistake of the firmware.)
> 
> "probe" interface can be triggered from userland. Then it may be worth to be
> blocked. How about to add device_pm_lock() to following place ?

This is not necessary as long as we freeze the userland before hibernation.
Still, this is one thing to remeber that the freezing is needed for. :-)

1. seems to be problematic, though, since we rely on zones remaining
unchanged while we're counting memory pages to free before hibernation
and this happens before the calling ->suspend() methods of device drivers.
Of course we can count free pages in a different way, but that will be a
substantial modification (I think).

How's the firmware supposed to be notified that hibernation is going to happen?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
