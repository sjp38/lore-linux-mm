Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BF6D96B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 12:12:32 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so25990788pab.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:12:32 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h68si17968534pfj.161.2016.01.28.09.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 09:12:31 -0800 (PST)
Date: Thu, 28 Jan 2016 20:12:20 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [LSF/MM TOPIC] VM containers
Message-ID: <20160128171220.GA4952@esperanza>
References: <56A2511F.1080900@redhat.com>
 <20160122171121.GA18062@cmpxchg.org>
 <20160127154831.GF9623@esperanza>
 <20160127183651.GA2560@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160127183651.GA2560@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, lsf-pc@lists.linuxfoundation.org, Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

On Wed, Jan 27, 2016 at 01:36:51PM -0500, Johannes Weiner wrote:
> On Wed, Jan 27, 2016 at 06:48:31PM +0300, Vladimir Davydov wrote:
> > On Fri, Jan 22, 2016 at 12:11:21PM -0500, Johannes Weiner wrote:
> > > Hi,
> > > 
> > > On Fri, Jan 22, 2016 at 10:56:15AM -0500, Rik van Riel wrote:
> > > > I am trying to gauge interest in discussing VM containers at the LSF/MM
> > > > summit this year. Projects like ClearLinux, Qubes, and others are all
> > > > trying to use virtual machines as better isolated containers.
> > > > 
> > > > That changes some of the goals the memory management subsystem has,
> > > > from "use all the resources effectively" to "use as few resources as
> > > > necessary, in case the host needs the memory for something else".
> > > 
> > > I would be very interested in discussing this topic, because I think
> > > the issue is more generic than these VM applications. We are facing
> > > the same issues with regular containers, where aggressive caching is
> > > counteracting the desire to cut down workloads to their bare minimum
> > > in order to pack them as tightly as possible.
> > > 
> > > With per-cgroup LRUs and thrash detection, we have infrastructure in
> > 
> > By thrash detection, do you mean vmpressure?
> 
> I mean mm/workingset.c, we'd have to look at actual refaults.
> 
> Reclaim efficiency is not a meaningful measure of memory pressure. You
> could be reclaiming happily and successfully every single cache page
> on the LRU, only to have userspace fault them in again right after.
> No memory pressure would be detected, even though a ton of IO is

But, if they are part of ws, mm/workingset should activate them, so that
they'd be given one more round over lru and therefore contribute to
vmpressure. So vmpressure should be a good enough indicator of
thrashing, provided mm/workingset works fine.

> caused by a lack of memory. [ For this reason, I think we should phase
> out reclaim effifiency as a metric throughout the VM - vmpressure, LRU
> type balancing, OOM invocation etc. - and base it all on thrashing. ]
> 
> > > place that could allow us to accomplish this. Right now we only enter
> > > reclaim once memory runs out, but we could add an allocation mode that
> > > would prefer to always reclaim from the local LRU before increasing
> > > the memory footprint, and only expand once we detect thrashing in the
> > > page cache. That would keep the workloads neatly trimmed at all times.
> > 
> > I don't get it. Do you mean a sort of special GFP flag that would force
> > the caller to reclaim before actual charging/allocation? Or is it
> > supposed to be automatic, basing on how memcg is behaving? If the
> > latter, I suppose it could be already done by a userspace daemon by
> > adjusting memory.high as needed, although it's unclear how to do it
> > optimally.
> 
> Yes, essentially we'd have a target footprint that we increase only
> when cache refaults (or swapins) are detected.
> 
> This could be memory.high and a userspace daemon.
> 
> We could also put it in the kernel so it's useful out of the box.

Yeah, it'd be great to have the perfect reclaimer out of the box. Not
sure it's feasible though, because there are so many ways of how it
could be implemented. I mean, well OK, it's more-or-less clear when we
should increase a container's allocation - when it starts thrashing. But
when to decrease it? Possible answers are: when other containers are
thrashing; when we detect a container stops using its memory (say, by
tracking access bits); or we can try to decrease a container's
allocation if it hasn't been thrashing for some time. That said, there
are a lot of options with their pros/cons, I don't think there's the
only right answer which could be fused into the kernel. May be, I'm
wrong.

> 
> It could be a watermark for the page allocator to work in virtualized
> environments.
> 
> > > For virtualized environments, the thrashing information would be
> > > communicated slightly differently to the page allocator and/or the
> > > host, but otherwise the fundamental principles should be the same.
> > > 
> > > We'd have to figure out how to balance the aggressiveness there and
> > > how to describe this to the user, as I can imagine that users would
> > > want to tune this based on a tolerance for the degree of thrashing: if
> > > pages are used every M ms, keep them cached; if pages are used every N
> > > ms, freeing up the memory and refetching them from disk is better etc.
> > 
> > Sounds reasonable. What about adding a parameter to memcg that would
> > define ws access time? So that it would act just like memory.low, but in
> > terms of lruvec age instead of lruvec size. I mean, we keep track of
> > lruvec ages and scan those lruvecs whose age is > ws access time before
> > others. That would protect those workloads that access their ws quite,
> > but not very often from streaming workloads which can generate a lot of
> > useless pressure.
> 
> I'm not following here. Which lruvec age?

Well, there's no such thing like lruvec age currently, but I think we
could add one. By lru list age I mean the real time that has passed
since the current tail page was added to the list or rotated. A
straightforward way to track it would be attaching a timestamp to each
page and updating it when a page is added to lru or rotated, but I
believe it is possible to get a good approximation w/o adding new page
fields. By biasing vmscan to those lruvecs whose 'age' is greater than N
ms, we would give containers N ms to set reference bits on ws pages so
that the next time they are scanned they all get rotated.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
