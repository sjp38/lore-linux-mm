Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B97E5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D6382070D
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:30:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D6382070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EB978E0002; Thu, 14 Feb 2019 06:30:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 299D58E0001; Thu, 14 Feb 2019 06:30:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B0278E0002; Thu, 14 Feb 2019 06:30:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B987E8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:30:49 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d9so2381989edh.4
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:30:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=K7l/vvN01NeVJmxbBysCPc6n+N3PmIZhixmKQAhlHXw=;
        b=R6a1fjRrnjRzymgPTczOokauGacV6gNKBB798LoOiZYL3aTaWpxvrsPYLv6wvYr2Vu
         exCeXpWnG/s6hbO16iFPYtB1jzepasizoFwCBhthbBR95feH+ixvwL6SWrYjpd+jqgtb
         8/Q5oT0QBY8LrWjyt433fUoSlKrrjM4kD3oVNdDMUFgcegCbdh/3kZW2Yr7Kj8Z1RJev
         oGdfR6JuTIRW0ZOX2Y3cUTna5xE1mTpGGX7V2mnSyAlol7sOYVF9ioADUyffx8pFtaiR
         vH7umReWtOh9oIjE15fMZ2OORmi79Ud0g5m4mURnwEC5sZXuWETd7GuwBMn2Gw7No5Zj
         b/WQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYrXVF0uhBBG+BJ4Z9Z8VcsXpfFouF0yRd4kct7O8xkTboRr0Ej
	RAvThcZq4KNwYLUbzW5FQufVWovWecB+0d7Y7i65rkfKB7H4aoJDEVlw5v7Lv/3FaniFupNkbUU
	2HZuiIjWHVH+6ZWTGQPOjPiZXc3IFNjv70uWCsX57g/wfZ0+HKG6qeWNaMEaYY48=
X-Received: by 2002:a17:906:1508:: with SMTP id b8mr2458579ejd.48.1550143849283;
        Thu, 14 Feb 2019 03:30:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZf5heSzgPFml2mjoj2rdqDvSrsbfdoShi/O5eZeT8ixvQlOb+5tkTkLzLPN+YVlrIWx90M
X-Received: by 2002:a17:906:1508:: with SMTP id b8mr2458528ejd.48.1550143848378;
        Thu, 14 Feb 2019 03:30:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550143848; cv=none;
        d=google.com; s=arc-20160816;
        b=PzT3Lm9o41+dpiyHyp01Zz5DX2x67KBWtqmOgcunWNzvBWhH4X8maSNfYpSELDqTBF
         442i/IwQ1L3eaFaVLbfzaiwP/oDhzqHBCGXRhmgPWqQnRi/RXKpkb8MzgD90dpZ9/cqP
         hSNJtmu/UbtiQkDMfjDnzSAMOsLbrXad4pi/WZJ36vYM2GldxvBlrtlRTeripvjyAI0N
         6uGvyi9WnIMC0m19J06U5qdCQ+9aCTBA4mVYTWrR+3pABlEYHNDqeyWBIItWCN0RNCMA
         j0OKbjod41ApfeZh+kaAsv1VViMK7ynBONd2XdArdFQvjWqekwI1ixi0lq8FpnNJtS9H
         LFqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=K7l/vvN01NeVJmxbBysCPc6n+N3PmIZhixmKQAhlHXw=;
        b=CpdRXuf/Q/nYBT/v7rBVgaIuIrwkfIRELbWqPSOOfATNl3BWrz0e2XXuk3Lwv8hf9R
         IzOCp7KZWMk27J5wH2bWDNJYX4o8QWoS74IByp56Ab4naCuLVq6SvR8hrz9mNjRUJjew
         vq+nrDZV9ouLx/L9MkrcpQo4kGgN+XLgRF3iK5dSX8yCUPw711lTlELj1/nGQ+l9oo1r
         EbEzza8qZf17J0kVGHy4bCQSLB0KFOzOwICsz5n3m3TfasMfgbOvp+XP1HurHOQFjspK
         Y4UOqofxvnHJ55q1q6VI95v08NLlrS00MdC3xjoPKASDtyj0M685xopUDlkfEsE+rKgY
         ESxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z18si912841eji.43.2019.02.14.03.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 03:30:48 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8D35FAC7A;
	Thu, 14 Feb 2019 11:30:47 +0000 (UTC)
Date: Thu, 14 Feb 2019 12:30:47 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MAINTAINERS: add entry for memblock
Message-ID: <20190214113047.GB4525@dhcp22.suse.cz>
References: <20190214093630.GC9063@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214093630.GC9063@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-02-19 11:36:31, Mike Rapoport wrote:
> Hi,
> 
> I was surprised to see lots of activity around memblock (beside the churn
> I create there), so I'm going to look after it.
> 
> >From 7b3d02797ef18fb1c515f32125fb9b0055a312de Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.ibm.com>
> Date: Thu, 14 Feb 2019 11:21:26 +0200
> Subject: [PATCH] MAINTAINERS: add entry for memblock
> 
> Add entry for memblock in MAINTAINERS file

It is great that this code gains an official maintainer finaly. Thanks
for stepping in.

> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  MAINTAINERS | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 41ce5f4ad838..4e870d8b31af 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -9792,6 +9792,14 @@ F:	kernel/sched/membarrier.c
>  F:	include/uapi/linux/membarrier.h
>  F:	arch/powerpc/include/asm/membarrier.h
>  
> +MEMBLOCK
> +M:	Mike Rapoport <rppt@linux.ibm.com>
> +L:	linux-mm@kvack.org
> +S:	Maintained
> +F:	include/linux/memblock.h
> +F:	mm/memblock.c
> +F:	Documentation/core-api/boot-time-mm.rst
> +
>  MEMORY MANAGEMENT
>  L:	linux-mm@kvack.org
>  W:	http://www.linux-mm.org
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

