Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BC41C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:51:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FD32208E4
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:51:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="UZK6Vmsl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FD32208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBD168E0080; Wed, 10 Jul 2019 13:51:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6D7A8E0032; Wed, 10 Jul 2019 13:51:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5C3E8E0080; Wed, 10 Jul 2019 13:51:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9095E8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:51:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 21so1769726pfu.9
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:51:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uKVGZA2rdeScy3bwyoxpCnlfJ0pW69jxWknu9B37i2E=;
        b=KcHsVyjQwtcTsc7yowJi36DmA3T3dGcqEpwiwksMrPmRcr68FOJjBYhYPt8eaEyorU
         rh9djSx7mg/NakIgF/3AslGNh/zdzPdjaCmLvzAGlrK/nVvkrmGBhMtURCEQjIVho0p9
         quu9fKfoHykj8ZGpdzx9w5gI20L39Ssj3mGddw/UYzQROl1e4F8QzHdhgWaxWYlrRTeJ
         qpeACbtT0aJKaFfaMoUCXpY2z7b25q9sexgcc6eg5lRB8/8BAC5WLcS8Yu63yGQxZvEZ
         T5ts79AwB7phlYj553xcLaUjKjeLB+KUn8VK5Vaxd7XrBTXZ85Sv7HgQb+sj3F+8ixBb
         1uVw==
X-Gm-Message-State: APjAAAUwbwRqn35ToReJ5ks6GmNJgm8jLkM3ziI2Ni34Rxxi2FqA4ehs
	ycO+7UO2LG8sysOmQJY9FGRCVFb5JSBKjzv1QtMvmj7UfBwpjH8spQeYbWx1VdhiqpqqWuzDYl4
	wPZZgT1MWDtRyGxlyOQDbiCIZGg1apDROvK0OLdzTdzZhcuLtJYRhP7LKFZXYqNZLCg==
X-Received: by 2002:a65:63cd:: with SMTP id n13mr38391381pgv.153.1562781095218;
        Wed, 10 Jul 2019 10:51:35 -0700 (PDT)
X-Received: by 2002:a65:63cd:: with SMTP id n13mr38391350pgv.153.1562781094539;
        Wed, 10 Jul 2019 10:51:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562781094; cv=none;
        d=google.com; s=arc-20160816;
        b=mK27mPziTkv2N83ceqj/Fqjo9do2SIwe5UeKIz3X/Gv9UlIwiR8048+JtBKooq6g5M
         5iXdCj8+tQKNSLZqlFDHwmCou4Kebt6if2SsY7cFIsI4XUiw+1EMgRLOn61hvTz3gnt9
         IY0zUqeKztYkcKUU4xzcXiVWeFnbf8zrMdujww+dgAo2uWXxA/HbQQyWR+YP60ADCHLh
         6buBxZeUzgbcd/cTtUmcasHBcepF/JA3q027e/2Ptm84Ydp82Hjnl7KxsQ67BCyQXvO4
         0aJ9g9zJxZcLRexRmbkFckM+7LFfnUuqpgIDC8Q23OzfnL+zs4GREv8LcvgA8W8aHdcY
         z+xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uKVGZA2rdeScy3bwyoxpCnlfJ0pW69jxWknu9B37i2E=;
        b=KqTIdu1KJYeIl9XO9bZS37MRJAvlqmVK2xx2p6aeG0MsFIIWR6H71xp7UK7Dn6I0xe
         L7ECSdnsADkBbhwEyrgvN2dimR050NVOKGdP039dYBSbtacyf6LODqlgmpvii6KhULFG
         TabyOavuuOZw6C5iKBLcbrUz47+HWyRVHOz5axnMRAeFOX1Pj4xUtqxx8J3xTgwmSpDn
         QU4CZOqWU2Yl+xSTdVFcZ3mmGbhkm/lhgrXDcVD+EuVod9TriBKE0xizbSVo1kwnYwmy
         nbYsQQhQEhkKlOOddcqH8FiX80Wz5zlFMoRdfdc28YShAWOtumxrkJpc5wwcqZ373rIf
         ox5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UZK6Vmsl;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor3598333plq.42.2019.07.10.10.51.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 10:51:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UZK6Vmsl;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uKVGZA2rdeScy3bwyoxpCnlfJ0pW69jxWknu9B37i2E=;
        b=UZK6Vmsl0GscAoMkvtUuBih99iOojK11B4bvX2Y3xO14yXORhC/0bcYZdxrAsSPYm0
         3cghVrqwrNceZtWVPS2OmuOTg8jqhlsmP74StkkSqNt3ZRtstSVQ2rqC4oa52GhxYWYP
         szwnVtXKZPWmkwhy+poSNKK7HVBlvyd6PMe0AaVqrSmXPBtUAl6kBVIteBLTp/hzC6Ca
         k1HlOYguhdbAY0QSGQauUptYzwBBp44xNU1GSIkDnJl7S8EffJ29kXDie/6fcE2Xx+9R
         LzD9VvJHiopZz0iXo4NPCaCU19GtW2sXRJBRyMMl3LJh1svVA5UnfRFEThRroQv5H/BN
         8IaA==
X-Google-Smtp-Source: APXvYqxf3k6wj0r1DWMxtICEKSsf7cXHz1s9bD0kZqyeu5LkX+cE8uIy0dD31APMZFjW0w+y3Coc3A==
X-Received: by 2002:a17:902:1486:: with SMTP id k6mr39639657pla.177.1562781093710;
        Wed, 10 Jul 2019 10:51:33 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id j15sm2877546pfr.146.2019.07.10.10.51.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 10:51:32 -0700 (PDT)
Date: Wed, 10 Jul 2019 13:51:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 1/6] filemap: check compound_head(page)->mapping in
 filemap_fault()
Message-ID: <20190710175131.GB11197@cmpxchg.org>
References: <20190625001246.685563-1-songliubraving@fb.com>
 <20190625001246.685563-2-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-2-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:41PM -0700, Song Liu wrote:
> Currently, filemap_fault() avoids trace condition with truncate by
> checking page->mapping == mapping. This does not work for compound
> pages. This patch let it check compound_head(page)->mapping instead.
> 
> Acked-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  mm/filemap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index df2006ba0cfa..f5b79a43946d 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2517,7 +2517,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  		goto out_retry;
>  
>  	/* Did it get truncated? */
> -	if (unlikely(page->mapping != mapping)) {
> +	if (unlikely(compound_head(page)->mapping != mapping)) {

There is another check like these in pagecache_get_page(), which is
used by find_lock_page() and thus the truncate code (partial page
truncate calls, but this could happen against read-only cache).

