Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7821028025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 04:11:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d15so15185829pfl.0
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 01:11:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l25si589101pfg.389.2017.11.16.01.11.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 01:11:33 -0800 (PST)
Date: Thu, 16 Nov 2017 10:11:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171116091126.rqfvvdqngdbv3l4p@dhcp22.suse.cz>
References: <20171115231409.12131-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115231409.12131-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed 15-11-17 23:14:09, Roman Gushchin wrote:
> Currently we display some hugepage statistics (total, free, etc)
> in /proc/meminfo, but only for default hugepage size (e.g. 2Mb).
> 
> If hugepages of different sizes are used (like 2Mb and 1Gb on x86-64),
> /proc/meminfo output can be confusing, as non-default sized hugepages
> are not reflected at all, and there are no signs that they are
> existing and consuming system memory.
> 
> To solve this problem, let's display the total amount of memory,
> consumed by hugetlb pages of all sized (both free and used).
> Let's call it "Hugetlb", and display size in kB to match generic
> /proc/meminfo style.
> 
> For example, (1024 2Mb pages and 2 1Gb pages are pre-allocated):
>   $ cat /proc/meminfo
>   MemTotal:        8168984 kB
>   MemFree:         3789276 kB
>   <...>
>   CmaFree:               0 kB
>   HugePages_Total:    1024
>   HugePages_Free:     1024
>   HugePages_Rsvd:        0
>   HugePages_Surp:        0
>   Hugepagesize:       2048 kB
>   Hugetlb:         4194304 kB
>   DirectMap4k:       32632 kB
>   DirectMap2M:     4161536 kB
>   DirectMap1G:     6291456 kB
> 
> Also, this patch updates corresponding docs to reflect
> Hugetlb entry meaning and difference between Hugetlb and
> HugePages_Total * Hugepagesize.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  Documentation/vm/hugetlbpage.txt | 27 ++++++++++++++++++---------
>  mm/hugetlb.c                     | 36 ++++++++++++++++++++++++------------
>  2 files changed, 42 insertions(+), 21 deletions(-)
> 
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index 59cbc803aad6..faf077d50d42 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -20,19 +20,20 @@ options.
>  
>  The /proc/meminfo file provides information about the total number of
>  persistent hugetlb pages in the kernel's huge page pool.  It also displays
> -information about the number of free, reserved and surplus huge pages and the
> -default huge page size.  The huge page size is needed for generating the
> -proper alignment and size of the arguments to system calls that map huge page
> -regions.
> +default huge page size and information about the number of free, reserved
> +and surplus huge pages in the pool of huge pages of default size.
> +The huge page size is needed for generating the proper alignment and
> +size of the arguments to system calls that map huge page regions.
>  
>  The output of "cat /proc/meminfo" will include lines like:
>  
>  .....
> -HugePages_Total: vvv
> -HugePages_Free:  www
> -HugePages_Rsvd:  xxx
> -HugePages_Surp:  yyy
> -Hugepagesize:    zzz kB
> +HugePages_Total: uuu
> +HugePages_Free:  vvv
> +HugePages_Rsvd:  www
> +HugePages_Surp:  xxx
> +Hugepagesize:    yyy kB
> +Hugetlb:         zzz kB
>  
>  where:
>  HugePages_Total is the size of the pool of huge pages.
> @@ -47,6 +48,14 @@ HugePages_Surp  is short for "surplus," and is the number of huge pages in
>                  the pool above the value in /proc/sys/vm/nr_hugepages. The
>                  maximum number of surplus huge pages is controlled by
>                  /proc/sys/vm/nr_overcommit_hugepages.
> +Hugepagesize    is the default hugepage size (in Kb).
> +Hugetlb         is the total amount of memory (in kB), consumed by huge
> +                pages of all sizes.
> +                If huge pages of different sizes are in use, this number
> +                will exceed HugePages_Total * Hugepagesize. To get more
> +                detailed information, please, refer to
> +                /sys/kernel/mm/hugepages (described below).
> +
>  
>  /proc/filesystems should also show a filesystem of type "hugetlbfs" configured
>  in the kernel.
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4b3bbd2980bb..672377e6de9f 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2973,20 +2973,32 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
>  
>  void hugetlb_report_meminfo(struct seq_file *m)
>  {
> -	struct hstate *h = &default_hstate;
> +	struct hstate *h;
> +	unsigned long total = 0;
> +
>  	if (!hugepages_supported())
>  		return;
> -	seq_printf(m,
> -			"HugePages_Total:   %5lu\n"
> -			"HugePages_Free:    %5lu\n"
> -			"HugePages_Rsvd:    %5lu\n"
> -			"HugePages_Surp:    %5lu\n"
> -			"Hugepagesize:   %8lu kB\n",
> -			h->nr_huge_pages,
> -			h->free_huge_pages,
> -			h->resv_huge_pages,
> -			h->surplus_huge_pages,
> -			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> +
> +	for_each_hstate(h) {
> +		unsigned long count = h->nr_huge_pages;
> +
> +		total += (PAGE_SIZE << huge_page_order(h)) * count;
> +
> +		if (h == &default_hstate)
> +			seq_printf(m,
> +				   "HugePages_Total:   %5lu\n"
> +				   "HugePages_Free:    %5lu\n"
> +				   "HugePages_Rsvd:    %5lu\n"
> +				   "HugePages_Surp:    %5lu\n"
> +				   "Hugepagesize:   %8lu kB\n",
> +				   count,
> +				   h->free_huge_pages,
> +				   h->resv_huge_pages,
> +				   h->surplus_huge_pages,
> +				   (PAGE_SIZE << huge_page_order(h)) / 1024);
> +	}
> +
> +	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
>  }
>  
>  int hugetlb_report_node_meminfo(int nid, char *buf)
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
