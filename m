Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id DA8F46B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 10:51:22 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so7576467wib.3
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 07:51:22 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id dk1si15469979wib.50.2014.07.01.07.51.20
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 07:51:21 -0700 (PDT)
Date: Tue, 1 Jul 2014 17:50:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v9] mm: support madvise(MADV_FREE)
Message-ID: <20140701145058.GA2084@node.dhcp.inet.fi>
References: <1404174975-22019-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404174975-22019-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Tue, Jul 01, 2014 at 09:36:15AM +0900, Minchan Kim wrote:
> +	do {
> +		/*
> +		 * XXX: We can optimize with supporting Hugepage free
> +		 * if the range covers.
> +		 */
> +		next = pmd_addr_end(addr, end);
> +		if (pmd_trans_huge(*pmd))
> +			split_huge_page_pmd(vma, addr, pmd);

Could you implement proper THP support before upstreaming the feature?
It shouldn't be a big deal.

> +		/*
> +		 * Here there can be other concurrent MADV_DONTNEED or
> +		 * trans huge page faults running, and if the pmd is
> +		 * none or trans huge it can change under us. This is
> +		 * because MADV_LAZYFREE holds the mmap_sem in read
> +		 * mode.
> +		 */
> +		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> +			goto next;
> +		next = madvise_free_pte_range(tlb, vma, pmd, addr, next);
> +next:
> +		cond_resched();
> +	} while (pmd++, addr = next, addr != end);

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
