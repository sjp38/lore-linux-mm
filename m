Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 39D236B005C
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 23:56:10 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so421056pad.35
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 20:56:09 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id xv10si255243pab.261.2014.04.07.19.01.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 19:01:33 -0700 (PDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9F7A33EE1E1
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:31 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 88B7945DEBF
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.nic.fujitsu.com [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6053945DEB9
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 48D731DB8043
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:31 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E30E01DB803F
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:30 +0900 (JST)
Message-ID: <53435848.1050601@jp.fujitsu.com>
Date: Tue, 8 Apr 2014 11:00:40 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] hugetlb: add hstate_is_gigantic()
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com> <1396462128-32626-2-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1396462128-32626-2-git-send-email-lcapitulino@redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, yinghai@kernel.org, riel@redhat.com

(2014/04/03 3:08), Luiz Capitulino wrote:
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   include/linux/hugetlb.h |  5 +++++
>   mm/hugetlb.c            | 28 ++++++++++++++--------------
>   2 files changed, 19 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 8c43cc4..8590134 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -333,6 +333,11 @@ static inline unsigned huge_page_shift(struct hstate *h)
>   	return h->order + PAGE_SHIFT;
>   }
>   
> +static inline bool hstate_is_gigantic(struct hstate *h)
> +{
> +	return huge_page_order(h) >= MAX_ORDER;
> +}
> +
>   static inline unsigned int pages_per_huge_page(struct hstate *h)
>   {
>   	return 1 << h->order;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c01cb9f..8c50547 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -574,7 +574,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>   {
>   	int i;
>   
> -	VM_BUG_ON(h->order >= MAX_ORDER);
> +	VM_BUG_ON(hstate_is_gigantic(h));
>   
>   	h->nr_huge_pages--;
>   	h->nr_huge_pages_node[page_to_nid(page)]--;
> @@ -627,7 +627,7 @@ static void free_huge_page(struct page *page)
>   	if (restore_reserve)
>   		h->resv_huge_pages++;
>   
> -	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
> +	if (h->surplus_huge_pages_node[nid] && !hstate_is_gigantic(h)) {
>   		/* remove the page from active list */
>   		list_del(&page->lru);
>   		update_and_free_page(h, page);
> @@ -731,7 +731,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>   {
>   	struct page *page;
>   
> -	if (h->order >= MAX_ORDER)
> +	if (hstate_is_gigantic(h))
>   		return NULL;
>   
>   	page = alloc_pages_exact_node(nid,
> @@ -925,7 +925,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>   	struct page *page;
>   	unsigned int r_nid;
>   
> -	if (h->order >= MAX_ORDER)
> +	if (hstate_is_gigantic(h))
>   		return NULL;
>   
>   	/*
> @@ -1118,7 +1118,7 @@ static void return_unused_surplus_pages(struct hstate *h,
>   	h->resv_huge_pages -= unused_resv_pages;
>   
>   	/* Cannot return gigantic pages currently */
> -	if (h->order >= MAX_ORDER)
> +	if (hstate_is_gigantic(h))
>   		return;
>   
>   	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
> @@ -1328,7 +1328,7 @@ static void __init gather_bootmem_prealloc(void)
>   		 * fix confusing memory reports from free(1) and another
>   		 * side-effects, like CommitLimit going negative.
>   		 */
> -		if (h->order > (MAX_ORDER - 1))
> +		if (hstate_is_gigantic(h))
>   			adjust_managed_page_count(page, 1 << h->order);
>   	}
>   }
> @@ -1338,7 +1338,7 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
>   	unsigned long i;
>   
>   	for (i = 0; i < h->max_huge_pages; ++i) {
> -		if (h->order >= MAX_ORDER) {
> +		if (hstate_is_gigantic(h)) {
>   			if (!alloc_bootmem_huge_page(h))
>   				break;
>   		} else if (!alloc_fresh_huge_page(h,
> @@ -1354,7 +1354,7 @@ static void __init hugetlb_init_hstates(void)
>   
>   	for_each_hstate(h) {
>   		/* oversize hugepages were init'ed in early boot */
> -		if (h->order < MAX_ORDER)
> +		if (!hstate_is_gigantic(h))
>   			hugetlb_hstate_alloc_pages(h);
>   	}
>   }
> @@ -1388,7 +1388,7 @@ static void try_to_free_low(struct hstate *h, unsigned long count,
>   {
>   	int i;
>   
> -	if (h->order >= MAX_ORDER)
> +	if (hstate_is_gigantic(h))
>   		return;
>   
>   	for_each_node_mask(i, *nodes_allowed) {
> @@ -1451,7 +1451,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>   {
>   	unsigned long min_count, ret;
>   
> -	if (h->order >= MAX_ORDER)
> +	if (hstate_is_gigantic(h))
>   		return h->max_huge_pages;
>   
>   	/*
> @@ -1577,7 +1577,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>   		goto out;
>   
>   	h = kobj_to_hstate(kobj, &nid);
> -	if (h->order >= MAX_ORDER) {
> +	if (hstate_is_gigantic(h)) {
>   		err = -EINVAL;
>   		goto out;
>   	}
> @@ -1660,7 +1660,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
>   	unsigned long input;
>   	struct hstate *h = kobj_to_hstate(kobj, NULL);
>   
> -	if (h->order >= MAX_ORDER)
> +	if (hstate_is_gigantic(h))
>   		return -EINVAL;
>   
>   	err = kstrtoul(buf, 10, &input);
> @@ -2071,7 +2071,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>   
>   	tmp = h->max_huge_pages;
>   
> -	if (write && h->order >= MAX_ORDER)
> +	if (write && hstate_is_gigantic(h))
>   		return -EINVAL;
>   
>   	table->data = &tmp;
> @@ -2124,7 +2124,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
>   
>   	tmp = h->nr_overcommit_huge_pages;
>   
> -	if (write && h->order >= MAX_ORDER)
> +	if (write && hstate_is_gigantic(h))
>   		return -EINVAL;
>   
>   	table->data = &tmp;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
