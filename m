Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCA26B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 11:25:43 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id k126so4334745wmd.5
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:25:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si1472760wra.454.2017.12.15.08.25.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 08:25:41 -0800 (PST)
Date: Fri, 15 Dec 2017 17:25:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
Message-ID: <20171215162534.GA16951@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 14-12-17 13:30:56, David Rientjes wrote:
> Commit 4d4bbd8526a8 ("mm, oom_reaper: skip mm structs with mmu notifiers")
> prevented the oom reaper from unmapping private anonymous memory with the
> oom reaper when the oom victim mm had mmu notifiers registered.
> 
> The rationale is that doing mmu_notifier_invalidate_range_{start,end}()
> around the unmap_page_range(), which is needed, can block and the oom
> killer will stall forever waiting for the victim to exit, which may not
> be possible without reaping.
> 
> That concern is real, but only true for mmu notifiers that have blockable
> invalidate_range_{start,end}() callbacks.  This patch adds a "flags" field
> to mmu notifier ops that can set a bit to indicate that these callbacks do
> not block.
> 
> The implementation is steered toward an expensive slowpath, such as after
> the oom reaper has grabbed mm->mmap_sem of a still alive oom victim.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Yes, this make sense. I haven't checked all the existing mmu notifiers
but those that you have marked seem to be OK.

I just think that the semantic of the flag should be describe more. See
below

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  v2:
>    - specifically exclude mmu_notifiers without invalidate callbacks
>    - move flags to mmu_notifier_ops per Paolo
>    - reverse flag from blockable -> not blockable per Christian
> 
>  drivers/infiniband/hw/hfi1/mmu_rb.c |  1 +
>  drivers/iommu/amd_iommu_v2.c        |  1 +
>  drivers/iommu/intel-svm.c           |  1 +
>  drivers/misc/sgi-gru/grutlbpurge.c  |  1 +
>  include/linux/mmu_notifier.h        | 21 +++++++++++++++++++++
>  mm/mmu_notifier.c                   | 31 +++++++++++++++++++++++++++++++
>  virt/kvm/kvm_main.c                 |  1 +
>  7 files changed, 57 insertions(+)
> 
[...]
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -10,6 +10,9 @@
>  struct mmu_notifier;
>  struct mmu_notifier_ops;
>  
> +/* mmu_notifier_ops flags */
> +#define MMU_INVALIDATE_DOES_NOT_BLOCK	(0x01)
> +
>  #ifdef CONFIG_MMU_NOTIFIER
>  
>  /*
> @@ -26,6 +29,15 @@ struct mmu_notifier_mm {
>  };
>  
>  struct mmu_notifier_ops {
> +	/*
> +	 * Flags to specify behavior of callbacks for this MMU notifier.
> +	 * Used to determine which context an operation may be called.
> +	 *
> +	 * MMU_INVALIDATE_DOES_NOT_BLOCK: invalidate_{start,end} does not
> +	 *				  block
> +	 */
> +	int flags;

This should be more specific IMHO. What do you think about the following
wording?

invalidate_{start,end,range} doesn't block on any locks which depend
directly or indirectly (via lock chain or resources e.g. worker context)
on a memory allocation.

> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -476,6 +476,7 @@ static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
>  }
>  
>  static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
> +	.flags			= MMU_INVALIDATE_DOES_NOT_BLOCK,
>  	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
>  	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
>  	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
