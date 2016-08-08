Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 70BE96B0253
	for <linux-mm@kvack.org>; Sun,  7 Aug 2016 22:17:50 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so570503612pab.1
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 19:17:50 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id l5si34279945pfa.134.2016.08.07.19.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Aug 2016 19:17:49 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id ti13so30522064pac.0
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 19:17:49 -0700 (PDT)
Date: Sun, 7 Aug 2016 19:15:27 -0700
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Message-ID: <20160808021525.GA81429@ast-mbp>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
 <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160803174107.GA38399@ast-mbp.thefacebook.com>
 <20160804181913.26ee17b9@redhat.com>
 <1470381333.13693.48.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470381333.13693.48.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net, netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com, hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>, Daniel Borkmann <daniel@iogearbox.net>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Fri, Aug 05, 2016 at 09:15:33AM +0200, Eric Dumazet wrote:
> On Thu, 2016-08-04 at 18:19 +0200, Jesper Dangaard Brouer wrote:
> 
> > I actually agree, that we should switch to order-0 allocations.
> > 
> > *BUT* this will cause performance regressions on platforms with
> > expensive DMA operations (as they no longer amortize the cost of
> > mapping a larger page).
> 
> 
> We much prefer reliable behavior, even it it is ~1 % slower than the
> super-optimized thing that opens highways for attackers.

+1
It's more important to have deterministic performance at fresh boot
and after long uptime when high order-N are gone.

> Anyway, in most cases pages are re-used, so we only call
> dma_sync_single_range_for_cpu(), and there is no way to avoid this.
> 
> Using order-0 pages [1] is actually faster, since when we use high-order
> pages (multiple frames per 'page') we can not reuse the pages.
> 
> [1] I had a local patch to allocate these pages using a very simple
> allocator allocating max order (order-10) pages and splitting them into
> order-0 ages, in order to lower TLB footprint. But I could not measure a
> gain doing so on x86, at least on my lab machines.

Which driver was that?
I suspect that should indeed be the case for any driver that
uses build_skb and <256 copybreak.

Saeed,
could you please share the performance numbers for mlx5 order-0 vs order-N ?
You mentioned that there was some performance improvement. We need to know
how much we'll lose when we turn off order-N.
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
