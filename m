Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BCAD56B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 12:11:31 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id b14so142553658wmb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:11:31 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p79si5393686wmd.111.2016.01.22.09.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 09:11:30 -0800 (PST)
Date: Fri, 22 Jan 2016 12:11:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] VM containers
Message-ID: <20160122171121.GA18062@cmpxchg.org>
References: <56A2511F.1080900@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A2511F.1080900@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: lsf-pc@lists.linuxfoundation.org, Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

Hi,

On Fri, Jan 22, 2016 at 10:56:15AM -0500, Rik van Riel wrote:
> I am trying to gauge interest in discussing VM containers at the LSF/MM
> summit this year. Projects like ClearLinux, Qubes, and others are all
> trying to use virtual machines as better isolated containers.
> 
> That changes some of the goals the memory management subsystem has,
> from "use all the resources effectively" to "use as few resources as
> necessary, in case the host needs the memory for something else".

I would be very interested in discussing this topic, because I think
the issue is more generic than these VM applications. We are facing
the same issues with regular containers, where aggressive caching is
counteracting the desire to cut down workloads to their bare minimum
in order to pack them as tightly as possible.

With per-cgroup LRUs and thrash detection, we have infrastructure in
place that could allow us to accomplish this. Right now we only enter
reclaim once memory runs out, but we could add an allocation mode that
would prefer to always reclaim from the local LRU before increasing
the memory footprint, and only expand once we detect thrashing in the
page cache. That would keep the workloads neatly trimmed at all times.

For virtualized environments, the thrashing information would be
communicated slightly differently to the page allocator and/or the
host, but otherwise the fundamental principles should be the same.

We'd have to figure out how to balance the aggressiveness there and
how to describe this to the user, as I can imagine that users would
want to tune this based on a tolerance for the degree of thrashing: if
pages are used every M ms, keep them cached; if pages are used every N
ms, freeing up the memory and refetching them from disk is better etc.

And we don't have thrash detection in secondary slab caches (yet).

> Are people interested in discussing this at LSF/MM, or is it better
> saved for a different forum?

If more people are interested, I think that could be a great topic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
