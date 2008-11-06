Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA60OOqj026372
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 19:24:24 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA60S532105808
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 19:28:05 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA60Rr6r001083
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 19:27:54 -0500
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
	hotplug
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081106091441.6517c072.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <1225817945.12673.602.camel@nimitz>
	 <20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
	 <200811051208.26628.rjw@sisk.pl>
	 <20081106091441.6517c072.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 05 Nov 2008 16:28:01 -0800
Message-Id: <1225931281.11514.27.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-11-06 at 09:14 +0900, KAMEZAWA Hiroyuki wrote:
> Ok, please consider "when memory hotplug happens." 
> 
> In general, it happens when
>   1. memory is inserted to slot.
>   2. the firmware notifes the system to enable already inserted memory.
> 
> To trigger "1", you have to open cover of server/pc. Do you open pc while the system
> starts hibernation ? for usual people, no.

You're right, this won't happen very often.  We're trying to close a
theoretical hole that hasn't ever been observed in practice.  But, we
don't exactly leave races in code just because we haven't observed them.
I think this is a classic race.

If we don't close it now, then someone doing some really weirdo hotplug
is going to run into it at some point.  Who knows what tomorrow's
hardware/firmware will do?

> To trigger "2", the user have special console to tell firmware "enable this memory".
> Such firmware console or users have to know "the system works well." And, more important,
> when the system is suspended, the firmware can't do hotplug because the kernel is sleeping.
> So, such firmware console or operator have to know the system status.
> 
> Am I missing some ? Current linux can know PCI/USB hotplug while the
> system is suspended ?

* echo 'disk' > /sys/power/state
* count number of pages to write to disk
* turn all interrupts off
* copy pages to disk
* power down

I think the race we're trying to close is the one between when we count
pages and when we turn interrupts off.  I assume that there is a reason
that we don't do the *entire* hibernation process with interrupts off,
probably because it would "lock" the system up for too long, and can
even possibly fail.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
