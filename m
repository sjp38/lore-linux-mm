Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADB426B02E1
	for <linux-mm@kvack.org>; Wed,  3 May 2017 21:21:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 123so5568733pge.14
        for <linux-mm@kvack.org>; Wed, 03 May 2017 18:21:17 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e64si701120pgc.32.2017.05.03.18.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 18:21:16 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id i63so865846pgd.2
        for <linux-mm@kvack.org>; Wed, 03 May 2017 18:21:16 -0700 (PDT)
Message-ID: <1493860869.8082.1.camel@gmail.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 04 May 2017 11:21:09 +1000
In-Reply-To: <20170502185507.GB19165@dhcp22.suse.cz>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
	 <20170427143721.GK4706@dhcp22.suse.cz> <87pofxk20k.fsf@firstfloor.org>
	 <20170428060755.GA8143@dhcp22.suse.cz>
	 <20170428073136.GE8143@dhcp22.suse.cz>
	 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
	 <20170428134831.GB26705@dhcp22.suse.cz>
	 <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
	 <20170502185507.GB19165@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Vladimir Davydov <vdavydov.dev@gmail.com>

> @@ -5527,7 +5527,7 @@ static void uncharge_list(struct list_head *page_list)
>  		next = page->lru.next;
>  
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
> -		VM_BUG_ON_PAGE(page_count(page), page);
> +		VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
>  
>  		if (!page->mem_cgroup)
>  			continue;
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8a6bd3a9eb1e..4497d9619bb4 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -541,6 +541,13 @@ static int delete_from_lru_cache(struct page *p)
>  		 */
>  		ClearPageActive(p);
>  		ClearPageUnevictable(p);
> +
> +		/*
> +		 * Poisoned page might never drop its ref count to 0 so we have to
> +		 * uncharge it manually from its memcg.
> +		 */
> +		mem_cgroup_uncharge(p);
> +

Yep, that is the right fix

https://lkml.org/lkml/2017/4/26/133

Reviewed-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
