Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E572828FF
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 03:18:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 4so40463493wmz.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 00:18:08 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id k2si6445285wjs.220.2016.06.14.00.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 00:18:06 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id k184so19988006wme.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 00:18:06 -0700 (PDT)
Date: Tue, 14 Jun 2016 09:18:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm, thp: convert from optimistic to conservative
Message-ID: <20160614071804.GD5681@dhcp22.suse.cz>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
 <1465672561-29608-3-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465672561-29608-3-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Sat 11-06-16 22:16:00, Ebru Akagunduz wrote:
> Currently, khugepaged collapses pages saying only
> a referenced page enough to create a THP.
> 
> This patch changes the design from optimistic to conservative.
> It gives a default threshold which is half of HPAGE_PMD_NR
> for referenced pages, also introduces a new sysfs knob.

I am not really happy about yet another tunable khugepaged_max_ptes_none
is too specific already. We do not want to have one knob per page
bit. Shouldn't we rather make the existing knob more generic to allow
implementation to decide whether young bit or present bit is more
important.

> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> ---
>  include/trace/events/huge_memory.h | 10 ++++----
>  mm/khugepaged.c                    | 50 +++++++++++++++++++++++++++++---------
>  2 files changed, 44 insertions(+), 16 deletions(-)
> 
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> index 830d47d..5f14025 100644
> --- a/include/trace/events/huge_memory.h
> +++ b/include/trace/events/huge_memory.h
> @@ -13,7 +13,7 @@
>  	EM( SCAN_EXCEED_NONE_PTE,	"exceed_none_pte")		\
>  	EM( SCAN_PTE_NON_PRESENT,	"pte_non_present")		\
>  	EM( SCAN_PAGE_RO,		"no_writable_page")		\
> -	EM( SCAN_NO_REFERENCED_PAGE,	"no_referenced_page")		\
> +	EM( SCAN_LACK_REFERENCED_PAGE,	"lack_referenced_page")		\
>  	EM( SCAN_PAGE_NULL,		"page_null")			\
>  	EM( SCAN_SCAN_ABORT,		"scan_aborted")			\
>  	EM( SCAN_PAGE_COUNT,		"not_suitable_page_count")	\
> @@ -47,7 +47,7 @@ SCAN_STATUS
>  TRACE_EVENT(mm_khugepaged_scan_pmd,
>  
>  	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
> -		 bool referenced, int none_or_zero, int status, int unmapped),
> +		 int referenced, int none_or_zero, int status, int unmapped),
>  
>  	TP_ARGS(mm, page, writable, referenced, none_or_zero, status, unmapped),
>  
> @@ -55,7 +55,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
>  		__field(struct mm_struct *, mm)
>  		__field(unsigned long, pfn)
>  		__field(bool, writable)
> -		__field(bool, referenced)
> +		__field(int, referenced)
>  		__field(int, none_or_zero)
>  		__field(int, status)
>  		__field(int, unmapped)
> @@ -108,14 +108,14 @@ TRACE_EVENT(mm_collapse_huge_page,
>  TRACE_EVENT(mm_collapse_huge_page_isolate,
>  
>  	TP_PROTO(struct page *page, int none_or_zero,
> -		 bool referenced, bool  writable, int status),
> +		 int referenced, bool  writable, int status),
>  
>  	TP_ARGS(page, none_or_zero, referenced, writable, status),
>  
>  	TP_STRUCT__entry(
>  		__field(unsigned long, pfn)
>  		__field(int, none_or_zero)
> -		__field(bool, referenced)
> +		__field(int, referenced)
>  		__field(bool, writable)
>  		__field(int, status)
>  	),
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index e3d8da7..43fc41e 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -27,7 +27,7 @@ enum scan_result {
>  	SCAN_EXCEED_NONE_PTE,
>  	SCAN_PTE_NON_PRESENT,
>  	SCAN_PAGE_RO,
> -	SCAN_NO_REFERENCED_PAGE,
> +	SCAN_LACK_REFERENCED_PAGE,
>  	SCAN_PAGE_NULL,
>  	SCAN_SCAN_ABORT,
>  	SCAN_PAGE_COUNT,
> @@ -68,6 +68,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>   */
>  static unsigned int khugepaged_max_ptes_none __read_mostly;
>  static unsigned int khugepaged_max_ptes_swap __read_mostly;
> +static unsigned int khugepaged_min_ptes_young __read_mostly;
>  
>  static int khugepaged(void *none);
>  
> @@ -282,6 +283,32 @@ static struct kobj_attribute khugepaged_max_ptes_swap_attr =
>  	__ATTR(max_ptes_swap, 0644, khugepaged_max_ptes_swap_show,
>  	       khugepaged_max_ptes_swap_store);
>  
> +static ssize_t khugepaged_min_ptes_young_show(struct kobject *kobj,
> +					      struct kobj_attribute *attr,
> +					      char *buf)
> +{
> +	return sprintf(buf, "%u\n", khugepaged_min_ptes_young);
> +}
> +
> +static ssize_t khugepaged_min_ptes_young_store(struct kobject *kobj,
> +					       struct kobj_attribute *attr,
> +					       const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long min_ptes_young;
> +	err  = kstrtoul(buf, 10, &min_ptes_young);
> +	if (err || min_ptes_young > HPAGE_PMD_NR-1)
> +		return -EINVAL;
> +
> +	khugepaged_min_ptes_young = min_ptes_young;
> +
> +	return count;
> +}
> +
> +static struct kobj_attribute khugepaged_min_ptes_young_attr =
> +		__ATTR(min_ptes_young, 0644, khugepaged_min_ptes_young_show,
> +		khugepaged_min_ptes_young_store);
> +
>  static struct attribute *khugepaged_attr[] = {
>  	&khugepaged_defrag_attr.attr,
>  	&khugepaged_max_ptes_none_attr.attr,
> @@ -291,6 +318,7 @@ static struct attribute *khugepaged_attr[] = {
>  	&scan_sleep_millisecs_attr.attr,
>  	&alloc_sleep_millisecs_attr.attr,
>  	&khugepaged_max_ptes_swap_attr.attr,
> +	&khugepaged_min_ptes_young_attr.attr,
>  	NULL,
>  };
>  
> @@ -502,8 +530,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  {
>  	struct page *page = NULL;
>  	pte_t *_pte;
> -	int none_or_zero = 0, result = 0;
> -	bool referenced = false, writable = false;
> +	int none_or_zero = 0, result = 0, referenced = 0;
> +	bool writable = false;
>  
>  	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
>  	     _pte++, address += PAGE_SIZE) {
> @@ -582,14 +610,14 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		VM_BUG_ON_PAGE(!PageLocked(page), page);
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
>  
> -		/* If there is no mapped pte young don't collapse the page */
> +		/* There should be enough young pte to collapse the page */
>  		if (pte_young(pteval) ||
>  		    page_is_young(page) || PageReferenced(page) ||
>  		    mmu_notifier_test_young(vma->vm_mm, address))
> -			referenced = true;
> +			referenced++;
>  	}
>  	if (likely(writable)) {
> -		if (likely(referenced)) {
> +		if (referenced >= khugepaged_min_ptes_young) {
>  			result = SCAN_SUCCEED;
>  			trace_mm_collapse_huge_page_isolate(page, none_or_zero,
>  							    referenced, writable, result);
> @@ -1082,11 +1110,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  	pmd_t *pmd;
>  	pte_t *pte, *_pte;
>  	int ret = 0, none_or_zero = 0, result = 0;
> +	int node = NUMA_NO_NODE, unmapped = 0, referenced = 0;
>  	struct page *page = NULL;
>  	unsigned long _address;
>  	spinlock_t *ptl;
> -	int node = NUMA_NO_NODE, unmapped = 0;
> -	bool writable = false, referenced = false;
> +	bool writable = false;
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  
> @@ -1174,14 +1202,14 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  		if (pte_young(pteval) ||
>  		    page_is_young(page) || PageReferenced(page) ||
>  		    mmu_notifier_test_young(vma->vm_mm, address))
> -			referenced = true;
> +			referenced++;
>  	}
>  	if (writable) {
> -		if (referenced) {
> +		if (referenced >= khugepaged_min_ptes_young) {
>  			result = SCAN_SUCCEED;
>  			ret = 1;
>  		} else {
> -			result = SCAN_NO_REFERENCED_PAGE;
> +			result = SCAN_LACK_REFERENCED_PAGE;
>  		}
>  	} else {
>  		result = SCAN_PAGE_RO;
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
