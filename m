Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7090A6B51E8
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:05:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v195-v6so5115409pgb.0
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:05:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e22-v6sor1775655pgg.344.2018.08.30.07.05.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 07:05:43 -0700 (PDT)
Date: Fri, 31 Aug 2018 00:05:38 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 2/7] mm/rmap: map_pte() was not handling private
 ZONE_DEVICE page properly
Message-ID: <20180830140538.GA28695@350D>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180824192549.30844-3-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

On Fri, Aug 24, 2018 at 03:25:44PM -0400, jglisse@redhat.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> Private ZONE_DEVICE pages use a special pte entry and thus are not
> present. Properly handle this case in map_pte(), it is already handled
> in check_pte(), the map_pte() part was lost in some rebase most probably.
> 
> Without this patch the slow migration path can not migrate back private
> ZONE_DEVICE memory to regular memory. This was found after stress
> testing migration back to system memory. This ultimatly can lead the
> CPU to an infinite page fault loop on the special swap entry.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org
> ---
>  mm/page_vma_mapped.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index ae3c2a35d61b..1cf5b9bfb559 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -21,6 +21,15 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
>  			if (!is_swap_pte(*pvmw->pte))
>  				return false;
>  		} else {
> +			if (is_swap_pte(*pvmw->pte)) {
> +				swp_entry_t entry;
> +
> +				/* Handle un-addressable ZONE_DEVICE memory */
> +				entry = pte_to_swp_entry(*pvmw->pte);
> +				if (is_device_private_entry(entry))
> +					return true;
> +			}
> +

This happens just for !PVMW_SYNC && PVMW_MIGRATION? I presume this
is triggered via the remove_migration_pte() code path? Doesn't
returning true here imply that we've taken the ptl lock for the
pvmw?

Balbir
