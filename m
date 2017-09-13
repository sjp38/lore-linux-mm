Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8B126B0033
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 09:18:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i14so206888qke.6
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 06:18:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p4si461592qkc.285.2017.09.13.06.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 06:18:33 -0700 (PDT)
Date: Wed, 13 Sep 2017 15:18:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom_reaper: skip mm structs with mmu notifiers
Message-ID: <20170913131830.GA12833@redhat.com>
References: <20170913113427.2291-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170913113427.2291-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Sep 13, 2017 at 01:34:27PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Andrea has noticed that the oom_reaper doesn't invalidate the range
> via mmu notifiers (mmu_notifier_invalidate_range_start,
> mmu_notifier_invalidate_range_end) and that can corrupt the memory
> of the kvm guest for example.
> 
> tlb_flush_mmu_tlbonly already invokes mmu notifiers but that is not
> sufficient as per Andrea:
> : mmu_notifier_invalidate_range cannot be used in replacement of
> : mmu_notifier_invalidate_range_start/end. For KVM
> : mmu_notifier_invalidate_range is a noop and rightfully so. A MMU
> : notifier implementation has to implement either
> : ->invalidate_range method or the invalidate_range_start/end
> : methods, not both. And if you implement invalidate_range_start/end
> : like KVM is forced to do, calling mmu_notifier_invalidate_range in
> : common code is a noop for KVM.
> :
> : For those MMU notifiers that can get away only implementing
> : ->invalidate_range, the ->invalidate_range is implicitly called by
> : mmu_notifier_invalidate_range_end(). And only those secondary MMUs
> : that share the same pagetable with the primary MMU (like AMD
> : iommuv2) can get away only implementing ->invalidate_range.
> 
> As the callback is allowed to sleep and the implementation is out
> of hand of the MM it is safer to simply bail out if there is an
> mmu notifier registered. In order to not fail too early make the
> mm_has_notifiers check under the oom_lock and have a little nap before
> failing to give the current oom victim some more time to exit.
> 
> Changes since v1
> - move mm_has_notifiers check after we hold mmap_sem to prevent from
>   any potential races as per Andrea
> 
> Fixes: aac453635549 ("mm, oom: introduce oom reaper")
> Noticed-by: Andrea Arcangeli <aarcange@redhat.com>
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> I have posted this as an RFC previously [1]. I have updated
> the changelog to be more clear about the issue and moved the
> mm_has_notifiers after the lock has been take based on Andrea's
> suggestion.
> 
> Can we merge this?
> 
> [1] http://lkml.kernel.org/r/20170830084600.17491-1-mhocko@kernel.org
> 
>  include/linux/mmu_notifier.h |  5 +++++
>  mm/oom_kill.c                | 16 ++++++++++++++++
>  2 files changed, 21 insertions(+)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
