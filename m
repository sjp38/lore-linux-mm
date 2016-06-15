Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 053836B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:40:48 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a64so21653430oii.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 23:40:48 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u2si3196794ith.9.2016.06.14.23.40.46
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 23:40:47 -0700 (PDT)
Date: Wed, 15 Jun 2016 15:40:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm, thp: convert from optimistic to conservative
Message-ID: <20160615064053.GH17127@bbox>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
 <1465672561-29608-3-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465672561-29608-3-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

Hello,

On Sat, Jun 11, 2016 at 10:16:00PM +0300, Ebru Akagunduz wrote:
> Currently, khugepaged collapses pages saying only
> a referenced page enough to create a THP.
> 
> This patch changes the design from optimistic to conservative.
> It gives a default threshold which is half of HPAGE_PMD_NR
> for referenced pages, also introduces a new sysfs knob.

Strictly speaking, It's not what I suggested.

I didn't mean that let's change threshold for deciding whether we should
collapse or not(although just *a* reference page seems be too
optimistic) and export the knob to the user. In fact, I cannot judge
whether it's worth or not because I never have an experience with THP
workload in practice although I believe it does make sense.

What I suggested is that a swapin operation would be much heavier than
a THP cost to collapse populated anon page so it should be more
conservative than THP collasping decision, at least. Given that thought,
decision point for collasping a THP is *a* reference page now so *half*
reference of populated pages for reading swapped-out page is more
conservative.

> 
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

We should set it to 1 to preserve old behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
