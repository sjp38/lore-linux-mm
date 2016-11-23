Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 645946B026B
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 04:16:38 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so9471046pfx.1
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:16:38 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10048.outbound.protection.outlook.com. [40.107.1.48])
        by mx.google.com with ESMTPS id 19si32795431pfr.164.2016.11.23.01.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 01:16:37 -0800 (PST)
Subject: Re: [HMM v13 00/18] HMM (Heterogeneous Memory Management) v13
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <5ba45b16-8edf-d835-ac04-eca5f71212c9@mellanox.com>
Date: Wed, 23 Nov 2016 11:16:04 +0200
MIME-Version: 1.0
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Feras Daoud <ferasda@mellanox.com>, Ilya Lesokhin <ilyal@mellanox.com>, Liran Liss <liranl@mellanox.com>

On 11/18/2016 8:18 PM, JA(C)rA'me Glisse wrote:
> Cliff note: HMM offers 2 things (each standing on its own). First
> it allows to use device memory transparently inside any process
> without any modifications to process program code. Second it allows
> to mirror process address space on a device.
> 
> Change since v12 is the use of struct page for device memory even if
> the device memory is not accessible by the CPU (because of limitation
> impose by the bus between the CPU and the device).
> 
> Using struct page means that their are minimal changes to core mm
> code. HMM build on top of ZONE_DEVICE to provide struct page, it
> adds new features to ZONE_DEVICE. The first 7 patches implement
> those changes.
> 
> Rest of patchset is divided into 3 features that can each be use
> independently from one another. First is the process address space
> mirroring (patch 9 to 13), this allow to snapshot CPU page table
> and to keep the device page table synchronize with the CPU one.
> 
> Second is a new memory migration helper which allow migration of
> a range of virtual address of a process. This memory migration
> also allow device to use their own DMA engine to perform the copy
> between the source memory and destination memory. This can be
> usefull even outside HMM context in many usecase.
> 
> Third part of the patchset (patch 17-18) is a set of helper to
> register a ZONE_DEVICE node and manage it. It is meant as a
> convenient helper so that device drivers do not each have to
> reimplement over and over the same boiler plate code.
> 
> 
> I am hoping that this can now be consider for inclusion upstream.
> Bottom line is that without HMM we can not support some of the new
> hardware features on x86 PCIE. I do believe we need some solution
> to support those features or we won't be able to use such hardware
> in standard like C++17, OpenCL 3.0 and others.
> 
> I have been working with NVidia to bring up this feature on their
> Pascal GPU. There are real hardware that you can buy today that
> could benefit from HMM. We also intend to leverage this inside the
> open source nouveau driver.


Hi,

I think the way this new version of the patchset uses ZONE_DEVICE looks
promising and makes the patchset a little simpler than the previous
versions.

The mirroring code seems like it could be used to simplify the on-demand
paging code in the mlx5 driver and the RDMA subsystem. It currently uses
mmu notifiers directly.

I'm also curious whether it can be used to allow peer to peer access
between devices. For instance, if one device calls hmm_vma_get_pfns on a
process that has unaddressable memory mapped in, with some additional
help from DMA-API, its driver can convert these pfns to bus addresses
directed to another device's MMIO region and thus enable peer to peer
access. Then by handling invalidations through HMM's mirroring callbacks
it can safely handle cases where the peer migrates the page back to the
CPU or frees it.

Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
