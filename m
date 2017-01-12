Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7D8C6B0261
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:21:53 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d140so5990069wmd.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:21:53 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 32si7683453wrx.326.2017.01.12.08.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:21:52 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CGJWlS007205
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:21:50 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 27xaca82fr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:21:50 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 12 Jan 2017 09:21:48 -0700
Subject: Re: [PATCH v1 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
References: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Thu, 12 Jan 2017 17:21:42 +0100
MIME-Version: 1.0
In-Reply-To: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Message-Id: <1ba9984d-aef5-0d49-4a9b-28e38a9a84de@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: hughd@google.com, izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On 01/12/2017 05:17 PM, Claudio Imbrenda wrote:
> Some architectures have a set of zero pages (coloured zero pages)
> instead of only one zero page, in order to improve the cache
> performance. In those cases, the kernel samepage merger (KSM) would
> merge all the allocated pages that happen to be filled with zeroes to
> the same deduplicated page, thus losing all the advantages of coloured
> zero pages.
> 
> This patch fixes this behaviour. When coloured zero pages are present,
> the checksum of a zero page is calculated during initialisation, and
> compared with the checksum of the current canditate during merging. In
> case of a match, the normal merging routine is used to merge the page
> with the correct coloured zero page, which ensures the candidate page
> is checked to be equal to the target zero page.
> 
> This behaviour is noticeable when a process accesses large arrays of
> allocated pages containing zeroes. A test I conducted on s390 shows
> that there is a speed penalty when KSM merges such pages, compared to
> not merging them or using actual zero pages from the start without
> breaking the COW.
> 
> With this patch, the performance with KSM is the same as with non
> COW-broken actual zero pages, which is also the same as without KSM.
> 
> Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>

FWIW, I cannot say if the memory management part is correct and sane. (the
patch below). But this issue (loosing the cache colouring for the zero 
page) is certainly a reason to not use KSM on s390 for specific workloads
(large sparsely matrixes backed by the guest empty zero page).

This patch will fix that.


> ---
>  mm/ksm.c | 29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 9ae6011..b0cfc30 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -223,6 +223,11 @@ struct rmap_item {
>  /* Milliseconds ksmd should sleep between batches */
>  static unsigned int ksm_thread_sleep_millisecs = 20;
> 
> +#ifdef __HAVE_COLOR_ZERO_PAGE
> +/* Checksum of an empty (zeroed) page */
> +static unsigned int zero_checksum;
> +#endif
> +
>  #ifdef CONFIG_NUMA
>  /* Zeroed when merging across nodes is not allowed */
>  static unsigned int ksm_merge_across_nodes = 1;
> @@ -1467,6 +1472,25 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  		return;
>  	}
> 
> +#ifdef __HAVE_COLOR_ZERO_PAGE
> +	/*
> +	 * Same checksum as an empty page. We attempt to merge it with the
> +	 * appropriate zero page.
> +	 */
> +	if (checksum == zero_checksum) {
> +		struct vm_area_struct *vma;
> +
> +		vma = find_mergeable_vma(rmap_item->mm, rmap_item->address);
> +		err = try_to_merge_one_page(vma, page,
> +					    ZERO_PAGE(rmap_item->address));
> +		/*
> +		 * In case of failure, the page was not really empty, so we
> +		 * need to continue. Otherwise we're done.
> +		 */
> +		if (!err)
> +			return;
> +	}
> +#endif
>  	tree_rmap_item =
>  		unstable_tree_search_insert(rmap_item, page, &tree_page);
>  	if (tree_rmap_item) {
> @@ -2304,6 +2328,11 @@ static int __init ksm_init(void)
>  	struct task_struct *ksm_thread;
>  	int err;
> 
> +#ifdef __HAVE_COLOR_ZERO_PAGE
> +	/* The correct value depends on page size and endianness */
> +	zero_checksum = calc_checksum(ZERO_PAGE(0));
> +#endif
> +
>  	err = ksm_slab_init();
>  	if (err)
>  		goto out;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
