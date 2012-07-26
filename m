Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id ADC986B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 14:33:25 -0400 (EDT)
Message-ID: <50118D16.4050603@redhat.com>
Date: Thu, 26 Jul 2012 14:31:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz>
In-Reply-To: <20120720143635.GE12434@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/20/2012 10:36 AM, Michal Hocko wrote:

> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -81,7 +81,12 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>   		if (saddr) {
>   			spte = huge_pte_offset(svma->vm_mm, saddr);
>   			if (spte) {
> -				get_page(virt_to_page(spte));
> +				struct page *spte_page = virt_to_page(spte);
> +				if (!is_hugetlb_pmd_page_valid(spte_page)) {

What prevents somebody else from marking the hugetlb
pmd invalid, between here...

> +					spte = NULL;
> +					continue;
> +				}

... and here?

> +				get_page(spte_page);
>   				break;
>   			}

I think need to take the refcount before checking whether
the hugetlb pmd is still valid.

Also, disregard my previous email in this thread, I just
read Mel's detailed explanation and wrapped my brain
around the bug :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
