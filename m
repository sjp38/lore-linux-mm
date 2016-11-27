Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09D4E6B0069
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 08:27:32 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so294359955pgd.0
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 05:27:32 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0041.outbound.protection.outlook.com. [104.47.0.41])
        by mx.google.com with ESMTPS id n23si51688361pfg.110.2016.11.27.05.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 27 Nov 2016 05:27:31 -0800 (PST)
Subject: Re: [HMM v13 00/18] HMM (Heterogeneous Memory Management) v13
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <5ba45b16-8edf-d835-ac04-eca5f71212c9@mellanox.com>
 <20161125161627.GA20703@redhat.com>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <28120b19-8167-2d27-0f59-f2ab27da2897@mellanox.com>
Date: Sun, 27 Nov 2016 15:27:11 +0200
MIME-Version: 1.0
In-Reply-To: <20161125161627.GA20703@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Feras Daoud <ferasda@mellanox.com>, Ilya Lesokhin <ilyal@mellanox.com>, Liran Liss <liranl@mellanox.com>

On 11/25/2016 6:16 PM, Jerome Glisse wrote:
> Yes this is something i have work on with NVidia, idea is that you will
> see the hmm_pfn_t with the device flag set you can then retrive the struct
> device from it. Issue is now to figure out how from that you can know that
> this is a device with which you can interact. I would like a common and
> device agnostic solution but i think as first step you will need to rely
> on some back channel communication.
Maybe this can be done with the same DMA-API changes you mention below.
Given two device structs (the peer doing the mapping and the device that
provided the pages) and some (unaddressable) ZONE_DEVICE page structs,
ask the DMA-API to provide bus addresses for that p2p transaction.

> Once you have setup a peer mapping to the GPU memory its lifetime will be
> tie with CPU page table content ie if the CPU page table is updated either
> to remove the page (because of munmap/truncate ...) or because the page
> is migrated to some other place. In both case the device using the peer
> mapping must stop using it and refault to update its page table with the
> new page where the data is.
Sounds good.

> Issue to implement the above lie in the order in which mmu_notifier call-
> back are call. We want to tear down the peer mapping only once we know
> that any device using it is gone. If all device involve use the HMM mirror
> API then this can be solve easily. Otherwise it will need some change to
> mmu_notifier.
I'm not sure I understand how p2p would work this way. If the device
that provides the memory is using HMM for migration it marks the CPU
page tables with the special swap entry. Another device that is not
using HMM mirroring won't be able to translate this into a pfn, even if
it uses mmu notifiers.

> Note that all of the above would rely on change to DMA-API to allow to
> IOMMAP (through iommu) PCI bar address into a device IOMMU context. But
> this is an orthogonal issue.

Even without an IOMMU, I think the DMA-API is a good place to tell
whether p2p is at all possible, or whether it is a good idea in terms of
performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
