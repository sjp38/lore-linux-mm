Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3A16B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 05:50:07 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so101894428lfg.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:50:07 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id m71si35848213wmb.117.2016.05.31.02.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 02:50:05 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so30897673wmg.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:50:05 -0700 (PDT)
Date: Tue, 31 May 2016 11:50:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][RFC] mm: memcontrol: fix a unbalance uncharged count
Message-ID: <20160531094952.GI26128@dhcp22.suse.cz>
References: <1464687512-10695-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464687512-10695-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roy.qing.li@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com

On Tue 31-05-16 17:38:32, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> I see the number of page of hpage_nr_pages(page) is charged if page is
> transparent huge or hugetlbfs pages; but when uncharge a huge page,

hugetlb pages do not get charged to the memcg. They have their own
hugetlbfscg controller.

> (1<<compound_order) page is uncharged, and maybe hpage_nr_pages(page) is
> not same as 1<<compound_order.

This should never happen. So this is not a fix. I guess it would a clean
up though.

> And remove VM_BUG_ON_PAGE(!PageTransHuge(page), page); since
> PageTransHuge(page) always is true, when this VM_BUG_ON_PAGE is called.

I guess we can drop this BUG_ON because nobody should be be seeing the
page at this stage so we cannot race with a THP split up. But I would
really have to look closer. This would be a patch on its own with the
full explanation though, IMHO.

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  mm/memcontrol.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 12aaadd..28c0137 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5453,8 +5453,7 @@ static void uncharge_list(struct list_head *page_list)
>  		}
>  
>  		if (PageTransHuge(page)) {
> -			nr_pages <<= compound_order(page);
> -			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> +			nr_pages = hpage_nr_pages(page);
>  			nr_huge += nr_pages;
>  		}
>  
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
