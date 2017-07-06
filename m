Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C74AE6B02F3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 09:19:43 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z81so475300wrc.2
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 06:19:43 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id v4si220014wmb.178.2017.07.06.06.19.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Jul 2017 06:19:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 8E8D399827
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 13:19:41 +0000 (UTC)
Date: Thu, 6 Jul 2017 14:19:41 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1499346271-15653-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, Jul 06, 2017 at 02:04:31PM +0100, Roman Gushchin wrote:
> High-order allocations are obviously more costly, and it's very useful
> to know how many of them happens, if there are any issues
> (or suspicions) with memory fragmentation.
> 
> This commit changes existing per-zone allocation counters to be
> per-zone per-order. These counters are displayed using a new
> procfs interface (similar to /proc/buddyinfo):
> 
> $ cat /proc/allocinfo
>      DMA          0          0          0          0          0 \
>        0          0          0          0          0          0
>    DMA32          3          0          1          0          0 \
>        0          0          0          0          0          0
>   Normal    4997056      23594      10902      23686        931 \
>       23        122        786         17          1          0
>  Movable          0          0          0          0          0 \
>        0          0          0          0          0          0
>   Device          0          0          0          0          0 \
>        0          0          0          0          0          0
> 
> The existing vmstat interface remains untouched*, and still shows
> the total number of single page allocations, so high-order allocations
> are represented as a corresponding number of order-0 allocations.
> 
> $ cat /proc/vmstat | grep alloc
> pgalloc_dma 0
> pgalloc_dma32 7
> pgalloc_normal 5461660
> pgalloc_movable 0
> pgalloc_device 0
> 
> * I've added device zone for consistency with other zones,
> and to avoid messy exclusion of this zone in the code.
> 

The alloc counter updates are themselves a surprisingly heavy cost to
the allocation path and this makes it worse for a debugging case that is
relatively rare. I'm extremely reluctant for such a patch to be added
given that the tracepoints can be used to assemble such a monitor even
if it means running a userspace daemon to keep track of it. Would such a
solution be suitable? Failing that if this is a severe issue, would it be
possible to at least make this a compile-time or static tracepoint option?
That way, only people that really need it have to take the penalty.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
