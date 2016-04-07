Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 97E606B0253
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 11:18:32 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id fe3so56679218pab.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 08:18:32 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id z4si63690par.198.2016.04.07.08.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 08:18:31 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id fe3so56679032pab.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 08:18:31 -0700 (PDT)
Message-ID: <1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [LSF/MM TOPIC] Generic page-pool recycle facility?
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Apr 2016 08:18:29 -0700
In-Reply-To: <20160407161715.52635cac@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, lsf-pc@lists.linux-foundation.org

On Thu, 2016-04-07 at 16:17 +0200, Jesper Dangaard Brouer wrote:
> (Topic proposal for MM-summit)
> 
> Network Interface Cards (NIC) drivers, and increasing speeds stress
> the page-allocator (and DMA APIs).  A number of driver specific
> open-coded approaches exists that work-around these bottlenecks in the
> page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
> allocating larger pages and handing-out page "fragments".
> 
> I'm proposing a generic page-pool recycle facility, that can cover the
> driver use-cases, increase performance and open up for zero-copy RX.
> 
> 
> The basic performance problem is that pages (containing packets at RX)
> are cycled through the page allocator (freed at TX DMA completion
> time).  While a system in a steady state, could avoid calling the page
> allocator, when having a pool of pages equal to the size of the RX
> ring plus the number of outstanding frames in the TX ring (waiting for
> DMA completion).


We certainly used this at Google for quite a while.

The thing is : in steady state, the number of pages being 'in tx queues'
is lower than number of pages that were allocated for RX queues.

The page allocator is hardly hit, once you have big enough RX ring
buffers. (Nothing fancy, simply the default number of slots)

The 'hard codedA' code is quite small actually

if (page_count(page) != 1) {
    free the page and allocate another one, 
    since we are not the exclusive owner.
    Prefer __GFP_COLD pages btw.
}
page_ref_inc(page);

Problem of a 'pool' is that it matches a router workload, not host one.

With existing code, new pages are automatically allocated on demand, if
say previous pages are still used by skb stored in sockets receive
queues and consumers are slow to react to the presence of this data.

But in most cases (steady state), the refcount on the page is released
by the application reading the data before the driver cycled through the
RX ring buffer and drivers only increments the page count.

I also played with grouping pages into the same 2MB pages, but got mixed
results.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
