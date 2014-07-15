Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 563ED6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:55:51 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id hu12so5709686vcb.0
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:55:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bw1si6951164vcb.18.2014.07.15.08.55.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 08:55:50 -0700 (PDT)
Date: Tue, 15 Jul 2014 11:55:37 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715155537.GA19454@nhori.bos.redhat.com>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jun 18, 2014 at 04:40:45PM -0400, Johannes Weiner wrote:
...
> diff --git a/mm/swap.c b/mm/swap.c
> index a98f48626359..3074210f245d 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -62,6 +62,7 @@ static void __page_cache_release(struct page *page)
>  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	}
> +	mem_cgroup_uncharge(page);
>  }
>  
>  static void __put_single_page(struct page *page)

This seems to cause a list breakage in hstate->hugepage_activelist
when freeing a hugetlbfs page.
For hugetlbfs, we uncharge in free_huge_page() which is called after
__page_cache_release(), so I think that we don't have to uncharge here.

In my testing, moving mem_cgroup_uncharge() inside if (PageLRU) block
fixed the problem, so if that works for you, could you fold the change
into your patch?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
