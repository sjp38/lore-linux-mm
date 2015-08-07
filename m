Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2B56B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 18:35:50 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so61305462pac.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 15:35:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ep1si20008979pbd.256.2015.08.07.15.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 15:35:49 -0700 (PDT)
Date: Fri, 7 Aug 2015 15:35:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Message-Id: <20150807153547.04cf3a12ae095fcdd19da670@linux-foundation.org>
In-Reply-To: <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
	<20150807074422.GE26566@dhcp22.suse.cz>
	<0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: 'Michal Hocko' <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

On Fri, 07 Aug 2015 18:16:47 +0530 PINTU KUMAR <pintu.k@samsung.com> wrote:

> > > This is useful to know the rate of allocation success within the
> > > slowpath.
> > 
> > What would be that information good for? Is a regular administrator expected
> to
> > consume this value or this is aimed more to kernel developers? If the later
> then I
> > think a trace point sounds like a better interface.
> > 
> This information is good for kernel developers.
> I found this information useful while debugging low memory situation and
> sluggishness behavior.
> I wanted to know how many times the first allocation is failing and how many
> times system entering slowpath.
> As I said, the existing counter does not give this information clearly. 
> The pageoutrun, allocstall is too confusing.
> Also, if kswapd and compaction is disabled, we have no other counter for
> slowpath (except allocstall).
> Another problem is that allocstall can also be incremented from hibernation
> during shrink_all_memory calling.
> Which may create more confusion.
> Thus I found this interface useful to understand low memory behavior.
> If device sluggishness is happening because of too many slowpath or due to some
> other problem.
> Then we can decide what will be the best memory configuration for my device to
> reduce the slowpath.
> 
> Regarding trace points, I am not sure if we can attach counter to it.
> Also trace may have more over-head and requires additional configs to be enabled
> to debug.
> Mostly these configs will not be enabled by default (at least in embedded, low
> memory device).
> I found the vmstat interface more easy and useful.

This does seem like a pretty basic and sensible thing to expose in
vmstat.  It probably makes more sense than some of the other things we
have in there.

Yes, it could be a tracepoint but practically speaking, a tracepoint
makes it developer-only.  You can ask a bug reporter or a customer
"what is /proc/vmstat:slowpath_entered" doing, but it's harder to ask
them to set up tracing.

And I don't think this will lock us into anything - vmstat is a big
dumping ground and I don't see a big problem with removing or changing
things later on.  IMO, debugfs rules apply here and vmstat would be in
debugfs, had debugfs existed at the time.


Two things:

- we appear to have forgotten to document /proc/vmstat

- How does one actually use slowpath_entered?  Obviously we'd like to
  know "what proportion of allocations entered the slowpath", so we
  calculate

	slowpath_entered/X

  how do we obtain "X"?  Is it by adding up all the pgalloc_*?  If
  so, perhaps we should really have slowpath_entered_dma,
  slowpath_entered_dma32, ...?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
