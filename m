Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA50dDmF031523
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 5 Nov 2008 09:39:13 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C30AC45DD85
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 09:39:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8331945DD80
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 09:39:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 385161DB8049
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 09:39:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D09311DB803E
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 09:39:11 +0900 (JST)
Date: Wed, 5 Nov 2008 09:38:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
 hotplug
Message-Id: <20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1225817945.12673.602.camel@nimitz>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	<200811041635.49932.rjw@sisk.pl>
	<1225813182.12673.587.camel@nimitz>
	<200811041734.04802.rjw@sisk.pl>
	<1225817945.12673.602.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 04 Nov 2008 08:59:05 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Tue, 2008-11-04 at 17:34 +0100, Rafael J. Wysocki wrote:
> > Now, I need to do one more thing, which is to check how much memory has to be
> > freed before creating the image.  For this purpose I need to lock memory
> > hotplug temporarily, count pages to free and unlock it.  What interface should
> > I use for this purpose? 
> > 
> > [I'll also need to lock memory hotplug temporarily during resume.]
> 
> We currently don't have any big switch to disable memory hotplug, like
> lock_memory_hotplug() or something. :)
> 
> If you are simply scanning and counting pages, I think the best thing to
> use would be the zone_span_seq*() seqlock stuff.  Do your count inside
> the seqlock's while loop.  That covers detecting a zone changing while
> it is being scanned.
> 
> The other case to detect is when a new zone gets added.  These are
> really rare.  Rare enough that we actually use a stop_machine() call in
> build_all_zonelists() to do it.  All you would have to do is detect when
> one of these calls gets made.  I think that's a good application for a
> new seq_lock.
> 
> I've attached an utterly untested patch that should do the trick.
> Yasunori and KAME should probably take a look at it since the node
> addition code is theirs.
> 

Hmm ? I think there is no real requirement for doing hibernation while
memory is under hotplug.

Assume following.
 - memory hotplug can be triggerred by
    1. interrupt from system.
    2. "probe" interface in sysfs.
 - ONLINE/OFFLINE is only trigerred by sysfs interface.

I believe we can't block "1", but "1" cannot be raised while hibernation.
(If it happens, it's mistake of the firmware.)

"probe" interface can be triggered from userland. Then it may be worth to be
blocked. How about to add device_pm_lock() to following place ?

  - /sys/device/system/memory/probe
  - ONLINE
  - OFFLINE



off-topic:
BTW, I hear hibernation can be done by kexec + kexec-tools.
If so, boot option for disabling memory hotplug is enough for us, isn't it ?
Or there is long way to make use of it in real world ?

Thanks,
-Kame
















> -- Dave
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
