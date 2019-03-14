Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB790C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:55:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EE7F21852
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:55:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EE7F21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 417B48E0004; Thu, 14 Mar 2019 03:55:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CB3C8E0001; Thu, 14 Mar 2019 03:55:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B43D8E0004; Thu, 14 Mar 2019 03:55:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBC7D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:55:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t4so1883508eds.1
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 00:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8w4ZeMk108gOJGm+HmzmcSQyt39pPVrRoNa0Lp1u6Co=;
        b=EM7vbyO9l3d+J3SnBiVFakMmidGELAMkZMwgXPfkEjeX8UbEfXm9Jak+mrfiPkCU9A
         /U8E91G8fXjI2vjrJ1sq7EiFgip2DJz1csjt4qWm0kjrnszbPDXNpS1ZVNbxB1ofwZLf
         jKtjylAhRVG2NjNcGacr5QljWD+/Flpco6/q5azEUt6Pwh3lzm0Kv2RXT2YY228oxVii
         g15m3XdBIdMN/dBilRz10oLV8jwnj0zdWsok8re1QV9v89Uin5w6hSJWY7vF/fmK/dKU
         lRfaR6LdzFu5nKKvH9p/KdvLM2d9oiQkbBbIYMWv01M1hT2OGP48T8w0+W4owi4+mg0L
         olaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUyxp7NhU7UB6GJ9VfGqwpIh5aWjCJHOLzm7/KJOmcAJbVs0Ekl
	Wm49J7QNQlcl8oG/qyFmPha5UrXNtIJDu0c2E4aFmFzUGRdJ+rJSBj5Gu0dZbOCDm0xH1zHWhPM
	kfKf+CB3pRsD8K97wuPFGkcOwgNNuIfJJhalPDE6nNVspqiJIEwOGIIwb07RuXEXQdw==
X-Received: by 2002:a17:906:4dcf:: with SMTP id f15mr18123570ejw.32.1552550127427;
        Thu, 14 Mar 2019 00:55:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/TRo+yiE/Iv4wHdw1hDtK8TmU7rKI5gqCd3+RSN7b3HvI8wxZZcyIpHT4DxKXuB2t159n
X-Received: by 2002:a17:906:4dcf:: with SMTP id f15mr18123538ejw.32.1552550126635;
        Thu, 14 Mar 2019 00:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552550126; cv=none;
        d=google.com; s=arc-20160816;
        b=1D6WsXbC2IIW+AhBaXk18kwkGjQ9rHuT5098sIVUA2yxa/zrAqjtbwg6Z/6Qt3eexw
         xMgTX9G79EbKgtNc7mhRrJHY1OwwBS4wUB1QIAaUAR2Edtdq8V8UP2VV3Ebeu7j+CdS5
         jlhBrsKC8BpiEULv0nnOj5Kk3qk5ylf0pbohKJSYkAMxjDZzWFUwDugwmYoG+afBbm2z
         U2xgKQkEzBWDs3pj2YGCSZnQBZEbrgeJ7l4AoLTwCJX9gmt+szoD3k2ePAPeWtcgJQzT
         DNbbOzZpk7AAT+0QUQeGyWnVPy1rOMGtJ56Brvm/TlE/lwhau5FLFZIgMJYun8MP2bu0
         m6+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8w4ZeMk108gOJGm+HmzmcSQyt39pPVrRoNa0Lp1u6Co=;
        b=EvKKMqo+9/vgNfgcNqSF+hdhAqfowvt7IbBzWipAJNF4jigwlYbajggaHlsJycO9xb
         U3UfKE43Lenz6JMNab8j2FtrO7KL7TUqXbqNpia78igZ0uDEG/w2xsF73pbN53lG47t7
         7z6J9zUNwFzBnzQbVKP87HzGLW9wEUL+19Vk3s/aeb1Qtj1T4ZurmZ6QecJN5HV9gcDb
         jmdFnyt6pwlLCT1G5/HvS+LEe/omlidjVxHIQTs0AWzVlOruMjzWyi2ZzLC+4DAgFNCM
         otSqOn4HMyCgdpjNY/zRrDZdUTSwYvFiCbep4W1NjGlHSooNog8KnGVuZsZ+QawFhyTT
         QJyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id w4si1645689edh.436.2019.03.14.00.55.26
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 00:55:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 56248456D; Thu, 14 Mar 2019 08:55:25 +0100 (CET)
Date: Thu, 14 Mar 2019 08:55:25 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: fix a wrong flag in set_migratetype_isolate()
Message-ID: <20190314075521.mp6k63bpwprqhtmh@d104.suse.de>
References: <20190313212507.49852-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313212507.49852-1-cai@lca.pw>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 05:25:07PM -0400, Qian Cai wrote:
> Due to has_unmovable_pages() takes an incorrect irqsave flag instead of
> the isolation flag in set_migratetype_isolate(), it causes issues with
> HWPOSION and error reporting where dump_page() is not called when there
> is an unmoveable page.
> 
> Fixes: d381c54760dc ("mm: only report isolation failures when offlining memory")
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/page_isolation.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index bf67b63227ca..0f5c92fdc7f1 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -59,7 +59,8 @@ static int set_migratetype_isolate(struct page *page, int migratetype, int isol_
>  	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
>  	 * We just check MOVABLE pages.
>  	 */
> -	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype, flags))
> +	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype,
> +				 isol_flags))
>  		ret = 0;
>  
>  	/*
> -- 
> 2.17.2 (Apple Git-113)
> 

-- 
Oscar Salvador
SUSE L3

