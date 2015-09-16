Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 780436B0254
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 18:26:30 -0400 (EDT)
Received: by qgx61 with SMTP id 61so7670qgx.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 15:26:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s18si24027774qgd.74.2015.09.16.15.26.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 15:26:29 -0700 (PDT)
Date: Wed, 16 Sep 2015 15:26:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/11] mm,thp: introduce flush_pmd_tlb_range
Message-Id: <20150916152628.32073b37c02550557672092c@linux-foundation.org>
In-Reply-To: <1440666194-21478-10-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
	<1440666194-21478-10-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com

On Thu, 27 Aug 2015 14:33:12 +0530 Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:

> --- a/mm/pgtable-generic.c
> +++ b/mm/pgtable-generic.c
> @@ -84,6 +84,19 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  
> +#ifndef __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
> +
> +/*
> + * ARCHes with special requirements for evicting THP backing TLB entries can
> + * implement this. Otherwise also, it can help optimizing thp flush operation.
> + * flush_tlb_range() can have optimization to nuke the entire TLB if flush span
> + * is greater than a threashhold, which will likely be true for a single
> + * huge page.
> + * e.g. see arch/arc: flush_pmd_tlb_range
> + */
> +#define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
> +#endif

Did you consider using a __weak function here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
