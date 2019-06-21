Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73149C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:09:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CAE82084E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:09:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CAE82084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5E158E0002; Fri, 21 Jun 2019 08:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A100F8E0001; Fri, 21 Jun 2019 08:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D77B8E0002; Fri, 21 Jun 2019 08:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3AD8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:09:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so8963893eda.2
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:09:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=cb+bWGD+HBxNB97rApn/jGEHo8WyU4g8aZHvN3ZHHKo=;
        b=WuID5Nw5JJDfH1eo2N5BK1/MCM+STqBihlvRTIV4xx69aqqYqWfQSfSNQ94bSzSm20
         0hZq10n29dYs/DYJRw0rfLAGrVhjgqNltAyyHQZHhn+bwZQ/Xgqk9ME8XTtap4cOoGoh
         Xwn6XitcjKd3fpv4LW9ot3CZkPE9fylL1BAgH/jFNw2jWgdsMZmr4CpXSDkw13ixWnO7
         eF8K65fiEl8jgtcdJlSnUrMtnU3G+fkFUcD+0NIOApzCI83m9rUI+81AVMplq0USp481
         AngHUyNkMmwIKg3uoCv5SLIzrGfwtcmbZKqLsb5rjAyticTdJb39oNtOGaA9+arn1vDZ
         OS6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAX8PYT+crkq3hXRLdcXPsrPpl+yAQQYhVuLN5Okwiz2u1gKzrWf
	OXdaD4qbMEYmvZ+yQ3Auibz9MGLv2ER6oFhRJqRp71za5fR6RBmlNywQ3bcaR1+BhwgCh7BD9XZ
	drlqNO+0Hc19f2DlREVxE13nPfAjtnSvQjk2NlzMEcozNOJdGbSyjy1HJIVv3QSh67A==
X-Received: by 2002:a50:84e2:: with SMTP id 89mr72503265edq.218.1561118972794;
        Fri, 21 Jun 2019 05:09:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydSLYM4daJzVEfD/PkYALcy+uGLCLQu1RBkk/9y+mPoDF2fBZArTYBiZQY9iR85dT+eB75
X-Received: by 2002:a50:84e2:: with SMTP id 89mr72503181edq.218.1561118971953;
        Fri, 21 Jun 2019 05:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561118971; cv=none;
        d=google.com; s=arc-20160816;
        b=D5vF4deKv63vToJQAkt0bpGpV0kxeeZ9yUzQeWBQVeTuX81RqMX7029jBkLWx+NaY0
         MJWmGkr4M4/IM/M2x0dQP1o6ZJR/mqnG//7+EjP+Yb2nLbMTNgZfDqavJu1AvOccdxvT
         +ToyJ4orZWHvQ6lZ0+PW4IBif29SFaKcRslRJKzuVqIDanlPgDpOEoDFQAbwVJP79knw
         EP6atvd9sY33nIr2Rljbgioa8Sdv28Wi+EQl6B47bcA9gVqUqeVNsY8+SmyXUvSJRRIe
         PRz39ZCmb6Sueqs/xT+Gx0wVEjLiHm+sa1euW7LEuwBTVT1qxUi7t7HsqMEpDjjihwsY
         hn3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=cb+bWGD+HBxNB97rApn/jGEHo8WyU4g8aZHvN3ZHHKo=;
        b=Ehq/JObJtqNaOffEQ7FIfEzlnGZ7kJabbDnfGCG5CHLEppo19M8ZyphJ7GKfpfOFV2
         yry/jdw9DGKyeAF0XMlWUk+MoI31qFmedlKTzVI20MwlJhBCHIirUOqbIOoIQeluPEON
         ebMeHvR7N11ZtYU758Rb3GrQvYeha8eBUKW+1BLtQCX1YkwSzV0gjhFQDalDN+l+upGv
         5p810RfDeeJK5bse952odDuB4dBC0amthtWAzoZ2efW1vGQ6vdq4XbvEDbno1vNyEbM1
         76NATyNpWAycKK+/EcvPNnOXVmGMmIPRy4vXXAjVkBQ4lvGYd74Rw2dgst/+wOdL9TQF
         ZhhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si1618570ejd.303.2019.06.21.05.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 05:09:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 554C9AF1E;
	Fri, 21 Jun 2019 12:09:31 +0000 (UTC)
Subject: Re: [PATCH] mm: fix setting the high and low watermarks
To: Alan Jenkins <alan.christopher.jenkins@gmail.com>,
 Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org
References: <20190621114325.711-1-alan.christopher.jenkins@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <3d15b808-b7cd-7379-a6a9-d3cf04b7dcec@suse.cz>
Date: Fri, 21 Jun 2019 14:09:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190621114325.711-1-alan.christopher.jenkins@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/21/19 1:43 PM, Alan Jenkins wrote:
> When setting the low and high watermarks we use min_wmark_pages(zone).
> I guess this is to reduce the line length.  But we forgot that this macro
> includes zone->watermark_boost.  We need to reset zone->watermark_boost
> first.  Otherwise the watermarks will be set inconsistently.
> 
> E.g. this could cause inconsistent values if the watermarks have been
> boosted, and then you change a sysctl which triggers
> __setup_per_zone_wmarks().
> 
> I strongly suspect this explains why I have seen slightly high watermarks.
> Suspicious-looking zoneinfo below - notice high-low != low-min.
> 
> Node 0, zone   Normal
>   pages free     74597
>         min      9582
>         low      34505
>         high     36900
> 
> https://unix.stackexchange.com/questions/525674/my-low-and-high-watermarks-seem-higher-than-predicted-by-documentation-sysctl-vm/525687
> 
> Signed-off-by: Alan Jenkins <alan.christopher.jenkins@gmail.com>
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external
>                       fragmentation event occurs")
> Cc: stable@vger.kernel.org

Nice catch, thanks!

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Personally I would implement it a bit differently, see below. If you
agree, it's fine if you keep the authorship of the whole patch.

> ---
> 
> Tested by compiler :-).
> 
> Ideally the commit message would be clear about what happens the
> *first* time __setup_per_zone_watermarks() is called.  I guess that
> zone->watermark_boost is *usually* zero, or we would have noticed
> some wild problems :-).  However I am not familiar with how the zone
> structures are allocated & initialized.  Maybe there is a case where
> zone->watermark_boost could contain an arbitrary unitialized value
> at this point.  Can we rule that out?

Dunno if there's some arch override, but generic_alloc_nodedata() uses
kzalloc() so it's zeroed.

-----8<-----
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..3b2f0cedf78e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7624,6 +7624,7 @@ static void __setup_per_zone_wmarks(void)
 
 	for_each_zone(zone) {
 		u64 tmp;
+		unsigned long wmark_min;
 
 		spin_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone_managed_pages(zone);
@@ -7642,13 +7643,13 @@ static void __setup_per_zone_wmarks(void)
 
 			min_pages = zone_managed_pages(zone) / 1024;
 			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
-			zone->_watermark[WMARK_MIN] = min_pages;
+			wmark_min = min_pages;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->_watermark[WMARK_MIN] = tmp;
+			wmark_min = tmp;
 		}
 
 		/*
@@ -7660,8 +7661,9 @@ static void __setup_per_zone_wmarks(void)
 			    mult_frac(zone_managed_pages(zone),
 				      watermark_scale_factor, 10000));
 
-		zone->_watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
-		zone->_watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
+		zone->_watermark[WMARK_MIN]  = wmark_min;
+		zone->_watermark[WMARK_LOW]  = wmark_min + tmp;
+		zone->_watermark[WMARK_HIGH] = wmark_min + tmp * 2;
 		zone->watermark_boost = 0;
 
 		spin_unlock_irqrestore(&zone->lock, flags);

