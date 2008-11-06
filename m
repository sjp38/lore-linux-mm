Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA60FHbA031039
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 09:15:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C084F45DD84
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:15:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EBA245DD80
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:15:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41F5E1DB8041
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:15:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D496DE08005
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:15:16 +0900 (JST)
Date: Thu, 6 Nov 2008 09:14:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
 hotplug
Message-Id: <20081106091441.6517c072.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200811051208.26628.rjw@sisk.pl>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	<1225817945.12673.602.camel@nimitz>
	<20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
	<200811051208.26628.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Nov 2008 12:08:25 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Wednesday, 5 of November 2008, KAMEZAWA Hiroyuki wrote:
> > On Tue, 04 Nov 2008 08:59:05 -0800
> > Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > 
> > > On Tue, 2008-11-04 at 17:34 +0100, Rafael J. Wysocki wrote:
> > > > Now, I need to do one more thing, which is to check how much memory has to be
> > > > freed before creating the image.  For this purpose I need to lock memory
> > > > hotplug temporarily, count pages to free and unlock it.  What interface should
> > > > I use for this purpose? 
> > > > 
> > > > [I'll also need to lock memory hotplug temporarily during resume.]
> > > 
> > > We currently don't have any big switch to disable memory hotplug, like
> > > lock_memory_hotplug() or something. :)
> > > 
> > > If you are simply scanning and counting pages, I think the best thing to
> > > use would be the zone_span_seq*() seqlock stuff.  Do your count inside
> > > the seqlock's while loop.  That covers detecting a zone changing while
> > > it is being scanned.
> > > 
> > > The other case to detect is when a new zone gets added.  These are
> > > really rare.  Rare enough that we actually use a stop_machine() call in
> > > build_all_zonelists() to do it.  All you would have to do is detect when
> > > one of these calls gets made.  I think that's a good application for a
> > > new seq_lock.
> > > 
> > > I've attached an utterly untested patch that should do the trick.
> > > Yasunori and KAME should probably take a look at it since the node
> > > addition code is theirs.
> > > 
> > 
> > Hmm ? I think there is no real requirement for doing hibernation while
> > memory is under hotplug.
> > 
> > Assume following.
> >  - memory hotplug can be triggerred by
> >     1. interrupt from system.
> >     2. "probe" interface in sysfs.
> >  - ONLINE/OFFLINE is only trigerred by sysfs interface.
> > 
> > I believe we can't block "1", but "1" cannot be raised while hibernation.
> > (If it happens, it's mistake of the firmware.)
> > 
> > "probe" interface can be triggered from userland. Then it may be worth to be
> > blocked. How about to add device_pm_lock() to following place ?
> 
> This is not necessary as long as we freeze the userland before hibernation.
> Still, this is one thing to remeber that the freezing is needed for. :-)
> 
> 1. seems to be problematic, though, since we rely on zones remaining
> unchanged while we're counting memory pages to free before hibernation
> and this happens before the calling ->suspend() methods of device drivers.
> Of course we can count free pages in a different way, but that will be a
> substantial modification (I think).
> 
> How's the firmware supposed to be notified that hibernation is going to happen?
> 

Ok, please consider "when memory hotplug happens." 

In general, it happens when
  1. memory is inserted to slot.
  2. the firmware notifes the system to enable already inserted memory.

To trigger "1", you have to open cover of server/pc. Do you open pc while the system
starts hibernation ? for usual people, no.

To trigger "2", the user have special console to tell firmware "enable this memory".
Such firmware console or users have to know "the system works well." And, more important,
when the system is suspended, the firmware can't do hotplug because the kernel is sleeping.
So, such firmware console or operator have to know the system status.

Am I missing some ? Current linux can know PCI/USB hotplug while the system is suspended ?


Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
