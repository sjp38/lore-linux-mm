Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4027F6B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 15:03:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v19-v6so2355926eds.3
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:03:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8-v6si3779041edj.379.2018.06.28.12.03.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 12:03:38 -0700 (PDT)
Date: Thu, 28 Jun 2018 13:21:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: hugetlb: yield when prepping struct pages
Message-ID: <20180628112139.GC32348@dhcp22.suse.cz>
References: <20180627214447.260804-1-cannonmatthews@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627214447.260804-1-cannonmatthews@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, gthelen@google.com

On Wed 27-06-18 14:44:47, Cannon Matthews wrote:
> When booting with very large numbers of gigantic (i.e. 1G) pages, the
> operations in the loop of gather_bootmem_prealloc, and specifically
> prep_compound_gigantic_page, takes a very long time, and can cause a
> softlockup if enough pages are requested at boot.
> 
> For example booting with 3844 1G pages requires prepping
> (set_compound_head, init the count) over 1 billion 4K tail pages, which
> takes considerable time. This should also apply to reserving the same
> amount of memory as 2M pages, as the same number of struct pages
> are affected in either case.
> 
> Add a cond_resched() to the outer loop in gather_bootmem_prealloc() to
> prevent this lockup.
> 
> Tested: Booted with softlockup_panic=1 hugepagesz=1G hugepages=3844 and
> no softlockup is reported, and the hugepages are reported as
> successfully setup.
> 
> Signed-off-by: Cannon Matthews <cannonmatthews@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/hugetlb.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a963f2034dfc..d38273c32d3b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2169,6 +2169,7 @@ static void __init gather_bootmem_prealloc(void)
>  		 */
>  		if (hstate_is_gigantic(h))
>  			adjust_managed_page_count(page, 1 << h->order);
> +		cond_resched();
>  	}
>  }
>  
> -- 
> 2.18.0.rc2.346.g013aa6912e-goog

-- 
Michal Hocko
SUSE Labs
