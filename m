Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5256B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 08:17:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o14so11042143wrf.6
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 05:17:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x58si6523686edd.371.2017.11.14.05.17.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 05:17:37 -0800 (PST)
Date: Tue, 14 Nov 2017 14:17:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171114131736.v2m6alrt5gelmh5c@dhcp22.suse.cz>
References: <20171114125026.7055-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114125026.7055-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue 14-11-17 12:50:26, Roman Gushchin wrote:
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
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

/proc/meminfo is paved with mistakes throughout the history. It pretends
to give a good picture of the memory usage, yet we have many pointless
entries while large consumers are not reflected at all in many case.

Hugetlb data with that great details shouldn't have been exported in the
first place when they reflect only one specific hugepage size. I would
argue that if somebody went down to configure non-default hugetlb page
sizes then checking for the sysfs stats would be an immediate place to
look at. Anyway I can see that the cumulative information might be
helpful for those who do not own the machine but merely debug an issue
which is the primary usacase for the file.

That being said, I am not rely happy to add more to the file but it is
too late to fix it now. The patch is non-intrusive

Acked-by: Michal Hocko <mhocko@suse.com>

One nit below

> ---
>  mm/hugetlb.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4b3bbd2980bb..1a65f8482282 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2974,6 +2974,8 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
>  void hugetlb_report_meminfo(struct seq_file *m)
>  {
>  	struct hstate *h = &default_hstate;
> +	unsigned long total = 0;
> +
>  	if (!hugepages_supported())
>  		return;
>  	seq_printf(m,
> @@ -2987,6 +2989,11 @@ void hugetlb_report_meminfo(struct seq_file *m)
>  			h->resv_huge_pages,
>  			h->surplus_huge_pages,
>  			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> +
> +	for_each_hstate(h)
> +		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;

Please keep the total calculation consistent with what we have there
already.

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
