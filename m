Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 226236B007E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 17:02:31 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fe3so5928851pab.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 14:02:31 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 65si7310480pfi.145.2016.03.08.14.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 14:02:29 -0800 (PST)
Date: Tue, 8 Mar 2016 14:02:28 -0800
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: HMM (Heterogeneous Memory Management)
In-Reply-To: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
Message-ID: <alpine.LNX.2.20.1603081334001.24810@blueforge.nvidia.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="296541600-1806732434-1457474548=:24810"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

--296541600-1806732434-1457474548=:24810
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Tue, 8 Mar 2016, JA(C)rA'me Glisse wrote:

> Last time I spoke with Linus and Andrew, the requirement for getting
> HMM upstream was having real hardware working with it beside Mellanox
> (as Mellanox does not use all HMM features), both with closed source
> driver and open source driver. Work on open source driver is underway,
> and I anticipate we will get update from NVIDIA and other parties on
> their efforts and plans shortly.

Hi Jerome,

NVIDIA is interested in getting HMM into the kernel soon, so that it will 
be available for some of our upcoming software releases in the coming months.
One of the coolest things about HMM is that our GPU "compute" customers 
will be able to just malloc() memory, and then use that pointer in 
programs that run on the GPU. That's basically impossible without HMM, and 
it represents a huge improvement in the GPU programming experience.

So, we're very, very interested in being able to do that sort of thing. 
Here are some of the things we have been doing, and plan to do. Maybe 
seeing where we are going will help with the patchset discussion.

Right now, NVIDIA is contributing to getting HMM supported in both our 
proprietary driver, and in open source software (Nouveau, mainly) as  
well. We have developed an open-source "UVM" [1] driver that is 
intended to work with both Nouveau and with our closed-source GPU driver. 

UVM does the CPU and GPU page fault handling, among other things. In fact, 
UVM pretty much owns GPU memory management. It sits in between the core 
(HMM-enabled) kernel, and the GPU driver (either Nouveau or NVIDIA 
proprietary).

Because Nouveau's support for GPU "compute" (non-graphical) use cases is 
only now starting to come together, I expect that we'll be working closely 
with the Nouveau team on the interface between UVM and Nouveau.

NVIDIA's recent contributions to the Nouveau project included enhancements 
for Kepler and Maxwell GPUs. For HMM, we are helping key Nouveau 
developers to enable HMM features on upcoming GPUs.

thanks,
John Hubbard

----------------------------------
[1] "Unified Virtual Memory", also variously known as "Unified Memory" in 
public CUDA documentation, but in Engineering we find the latter too 
ambiguous, so we've left all the acronyms as "uvm".
----------------------------------

> 
> I am re-posting now because I want people to have time to look at HMM
> again. The open source driver will stay behind close doors until
> hardware is released. I can however have the upstream maintainer share
> his progress here if anyone feels the need for that.
> 
> Other parties such as IBM and Mediatek are also interested in HMM. I
> expect they will comment on their respective hardware when they can.
> 
> I hope that HMM can be considered for inclusion upstream soon.
> 
> This version is virtualy the same as the one since last post (modulo
> rebase differences). Tree with the patchset:
> 
> git://people.freedesktop.org/~glisse/linux hmm-v12 branch
> 
> HMM (HMM (Heterogeneous Memory Management) is an helper layer
> for device driver, its main features are :
>    - Shadow CPU page table of a process into a device specific
>      format page table and keep both page table synchronize.
>    - Handle DMA mapping of system ram page on behalf of device
>      (for shadowed page table entry).
>    - Migrate private anonymous memory to private device memory
>      and handle CPU page fault (which triggers a migration back
>      to system memory so CPU can access it).
> 
> Benefits of HMM :
>    - Avoid current model where device driver have to pin page
>      which blocks several kernel features (KSM, migration, ...).
>    - No impact on existing workload that do not use HMM (it only
>      adds couple more if() to common code path).
>    - Intended as common infrastructure for various hardware.
>    - Allow userspace API to move away from explicit copy code
>      path where application programmer has to manage manually
>      memcpy to and from device memory.
>    - Transparent to userspace, for instance allowing library to
>      use GPU without involving application linked against it.
> 
> Change log :
> 
> v12:
>   - Rebase
> 
> v11:
>   - Fix PROT_NONE case
>   - Fix missing page table walk callback
>   - Add support for hugetlbfs
> 
> v10:
>   - Minor fixes here and there.
> 
> v9:
>   - Added new device driver helpers.
>   - Added documentions.
>   - Improved page table code claritity (minor architectural changes
>     and better names).
> 
> v8:
>   - Removed currently unuse fence code.
>   - Added DMA mapping on behalf of device.
> 
> v7:
>   - Redone and simplified page table code to match Linus suggestion
>     http://article.gmane.org/gmane.linux.kernel.mm/125257
> 
> ... Lost in translation ...
> 
> 
> Why doing this ?
> 
> Mirroring a process address space is mandatory with OpenCL 2.0 and
> with other GPU compute APIs. OpenCL 2.0 allows different level of
> implementation and currently only the lowest 2 are supported on
> Linux. To implement the highest level, where CPU and GPU access
> can happen concurently and are cache coherent, HMM is needed, or
> something providing same functionality, for instance through
> platform hardware.
> 
> Hardware solution such as PCIE ATS/PASID is limited to mirroring
> system memory and does not provide way to migrate memory to device
> memory (which offer significantly more bandwidth, up to 10 times
> faster than regular system memory with discrete GPU, also have
> lower latency than PCIE transaction).
> 
> Current CPU with GPU on same die (AMD or Intel) use the ATS/PASID
> and for Intel a special level of cache (backed by a large pool of
> fast memory).
> 
> For foreseeable future, discrete GPUs will remain releveant as they
> can have a large quantity of faster memory than integrated GPU.
> 
> Thus we believe HMM will allow us to leverage discrete GPUs memory
> in a transparent fashion to the application, with minimum disruption
> to the linux kernel mm code. Also HMM can work along hardware
> solution such as PCIE ATS/PASID (leaving regular case to ATS/PASID
> while HMM handles the migrated memory case).
> 
> 
> Design :
> 
> The patch 1, 2, 3 and 4 augment the mmu notifier API with new
> informations to more efficiently mirror CPU page table updates.
> 
> The first side of HMM, process address space mirroring, is
> implemented in patch 5 through 14. This use a secondary page
> table, in which HMM mirror memory actively use by the device.
> HMM does not take a reference on any of the page, it use the
> mmu notifier API to track changes to the CPU page table and to
> update the mirror page table. All this while providing a simple
> API to device driver.
> 
> To implement this we use a "generic" page table and not a radix
> tree because we need to store more flags than radix tree allows
> and we need to store dma address (sizeof(dma_addr_t) > sizeof(long)
> on some platform).
> 
> 
> (1) Previous patchset posting :
>     v1 http://lwn.net/Articles/597289/
>     v2 https://lkml.org/lkml/2014/6/12/559
>     v3 https://lkml.org/lkml/2014/6/13/633
>     v4 https://lkml.org/lkml/2014/8/29/423
>     v5 https://lkml.org/lkml/2014/11/3/759
>     v6 http://lwn.net/Articles/619737/
>     v7 http://lwn.net/Articles/627316/
>     v8 https://lwn.net/Articles/645515/
>     v9 https://lwn.net/Articles/651553/
>     v10 https://lwn.net/Articles/654430/
>     v11 https://lkml.org/lkml/2015/10/21/739
> 
> Cheers,
> JA(C)rA'me
> 
> To: "Andrew Morton" <akpm@linux-foundation.org>,
> To: <linux-kernel@vger.kernel.org>,
> To: linux-mm <linux-mm@kvack.org>,
> Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
> Cc: "Mel Gorman" <mgorman@suse.de>,
> Cc: "H. Peter Anvin" <hpa@zytor.com>,
> Cc: "Peter Zijlstra" <peterz@infradead.org>,
> Cc: "Linda Wang" <lwang@redhat.com>,
> Cc: "Kevin E Martin" <kem@redhat.com>,
> Cc: "Andrea Arcangeli" <aarcange@redhat.com>,
> Cc: "Johannes Weiner" <jweiner@redhat.com>,
> Cc: "Larry Woodman" <lwoodman@redhat.com>,
> Cc: "Rik van Riel" <riel@redhat.com>,
> Cc: "Dave Airlie" <airlied@redhat.com>,
> Cc: "Jeff Law" <law@redhat.com>,
> Cc: "Brendan Conoboy" <blc@redhat.com>,
> Cc: "Joe Donohue" <jdonohue@redhat.com>,
> Cc: "Christophe Harle" <charle@nvidia.com>,
> Cc: "Duncan Poole" <dpoole@nvidia.com>,
> Cc: "Sherry Cheung" <SCheung@nvidia.com>,
> Cc: "Subhash Gutti" <sgutti@nvidia.com>,
> Cc: "John Hubbard" <jhubbard@nvidia.com>,
> Cc: "Mark Hairgrove" <mhairgrove@nvidia.com>,
> Cc: "Lucien Dunning" <ldunning@nvidia.com>,
> Cc: "Cameron Buschardt" <cabuschardt@nvidia.com>,
> Cc: "Arvind Gopalakrishnan" <arvindg@nvidia.com>,
> Cc: "Haggai Eran" <haggaie@mellanox.com>,
> Cc: "Or Gerlitz" <ogerlitz@mellanox.com>,
> Cc: "Sagi Grimberg" <sagig@mellanox.com>
> Cc: "Shachar Raindel" <raindel@mellanox.com>,
> Cc: "Liran Liss" <liranl@mellanox.com>,
> Cc: "Roland Dreier" <roland@purestorage.com>,
> Cc: "Sander, Ben" <ben.sander@amd.com>,
> Cc: "Stoner, Greg" <Greg.Stoner@amd.com>,
> Cc: "Bridgman, John" <John.Bridgman@amd.com>,
> Cc: "Mantor, Michael" <Michael.Mantor@amd.com>,
> Cc: "Blinzer, Paul" <Paul.Blinzer@amd.com>,
> Cc: "Morichetti, Laurent" <Laurent.Morichetti@amd.com>,
> Cc: "Deucher, Alexander" <Alexander.Deucher@amd.com>,
> Cc: "Leonid Shamis" <Leonid.Shamis@amd.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> 
--296541600-1806732434-1457474548=:24810--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
