Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B60386B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:48:44 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id x125so6822124pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 07:48:44 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rw5si10195431pab.59.2016.01.27.07.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 07:48:43 -0800 (PST)
Date: Wed, 27 Jan 2016 18:48:31 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [LSF/MM TOPIC] VM containers
Message-ID: <20160127154831.GF9623@esperanza>
References: <56A2511F.1080900@redhat.com>
 <20160122171121.GA18062@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160122171121.GA18062@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, lsf-pc@lists.linuxfoundation.org, Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

On Fri, Jan 22, 2016 at 12:11:21PM -0500, Johannes Weiner wrote:
> Hi,
> 
> On Fri, Jan 22, 2016 at 10:56:15AM -0500, Rik van Riel wrote:
> > I am trying to gauge interest in discussing VM containers at the LSF/MM
> > summit this year. Projects like ClearLinux, Qubes, and others are all
> > trying to use virtual machines as better isolated containers.
> > 
> > That changes some of the goals the memory management subsystem has,
> > from "use all the resources effectively" to "use as few resources as
> > necessary, in case the host needs the memory for something else".
> 
> I would be very interested in discussing this topic, because I think
> the issue is more generic than these VM applications. We are facing
> the same issues with regular containers, where aggressive caching is
> counteracting the desire to cut down workloads to their bare minimum
> in order to pack them as tightly as possible.
> 
> With per-cgroup LRUs and thrash detection, we have infrastructure in

By thrash detection, do you mean vmpressure?

> place that could allow us to accomplish this. Right now we only enter
> reclaim once memory runs out, but we could add an allocation mode that
> would prefer to always reclaim from the local LRU before increasing
> the memory footprint, and only expand once we detect thrashing in the
> page cache. That would keep the workloads neatly trimmed at all times.

I don't get it. Do you mean a sort of special GFP flag that would force
the caller to reclaim before actual charging/allocation? Or is it
supposed to be automatic, basing on how memcg is behaving? If the
latter, I suppose it could be already done by a userspace daemon by
adjusting memory.high as needed, although it's unclear how to do it
optimally.

> 
> For virtualized environments, the thrashing information would be
> communicated slightly differently to the page allocator and/or the
> host, but otherwise the fundamental principles should be the same.
> 
> We'd have to figure out how to balance the aggressiveness there and
> how to describe this to the user, as I can imagine that users would
> want to tune this based on a tolerance for the degree of thrashing: if
> pages are used every M ms, keep them cached; if pages are used every N
> ms, freeing up the memory and refetching them from disk is better etc.

Sounds reasonable. What about adding a parameter to memcg that would
define ws access time? So that it would act just like memory.low, but in
terms of lruvec age instead of lruvec size. I mean, we keep track of
lruvec ages and scan those lruvecs whose age is > ws access time before
others. That would protect those workloads that access their ws quite,
but not very often from streaming workloads which can generate a lot of
useless pressure.

Thanks,
Vladimir

> 
> And we don't have thrash detection in secondary slab caches (yet).
> 
> > Are people interested in discussing this at LSF/MM, or is it better
> > saved for a different forum?
> 
> If more people are interested, I think that could be a great topic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
