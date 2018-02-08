Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61C696B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 17:39:30 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h13so3436249wrc.9
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 14:39:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o10si632245wrg.396.2018.02.08.14.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 14:39:29 -0800 (PST)
Date: Thu, 8 Feb 2018 14:39:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: thp: fix potential clearing to referenced flag in
 page_idle_clear_pte_refs_one()
Message-Id: <20180208143926.5484e8fd75a56ff35b778bcc@linux-foundation.org>
In-Reply-To: <1517875596-76350-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1517875596-76350-1-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, gavin.dg@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  6 Feb 2018 08:06:36 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> For PTE-mapped THP, the compound THP has not been split to normal 4K
> pages yet, the whole THP is considered referenced if any one of sub
> page is referenced.
> 
> When walking PTE-mapped THP by pvmw, all relevant PTEs will be checked
> to retrieve referenced bit. But, the current code just returns the
> result of the last PTE. If the last PTE has not referenced, the
> referenced flag will be cleared.
> 
> So, here just break pvmw walk once referenced PTE is found if the page
> is a part of THP.
> 
> ...
>
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -67,6 +67,14 @@ static bool page_idle_clear_pte_refs_one(struct page *page,
>  		if (pvmw.pte) {
>  			referenced = ptep_clear_young_notify(vma, addr,
>  					pvmw.pte);
> +			/*
> +			 * For PTE-mapped THP, one sub page is referenced,
> +			 * the whole THP is referenced.
> +			 */
> +			if (referenced && PageTransCompound(pvmw.page)) {
> +				page_vma_mapped_walk_done(&pvmw);
> +				break;
> +			}

This means that the function will no longer clear the referenced bits
in all the ptes.  What effect does this have and should we document
this in some fashion?

>  		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
>  			referenced = pmdp_clear_young_notify(vma, addr,
>  					pvmw.pmd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
