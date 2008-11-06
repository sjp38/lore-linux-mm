Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA60rqu1027148
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 09:53:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D49045DD79
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:53:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B85E45DD77
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:53:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B904F1DB803C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:53:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A2B71DB8037
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:53:51 +0900 (JST)
Date: Thu, 6 Nov 2008 09:53:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
 hotplug
Message-Id: <20081106095314.8e65f443.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1225931281.11514.27.camel@nimitz>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	<1225817945.12673.602.camel@nimitz>
	<20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
	<200811051208.26628.rjw@sisk.pl>
	<20081106091441.6517c072.kamezawa.hiroyu@jp.fujitsu.com>
	<1225931281.11514.27.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 05 Nov 2008 16:28:01 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Thu, 2008-11-06 at 09:14 +0900, KAMEZAWA Hiroyuki wrote:
> > Ok, please consider "when memory hotplug happens." 
> > 
> > In general, it happens when
> >   1. memory is inserted to slot.
> >   2. the firmware notifes the system to enable already inserted memory.
> > 
> > To trigger "1", you have to open cover of server/pc. Do you open pc while the system
> > starts hibernation ? for usual people, no.
> 
> You're right, this won't happen very often.  We're trying to close a
> theoretical hole that hasn't ever been observed in practice.  But, we
> don't exactly leave races in code just because we haven't observed them.
> I think this is a classic race.
> 
> If we don't close it now, then someone doing some really weirdo hotplug
> is going to run into it at some point.  Who knows what tomorrow's
> hardware/firmware will do?
> 
Hmm, people tend to make crazy hardware, oh yes. the pc may fly in the sky with rocket engine.

My answer to this was "add mutex used in hibernation to memory hotplug interface".
When the mutex blocks ONLINE/OFFLINE memory, the memory range which hibernation should save
will not change. 

Possible solution for this interrupt handling is to do __add_memory() operation
in some kernel thread. Then, we can wait the mutex. 

> > To trigger "2", the user have special console to tell firmware "enable this memory".
> > Such firmware console or users have to know "the system works well." And, more important,
> > when the system is suspended, the firmware can't do hotplug because the kernel is sleeping.
> > So, such firmware console or operator have to know the system status.
> > 
> > Am I missing some ? Current linux can know PCI/USB hotplug while the
> > system is suspended ?
> 
> * echo 'disk' > /sys/power/state
> * count number of pages to write to disk
> * turn all interrupts off
> * copy pages to disk
> * power down
> 
> I think the race we're trying to close is the one between when we count
> pages and when we turn interrupts off.  I assume that there is a reason
> that we don't do the *entire* hibernation process with interrupts off,
> probably because it would "lock" the system up for too long, and can
> even possibly fail.
> 
Hmm, while interrupts off, lru_add_drain_all() or some smp_call_function() will be blocked.
Can't we do 
    while(..){
            go to next mem_section
            if (!section_is_available)
		continue;
            freeze this mem_section.
	    count pages should be saved.
    	    write it to disk
    }
per mem_section ? (maybe addling lock bit in mem_section->section_mem_map is enough.)

Hmm? 

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
