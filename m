Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FAKE_REPLY_C,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 426E9C46460
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF9942081C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:18:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="GXLavN/7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF9942081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 859336B000A; Wed, 22 May 2019 18:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2816B000C; Wed, 22 May 2019 18:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F7976B000D; Wed, 22 May 2019 18:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39DD36B000A
	for <linux-mm@kvack.org>; Wed, 22 May 2019 18:18:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w2so2176547plq.0
        for <linux-mm@kvack.org>; Wed, 22 May 2019 15:18:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=Jd0RSCXoP1EdL1cjt/xgeuNaQX2V7Ph/JBkgB7uNH0g=;
        b=ieMK6R2qyJGhwkT4h08AN0Dcnbbedn9n3aKj+kVVVLBScTbr8ErgUoW7vyaBC9anRE
         nVgkgyUmiCJuYioDyQNfy81gw0oHpsnK+QBYf9gt1YMVD12pHD3ODqTLpszv0hD2QnHB
         QKTWzkwDBUPRH+tKW6EK46yWB4waZsT/6BHK99gZpWq+jl4NTfb/mZFp51ZJ3UhN10G0
         Yx0fqx+A/Y0ZAGfyi3BF0UBqKm2gkwgfxqtgrHyy2xbixw94w/JzUogn1KcvMAjqB/44
         v8XekK8Ds8CO5/MFHA0oprNGRdmFH4WOwMTWURHlSKYuJddmjTgFXHHgVq3a3lH1egri
         rRFg==
X-Gm-Message-State: APjAAAVOCDi1RYgK1H1KQ9wwZw8RsFe4IUzZ3fajB7BaK9++oIcpFHOY
	ZC4HlbMWzrYrP+HaV2w8TpSuNTZ38wELz1ZdJA/V8kmv438eSM6c0008sCXMwufSMwfwp+D4ocl
	FHjsSToGgAPuLKPjUiZQ4uswLj6zqgKg5LEHRnkawA+Znl/YedPOxfq40K9m3+6bBtw==
X-Received: by 2002:a63:246:: with SMTP id 67mr93972351pgc.145.1558563488755;
        Wed, 22 May 2019 15:18:08 -0700 (PDT)
X-Received: by 2002:a63:246:: with SMTP id 67mr93972294pgc.145.1558563488154;
        Wed, 22 May 2019 15:18:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558563488; cv=none;
        d=google.com; s=arc-20160816;
        b=fyZYVCoic8ovFpFDvPoY8v+HcQL1WakvYAeVPaJfpFsp0F5YKkQiP9xXch7WYeezUg
         bnJjVQ1/8s98+akzSvtDhCsjHnvS/LV4tToITLLuo9o9Ph0oGXs7bjg5w0Q3FcCcvM5Y
         8MAIUyq+qpK4qjE2YjV8y6qQRkfUCzMGDbVdLDL9TI0Egcz9ZN1ZmEHRfb6QdHBu4Bx/
         LQe5l6Qi58t8d5Obz0fjWz6ShC9el/wLEcUaOOR3BGWDUsLgdXTRHqYei0ynLEEzIEtS
         ejWL+tXImWko78Y6gbtqOKImFxWxqnMI9Yu+EQBaEMsvHEqDjoCXq2x1js6b2liJdHmy
         HvNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=Jd0RSCXoP1EdL1cjt/xgeuNaQX2V7Ph/JBkgB7uNH0g=;
        b=F23Rt6wHSpxa1KBTNQg6ZT8IxMB01FLlv8gCrbzFz5tbwfKJqPF6k8+YR9CSWjOG69
         hsj5ir+OnXSPsNh+CzeoHfPYxljI3/ZE+dd/1X2lMCbAlAe6uFZbBeElq246Z6CF0WMq
         o5UiMXgC5SqfBiRHk1SjbnU5tm5kwzWapHLGzCJwPy3Ooh3yHV/fhJdFk0Wlr5YzOh68
         QSe8y9Zx8OUheKNqZk/Npdxp8BtGsrfmN1kWKVeWnFCdc5Y7FG7OHWQaPUPhnyNSFhXd
         xnLuy41EdETJknTQLhUZgf2bRxWjE3jz164KOOUz+s5o61b8GvXH6AHFV9HZ/PLl9uuz
         v/iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="GXLavN/7";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u2sor28065084pfm.28.2019.05.22.15.18.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 15:18:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="GXLavN/7";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Jd0RSCXoP1EdL1cjt/xgeuNaQX2V7Ph/JBkgB7uNH0g=;
        b=GXLavN/7grE6LNJqyGhvPPesKBk185WFjgJna7ETOIJBaq1hY/O3DZYH9mqYTRPG6J
         GdFKCMBa8+OJJ7SXTg/NgAmRQpnKKVfSSiZLmo2keKmw0ot67menzPS8qFUMaPrsgUDO
         GNub7HFs2rNTz94sRTH62HK1i3T4MLXdmoCYI=
X-Google-Smtp-Source: APXvYqwYkSpq4sI0OwVnuYJtsng97b6lnFAf2peUNKoiZTQR4ze4ezgmfpK+1cl50ZPOllSPkVklsg==
X-Received: by 2002:a63:6f0b:: with SMTP id k11mr92068194pgc.342.1558563487623;
        Wed, 22 May 2019 15:18:07 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::e733])
        by smtp.gmail.com with ESMTPSA id l7sm28232045pfl.9.2019.05.22.15.18.06
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 22 May 2019 15:18:06 -0700 (PDT)
Date: Wed, 22 May 2019 18:18:05 -0400
From: Chris Down <chris@chrisdown.name>
To: deepa.kernel@gmail.com
Cc: akpm@linux-foundation.org, arnd@arndb.de, axboe@kernel.dk,
	dave@stgolabs.net, dbueso@suse.de, e@80x24.org, jbaron@akamai.com,
	linux-aio@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, oleg@redhat.com,
	omar.kilani@gmail.com, stable@vger.kernel.org, tglx@linutronix.de,
	viro@zeniv.linux.org.uk, linux-mm@kvack.org
Subject: Re: [PATCH v2] signal: Adjust error codes according to
 restore_user_sigmask()
Message-ID: <20190522221805.GA30062@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190522032144.10995-1-deepa.kernel@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+Cc: linux-mm, since this broke mmots tree and has been applied there

This patch is missing a definition for signal_detected in io_cqring_wait, which 
breaks the build.

diff --git fs/io_uring.c fs/io_uring.c
index b785c8d7efc4..b34311675d2d 100644
--- fs/io_uring.c
+++ fs/io_uring.c
@@ -2182,7 +2182,7 @@ static int io_cqring_wait(struct io_ring_ctx *ctx, int min_events,
 {
        struct io_cq_ring *ring = ctx->cq_ring;
        sigset_t ksigmask, sigsaved;
-       int ret;
+       int ret, signal_detected;
 
        if (io_cqring_events(ring) >= min_events)
                return 0;

