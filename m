Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB576B004A
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:04:11 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5GFqjkk024418
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 11:52:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5GG48ri153738
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:04:08 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5GC3uF1030992
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 09:03:56 -0300
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110616042044.GA28563@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	 <20110613134701.2b23b8d8.kamezawa.hiroyu@jp.fujitsu.com>
	 <20110616042044.GA28563@in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jun 2011 09:04:00 -0700
Message-ID: <1308240240.11430.115.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Thu, 2011-06-16 at 09:50 +0530, Ankita Garg wrote:
> - Correctly predicting memory pressure is difficult and thereby being
>   able to online the required pages at the right time could be a
>   challenge

For the sake of this discussion, let's forget about this.  There are
certainly a lot of scenarios where turning memory on/off is necessary
and useful _without_ knowing what kind of load the system is under.  "We
just shut down our huge database, and now have 99% of RAM free" is a
fine, dumb, metric.  We don't have to have magical pony memory pressure
detection as a prerequisite.

> - Memory hotplug is a heavy operation, so the overhead involved may be
>   high

I'm curious.  Why do you say this?  Could you elaborate a bit on _how_
memory hotplug is different from what you're doing here?  On powerpc, at
least, we can do memory hotplug in areas as small as 16MB.  That's _way_
smaller than what you're talking about here, and I would assume that
smaller here means less overhead.

> - Powering off memory is just one of the ways in which memory power could
>   be saved. The platform can also dynamically transition areas of memory
>   into a  content-preserving lower power state if it is not referenced
>   for a pre-defined threshold of time. In such a case, we would need a
>   mechanism to soft offline the pages - i.e, no new allocations to be
>   directed to that memory

OK...  That's fine, but I think you're avoiding the question a bit.  You
need to demonstrate that this 'regions' thing is necessary to do this,
and that we can not get by just modifying what we have now.  For
instance:

1. Have something like khugepaged try to find region-sized chunks of
   memory to free.
2. Modify the buddy allocator to be "picky" about when it lets you get 
   access to these regions.
3. Try to bunch up 'like allocations' like ZONE_MOVABLE does.

(2) could easily mean that we take the MAX_ORDER-1 buddy pages and treat
them differently.  If the page being freed is going (or trying to go) in
to a low power state, insert freed pages on to the tail, or on a special
list.  When satisfying allocations, we'd make some bit of effort to
return pages which are powered on.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
