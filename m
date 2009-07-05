Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 454146B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 19:16:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n65Nn5G4024946
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 6 Jul 2009 08:49:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DC1745DE4F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 08:49:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4436E45DD7B
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 08:49:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D0841DB803F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 08:49:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D09F51DB803B
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 08:49:04 +0900 (JST)
Date: Mon, 6 Jul 2009 08:47:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: +
 memory-hotplug-alloc-page-from-other-node-in-memory-online.patch added to
 -mm tree
Message-Id: <20090706084719.4f93179b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090703091206.GA27930@sli10-desk.sh.intel.com>
References: <1246497073.18688.28.camel@localhost.localdomain>
	<20090702102208.ff480a2d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090702144415.8B21.E1E9C6FF@jp.fujitsu.com>
	<alpine.DEB.1.10.0907020929060.32407@gentwo.org>
	<20090703085556.fc711310.kamezawa.hiroyu@jp.fujitsu.com>
	<20090703091206.GA27930@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, "Zhao, Yakui" <yakui.zhao@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Jul 2009 17:12:06 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> On Fri, Jul 03, 2009 at 07:55:56AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Thu, 2 Jul 2009 09:31:04 -0400 (EDT)
> > Christoph Lameter <cl@linux-foundation.org> wrote:
> > 
> > > On Thu, 2 Jul 2009, Yasunori Goto wrote:
> > > 
> > > > However, I don't enough time for memory hotplug now,
> > > > and they are just redundant functions now.
> > > > If someone create new allocator (and unifying bootmem allocator),
> > > > I'm very glad. :-)
> > > 
> > > "Senior"ities all around.... A move like that would require serious
> > > commitment of time. None of us older developers can take that on it
> > > seems.
> > > 
> > > Do we need to accept that the zone and page metadata are living on another
> > > node?
> > > 
> > I don't think so. Someone should do. I just think I can't do it _now_.
> > (because I have more things to do for cgroup..)
> > 
> > And, if not node-hotplug, memmap is allocated from local memory if possible.
> > "We should _never_ allow fallback to other nodes or not" is problem ?
> > I think we should allow fallback.
> > About pgdat, zones, I hope they will be on-cache...
> > 
> > Maybe followings are necessary for allocating pgdat/zones from local node
> > at node-hotplug.
> > 
> >   a) Add new tiny functions to alloacate memory from not-initialized area.
> >      allocate pgdat/memmap from here if necessary.
> >   b) leave allocated memory from (a) as PG_reserved at onlining.
> >   c) There will be "not unpluggable" section after (b). We should show this to
> >      users.
> >   d) For removal, we have to keep precise trace of PG_reserved pages.
> >   e) vmemmap removal, which uses large page for vmemmap, is a problem.
> >      edges of section memmap is not aligned to large pages. Then we need
> >      some clever trick to handle this.
> > 
> > Allocationg memmap from its own section was an idea (I love this) but
> > IBM's 16MB memory section doesn't allow this.
> Adding code for allocation should not be hard, but hard to make the memory
> unpluggable. For example, the vmemmap page table pages can map several
> sections and even several nodes (a pgd page). This will make some sections
> completely not unpluggable if the sections have page table pages.
> Is it possible we can merge the workaround temporarily? Without it, the hotplug
> fails immediately in our side.
> 
ZONE_MOVABLE is for that. I wonder current ZONE_MOVABLE interface is not enough.
If section should be removable later, the section should be onlined as ZONE_MOVABLE
as following.

example)
  echo removable_online > /sys/devices/system/memory/memoryXXX/online


thx,
-Kame

> Thanks,
> Shaohua
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
