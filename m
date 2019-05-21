Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD01C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1291721783
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1291721783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D35B6B0006; Tue, 21 May 2019 00:53:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95C4E6B0007; Tue, 21 May 2019 00:53:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 824B56B0008; Tue, 21 May 2019 00:53:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 28EE86B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p14so28824139edc.4
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=7V1PnxYMdan+rXYXCxI+Y2lBSy5FqT6Og3jDMzniECk=;
        b=jg1XhVGYIHeBNrvOv2uhOOUrrR+Ef7gVSoABVXHKI5jjgUed62aIQ9Xb+jNvYQKbXD
         ywqqXsdeR8K+R9W1QIIHAw992QlpOfGYsFDwiLdqHyLYTueg7pyTcr2jDLm/R+Mz6nrV
         F2jMyHlNireDbN8BqESD5YUS+xsOUuwEFoIyU1M1cridMxYR097XfdJCP2v52qKr53wB
         0edgJpU5oEIaNQ5TFTSbyIKgyPSlNz0Q5ZYQDRSIWVA02zqnZxN+Nm59BMWG4wcf9YmZ
         fur30uRQGp4LVSFY5B1+hfwxFH1T8UErWCQMHCPyIgYVrjCDsMjQOSCqzJXmwOywC55h
         xtcw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAW+2xnba/0tzp34J5Q8Ibzgi2Trog5lcQP20oDjMUsF0dl1Y03j
	7AxWDd0FFttaGuIQ+uYjCzq4IZBKKoc2fJmYaGAw5v4H9h/E3Z5/yHZXZcE8QXEyKfhwcoos4Cn
	0KUb2jsZmRfW7uRZ+EWzHDZT7U9IllpVN++jMetsCVSOmFjETP3apuGEjNX1w7xY=
X-Received: by 2002:a50:f4fb:: with SMTP id v56mr81616760edm.13.1558414384607;
        Mon, 20 May 2019 21:53:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUmWL3DBWQaNCE46bke6NPJm/qjz+6/X+5eI1nPld3Bzscir0K9nDXS4LA/TadY+jZFtjd
X-Received: by 2002:a50:f4fb:: with SMTP id v56mr81616666edm.13.1558414383063;
        Mon, 20 May 2019 21:53:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414383; cv=none;
        d=google.com; s=arc-20160816;
        b=R2gs1pVPY+xP7zTCnD6hOfZxuyuETGmYx/Eh2xcpX33loOuqJYh9RHhyIMLVMhxQS+
         GeYjLIFJ2pnsiFbDgAyFQG0CpeN+nIchdIbgCvQXHx1zXz3SAv5ZZ9X3FFoEP02W4lIC
         em2jHswH5FlO1bNWz0MbwX3SUrHCdyv8rafj+q89hQtI2UiNF6NAtzH5N1kMoDZmQzPI
         vax5/u7477FvQq/Dg0xbEhWxWGONG/81f8zqBCyrScDLz2Hs3RuOzTfMCle/yCQFrYNg
         KF49YRL+Z4ZZZW5mLLOgRX4DzcTUpy8jZ+6j3qJgEox+C6lfO79jBoF7VIQi8l79u0qr
         MsZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=7V1PnxYMdan+rXYXCxI+Y2lBSy5FqT6Og3jDMzniECk=;
        b=qzsIzPZP9B99vXDdL0gAOdQ8muDkyXkQ4E1+IRdoz35YYNSEvuOtqVIC9fARdzZhI6
         W6ULN3SEdLpf9KFBIVTPup4m2ocLDNzmVChN9buHCBNsrwln/4MK18o/aWsFPfe2Ci6W
         jR81DXiv9DXtVEaolg7k+1RnMS1tHDGkfvGE/szg71DUnziHf1xq0JN74gSGjLvgyCLU
         fdUiUKkhh4s9zX0uHY4idwzg4NPJ/4EFKHx3Pu6yF24IdmvEv+DPAAEtuoj+JeWIT+2p
         yxo69DcZh3jBW3CZSDVTIcX0LARNXHTZYdcUUE/qOJOmIotOJoofC6I/1KT9TuVFf8jw
         OA7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id b3si6694831edb.376.2019.05.20.21.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:01 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:52:55 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net
Subject: [RFC PATCH 00/14] mmap_sem range locking
Date: Mon, 20 May 2019 21:52:28 -0700
Message-Id: <20190521045242.24378-1-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

The following is a summarized repost of the range locking mmap_sem idea[1]
and is _not_ intended for being considered upstream as there are quite a few
issues that arise with this approach of tackling mmap_sem contention (keep reading).

In fact this patch is quite incomplete and will break compiling on anything
non-x86, and is also _completely broken_ for ksm and hmm.  That being said, this
does build an enterprise kernel and survives a number of workloads as well as
'runltp -f syscalls'. The previous series is a complete range locking conversion,
which ensured we had all the range locking apis we needed. The changelog also
included a number of performance numbers and overall design.

While finding issues with the code itself is always welcome, the idea of this series
is to discuss what can be done on top of it, if anything.

From a locking pov, most recently there has been a revival in the interest of the
range lock code for dchinner's plans of range locking the i_rwsem. However, it
showed that xfs's extent tree significantly outperformed[2] the (full) range lock.
The performance differences when doing 1:1 rwsem comparisons, have already been shown
in [1].

Considering both the range lock and the extent tree lock the whole tree, most of this
performance penalties are due to the fact that rbtrees' depth is a lot larger than
btree's, so the latter avoids most of the pointer chasing which is a common performance
issue. This was a trade-off for not having to allocate memory for the range nodes.

However, on the _positive side_, and which is what we care most about for mmap_sem,
when actually using the lock as intended, the range locking did show its purpose:

			IOPS read/write (buffered IO)
fio processes		rwsem			rangelock
 1			57k / 57k		64k / 64k
 2			61k / 61k		111k / 111k
 4			61k / 61k		228k / 228k
 8			55k / 55k		195k / 195k
 16			15k / 15k		 40k /  40k

So it would be nice to apply this concept to our address space and allow mmaps, munmaps
and pagefaults to all work concurrently in non-overlapping scenarios -- which is what
is provided by userspace mm related syscalls. However, when using the range lock without
a full range, a number of issues around the vma immediately popup as a consequence of
this *top-down* approach to solving scalability:

Races within a vma: non-overlapping regions can still belong to the same vma, hence
wrecking merges and splits. One popular idea is to have a vma->rwsem (taken, for example,
after a find_vma()), however, this throws out the window any potential scalability gains
for large vmas as we just end up just moving down the point of contention. The same
problem occurs when refcouting the vma (such as with speculative pfs). There's also
the fact that we can end up taking numerous vma locks as the vma list is later traversed
once the first vma is found.

Alternatively, we could just expand the passed range such that it covers the whole first
and last vma(s) endpoints; of course we don't have that information aprori (protected by
mmap_sem :), and enlarging the range _after_ acquiring the lock opens a can of worms
because now we have to inform userspace and/or deadlock, among others.

Similarly, there's the issue of keeping the vma tree correct during modifications as well
as regular find_vma()s. Laurent has already pointed out that we have too many ways of
getting a vma: the tree, the list and the vmacache, all currently protected by mmap_sem
and breaks because of the above when not using full ranges. This also touches a bit in
a more *bottom-up* approach to mmap_sem performance, which scales from within, instead
of putting a big rangelock tree on top of the address space.

Matthew has pointed out a the xarray as well as an rcu based maple tree[3] replacement
of the rbtree, however we already have the vmacache so most of the benefits of a shallower
data structure are unnecessary, in cache-hot situations, naturally. The vma-list is easily
removable once we have O(1) next/prev pointers, which for rbtrees can be done via threading
the data structure (at the cost of extra branch for every level down the tree when
inserting). Maple trees already give us this. So all in all, if we were going to go down
this path of a cache friendlier tree, we'd end up needing comparisons of the maple tree vs
the current vmacache+rbtree combo. Regarding rcu-ifying the vma tree and replacing read
locking (and therefore plays nicer with cachelines), I sounds nice, it does not seem
practical considering that the page tables cannot be rcu-ified.

I'm sure I'm missing a lot more, but I'm hoping to kickstart the conversation again.

Patches 1-2: adds the range locking machinery. This is rebased on the rbtree optimizations
for interval trees such that we can quickly detect overlapping ranges. Some bug fixes and
more documentation as also been added, with an ordering example in the source code.

Patch 3: adds new mm locking wrappers around mmap_sem.

Patches 4: teaches page fault paths about mmrange (specifically adding the range in question
to the struct vm_fault). In addition, most of these patches update mmap_sem callers.

Patch 5: is mostly a collection of shameless hacks to avoid for now teaching callers about
range locking and just enlarging the series needlessly.

Patches 6-13: adds most of the trivial conversions; most of this is generated with a cocinelle
script[4], it's rather lame but gets most of the job done. Fix ups are pretty straightforward,
yet manual.

Patch 14: finally do the actual conversion and replace mmap_sem with the full range mmap_lock.

Applies on top of today's linux-next tree.


[1] https://lkml.org/lkml/2018/2/4/235
[2] https://lore.kernel.org/linux-fsdevel/20190416122240.GN29573@dread.disaster.area/
[3] https://lore.kernel.org/lkml/20190314195452.GN19508@bombadil.infradead.org/
[4] http://linux-scalability.org/range-mmap_lock/mmap_sem.cocci

Thanks!

Davidlohr Bueso (14):
  interval-tree: build unconditionally
  Introduce range reader/writer lock
  mm: introduce mm locking wrappers
  mm: teach pagefault paths about range locking
  mm: remove some BUG checks wrt mmap_sem
  mm: teach the mm about range locking
  fs: teach the mm about range locking
  arch/x86: teach the mm about range locking
  virt: teach the mm about range locking
  net: teach the mm about range locking
  ipc: teach the mm about range locking
  kernel: teach the mm about range locking
  drivers: teach the mm about range locking
  mm: convert mmap_sem to range mmap_lock

 arch/x86/entry/vdso/vma.c                        |  12 +-
 arch/x86/events/core.c                           |   2 +-
 arch/x86/kernel/tboot.c                          |   2 +-
 arch/x86/kernel/vm86_32.c                        |   5 +-
 arch/x86/kvm/paging_tmpl.h                       |   9 +-
 arch/x86/mm/debug_pagetables.c                   |   8 +-
 arch/x86/mm/fault.c                              |  37 +-
 arch/x86/mm/mpx.c                                |  15 +-
 arch/x86/um/vdso/vma.c                           |   5 +-
 drivers/android/binder_alloc.c                   |   7 +-
 drivers/firmware/efi/efi.c                       |   2 +-
 drivers/gpu/drm/Kconfig                          |   2 -
 drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |   4 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |   7 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          |  11 +-
 drivers/gpu/drm/amd/amdkfd/kfd_events.c          |   5 +-
 drivers/gpu/drm/i915/Kconfig                     |   1 -
 drivers/gpu/drm/i915/i915_gem.c                  |   5 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c          |  13 +-
 drivers/gpu/drm/nouveau/nouveau_svm.c            |  23 +-
 drivers/gpu/drm/radeon/radeon_cs.c               |   5 +-
 drivers/gpu/drm/radeon/radeon_gem.c              |   8 +-
 drivers/gpu/drm/radeon/radeon_mn.c               |   7 +-
 drivers/gpu/drm/ttm/ttm_bo_vm.c                  |   4 +-
 drivers/infiniband/core/umem.c                   |   7 +-
 drivers/infiniband/core/umem_odp.c               |  14 +-
 drivers/infiniband/core/uverbs_main.c            |   5 +-
 drivers/infiniband/hw/mlx4/mr.c                  |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c       |   7 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c         |   5 +-
 drivers/iommu/Kconfig                            |   1 -
 drivers/iommu/amd_iommu_v2.c                     |   7 +-
 drivers/iommu/intel-svm.c                        |   7 +-
 drivers/media/v4l2-core/videobuf-core.c          |   5 +-
 drivers/media/v4l2-core/videobuf-dma-contig.c    |   5 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c        |   5 +-
 drivers/misc/cxl/cxllib.c                        |   5 +-
 drivers/misc/cxl/fault.c                         |   5 +-
 drivers/misc/sgi-gru/grufault.c                  |  20 +-
 drivers/misc/sgi-gru/grufile.c                   |   5 +-
 drivers/misc/sgi-gru/grukservices.c              |   4 +-
 drivers/misc/sgi-gru/grumain.c                   |   6 +-
 drivers/misc/sgi-gru/grutables.h                 |   5 +-
 drivers/oprofile/buffer_sync.c                   |  12 +-
 drivers/staging/kpc2000/kpc_dma/fileops.c        |   5 +-
 drivers/tee/optee/call.c                         |   5 +-
 drivers/vfio/vfio_iommu_type1.c                  |  11 +-
 drivers/xen/gntdev.c                             |   5 +-
 drivers/xen/privcmd.c                            |  17 +-
 fs/aio.c                                         |   5 +-
 fs/coredump.c                                    |   5 +-
 fs/exec.c                                        |  21 +-
 fs/io_uring.c                                    |   5 +-
 fs/proc/base.c                                   |  23 +-
 fs/proc/internal.h                               |   2 +
 fs/proc/task_mmu.c                               |  32 +-
 fs/proc/task_nommu.c                             |  22 +-
 fs/userfaultfd.c                                 |  50 +-
 include/linux/hmm.h                              |   7 +-
 include/linux/huge_mm.h                          |   2 -
 include/linux/hugetlb.h                          |   9 +-
 include/linux/lockdep.h                          |  33 ++
 include/linux/mm.h                               | 108 +++-
 include/linux/mm_types.h                         |   4 +-
 include/linux/pagemap.h                          |   6 +-
 include/linux/range_lock.h                       | 189 +++++++
 include/linux/userfaultfd_k.h                    |   5 +-
 ipc/shm.c                                        |  10 +-
 kernel/acct.c                                    |   5 +-
 kernel/bpf/stackmap.c                            |  16 +-
 kernel/events/core.c                             |   5 +-
 kernel/events/uprobes.c                          |  27 +-
 kernel/exit.c                                    |   9 +-
 kernel/fork.c                                    |  18 +-
 kernel/futex.c                                   |   7 +-
 kernel/locking/Makefile                          |   2 +-
 kernel/locking/range_lock.c                      | 667 +++++++++++++++++++++++
 kernel/sched/fair.c                              |   5 +-
 kernel/sys.c                                     |  22 +-
 kernel/trace/trace_output.c                      |   5 +-
 lib/Kconfig                                      |  14 -
 lib/Kconfig.debug                                |   1 -
 lib/Makefile                                     |   3 +-
 mm/filemap.c                                     |  10 +-
 mm/frame_vector.c                                |  10 +-
 mm/gup.c                                         |  86 +--
 mm/hmm.c                                         |   7 +-
 mm/hugetlb.c                                     |  14 +-
 mm/init-mm.c                                     |   2 +-
 mm/internal.h                                    |   3 +-
 mm/khugepaged.c                                  |  78 +--
 mm/ksm.c                                         |  45 +-
 mm/madvise.c                                     |  36 +-
 mm/memcontrol.c                                  |  10 +-
 mm/memory.c                                      |  28 +-
 mm/mempolicy.c                                   |  34 +-
 mm/migrate.c                                     |  10 +-
 mm/mincore.c                                     |   6 +-
 mm/mlock.c                                       |  20 +-
 mm/mmap.c                                        |  73 +--
 mm/mmu_notifier.c                                |   9 +-
 mm/mprotect.c                                    |  17 +-
 mm/mremap.c                                      |   9 +-
 mm/msync.c                                       |   9 +-
 mm/nommu.c                                       |  25 +-
 mm/oom_kill.c                                    |   5 +-
 mm/pagewalk.c                                    |   3 -
 mm/process_vm_access.c                           |   8 +-
 mm/shmem.c                                       |   2 +-
 mm/swapfile.c                                    |   5 +-
 mm/userfaultfd.c                                 |  21 +-
 mm/util.c                                        |  10 +-
 net/ipv4/tcp.c                                   |   5 +-
 net/xdp/xdp_umem.c                               |   5 +-
 security/tomoyo/domain.c                         |   2 +-
 virt/kvm/arm/mmu.c                               |  17 +-
 virt/kvm/async_pf.c                              |   7 +-
 virt/kvm/kvm_main.c                              |  18 +-
 118 files changed, 1776 insertions(+), 594 deletions(-)
 create mode 100644 include/linux/range_lock.h
 create mode 100644 kernel/locking/range_lock.c

-- 
2.16.4

