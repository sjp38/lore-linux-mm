Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7C90B6B00C8
	for <linux-mm@kvack.org>; Mon, 18 May 2015 11:35:20 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so74267536wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 08:35:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa5si16151213wjc.199.2015.05.18.08.35.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 18 May 2015 08:35:19 -0700 (PDT)
Message-ID: <555A06B4.2000706@suse.cz>
Date: Mon, 18 May 2015 17:35:16 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 20/28] mm: differentiate page_mapped() from page_mapcount()
 for compound pages
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-21-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> Let's define page_mapped() to be true for compound pages if any
> sub-pages of the compound page is mapped (with PMD or PTE).
>
> On other hand page_mapcount() return mapcount for this particular small
> page.
>
> This will make cases like page_get_anon_vma() behave correctly once we
> allow huge pages to be mapped with PTE.
>
> Most users outside core-mm should use page_mapcount() instead of
> page_mapped().

Does "should" mean that they do that now, or just that you would like 
them to? Should there be a warning before the function then?

>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -909,7 +909,16 @@ static inline pgoff_t page_file_index(struct page *page)

(not shown in the diff)

  * Return true if this page is mapped into pagetables.
>    */

Expand the comment? Especially if you put compound_head() there.

>   static inline int page_mapped(struct page *page)

Convert to proper bool while at it?

>   {
> -	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
> +	int i;
> +	if (likely(!PageCompound(page)))
> +		return atomic_read(&page->_mapcount) >= 0;
> +	if (compound_mapcount(page))
> +		return 1;
> +	for (i = 0; i < hpage_nr_pages(page); i++) {
> +		if (atomic_read(&page[i]._mapcount) >= 0)
> +			return 1;
> +	}
> +	return 0;
>   }
>
>   /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
