Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE536B0258
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:37:45 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l66so16565244wml.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:37:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bc5si10058819wjb.106.2016.01.27.10.37.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:37:44 -0800 (PST)
Date: Wed, 27 Jan 2016 13:36:51 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] VM containers
Message-ID: <20160127183651.GA2560@cmpxchg.org>
References: <56A2511F.1080900@redhat.com>
 <20160122171121.GA18062@cmpxchg.org>
 <20160127154831.GF9623@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160127154831.GF9623@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Rik van Riel <riel@redhat.com>, lsf-pc@lists.linuxfoundation.org, Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

On Wed, Jan 27, 2016 at 06:48:31PM +0300, Vladimir Davydov wrote:
> On Fri, Jan 22, 2016 at 12:11:21PM -0500, Johannes Weiner wrote:
> > Hi,
> > 
> > On Fri, Jan 22, 2016 at 10:56:15AM -0500, Rik van Riel wrote:
> > > I am trying to gauge interest in discussing VM containers at the LSF/MM
> > > summit this year. Projects like ClearLinux, Qubes, and others are all
> > > trying to use virtual machines as better isolated containers.
> > > 
> > > That changes some of the goals the memory management subsystem has,
> > > from "use all the resources effectively" to "use as few resources as
> > > necessary, in case the host needs the memory for something else".
> > 
> > I would be very interested in discussing this topic, because I think
> > the issue is more generic than these VM applications. We are facing
> > the same issues with regular containers, where aggressive caching is
> > counteracting the desire to cut down workloads to their bare minimum
> > in order to pack them as tightly as possible.
> > 
> > With per-cgroup LRUs and thrash detection, we have infrastructure in
> 
> By thrash detection, do you mean vmpressure?

I mean mm/workingset.c, we'd have to look at actual refaults.

Reclaim efficiency is not a meaningful measure of memory pressure. You
could be reclaiming happily and successfully every single cache page
on the LRU, only to have userspace fault them in again right after.
No memory pressure would be detected, even though a ton of IO is
caused by a lack of memory. [ For this reason, I think we should phase
out reclaim effifiency as a metric throughout the VM - vmpressure, LRU
type balancing, OOM invocation etc. - and base it all on thrashing. ]

> > place that could allow us to accomplish this. Right now we only enter
> > reclaim once memory runs out, but we could add an allocation mode that
> > would prefer to always reclaim from the local LRU before increasing
> > the memory footprint, and only expand once we detect thrashing in the
> > page cache. That would keep the workloads neatly trimmed at all times.
> 
> I don't get it. Do you mean a sort of special GFP flag that would force
> the caller to reclaim before actual charging/allocation? Or is it
> supposed to be automatic, basing on how memcg is behaving? If the
> latter, I suppose it could be already done by a userspace daemon by
> adjusting memory.high as needed, although it's unclear how to do it
> optimally.

Yes, essentially we'd have a target footprint that we increase only
when cache refaults (or swapins) are detected.

This could be memory.high and a userspace daemon.

We could also put it in the kernel so it's useful out of the box.

It could be a watermark for the page allocator to work in virtualized
environments.

> > For virtualized environments, the thrashing information would be
> > communicated slightly differently to the page allocator and/or the
> > host, but otherwise the fundamental principles should be the same.
> > 
> > We'd have to figure out how to balance the aggressiveness there and
> > how to describe this to the user, as I can imagine that users would
> > want to tune this based on a tolerance for the degree of thrashing: if
> > pages are used every M ms, keep them cached; if pages are used every N
> > ms, freeing up the memory and refetching them from disk is better etc.
> 
> Sounds reasonable. What about adding a parameter to memcg that would
> define ws access time? So that it would act just like memory.low, but in
> terms of lruvec age instead of lruvec size. I mean, we keep track of
> lruvec ages and scan those lruvecs whose age is > ws access time before
> others. That would protect those workloads that access their ws quite,
> but not very often from streaming workloads which can generate a lot of
> useless pressure.

I'm not following here. Which lruvec age?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
