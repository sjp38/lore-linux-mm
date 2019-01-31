Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DE19C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:10:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 062802085B
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:10:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 062802085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E1E48E0005; Thu, 31 Jan 2019 11:10:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 991F48E0003; Thu, 31 Jan 2019 11:10:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8809B8E0005; Thu, 31 Jan 2019 11:10:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB8E8E0003
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:10:17 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 41so4067599qto.17
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:10:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SwY0+Y6CvG8ZDhsgFQ4o1R3WtSfZyWTlSXJTD24H1UQ=;
        b=RVPShMEhmEbGyQytjfq2DuT6mWa3HW1g8uq7jxaDYEfZRXew8gylILBIeuHaGPDHs1
         3YpHLYngehV9ugz1DvkONF1GsFVIAENsB6kIzJNAJfDsec3XJvVGRlpC9KEjzrN5OADt
         xk5RYe+oUVGyBLKohHpVuykt1ZD31rQdP/7LdS2mk4Hd0oF5nhtTXi/8lB3bGY7biXRV
         fE5+zED0jHyHv1ZD1ySjx8PLLufLyW/j8L+/8KmrIP03ki1c9SGBKa6ga5JKN1N9tUQL
         +FXlDq6W9D9H5qBCYPsQVYccMvOU7Hl1iUsWjKhiem4zQspPNFYKgCXor5LPwNIrW1vM
         uvNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfpEwtN02B4+GPppt3QnO2RUMT25hZnUOT4gYzIIqJrLuy81FIH
	r+gYvH+VThelAueZXzm8z0rmiHusDIdf7jxwK48CpkWJRhJrAWNawDJ0VvI84IP43W/J/5o6hk9
	FPy0sTgkM0dPHcP0SBah5s8eYBuj2oIQn/aqLqGyfKeEEqoiyzbdWs75TGJhR7L1irw==
X-Received: by 2002:a0c:9549:: with SMTP id m9mr33784625qvm.214.1548951017069;
        Thu, 31 Jan 2019 08:10:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN77ZYduioFIc2CZOZ2ty6N/M1g9XNAxKyXhP+ssrx+DfpTUHkJiBHt6RhG7rsxQNQerNWag
X-Received: by 2002:a0c:9549:: with SMTP id m9mr33784552qvm.214.1548951016192;
        Thu, 31 Jan 2019 08:10:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548951016; cv=none;
        d=google.com; s=arc-20160816;
        b=r2e+eLjpVX7U3fgVPpGbf0Mhy9e/E5TJIu0pCziIXeTqxHODSiuCKFTB/U9S0Z5T5p
         W/+/gpB32dV8D26/+b4ixkE16QQTlUNRrucBrYfk/bsNyUbhzzmMVw1I9FL3GkXvUrub
         xuIT4xnov0AHdTd78aXKvQqlmOd573S3kPNhkD+SiZ3szK+loyDz6i+17yZH7r9gKt4k
         ts49Osc7BE+m5OOV8XLXUTBjAUeFXd7n5uOAC/JaPlru+mcZt9xLGzAMamPD8eMd01F0
         AAdogr609cgDOWYsu4H4MMWjMIAvkQL5dYTkCKzyTnxPETvKiS4rnKh+6eAmY9fDogKf
         vUPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=SwY0+Y6CvG8ZDhsgFQ4o1R3WtSfZyWTlSXJTD24H1UQ=;
        b=vVEEMLhBnHncoxuYGs/DQEm1I2Re9AY8o8cfMAx5asyFZYfop9aCQwuGANW96LeQzt
         OIcoDrytmd8r3WjaqCO28JD3qfBPzc2wV/CFh5GBq2MjQ140UuJwLuEg3CxXt2svth1p
         CU2Uq3D/+/nYYJEc/gthiLPiizxjrWijn4ciFl7UNRQ9xkBGkfo9Z4WhZay3+B6RIMrT
         ZrFYGlpf+yvN2/jUK967+HM/urQZlS3ik/3sbzMIdD3940Rudt9l5M7JTN6OyuPEgO3e
         HiX7BfeoyxyFYjajLXjNtEhsuUutg8bgS7qieOpiwgHGanyU5PGOxSkHCJI5byOUK4V8
         DRUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h64si3443271qkd.110.2019.01.31.08.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 08:10:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 80D073DBD2;
	Thu, 31 Jan 2019 16:10:14 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4530C5D717;
	Thu, 31 Jan 2019 16:10:08 +0000 (UTC)
Date: Thu, 31 Jan 2019 11:10:06 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>, Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
Message-ID: <20190131161006.GA16593@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190123222315.1122-1-jglisse@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 31 Jan 2019 16:10:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew what is your plan for this ? I had a discussion with Peter Xu
and Andrea about change_pte() and kvm. Today the change_pte() kvm
optimization is effectively disabled because of invalidate_range
calls. With a minimal couple lines patch on top of this patchset
we can bring back the kvm change_pte optimization and we can also
optimize some other cases like for instance when write protecting
after fork (but i am not sure this is something qemu does often so
it might not help for real kvm workload).

I will be posting a the extra patch as an RFC, but in the meantime
i wanted to know what was the status for this.


Jan, Christian does your previous ACK still holds for this ?


On Wed, Jan 23, 2019 at 05:23:06PM -0500, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> Hi Andrew, i see that you still have my event patch in you queue [1].
> This patchset replace that single patch and is broken down in further
> step so that it is easier to review and ascertain that no mistake were
> made during mechanical changes. Here are the step:
> 
>     Patch 1 - add the enum values
>     Patch 2 - coccinelle semantic patch to convert all call site of
>               mmu_notifier_range_init to default enum value and also
>               to passing down the vma when it is available
>     Patch 3 - update many call site to more accurate enum values
>     Patch 4 - add the information to the mmu_notifier_range struct
>     Patch 5 - helper to test if a range is updated to read only
> 
> All the remaining patches are update to various driver to demonstrate
> how this new information get use by device driver. I build tested
> with make all and make all minus everything that enable mmu notifier
> ie building with MMU_NOTIFIER=no. Also tested with some radeon,amd
> gpu and intel gpu.
> 
> If they are no objections i believe best plan would be to merge the
> the first 5 patches (all mm changes) through your queue for 5.1 and
> then to delay driver update to each individual driver tree for 5.2.
> This will allow each individual device driver maintainer time to more
> thouroughly test this more then my own testing.
> 
> Note that i also intend to use this feature further in nouveau and
> HMM down the road. I also expect that other user like KVM might be
> interested into leveraging this new information to optimize some of
> there secondary page table invalidation.
> 
> Here is an explaination on the rational for this patchset:
> 
> 
> CPU page table update can happens for many reasons, not only as a result
> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
> 
> This patch introduce a set of enums that can be associated with each of
> the events triggering a mmu notifier. Latter patches take advantages of
> those enum values.
> 
> - UNMAP: munmap() or mremap()
> - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
> - PROTECTION_VMA: change in access protections for the range
> - PROTECTION_PAGE: change in access protections for page in the range
> - SOFT_DIRTY: soft dirtyness tracking
> 
> Being able to identify munmap() and mremap() from other reasons why the
> page table is cleared is important to allow user of mmu notifier to
> update their own internal tracking structure accordingly (on munmap or
> mremap it is not longer needed to track range of virtual address as it
> becomes invalid).
> 
> [1] https://www.ozlabs.org/~akpm/mmotm/broken-out/mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2.patch
> 
> Cc: Christian König <christian.koenig@amd.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Krčmář <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> 
> Jérôme Glisse (9):
>   mm/mmu_notifier: contextual information for event enums
>   mm/mmu_notifier: contextual information for event triggering
>     invalidation
>   mm/mmu_notifier: use correct mmu_notifier events for each invalidation
>   mm/mmu_notifier: pass down vma and reasons why mmu notifier is
>     happening
>   mm/mmu_notifier: mmu_notifier_range_update_to_read_only() helper
>   gpu/drm/radeon: optimize out the case when a range is updated to read
>     only
>   gpu/drm/amdgpu: optimize out the case when a range is updated to read
>     only
>   gpu/drm/i915: optimize out the case when a range is updated to read
>     only
>   RDMA/umem_odp: optimize out the case when a range is updated to read
>     only
> 
>  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 13 ++++++++
>  drivers/gpu/drm/i915/i915_gem_userptr.c | 16 ++++++++++
>  drivers/gpu/drm/radeon/radeon_mn.c      | 13 ++++++++
>  drivers/infiniband/core/umem_odp.c      | 22 +++++++++++--
>  fs/proc/task_mmu.c                      |  3 +-
>  include/linux/mmu_notifier.h            | 42 ++++++++++++++++++++++++-
>  include/rdma/ib_umem_odp.h              |  1 +
>  kernel/events/uprobes.c                 |  3 +-
>  mm/huge_memory.c                        | 14 +++++----
>  mm/hugetlb.c                            | 11 ++++---
>  mm/khugepaged.c                         |  3 +-
>  mm/ksm.c                                |  6 ++--
>  mm/madvise.c                            |  3 +-
>  mm/memory.c                             | 25 +++++++++------
>  mm/migrate.c                            |  5 ++-
>  mm/mmu_notifier.c                       | 10 ++++++
>  mm/mprotect.c                           |  4 ++-
>  mm/mremap.c                             |  3 +-
>  mm/oom_kill.c                           |  3 +-
>  mm/rmap.c                               |  6 ++--
>  20 files changed, 171 insertions(+), 35 deletions(-)
> 
> -- 
> 2.17.2
> 

