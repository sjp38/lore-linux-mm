Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_SBL,URIBL_SBL_A,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ACB0C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:09:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A2BB21852
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:09:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A2BB21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A39E06B0006; Fri, 26 Jul 2019 03:09:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EA228E0002; Fri, 26 Jul 2019 03:09:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D8D86B0008; Fri, 26 Jul 2019 03:09:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40A1A6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:09:46 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g8so25186848wrw.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:09:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v++9QLQIxVKfcXRp7P294AsYAgLGPGoB58FG1MNQyhk=;
        b=GaVx7zAnzT08lZeSoKt3En0q0nrWUMUsaPgbWETiwvfnbQTNJXBeLzOdDUnX0+at15
         L5zJvZGISA/PXlu1z/Ak9jUCxN9JiLUs3xFPCAuZHGSPa18Bl944IAy1BUh3RgDaTz9E
         KZJzKOmicL+zHc+S3KIB1nTP8IDAQdvjP5RgVqBgpIg2EAp4X/KDQzw6yFlYSc7I8CNf
         wjjPsTG3llCPzkfQD+He38eRWpGHB4FH+AfUN5+9JHGYuMj6rFWsM7S1LMj2luSocngf
         80SqYWA7NSJfn45Yd4yRlKBfE2bL3/2blxoHY5QQqITi4H2v6NpCBpB4+MU2Uc0El5Pj
         5A1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAX7cHEbi9yOYcCo9bJiK+owSMdC/vvmvW1H7YADPKrCDCm0gOlM
	4oxntFeRTclgbwmD4yDTmAo3WXWzTgJmWFTlzqIFdTejkjbHfrtsTR1t9eYGFEd9A/0uKq1qiwx
	y2hmc17j7dGpBMfIYODbC10qIdkErqbKoKhrnPm5cLMpYOG3wiY2Dv4qGQtlELhrYQg==
X-Received: by 2002:adf:f050:: with SMTP id t16mr93248845wro.99.1564124985819;
        Fri, 26 Jul 2019 00:09:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9vHvIL9jEWoTYmKcKhmcau2BeeZGrG93TAGNK5qCCaICne5oiNUxmekhQXVgHI8cfFuTQ
X-Received: by 2002:adf:f050:: with SMTP id t16mr93248737wro.99.1564124985061;
        Fri, 26 Jul 2019 00:09:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564124985; cv=none;
        d=google.com; s=arc-20160816;
        b=wI6NT8NaMlF/P4UxDdf+2+cadg9beSSDirGLbGBVBTX+PbLFkGAi3XIBhvrhZgXZ1G
         McbAAq09HZS6O8VGgwdNmzj3CRbYvnoMxQMMep60WOK8hVTjoUU/KMdhJD24dfkSOu63
         HHUVA4zOJ3mI/IKHj4myqQIsAXLfr+VlA5XsvsLmXKgFgUFbpQyEWrExXjLX/WLGTKWm
         volF92aOYaLdzuJZX6k/g6i4T5AdlB7e3D2osHCrPoUVLs5Pg+BeJg6Z6+zinOzGCUX4
         8gKt6uIqiyqg7YDLLeVqslsIccXY4nBtYZa8vz3aA4qUJz/U2wtvKOw/WoTQnR0fD/D6
         clDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v++9QLQIxVKfcXRp7P294AsYAgLGPGoB58FG1MNQyhk=;
        b=Tlt/8E3J1G4UWyZmyf2F3v3c8OsFRBrrtmWDIICHD03MZ8Js0IhLtvz5f/RJalUNxd
         84JXq3kh07x9+Q/cX0yux4cN07d5xBlwNiYgVmNH6rwURV/8vw6K1xBtvfw2XIO/F+kW
         Lh9ge+rbGqXXpzP98B7EOPRPNf2b56Y8ZU1UUj1P1OgpulzUwK7hra/ijgJogw5pt+DE
         VOc4Zc3AHAiGWChI/mOjHWW9ZApyEFg8eGSky38EaavyXJvnZZchJ4RiiEPX4vJaJ8gv
         ScOzSrNP7Y36/LRmAjLRcS1JYWEZL9Tzt04AFVuLSvMsJvi9X9ey2hgcKPSB87pxlTMD
         t8xg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id a10si46077369wrt.276.2019.07.26.00.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 00:09:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) client-ip=81.17.249.8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id BEEE198B4C
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:09:44 +0100 (IST)
Received: (qmail 8584 invoked from network); 26 Jul 2019 07:09:44 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.19.7])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 26 Jul 2019 07:09:44 -0000
Date: Fri, 26 Jul 2019 08:09:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>, Arnd Bergmann <arnd@arndb.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Rik van Riel <riel@redhat.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: use proper zoneid for
 compaction_suitable()
Message-ID: <20190726070939.GA2739@techsingularity.net>
References: <1564062621-8105-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1564062621-8105-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 09:50:21AM -0400, Yafang Shao wrote:
> By now there're three compaction paths,
> - direct compaction
> - kcompactd compcation
> - proc triggered compaction
> When we do compaction in all these paths, we will use compaction_suitable()
> to check whether a zone is suitable to do compaction.
> 
> There're some issues around the usage of compaction_suitable().
> We don't use the proper zoneid in kcompactd_node_suitable() when try to
> wakeup kcompactd. In the kcompactd compaction paths, we call
> compaction_suitable() twice and the zoneid isn't proper in the second call.
> For proc triggered compaction, the classzone_idx is always zero.
> 
> In order to fix these issues, I change the type of classzone_idx in the
> struct compact_control from const int to int and assign the proper zoneid
> before calling compact_zone().
> 

What is actually fixed by this?

> This patch also fixes some comments in struct compact_control, as these
> fields are not only for direct compactor but also for all other compactors.
> 
> Fixes: ebff398017c6("mm, compaction: pass classzone_idx and alloc_flags to watermark checking")
> Fixes: 698b1b30642f("mm, compaction: introduce kcompactd")
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Yafang Shao <shaoyafang@didiglobal.com>
> ---
>  mm/compaction.c | 12 +++++-------
>  mm/internal.h   | 10 +++++-----
>  2 files changed, 10 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index ac4ead0..984dea7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -2425,6 +2425,7 @@ static void compact_node(int nid)
>  			continue;
>  
>  		cc.zone = zone;
> +		cc.classzone_idx = zoneid;
>  
>  		compact_zone(&cc, NULL);
>  
> @@ -2508,7 +2509,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
>  			continue;
>  
>  		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
> -					classzone_idx) == COMPACT_CONTINUE)
> +					zoneid) == COMPACT_CONTINUE)
>  			return true;
>  	}
>  

This is a semantic change. The use of the classzone_idx here and not
classzone_idx is so that the watermark check takes the lowmem reserves
into account in the __zone_watermark_ok check. This means that
compaction is more likely to proceed but not necessarily correct.

> @@ -2526,7 +2527,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  	struct compact_control cc = {
>  		.order = pgdat->kcompactd_max_order,
>  		.search_order = pgdat->kcompactd_max_order,
> -		.classzone_idx = pgdat->kcompactd_classzone_idx,
>  		.mode = MIGRATE_SYNC_LIGHT,
>  		.ignore_skip_hint = false,
>  		.gfp_mask = GFP_KERNEL,
> @@ -2535,7 +2535,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  							cc.classzone_idx);
>  	count_compact_event(KCOMPACTD_WAKE);
>  
> -	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
> +	for (zoneid = 0; zoneid <= pgdat->kcompactd_classzone_idx; zoneid++) {
>  		int status;
>  
>  		zone = &pgdat->node_zones[zoneid];

This variable can be updated by a wakeup while the loop is executing
making the loop more difficult to reason about given the exit conditions
can change.

Please explain what exactly this patch is fixing and why it should be
done because it currently appears to be making a number of subtle
changes without justification.

-- 
Mel Gorman
SUSE Labs

