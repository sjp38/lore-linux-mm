Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C09326B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 03:26:50 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l6so52214771wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 00:26:50 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id 130si2250021wmj.112.2016.04.06.00.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 00:26:49 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id v188so12612280wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 00:26:49 -0700 (PDT)
Subject: Re: [patch] mm, hugetlb_cgroup: round limit_in_bytes down to hugepage
 size
References: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <5704BA37.2080508@kyup.com>
Date: Wed, 6 Apr 2016 10:26:47 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 04/06/2016 04:25 AM, David Rientjes wrote:
> The page_counter rounds limits down to page size values.  This makes
> sense, except in the case of hugetlb_cgroup where it's not possible to
> charge partial hugepages.
> 
> Round the hugetlb_cgroup limit down to hugepage size.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/hugetlb_cgroup.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -288,6 +288,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
>  
>  	switch (MEMFILE_ATTR(of_cft(of)->private)) {
>  	case RES_LIMIT:
> +		nr_pages &= ~((1 << huge_page_order(&hstates[idx])) - 1);

Why not:

nr_pages = round_down(nr_pages, huge_page_order(&hstates[idx]));


>  		mutex_lock(&hugetlb_limit_mutex);
>  		ret = page_counter_limit(&h_cg->hugepage[idx], nr_pages);
>  		mutex_unlock(&hugetlb_limit_mutex);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
