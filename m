Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id D92D76B0253
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 15:15:41 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so18758667qkb.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:15:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si5379737qgl.25.2015.08.13.12.15.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 12:15:41 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: HMM (Heterogeneous Memory Management) v10
Date: Thu, 13 Aug 2015 15:15:13 -0400
Message-Id: <1439493328-1028-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

Minor fixes since last post (1), apply on top of 4.2-rc6 done
that because conflict in infiniband are harder to solve then
conflict with mm tree.

Tree with the patchset:
git://people.freedesktop.org/~glisse/linux hmm-v10 branch

Previous cover letter :



HMM (Heterogeneous Memory Management) is an helper layer for device
that want to mirror a process address space into their own mmu. Main
target is GPU but other hardware, like network device can take also
use HMM.

There is two side to HMM, first one is mirroring of process address
space on behalf of a device. HMM will manage a secondary page table
for the device and keep it synchronize with the CPU page table. HMM
also do DMA mapping on behalf of the device (which would allow new
kind of optimization further down the road (2)).

Second side is allowing to migrate process memory to device memory
where device memory is unmappable by the CPU. Any CPU access will
trigger special fault that will migrate memory back. This patchset
does not deal with remote memory migration.


Why doing this ?

Mirroring a process address space is mandatory with OpenCL 2.0 and
with other GPU compute API. OpenCL 2.0 allow different level of
implementation and currently only the lowest 2 are supported on
Linux. To implement the highest level, where CPU and GPU access
can happen concurently and are cache coherent, HMM is needed, or
something providing same functionality, for instance through
platform hardware.

Hardware solution such as PCIE ATS/PASID is limited to mirroring
system memory and does not provide way to migrate memory to device
memory (which offer significantly more bandwidth up to 10 times
faster than regular system memory with discret GPU, also have
lower latency than PCIE transaction).

Current CPU with GPU on same die (AMD or Intel) use the ATS/PASID
and for Intel a special level of cache (backed by a large pool of
fast memory).

For foreseeable futur, discrete GPU will remain releveant as they
can have a large quantity of faster memory than integrated GPU.

Thus we believe HMM will allow to leverage discret GPU memory in
a transparent fashion to the application, with minimum disruption
to the linux kernel mm code. Also HMM can work along hardware
solution such as PCIE ATS/PASID (leaving regular case to ATS/PASID
while HMM handles the migrated memory case).


Design :

The patch 1, 2, 3 and 4 augment the mmu notifier API with new
informations to more efficiently mirror CPU page table updates.

The first side of HMM, process address space mirroring, is
implemented in patch 5 through 14. This use a secondary page
table, in which HMM mirror memory actively use by the device.
HMM does not take a reference on any of the page, it use the
mmu notifier API to track changes to the CPU page table and to
update the mirror page table. All this while providing a simple
API to device driver.

To implement this we use a "generic" page table and not a radix
tree because we need to store more flags than radix allows and
we need to store dma address (sizeof(dma_addr_t) > sizeof(long)
on some platform). All this is


(1) Previous patchset posting :
    v1 http://lwn.net/Articles/597289/
    v2 https://lkml.org/lkml/2014/6/12/559
    v3 https://lkml.org/lkml/2014/6/13/633
    v4 https://lkml.org/lkml/2014/8/29/423
    v5 https://lkml.org/lkml/2014/11/3/759
    v6 http://lwn.net/Articles/619737/
    v7 http://lwn.net/Articles/627316/
    v8 https://lwn.net/Articles/645515/
    v9 https://lwn.net/Articles/651553/

(2) Because HMM keeps a secondary page table which keeps track of
    DMA mapping, there is room for new optimization. We want to
    add a new DMA API to allow to manage DMA page table mapping
    at directory level. This would allow to minimize memory
    consumption of mirror page table and also over head of doing
    DMA mapping page per page. This is a future feature we want
    to work on and hope the idea will proove usefull not only to
    HMM users.


Cheers,
JA(C)rA'me

To: "Andrew Morton" <akpm@linux-foundation.org>,
To: <linux-kernel@vger.kernel.org>,
To: linux-mm <linux-mm@kvack.org>,
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
Cc: "Mel Gorman" <mgorman@suse.de>,
Cc: "H. Peter Anvin" <hpa@zytor.com>,
Cc: "Peter Zijlstra" <peterz@infradead.org>,
Cc: "Linda Wang" <lwang@redhat.com>,
Cc: "Kevin E Martin" <kem@redhat.com>,
Cc: "Andrea Arcangeli" <aarcange@redhat.com>,
Cc: "Johannes Weiner" <jweiner@redhat.com>,
Cc: "Larry Woodman" <lwoodman@redhat.com>,
Cc: "Rik van Riel" <riel@redhat.com>,
Cc: "Dave Airlie" <airlied@redhat.com>,
Cc: "Jeff Law" <law@redhat.com>,
Cc: "Brendan Conoboy" <blc@redhat.com>,
Cc: "Joe Donohue" <jdonohue@redhat.com>,
Cc: "Christophe Harle" <charle@nvidia.com>,
Cc: "Duncan Poole" <dpoole@nvidia.com>,
Cc: "Sherry Cheung" <SCheung@nvidia.com>,
Cc: "Subhash Gutti" <sgutti@nvidia.com>,
Cc: "John Hubbard" <jhubbard@nvidia.com>,
Cc: "Mark Hairgrove" <mhairgrove@nvidia.com>,
Cc: "Lucien Dunning" <ldunning@nvidia.com>,
Cc: "Cameron Buschardt" <cabuschardt@nvidia.com>,
Cc: "Arvind Gopalakrishnan" <arvindg@nvidia.com>,
Cc: "Haggai Eran" <haggaie@mellanox.com>,
Cc: "Or Gerlitz" <ogerlitz@mellanox.com>,
Cc: "Sagi Grimberg" <sagig@mellanox.com>
Cc: "Shachar Raindel" <raindel@mellanox.com>,
Cc: "Liran Liss" <liranl@mellanox.com>,
Cc: "Roland Dreier" <roland@purestorage.com>,
Cc: "Sander, Ben" <ben.sander@amd.com>,
Cc: "Stoner, Greg" <Greg.Stoner@amd.com>,
Cc: "Bridgman, John" <John.Bridgman@amd.com>,
Cc: "Mantor, Michael" <Michael.Mantor@amd.com>,
Cc: "Blinzer, Paul" <Paul.Blinzer@amd.com>,
Cc: "Morichetti, Laurent" <Laurent.Morichetti@amd.com>,
Cc: "Deucher, Alexander" <Alexander.Deucher@amd.com>,
Cc: "Leonid Shamis" <Leonid.Shamis@amd.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
