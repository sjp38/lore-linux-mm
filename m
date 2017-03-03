Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3176B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 06:45:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so123800980pgi.7
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 03:45:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w187si9193832pgb.130.2017.03.03.03.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 03:45:36 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v23BjR31001268
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 06:45:36 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xs8ekmeg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Mar 2017 06:45:31 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 21:45:00 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 5135A3578053
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 22:44:59 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v23Biphm40501380
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 22:44:59 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v23BiQdQ030006
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 22:44:26 +1100
Subject: Re: [RFC 05/11] mm: make the try_to_munlock void function
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-6-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 3 Mar 2017 17:13:54 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-6-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <98488e1a-0202-b88b-ca9c-1dc0d6c27ae5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
> the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
> the page if the page is not pte-mapped THP which cannot be
> mlocked, either.

Right.

> 
> With that, __munlock_isolated_page can use PageMlocked to check
> whether try_to_munlock is successful or not without relying on
> try_to_munlock's retval. It helps to make ttu/ttuo simple with
> upcoming patches.

Right.

> 
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/rmap.h |  2 +-
>  mm/mlock.c           |  6 ++----
>  mm/rmap.c            | 16 ++++------------
>  3 files changed, 7 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index b556eef..1b0cd4c 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -235,7 +235,7 @@ int page_mkclean(struct page *);
>   * called in munlock()/munmap() path to check for other vmas holding
>   * the page mlocked.
>   */
> -int try_to_munlock(struct page *);
> +void try_to_munlock(struct page *);
>  
>  void remove_migration_ptes(struct page *old, struct page *new, bool locked);
>  
> diff --git a/mm/mlock.c b/mm/mlock.c
> index cdbed8a..d34a540 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -122,17 +122,15 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
>   */
>  static void __munlock_isolated_page(struct page *page)
>  {
> -	int ret = SWAP_AGAIN;
> -
>  	/*
>  	 * Optimization: if the page was mapped just once, that's our mapping
>  	 * and we don't need to check all the other vmas.
>  	 */
>  	if (page_mapcount(page) > 1)
> -		ret = try_to_munlock(page);
> +		try_to_munlock(page);
>  
>  	/* Did try_to_unlock() succeed or punt? */
> -	if (ret != SWAP_MLOCK)
> +	if (!PageMlocked(page))

Checks if the page is still mlocked or not.

>  		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
>  
>  	putback_lru_page(page);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0a48958..61ae694 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1540,18 +1540,10 @@ static int page_not_mapped(struct page *page)
>   * Called from munlock code.  Checks all of the VMAs mapping the page
>   * to make sure nobody else has this page mlocked. The page will be
>   * returned with PG_mlocked cleared if no other vmas have it mlocked.
> - *
> - * Return values are:
> - *
> - * SWAP_AGAIN	- no vma is holding page mlocked, or,
> - * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
> - * SWAP_FAIL	- page cannot be located at present
> - * SWAP_MLOCK	- page is now mlocked.
>   */
> -int try_to_munlock(struct page *page)
> -{
> -	int ret;
>  
> +void try_to_munlock(struct page *page)
> +{
>  	struct rmap_walk_control rwc = {
>  		.rmap_one = try_to_unmap_one,
>  		.arg = (void *)TTU_MUNLOCK,
> @@ -1561,9 +1553,9 @@ int try_to_munlock(struct page *page)
>  	};
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
> +	VM_BUG_ON_PAGE(PageMlocked(page), page);

We are calling on the page to see if its mlocked from any of it's
mapping VMAs. Then it is a possibility that the page is mlocked
and the above condition is true and we print VM BUG report there.
The point is if its a valid possibility why we have added the
above check ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
