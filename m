Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D282C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 09:04:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8F392083D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 09:04:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8F392083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E1966B0003; Mon, 24 Jun 2019 05:04:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 594338E0003; Mon, 24 Jun 2019 05:04:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A8A08E0002; Mon, 24 Jun 2019 05:04:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8386B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:04:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s22so4237773qtb.22
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 02:04:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WVy0vpi9Lz2dks4RVhNhqk2jEKnaYPfiE7jBKsvgnnw=;
        b=X1wAIWFpkdV1nH90ro/8RI08k+spmErE8bNvyxNDEkjWnwg6Cbw/msqZZvLbgkv/sr
         6amrRGZVs1wIPB8aop7SNgvTp9CFxnk77WLVNXrjc78NA+8O5B2GMgzulZ1sDB9Fhv76
         nX/kz/Z5012NcF9+pa2QahWKjkstIx3vdvTlbkILzkNF/f8OW/IERSCD3Zcq/26GifW1
         j+sUCIlLEHB4WRrqPYVyhELRumFY7j3AEuUtc9EFg2ojD+BZ8KBXyK5B4N7N8l/HvQ/R
         d33hcf58ioUphH8TkJb0YALp/aU7pCBGbZbQKV6SMwjXUQpeu3NOEjvFv1TqZl3/jN+r
         BogA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUd0XI3ZaOsYsQwtRW/GVMoly3oqi8RZfCZNdF1EDZT6iIyspPJ
	xYjVuNtPRgrQK9qESnZA/tzcpYcTyxfgET+tt8pHGuqXb/MEy98hIoPceM+dv8sEt9IBfMbR8Xd
	xtnnw5NhdLQti4GHi8Aatx6REE7Nv4HMmeMhcTp2mIszMhFbEZxx83Uqj8MCtBPYchA==
X-Received: by 2002:ae9:ec0d:: with SMTP id h13mr93908660qkg.26.1561367085891;
        Mon, 24 Jun 2019 02:04:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNt8aRnVHHem14g32AEYMm1o0J3pcCfbpPZ3j479dzg3D6kx8+mNu428wuqrwQY5WkSzeB
X-Received: by 2002:ae9:ec0d:: with SMTP id h13mr93908636qkg.26.1561367085327;
        Mon, 24 Jun 2019 02:04:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561367085; cv=none;
        d=google.com; s=arc-20160816;
        b=ac235mLiExionMerkh1v/QAq7ZI4FQgN7PEEQe7WdKUFNqxT8bRmH6AcwvYj5ASvHB
         bJszWY4Ws0XoMsAU4qjRlPICyN+7fZgOch9WEZGbJrKV54cCr+6xIOKmnwOd155DuBai
         kkHQmsqSZ4ZlyKYUFBwRxjgI4LJmIVvG9Zj8H4vcizfapVdhnET/JmUhKiIDU/XxmM3h
         qLIT5UW6ukiKPWgMWW898LNx5rNP7zpsdJSUBT6oqUNU8GzzmRgzAvsP90FCuHbpN1n1
         Zu3ACOjRlRZ0XVs8MP1jIO55I+i+B4fyu72cnYUC2Rb+1bf0cu6JyvORsR7fPs9hPGbs
         zt1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WVy0vpi9Lz2dks4RVhNhqk2jEKnaYPfiE7jBKsvgnnw=;
        b=wCQzDHdeCRKV4Lb8Wt+lGdD2ulxxOFCeuPDNI8mzhwv7mBoj6D+Po/8hBPbJjUHLrz
         g1kmaIwiYXuAVaQ+rAR8bVSF7xOJR1eU+C9XguSozGE7gvrkAHK75Ef8ZqAkTP89sL5j
         xsL2L2KrhDjD1+2zoWX4bvilBXtcc4Lcs9FlXwOJ4IXe+beomVgxhuE4tswWqGlvCo8n
         xI5hdYDIWw+3CZ4tAhlrhSqZ5lmK1T55suzlQvKlIfpaK4wgjVg67aW47AzsLObLjABY
         /6XohIN7dBAGSMA3sNHlvZGQyksiAAjE82AIJ0SJCmo+9xCBljDtZODjOkqi/vOXtS8j
         8iTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t48si6657311qtb.41.2019.06.24.02.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 02:04:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4EA8C13A4D;
	Mon, 24 Jun 2019 09:04:39 +0000 (UTC)
Received: from ming.t460p (ovpn-8-18.pek2.redhat.com [10.72.8.18])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B2AF919728;
	Mon, 24 Jun 2019 09:04:26 +0000 (UTC)
Date: Mon, 24 Jun 2019 17:04:21 +0800
From: Ming Lei <ming.lei@redhat.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>,
	Rik van Riel <riel@redhat.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix THP swap out
Message-ID: <20190624090420.GD10941@ming.t460p>
References: <20190624075515.31040-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624075515.31040-1-ying.huang@intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 24 Jun 2019 09:04:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 03:55:15PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> 0-Day test system reported some OOM regressions for several
> THP (Transparent Huge Page) swap test cases.  These regressions are
> bisected to 6861428921b5 ("block: always define BIO_MAX_PAGES as
> 256").  In the commit, BIO_MAX_PAGES is set to 256 even when THP swap
> is enabled.  So the bio_alloc(gfp_flags, 512) in get_swap_bio() may
> fail when swapping out THP.  That causes the OOM.
> 
> As in the patch description of 6861428921b5 ("block: always define
> BIO_MAX_PAGES as 256"), THP swap should use multi-page bvec to write
> THP to swap space.  So the issue is fixed via doing that in
> get_swap_bio().
> 
> BTW: I remember I have checked the THP swap code when
> 6861428921b5 ("block: always define BIO_MAX_PAGES as 256") was merged,
> and thought the THP swap code needn't to be changed.  But apparently,
> I was wrong.  I should have done this at that time.
> 
> Fixes: 6861428921b5 ("block: always define BIO_MAX_PAGES as 256")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Ming Lei <ming.lei@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> 
> Changelogs:
> 
> V2:
> 
> - Replace __bio_add_page() with bio_add_page() per Ming's comments.
> 
> ---
>  mm/page_io.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 2e8019d0e048..189415852077 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -29,10 +29,9 @@
>  static struct bio *get_swap_bio(gfp_t gfp_flags,
>  				struct page *page, bio_end_io_t end_io)
>  {
> -	int i, nr = hpage_nr_pages(page);
>  	struct bio *bio;
>  
> -	bio = bio_alloc(gfp_flags, nr);
> +	bio = bio_alloc(gfp_flags, 1);
>  	if (bio) {
>  		struct block_device *bdev;
>  
> @@ -41,9 +40,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>  		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
>  		bio->bi_end_io = end_io;
>  
> -		for (i = 0; i < nr; i++)
> -			bio_add_page(bio, page + i, PAGE_SIZE, 0);
> -		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
> +		bio_add_page(bio, page, PAGE_SIZE * hpage_nr_pages(page), 0);
>  	}
>  	return bio;
>  }
> -- 
> 2.20.1
> 

Looks fine:

Reviewed-by: Ming Lei <ming.lei@redhat.com>

Thanks,
Ming

