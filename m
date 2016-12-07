Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 734866B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 14:48:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so40791546wmw.0
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 11:48:07 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id m186si9703478wmm.130.2016.12.07.11.48.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 11:48:06 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id C3D9C98E5A
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 19:48:02 +0000 (UTC)
Date: Wed, 7 Dec 2016 19:48:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161207194801.krhonj7yggbedpba@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 07, 2016 at 11:00:49AM -0800, Eric Dumazet wrote:
> On Wed, 2016-12-07 at 10:12 +0000, Mel Gorman wrote:
> 
> > This is the result from netperf running UDP_STREAM on localhost. It was
> > selected on the basis that it is slab-intensive and has been the subject
> > of previous SLAB vs SLUB comparisons with the caveat that this is not
> > testing between two physical hosts.
> > 
> 
> Interesting results.
> 
> netperf UDP_STREAM is not really slab intensive : (for large sendsizes
> like 16KB)
> 

Interesting because it didn't match what I previous measured but then
again, when I established that netperf on localhost was slab intensive,
it was also an older kernel. Can you tell me if SLAB or SLUB was enabled
in your test kernel?

Either that or the baseline I used has since been changed from what you
are testing and we're not hitting the same paths.

> Bulk of the storage should be allocated from alloc_skb_with_frags(),
> ie using pages.
> 
> And I am not sure we enabled high order pages in this path ?
> 
> ip_make_skb()
>  __ip_append_data()
>   sock_alloc_send_skb()
>    sock_alloc_send_pskb (...,  max_page_order=0)
>     alloc_skb_with_frags ( max_page_order=0)
>  

It doesn't look like it. While it's not directly related to this patch,
can you give the full stack? I'm particularly curious to see if these
allocations are in an IRQ path or not.

> We probably could enable high-order pages there, if we believe this is
> okay.
> 

Ultimately, not a great idea unless you want variable performance depending
on whether high-order pages are available or not. The motivation for the
patch was primarily for SLUB-intensive workloads.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
