Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id D39E36B0031
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 16:25:01 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id x13so975307qcv.29
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 13:25:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z3si11028489qcl.62.2014.04.17.13.25.00
        for <linux-mm@kvack.org>;
        Thu, 17 Apr 2014 13:25:01 -0700 (PDT)
Date: Thu, 17 Apr 2014 22:16:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: close race between split and zap huge pages
Message-ID: <20140417201602.GI10119@redhat.com>
References: <1397598536-25074-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397598536-25074-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi everyone,

On Wed, Apr 16, 2014 at 12:48:56AM +0300, Kirill A. Shutemov wrote:
> -	pmd = mm_find_pmd(mm, address);
> -	if (!pmd)
> +	pgd = pgd_offset(mm, address);
> +	if (!pgd_present(*pgd))
>  		return NULL;
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		return NULL;
> +	pmd = pmd_offset(pud, address);

This fix looks good to me and it was another potential source of
trouble making the BUG_ON flakey. But the rmap_walk out of order
problem still exists too I think. Possibly the testcase doesn't
exercise that.

> -	if (pmd_none(*pmd))
> +	if (!pmd_present(*pmd))
>  		goto unlock;

pmd_present is a bit slower, but functionally it's equivalent, the
pmd_present check is just more pedantic (kind of defining the
invariants for how a mapped pmd should look like).

If we'd add native THP swapout later !pmd_present would be more
correct for the VM calls to page_check_address_pmd, but something
would need changing anyway if split_huge_page is the callee as I don't
think we can skip the conversion from trans huge swap entry to linear
swap entries and the pmd2pte conversion.

The main reason that most places that could run into a trans huge pmd
would use pmd_none and never pmd_present is that originally
pmd_present wouldn't check _PAGE_PSE and _PAGE_PRESENT can be
temporarily be cleared with pmdp_invalidate on trans huge pmds. Now
pmd_present is safe too so there's no problem in using it on trans
huge pmds.

So either pmd_none !pmd_present are fine, the functional fix is the
part above.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
