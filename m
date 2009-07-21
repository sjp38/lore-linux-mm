Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A01546B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 13:51:40 -0400 (EDT)
Date: Tue, 21 Jul 2009 19:51:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
Message-ID: <20090721175139.GE2239@random.random>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247851850-4298-7-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 17, 2009 at 08:30:46PM +0300, Izik Eidus wrote:
> +static inline int PageKsm(struct page *page)
> +{
> +	return ((unsigned long)page->mapping == PAGE_MAPPING_ANON);
> +}

I'm unconvinced it's sane to have PageAnon return 1 on Ksm pages.

The above will also have short lifetime so not sure it's worth it,
if we want to swap we'll have to move to something that to:

PageExternal()
{
	return (unsigned long)page->mapping & PAGE_MAPPING_EXTERNAL != 0;
}

> +static inline void page_add_ksm_rmap(struct page *page)
> +{
> +	if (atomic_inc_and_test(&page->_mapcount)) {
> +		page->mapping = (void *) PAGE_MAPPING_ANON;
> +		__inc_zone_page_state(page, NR_ANON_PAGES);
> +	}
> +}

Is it correct to account them as anon pages?

> -	if (PageAnon(old_page)) {
> +	if (PageAnon(old_page) && !PageKsm(old_page)) {
>  		if (!trylock_page(old_page)) {
>  			page_cache_get(old_page);
>  			pte_unmap_unlock(page_table, ptl);

What exactly does it buy to have PageAnon return 1 on ksm pages,
besides requiring the above additional check (that if we stick to the
above code, I would find safer to move inside reuse_swap_page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
