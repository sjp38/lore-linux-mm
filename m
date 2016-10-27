Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6FCD6B0282
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:51:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i128so6955759wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:51:48 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id h62si2182478wmg.22.2016.10.27.02.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 02:51:47 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id m83so1810321wmc.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:51:47 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH 0/2] mm: unexport __get_user_pages_unlocked()
Date: Thu, 27 Oct 2016 10:51:39 +0100
Message-Id: <20161027095141.2569-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-rdma@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org

This patch series continues the cleanup of get_user_pages*() functions taking
advantage of the fact we can now pass gup_flags as we please.

It firstly adds an additional 'locked' parameter to get_user_pages_remote() to
allow for its callers to utilise VM_FAULT_RETRY functionality. This is necessary
as the invocation of __get_user_pages_unlocked() in process_vm_rw_single_vec()
makes use of this and no other existing higher level function would allow it to
do so.

Secondly existing callers of __get_user_pages_unlocked() are replaced with the
appropriate higher-level replacement - get_user_pages_unlocked() if the current
task and memory descriptor are referenced, or get_user_pages_remote() if other
task/memory descriptors are referenced (having acquiring mmap_sem.)

Lorenzo Stoakes (2):
  mm: add locked parameter to get_user_pages_remote()
  mm: unexport __get_user_pages_unlocked()

 drivers/gpu/drm/etnaviv/etnaviv_gem.c   |  2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/infiniband/core/umem_odp.c      |  2 +-
 fs/exec.c                               |  2 +-
 include/linux/mm.h                      |  5 +----
 kernel/events/uprobes.c                 |  4 ++--
 mm/gup.c                                | 20 ++++++++++++--------
 mm/memory.c                             |  2 +-
 mm/nommu.c                              |  7 +++----
 mm/process_vm_access.c                  | 12 ++++++++----
 security/tomoyo/domain.c                |  2 +-
 virt/kvm/async_pf.c                     | 10 +++++++---
 virt/kvm/kvm_main.c                     |  5 ++---
 13 files changed, 41 insertions(+), 34 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
