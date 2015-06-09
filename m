Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id DDB156B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 06:59:56 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so10133223wgb.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 03:59:56 -0700 (PDT)
Received: from johanna3.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id wn9si10739183wjb.52.2015.06.09.03.59.53
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 03:59:54 -0700 (PDT)
Date: Tue, 9 Jun 2015 13:58:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 27/36] mm: differentiate page_mapped() from
 page_mapcount() for compound pages
Message-ID: <20150609105831.GA20336@node.dhcp.inet.fi>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1433351167-125878-28-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433351167-125878-28-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 03, 2015 at 08:05:58PM +0300, Kirill A. Shutemov wrote:
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 22cd540104ec..16add6692f49 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -917,10 +917,21 @@ static inline pgoff_t page_file_index(struct page *page)
>  
>  /*
>   * Return true if this page is mapped into pagetables.
> + * For compound page it returns true if any subpage of compound page is mapped.
>   */
> -static inline int page_mapped(struct page *page)
> +static inline bool page_mapped(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
> +	int i;
> +	if (likely(!PageCompound(page)))
> +		return atomic_read(&page->_mapcount) >= 0;
> +	page = compound_head(page);
> +	if (compound_mapcount(page))
> +		return true;
> +	for (i = 0; i < hpage_nr_pages(page); i++) {
> +		if (atomic_read(&page[i]._mapcount) >= 0)
> +			return true;
> +	}
> +	return true;

Oops. 'false' should be here. Updated patch is below.
