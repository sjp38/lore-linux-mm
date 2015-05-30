Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A606B6B0032
	for <linux-mm@kvack.org>; Fri, 29 May 2015 23:01:08 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so66456358pdb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 20:01:08 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id i12si11087115pde.152.2015.05.29.20.01.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 20:01:07 -0700 (PDT)
Date: Fri, 29 May 2015 20:01:04 -0700
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: HMM (Heterogeneous Memory Management) v8
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
Message-ID: <alpine.LNX.2.03.1505291937510.13637@nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="279739828-502894658-1432954864=:13637"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-fsdevel@vger.kernel.org, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

--279739828-502894658-1432954864=:13637
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Thu, 21 May 2015, j.glisse@gmail.com wrote:

> 
> So sorry had to resend because i stupidly forgot to cc mailing list.
> Ignore private send done before.
> 
> 
> HMM (Heterogeneous Memory Management) is an helper layer for device
> that want to mirror a process address space into their own mmu. Main
> target is GPU but other hardware, like network device can take also
> use HMM.
> 
> There is two side to HMM, first one is mirroring of process address
> space on behalf of a device. HMM will manage a secondary page table
> for the device and keep it synchronize with the CPU page table. HMM
> also do DMA mapping on behalf of the device (which would allow new
> kind of optimization further down the road (1)).
> 
> Second side is allowing to migrate process memory to device memory
> where device memory is unmappable by the CPU. Any CPU access will
> trigger special fault that will migrate memory back.
> 
> From design point of view not much changed since last patchset (2).
> Most of the change are in small details of the API expose to device
> driver. This version also include device driver change for Mellanox
> hardware to use HMM as an alternative to ODP (which provide a subset
> of HMM functionality specificaly for RDMA devices). Long term plan
> is to have HMM completely replace ODP.
> 

Hi Jerome!

OK, seeing as how there is so much material to review here, I'll start 
with the easiest part first: documentation.

There is a lot of information spread throughout this patchset that needs 
to be preserved and made readily accessible, but some of it is only found 
in the comments in patch headers. It would be better if the information 
were right there in the source tree, not just in git history. Also, the 
comment blocks that are in the code itself are useful, but maybe not 
quite sufficient to provide the big picture.

With that in mind, I think that a Documentation/vm/hmm.txt file should be 
provided. It could capture all of this. We can refer to it from within the 
code, thus providing a higher level of quality (because we only have to 
update one place, for big-picture documentation comments).

If it helps, I'll volunteer to piece something together from the material 
that you have created, plus maybe a few notes about what a typical calling 
sequence looks like (since I have actual backtraces here from the 
ConnectIB cards).

Also, there are a lot of typographical errors that we can fix up as part 
of that effort. We want to ensure that such tiny issues don't distract 
people from the valuable content, so those need to be fixed. I'll let 
others decide as to whether that sort of fit-and-finish needs to happen 
now, or as a follow-up patch or two.

And finally, a critical part of good documentation is the naming of 
things. We're sort of still in the "wow, it works" phase of this project, 
and so now is a good time to start fussing about names. Therefore, you'll 
see a bunch of small and large naming recommendations coming from me, for 
the various patches here.

thanks,
John Hubbard

> 
> 
> Why doing this ?
> 
> Mirroring a process address space is mandatory with OpenCL 2.0 and
> with other GPU compute API. OpenCL 2.0 allow different level of
> implementation and currently only the lowest 2 are supported on
> Linux. To implement the highest level, where CPU and GPU access
> can happen concurently and are cache coherent, HMM is needed, or
> something providing same functionality, for instance through
> platform hardware.
> 
> Hardware solution such as PCIE ATS/PASID is limited to mirroring
> system memory and does not provide way to migrate memory to device
> memory (which offer significantly more bandwidth up to 10 times
> faster than regular system memory with discret GPU, also have
> lower latency than PCIE transaction).
> 
> Current CPU with GPU on same die (AMD or Intel) use the ATS/PASID
> and for Intel a special level of cache (backed by a large pool of
> fast memory).
> 
> For foreseeable futur, discrete GPU will remain releveant as they
> can have a large quantity of faster memory than integrated GPU.
> 
> Thus we believe HMM will allow to leverage discret GPU memory in
> a transparent fashion to the application, with minimum disruption
> to the linux kernel mm code. Also HMM can work along hardware
> solution such as PCIE ATS/PASID (leaving regular case to ATS/PASID
> while HMM handles the migrated memory case).
> 
> 
> 
> Design :
> 
> The patch 1, 2, 3 and 4 augment the mmu notifier API with new
> informations to more efficiently mirror CPU page table updates.
> 
> The first side of HMM, process address space mirroring, is
> implemented in patch 5 through 12. This use a secondary page
> table, in which HMM mirror memory actively use by the device.
> HMM does not take a reference on any of the page, it use the
> mmu notifier API to track changes to the CPU page table and to
> update the mirror page table. All this while providing a simple
> API to device driver.
> 
> To implement this we use a "generic" page table and not a radix
> tree because we need to store more flags than radix allows and
> we need to store dma address (sizeof(dma_addr_t) > sizeof(long)
> on some platform). All this is
> 
> Patch 14 pass down the lane the new child mm struct of a parent
> process being forked. This is necessary to properly handle fork
> when parent process have migrated memory (more on that below).
> 
> Patch 15 allow to get the current memcg against which anonymous
> memory of a process should be accounted. It usefull because in
> HMM we do bulk transaction on address space and we wish to avoid
> storing a pointer to memcg for each single page. All operation
> dealing with memcg happens under the protection of the mmap
> semaphore.
> 
> 
> Second side of HMM, migration to device memory, is implemented
> in patch 16 to 28. This only deal with anonymous memory. A new
> special swap type is introduced. Migrated memory will have there
> CPU page table entry set to this special swap entry (like the
> migration entry but unlike migration this is not a short lived
> state).
> 
> All the patches are then set of functions that deals with those
> special entry in the various code path that might face them.
> 
> Memory migration require several steps, first the memory is un-
> mapped from CPU and replace with special "locked" entry, HMM
> locked entry is a short lived transitional state, this is to
> avoid two threads to fight over migration entry.
> 
> Once unmapped HMM can determine what can be migrated or not by
> comparing mapcount and page count. If something holds a reference
> then the page is not migrated and CPU page table is restored.
> Next step is to schedule the copy to device memory and update
> the CPU page table to regular HMM entry.
> 
> Migration back follow the same pattern, replace with special
> lock entry, then copy back, then update CPU page table.
> 
> 
> (1) Because HMM keeps a secondary page table which keeps track of
>     DMA mapping, there is room for new optimization. We want to
>     add a new DMA API to allow to manage DMA page table mapping
>     at directory level. This would allow to minimize memory
>     consumption of mirror page table and also over head of doing
>     DMA mapping page per page. This is a future feature we want
>     to work on and hope the idea will proove usefull not only to
>     HMM users.
> 
> (2) Previous patchset posting :
>     v1 http://lwn.net/Articles/597289/
>     v2 https://lkml.org/lkml/2014/6/12/559
>     v3 https://lkml.org/lkml/2014/6/13/633
>     v4 https://lkml.org/lkml/2014/8/29/423
>     v5 https://lkml.org/lkml/2014/11/3/759
>     v6 http://lwn.net/Articles/619737/
>     v7 http://lwn.net/Articles/627316/
> 
> 
> Cheers,
> JA(C)rA'me
> 
> To: "Andrew Morton" <akpm@linux-foundation.org>,
> Cc: <linux-kernel@vger.kernel.org>,
> Cc: linux-mm <linux-mm@kvack.org>,
> Cc: <linux-fsdevel@vger.kernel.org>,
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
> Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>,
> 
> 

thanks,
John H.

--279739828-502894658-1432954864=:13637--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
