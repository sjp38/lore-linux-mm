Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83CACC3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 13:17:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37CBD2053B
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 13:17:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37CBD2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE346B0005; Tue,  3 Sep 2019 09:17:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9E9B6B0006; Tue,  3 Sep 2019 09:17:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B54A6B0008; Tue,  3 Sep 2019 09:17:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7C00C6B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 09:17:40 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 28C559063
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 13:17:40 +0000 (UTC)
X-FDA: 75893661480.24.ear43_60051e7295018
X-HE-Tag: ear43_60051e7295018
X-Filterd-Recvd-Size: 3039
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 13:17:39 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 252E0B116;
	Tue,  3 Sep 2019 13:17:38 +0000 (UTC)
Date: Tue, 3 Sep 2019 15:17:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: sunqiuyang <sunqiuyang@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Message-ID: <20190903131737.GB18939@dhcp22.suse.cz>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903082746.20736-1-sunqiuyang@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 16:27:46, sunqiuyang wrote:
> From: Qiuyang Sun <sunqiuyang@huawei.com>
> 
> Currently, after a page is migrated, it
> 1) has its PG_isolated flag cleared in move_to_new_page(), and
> 2) is deleted from its LRU list (cc->migratepages) in unmap_and_move().
> However, between steps 1) and 2), the page could be isolated by another
> thread in isolate_movable_page(), and added to another LRU list, leading
> to list_del corruption later.

Care to explain the race? Both paths use page_lock AFAICS
> 
> This patch fixes the bug by moving list_del into the critical section
> protected by lock_page(), so that a page will not be isolated again before
> it has been deleted from its LRU list.
> 
> Signed-off-by: Qiuyang Sun <sunqiuyang@huawei.com>
> ---
>  mm/migrate.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index a42858d..c58a606 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1124,6 +1124,8 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  	/* Drop an anon_vma reference if we took one */
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
> +	if (rc != -EAGAIN)
> +		list_del(&page->lru);
>  	unlock_page(page);
>  out:
>  	/*
> @@ -1190,6 +1192,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  			put_new_page(newpage, private);
>  		else
>  			put_page(newpage);
> +		list_del(&page->lru);
>  		goto out;
>  	}
>  
> @@ -1200,14 +1203,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  out:
>  	if (rc != -EAGAIN) {
>  		/*
> -		 * A page that has been migrated has all references
> -		 * removed and will be freed. A page that has not been
> -		 * migrated will have kepts its references and be
> -		 * restored.
> -		 */
> -		list_del(&page->lru);
> -
> -		/*
>  		 * Compaction can migrate also non-LRU pages which are
>  		 * not accounted to NR_ISOLATED_*. They can be recognized
>  		 * as __PageMovable
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

