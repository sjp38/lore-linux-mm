Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DACCDC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:12:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4184223A2
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:12:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4184223A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219D06B0005; Tue, 23 Jul 2019 04:12:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CA216B0007; Tue, 23 Jul 2019 04:12:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B9C28E0002; Tue, 23 Jul 2019 04:12:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFF566B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:12:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e9so16631890edv.18
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:12:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RoOQmmZIOhAy7LcIy6BtrpB/uYoos2Ac89b4XGhvF4o=;
        b=bV5TX28w8L/IIXJJN9IgKXy3SmL6DnXI03PVLzm24koMm4TnswvjnLk03PxO4IfxK+
         Ny98DnCano+hNO96x/XphB/iNwI10+ntETdcI/ta8X980O+fnMaCx6VV7zNaStm/nbZV
         3uGDL649kMDvkr/KySwh3NCJ+X9aLjUzejockLLqLkl5dEBSmFuxDC5d+PaN+5ruQAbT
         U0/8QrRUpwxh12MV835rL6UU/6Qr9f5LqOHNkMvfFfc3ZauT0pQQrEpn8/bBkW+fR1Jv
         joGpeWuUEnIwfBwhxCHmk+3ajBQmbzoE4OL1CrZsjR0X0xF3OF/WeJyt1KgVTpfUmr3o
         b+rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWWgrq9vj3Z8HqcX/TnPpN1mSSIqiMPbck4c/IJSWqh9hL4CWpp
	Z7rqs20YhL930n0w3PAnPHGs1ZldWNoJH63eXotETs7bs1HF0buop4A6+TaGfxv3s6QFJdHgpTW
	C9eZ0v2AOVpjFGSaZdYGdI9aYg1bv1Jm7aUQD//slywv84H7Dyuy/A9YHr0QM4nSHvg==
X-Received: by 2002:a17:906:e009:: with SMTP id cu9mr56428277ejb.267.1563869542281;
        Tue, 23 Jul 2019 01:12:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOjiJBQKSagb9wg5GMD4dA7Kyzg6v3roKngAk8NZkvFY9nkukgpQMgbLmM8ia2q4BUJEUQ
X-Received: by 2002:a17:906:e009:: with SMTP id cu9mr56428248ejb.267.1563869541642;
        Tue, 23 Jul 2019 01:12:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563869541; cv=none;
        d=google.com; s=arc-20160816;
        b=MmmViRLrCkY2SoRsUWICStAFXcdGN+T7biPQk+2/7uCWTP9WX20RidCTLLmu/BGXTG
         +Tr5YLJAZ7sFOq4ZQPj+USpVboFdtnVBxnE3TF3IDOam00fzgSdORJkrQTBTeD4fPWg7
         hGy00Uig/XiVZDH7cVmDPUzQs4fQPQDBjT1XLvLrbYj5UqqhK/moWtCQs9E7raSG/dB6
         x5PEX5bl/fjmZcDlHlGsiZ8VAGsxbMQBWxiWPh9wV2NTj29pTB7HudJK8dOsdxAi+6Cf
         xB8VoPw1Pa2rvb+9PR7aE37N6NQOffxRGWOkhpoM/796REZrshDjPIwRdyvPdYi+stcU
         OPHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RoOQmmZIOhAy7LcIy6BtrpB/uYoos2Ac89b4XGhvF4o=;
        b=Qk4u7Jlc+8wh3UK262K+ln1zJmkXDqBhy78RHKuRnWJaLVKLPvNf8614F43VboZSEW
         tanvdk3rJOHuxNvfszvO/WsIdRhMyulSFNn39s1JWkv+bLcY6/wwf2+fvE+1cb+ePVOo
         LgGZ8Mh8lyS9BnFT1pf0ki/y3UX9LKbg7YbxgxJdqnT0RsaLOwhsJ6+KyS+ORktpttyH
         2IN6qGIMiEvaAjCAmY/tclgYy0R/YmHus7hvBcUDNLHQmgWtuzJqTebmp572YmrlkovE
         4+GQtOccJf0oog5Xx8XfYpsD/bVcvfwcQ3L4mLpkHcRqyIIi3Go1280kOjhBNiW9E01U
         YQ4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i14si5378239eja.395.2019.07.23.01.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 01:12:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92614AD45;
	Tue, 23 Jul 2019 08:12:20 +0000 (UTC)
Date: Tue, 23 Jul 2019 10:12:18 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Mel Gorman <mgorman@techsingularity.net>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: introduce a helper
 compact_zone_counters_init()
Message-ID: <20190723081218.GD4552@dhcp22.suse.cz>
References: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 23-07-19 04:08:15, Yafang Shao wrote:
> This is the follow-up of the
> commit "mm/compaction.c: clear total_{migrate,free}_scanned before scanning a new zone".
> 
> These counters are used to track activities during compacting a zone,
> and they will be set to zero before compacting a new zone in all compact
> paths. Move all these common settings into compact_zone() for better
> management. A new helper compact_zone_counters_init() is introduced for
> this purpose.

The helper seems excessive a bit because we have a single call site but
other than that this is an improvement to the current fragile and
duplicated code.

I would just get rid of the helper and squash it to your previous patch
which Andrew already took to the mm tree.

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Yafang Shao <shaoyafang@didiglobal.com>
> ---
>  mm/compaction.c | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index a109b45..356348b 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -2065,6 +2065,19 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  	return false;
>  }
>  
> +
> +/*
> + * Bellow counters are used to track activities during compacting a zone.
> + * Before compacting a new zone, we should init these counters first.
> + */
> +static void compact_zone_counters_init(struct compact_control *cc)
> +{
> +	cc->total_migrate_scanned = 0;
> +	cc->total_free_scanned = 0;
> +	cc->nr_migratepages = 0;
> +	cc->nr_freepages = 0;
> +}
> +
>  static enum compact_result
>  compact_zone(struct compact_control *cc, struct capture_control *capc)
>  {
> @@ -2075,6 +2088,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  	const bool sync = cc->mode != MIGRATE_ASYNC;
>  	bool update_cached;
>  
> +	compact_zone_counters_init(cc);
>  	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
>  	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
>  							cc->classzone_idx);
> @@ -2278,10 +2292,6 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  {
>  	enum compact_result ret;
>  	struct compact_control cc = {
> -		.nr_freepages = 0,
> -		.nr_migratepages = 0,
> -		.total_migrate_scanned = 0,
> -		.total_free_scanned = 0,
>  		.order = order,
>  		.search_order = order,
>  		.gfp_mask = gfp_mask,
> @@ -2418,10 +2428,6 @@ static void compact_node(int nid)
>  		if (!populated_zone(zone))
>  			continue;
>  
> -		cc.nr_freepages = 0;
> -		cc.nr_migratepages = 0;
> -		cc.total_migrate_scanned = 0;
> -		cc.total_free_scanned = 0;
>  		cc.zone = zone;
>  		INIT_LIST_HEAD(&cc.freepages);
>  		INIT_LIST_HEAD(&cc.migratepages);
> @@ -2526,8 +2532,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  	struct compact_control cc = {
>  		.order = pgdat->kcompactd_max_order,
>  		.search_order = pgdat->kcompactd_max_order,
> -		.total_migrate_scanned = 0,
> -		.total_free_scanned = 0,
>  		.classzone_idx = pgdat->kcompactd_classzone_idx,
>  		.mode = MIGRATE_SYNC_LIGHT,
>  		.ignore_skip_hint = false,
> @@ -2551,10 +2555,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  							COMPACT_CONTINUE)
>  			continue;
>  
> -		cc.nr_freepages = 0;
> -		cc.nr_migratepages = 0;
> -		cc.total_migrate_scanned = 0;
> -		cc.total_free_scanned = 0;
>  		cc.zone = zone;
>  		INIT_LIST_HEAD(&cc.freepages);
>  		INIT_LIST_HEAD(&cc.migratepages);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

