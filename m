Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2546B0039
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:11:51 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so1123479pdj.40
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:11:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.122])
        by mx.google.com with SMTP id am2si12651780pad.241.2013.11.19.15.11.49
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 15:11:49 -0800 (PST)
Date: Tue, 19 Nov 2013 15:11:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: hugetlbfs: fix hugetlbfs optimization
Message-Id: <20131119151146.a1e1f9073a0e5d35c4e83bab@linux-foundation.org>
In-Reply-To: <1384537668-10283-2-git-send-email-aarcange@redhat.com>
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
	<1384537668-10283-2-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, 15 Nov 2013 18:47:46 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> The patch from commit 7cb2ef56e6a8b7b368b2e883a0a47d02fed66911 can
> cause dereference of a dangling pointer if split_huge_page runs during
> PageHuge() if there are updates to the tail_page->private field.
> 
> Also it is repeating compound_head twice for hugetlbfs and it is
> running compound_head+compound_trans_head for THP when a single one is
> needed in both cases.
> 
> The new code within the PageSlab() check doesn't need to verify that
> the THP page size is never bigger than the smallest hugetlbfs page
> size, to avoid memory corruption.
> 
> A longstanding theoretical race condition was found while fixing the
> above (see the change right after the skip_unlock label, that is
> relevant for the compound_lock path too).
> 
> By re-establishing the _mapcount tail refcounting for all compound
> pages, this also fixes the below problem:
> 
> echo 0 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
> 
> ...
>
> +/*
> + * PageHeadHuge() only returns true for hugetlbfs head page, but not for
> + * normal or transparent huge pages.
> + */
> +int PageHeadHuge(struct page *page_head)
> +{
> +	compound_page_dtor *dtor;
> +
> +	if (!PageHead(page_head))
> +		return 0;
> +
> +	dtor = get_compound_page_dtor(page_head);
> +
> +	return dtor == free_huge_page;
> +}
> +EXPORT_SYMBOL_GPL(PageHeadHuge);

This is all rather verbose.  How about we do this?

--- a/mm/hugetlb.c~mm-hugetlbc-simplify-pageheadhuge-and-pagehuge
+++ a/mm/hugetlb.c
@@ -690,15 +690,11 @@ static void prep_compound_gigantic_page(
  */
 int PageHuge(struct page *page)
 {
-	compound_page_dtor *dtor;
-
 	if (!PageCompound(page))
 		return 0;
 
 	page = compound_head(page);
-	dtor = get_compound_page_dtor(page);
-
-	return dtor == free_huge_page;
+	return get_compound_page_dtor(page) == free_huge_page;
 }
 EXPORT_SYMBOL_GPL(PageHuge);
 
@@ -708,14 +704,10 @@ EXPORT_SYMBOL_GPL(PageHuge);
  */
 int PageHeadHuge(struct page *page_head)
 {
-	compound_page_dtor *dtor;
-
 	if (!PageHead(page_head))
 		return 0;
 
-	dtor = get_compound_page_dtor(page_head);
-
-	return dtor == free_huge_page;
+	return get_compound_page_dtor(page_head) == free_huge_page;
 }
 EXPORT_SYMBOL_GPL(PageHeadHuge);
 
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -82,19 +82,6 @@ static void __put_compound_page(struct page *page)
>  
>  static void put_compound_page(struct page *page)

This function has become quite crazy.  I sat down to refamiliarize but
immediately failed.

: static void put_compound_page(struct page *page)
: {
: 	if (unlikely(PageTail(page))) {
:	...
: 	} else if (put_page_testzero(page)) {
: 		if (PageHead(page))

How can a page be both PageTail() and PageHead()?

: 			__put_compound_page(page);
: 		else
: 			__put_single_page(page);
: 	}
: }
: 
: 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
