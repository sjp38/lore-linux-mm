Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7BB0A6B004D
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 10:12:27 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so3406647pad.24
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 07:12:27 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id ag1si2479428vec.32.2014.07.17.07.12.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 07:12:26 -0700 (PDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so2042651qge.16
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 07:12:26 -0700 (PDT)
Date: Thu, 17 Jul 2014 10:12:18 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v2 01/25] mm: Add kfd_process pointer to mm_struct
Message-ID: <20140717141216.GA1963@gmail.com>
References: <1405603773-32688-1-git-send-email-oded.gabbay@amd.com>
 <53C7D666.6000405@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53C7D666.6000405@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, Jul 17, 2014 at 04:57:58PM +0300, Oded Gabbay wrote:
> Forgot to add mm mailing list. Sorry.
> 
> This patch enables the amdkfd driver to retrieve the kfd_process
> object from the process's mm_struct. This is needed because kfd_process
> lifespan is bound to the process's mm_struct lifespan.
> 
> When amdkfd is notified about an mm_struct tear-down, it checks if the
> kfd_process pointer is valid. If so, it releases the kfd_process object
> and all relevant resources.
> 
> In v3 of the patchset I will update the binding to match the final discussions
> on [PATCH 1/8] mmput: use notifier chain to call subsystem exit handler.
> In the meantime, I'm going to try and see if I can drop the kfd_process
> in mm_struct and remove the use of the new notification chain in mmput.
> Instead, I will try to use the mmu release notifier.

So the mmput notifier chain will not happen. I did a patch with call_srcu
and adding couple more helper to mmu_notifier. I will send that today for
review.

That being said, adding a device driver specific to mm_struct will most
likely be a big no. I am myself gonna remove hmm from mm_struct as people
are reluctant to see such change.

Cheers,
Jerome


> 
> Signed-off-by: Oded Gabbay <oded.gabbay@amd.com>
> ---
>  include/linux/mm_types.h | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 678097c..ff71496 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -20,6 +20,10 @@
>  struct hmm;
>  #endif
>  +#if defined(CONFIG_HSA_RADEON) || defined(CONFIG_HSA_RADEON_MODULE)
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
