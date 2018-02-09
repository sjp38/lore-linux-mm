Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6298D6B026A
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 15:43:04 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t14so4371518wmc.5
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 12:43:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c8si2207771wre.497.2018.02.09.12.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 12:43:03 -0800 (PST)
Date: Fri, 9 Feb 2018 12:43:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: thp: fix potential clearing to referenced flag
 in page_idle_clear_pte_refs_one()
Message-Id: <20180209124300.fc3468a72e0d223c0e4d4195@linux-foundation.org>
In-Reply-To: <1518203521-81173-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1518203521-81173-1-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, gavin.dg@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 10 Feb 2018 03:12:01 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> For PTE-mapped THP, the compound THP has not been split to normal 4K
> pages yet, the whole THP is considered referenced if any one of sub
> page is referenced.
> 
> When walking PTE-mapped THP by pvmw, all relevant PTEs will be checked
> to retrieve referenced bit. But, the current code just returns the
> result of the last PTE. If the last PTE has not referenced, the
> referenced flag will be cleared.
> 
> Just did logical OR for referenced to get the correct result.
> 
> Reported-by: Gang Deng <gavin.dg@linux.alibaba.com>
> Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v2: adopted the suggestion from Kirill. Not use "||=" style to keep checkpatch
> quiet, otherwise it reports ERROR: spaces required around that '||'
> 
>  mm/page_idle.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_idle.c b/mm/page_idle.c
> index 0a49374..a4baec9 100644
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -65,11 +65,15 @@ static bool page_idle_clear_pte_refs_one(struct page *page,
>  	while (page_vma_mapped_walk(&pvmw)) {
>  		addr = pvmw.address;
>  		if (pvmw.pte) {
> -			referenced = ptep_clear_young_notify(vma, addr,
> -					pvmw.pte);
> +			/*
> +			 * For PTE-mapped THP, one sub page is referenced,
> +			 * the whole THP is referenced.
> +			 */
> +			referenced = referenced || ptep_clear_young_notify(vma,
> +					addr, pvmw.pte);

That doesn't work.  If `referenced' is already true,
ptep_clear_young_notify() will not be called.

	if (ptep_clear_young_notify(...))
		referenced = true;

would suit.


It makes me wonder what difference this bug makes and why that
difference was not noted in your testing.  Any theories about that? 
How can we design a test which *will* make this error apparent?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
