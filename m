Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 855E5900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:42:39 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id r5so323423qcx.13
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:42:39 -0700 (PDT)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id q45si3976130qga.96.2014.07.11.08.42.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 08:42:38 -0700 (PDT)
Received: by mail-qa0-f45.google.com with SMTP id s7so1015394qap.4
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:42:37 -0700 (PDT)
Date: Fri, 11 Jul 2014 11:42:32 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 01/83] mm: Add kfd_process pointer to mm_struct
Message-ID: <20140711154231.GB1870@gmail.com>
References: <1405028848-5660-1-git-send-email-oded.gabbay@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1405028848-5660-1-git-send-email-oded.gabbay@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Airlie <airlied@linux.ie>, Alex Deucher <alexander.deucher@amd.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, John Bridgman <John.Bridgman@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Joerg Roedel <joro@8bytes.org>, linux-mm <linux-mm@kvack.org>, Oded Gabbay <oded.gabbay@amd.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Michel Lespinasse <walken@google.com>

On Fri, Jul 11, 2014 at 12:47:26AM +0300, Oded Gabbay wrote:
> This patch enables the KFD to retrieve the kfd_process
> object from the process's mm_struct. This is needed because kfd_process
> lifespan is bound to the process's mm_struct lifespan.
> 
> When KFD is notified about an mm_struct tear-down, it checks if the
> kfd_process pointer is valid. If so, it releases the kfd_process object
> and all relevant resources.
> 
> Signed-off-by: Oded Gabbay <oded.gabbay@amd.com>
> ---
>  include/linux/mm_types.h | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 678097c..6179107 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -20,6 +20,10 @@
>  struct hmm;
>  #endif
>  
> +#ifdef CONFIG_HSA_RADEON
> +struct kfd_process;
> +#endif
> +
>  #ifndef AT_VECTOR_SIZE_ARCH
>  #define AT_VECTOR_SIZE_ARCH 0
>  #endif
> @@ -439,6 +443,16 @@ struct mm_struct {
>  	 */
>  	struct hmm *hmm;
>  #endif
> +#if defined(CONFIG_HSA_RADEON) || defined(CONFIG_HSA_RADEON_MODULE)
> +	/*
> +	 * kfd always register an mmu_notifier we rely on mmu notifier to keep
> +	 * refcount on mm struct as well as forbiding registering kfd on a
> +	 * dying mm
> +	 *
> +	 * This field is set with mmap_sem old in write mode.
> +	 */
> +	struct kfd_process *kfd_process;
> +#endif

I understand the need to bind kfd to mm life time but this is wrong
on several level. First we do not want per driver define flag here.
Second this should be a IOMMU/PASID pointer of some sort, i am sure
that Intel will want to add itself too to mm_struct so instead of
having each IOMMU add a pointer here, i would rather see a generic
pointer to a generic IOMMU struct and have this use generic IOMMU
code that can then call specific user dispatch function.

I know this add a layer but this is not a critical code path and
should never be.

I am adding Jesse as he might have thought on that.

So this one is NAK

Cheers,
Jerome

>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>  	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
>  #endif
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
