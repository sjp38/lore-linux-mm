Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69F21C49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 19:23:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 099612168B
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 19:23:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gt1VGbq3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 099612168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C7A46B0005; Tue, 10 Sep 2019 15:23:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9786D6B0006; Tue, 10 Sep 2019 15:23:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83F4C6B0007; Tue, 10 Sep 2019 15:23:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 6252C6B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 15:23:10 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EC978824CA3D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:23:09 +0000 (UTC)
X-FDA: 75919984098.04.flame06_38ad2178d8116
X-HE-Tag: flame06_38ad2178d8116
X-Filterd-Recvd-Size: 5284
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:23:09 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id c17so2473223pgg.4
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:23:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Fubhhbk8mxGQHPIu8VHPq/5qo3lMlhc0PCcFAaxFEGw=;
        b=Gt1VGbq3idOl6Pfrz2txkeuG9O1wiAO53ibNvoeLaHaxro0fJ8rXjlbFedy5/YQNUm
         e4uwdYOTu80BR1VJ1iin45qfQeyExtRvdHZor7SDe6QkMvGtjMDsyfE0yQzFWq84ze5A
         lVC+orwGCh/1CQe24dWiEiGCOmiU0PqQvW1Cft0nrmvA+DYu+sqzqa3HbuU/6bKLNb5D
         mZ8Fg/V3uolNAKmOw3lmSoGNNS/JltnhyxPyuxq8m2D0jnK6ljkx7ewMKSE0UuIZDMrj
         ZORHKfO4D7/PnvRDI1SU0kBdY9gazIsy3pMuV4EvpY80bkGzyrThKyb4AiN5xx8zwarF
         mW0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=Fubhhbk8mxGQHPIu8VHPq/5qo3lMlhc0PCcFAaxFEGw=;
        b=VuSnL9T0Hu1MP77AcVYUdg/8TNG2q24FoVzfblUsOeLJN9WxgdIziFTU2WjlfONo6F
         3FRIExEgIBDX2t0hdBxIzz8J2KYELsPqN6unl3xDzJvdp+TzC0S+EMCBbclWV6KwGzXc
         jP3uNxgFUiEfX/X4XlQZRvLzp4rv4lXSYY19i9QzVU60AwNC36EyVkVK5fveWkxGGm/q
         4pbwXJvZvAe81invm3AeAyakBHkDF1SmYwC3H8W3KKCx58OBhYIPheipcNTvz/ZdJ94f
         7CujJ067hlHLY4qisCpDAbhO0uCMeplSFUEl2O/MyUSGJNeOe6hy1qVI7pF/0F5XlzIV
         HRJw==
X-Gm-Message-State: APjAAAXVJyfLU2qCsm6QXpXGDP6xtFHkCreEW3/051yQ/JKLHMcgSyQy
	81RVtbzZcCJdHK/iFMD8j/k=
X-Google-Smtp-Source: APXvYqwTr7I/0FMR7eX2wqUS4TniGCurKs704j7dqSnY0tcIsHL6uyUViuXQmxjpXx7GquwkQsyA6g==
X-Received: by 2002:a17:90a:d0c3:: with SMTP id y3mr1214847pjw.102.1568143387926;
        Tue, 10 Sep 2019 12:23:07 -0700 (PDT)
Received: from google.com ([2620:15c:211:1:3e01:2939:5992:52da])
        by smtp.gmail.com with ESMTPSA id o9sm14597446pgv.19.2019.09.10.12.23.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Sep 2019 12:23:06 -0700 (PDT)
Date: Tue, 10 Sep 2019 12:23:04 -0700
From: Minchan Kim <minchan@kernel.org>
To: sunqiuyang <sunqiuyang@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Message-ID: <20190910192304.GA220078@google.com>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903082746.20736-1-sunqiuyang@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 04:27:46PM +0800, sunqiuyang wrote:
> From: Qiuyang Sun <sunqiuyang@huawei.com>
> 
> Currently, after a page is migrated, it
> 1) has its PG_isolated flag cleared in move_to_new_page(), and
> 2) is deleted from its LRU list (cc->migratepages) in unmap_and_move().
> However, between steps 1) and 2), the page could be isolated by another
> thread in isolate_movable_page(), and added to another LRU list, leading
> to list_del corruption later.

Once non-LRU page is migrated out successfully, driver should clear
the movable flag in the page. Look at reset_page in zs_page_migrate.
So, other thread couldn't isolate the page during the window.

If I miss something, let me know it.
Thanks.

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
> 
> 

