Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5228E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 03:21:49 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v74-v6so3573326lje.6
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:21:49 -0800 (PST)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::190])
        by mx.google.com with ESMTPS id y193si9413979lfa.15.2018.12.11.00.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 00:21:47 -0800 (PST)
Subject: Re: [PATCH v2] mm: thp: fix flags for pmd migration when split
References: <20181211051254.16633-1-peterx@redhat.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <1fc103f7-3164-007d-bcfd-7ad7c60bb6ec@yandex-team.ru>
Date: Tue, 11 Dec 2018 11:21:44 +0300
MIME-Version: 1.0
In-Reply-To: <20181211051254.16633-1-peterx@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On 11.12.2018 8:12, Peter Xu wrote:
> When splitting a huge migrating PMD, we'll transfer all the existing
> PMD bits and apply them again onto the small PTEs.  However we are
> fetching the bits unconditionally via pmd_soft_dirty(), pmd_write()
> or pmd_yound() while actually they don't make sense at all when it's
> a migration entry.  Fix them up by make it conditional.
> 
> Note that if my understanding is correct about the problem then if
> without the patch there is chance to lose some of the dirty bits in
> the migrating pmd pages (on x86_64 we're fetching bit 11 which is part
> of swap offset instead of bit 2) and it could potentially corrupt the
> memory of an userspace program which depends on the dirty bit.
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
> v2:
> - fix it up for young/write/dirty bits too [Konstantin]
> ---
>   mm/huge_memory.c | 15 ++++++++++-----
>   1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f2d19e4fe854..b00941b3d342 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2157,11 +2157,16 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>   		page = pmd_page(old_pmd);
>   	VM_BUG_ON_PAGE(!page_count(page), page);
>   	page_ref_add(page, HPAGE_PMD_NR - 1);
> -	if (pmd_dirty(old_pmd))
> -		SetPageDirty(page);
> -	write = pmd_write(old_pmd);
> -	young = pmd_young(old_pmd);
> -	soft_dirty = pmd_soft_dirty(old_pmd);
> +	if (unlikely(pmd_migration)) {
> +		soft_dirty = pmd_swp_soft_dirty(old_pmd);
> +		young = write = false;
> +	} else {
> +		if (pmd_dirty(old_pmd))
> +			SetPageDirty(page);
> +		write = pmd_write(old_pmd);
> +		young = pmd_young(old_pmd);
> +		soft_dirty = pmd_soft_dirty(old_pmd);
> +	}

Write/read-only is encoded into migration entry.
I suppose there should be something like this:

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2151,16 +2151,21 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,

                 entry = pmd_to_swp_entry(old_pmd);
                 page = pfn_to_page(swp_offset(entry));
+               write = is_write_migration_entry(entry);
+               young = false;
+               soft_dirty = pmd_swp_soft_dirty(old_pmd);
         } else
  #endif
+       {
                 page = pmd_page(old_pmd);
+               if (pmd_dirty(old_pmd))
+                       SetPageDirty(page);
+               write = pmd_write(old_pmd);
+               young = pmd_young(old_pmd);
+               soft_dirty = pmd_soft_dirty(old_pmd);
+       }
         VM_BUG_ON_PAGE(!page_count(page), page);
         page_ref_add(page, HPAGE_PMD_NR - 1);
-       if (pmd_dirty(old_pmd))
-               SetPageDirty(page);
-       write = pmd_write(old_pmd);
-       young = pmd_young(old_pmd);
-       soft_dirty = pmd_soft_dirty(old_pmd);

         /*
          * Withdraw the table only after we mark the pmd entry invalid.

>   
>   	/*
>   	 * Withdraw the table only after we mark the pmd entry invalid.
> 
