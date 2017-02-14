Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE1F680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:04:30 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y2so54778959qkb.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:04:30 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id c26si1013279pgf.22.2017.02.14.09.04.29
        for <linux-mm@kvack.org>;
        Tue, 14 Feb 2017 09:04:29 -0800 (PST)
Date: Tue, 14 Feb 2017 12:04:26 -0500 (EST)
Message-Id: <20170214.120426.2032015522492111544.davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
From: David Miller <davem@davemloft.net>
In-Reply-To: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
References: <20170214131206.44b644f6@redhat.com>
	<CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
	<cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ttoukan.linux@gmail.com
Cc: edumazet@google.com, brouer@redhat.com, alexander.duyck@gmail.com, netdev@vger.kernel.org, tariqt@mellanox.com, kafai@fb.com, saeedm@mellanox.com, willemb@google.com, bblanco@plumgrid.com, ast@kernel.org, eric.dumazet@gmail.com, linux-mm@kvack.org

From: Tariq Toukan <ttoukan.linux@gmail.com>
Date: Tue, 14 Feb 2017 16:56:49 +0200

> Internally, I already implemented "dynamic page-cache" and
> "page-reuse" mechanisms in the driver, and together they totally
> bridge the performance gap.

I worry about a dynamically growing page cache inside of drivers
because it is invisible to the rest of the kernel.

It responds only to local needs.

The price of the real page allocator comes partly because it can
respond to global needs.

If a driver consumes some unreasonable percentage of system memory, it
is keeping that memory from being used from other parts of the system
even if it would be better for networking to be slightly slower with
less cache because that other thing that needs memory is more
important.

I think this is one of the primary reasons that the MM guys severely
chastise us when we build special purpose local caches into networking
facilities.

And the more I think about it the more I think they are right.

One path I see around all of this is full integration.  Meaning that
we can free pages into the page allocator which are still DMA mapped.
And future allocations from that device are prioritized to take still
DMA mapped objects.

Yes, we still need to make the page allocator faster, but this kind of
work helps everyone not just 100GB ethernet NICs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
