Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4283C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 12:25:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9747621744
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 12:25:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fXxBmE7z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9747621744
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31FCC6B0007; Thu,  9 May 2019 08:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A96F6B0008; Thu,  9 May 2019 08:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 173116B000A; Thu,  9 May 2019 08:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A84D56B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 08:25:30 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id i127so454657lji.1
        for <linux-mm@kvack.org>; Thu, 09 May 2019 05:25:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=bgwFcpr4h0CqLDwaKDRvVqsaxrlGDdYtmYdrXixSeUQ=;
        b=knZIwH9A9ssY0WFK6V1BF/C2N6IDU7/iggkki3t5HQYQ4ICFS5mTegBQqrM1M9BxEt
         hQyLTDgRWH3xlMdlPdIKvTe80sgf4MwObRUyIuDAV/HDUMwDMeLy1uRkekqB5ZT0GUiR
         eQ//70uI8mnwSlNoRrbTlxpoPpGapxZFR2vmSmkXnv9vXBKbkB6uUF1Mm/WqOIqUaL9o
         bYRa+JqTanyRQD4SPHvchrnFaaDOzpYP4+V56ZybaqIkV8qd0BOxkXrxZODPq6CrW0UJ
         rMN9tKHuPBWBNiHT38Yfyk4orP6brWJOr27NRl1LmtrmlJX+6IGNeTOd1mjH2jMD/c3R
         sjzg==
X-Gm-Message-State: APjAAAXISQuSUxol9F9RRRTDW4ZDvDhPcnCDtKRjeot34KqbqtsnQlw7
	gWzpgMTxzZIU5DcqMuZVl+CA2LHe8yCh/R4fXP8B3LRW5wUZhsDuaHT7hX16Y/A8vGHmbWx2XTJ
	JmafBuZqGJKM+FD/dB/NxIxoC1BUxg4NGLZ8qoSl6TNQ8QKZz/IuMWI6LMqv8Dh7z7g==
X-Received: by 2002:a2e:94c7:: with SMTP id r7mr2233179ljh.91.1557404729766;
        Thu, 09 May 2019 05:25:29 -0700 (PDT)
X-Received: by 2002:a2e:94c7:: with SMTP id r7mr2233134ljh.91.1557404728739;
        Thu, 09 May 2019 05:25:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557404728; cv=none;
        d=google.com; s=arc-20160816;
        b=jRxV8/W/2WGW46+38QWdrEvq1Le+CFJPn2e0P3elzpqm+qtAxzormBlIoGldPGHAAY
         a+hzUeGArgOksD7kHgVtsFmcj2OvyCNNI2JSm2aldKPrthGKHBKr5C9+1Xc7vOwJI38q
         gLEcEgfHtT+GwxTyn931QU7o29f1IhtIif70JW0Hb/yBa4v7wsAd7H5EEl45Txi1PPzJ
         1aQoY1bDKJG2KwXJeNsz/DA5wWE84GRKrxkW7qu+RNoMCZeQnX7cJSOQ3INdFgMYtCUh
         oHDaBBatN5KrVyT0O9+m5jDPTiFtii2tH2fLPylzampGiT8xsqeDOjC+5KoAyRlzW4Tx
         PsiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=bgwFcpr4h0CqLDwaKDRvVqsaxrlGDdYtmYdrXixSeUQ=;
        b=arhmWLHtY6vwgQRZv05zNktxWPaTay1FooVl6FDlOocT8ItrTrkjOvUCG2Gvn3TA/K
         hi9kUDuMIDA7siO55UvnkM+Y8CMKHItcFKPo73m/YCum2mNJK2c1Qhw85tWB1dCC85OY
         I98izTkIsHoqlIQKh8Bdp/GpqaFEkmbAE8hKBrL2Q3ENycGz5lgx+KnqbgFGnRGeFWHr
         tTLHzefiM8MXhqdqJ5HQFNXPkn8U9uN29YRtxpfDsot8mshq1cXrsooohsJrCch+WAd5
         uml1p9vceGam0W2SeohTZt1m5/syuGdkkPHvGrkmbs0ikwKOOGOF69Jd3pMN0/oU8jZT
         PIKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fXxBmE7z;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s6sor1188760ljs.19.2019.05.09.05.25.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 05:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fXxBmE7z;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=bgwFcpr4h0CqLDwaKDRvVqsaxrlGDdYtmYdrXixSeUQ=;
        b=fXxBmE7ze/Z+gLUgPusLSOjeC8DPRni8xSXs72THlqUgvZ+YkB7C2X2joI2yabhZE3
         8p3jL+zSxjqkE6WDx9RdpWMHV1BE+w1kk8V/mtEhJpgbCLjSPVymx2kjkrzPGSAIjr7D
         w45LanlpZrGomO0jnZvIOzl4VSSIY4E3z+gyzmExHr1o6buuZO0GHkOYXoWSCeqrQLSb
         FlCkYEZRTrKaSU02Al80SESzb5ftUvtSa4dEV1Il4KRbvvZUIkjl7K++UhJMBcIliYoC
         xFLukUi+LA2L9H8oQGAQXR71a6J/JTXgKcmL1WnzuE5ndqFELwKSjnp7ngbqhxZBf77S
         RirQ==
X-Google-Smtp-Source: APXvYqwy62cie0c9VYiWdxvOgL2dz0bVljr6TDZHfH9f2UgG36OiRDna8QWxOvWyDUp4EYX5rZFmew==
X-Received: by 2002:a2e:814e:: with SMTP id t14mr2163558ljg.25.1557404728231;
        Thu, 09 May 2019 05:25:28 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id y7sm306917ljj.34.2019.05.09.05.25.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 05:25:27 -0700 (PDT)
Date: Thu, 9 May 2019 15:25:26 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
Message-ID: <20190509122526.ck25wscwanooxa3t@esperanza>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429105939.11962-1-jslaby@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 12:59:39PM +0200, Jiri Slaby wrote:
> We have a single node system with node 0 disabled:
>   Scanning NUMA topology in Northbridge 24
>   Number of physical nodes 2
>   Skipping disabled node 0
>   Node 1 MemBase 0000000000000000 Limit 00000000fbff0000
>   NODE_DATA(1) allocated [mem 0xfbfda000-0xfbfeffff]
> 
> This causes crashes in memcg when system boots:
>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>   #PF error: [normal kernel read fault]
> ...
>   RIP: 0010:list_lru_add+0x94/0x170
> ...
>   Call Trace:
>    d_lru_add+0x44/0x50
>    dput.part.34+0xfc/0x110
>    __fput+0x108/0x230
>    task_work_run+0x9f/0xc0
>    exit_to_usermode_loop+0xf5/0x100
> 
> It is reproducible as far as 4.12. I did not try older kernels. You have
> to have a new enough systemd, e.g. 241 (the reason is unknown -- was not
> investigated). Cannot be reproduced with systemd 234.
> 
> The system crashes because the size of lru array is never updated in
> memcg_update_all_list_lrus and the reads are past the zero-sized array,
> causing dereferences of random memory.
> 
> The root cause are list_lru_memcg_aware checks in the list_lru code.
> The test in list_lru_memcg_aware is broken: it assumes node 0 is always
> present, but it is not true on some systems as can be seen above.
> 
> So fix this by checking the first online node instead of node 0.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: <cgroups@vger.kernel.org>
> Cc: <linux-mm@kvack.org>
> Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---
>  mm/list_lru.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 0730bf8ff39f..7689910f1a91 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
>  
>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>  {
> -	/*
> -	 * This needs node 0 to be always present, even
> -	 * in the systems supporting sparse numa ids.
> -	 */
> -	return !!lru->node[0].memcg_lrus;
> +	return !!lru->node[first_online_node].memcg_lrus;
>  }
>  
>  static inline struct list_lru_one *

Yep, I didn't expect node 0 could ever be unavailable, my bad.
The patch looks fine to me:

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

However, I tend to agree with Michal that (ab)using node[0].memcg_lrus
to check if a list_lru is memcg aware looks confusing. I guess we could
simply add a bool flag to list_lru instead. Something like this, may be:

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index aa5efd9351eb..d5ceb2839a2d 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -54,6 +54,7 @@ struct list_lru {
 #ifdef CONFIG_MEMCG_KMEM
 	struct list_head	list;
 	int			shrinker_id;
+	bool			memcg_aware;
 #endif
 };
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 0730bf8ff39f..8e605e40a4c6 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
 
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
-	/*
-	 * This needs node 0 to be always present, even
-	 * in the systems supporting sparse numa ids.
-	 */
-	return !!lru->node[0].memcg_lrus;
+	return lru->memcg_aware;
 }
 
 static inline struct list_lru_one *
@@ -451,6 +447,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 {
 	int i;
 
+	lru->memcg_aware = memcg_aware;
 	if (!memcg_aware)
 		return 0;
 

