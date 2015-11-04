Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id C17C782F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 21:15:30 -0500 (EST)
Received: by iodd200 with SMTP id d200so39636075iod.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 18:15:30 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id gb2si380790igd.38.2015.11.03.18.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 18:15:30 -0800 (PST)
Received: by padda3 with SMTP id da3so4437681pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 18:15:29 -0800 (PST)
Date: Wed, 4 Nov 2015 11:16:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Message-ID: <20151104021624.GA2476@swordfish>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446600367-7976-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi Minchan,

On (11/04/15 10:25), Minchan Kim wrote:
[..]
>+static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>+                               unsigned long end, struct mm_walk *walk)
>+
...
> +	if (pmd_trans_unstable(pmd))
> +		return 0;

I think it makes sense to update pmd_trans_unstable() and
pmd_none_or_trans_huge_or_clear_bad() comments in asm-generic/pgtable.h
Because they explicitly mention MADV_DONTNEED only. Just a thought.


> @@ -379,6 +502,14 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  		return madvise_remove(vma, prev, start, end);
>  	case MADV_WILLNEED:
>  		return madvise_willneed(vma, prev, start, end);
> +	case MADV_FREE:
> +		/*
> +		 * XXX: In this implementation, MADV_FREE works like
		  ^^^^
		XXX

> +		 * MADV_DONTNEED on swapless system or full swap.
> +		 */
> +		if (get_nr_swap_pages() > 0)
> +			return madvise_free(vma, prev, start, end);
> +		/* passthrough */

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
