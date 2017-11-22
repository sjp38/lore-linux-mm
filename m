Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22D3A6B027E
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:47:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id r12so16138422pgu.9
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:47:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h89si4588361pld.202.2017.11.22.04.47.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:47:25 -0800 (PST)
Date: Wed, 22 Nov 2017 13:47:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hugetlb: Fix NULL-pointer dereference on 5-level
 paging machine
Message-ID: <20171122124723.pr2yazh2g3zqjula@dhcp22.suse.cz>
References: <20171122121921.64822-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122121921.64822-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, stable@vger.kernel.org

On Wed 22-11-17 15:19:21, Kirill A. Shutemov wrote:
> I've made mistake during converting hugetlb code to 5-level paging:
> in huge_pte_alloc() we have to use p4d_alloc(), not p4d_offset().
> Otherwise it leads to crash -- NULL-pointer dereference in pud_alloc()
> if p4d table is not yet allocated.

Ups, I have completely missed that when reviewing the patch. Sorry about
that.
 
> It only can happen in 5-level paging mode. In 4-level paging mode
> p4d_offset() always returns pgd, so we are fine.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: c2febafc6773 ("mm: convert generic code to 5-level paging")
> Cc: <stable@vger.kernel.org> # v4.11+

Acked-by: Michal Hocko <mhocko@suse.com>

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
> -- 
> 2.15.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
