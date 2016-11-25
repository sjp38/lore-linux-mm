Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC04C6B0253
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 11:16:35 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j49so48337906qta.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:16:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o22si18380717qta.236.2016.11.25.08.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 08:16:34 -0800 (PST)
Date: Fri, 25 Nov 2016 11:16:28 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 00/18] HMM (Heterogeneous Memory Management) v13
Message-ID: <20161125161627.GA20703@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <5ba45b16-8edf-d835-ac04-eca5f71212c9@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5ba45b16-8edf-d835-ac04-eca5f71212c9@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Feras Daoud <ferasda@mellanox.com>, Ilya Lesokhin <ilyal@mellanox.com>, Liran Liss <liranl@mellanox.com>

On Wed, Nov 23, 2016 at 11:16:04AM +0200, Haggai Eran wrote:
> On 11/18/2016 8:18 PM, Jerome Glisse wrote:
> > Cliff note: HMM offers 2 things (each standing on its own). First
> > it allows to use device memory transparently inside any process
> > without any modifications to process program code. Second it allows
> > to mirror process address space on a device.
> > 
> > Change since v12 is the use of struct page for device memory even if
> > the device memory is not accessible by the CPU (because of limitation
> > impose by the bus between the CPU and the device).
> > 
> > Using struct page means that their are minimal changes to core mm
> > code. HMM build on top of ZONE_DEVICE to provide struct page, it
> > adds new features to ZONE_DEVICE. The first 7 patches implement
> > those changes.
> > 
> > Rest of patchset is divided into 3 features that can each be use
> > independently from one another. First is the process address space
> > mirroring (patch 9 to 13), this allow to snapshot CPU page table
> > and to keep the device page table synchronize with the CPU one.
> > 
> > Second is a new memory migration helper which allow migration of
> > a range of virtual address of a process. This memory migration
> > also allow device to use their own DMA engine to perform the copy
> > between the source memory and destination memory. This can be
> > usefull even outside HMM context in many usecase.
> > 
> > Third part of the patchset (patch 17-18) is a set of helper to
> > register a ZONE_DEVICE node and manage it. It is meant as a
> > convenient helper so that device drivers do not each have to
> > reimplement over and over the same boiler plate code.
> > 
> > 
> > I am hoping that this can now be consider for inclusion upstream.
> > Bottom line is that without HMM we can not support some of the new
> > hardware features on x86 PCIE. I do believe we need some solution
> > to support those features or we won't be able to use such hardware
> > in standard like C++17, OpenCL 3.0 and others.
> > 
> > I have been working with NVidia to bring up this feature on their
> > Pascal GPU. There are real hardware that you can buy today that
> > could benefit from HMM. We also intend to leverage this inside the
> > open source nouveau driver.
> 
> 
> Hi,
> 
> I think the way this new version of the patchset uses ZONE_DEVICE looks
> promising and makes the patchset a little simpler than the previous
> versions.
> 
> The mirroring code seems like it could be used to simplify the on-demand
> paging code in the mlx5 driver and the RDMA subsystem. It currently uses
> mmu notifiers directly.
> 

Yes i plan to spawn a patchset to show how to use HMM to replace some of
the ODP code. I am waiting for patchset to go upstream first before doing
that.

> I'm also curious whether it can be used to allow peer to peer access
> between devices. For instance, if one device calls hmm_vma_get_pfns on a
> process that has unaddressable memory mapped in, with some additional
> help from DMA-API, its driver can convert these pfns to bus addresses
> directed to another device's MMIO region and thus enable peer to peer
> access. Then by handling invalidations through HMM's mirroring callbacks
> it can safely handle cases where the peer migrates the page back to the
> CPU or frees it.

Yes this is something i have work on with NVidia, idea is that you will
see the hmm_pfn_t with the device flag set you can then retrive the struct
device from it. Issue is now to figure out how from that you can know that
this is a device with which you can interact. I would like a common and
device agnostic solution but i think as first step you will need to rely
on some back channel communication.

Once you have setup a peer mapping to the GPU memory its lifetime will be
tie with CPU page table content ie if the CPU page table is updated either
to remove the page (because of munmap/truncate ...) or because the page
is migrated to some other place. In both case the device using the peer
mapping must stop using it and refault to update its page table with the
new page where the data is.

Issue to implement the above lie in the order in which mmu_notifier call-
back are call. We want to tear down the peer mapping only once we know
that any device using it is gone. If all device involve use the HMM mirror
API then this can be solve easily. Otherwise it will need some change to
mmu_notifier.

Note that all of the above would rely on change to DMA-API to allow to
IOMMAP (through iommu) PCI bar address into a device IOMMU context. But
this is an orthogonal issue.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
