Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60D6F6B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 03:01:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so3231606pgn.7
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 00:01:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si218687pli.361.2017.09.15.00.01.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 00:01:06 -0700 (PDT)
Date: Fri, 15 Sep 2017 09:01:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcg: avoid page count check for zone device
Message-ID: <20170915070100.2vuxxxk2zf2yceca@dhcp22.suse.cz>
References: <20170914190011.5217-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170914190011.5217-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 14-09-17 15:00:11, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Fix for 4.14, zone device page always have an elevated refcount
> of one and thus page count sanity check in uncharge_page() is
> inappropriate for them.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Reported-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Side note. Wouldn't it be better to re-organize the check a bit? It is
true that this is VM_BUG so it is not usually compiled in but when it
preferably checks for unlikely cases first while the ref count will be
0 in the prevailing cases. So can we have
	VM_BUG_ON_PAGE(page_count(page) && !is_zone_device_page(page) &&
			!PageHWPoison(page), page);

I would simply fold this nano optimization into the patch as you are
touching it already. Not sure it is worth a separate commit.

> ---
>  mm/memcontrol.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 15af3da5af02..d51d3e1f49c9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5648,7 +5648,8 @@ static void uncharge_batch(const struct uncharge_gather *ug)
>  static void uncharge_page(struct page *page, struct uncharge_gather *ug)
>  {
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
> -	VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
> +	VM_BUG_ON_PAGE(!PageHWPoison(page) && !is_zone_device_page(page) &&
> +			page_count(page), page);
>  
>  	if (!page->mem_cgroup)
>  		return;
> -- 
> 2.13.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
