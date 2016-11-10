Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5993280253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 05:31:31 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id rf5so89551410pab.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 02:31:31 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id h26si4137521pfh.56.2016.11.10.02.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 02:31:30 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id 144so3741687pfv.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 02:31:30 -0800 (PST)
Subject: Re: [PATCH v2 09/12] mm: hwpoison: soft offline supports thp
 migration
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-10-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <6e9aa943-31ea-5b08-8459-2e6a85940546@gmail.com>
Date: Thu, 10 Nov 2016 21:31:10 +1100
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-10-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>



On 08/11/16 10:31, Naoya Horiguchi wrote:
> This patch enables thp migration for soft offline.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 31 ++++++++++++-------------------
>  1 file changed, 12 insertions(+), 19 deletions(-)
> 
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
> index 19e796d..6cc8157 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
> @@ -1485,7 +1485,17 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
>  	if (PageHuge(p))
>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>  						   nid);
> -	else
> +	else if (thp_migration_supported() && PageTransHuge(p)) {
> +		struct page *thp;
> +
> +		thp = alloc_pages_node(nid,
> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> +			HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;

Just wondering if new_page() fails, migration of that entry fails. Do we then
split and migrate? I guess this applies to THP migration in general.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
