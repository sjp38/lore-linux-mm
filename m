Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFD06B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:02:14 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so1155200eek.21
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:02:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si2504600eei.228.2014.01.09.01.02.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:02:12 -0800 (PST)
Date: Thu, 9 Jan 2014 10:02:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140109090208.GA27538@dhcp22.suse.cz>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
 <20140108101611.GD27937@dhcp22.suse.cz>
 <20140109073259.GK4106@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140109073259.GK4106@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

On Thu 09-01-14 15:32:59, Han Pingtian wrote:
[...]
> From b8db4f157a17d6d8652cc9cff024a192c3ee0779 Mon Sep 17 00:00:00 2001
> From: Han Pingtian <hanpt@linux.vnet.ibm.com>
> Date: Thu, 9 Jan 2014 15:24:26 +0800
> Subject: [PATCH] mm: show message when raising min_free_kbytes in THP
> 
> min_free_kbytes may be raised during THP's initialization. Sometimes,
> this will change the value being set by user. Showing message will
> clarify this confusion.
> 
> Only show this message when changing the value set by user according to
> Michal Hocko's suggestion.
> 
> Showing the old value of min_free_kbytes according to Dave Hansen's
> suggestion. This will give user the chance to restore old value of
> min_free_kbytes.
> 
> Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>

Looks good to me
Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/huge_memory.c |    9 ++++++++-
>  mm/page_alloc.c  |    2 +-
>  2 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7de1bf8..e0e4e29 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -100,6 +100,7 @@ static struct khugepaged_scan khugepaged_scan = {
>  	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
>  };
>  
> +extern int user_min_free_kbytes;
>  
>  static int set_recommended_min_free_kbytes(void)
>  {
> @@ -130,8 +131,14 @@ static int set_recommended_min_free_kbytes(void)
>  			      (unsigned long) nr_free_buffer_pages() / 20);
>  	recommended_min <<= (PAGE_SHIFT-10);
>  
> -	if (recommended_min > min_free_kbytes)
> +	if (recommended_min > min_free_kbytes) {
> +		if (user_min_free_kbytes >= 0)
> +			pr_info("raising min_free_kbytes from %d to %lu "
> +				"to help transparent hugepage allocations\n",
> +				min_free_kbytes, recommended_min);
> +
>  		min_free_kbytes = recommended_min;
> +	}
>  	setup_per_zone_wmarks();
>  	return 0;
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9ea62b2..a9dcfd8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -205,7 +205,7 @@ static char * const zone_names[MAX_NR_ZONES] = {
>  };
>  
>  int min_free_kbytes = 1024;
> -int user_min_free_kbytes;
> +int user_min_free_kbytes = -1;
>  
>  static unsigned long __meminitdata nr_kernel_pages;
>  static unsigned long __meminitdata nr_all_pages;
> -- 
> 1.7.7.6
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
