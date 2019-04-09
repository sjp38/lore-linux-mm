Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9647FC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:21:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 292AD208C0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:21:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 292AD208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BD216B000D; Tue,  9 Apr 2019 10:21:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76C546B0269; Tue,  9 Apr 2019 10:21:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65E226B026A; Tue,  9 Apr 2019 10:21:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 439336B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 10:21:58 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q12so16020348qtr.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 07:21:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jETpLMT8PCZ1W45Cc9kmHovSdI/plV0Hlc35ED1sZrY=;
        b=qRMvUCtbAIS7pl1SA86TDGMcPujCbZcVinl4xppDv8F9naCw6OeTBFdxS5sC0QYJVD
         pcDhzH6DsdIF+InyzVvIyIfgMKd2trjlD0kbXyggqKB06VZxzisUr/pdLxz2ZKPz9T3z
         Y/Mzv7lhIoaMAlw9HiN6VXfMytEI/4M7xThHoEVAIj5dtwz+GZlqtQLk/L0NRlokxotB
         OUqIElvbvA5NV5Z2AOqXVaaW6C6/iK04VrZlaQr2GZHqvJ3V4dfsG+yad7BA96I426+s
         TSQ7Zjuth+IxsxwwsioSpr/HiKcqDxBMwlZixyluxd7MwWOBsU4Ava7wuTYKDL9ogWjt
         pFwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWDCpV3qbexwT3v9FqM4XzObu4BsL9maxU0lbXGyxOh9UecfdfP
	ch415OY/crhE+2HnAqo2mEJO3QPxxv/ANz9agUTMOy/z2EnQcaLYsr6mobrxTaxuW0Wme7jpXHF
	mkke512Pgf3ADvoa7hGyiq135XFmnrdLg5ejB3lTi/qXi1488F/P410fkCSvL3BzI3w==
X-Received: by 2002:aed:3fb8:: with SMTP id s53mr29508012qth.61.1554819718000;
        Tue, 09 Apr 2019 07:21:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTyhpb1IkUUe/yy9l7j85FEhKdVfxeXr5qVOxL37VyRnY9wzoQ35itjMHi84r7oh+Rklu+
X-Received: by 2002:aed:3fb8:: with SMTP id s53mr29507907qth.61.1554819716828;
        Tue, 09 Apr 2019 07:21:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554819716; cv=none;
        d=google.com; s=arc-20160816;
        b=mjb841CMt0nvy+KttiDF2eOczcIYczBNpvIwLrRO6q5goV5ltlnVfQgQdus9GBFeTt
         bev8/zJuuJwjOwoPllOlQgS8I+6LanAjXQMglH5xRWzAWo/5vBaeOzcT/slp5Swp8qdl
         9g1NVnBQcQO+3fun6XgcQifKvLWvr73GSiGyGiHGRf2WDVIb/U80tq+R4c+ThjGHW3RF
         BW+4A6eQTCmUgWsgIhMiG30ClB+2Lc+yeFtKm8L1GAqpFIKXjOupv4wOYcAi1eT92OY9
         7t7z0N/Ob0RzAteX8Hp2k1ooM/sh5Da6sP08Gtfxhsuh20kh+yJGeQDNsPRG+t9Ai3RE
         TF7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jETpLMT8PCZ1W45Cc9kmHovSdI/plV0Hlc35ED1sZrY=;
        b=h4oYdjLvtkGJN9KJ0yHNNdW5mz3gF+W+lHO0x8ml/xyMEdr75mBsFyH+upt0zkpwCl
         yl9clwfUphGwXGJe+1lYiu5vsYbOURMzm+6j/33INnzjbh+ekak7sMPMaRt0zxTxl/vT
         B4u9+AT9MgOwohYZHMmkcRYBaR53PlC3oJXYLsj13fOt/uqr1mQ66+7m1ZVAaQBuFsHO
         ii8njKin5EuOVbB+O8qicHra1fOO7TciLojO862sO37/43JJ0GNVDFdkt9GrBGpzN3XT
         qSL1LoDEoD3B4CRV3d+IgQUhB9IJs533iLIzvACG9H/rzaBl5MrECWvFEM6Kwbe83ORo
         1q2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c48si665192qvd.163.2019.04.09.07.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 07:21:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7AF093167695;
	Tue,  9 Apr 2019 14:21:50 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 828C764446;
	Tue,  9 Apr 2019 14:21:28 +0000 (UTC)
Date: Tue, 9 Apr 2019 10:21:26 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v6 0/8] mmu notifier provide context informations
Message-ID: <20190409142126.GC4190@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 09 Apr 2019 14:21:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew anything blocking this for 5.2 ? Should i ask people (ie the end
user of this) to re-ack v6 (it is the same as previous version just rebase
and dropped kvm bits).



On Tue, Mar 26, 2019 at 12:47:39PM -0400, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> (Andrew this apply on top of my HMM patchset as otherwise you will have
>  conflict with changes to mm/hmm.c)
> 
> Changes since v5:
>     - drop KVM bits waiting for KVM people to express interest if they
>       do not then i will post patchset to remove change_pte_notify as
>       without the changes in v5 change_pte_notify is just useless (it
>       it is useless today upstream it is just wasting cpu cycles)
>     - rebase on top of lastest Linus tree
> 
> Previous cover letter with minor update:
> 
> 
> Here i am not posting users of this, they already have been posted to
> appropriate mailing list [6] and will be merge through the appropriate
> tree once this patchset is upstream.
> 
> Note that this serie does not change any behavior for any existing
> code. It just pass down more information to mmu notifier listener.
> 
> The rational for this patchset:
> 
> CPU page table update can happens for many reasons, not only as a
> result of a syscall (munmap(), mprotect(), mremap(), madvise(), ...)
> but also as a result of kernel activities (memory compression, reclaim,
> migration, ...).
> 
> This patch introduce a set of enums that can be associated with each
> of the events triggering a mmu notifier:
> 
>     - UNMAP: munmap() or mremap()
>     - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
>     - PROTECTION_VMA: change in access protections for the range
>     - PROTECTION_PAGE: change in access protections for page in the range
>     - SOFT_DIRTY: soft dirtyness tracking
> 
> Being able to identify munmap() and mremap() from other reasons why the
> page table is cleared is important to allow user of mmu notifier to
> update their own internal tracking structure accordingly (on munmap or
> mremap it is not longer needed to track range of virtual address as it
> becomes invalid). Without this serie, driver are force to assume that
> every notification is an munmap which triggers useless trashing within
> drivers that associate structure with range of virtual address. Each
> driver is force to free up its tracking structure and then restore it
> on next device page fault. With this serie we can also optimize device
> page table update [6].
> 
> More over this can also be use to optimize out some page table updates
> like for KVM where we can update the secondary MMU directly from the
> callback instead of clearing it.
> 
> ACKS AMD/RADEON https://lkml.org/lkml/2019/2/1/395
> ACKS RDMA https://lkml.org/lkml/2018/12/6/1473
> 
> Cheers,
> Jérôme
> 
> [1] v1 https://lkml.org/lkml/2018/3/23/1049
> [2] v2 https://lkml.org/lkml/2018/12/5/10
> [3] v3 https://lkml.org/lkml/2018/12/13/620
> [4] v4 https://lkml.org/lkml/2019/1/23/838
> [5] v5 https://lkml.org/lkml/2019/2/19/752
> [6] patches to use this:
>     https://lkml.org/lkml/2019/1/23/833
>     https://lkml.org/lkml/2019/1/23/834
>     https://lkml.org/lkml/2019/1/23/832
>     https://lkml.org/lkml/2019/1/23/831
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: Christian König <christian.koenig@amd.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: Radim Krčmář <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> 
> Jérôme Glisse (8):
>   mm/mmu_notifier: helper to test if a range invalidation is blockable
>   mm/mmu_notifier: convert user range->blockable to helper function
>   mm/mmu_notifier: convert mmu_notifier_range->blockable to a flags
>   mm/mmu_notifier: contextual information for event enums
>   mm/mmu_notifier: contextual information for event triggering
>     invalidation v2
>   mm/mmu_notifier: use correct mmu_notifier events for each invalidation
>   mm/mmu_notifier: pass down vma and reasons why mmu notifier is
>     happening v2
>   mm/mmu_notifier: mmu_notifier_range_update_to_read_only() helper
> 
>  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |  8 ++--
>  drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
>  drivers/gpu/drm/radeon/radeon_mn.c      |  4 +-
>  drivers/infiniband/core/umem_odp.c      |  5 +-
>  drivers/xen/gntdev.c                    |  6 +--
>  fs/proc/task_mmu.c                      |  3 +-
>  include/linux/mmu_notifier.h            | 63 +++++++++++++++++++++++--
>  kernel/events/uprobes.c                 |  3 +-
>  mm/hmm.c                                |  6 +--
>  mm/huge_memory.c                        | 14 +++---
>  mm/hugetlb.c                            | 12 +++--
>  mm/khugepaged.c                         |  3 +-
>  mm/ksm.c                                |  6 ++-
>  mm/madvise.c                            |  3 +-
>  mm/memory.c                             | 25 ++++++----
>  mm/migrate.c                            |  5 +-
>  mm/mmu_notifier.c                       | 12 ++++-
>  mm/mprotect.c                           |  4 +-
>  mm/mremap.c                             |  3 +-
>  mm/oom_kill.c                           |  3 +-
>  mm/rmap.c                               |  6 ++-
>  virt/kvm/kvm_main.c                     |  3 +-
>  22 files changed, 147 insertions(+), 52 deletions(-)
> 
> -- 
> 2.20.1
> 

