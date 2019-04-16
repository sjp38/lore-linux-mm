Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18F7EC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:32:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3BAC2087C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:32:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="X5278fNa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3BAC2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EE3F6B02BC; Tue, 16 Apr 2019 11:32:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39E216B02BE; Tue, 16 Apr 2019 11:32:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B5296B02BF; Tue, 16 Apr 2019 11:32:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E73F6B02BC
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:32:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q12so19765671qtr.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:32:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=F/oz3Bz8Jc92v+9XDThS/dyZMGA2I7Q08A3BbUkZT5M=;
        b=e+ezjw1AtPp69x5FklB0OjLWVNoUT7fLiepgutYPTlGOG6W6ZOU/OEaX0OWrbJqSdM
         t+gP5VGw8Hcxu2y8QGfcY3MomCn6X5PxKaC7eT4ImW/YJZ5NJ4kYltY+BuoCZnAVG76W
         5dqMDM2HV7JwBpORk54a/7YI/1Ufu0+yDC0y89tATcdFiRfVq502BDdYXfbihFzmj9iP
         5Zev3/GgSaf74mPRaDBEKLsdU+VacPaTw/FyFYxffHhUlD1dJ75c1TumCW2pjnZ4l4fI
         UeOVkkIlJoXmBtPr1QhcQuqhdMit/1P/mJvhNuTQnmVdeCjchzlzPvEHoD3a32bEaZKi
         d3vw==
X-Gm-Message-State: APjAAAU3aPokKr2ZLjIpcxh7qOKS9CiNOPUuRlka5XPA8V8wDP4QbLb2
	zHhZbcdBWW4BwzgiOdKluYSXMrDKAmDmbPdER5v7rpCMcaapyTXKEzNwxSOvTzdlAHBiNLz3p6b
	RJmBsKB2jahQ6AcF845npFUD59kwN2YCCd+gwgnnJ2GDpgxGzxVg8JIONEvmi0yY=
X-Received: by 2002:ac8:2228:: with SMTP id o37mr63457557qto.200.1555428742831;
        Tue, 16 Apr 2019 08:32:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDxRdK8oy5LECVOcdG5tTeaO1WVwOAg+y4JwcNy50a3bvPa2jioUiuIaVxnUcYUuM0wQM7
X-Received: by 2002:ac8:2228:: with SMTP id o37mr63457504qto.200.1555428742191;
        Tue, 16 Apr 2019 08:32:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555428742; cv=none;
        d=google.com; s=arc-20160816;
        b=QaH4Sl5C20eww8sk5ZiAWRlR0kFBLAasibWUYzhKU10j7RpYU5DSmjK4IXZ+5nNIcE
         5Vn7fPLTchuW+LsngF4DeLQHXPsoKhOWnjo6PADL1ttI2TnOl2qJ3OJmRoGA+/nRgYB8
         K464V3VyDsPnoZuDMOaB3BbMpmcAGcieOfW5yM8Gw51JKb2yR83ut7eBCrp0j1+rxBX2
         +Lvp5t4l9hNQl2VYLSPEspSx2HLfQx7q+001gJ3b7KwxmZQJAxS/QE2+09U90hcQu/s0
         M1yAVl0EylgihI+6h04sbtonl3YVRHDqekKD885QevgWz6pLXmvA4MmSOs0SdJLUv6aj
         7oLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=F/oz3Bz8Jc92v+9XDThS/dyZMGA2I7Q08A3BbUkZT5M=;
        b=wEw8ZTt1JrYypHOjGT0o4c2qGVX+ZeNdMfXpXehugahMMmoREh65P4q2Lzv8A3VmNN
         3rEDlbIYqhdRQ0K38/l2k1Jo4mruMjUW4QlcvWsIo2C5aK+DAdKNa8akMp3uNp1Vgx0v
         VXWJJGaa5iLXPK8OXa7W4SGzTBiP90ivqM/tu+ve23mWH5E2EpMSiPe14VziALK0N/4l
         d6JF1bOqK3i1uE0ZfNHfVuhkRKhUkoUMyUDZ+V/DcGTxwHcMS+mnosF9MEg8D12Osk/P
         FfWyPRCCOcaFxqc50BDg0OtaP2NVZr3Ls/Dtijp/hA6/SPCZTWA3vOLaA++gdyDwUlAp
         kLjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=X5278fNa;
       spf=pass (google.com: domain of 0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id t56si791289qte.112.2019.04.16.08.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 08:32:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=X5278fNa;
       spf=pass (google.com: domain of 0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1555428741;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=/ZH+qQc+d3T9Uz+fe5gzibpOM/H0qPfROftUoVT10Kc=;
	b=X5278fNazPX14D+0RglGkXaLk/g3fLT6eAzYLZi9e90hc9jiTiSW+k+2BnL4rePK
	ol+DvSy7dHo7KUTaLL2v1Ovpxx9eOiLnuKqraWmO7vHFssb4k4zVGGOWYYCqzVSuiv/
	QCFin1yOMUal5z5Wg33FXWOF+U7DW3get5Q0Ax1A=
Date: Tue, 16 Apr 2019 15:32:21 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Alexander Potapenko <glider@google.com>
cc: akpm@linux-foundation.org, linux-security-module@vger.kernel.org, 
    linux-mm@kvack.org, ndesaulniers@google.com, kcc@google.com, 
    dvyukov@google.com, Kees Cook <keescook@chromium.org>, sspatil@android.com, 
    labbott@redhat.com, kernel-hardening@lists.openwall.com
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
In-Reply-To: <20190412124501.132678-1-glider@google.com>
Message-ID: <0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@email.amazonses.com>
References: <20190412124501.132678-1-glider@google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.16-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Apr 2019, Alexander Potapenko wrote:

> diff --git a/mm/slab.h b/mm/slab.h
> index 43ac818b8592..4bb10af0031b 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -167,6 +167,16 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
>  			      SLAB_TEMPORARY | \
>  			      SLAB_ACCOUNT)
>
> +/*
> + * Do we need to initialize this allocation?
> + * Always true for __GFP_ZERO, CONFIG_INIT_HEAP_ALL enforces initialization
> + * of caches without constructors and RCU.
> + */
> +#define SLAB_WANT_INIT(cache, gfp_flags) \
> +	((GFP_INIT_ALWAYS_ON && !(cache)->ctor && \
> +	  !((cache)->flags & SLAB_TYPESAFE_BY_RCU)) || \
> +	 (gfp_flags & __GFP_ZERO))

This is another complex thing to maintain when adding flags to the slab
allocator.

> +config INIT_HEAP_ALL
> +	bool "Initialize kernel heap allocations"

"Zero pages and objects allocated in the kernel"

> +	default n
> +	help
> +	  Enforce initialization of pages allocated from page allocator
> +	  and objects returned by kmalloc and friends.
> +	  Allocated memory is initialized with zeroes, preventing possible
> +	  information leaks and making the control-flow bugs that depend
> +	  on uninitialized values more deterministic.

Hmmm... But we already have debugging options that poison objects and
pages?

