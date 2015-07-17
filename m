Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF95A28034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:54:12 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so43508683igb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:54:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p16si10512533ico.48.2015.07.17.11.54.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:54:12 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 14/15] HMM: add documentation explaining HMM internals and how to use it.
Date: Fri, 17 Jul 2015 14:52:24 -0400
Message-Id: <1437159145-6548-15-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This add documentation with a high level overview of how HMM works
and a more in depth view of how it should be use by device driver
writers.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 Documentation/vm/hmm.txt | 219 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 219 insertions(+)
 create mode 100644 Documentation/vm/hmm.txt

diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
new file mode 100644
index 0000000..febed50
--- /dev/null
+++ b/Documentation/vm/hmm.txt
@@ -0,0 +1,219 @@
+Heterogeneous Memory Management (HMM)
+-------------------------------------
+
+The raison d'etre of HMM is to provide a common API for device driver that
+wants to mirror a process address space on there device and/or migrate system
+memory to device memory. Device driver can decide to only use one aspect of
+HMM (mirroring or memory migration), for instance some device can directly
+access process address space through hardware (for instance PCIe ATS/PASID),
+but still want to benefit from memory migration capabilities that HMM offer.
+
+While HMM rely on existing kernel infrastructure (namely mmu_notifier) some
+of its features (memory migration, atomic access) require integration with
+core mm kernel code. Having HMM as the common intermediary is more appealing
+than having each device driver hooking itself inside the common mm code.
+
+Moreover HMM as a layer allows integration with DMA API or page reclaimation.
+
+
+Mirroring address space on the device:
+--------------------------------------
+
+Device that can't directly access transparently the process address space, need
+to mirror the CPU page table into there own page table. HMM helps to keep the
+device page table synchronize with the CPU page table. It is not expected that
+the device will fully mirror the CPU page table but only mirror region that are
+actively accessed by the device. For that reasons HMM only helps populating and
+synchronizing device page table for range that the device driver explicitly ask
+for.
+
+Mirroring address space inside the device page table is easy with HMM :
+
+  /* Create a mirror for the current process for your device. */
+  your_hmm_mirror->hmm_mirror.device = your_hmm_device;
+  hmm_mirror_register(&your_hmm_mirror->hmm_mirror);
+
+  ...
+
+  /* Mirror memory (in read mode) between addressA and addressB */
+  your_hmm_event->hmm_event.start = addressA;
+  your_hmm_event->hmm_event.end = addressB;
+  your_hmm_event->hmm_event.etype = HMM_DEVICE_RFAULT;
+  hmm_mirror_fault(&your_hmm_mirror->hmm_mirror, &your_hmm_event->hmm_event);
+    /* HMM callback into your driver with the >update() callback. During the
+     * callback use the HMM page table to populate the device page table. You
+     * can only use the HMM page table to populate the device page table for
+     * the specified range during the >update() callback, at any other point in
+     * time the HMM page table content should be assume to be undefined.
+     */
+    your_hmm_device->update(mirror, event);
+
+  ...
+
+  /* Process is quiting or device done stop the mirroring and cleanup. */
+  hmm_mirror_unregister(&your_hmm_mirror->hmm_mirror);
+  /* Device driver can free your_hmm_mirror */
+
+
+HMM mirror page table:
+----------------------
+
+Each hmm_mirror object is associated with a mirror page table that HMM keeps
+synchronize with the CPU page table by using the mmu_notifier API. HMM is using
+its own generic page table format because it needs to store DMA address, which
+are bigger than long on some architecture, and have more flags per entry than
+radix tree allows.
+
+The HMM page table mostly mirror x86 page table layout. A page holds a global
+directory and each entry points to a lower level directory. Unlike regular CPU
+page table, directory level are more aggressively freed and remove from the HMM
+mirror page table. This means device driver needs to use the HMM helpers and to
+follow directive on when and how to access the mirror page table. HMM use the
+per page spinlock of directory page to synchronize update of directory ie update
+can happen on different directory concurently.
+
+As a rules the mirror page table can only be accessed by device driver from one
+of the HMM device callback. Any access from outside a callback is illegal and
+gives undertimed result.
+
+Accessing the mirror page table from a device callback needs to use the HMM
+page table helpers. A loop to access entry for a range of address looks like :
+
+  /* Initialize a HMM page table iterator. */
+  struct hmm_pt_iter iter;
+  hmm_pt_iter_init(&iter, &mirror->pt)
+
+  /* Get pointer to HMM page table entry for a given address. */
+  dma_addr_t *hmm_pte;
+  hmm_pte = hmm_pt_iter_walk(&iter, &addr, &next);
+
+If there is no valid entry directory for given range address then hmm_pte is
+NULL. If there is a valid entry directory then you can access the hmm_pte and
+the pointer will stay valid as long as you do not call hmm_pt_iter_walk() with
+the same iter struct for a different address or call hmm_pt_iter_fini().
+
+While the HMM page table entry pointer stays valid you can only modify the
+value it is pointing to by using one of HMM helpers (hmm_pte_*()) as other
+threads might be updating the same entry concurrently. The device driver only
+need to update an HMM page table entry to set the dirty bit, so driver should
+only be using hmm_pte_set_dirty().
+
+Similarly to extract information the device driver should use one of the helper
+like hmm_pte_dma_addr() or hmm_pte_pfn() (if HMM is not doing DMA mapping which
+is a device driver at initialization parameter).
+
+
+Migrating system memory to device memory:
+-----------------------------------------
+
+Device like discret GPU often have there own local memory which offer bigger
+bandwidth and smaller latency than access to system memory for the GPU. This
+local memory is not necessarily accessible by the CPU. Device local memory will
+remain revealent for the foreseeable future as bandwidth of GPU memory keep
+increasing faster than bandwidth of system memory and as latency of PCIe does
+not decrease.
+
+Thus to maximize use of device like GPU, program need to use the device memory.
+Userspace API wants to make this as transparent as it can be, so that there is
+no need for complex modification of applications.
+
+Transparent use of device memory for range of address of a process require core
+mm code modifications. Adding a new memory zone for devices memory did not make
+sense given that such memory is often only accessible by the device only. This
+is why we decided to use a special kind of swap, migrated memory is mark as a
+special swap entry inside the CPU page table.
+
+While HMM handles the migration process, it does not decide what range or when
+to migrate memory. The decision to perform such migration is under the control
+of the device driver. Migration back to system memory happens either because
+the CPU try to access the memory or because device driver decided to migrate
+the memory back.
+
+
+  /* Migrate system memory between addressA and addressB to device memory. */
+  your_hmm_event->hmm_event.start = addressA;
+  your_hmm_event->hmm_event.end = addressB;
+  your_hmm_event->hmm_event.etype = HMM_COPY_TO_DEVICE;
+  hmm_mirror_fault(&your_hmm_mirror->hmm_mirror, &your_hmm_event->hmm_event);
+    /* HMM callback into your driver with the >copy_to_device() callback.
+     * Device driver must allocate device memory, DMA system memory to device
+     * memory, update the device page table to point to device memory and
+     * return. See hmm.h for details instructions and how failure are handled.
+     */
+    your_hmm_device->copy_to_device(mirror, event, dst, addressA, addressB);
+
+
+Right now HMM only support migrating anonymous private memory. Migration of
+share memory and more generaly file mapped memory is on the road map.
+
+
+Locking consideration and overall design:
+-----------------------------------------
+
+As a rule HMM will handle proper locking on the behalf of the device driver,
+as such device driver does not need to take any mm lock before calling into
+the HMM code.
+
+HMM is also responsible of the hmm_device and hmm_mirror object lifetime. The
+device driver can only free those after calling hmm_device_unregister() or
+hmm_mirror_unregister() respectively.
+
+All the lock inside any of the HMM structure should never be use by the device
+driver. They are intended to be use only and only by HMM code. Below is short
+description of the 3 main locks that exist for HMM internal use. Educational
+purpose only.
+
+Each process mm has one and only one struct hmm associated with it. Each hmm
+struct can be use by several different mirror. There is one and only one mirror
+per mm and device pair. So in essence the hmm struct is the core that dispatch
+everything to every single mirror, each of them corresponding to a specific
+device. The list of mirror for an hmm struct is protected by a semaphore as it
+sees mostly read access.
+
+Each time a device fault a range of address it calls hmm_mirror_fault(), HMM
+keeps track, inside the hmm struct, of each range currently being faulted. It
+does that so it can synchronize with any CPU page table update. If there is a
+CPU page table update then a callback through mmu_notifier will happen and HMM
+will try to interrupt the device page fault that conflict (ie address range
+overlap with the range being updated) and wait for them to back off. This
+insure that at no point in time the device driver see transient page table
+information. The list of active fault is protected by a spinlock, query on
+that list should be short and quick (we haven't gather enough statistic on
+that side yet to have a good idea of the average access pattern).
+
+Each device driver wanting to use HMM must register one and only one hmm_device
+struct per physical device with HMM. The hmm_device struct have pointer to the
+device driver call back and keeps track of active mirrors for a given device.
+The active mirrors list is protected by a spinlock.
+
+
+Future work:
+------------
+
+Improved atomic access by the device to system memory. Some platform bus (PCIe)
+offer limited number of atomic memory operations, some platform do not even
+have any kind of atomic memory operations by a device. In order to allow such
+atomic operation we want to map page read only the CPU while the device perform
+its operation. For this we need a new case inside the CPU write fault code path
+to synchronize with the device.
+
+We want to allow program to lock a range of memory inside device memory and
+forbid CPU access while the memory is lock inside the device. Any CPU access
+to locked range would result in SIGBUS. We think that madvise() would be the
+right syscall into which we could plug that feature.
+
+In order to minimize kernel memory consumption and overhead of DMA mapping, we
+want to introduce new DMA API that allows to manage mapping on IOMMU directory
+page basis. This would allow to map/unmap/update DMA mapping in bulk and
+minimize IOMMU update and flushing overhead. Moreover this would allow to
+improve IOMMU bad access reporting for DMA address inside those directory.
+
+Because update to the device page table might require "heavy" synchronization
+with the device, the mmu_notifier callback might have to sleep while HMM is
+waiting for the device driver to report device page table update completion.
+This is especialy bad if this happens during page reclaimation, this might
+bring the system to pause. We want to mitigate this, either by maintaining a
+new intermediate lru level in which we put pages actively mirrored by a device
+or by some other mecanism. For time being we advice that device driver that
+use HMM explicitly explain this corner case so that user are aware that this
+can happens if there is memory pressure.
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
