Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8742806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:16:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u96so5122976wrc.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 06:16:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s35si10249430eda.251.2017.05.19.06.16.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 06:16:01 -0700 (PDT)
Subject: Re: [PATCH v1] mm: drop NULL return check of pte_offset_map_lock()
References: <1495089737-1292-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <edb3ffa0-3694-fbbb-a422-79f1ed3bd824@suse.cz>
Date: Fri, 19 May 2017 15:15:59 +0200
MIME-Version: 1.0
In-Reply-To: <1495089737-1292-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 05/18/2017 08:42 AM, Naoya Horiguchi wrote:
> pte_offset_map_lock() finds and takes ptl, and returns pte.
> But some callers return without unlocking the ptl when pte == NULL,
> which seems weird.
> 
> Git history said that !pte check in change_pte_range() was introduced in
> commit 1ad9f620c3a2 ("mm: numa: recheck for transhuge pages under lock
> during protection changes") and still remains after commit 175ad4f1e7a2
> ("mm: mprotect: use pmd_trans_unstable instead of taking the pmd_lock")
> which partially reverts 1ad9f620c3a2. So I think that it's just dead code.
> 
> Many other caller of pte_offset_map_lock() never check NULL return, so
> let's do likewise.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/memory.c   | 2 --
>  mm/mprotect.c | 2 --
>  2 files changed, 4 deletions(-)
> 
> diff --git v4.11-rc6-mmotm-2017-04-13-14-50/mm/memory.c v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/memory.c
> index 8ae6700..c17fad1d 100644
> --- v4.11-rc6-mmotm-2017-04-13-14-50/mm/memory.c
> +++ v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/memory.c
> @@ -4040,8 +4040,6 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  		goto out;
>  
>  	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
> -	if (!ptep)
> -		goto out;
>  	if (!pte_present(*ptep))
>  		goto unlock;
>  	*ptepp = ptep;
> diff --git v4.11-rc6-mmotm-2017-04-13-14-50/mm/mprotect.c v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/mprotect.c
> index 8fd010f..d60a1ee 100644
> --- v4.11-rc6-mmotm-2017-04-13-14-50/mm/mprotect.c
> +++ v4.11-rc6-mmotm-2017-04-13-14-50_patched/mm/mprotect.c
> @@ -58,8 +58,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	 * reading.
>  	 */
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> -	if (!pte)
> -		return 0;
>  
>  	/* Get target node for single threaded private VMAs */
>  	if (prot_numa && !(vma->vm_flags & VM_SHARED) &&
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
