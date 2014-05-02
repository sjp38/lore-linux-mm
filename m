Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6A51A6B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:52:49 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id x13so4739916qcv.7
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:52:49 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id w38si5722000qgd.78.2014.05.02.06.52.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:52:48 -0700 (PDT)
Received: by mail-qg0-f47.google.com with SMTP id e89so4764922qgf.34
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:52:48 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [RFC] Heterogeneous memory management (mirror process address space on a device mmu).
Date: Fri,  2 May 2014 09:51:59 -0400
Message-Id: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>

In a nutshell:

The heterogeneous memory management (hmm) patchset implement a new api that
sit on top of the mmu notifier api. It provides a simple api to device driver
to mirror a process address space without having to lock or take reference on
page and block them from being reclam or migrated. Any changes on a process
address space is mirrored to the device page table by the hmm code. To achieve
this not only we need each driver to implement a set of callback functions but
hmm also interface itself in many key location of the mm code and fs code.
Moreover hmm allow to migrate range of memory to the device remote memory to
take advantages of its lower latency and higher bandwidth.

The why:

We want to be able to mirror a process address space so that compute api such
as OpenCL or other similar api can start using the exact same address space on
the GPU as on the CPU. This will greatly simplify usages of those api. Moreover
we believe that we will see more and more specialize unit functions that will
want to mirror process address using their own mmu.

To achieve this hmm requires :
 A.1 - Hardware requirements
 A.2 - sleeping inside mmu_notifier
 A.3 - context information for mmu_notifier callback (patch 1 and 2)
 A.4 - new helper function for memcg (patch 5)
 A.5 - special swap type and fault handling code
 A.6 - file backed memory and filesystem changes
 A.7 - The write back expectation

While avoiding :
 B.1 - No new page flag
 B.2 - No special page reclamation code

Finally the rest of this email deals with :
 C.1 - Alternative designs
 C.2 - Hardware solution
 C.3 - Routines marked EXPORT_SYMBOL
 C.4 - Planned features
 C.5 - Getting upstream

But first patchlist :

 0001 - Clarify the use of TTU_UNMAP as being done for VMSCAN or POISONING
 0002 - Give context information to mmu_notifier callback ie why the callback
        is made for (because of munmap call, or page migration, ...).
 0003 - Provide the vma for which the invalidation is happening to mmu_notifier
        callback. This is mostly and optimization to avoid looking up again the
        vma inside the mmu_notifier callback.
 0004 - Add new helper to the generic interval tree (which use rb tree).
 0005 - Add new helper to memcg so that anonymous page can be accounted as well
        as unaccounted without a page struct. Also add a new helper function to
        transfer a charge to a page (charge which have been accounted without a
        struct page in the first place).
 0006 - Introduce the hmm basic code to support simple device mirroring of the
        address space. It is fully functional modulo some missing bit (guard or
        huge page and few other small corner cases).
 0007 - Introduce support for migrating anonymous memory to device memory. This
        involve introducing a new special swap type and teach the mm page fault
        code about hmm.
 0008 - Introduce support for migrating shared or private memory that is backed
        by a file. This is way more complex than anonymous case as it needs to
        synchronize with and exclude other kernel code path that might try to
        access those pages.
 0009 - Add hmm support to ext4 filesystem.
 0010 - Introduce a simple dummy driver that showcase use of the hmm api.
 0011 - Add support for remote memory to the dummy driver.

I believe that patch 1, 2, 3 are use full on their own as they could help fix
some kvm issues (see https://lkml.org/lkml/2014/1/15/125) and they do not
modify behavior of any current code (except that patch 3 might result in a
larger number of call to mmu_notifier as many as there is different vma for
a range).

Other patches have many rough edges but we would like to validate our design
and see what we need to change before smoothing out any of them.


A.1 - Hardware requirements :

The hardware must have its own mmu with a page table per process it wants to
mirror. The device mmu mandatory features are :
  - per page read only flag.
  - page fault support that stop/suspend hardware thread and support resuming
    those hardware thread once the page fault have been serviced.
  - same number of bits for the virtual address as the target architecture (for
    instance 48 bits on current AMD 64).

Advanced optional features :
  - per page dirty bit (indicating the hardware did write to the page).
  - per page access bit (indicating the hardware did access the page).


A.2 - Sleeping in mmu notifier callback :

Because update device mmu might need to sleep, either for taking device driver
lock (which might be consider fixable) or simply because invalidating the mmu
might take several hundred millisecond and might involve allocating device or
driver resources to perform the operation any of which might require to sleep.

Thus we need to be able to sleep inside mmu_notifier_invalidate_range_start at
the very least. Also we need to call to mmu_notifier_change_pte to be bracketed
by mmu_notifier_invalidate_range_start and mmu_notifier_invalidate_range_end.
We need this because mmu_notifier_change_pte is call with the anon vma lock
held (and this is a non sleepable lock).


A.3 - Context information for mmu_notifier callback :

There is a need to provide more context information on why a mmu_notifier call
back does happen. Was it because userspace call munmap ? Or was it because the
kernel is trying to free some memory ? Or because page is being migrated ?

The context is provided by using unique enum value associated with call site of
mmu_notifier functions. The patch here just add the enum value and modify each
call site to pass along the proper value.

The context information is important for management of the secondary mmu. For
instance on a munmap the device driver will want to free all resources used by
that range (device page table memory). This could as well solve the issue that
was discussed in this thread https://lkml.org/lkml/2014/1/15/125 kvm can ignore
mmu_notifier_invalidate_range based on the enum value.


A.4 - New helper function for memcg :

To keep memory control working as expect with the introduction of remote memory
we need to add new helper function so we can account anonymous remote memory as
if it was backed by a page. We also need to be able to transfer charge from the
remote memory to pages and we need to be able clear a page cgroup without side
effect to the memcg.

The patchset currently does add a new type of memory resource but instead just
account remote memory as local memory (struct page) is. This is done with the
minimum amount of change to the memcg code. I believe they are correct.

It might make sense to introduce a new sub-type of memory down the road so that
device memory can be included inside the memcg accounting but we choose to not
do so at first.


A.5 - Special swap type and fault handling code :

When some range of address is backed by device memory we need cpu fault to be
aware of that so it can ask hmm to trigger migration back to local memory. To
avoid too much code disruption we do so by adding a new special hmm swap type
that is special cased in various place inside the mm page fault code. Refer to
patch 7 for details.


A.6 - File backed memory and filesystem changes :

Using remote memory for range of address backed by a file is more complex than
anonymous memory. There are lot more code path that might want to access pages
that cache a file (for read, write, splice, ...). To avoid disrupting the code
too much and sleeping inside page cache look up we decided to add hmm support
on a per filesystem basis. So each filesystem can be teach about hmm and how to
interact with it correctly.

The design is relatively simple, the radix tree is updated to use special hmm
swap entry for any page which is in remote memory. Thus any radix tree look up
will find the special entry and will know it needs to synchronize itself with
hmm to access the file.

There is however subtleties. Updating the radix tree does not guarantee that
hmm is the sole user of the page, another kernel/user thread might have done a
radix look up before the radix tree update.

The solution to this issue is to first update the radix tree, then lock each
page we are migrating, then unmap it from all the process using it and setting
its mapping field to NULL so that once we unlock the page all existing code
will thought that the page was either truncated or reclaimed in both cases all
existing kernel code path will eith perform new look and see the hmm special
entry or will just skip the page. Those code path were audited to insure that
their behavior and expected result are not modified by this.

However this does not insure us exclusive access to the page. So at first when
migrating such page to remote memory we map it read only inside the device and
keep the page around so that both the device copy and the page copy contain the
same data. If the device wishes to write to this remote memory then it call hmm
fault code.

To allow write on remote memory hmm will try to free the page, if the page can
be free then it means hmm is the unique user of the page and the remote memory
can safely be written to. If not then this means that the page content might
still be in use by some other process and the device driver have to choose to
either wait or use the local memory instead. So local memory page are kept as
long as there are other user for them. We likely need to hookup some special
page reclamation code to force reclaiming those pages after a while.


A.7 - The write back expectation :

We also wanted to preserve the writeback and dirty balancing as we believe this
is an important behavior (avoiding dirty content to stay for too long inside
remote memory without being write back to disk). To avoid constantly migrating
memory back and forth we decided to use existing page (hmm keep all shared page
around and never free them for the lifetime of rmem object they are associated
with) as temporary writeback source. On writeback the remote memory is mapped
read only on the device and copied back to local memory which is use as source
for the disk write.

This design choice can however be seen as counter productive as it means that
the device using hmm will see its rmem map read only for writeback and then
will have to wait for writeback to go through. Another choice would be to
forget writeback while memory is on the device and pretend page are clear but
this would break fsync and similar API for file that does have part of its
content inside some device memory.

Middle ground might be to keep fsync and alike working but to ignore any other
writeback.


B.1 - No new page flag :

While adding a new page flag would certainly help to find a different design to
implement the hmm feature set. We tried to only think about design that do not
require such a new flag.


B.2 - No special page reclamation code :

This is one of the big issue, should be isolate pages that are actively use
by a device from the regular lru to a specific lru managed by the hmm code.
In this patchset we decided to avoid doing so as it would just add complexity
to already complex code.

Current code will trigger sleep inside vmscan when trying to reclaim page that
belong to a process which is mirrored on a device. Is this acceptable or should
we add a new hmm lru list that would handle all pages used by device in special
way so that those pages are isolated from the regular page reclamation code.


C.1 - Alternative designs :

The current design is the one we believe provide enough ground to support all
necessary features while keeping complexity as low as possible. However i think
it is important to state that several others designs were tested and to explain
why they were discarded.

D1) One of the first design introduced a secondary page table directly updated
  by hmm helper functions. Hope was that this secondary page table could be in
  some way directly use by the device. That was naive ... to say the least.

D2) The secondary page table with hmm specific format, was another design that
  we tested. In this one the secondary page table was not intended to be use by
  the device but was intended to serve as a buffer btw the cpu page table and
  the device page table. Update to the device page table would use the hmm page
  table.

  While this secondary page table allow to track what is actively use and also
  gather statistics about it. It does require memory, in worst case as much as
  the cpu page table.

  Another issue is that synchronization between cpu update and device trying to
  access this secondary page table was either prone to lock contention. Or was
  getting awfully complex to avoid locking all while duplicating complexity
  inside each of the device driver.

  The killing bullet was however the fact that the code was littered with bug
  condition about discrepancy between the cpu and the hmm page table.

D3) Use a structure to track all actively mirrored range per process and per
  device. This allow to have an exact view of which range of memory is in use
  by which device.

  Again this need a lot of memory to track each of the active range and worst
  case would need more memory than a secondary page table (one struct range per
  page).

  Issue here was with the complexity or merging and splitting range on address
  space changes.

D4) Use a structure to track all active mirrored range per process (shared by
  all the devices that mirror the same process). This partially address the
  memory requirement of D3 but this leave the complexity of range merging and
  splitting intact.

The current design is a simplification of D4 in which we only track range of
memory for memory that have been migrated to device memory. So for any others
operations hmm directly access the cpu page table and forward the appropriate
information to the device driver through the hmm api. We might need to go back
to D4 design or a variation of it for some of the features we want add.


C.2 - Hardware solution :

What hmm try to achieve can be partially achieved using hardware solution. Such
hardware solution is part of PCIE specification with the PASID (process address
space id) and ATS (address translation service). With both of this PCIE feature
a device can ask for a virtual address of a given process to be translated into
its corresponding physical address. To achieve this the IOMMU bridge is capable
of understanding and walking the cpu page table of a process. See the IOMMUv2
implementation inside the linux kernel for reference.

There is two huge restriction with hardware solution to this problem. First an
obvious one is that you need hardware support. While HMM also require hardware
support on the GPU side it does not on the architecture side (no requirement on
IOMMU, or any bridges that are between the GPU and the system memory). This is
a strong advantages to HMM it only require hardware support to one specific
part.

The second restriction is that hardware solution like IOMMUv2 does not permit
migrating chunk of memory to the device local memory which means under-using
hardware resources (all discrete GPU comes with fast local memory that can
have more than ten times the bandwidth of system memory).

This two reasons alone, are we believe enough to justify hmm usefulness.

Moreover hmm can work in a hybrid solution where non migrated chunk of memory
goes through the hardware solution (IOMMUv2 for instance) and only the memory
that is migrated to the device is handled by the hmm code. The requirement for
the hardware is minimal, the hardware need to support the PASID & ATS (or any
other hardware implementation of the same idea) on page granularity basis (it
could be on the granularity of any level of the device page table so no need
to populate all levels of the device page table). Which is the best solution
for the problem.


C.3 - Routines marked EXPORT_SYMBOL

As these routines are intended to be referenced in device drivers, they
are marked EXPORT_SYMBOL as is common practice. This encourages adoption
of HMM in both GPL and non-GPL drivers, and allows ongoing collaboration
with one of the primary authors of this idea.

I think it would be beneficial to include this feature as soon as possible.
Early collaborators can go to the trouble of fixing and polishing the HMM
implementation, allowing it to fully bake by the time other drivers start
implementing features requiring it. We are confident that this API will be
useful to others as they catch up with supporting hardware.


C.4 - Planned features :

We are planning to add various features down the road once we can clear the
basic design. Most important ones are :
  - Allowing inter-device migration for compatible devices.
  - Allowing hmm_rmem without backing storage (simplify some of the driver).
  - Device specific memcg.
  - Improvement to allow APU to take advantages of rmem, by hiding the page
    from the cpu the gpu can use a different memory controller link that do
    not require cache coherency with the cpu and thus provide higher bandwidth.
  - Atomic device memory operation by unmapping on the cpu while the device is
    performing atomic operation (this require hardware mmu to differentiate
    between regular memory access and atomic memory access and to have a flag
    that allow atomic memory access on per page basis).
  - Pining private memory to rmem this would be a useful feature to add and
    would require addition of a new flag to madvise. Any cpu access would
    result in SIGBUS for the cpu process.


C.5 - Getting upstream :

So what should i do to get this patchset in a mergeable form at least at first
as a staging feature ? Right now the patchset has few rough edges around huge
page support and other smaller issues. But as said above i believe that patch
1, 2, 3 and 4 can be merge as is as they do not modify current behavior while
being useful to other.

Should i implement some secondary hmm specific lru and their associated worker
thread to avoid having the regular reclaim code to end up sleeping waiting for
a device to update its page table ?

Should i go for a totaly different design ? If so what direction ? As stated
above we explored other design and i listed there flaws.

Any others things that i need to fix/address/change/improve ?

Comments and flames are welcome.

Cheers,
JA(C)rA'me Glisse

To: <linux-kernel@vger.kernel.org>,
To: linux-mm <linux-mm@kvack.org>,
To: <linux-fsdevel@vger.kernel.org>,
Cc: "Mel Gorman" <mgorman@suse.de>,
Cc: "H. Peter Anvin" <hpa@zytor.com>,
Cc: "Peter Zijlstra" <peterz@infradead.org>,
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
Cc: "Linda Wang" <lwang@redhat.com>,
Cc: "Kevin E Martin" <kem@redhat.com>,
Cc: "Jerome Glisse" <jglisse@redhat.com>,
Cc: "Andrea Arcangeli" <aarcange@redhat.com>,
Cc: "Johannes Weiner" <jweiner@redhat.com>,
Cc: "Larry Woodman" <lwoodman@redhat.com>,
Cc: "Rik van Riel" <riel@redhat.com>,
Cc: "Dave Airlie" <airlied@redhat.com>,
Cc: "Jeff Law" <law@redhat.com>,
Cc: "Brendan Conoboy" <blc@redhat.com>,
Cc: "Joe Donohue" <jdonohue@redhat.com>,
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
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
