Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 865776B025E
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 03:54:18 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w95so9683604wrc.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:54:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j61si199029edb.190.2017.11.22.00.54.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 00:54:17 -0800 (PST)
Date: Wed, 22 Nov 2017 09:54:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Message-ID: <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
References: <20171121021855.50525-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171121021855.50525-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Reale <ar@linux.vnet.ibm.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

On Mon 20-11-17 21:18:55, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> In [1], Andrea reported that during memory hotplug/hot remove
> prep_transhuge_page() is called incorrectly on non-THP pages for
> migration, when THP is on but THP migration is not enabled.
> This leads to a bad state of target pages for migration.
> 
> This patch fixes it by only calling prep_transhuge_page() when we are
> certain that the target page is THP.
> 
> [1] https://lkml.org/lkml/2017/11/20/411

lkml.org tends to be quite unstable so a
http://lkml.kernel.org/r/$msg-id is usually a preferred way.

> 
> Cc: stable@vger.kernel.org # v4.14
> Fixes: 8135d8926c08 ("mm: memory_hotplug: memory hotremove supports thp migration")
> Reported-by: Andrea Reale <ar@linux.vnet.ibm.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: "Jerome Glisse" <jglisse@redhat.com>
> ---
>  include/linux/migrate.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 895ec0c4942e..a2246cf670ba 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -54,7 +54,7 @@ static inline struct page *new_page_nodemask(struct page *page,
>  	new_page = __alloc_pages_nodemask(gfp_mask, order,
>  				preferred_nid, nodemask);
>  
> -	if (new_page && PageTransHuge(page))
> +	if (new_page && PageTransHuge(new_page))
>  		prep_transhuge_page(new_page);

I would keep the two checks consistent. But that leads to a more
interesting question. new_page_nodemask does

	if (thp_migration_supported() && PageTransHuge(page)) {
		order = HPAGE_PMD_ORDER;
		gfp_mask |= GFP_TRANSHUGE;
	}

How come it is safe to allocate an order-0 page if
!thp_migration_supported() when we are about to migrate THP? This
doesn't make any sense to me. Are we working around this somewhere else?
Why shouldn't we simply return NULL here?

Nayoa, could you explain please? 8135d8926c08 ("mm: memory_hotplug:
memory hotremove supports thp migration") changelog is less than
satisfactory.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
