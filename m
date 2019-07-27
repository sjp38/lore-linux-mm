Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84F12C433FF
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 10:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52A4C20840
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 10:16:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="a71xFW1N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52A4C20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB4318E0005; Sat, 27 Jul 2019 06:16:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D651C8E0002; Sat, 27 Jul 2019 06:16:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C78FC8E0005; Sat, 27 Jul 2019 06:16:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7EDA38E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 06:16:11 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i2so27025461wrp.12
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 03:16:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IXEjdnUn3VkhWBwJSQhECGFViuPtRLCo9vxT8tzVgl8=;
        b=UUMxGgw+fR2C98c93pGa5pYLIbVHl7p2+1orMPu4+OQnYOuqAe1TkzCJgfbPYK/hqt
         wndXutQO6P2Ah8+DGZkVU2up6xSs/LhrOgTae/wfabDFB/vLv1glRFepNIrCebC7MTK+
         Eidyh5jd1dTHfVksDK3f3sqMZxr9/XVZUS3u+eiJxVFlOxv6PHAKLO3/a8CYQWZCX7dd
         fonvM60S3oyuLVHB7IP9VpCMnfZL1CPQcyejuiCfnTAaw1Ln5l3Y3znt0Ufty5FDkYOZ
         ze65DNhiemc3wlC6DTqxHxUw2n+uUDQ/lLL1/cIs0J3l3W/OY/cTi5A4st1+f8OJ0TX/
         opNA==
X-Gm-Message-State: APjAAAX/l1nJIcbSxFrZYSe7yGAmCt7CMRzr5IN5LXHeisgHSI5I5CsU
	KEdTF6d3VE+cRYxlJ+qsgHuaSWoPIOpgPbvaaPz9s3kBd16hjhVpD4I1uJtVYIDVf5kOML58I49
	Q1HJYvnmY6BxY7EDu/Y0XXd5IkcbQfafsaTrbtpGSdLWk/XlAgPmItfsrP66WjLYuTA==
X-Received: by 2002:a1c:7e85:: with SMTP id z127mr92359905wmc.95.1564222571071;
        Sat, 27 Jul 2019 03:16:11 -0700 (PDT)
X-Received: by 2002:a1c:7e85:: with SMTP id z127mr92359818wmc.95.1564222570257;
        Sat, 27 Jul 2019 03:16:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564222570; cv=none;
        d=google.com; s=arc-20160816;
        b=ES4cynxPioEjV+Kk3xB3nwnMeb4maGUVbA1fIaec/gcjsk2cC6aRoOV87AVkWLsIo7
         Xdjl3JrVpPWhoMy9kJM4pyn5q6l6/7AeQOav+2il74zHdfrjCYtvuObiRsr1uLshOwyq
         4jE9JFjR24g34rLMI31bMmEFZ5i8+jdzHw9Kz3IrIDHBa+saedBkgAoDdCWQSlxKXrQR
         gjfAX7ZV0MPOB+iemKQNf/pbQ4ik8nO06n3dFjxkfO3vjG4Fu2VBdXz4WJUIwWiNh6iQ
         /dVyeM32tPtLU+V1KUiioIRoKFXlRa8B9LD80zDmrPoc7/bjzt3RPslDD0d+XHcsnV3N
         1GUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IXEjdnUn3VkhWBwJSQhECGFViuPtRLCo9vxT8tzVgl8=;
        b=HRHF6CQteC+JhC+bRDPcWG/ZMdzrnnIeIW0MuAqQnf2qi2DYrnzuYw8K6uDEwaEN9K
         TRSUh/35L9qAygOEvZuOa1IbKS55AcaNf1bW/i8VY90NWKcEL21wM1uWqx4GRu8zV5XT
         hBn82cwL/K9z3RXdy43DHjTQtXvf13iBPBI8X/p4vEvmtqaynhY1H8NGC2/mSpREbICA
         csgQ2aFZhpfTxqr1oXJjVOxVbmXey9Cpfly/3D+27Ut0V+885/CAf18qeu4YPu3SMyPx
         SNizhZdStCbUoQthZJw7hlHMGmH3SNHE+MGLNxx9MwDTi89m38vQd/OkXYwx0gC0z3xt
         9feg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=a71xFW1N;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor44284561wrm.11.2019.07.27.03.16.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Jul 2019 03:16:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=a71xFW1N;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IXEjdnUn3VkhWBwJSQhECGFViuPtRLCo9vxT8tzVgl8=;
        b=a71xFW1NUEq3o8kaHcCrDOOxweDvWfxkp5iKwmVSBuzUXtmp2Bs/hmDEUtV3HkeQnQ
         JWMv9wk0XNKWjntQLlyVE8LDYrP7rri71bngMvGZW5+W2nL4nbe36sjnAUywcyUSnLxn
         ET/QGwikXysoTxta0lpPP7dpr1pLviGffAq1w=
X-Google-Smtp-Source: APXvYqx/cGuS1gJ0Afm2ttVoWqm/3PaHRFGZ43BnTfOXHbEQEMJU5qWym22vdCCCuNXUHFEHPP+FUQ==
X-Received: by 2002:adf:e841:: with SMTP id d1mr28181928wrn.204.1564222569709;
        Sat, 27 Jul 2019 03:16:09 -0700 (PDT)
Received: from localhost ([2a01:4b00:8432:8a00:56e1:adff:fe3f:49ed])
        by smtp.gmail.com with ESMTPSA id f2sm49931061wrq.48.2019.07.27.03.16.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 27 Jul 2019 03:16:09 -0700 (PDT)
Date: Sat, 27 Jul 2019 11:16:08 +0100
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Chancellor <natechancellor@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>, broonie@kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
Message-ID: <20190727101608.GA1740@chrisdown.name>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
 <4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
 <20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
 <20190727034205.GA10843@archlinux-threadripper>
 <20190726211952.757a63db5271d516faa7eaac@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190726211952.757a63db5271d516faa7eaac@linux-foundation.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

u64 division: truly the gift that keeps on giving. Thanks Andrew for following 
up on these.

Andrew Morton writes:
>Ah.
>
>It's rather unclear why that u64 cast is there anyway.  We're dealing
>with ulongs all over this code.  The below will suffice.

This place in particular uses u64 to make sure we don't overflow when left 
shifting, since the numbers can get pretty big (and that's somewhat needed due 
to the need for high precision when calculating the penalty jiffies). It's ok 
if the output after division is an unsigned long, just the intermediate steps 
need to have enough precision.

>Chris, please take a look?
>
>--- a/mm/memcontrol.c~mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix-fix
>+++ a/mm/memcontrol.c
>@@ -2415,7 +2415,7 @@ void mem_cgroup_handle_over_high(void)
> 	clamped_high = max(high, 1UL);
>
> 	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
>-	do_div(overage, clamped_high);
>+	overage /= clamped_high;

I think this isn't going to work because left shifting by 
MEMCG_DELAY_PRECISION_SHIFT can make the number bigger than ULONG_MAX, which 
may cause wraparound -- we need to retain the u64 until we divide.

Maybe div_u64 will satisfy both ARM and i386? ie.

diff --git mm/memcontrol.c mm/memcontrol.c
index 5c7b9facb0eb..e12a47e96154 100644
--- mm/memcontrol.c
+++ mm/memcontrol.c
@@ -2419,8 +2419,8 @@ void mem_cgroup_handle_over_high(void)
         */
        clamped_high = max(high, 1UL);
 
-       overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
-       do_div(overage, clamped_high);
+       overage = div_u64((u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT,
+                         clamped_high);
 
        penalty_jiffies = ((u64)overage * overage * HZ)
                >> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);

