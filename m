Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBE22C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:19:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 772D62084A
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:19:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="naw7755f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 772D62084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 146F26B0005; Thu, 20 Jun 2019 21:19:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F8CF8E0002; Thu, 20 Jun 2019 21:19:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F296D8E0001; Thu, 20 Jun 2019 21:19:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B897A6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 21:19:30 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q2so2655276plr.19
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 18:19:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=eJKYybw5a1SWYpHwymEpjHSIfv7GuhVzn0pIpamG/wM=;
        b=SSW1swXgpnd7uK8VhhD8qTYEAIYPcUMRZyxXukoq5idFvmdF4f8Spw5XCfzU8IuCyC
         Zeo06a+si0tsd/zOIm6aj1IR4on1tB5031HKySEuHrg7OfCZJTexxBJSeCSFLpS/nkWT
         zfsLTHHK9HxEECqAfs3MiBlMkKCPrRV7rheeTFNi5siK7Jrtp0TjIr8CKeS1Wuo8FTbV
         1zmUbanuFhbWnhzLWjQG8Lrj9VXwDMxLR1slXehn9hVk9dRN6xTezbDM7ZKbb2auNjMk
         kP/EnaGZPYjAnzCjGhmWOiKBZm78l2y+gkps7FUd34ZCyVh+PCV4oNsK1L5DogDmfPog
         hFyQ==
X-Gm-Message-State: APjAAAW+prEzpBPEYXjvs7X73kd+cilxyHrPxu2DSXgodfRBY+y7c/ZL
	mVbXWzlSsP/YueXIEleyAaSNvhfzXnSUWRWDUnzbkDCQozpdH/EtwfnMwwz4kYijYTYzl1xvob8
	ldawJQXiMEGM0Npf8SQmiqCllug2y0JZM33LLUWHGW/8vz9MWzx6dNxOFfPs5pJV3Ww==
X-Received: by 2002:a17:90a:1b0c:: with SMTP id q12mr2890267pjq.76.1561079970380;
        Thu, 20 Jun 2019 18:19:30 -0700 (PDT)
X-Received: by 2002:a17:90a:1b0c:: with SMTP id q12mr2890222pjq.76.1561079969829;
        Thu, 20 Jun 2019 18:19:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561079969; cv=none;
        d=google.com; s=arc-20160816;
        b=X98Ljsm3B9Na5PoEvyWuP1mh2L1+llC7k0iE3whNLffSRniIVy69f0IIJ2FTSST7Kj
         QJDwo2o5qsshxDg20mHkDWqfsHJV6nC/OXWiJgwg9rQgKkHWZsVUpcjS4k3VjwQSrJH4
         8Rspep0IBKGvRBnc80XfJyJQFc4hYw0xdQUxcTSWiSvpEUIpEgAy7LiGwDW3wf5PzZof
         FgukOPgE001tv+lq3BABcpowjdI8U790t+TU6wIXGCmokjnO9GbFBrsWvVzpuYolxFid
         NA+tLlskDYFry62tMaMtrlIl4rRjUZHY3GiAoBefJ6n2I87VbpatvEq9ve710ssZHXkt
         pHHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=eJKYybw5a1SWYpHwymEpjHSIfv7GuhVzn0pIpamG/wM=;
        b=Lwcp1APB0wD3nVvytaOxYvCBSOIjWfzMtXcTbgPxGYnW/buyXIPEWneYAY+qkSRabj
         L0WUvTXi1OK4lwLkGAjmNSBA5S4p0kSKs+5GRPgqJLb+8/0ptyJsdg/K8RlTbBOkDI7N
         Eq0kuC73mjSiVGw2s8qm4K8SuzQxfHLmUGNuBsxuKyc1S9Ynmv0Jf3v92zpyS+g0zV3m
         CgSq7LGpGREmKMF/PxD04Pmt9AM5dhqZCgET5tn9m9+ltenHm9NzX4dZFjpmj0gya6uX
         6HG+ldoYYKF2h9zbbMP1fdZ4WBKOfs5IExG0ETqX9HLbdtUjohhSqDIzwzbPh4DJwvEk
         nCWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=naw7755f;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1sor1632795plo.9.2019.06.20.18.19.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 18:19:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=naw7755f;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=eJKYybw5a1SWYpHwymEpjHSIfv7GuhVzn0pIpamG/wM=;
        b=naw7755fmAIXafE+Jl7dV8RVkpTo05kib/8CyuURh0MhrDFRQHF3jVyKVS6EeiB8N9
         BoFpd2iPgtOquKwlZ5rum1uAPcDMOfYH2zVtsc/BNjku12A7gon9LDPgQ+5iJ4Ko7J14
         5OMRX+XjMMr1O4lr8I4IGUtO/vyhyJrLisAS0=
X-Google-Smtp-Source: APXvYqzDCGsl/sfw+DruyeiWlGEv/UbXrhWxZujE3VvkgVVndHlvNmAR1JKU/5PFrVACJM85q79/Uw==
X-Received: by 2002:a17:902:968c:: with SMTP id n12mr34357353plp.59.1561079969560;
        Thu, 20 Jun 2019 18:19:29 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id b26sm680142pfo.129.2019.06.20.18.19.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Jun 2019 18:19:28 -0700 (PDT)
Date: Thu, 20 Jun 2019 18:19:27 -0700
From: Kees Cook <keescook@chromium.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, glider@google.com, cl@linux.com,
	penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] slub: play init_on_free=1 well with SLAB_RED_ZONE
Message-ID: <201906201818.6C90BC875@keescook>
References: <1561058881-9814-1-git-send-email-cai@lca.pw>
 <201906201812.8B49A36@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201906201812.8B49A36@keescook>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.005145, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 06:14:33PM -0700, Kees Cook wrote:
> On Thu, Jun 20, 2019 at 03:28:01PM -0400, Qian Cai wrote:
> > diff --git a/mm/slub.c b/mm/slub.c
> > index a384228ff6d3..787971d4fa36 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1437,7 +1437,7 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
> >  		do {
> >  			object = next;
> >  			next = get_freepointer(s, object);
> > -			memset(object, 0, s->size);
> > +			memset(object, 0, s->object_size);
> 
> I think this should be more dynamic -- we _do_ want to wipe all
> of object_size in the case where it's just alignment and padding
> adjustments. If redzones are enabled, let's remove that portion only.

(Sorry, I meant: all of object's "size", not object_size.)

-- 
Kees Cook

