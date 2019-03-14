Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6927BC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28808217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:25:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28808217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA3FF8E0003; Thu, 14 Mar 2019 04:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B292F8E0001; Thu, 14 Mar 2019 04:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CAFB8E0003; Thu, 14 Mar 2019 04:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39BDE8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:25:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f15so2052721edt.7
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yeEaIpoUjOwkAcixjiXgOfDHUz1W2PfPaUhl1MZWbg4=;
        b=pOJFS8+O84bQ/+imo8ZEoXOANv9smpBYhpgqh94WNHdY+6+XRGayFiuQOlOV9jWqx8
         bzksv7dHWMD64knAjx3hgg/BB4oTZ09MXkc9+BHfFPS0EUlMXF/IprIZIWzRSz91fESt
         88cXMWVePTXbYY0w4piFgV5I4zCrC+bn4cWCXBnwJg2crSzE5Qf8sfLgh6TvjibYBsw3
         GOTZvCfQvnzWaL2zKxR+wWsgt6Cq7vAlj2nalu+aQRhrxE6YHYQva7ltYREMyddoHVad
         sq8yiyi1aQDOGVejWb0cVDejaQlgnmL1Mzi9tPFAM3hg25mf/Q4p6jWH6Kg+hD8ZCPJx
         CErw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUKJUvWCYGxRVcxMn9KTFkm06UccSCB15d+533547o5thCHYn8a
	pedUKbat162//TbDMLgz+x04OyJbEs1ypgps2TzJ3qkrRvdVNKQvGXvI108WKNhrcmzcA7XaL2J
	gtktGjFboFvwOnchHU1ZJpLArmsCr0YizKFJ812qfg7GtnJr+Nqguk5RtRPH6pjXa3Q==
X-Received: by 2002:a50:9268:: with SMTP id j37mr10692483eda.170.1552551930782;
        Thu, 14 Mar 2019 01:25:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbufaYHuqmyFFD2P0i2a3cTz9yFKx3GVfGOcwo+hZi32yu5OV9av/Dzz3nZ7xnWa0VPHAB
X-Received: by 2002:a50:9268:: with SMTP id j37mr10692439eda.170.1552551929951;
        Thu, 14 Mar 2019 01:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552551929; cv=none;
        d=google.com; s=arc-20160816;
        b=P2/tk78GAw4GwdHj6XIKrq6bwL3BtfhX3c4V2RwecDk6YeXuplggQwf18dONLtZECq
         Lt+CsCyDxtU6NN/px6ePmCfxu7k6h0VlBAR3QnR5NpxbWOvrpOhbu4tCvfR75Z+dsrLf
         MGa4v14/AI5FrONZzktp7nAYR44wr2DhJdlhbGO6//RZ1wkw/t8Ccnqox0QEFA/3Pp35
         xK+N60TGD2fzLCh3IB+0frka4rd/BxUbbsB9DG4iWdKYMqyNrFgCO7rHNUHo9IzCldsh
         SrreKTQ6mhOorEOdhGalObD64ags7cVBSD2KoZmve2plDq5uTw+5WT5EB3tsYnN2KeTs
         bl/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yeEaIpoUjOwkAcixjiXgOfDHUz1W2PfPaUhl1MZWbg4=;
        b=J4UJsDBZsZArUm+yQocDqQHK2mY9MPcJXwkq/864xBzDElp+0W5qlmzdfb3Ix6fpe8
         yj2fiKeBqx2wPYtxg8zwcepKAoE7roLi0bCkX9CSM14VdpaSM7PKyEReu9KWrcZqO4qG
         BNtkWVJEHp6qPE4Caq8A4Qq0HPeiyXJ6wYJTVUXvCwfiML6Vkz9p6Xn40ehM4tSgzRlt
         SyOl3P36nWK/RR4zLU3mFFZFWvWMdYFR76MkyLmMaJX/daM89RrOxHzSkdpYB3EfXJIV
         cpmfb/S3oWOUVeyHnMWqgGvrv1v4GdAnMTbE/Bkr/CJYL2vZ+ArRYSg7W8tQSTGRtSLT
         E2Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g6si1618073edm.219.2019.03.14.01.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 01:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 36A06ACE3;
	Thu, 14 Mar 2019 08:25:28 +0000 (UTC)
Subject: Re: [RESEND PATCH] mm/compaction: fix an undefined behaviour
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: mgorman@techsingularity.net, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190313180616.47908-1-cai@lca.pw>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <433eedda-bba6-798d-31e8-d603fa33a20d@suse.cz>
Date: Thu, 14 Mar 2019 09:25:27 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190313180616.47908-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/13/19 7:06 PM, Qian Cai wrote:
> In a low-memory situation, cc->fast_search_fail can keep increasing as
> it is unable to find an available page to isolate in
> fast_isolate_freepages(). As the result, it could trigger an error
> below, so just compare with the maximum bits can be shifted first.
> 
> UBSAN: Undefined behaviour in mm/compaction.c:1160:30
> shift exponent 64 is too large for 64-bit type 'unsigned long'
> CPU: 131 PID: 1308 Comm: kcompactd1 Kdump: loaded Tainted: G
> W    L    5.0.0+ #17
> Call trace:
>  dump_backtrace+0x0/0x450
>  show_stack+0x20/0x2c
>  dump_stack+0xc8/0x14c
>  __ubsan_handle_shift_out_of_bounds+0x7e8/0x8c4
>  compaction_alloc+0x2344/0x2484
>  unmap_and_move+0xdc/0x1dbc
>  migrate_pages+0x274/0x1310
>  compact_zone+0x26ec/0x43bc
>  kcompactd+0x15b8/0x1a24
>  kthread+0x374/0x390
>  ret_from_fork+0x10/0x18
> 
> Fixes: 70b44595eafe ("mm, compaction: use free lists to quickly locate a migration source")
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> 
> Resend because Andrew's email was bounced back at some point.
> 
>  mm/compaction.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f171a83707ce..6aebf1eb8d98 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1157,7 +1157,9 @@ static bool suitable_migration_target(struct compact_control *cc,
>  static inline unsigned int
>  freelist_scan_limit(struct compact_control *cc)
>  {
> -	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
> +	return (COMPACT_CLUSTER_MAX >>
> +		min((unsigned short)(BITS_PER_LONG - 1), cc->fast_search_fail))
> +		+ 1;
>  }
>  
>  /*
> 

