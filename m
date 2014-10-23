Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BF99E6B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 20:19:36 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so4509163pdb.16
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 17:19:36 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id y15si217484pdj.67.2014.10.22.17.19.34
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 17:19:35 -0700 (PDT)
Message-ID: <54484993.1090803@lge.com>
Date: Thu, 23 Oct 2014 09:19:31 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com> <1413986796-19732-1-git-send-email-pintu.k@samsung.com> <1413986796-19732-2-git-send-email-pintu.k@samsung.com>
In-Reply-To: <1413986796-19732-2-git-send-email-pintu.k@samsung.com>
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>, akpm@linux-foundation.org, riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, lauraa@codeaurora.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com



2014-10-22 ?AEA 11:06, Pintu Kumar  3/4 ' +-U:
> This patch include CMA info (CMATotal, CMAFree) in /proc/meminfo.
> Currently, in a CMA enabled system, if somebody wants to know the
> total CMA size declared, there is no way to tell, other than the dmesg
> or /var/log/messages logs.
> With this patch we are showing the CMA info as part of meminfo, so that
> it can be determined at any point of time.
> This will be populated only when CMA is enabled.
> 
> Below is the sample output from a ARM based device with RAM:512MB and CMA:16MB.
> 
> MemTotal:         471172 kB
> MemFree:          111712 kB
> MemAvailable:     271172 kB
> .
> .
> .
> CmaTotal:          16384 kB
> CmaFree:            6144 kB
> 
> This patch also fix below checkpatch errors that were found during these changes.

Why don't you split patch for it?
I think there's a rule not to mix separate patchs.

> 
> ERROR: space required after that ',' (ctx:ExV)
> 199: FILE: fs/proc/meminfo.c:199:
> +       ,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
>          ^
> 
> ERROR: space required after that ',' (ctx:ExV)
> 202: FILE: fs/proc/meminfo.c:202:
> +       ,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>          ^
> 
> ERROR: space required after that ',' (ctx:ExV)
> 206: FILE: fs/proc/meminfo.c:206:
> +       ,K(totalcma_pages)
>          ^
> 
> total: 3 errors, 0 warnings, 2 checks, 236 lines checked
> 
> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>
> ---
>   fs/proc/meminfo.c |   15 +++++++++++++--
>   1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index aa1eee0..d3ebf2e 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -12,6 +12,9 @@
>   #include <linux/vmstat.h>
>   #include <linux/atomic.h>
>   #include <linux/vmalloc.h>
> +#ifdef CONFIG_CMA
> +#include <linux/cma.h>
> +#endif
>   #include <asm/page.h>
>   #include <asm/pgtable.h>
>   #include "internal.h"
> @@ -138,6 +141,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>   		"AnonHugePages:  %8lu kB\n"
>   #endif
> +#ifdef CONFIG_CMA
> +		"CmaTotal:       %8lu kB\n"
> +		"CmaFree:        %8lu kB\n"
> +#endif
>   		,
>   		K(i.totalram),
>   		K(i.freeram),
> @@ -187,12 +194,16 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>   		vmi.used >> 10,
>   		vmi.largest_chunk >> 10
>   #ifdef CONFIG_MEMORY_FAILURE
> -		,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
> +		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
>   #endif
>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
> +		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>   		   HPAGE_PMD_NR)
>   #endif
> +#ifdef CONFIG_CMA
> +		, K(totalcma_pages)
> +		, K(global_page_state(NR_FREE_CMA_PAGES))
> +#endif
>   		);

Just for sure, are zoneinfo and pagetypeinfo not suitable?

I don't know HOTPLUG feature so I'm just asking for sure.
Does HOTPLUG not need printing message like this?

Thanks a lot.

>   
>   	hugetlb_report_meminfo(m);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
