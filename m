Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA6956B0269
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 14:01:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so112128140pgd.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 11:01:52 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s136si25088198pgc.65.2016.12.07.11.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 11:01:51 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id i88so11589929pfk.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 11:01:51 -0800 (PST)
Message-ID: <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Dec 2016 11:00:49 -0800
In-Reply-To: <20161207101228.8128-1-mgorman@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, 2016-12-07 at 10:12 +0000, Mel Gorman wrote:

> This is the result from netperf running UDP_STREAM on localhost. It was
> selected on the basis that it is slab-intensive and has been the subject
> of previous SLAB vs SLUB comparisons with the caveat that this is not
> testing between two physical hosts.
> 

Interesting results.

netperf UDP_STREAM is not really slab intensive : (for large sendsizes
like 16KB)

Bulk of the storage should be allocated from alloc_skb_with_frags(),
ie using pages.

And I am not sure we enabled high order pages in this path ?

ip_make_skb()
 __ip_append_data()
  sock_alloc_send_skb()
   sock_alloc_send_pskb (...,  max_page_order=0)
    alloc_skb_with_frags ( max_page_order=0)
 
So far, I believe net/unix/af_unix.c uses PAGE_ALLOC_COSTLY_ORDER as
max_order, but UDP does not do that yet.

We probably could enable high-order pages there, if we believe this is
okay.

Or maybe I missed and this already happened ? ;)

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
