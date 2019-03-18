Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44E08C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:40:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F7562070D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:40:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F7562070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F4F6B0006; Mon, 18 Mar 2019 13:40:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1ED76B0008; Mon, 18 Mar 2019 13:40:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90D9C6B000A; Mon, 18 Mar 2019 13:40:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 714C56B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:40:09 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id l203so23295319ywb.11
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:40:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=X2g+VepdiRAOMeU7MHERJDBcxJ1Pw1UOaJtbtsqlPFg=;
        b=hvk8kPFxRUgpmJt+aR1FIHqfT5y1E6ClIWYPLA7i0SzQ/SrEYzpvgv9IURMrGhab4/
         fQK4dZhzwg1D5WGIgVX8751YYATrQfod2JK0dIwP/32pTx3C/SHcG68bCQfUhAnUYooA
         cFTXntInPSbQryc0n7RbjbBQLyqFihc/f5gxsMg5WvgUQ7p+9mpwZQEXUqVQGxD17JWa
         k106ufWFBhv6kDAAZQfJDe+wKEgOtGGxAkWVRDmUdxMhWOJHPocsw80GzXgKywsW3T9u
         rmngVQ0C7USHuNJ+7qrGkUG+VfguvfmBb4U9okoXO32QZDjLjEvaiIfDj1+Lgm3AW98p
         SorA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWmzCk100WbSoQp+z/LDPjU0SP8S9eVjqVhKAobU+nCA+94utq2
	0b8jHMT3nBJwipFSXnQog+NnCV9OE4kuB/69IkR5t+64frqh1SzTmuFnJ0qTlhPrCsu4HGtBSZl
	ElFg786CxY4OaR7nkemjY1pBNtd5tGXTl2Vt3Yy35NcGWHUGcJFYMJuBhOKlZGTc=
X-Received: by 2002:a0d:eaca:: with SMTP id t193mr15301565ywe.29.1552930809210;
        Mon, 18 Mar 2019 10:40:09 -0700 (PDT)
X-Received: by 2002:a0d:eaca:: with SMTP id t193mr15301513ywe.29.1552930808372;
        Mon, 18 Mar 2019 10:40:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552930808; cv=none;
        d=google.com; s=arc-20160816;
        b=p6vNlm0rlB1HiCa8br/kOC70kAZIKdJ1lnzIhqjVLrc/nYxFEXpJMXoNL+LefkbcYp
         iLmLyuJreQqdoCyQj8DK9sQ1qlxmfRq+3ke4j2R+dHvPQjq5L9Yf540+p/XNNMaBstvj
         fPPvNyOu3SpR6W3FVXxYmh6Qrc6/5amy6VhB1SmF7wzYPqR7KxleyX++6/Jx4DxZVvxb
         TRU8elRZlhL/xhV5LMTmIEE5dEVgFl5fexhPJa7+nePePsVRFN4gK7OT4JB0E/1Nfdkj
         /6DLAhU2C+X5H8nS2W+8lJl3ruGWeiDq5iBr6hdwC7zll3vYuq0xTdDtCz22wqNsouPf
         o2tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=X2g+VepdiRAOMeU7MHERJDBcxJ1Pw1UOaJtbtsqlPFg=;
        b=a7LGyVn4aP3cUyi3Fi/PTFSdTOKffLii5sY5JrVKD37hWkcFlOXQr1rCTXllNiRLIS
         rDZvcl4izVUKmKOUJCLO3Pp8BOH09MZb017g05HCd2McY8XAXeQS8XiVeg4Z/RwZjZJB
         n2W1tcd4LTJQagbVO0wSatvzDex+97SNP7vncYKrWnt7HXIQnKbaK4Ie2S0c76ITSza9
         JCIU7LMCqXeB6nDx3br2CswelNjtwqat3kU7hYW4TofABwXCaUwrrS0H9yhqCQEwA3or
         xZjZK+VaiklvRrflm0tgUDbTV+y9T89qKye06wqi/h0ghtw/AdTNSYe4YkVQYVgIZpY8
         ncNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j188sor1707532ywf.153.2019.03.18.10.40.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:40:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwNX9FSn0lknNGVqi3elbetV5UsK+cFr8UxcQF8U5+ujKMXdu3GxTZr1+lI8HOxhcSk9HftSg==
X-Received: by 2002:a81:3d17:: with SMTP id k23mr15108355ywa.266.1552930808046;
        Mon, 18 Mar 2019 10:40:08 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::3:734b])
        by smtp.gmail.com with ESMTPSA id 136sm305236ywl.109.2019.03.18.10.40.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 10:40:06 -0700 (PDT)
Date: Mon, 18 Mar 2019 13:40:04 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Matteo Croce <mcroce@redhat.com>
Cc: linux-mm@kvack.org, Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: stop printing kernel addresses
Message-ID: <20190318174004.GA60491@dennisz-mbp.dhcp.thefacebook.com>
References: <20190318013236.31755-1-mcroce@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190318013236.31755-1-mcroce@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Matteo,

On Mon, Mar 18, 2019 at 02:32:36AM +0100, Matteo Croce wrote:
> Since commit ad67b74d2469d9b8 ("printk: hash addresses printed with %p"),
> at boot "____ptrval____" is printed instead of actual addresses:
> 
>     percpu: Embedded 38 pages/cpu @(____ptrval____) s124376 r0 d31272 u524288
> 
> Instead of changing the print to "%px", and leaking kernel addresses,
> just remove the print completely, cfr. e.g. commit 071929dbdd865f77
> ("arm64: Stop printing the virtual memory layout").
> 
> Signed-off-by: Matteo Croce <mcroce@redhat.com>
> ---
>  mm/percpu.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 2e6fc8d552c9..68dd2e7e73b5 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2567,8 +2567,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  		ai->groups[group].base_offset = areas[group] - base;
>  	}
>  
> -	pr_info("Embedded %zu pages/cpu @%p s%zu r%zu d%zu u%zu\n",
> -		PFN_DOWN(size_sum), base, ai->static_size, ai->reserved_size,
> +	pr_info("Embedded %zu pages/cpu s%zu r%zu d%zu u%zu\n",
> +		PFN_DOWN(size_sum), ai->static_size, ai->reserved_size,
>  		ai->dyn_size, ai->unit_size);
>  
>  	rc = pcpu_setup_first_chunk(ai, base);
> @@ -2692,8 +2692,8 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
>  	}
>  
>  	/* we're ready, commit */
> -	pr_info("%d %s pages/cpu @%p s%zu r%zu d%zu\n",
> -		unit_pages, psize_str, vm.addr, ai->static_size,
> +	pr_info("%d %s pages/cpu s%zu r%zu d%zu\n",
> +		unit_pages, psize_str, ai->static_size,
>  		ai->reserved_size, ai->dyn_size);
>  
>  	rc = pcpu_setup_first_chunk(ai, vm.addr);
> -- 
> 2.20.1
> 

I've applied this to for-5.1-fixes.

Thanks,
Dennis

