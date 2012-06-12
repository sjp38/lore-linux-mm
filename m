Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 001076B005C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 03:33:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1543C3EE0C2
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:33:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C2ED45DE54
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:33:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8202245DE59
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:33:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E7D51DB8053
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:33:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14AAF1DB804B
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:33:45 +0900 (JST)
Message-ID: <4FD6F05D.5010404@jp.fujitsu.com>
Date: Tue, 12 Jun 2012 16:31:41 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V8 06/16] hugetlb: simplify migrate_huge_page()
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339232401-14392-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/06/09 17:59), Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> 
> Since we migrate only one hugepage don't use linked list for passing the
> page around.  Directly pass page that need to be migrated as argument.
> This also remove the usage page->lru in migrate path.
> 
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>   include/linux/migrate.h |    4 +--
>   mm/memory-failure.c     |   13 ++--------
>   mm/migrate.c            |   65 +++++++++++++++--------------------------------
>   3 files changed, 25 insertions(+), 57 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 855c337..ce7e667 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -15,7 +15,7 @@ extern int migrate_page(struct address_space *,
>   extern int migrate_pages(struct list_head *l, new_page_t x,
>   			unsigned long private, bool offlining,
>   			enum migrate_mode mode);
> -extern int migrate_huge_pages(struct list_head *l, new_page_t x,
> +extern int migrate_huge_page(struct page *, new_page_t x,
>   			unsigned long private, bool offlining,
>   			enum migrate_mode mode);
> 
> @@ -36,7 +36,7 @@ static inline void putback_lru_pages(struct list_head *l) {}
>   static inline int migrate_pages(struct list_head *l, new_page_t x,
>   		unsigned long private, bool offlining,
>   		enum migrate_mode mode) { return -ENOSYS; }
> -static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
> +static inline int migrate_huge_page(struct page *page, new_page_t x,
>   		unsigned long private, bool offlining,
>   		enum migrate_mode mode) { return -ENOSYS; }
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index ab1e714..53a1495 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1414,7 +1414,6 @@ static int soft_offline_huge_page(struct page *page, int flags)
>   	int ret;
>   	unsigned long pfn = page_to_pfn(page);
>   	struct page *hpage = compound_head(page);
> -	LIST_HEAD(pagelist);
> 
>   	ret = get_any_page(page, pfn, flags);
>   	if (ret<  0)
> @@ -1429,19 +1428,11 @@ static int soft_offline_huge_page(struct page *page, int flags)
>   	}
> 
>   	/* Keep page count to indicate a given hugepage is isolated. */
> -
> -	list_add(&hpage->lru,&pagelist);
> -	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0,
> -				true);
> +	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, 0, true);
> +	put_page(hpage);
>   	if (ret) {
> -		struct page *page1, *page2;
> -		list_for_each_entry_safe(page1, page2,&pagelist, lru)
> -			put_page(page1);
> -
>   		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>   			pfn, ret, page->flags);
> -		if (ret>  0)
> -			ret = -EIO;
>   		return ret;
>   	}
>   done:
> diff --git a/mm/migrate.c b/mm/migrate.c
> index be26d5c..fdce3a2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -932,15 +932,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>   	if (anon_vma)
>   		put_anon_vma(anon_vma);
>   	unlock_page(hpage);
> -
>   out:
> -	if (rc != -EAGAIN) {
> -		list_del(&hpage->lru);
> -		put_page(hpage);
> -	}
> -
>   	put_page(new_hpage);
> -
>   	if (result) {
>   		if (rc)
>   			*result = rc;
> @@ -1016,48 +1009,32 @@ out:
>   	return nr_failed + retry;
>   }
> 
> -int migrate_huge_pages(struct list_head *from,
> -		new_page_t get_new_page, unsigned long private, bool offlining,
> -		enum migrate_mode mode)
> +int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
> +		      unsigned long private, bool offlining,
> +		      enum migrate_mode mode)
>   {
> -	int retry = 1;
> -	int nr_failed = 0;
> -	int pass = 0;
> -	struct page *page;
> -	struct page *page2;
> -	int rc;
> -
> -	for (pass = 0; pass<  10&&  retry; pass++) {
> -		retry = 0;
> -
> -		list_for_each_entry_safe(page, page2, from, lru) {
> +	int pass, rc;
> +
> +	for (pass = 0; pass<  10; pass++) {
> +		rc = unmap_and_move_huge_page(get_new_page,
> +					      private, hpage, pass>  2, offlining,
> +					      mode);
> +		switch (rc) {
> +		case -ENOMEM:
> +			goto out;
> +		case -EAGAIN:
> +			/* try again */
>   			cond_resched();
> -
> -			rc = unmap_and_move_huge_page(get_new_page,
> -					private, page, pass>  2, offlining,
> -					mode);
> -
> -			switch(rc) {
> -			case -ENOMEM:
> -				goto out;
> -			case -EAGAIN:
> -				retry++;
> -				break;
> -			case 0:
> -				break;
> -			default:
> -				/* Permanent failure */
> -				nr_failed++;
> -				break;
> -			}
> +			break;
> +		case 0:
> +			goto out;
> +		default:
> +			rc = -EIO;
> +			goto out;
>   		}
>   	}
> -	rc = 0;
>   out:
> -	if (rc)
> -		return rc;
> -
> -	return nr_failed + retry;
> +	return rc;
>   }
> 
>   #ifdef CONFIG_NUMA


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
