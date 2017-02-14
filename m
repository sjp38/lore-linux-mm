Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61FCC680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:22:35 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n199so50287424qkn.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:22:35 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id b26si1024375pgf.332.2017.02.14.09.22.34
        for <linux-mm@kvack.org>;
        Tue, 14 Feb 2017 09:22:34 -0800 (PST)
Date: Tue, 14 Feb 2017 12:22:31 -0500 (EST)
Message-Id: <20170214.122231.2022548659001388286.davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
From: David Miller <davem@davemloft.net>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE63512@AcuExch.aculab.com>
References: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
	<20170214.120426.2032015522492111544.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6DCFE63512@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David.Laight@ACULAB.COM
Cc: ttoukan.linux@gmail.com, edumazet@google.com, brouer@redhat.com, alexander.duyck@gmail.com, netdev@vger.kernel.org, tariqt@mellanox.com, kafai@fb.com, saeedm@mellanox.com, willemb@google.com, bblanco@plumgrid.com, ast@kernel.org, eric.dumazet@gmail.com, linux-mm@kvack.org

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 14 Feb 2017 17:17:22 +0000

> From: David Miller
>> Sent: 14 February 2017 17:04
> ...
>> One path I see around all of this is full integration.  Meaning that
>> we can free pages into the page allocator which are still DMA mapped.
>> And future allocations from that device are prioritized to take still
>> DMA mapped objects.
> ...
> 
> For systems with 'expensive' iommu has anyone tried separating the
> allocation of iommu resource (eg page table slots) from their
> assignment to physical pages?
> 
> Provided the page sizes all match, setting up a receive buffer might
> be as simple as writing the physical address into the iommu slot
> that matches the ring entry.
> 
> Or am I thinking about hardware that is much simpler than real life?

You still will eat an expensive MMIO or hypervisor call to setup the
mapping.

IOMMU is expensive because of two operations, the slot allocation
(which takes locks) and the modification of the IOMMU PTE to setup
or teardown the mapping.

This is why attempts to preallocate slots (which people have looked
into) never really takes off.  You really have to eliminate the
entire operation to get worthwhile gains.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
