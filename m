Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77F7F6B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 10:47:08 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id p123so3004403ybg.10
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 07:47:08 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 133si52775ybu.532.2017.07.06.07.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 07:47:07 -0700 (PDT)
Date: Thu, 6 Jul 2017 15:46:34 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706144634.GB14840@castle>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, Jul 06, 2017 at 02:19:41PM +0100, Mel Gorman wrote:
> On Thu, Jul 06, 2017 at 02:04:31PM +0100, Roman Gushchin wrote:
> > High-order allocations are obviously more costly, and it's very useful
> > to know how many of them happens, if there are any issues
> > (or suspicions) with memory fragmentation.
> > 
> > This commit changes existing per-zone allocation counters to be
> > per-zone per-order. These counters are displayed using a new
> > procfs interface (similar to /proc/buddyinfo):
> > 
> > $ cat /proc/allocinfo
> >      DMA          0          0          0          0          0 \
> >        0          0          0          0          0          0
> >    DMA32          3          0          1          0          0 \
> >        0          0          0          0          0          0
> >   Normal    4997056      23594      10902      23686        931 \
> >       23        122        786         17          1          0
> >  Movable          0          0          0          0          0 \
> >        0          0          0          0          0          0
> >   Device          0          0          0          0          0 \
> >        0          0          0          0          0          0
> > 
> > The existing vmstat interface remains untouched*, and still shows
> > the total number of single page allocations, so high-order allocations
> > are represented as a corresponding number of order-0 allocations.
> > 
> > $ cat /proc/vmstat | grep alloc
> > pgalloc_dma 0
> > pgalloc_dma32 7
> > pgalloc_normal 5461660
> > pgalloc_movable 0
> > pgalloc_device 0
> > 
> > * I've added device zone for consistency with other zones,
> > and to avoid messy exclusion of this zone in the code.
> > 
> 
> The alloc counter updates are themselves a surprisingly heavy cost to
> the allocation path and this makes it worse for a debugging case that is
> relatively rare. I'm extremely reluctant for such a patch to be added
> given that the tracepoints can be used to assemble such a monitor even
> if it means running a userspace daemon to keep track of it. Would such a
> solution be suitable? Failing that if this is a severe issue, would it be
> possible to at least make this a compile-time or static tracepoint option?
> That way, only people that really need it have to take the penalty.

I've tried to measure the difference with my patch applied and without
any accounting at all (__count_alloc_event() redefined to an empty function),
and I wasn't able to find any measurable difference.
Can you, please, provide more details, how your scenario looked like,
when alloc coutners were costly?

As new counters replace an old one, and both are per-cpu counters, I believe,
that the difference should be really small.

If there is a case, when the difference is meaningful,
I'll, of course, make the whole thing a compile-time option.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
