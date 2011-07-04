Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C07679000C2
	for <linux-mm@kvack.org>; Mon,  4 Jul 2011 01:25:50 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p645PgPW008248
	for <linux-mm@kvack.org>; Mon, 4 Jul 2011 10:55:42 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p645PgoP3772558
	for <linux-mm@kvack.org>; Mon, 4 Jul 2011 10:55:42 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p645Pevk004403
	for <linux-mm@kvack.org>; Mon, 4 Jul 2011 15:25:41 +1000
Date: Mon, 4 Jul 2011 10:55:39 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory
 Allocator added
Message-ID: <20110704052539.GK12667@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <000901cc2b37$4c21f030$e465d090$%szyprowski@samsung.com>
 <20110615213958.GB28032@labbmf-linux.qualcomm.com>
 <201106160006.07742.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106160006.07742.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Larry Bassel <lbassel@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, 'Zach Pfeffer' <zach.pfeffer@linaro.org>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Daniel Stone' <daniels@collabora.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hi,

On Thu, Jun 16, 2011 at 12:06:07AM +0200, Arnd Bergmann wrote:
> On Wednesday 15 June 2011 23:39:58 Larry Bassel wrote:
> > On 15 Jun 11 10:36, Marek Szyprowski wrote:
> > > On Tuesday, June 14, 2011 10:42 PM Arnd Bergmann wrote:
> > > 
> > > > On Tuesday 14 June 2011 20:58:25 Zach Pfeffer wrote:
> > > > > I've seen this split bank allocation in Qualcomm and TI SoCs, with
> > > > > Samsung, that makes 3 major SoC vendors (I would be surprised if
> > > > > Nvidia didn't also need to do this) - so I think some configurable
> > > > > method to control allocations is necessarily. The chips can't do
> > > > > decode without it (and by can't do I mean 1080P and higher decode is
> > > > > not functionally useful). Far from special, this would appear to be
> > > > > the default.
> > 
> > We at Qualcomm have some platforms that have memory of different
> > performance characteristics, some drivers will need a way of
> > specifying that they need fast memory for an allocation (and would prefer
> > an error if it is not available rather than a fallback to slower
> > memory). It would also be bad if allocators who don't need fast
> > memory got it "accidentally", depriving those who really need it.
> 
> Can you describe how the memory areas differ specifically?
> Is there one that is always faster but very small, or are there
> just specific circumstances under which some memory is faster than
> another?
> 
> > > > The possible conflict that I still see with per-bank CMA regions are:
> > > > 
> > > > * It completely destroys memory power management in cases where that
> > > >   is based on powering down entire memory banks.
> > > 
> We already established that we have to know something about the banks,
> and your additional input makes it even clearer that we need to consider
> the bigger picture here: We need to describe parts of memory separately
> regarding general performance, device specific allocations and hotplug
> characteristics.
> 
> It still sounds to me that this can be done using the NUMA properties
> that Linux already understands, and teaching more subsystems about it,
> but maybe the memory hotplug developers have already come up with
> another scheme. The way that memory hotplug and CMA choose their
> memory regions certainly needs to take both into account. As far as
> I can see there are both conflicting and synergistic effects when
> you combine the two.
> 

Recently, we proposed a generic 'memory regions' framework to exploit
the memory power management capabilities on the embedded boards. Think
of some of the above CMA requirements could be met by this fraemwork.
One of the main goals of regions is to make the VM aware of the hardware
memory boundaries, like bank. For managing memory power consumption,
memory regions are created aligned to the hardware granularity at which
the power can be managed (ie, the memory power consumption operations
like on/off can be performed). If attributed are associated with each of
these regions, some of these regions could be marked as CMA-only,
ensuring that only movable and per-bank memory is allocated. More
details on the design can be found here:

http://lkml.org/lkml/2011/5/27/177
http://lkml.org/lkml/2011/6/29/202
http://lwn.net/Articles/446493/

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
