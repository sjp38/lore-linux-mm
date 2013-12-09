Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 776366B00B7
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:13:55 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so1660941eaj.37
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:13:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l44si10188030eem.40.2013.12.09.08.13.54
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:13:54 -0800 (PST)
Message-ID: <52A5EC3E.2050301@redhat.com>
Date: Mon, 09 Dec 2013 11:13:50 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/18] mm: numa: Defer TLB flush for THP migration as
 long as possible
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-13-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:

> diff --git a/mm/migrate.c b/mm/migrate.c
> index cfb4190..5372521 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1759,6 +1759,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  		goto out_fail;
>  	}
>  
> +	/* PTL provides a memory barrier with change_protection_range */
> +	ptl = pmd_lock(mm, pmd);
> +	if (tlb_flush_pending(mm))
> +		flush_tlb_range(vma, mmun_start, mmun_end);
> +	spin_unlock(ptl);
> +
>  	/* Prepare a page as a migration target */
>  	__set_page_locked(new_page);
>  	SetPageSwapBacked(new_page);

I don't think there is a need for that extra memory barrier.

On the "set_tlb_flush_pending, turn ptes into NUMA ones" side, we
have a barrier in the form of the page table lock.

We only end up in this code path if the pte/pmd already is a NUMA
one, and we take several spinlocks along the way to doing this test.
That provides for the memory barrier in this code path.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
