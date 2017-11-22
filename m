Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1A8C6B0275
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:36:47 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id f9so10067344wra.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:36:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c40si2405840edf.117.2017.11.22.04.36.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:36:46 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlb: Fix NULL-pointer dereference on 5-level
 paging machine
References: <20171122121921.64822-1-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <88a7a176-6070-2bf1-4579-d5fccdfc7f37@suse.cz>
Date: Wed, 22 Nov 2017 13:36:43 +0100
MIME-Version: 1.0
In-Reply-To: <20171122121921.64822-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, stable@vger.kernel.org

On 11/22/2017 01:19 PM, Kirill A. Shutemov wrote:
> I've made mistake during converting hugetlb code to 5-level paging:
> in huge_pte_alloc() we have to use p4d_alloc(), not p4d_offset().
> Otherwise it leads to crash -- NULL-pointer dereference in pud_alloc()
> if p4d table is not yet allocated.
> 
> It only can happen in 5-level paging mode. In 4-level paging mode
> p4d_offset() always returns pgd, so we are fine.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: c2febafc6773 ("mm: convert generic code to 5-level paging")
> Cc: <stable@vger.kernel.org> # v4.11+

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/hugetlb.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 2d2ff5e8bf2b..94a4c0b63580 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4617,7 +4617,9 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  	pte_t *pte = NULL;
>  
>  	pgd = pgd_offset(mm, addr);
> -	p4d = p4d_offset(pgd, addr);
> +	p4d = p4d_alloc(mm, pgd, addr);
> +	if (!p4d)
> +		return NULL;
>  	pud = pud_alloc(mm, p4d, addr);
>  	if (pud) {
>  		if (sz == PUD_SIZE) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
