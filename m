Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 41A956B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 17:07:48 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so81121966wid.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 14:07:47 -0700 (PDT)
Received: from johanna1.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id oo2si32032858wjc.190.2015.07.13.14.07.45
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 14:07:46 -0700 (PDT)
Date: Tue, 14 Jul 2015 00:06:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 1/3] mm: add tracepoint for scanning pages
Message-ID: <20150713210646.GA1427@node.dhcp.inet.fi>
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
 <1436819284-3964-2-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436819284-3964-2-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, Jul 13, 2015 at 11:28:02PM +0300, Ebru Akagunduz wrote:
> Using static tracepoints, data of functions is recorded.
> It is good to automatize debugging without doing a lot
> of changes in the source code.
> 
> This patch adds tracepoint for khugepaged_scan_pmd,
> collapse_huge_page and __collapse_huge_page_isolate.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> Changes in v2:
>  - Nothing changed
> 
> Changes in v3:
>  - Print page address instead of vm_start (Vlastimil Babka)
>  - Define constants to specify exact tracepoint result (Vlastimil Babka)
>  
> 
>  include/linux/mm.h                 |  18 ++++++
>  include/trace/events/huge_memory.h | 100 ++++++++++++++++++++++++++++++++
>  mm/huge_memory.c                   | 114 +++++++++++++++++++++++++++----------
>  3 files changed, 203 insertions(+), 29 deletions(-)
>  create mode 100644 include/trace/events/huge_memory.h
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7f47178..bf341c0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -21,6 +21,24 @@
>  #include <linux/resource.h>
>  #include <linux/page_ext.h>
>  
> +#define MM_PMD_NULL		0
> +#define MM_EXCEED_NONE_PTE	3
> +#define MM_PTE_NON_PRESENT	4
> +#define MM_PAGE_NULL		5
> +#define MM_SCAN_ABORT		6
> +#define MM_PAGE_COUNT		7
> +#define MM_PAGE_LRU		8
> +#define MM_ANY_PROCESS		0
> +#define MM_VMA_NULL		2
> +#define MM_VMA_CHECK		3
> +#define MM_ADDRESS_RANGE	4
> +#define MM_PAGE_LOCK		2
> +#define MM_SWAP_CACHE_PAGE	6
> +#define MM_ISOLATE_LRU_PAGE	7
> +#define MM_ALLOC_HUGE_PAGE_FAIL	6
> +#define MM_CGROUP_CHARGE_FAIL	7
> +#define MM_COLLAPSE_ISOLATE_FAIL 5
> +

These magic numbers looks very random. What's logic behind?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
