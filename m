Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 054136B7C56
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 22:34:16 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so2299309qkn.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 19:34:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 63si235279qkr.108.2018.12.06.19.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 19:34:15 -0800 (PST)
Date: Fri, 7 Dec 2018 11:34:07 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH] mm: thp: fix soft dirty for migration when split
Message-ID: <20181207033407.GB10726@xz-x1>
References: <20181206084604.17167-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181206084604.17167-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org

On Thu, Dec 06, 2018 at 04:46:04PM +0800, Peter Xu wrote:
> When splitting a huge migrating PMD, we'll transfer the soft dirty bit
> from the huge page to the small pages.  However we're possibly using a
> wrong data since when fetching the bit we're using pmd_soft_dirty()
> upon a migration entry.  Fix it up.

Note that if my understanding is correct about the problem then if
without the patch there is chance to lose some of the dirty bits in
the migrating pmd pages (on x86_64 we're fetching bit 11 which is part
of swap offset instead of bit 2) and it could potentially corrupt the
memory of an userspace program which depends on the dirty bit.

> 
> CC: Andrea Arcangeli <aarcange@redhat.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> CC: Matthew Wilcox <willy@infradead.org>
> CC: Michal Hocko <mhocko@suse.com>
> CC: Dave Jiang <dave.jiang@intel.com>
> CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> CC: Souptick Joarder <jrdr.linux@gmail.com>
> CC: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
> 
> I noticed this during code reading.  Only compile tested.  I'm sending
> a patch directly for review comments since it's relatively
> straightforward and not easy to test.  Please have a look, thanks.
> ---
>  mm/huge_memory.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f2d19e4fe854..fb0787c3dd3b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2161,7 +2161,10 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  		SetPageDirty(page);
>  	write = pmd_write(old_pmd);
>  	young = pmd_young(old_pmd);
> -	soft_dirty = pmd_soft_dirty(old_pmd);
> +	if (unlikely(pmd_migration))
> +		soft_dirty = pmd_swp_soft_dirty(old_pmd);
> +	else
> +		soft_dirty = pmd_soft_dirty(old_pmd);
>  
>  	/*
>  	 * Withdraw the table only after we mark the pmd entry invalid.
> -- 
> 2.17.1
> 

Regards,

-- 
Peter Xu
