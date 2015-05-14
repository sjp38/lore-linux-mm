Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC486B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 12:07:52 -0400 (EDT)
Received: by wizk4 with SMTP id k4so247412226wiz.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 09:07:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ck4si15160276wib.31.2015.05.14.09.07.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 09:07:50 -0700 (PDT)
Message-ID: <5554C854.6020900@suse.cz>
Date: Thu, 14 May 2015 18:07:48 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 02/28] rmap: add argument to charge compound page
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound
> page. It means we cannot rely on PageTransHuge() check to decide if
> map/unmap small page or THP.
>
> The patch adds new argument to rmap functions to indicate whether we want
> to operate on whole compound page or only the small page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But I wonder about one thing:

> -void page_remove_rmap(struct page *page)
> +void page_remove_rmap(struct page *page, bool compound)
>   {
> +	int nr = compound ? hpage_nr_pages(page) : 1;
> +
>   	if (!PageAnon(page)) {
> +		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
>   		page_remove_file_rmap(page);
>   		return;
>   	}

The function continues by:

         /* page still mapped by someone else? */
         if (!atomic_add_negative(-1, &page->_mapcount))
                 return;

         /* Hugepages are not counted in NR_ANON_PAGES for now. */
         if (unlikely(PageHuge(page)))
                 return;

The handling of compound parameter for PageHuge() pages feels just 
weird. You use hpage_nr_pages() for them which tests PageTransHuge(). It 
doesn't break anything and the value of nr is effectively ignored 
anyway, but still...

So I wonder, if all callers of page_remove_rmap() for PageHuge() pages 
are the two in mm/hugetlb.c, why not just create a special case 
function? Or are some callers elsewhere, not aware whether they are 
calling this on a PageHuge()? So compound might be even false for those? 
If that's all possible and legal, then maybe explain it in a comment to 
reduce confusion of further readers. And move the 'nr' assignment to a 
place where we are sure it's not a PageHuge(), i.e. right above the 
place the value is used, perhaps?


> @@ -1181,11 +1191,12 @@ void page_remove_rmap(struct page *page)
>   	 * these counters are not modified in interrupt context, and
>   	 * pte lock(a spinlock) is held, which implies preemption disabled.
>   	 */
> -	if (PageTransHuge(page))
> +	if (compound) {
> +		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>   		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> +	}
>
> -	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
> -			      -hpage_nr_pages(page));
> +	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
>
>   	if (unlikely(PageMlocked(page)))
>   		clear_page_mlock(page);
> @@ -1327,7 +1338,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>   		dec_mm_counter(mm, MM_FILEPAGES);
>
>   discard:
> -	page_remove_rmap(page);
> +	page_remove_rmap(page, false);
>   	page_cache_release(page);
>
>   out_unmap:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
