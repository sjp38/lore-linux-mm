Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA646B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 06:03:16 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id p5HA35Ah009552
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:33:05 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5HA35bt4165720
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:33:05 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5HA35u8007657
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 20:03:05 +1000
Date: Fri, 17 Jun 2011 15:33:00 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110617100300.GA24954@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110613134701.2b23b8d8.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616042044.GA28563@in.ibm.com>
 <1308240240.11430.115.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308240240.11430.115.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Hi,

On Thu, Jun 16, 2011 at 09:04:00AM -0700, Dave Hansen wrote:
> On Thu, 2011-06-16 at 09:50 +0530, Ankita Garg wrote:
> > - Correctly predicting memory pressure is difficult and thereby being
> >   able to online the required pages at the right time could be a
> >   challenge
> 
> For the sake of this discussion, let's forget about this.  There are
> certainly a lot of scenarios where turning memory on/off is necessary
> and useful _without_ knowing what kind of load the system is under.  "We
> just shut down our huge database, and now have 99% of RAM free" is a
> fine, dumb, metric.  We don't have to have magical pony memory pressure
> detection as a prerequisite.
>

I agree, but when using memory hotplug for managing memory power, it
would be important to correctly predict pressure so that performance is
not affected too much. Also, especially since memory would be offlined
only when memory is mostly idle. While in the case of CPU, a user space
daemon can automatically online/offline cpus based on load, but in the
case of memory, I guess a kernel thread that maintains global statistics
might have to be used.

> > - Memory hotplug is a heavy operation, so the overhead involved may be
> >   high
> 
> I'm curious.  Why do you say this?  Could you elaborate a bit on _how_
> memory hotplug is different from what you're doing here?  On powerpc, at
> least, we can do memory hotplug in areas as small as 16MB.  That's _way_
> smaller than what you're talking about here, and I would assume that
> smaller here means less overhead.
> 

To save any power, the entire memory unit (like a bank for PASR) will
have to be turned off (and hence offlined). The overhead in memory
hotplug is to migrate/free pages belonging to the sections and
creating/deleting the various memory management structures. Instead, if
we could have a framework like you mentiond below that could target
allocations away from certain areas of memory, the migration step will
not be needed. Further, the hardware would just turn off the memory and
the OS would retain all the memory management structures.

We intend to use memory regions to group the memory together into units
that can be independently power managed. We propose to achieve this by
re-ordering zones within the zonelist, such that zones from regions that
are the target for evacuation would be at the tail of the zonelist and
thus will not be prefered for allocations.

> > - Powering off memory is just one of the ways in which memory power could
> >   be saved. The platform can also dynamically transition areas of memory
> >   into a  content-preserving lower power state if it is not referenced
> >   for a pre-defined threshold of time. In such a case, we would need a
> >   mechanism to soft offline the pages - i.e, no new allocations to be
> >   directed to that memory
> 
> OK...  That's fine, but I think you're avoiding the question a bit.  You
> need to demonstrate that this 'regions' thing is necessary to do this,
> and that we can not get by just modifying what we have now.  For
> instance:
> 
> 1. Have something like khugepaged try to find region-sized chunks of
>    memory to free.
> 2. Modify the buddy allocator to be "picky" about when it lets you get 
>    access to these regions.

Managing pages belonging to multiple regions on the same buddy list
might make the buddy allocator more complex. But thanks for suggesting
the different approaches, will looking into these and get back to you.

> 3. Try to bunch up 'like allocations' like ZONE_MOVABLE does.
> 
> (2) could easily mean that we take the MAX_ORDER-1 buddy pages and treat
> them differently.  If the page being freed is going (or trying to go) in
> to a low power state, insert freed pages on to the tail, or on a special
> list.  When satisfying allocations, we'd make some bit of effort to
> return pages which are powered on.
> 

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
