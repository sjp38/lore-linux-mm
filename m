Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC206B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 06:27:07 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so4124478pab.8
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 03:27:07 -0700 (PDT)
Date: Fri, 11 Oct 2013 11:26:29 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 33/34] iommu/arm-smmu: handle pgtable_page_ctor() fail
Message-ID: <20131011102629.GB14732@mudshark.cambridge.arm.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381428359-14843-34-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381428359-14843-34-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "grant.likely@linaro.org" <grant.likely@linaro.org>, "rob.herring@calxeda.com" <rob.herring@calxeda.com>

On Thu, Oct 10, 2013 at 07:05:58PM +0100, Kirill A. Shutemov wrote:
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: Rob Herring <rob.herring@calxeda.com>
> ---
>  drivers/iommu/arm-smmu.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/iommu/arm-smmu.c b/drivers/iommu/arm-smmu.c
> index f417e89e1e..2b256a5075 100644
> --- a/drivers/iommu/arm-smmu.c
> +++ b/drivers/iommu/arm-smmu.c
> @@ -1211,7 +1211,10 @@ static int arm_smmu_alloc_init_pte(struct arm_smmu_device *smmu, pmd_t *pmd,
>  
>  		arm_smmu_flush_pgtable(smmu, page_address(table),
>  				       ARM_SMMU_PTE_HWTABLE_SIZE);
> -		pgtable_page_ctor(table);
> +		if (!pgtable_page_ctor(table)) {
> +			__free_page(table);
> +			return -ENOMEM;
> +		}
>  		pmd_populate(NULL, pmd, table);
>  		arm_smmu_flush_pgtable(smmu, pmd, sizeof(*pmd));
>  	}

  Acked-by: Will Deacon <will.deacon@arm.com>

I have quite a few changes queued for this driver, but it doesn't look like
you'll get a conflict with the iommu tree.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
