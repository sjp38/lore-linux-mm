Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4606680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:38:30 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id y2so59888826qkb.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:38:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m70si1140220qkl.236.2017.02.14.11.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:38:29 -0800 (PST)
Date: Tue, 14 Feb 2017 20:38:22 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Message-ID: <20170214203822.72d41268@redhat.com>
In-Reply-To: <20170214.120426.2032015522492111544.davem@davemloft.net>
References: <20170214131206.44b644f6@redhat.com>
	<CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
	<cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
	<20170214.120426.2032015522492111544.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: ttoukan.linux@gmail.com, edumazet@google.com, alexander.duyck@gmail.com, netdev@vger.kernel.org, tariqt@mellanox.com, kafai@fb.com, saeedm@mellanox.com, willemb@google.com, bblanco@plumgrid.com, ast@kernel.org, eric.dumazet@gmail.com, linux-mm@kvack.org, brouer@redhat.com

On Tue, 14 Feb 2017 12:04:26 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Tariq Toukan <ttoukan.linux@gmail.com>
> Date: Tue, 14 Feb 2017 16:56:49 +0200
> 
> > Internally, I already implemented "dynamic page-cache" and
> > "page-reuse" mechanisms in the driver, and together they totally
> > bridge the performance gap.  

It sounds like you basically implemented a page_pool scheme...

> I worry about a dynamically growing page cache inside of drivers
> because it is invisible to the rest of the kernel.

Exactly, that is why I wanted a separate standardized thing, I call the
page_pool, which is part of the MM-tree and interacts with the page
allocator.  E.g. it must implement/support a way the page allocator can
reclaim pages from it (admit I didn't implement this in RFC patches).


> It responds only to local needs.

Generally true, but a side effect of recycling these pages, result in
less fragmentation of the page allocator/buddy system.


> The price of the real page allocator comes partly because it can
> respond to global needs.
> 
> If a driver consumes some unreasonable percentage of system memory, it
> is keeping that memory from being used from other parts of the system
> even if it would be better for networking to be slightly slower with
> less cache because that other thing that needs memory is more
> important.

(That is why I want to have OOM protection at device level, with the
recycle feedback from page pool we have this knowledge, and further I
wanted to allow blocking a specific RX queue[1])
[1] https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html#userspace-delivery-and-oom


> I think this is one of the primary reasons that the MM guys severely
> chastise us when we build special purpose local caches into networking
> facilities.
> 
> And the more I think about it the more I think they are right.

+1
 
> One path I see around all of this is full integration.  Meaning that
> we can free pages into the page allocator which are still DMA mapped.
> And future allocations from that device are prioritized to take still
> DMA mapped objects.

I like this idea.  Are you saying that this should be done per DMA
engine or per device?

If this is per device, it is almost the page_pool idea.  

 
> Yes, we still need to make the page allocator faster, but this kind of
> work helps everyone not just 100GB ethernet NICs.

True.  And Mel already have some generic improvements to the page
allocator queued for the next merge.  And I have the responsibility to
get the bulking API into shape.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
