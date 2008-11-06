Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA627j9V006069
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 11:07:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 96A0E45DD7F
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:07:45 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6673D45DD79
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:07:45 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A6C71DB803E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:07:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id DCB311DB803A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:07:44 +0900 (JST)
Date: Thu, 6 Nov 2008 11:07:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
 hotplug
Message-Id: <20081106110709.b168cc30.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1225936818.6216.20.camel@nigel-laptop>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	<1225817945.12673.602.camel@nimitz>
	<20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
	<200811051208.26628.rjw@sisk.pl>
	<20081106091441.6517c072.kamezawa.hiroyu@jp.fujitsu.com>
	<20081106101751.14113f24.kamezawa.hiroyu@jp.fujitsu.com>
	<1225935787.6216.12.camel@nigel-laptop>
	<20081106105453.b2c1b0fc.kamezawa.hiroyu@jp.fujitsu.com>
	<1225936818.6216.20.camel@nigel-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Hansen <dave@linux.vnet.ibm.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 06 Nov 2008 13:00:18 +1100
Nigel Cunningham <ncunningham@crca.org.au> wrote:

> Hi.
> 
> On Thu, 2008-11-06 at 10:54 +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 06 Nov 2008 12:43:07 +1100
> > Nigel Cunningham <ncunningham@crca.org.au> wrote:
> > 
> > > Hi.
> > > 
> > > On Thu, 2008-11-06 at 10:17 +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 6 Nov 2008 09:14:41 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > 
> > > > > Ok, please consider "when memory hotplug happens." 
> > > > > 
> > > > > In general, it happens when
> > > > >   1. memory is inserted to slot.
> > > > >   2. the firmware notifes the system to enable already inserted memory.
> > > > > 
> > > > > To trigger "1", you have to open cover of server/pc. Do you open pc while the system
> > > > > starts hibernation ? for usual people, no.
> > > > > 
> > > > > To trigger "2", the user have special console to tell firmware "enable this memory".
> > > > > Such firmware console or users have to know "the system works well." And, more important,
> > > > > when the system is suspended, the firmware can't do hotplug because the kernel is sleeping.
> > > > > So, such firmware console or operator have to know the system status.
> > > > > 
> > > > > Am I missing some ? Current linux can know PCI/USB hotplug while the system is suspended ?
> > > > > 
> > > > *OFFTOPIC*
> > > > 
> > > > I hear following answer from my friend.
> > > > 
> > > >   - hibernate the system
> > > > 	=> plug USB memory
> > > > 		=> wake up the system
> > > > 			=> panic.
> > > >   - hibernate the system
> > > > 	=> unplug USB memory
> > > > 		=> wake up the sytem
> > > > 			=> panic.
> > > 
> > > We currently check that the number of physical pages is the same when
> > > starting to load the image, so neither of these issues cause real
> > > problems.
> > > 
> > Hmm? this doesn't come from lost of hotplug interrupt ?
> > the memory plugged while the system is sleeping can be recognized when the system wakes up ?
> 
> Remember that when we hibernate (assuming we don't then suspend to ram),
> the power is fully off. Resuming starts off like a fresh boot.
> 
It seems I don't study enough.

> > My point is the firmware/operator has to know "the system is sleeping or not" to do *any* hotplug.
> > (I'm not sure but removing a cpu while the system is under hibernation may cause panic, too.)
> > In my point of view, this is operator's problem, not hibernation's.
> 
> If a cpu is removed while we're hibernated, that's okay. We use
> hotplugging and can therefore cope quite happily with cpus going away
> while the system is powered down.
> 
Why cpu hotplugging works while the power is fully off ?
"Resuming starts off like a fresh boot." updates all necessary data strucutures ?

> > If you want to fix the small race really, please add(or export) some mutex or notifier. like
> > 
> >   NOTIFY_HIBERNATION_START
> >   NOTIFY_HIBERNATION_END
> >   NOTIFY_HIBERNATION_RESUME
> > 
> > other pepole will make use of this.
> > I think __add_memory called by interrupt can be executed in some kernel thread.
> > 
> > Thanks,
> > -Kame
> 
> There are notifier chains for hibernation already
> (PM_HIBERNATION_PREPARE, PM_RESTORE_PREPARE, PM_POST_RESTORE and
> PM_POST_HIBERNATION).
> 

Okay. then we can add "kernel thread for calling add/remove memory" and say
"PLEASE WAIT UNTIL HIBERNATION IS READY".

I can try that by myself but doesn't have suitable machine....
I think I can show you pseudo code in hours. please wait a bit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
