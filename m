Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95BE76B03A7
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:51:30 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 73so199768274otj.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:51:30 -0800 (PST)
Received: from mail-ot0-x244.google.com (mail-ot0-x244.google.com. [2607:f8b0:4003:c0f::244])
        by mx.google.com with ESMTPS id m66si449445otm.162.2017.02.14.07.51.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 07:51:30 -0800 (PST)
Received: by mail-ot0-x244.google.com with SMTP id t47so2309259ota.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:51:29 -0800 (PST)
Message-ID: <1487087488.8227.53.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Feb 2017 07:51:28 -0800
In-Reply-To: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
References: <20170213195858.5215-1-edumazet@google.com>
	 <20170213195858.5215-9-edumazet@google.com>
	 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
	 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
	 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
	 <20170214131206.44b644f6@redhat.com>
	 <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
	 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, "David S
 . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 2017-02-14 at 16:56 +0200, Tariq Toukan wrote:

> As the previous series caused hangs, we must run functional regression 
> tests over this series as well.
> Run has already started, and results will be available tomorrow morning.
> 
> In general, I really like this series. The re-factorization looks more 
> elegant and more correct, functionally.
> 
> However, performance wise: we fear that the numbers will be drastically 
> lower with this transition to order-0 pages,
> because of the (becoming critical) page allocator and dma operations 
> bottlenecks, especially on systems with costly
> dma operations, such as ARM, iommu=on, etc...
> 

So, again, performance after this patch series his higher,
once you have sensible RX queues parameters, for the expected workload.

Only in pathological cases, you might have some regression.

The old schem was _maybe_ better _when_ memory is not fragmented.

When you run hosts for months, memory _is_ fragmented.

You never see that on benchmarks, unless you force memory being
fragmented.



> We already have this exact issue in mlx5, where we moved to order-0 
> allocations with a fixed size cache, but that was not enough.
> Customers of mlx5 have already complained about the performance 
> degradation, and currently this is hurting our business.
> We get a clear nack from our performance regression team regarding doing 
> the same in mlx4.
> So, the question is, can we live with this degradation until those 
> bottleneck challenges are addressed?

Again, there is no degradation.

We have been using order-0 pages for years at Google.

Only when we made the mistake to rebase from the upstream driver and
order-3 pages we got horrible regressions, causing production outages.

I was silly to believe that mm layer got better.

> Following our perf experts feedback, I cannot just simply Ack. We need 
> to have a clear plan to close the perf gap or reduce the impact.

Your perf experts need to talk to me, or any experts at Google and
Facebook, really.

Anything _relying_ on order-3 pages being available to impress
friends/customers is a lie.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
