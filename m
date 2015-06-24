Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF6BB6B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 03:49:34 -0400 (EDT)
Received: by wgck11 with SMTP id k11so28852585wgc.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 00:49:34 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0099.outbound.protection.outlook.com. [157.55.234.99])
        by mx.google.com with ESMTPS id da6si1378087wib.118.2015.06.24.00.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Jun 2015 00:49:33 -0700 (PDT)
Message-ID: <558A610F.7090501@mellanox.com>
Date: Wed, 24 Jun 2015 10:49:35 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/36] HMM: add special swap filetype for memory migrated
 to HMM device memory.
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-17-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-17-git-send-email-j.glisse@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul
 Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Jerome Glisse <jglisse@redhat.com>, Jatin
 Kumar <jakumar@nvidia.com>

On 21/05/2015 22:31, j.glisse@gmail.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> When migrating anonymous memory from system memory to device memory
> CPU pte are replaced with special HMM swap entry so that page fault,
> get user page (gup), fork, ... are properly redirected to HMM helpers.
> 
> This patch only add the new swap type entry and hooks HMM helpers
> functions inside the page fault and fork code path.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> ---
>  include/linux/hmm.h     | 34 ++++++++++++++++++++++++++++++++++
>  include/linux/swap.h    | 12 +++++++++++-
>  include/linux/swapops.h | 43 ++++++++++++++++++++++++++++++++++++++++++-
>  mm/hmm.c                | 21 +++++++++++++++++++++
>  mm/memory.c             | 22 ++++++++++++++++++++++
>  5 files changed, 130 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 186f497..f243eb5 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -257,6 +257,40 @@ void hmm_mirror_range_dirty(struct hmm_mirror *mirror,
>  			    unsigned long start,
>  			    unsigned long end);
>  
> +int hmm_handle_cpu_fault(struct mm_struct *mm,
> +			struct vm_area_struct *vma,
> +			pmd_t *pmdp, unsigned long addr,
> +			unsigned flags, pte_t orig_pte);
> +
> +int hmm_mm_fork(struct mm_struct *src_mm,
> +		struct mm_struct *dst_mm,
> +		struct vm_area_struct *dst_vma,
> +		pmd_t *dst_pmd,
> +		unsigned long start,
> +		unsigned long end);
> +
> +#else /* CONFIG_HMM */
> +
> +static inline int hmm_handle_mm_fault(struct mm_struct *mm,
I think this should be hmm_handle_cpu_fault, to match the function
declared above in the CONFIG_HMM case.

> +				      struct vm_area_struct *vma,
> +				      pmd_t *pmdp, unsigned long addr,
> +				      unsigned flags, pte_t orig_pte)
> +{
> +	return VM_FAULT_SIGBUS;
> +}
> +
> +static inline int hmm_mm_fork(struct mm_struct *src_mm,
> +			      struct mm_struct *dst_mm,
> +			      struct vm_area_struct *dst_vma,
> +			      pmd_t *dst_pmd,
> +			      unsigned long start,
> +			      unsigned long end)
> +{
> +	BUG();
> +	return -ENOMEM;
> +}
>  
>  #endif /* CONFIG_HMM */
> +
> +
>  #endif

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
