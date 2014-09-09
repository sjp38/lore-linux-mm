Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 945766B0072
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 11:44:16 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id pn19so19842495lab.18
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:44:16 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id vs12si18400906lac.36.2014.09.09.08.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 08:44:14 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 0/3 v3] mmu_notifier: Allow to manage CPU external TLBs
Date: Tue,  9 Sep 2014 17:43:51 +0200
Message-Id: <1410277434-3087-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, joro@8bytes.org, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

Changes V2->V3:

* Rebased to v3.17-rc4
* Fixed compile error because pmdp_get_and_clear_notify was
  missing

Changes V1->V2:

* Rebase to v3.16-rc7
* Added call of ->invalidate_range to
  __mmu_notifier_invalidate_end() so that the subsystem
  doesn't need to register an ->invalidate_end() call-back,
  subsystems will likely either register
  invalidate_range_start/end or invalidate_range, so that
  should be fine.
* Re-orded declarations a bit to reflect that
  invalidate_range is not only called between
  invalidate_range_start/end
* Updated documentation to cover the case where
  invalidate_range is called outside of
  invalidate_range_start/end to flush page-table pages out
  of the TLB

Hi,

here is a patch-set to extend the mmu_notifiers in the Linux
kernel to allow managing CPU external TLBs. Those TLBs may
be implemented in IOMMUs or any other external device, e.g.
ATS/PRI capable PCI devices.

The problem with managing these TLBs are the semantics of
the invalidate_range_start/end call-backs currently
available. Currently the subsystem using mmu_notifiers has
to guarantee that no new TLB entries are established between
invalidate_range_start/end. Furthermore the
invalidate_range_start() function is called when all pages
are still mapped and invalidate_range_end() when the pages
are unmapped an already freed.

So both call-backs can't be used to safely flush any non-CPU
TLB because _start() is called too early and _end() too
late.

In the AMD IOMMUv2 driver this is currently implemented by
assigning an empty page-table to the external device between
_start() and _end(). But as tests have shown this doesn't
work as external devices don't re-fault infinitly but enter
a failure state after some time.

Next problem with this solution is that it causes an
interrupt storm for IO page faults to be handled when an
empty page-table is assigned.

Furthermore the _start()/end() notifiers only catch the
moment when page mappings are released, but not page-table
pages. But this is necessary for managing external TLBs when
the page-table is shared with the CPU.

To solve this situation I wrote a patch-set to introduce a
new notifier call-back: mmu_notifer_invalidate_range(). This
notifier lifts the strict requirements that no new
references are taken in the range between _start() and
_end(). When the subsystem can't guarantee that any new
references are taken is has to provide the
invalidate_range() call-back to clear any new references in
there.

It is called between invalidate_range_start() and _end()
every time the VMM has to wipe out any references to a
couple of pages. This are usually the places where the CPU
TLBs are flushed too and where its important that this
happens before invalidate_range_end() is called.

Any comments and review appreciated!

Thanks,

	Joerg

Joerg Roedel (3):
  mmu_notifier: Add mmu_notifier_invalidate_range()
  mmu_notifier: Call mmu_notifier_invalidate_range() from VMM
  mmu_notifier: Add the call-back for mmu_notifier_invalidate_range()

 include/linux/mmu_notifier.h | 88 +++++++++++++++++++++++++++++++++++++++++---
 kernel/events/uprobes.c      |  2 +-
 mm/fremap.c                  |  2 +-
 mm/huge_memory.c             |  9 +++--
 mm/hugetlb.c                 |  7 +++-
 mm/ksm.c                     |  4 +-
 mm/memory.c                  |  3 +-
 mm/migrate.c                 |  3 +-
 mm/mmu_notifier.c            | 25 +++++++++++++
 mm/rmap.c                    |  2 +-
 10 files changed, 128 insertions(+), 17 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
