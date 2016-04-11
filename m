Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 355D76B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:19:16 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id j35so148409869qge.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:19:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p73si5134137qkp.18.2016.04.11.09.19.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 09:19:15 -0700 (PDT)
Date: Mon, 11 Apr 2016 18:19:07 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Message-ID: <20160411181907.15fdb8b9@redhat.com>
In-Reply-To: <20160411130826.GB32073@techsingularity.net>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160411085819.GE21128@suse.de>
	<20160411142639.1c5e520b@redhat.com>
	<20160411130826.GB32073@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com


On Mon, 11 Apr 2016 14:08:27 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> On Mon, Apr 11, 2016 at 02:26:39PM +0200, Jesper Dangaard Brouer wrote:
[...]
> > 
> > It is always great if you can optimized the page allocator.  IMHO the
> > page allocator is too slow.  
> 
> It's why I spent some time on it as any improvement in the allocator is
> an unconditional win without requiring driver modifications.
> 
> > At least for my performance needs (67ns
> > per packet, approx 201 cycles at 3GHz).  I've measured[1]
> > alloc_pages(order=0) + __free_pages() to cost 277 cycles(tsc).
> >   
> 
> It'd be worth retrying this with the branch
> 
> http://git.kernel.org/cgit/linux/kernel/git/mel/linux.git/log/?h=mm-vmscan-node-lru-v4r5
> 

The cost decreased to: 228 cycles(tsc), but there are some variations,
sometimes it increase to 238 cycles(tsc).

Nice, but there is still a looong way to my performance target, where I
can spend 201 cycles for the entire forwarding path....


> This is an unreleased series that contains both the page allocator
> optimisations and the one-LRU-per-node series which in combination remove a
> lot of code from the page allocator fast paths. I have no data on how the
> combined series behaves but each series individually is known to improve
> page allocator performance.
>
> Once you have that, do a hackjob to remove the debugging checks from both the
> alloc and free path and see what that leaves. They could be bypassed properly
> with a __GFP_NOACCT flag used only by drivers that absolutely require pages
> as quickly as possible and willing to be less safe to get that performance.

I would be interested in testing/benchmarking a patch where you remove
the debugging checks...

You are also welcome to try out my benchmarking modules yourself:
 https://github.com/netoptimizer/prototype-kernel/blob/master/getting_started.rst

This is really simple stuff (for rapid prototyping) I'm just doing:
 modprobe page_bench01; rmmod page_bench01 ; dmesg | tail -n40

[...]
> 
> Be aware that compound order allocs like this are a double edged sword as
> it'll be fast sometimes and other times require reclaim/compaction which
> can stall for prolonged periods of time.

Yes, I've notice that there can be a fairly high variation, when doing
compound order allocs, which is not so nice!  I really don't like these
variations....

Drivers also do tricks where they fallback to smaller order pages. E.g.
lookup function mlx4_alloc_pages().  I've tried to simulate that
function here:
https://github.com/netoptimizer/prototype-kernel/blob/91d323fc53/kernel/mm/bench/page_bench01.c#L69

It does not seem very optimal. I tried to mem pressure the system a bit
to cause the alloc_pages() to fail, and then the result were very bad,
something like 2500 cycles, and it usually got the next order pages.


> > I've measured order 3 (32KB) alloc_pages(order=3) + __free_pages() to
> > cost approx 500 cycles(tsc).  That was more expensive, BUT an order=3
> > page 32Kb correspond to 8 pages (32768/4096), thus 500/8 = 62.5
> > cycles.  Usually a network RX-frame only need to be 2048 bytes, thus
> > the "bulk" effect speed up is x16 (32768/2048), thus 31.25 cycles.

The order=3 cost were reduced to: 417 cycles(tsc), nice!  But I've also
seen it jump to 611 cycles.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
