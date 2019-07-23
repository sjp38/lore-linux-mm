Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A580EC76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:36:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6857A2239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:36:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6857A2239E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1558F8E0005; Tue, 23 Jul 2019 01:36:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106E28E0001; Tue, 23 Jul 2019 01:36:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10348E0005; Tue, 23 Jul 2019 01:36:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5CC98E0001
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:36:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so27521776edc.17
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:36:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qizxPeHqmw6Ku03n+jK3sGWM4kmcj3aRNitFWV47YIA=;
        b=dZho1nRxEB26lN4iVHOkT4Iy5ebsK4ynr2qifhjJDEP1wWBAr6Ch6P6SIRvChbPubt
         EICEGUbc2u42++OkMG988Ys9sbo67QHFHePmxmy7rJ14xL3DS7WXUINgvLZk134Tc0R9
         +XAxEz4pR/ZwaPwGxEtEMcGSXqrS7sifzJVJf+DddPqxqJ6pE6LetTIcUbzIGOuZn3Fr
         kvOsAVJtVDCCcJlK2oMv5fdea8a8iGwM7M0UD86QPphbAYm/E6Jg2CdFjanu2fcVCGk4
         UogpdjIP+wmyEiuFmpBO26FGF2uDm6f+pzLWt2thsVdy/XxvJc6hroE5HtNVpmDqP4tb
         edGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAX+6nmnZ8HamaDfvFl5Kr0I17y3GK9oLlmyJJMPoZZcyI3OCHUl
	+7SYjG+mFLWfZmNRmHiTd4bCO9lFDjkv00JxBhki/bip5inHACf8rvUn1KsyYIBkC+zr3M8Lw6g
	3rCWZjFfegG0EuEQlmWsoBs46z8YXG6Rx1upZBT9kVoi/KdSPfY/+M9elRkIh9bEqSQ==
X-Received: by 2002:a50:9167:: with SMTP id f36mr63952464eda.297.1563860208233;
        Mon, 22 Jul 2019 22:36:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhv0MoMNopxCrZDzVXgZXmr9uryV6EUmb16URWzusgMN68hCxWYlHeRd5j9JhQMDqvp5qa
X-Received: by 2002:a50:9167:: with SMTP id f36mr63952436eda.297.1563860207608;
        Mon, 22 Jul 2019 22:36:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563860207; cv=none;
        d=google.com; s=arc-20160816;
        b=xMK9AGGl3Cu5u8zxiDvNS3cOqAzN7BbA/5QSk2Z2qH/fO/GajODFRLfz+KdlB2V0dK
         BBT7SxmJSJt5/5SWDL1IyQA5ziH23Q3TivD8XTcXSHoV4/YNnF6K3889ghF/SsiBeh9U
         WrPFlogulSBYfujQnqvS2nDzOoIl+1++16TiWT3z64Jo7zbt/zUCIUzPk1acpQvx5jNh
         X4lmD+jv9O/oRFwfBu/BXjX2185W/YothqnimZM4H3yjjRO9IcqCkUBdL6JP+/H431zV
         /uiFw8Cgsrf/otxWjcVdIxa9H8Wy34oHT/CwF7OVxp6kjKco6V8T6wkkVhmCXVTsoCQ3
         OuSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qizxPeHqmw6Ku03n+jK3sGWM4kmcj3aRNitFWV47YIA=;
        b=MqFbLI6lGt2HtAy3K2CunWP9wXocUmBpVtlKYY3UgaRTQEEVcO1OvXz52bzwSHg73G
         2LCUFuSPrCIFveaSvZQ03OtYPiPFeJJBhYTtGTpMIVIzU9PXArTmyOqRfnTDefnhrJvz
         rVfNr+YHzSgdtmN54Pwfh+2WFuGXKV14aMzV/0trhQWDGRMkABglSW9qw+S+fFJ5tAn9
         Ed4jCZoSI3L0JphWAiWAnpsHrum2YyamVaCLiA2t1OIzmzdvuDvstDYsiBTgxsemFVzA
         L/3hFwr+a5ci4AEcF63wyCb+pTjlTRmMS/d+BJMxuX0gtNjAshtYGi4Uujk2ogqAaOEq
         SCGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga9si5070598ejb.257.2019.07.22.22.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:36:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7042AAF84;
	Tue, 23 Jul 2019 05:36:46 +0000 (UTC)
Date: Tue, 23 Jul 2019 07:36:45 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: clear total_{migrate,free}_scanned before
 scanning a new zone
Message-ID: <20190723053645.GA4656@dhcp22.suse.cz>
References: <1563789275-9639-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563789275-9639-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 22-07-19 05:54:35, Yafang Shao wrote:
> total_{migrate,free}_scanned will be added to COMPACTMIGRATE_SCANNED and
> COMPACTFREE_SCANNED in compact_zone(). We should clear them before scanning
> a new zone.
> In the proc triggered compaction, we forgot clearing them.

Wouldn't it be more robust to move zeroying to compact_zone so that none
of the three current callers has to duplicate (and forget) to do that?

> Fixes: 7f354a548d1c ("mm, compaction: add vmstats for kcompactd work")
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Yafang Shao <shaoyafang@didiglobal.com>
> ---
>  mm/compaction.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9ac..a109b45 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -2405,8 +2405,6 @@ static void compact_node(int nid)
>  	struct zone *zone;
>  	struct compact_control cc = {
>  		.order = -1,
> -		.total_migrate_scanned = 0,
> -		.total_free_scanned = 0,
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
>  		.whole_zone = true,
> @@ -2422,6 +2420,8 @@ static void compact_node(int nid)
>  
>  		cc.nr_freepages = 0;
>  		cc.nr_migratepages = 0;
> +		cc.total_migrate_scanned = 0;
> +		cc.total_free_scanned = 0;
>  		cc.zone = zone;
>  		INIT_LIST_HEAD(&cc.freepages);
>  		INIT_LIST_HEAD(&cc.migratepages);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

