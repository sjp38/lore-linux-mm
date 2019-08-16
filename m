Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D04CCC41514
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:48:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92FD421721
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:48:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="mrS+amgv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92FD421721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45B426B0007; Fri, 16 Aug 2019 17:48:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C9B6B000A; Fri, 16 Aug 2019 17:48:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FB056B000C; Fri, 16 Aug 2019 17:48:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 0851E6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:48:25 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9E16B12780
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:48:25 +0000 (UTC)
X-FDA: 75829630170.13.ducks86_f416a1218037
X-HE-Tag: ducks86_f416a1218037
X-Filterd-Recvd-Size: 3509
Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:48:24 +0000 (UTC)
Received: by mail-ot1-f41.google.com with SMTP id k18so371232otr.3
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:48:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LyElFB/DQKr6Gizru8u06ztJ06NwMdbnhXlNaM4nxfY=;
        b=mrS+amgv8MUZtXXjJgioy8ife407MwfpV3HzSJJM97stHaySnNcwdMkTrTmdO42TYK
         mUXUzfAuYL56dOpVKrZt05dICfv+fI8pIKUkLoB5gQS7fIMA6VnmaZtqpu9yzur2D52u
         LBrXk8ygWWjZ4FpncAY6ObVGddD32Crqr5bzzOhGaPJ93LP4y7Z4pFxkMRd6W/qhzGfa
         PVa4MQVGxMg4/5XN3/SAYycOiedKl5K2505hnWWZdBfrl4KYNov4c0Gpp35IRPTqtVMZ
         vK/09rXwd8ggXEKI8s7m22aN7Zk8QYG7+wbSQ7oyz0uPAgtAeOWiv4nUyaMJzO4hBrPb
         czfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=LyElFB/DQKr6Gizru8u06ztJ06NwMdbnhXlNaM4nxfY=;
        b=WoEdyW0hWdE9pOsdQLtujpaEKoIoskkF8zFFfvbZyptfUd3UFvWEKQuaK88IL6yVPv
         bRqynSsJ1hpbrZlpWqW4DPCjQnW+eQX448gQ+78/IImS0tLCnueb6EDeKAQD8k1EV9kP
         C+Dy7ug5ndNYPOuJJtRV7ePRhiS53WFjDsJQrSnJMtv9YaXfRapjNq4jENLLM8FYzSVg
         RW2fpPN6wvla7FI6kdQLcU+aAjJYV79IzMSkZNwilkkWXZ1Ilc6dEKT5WtAd3yXa5Ezo
         s3lmYeDJysV4ciohxPzeBMPFJfHV24bgKatn6svU4Z496xXXtMexqLRGlDSJHuItIr1X
         IpAA==
X-Gm-Message-State: APjAAAWWPBqJM5cOfhtP2dBen6PCKNqjXcRGIR9JEdjlHnfqHQwBnqrl
	kGR5keMLJQtfLyb8lbFCTSzRVN4gLWagASXo+WePlTIj2kQ=
X-Google-Smtp-Source: APXvYqyDpwbVXFlvMymCKEQxblapyLZJ2uTf8kCcMCHUlKmdPHMPy2wDX6J/Yo2/rZ+OzbU3y2tiV4thup6lKoyweVk=
X-Received: by 2002:a05:6830:1e05:: with SMTP id s5mr8439514otr.247.1565992103975;
 Fri, 16 Aug 2019 14:48:23 -0700 (PDT)
MIME-Version: 1.0
References: <1565991345.8572.28.camel@lca.pw>
In-Reply-To: <1565991345.8572.28.camel@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 16 Aug 2019 14:48:11 -0700
Message-ID: <CAPcyv4i9VFLSrU75U0gQH6K2sz8AZttqvYidPdDcS7sU2SFaCA@mail.gmail.com>
Subject: Re: devm_memremap_pages() triggers a kasan_add_zero_shadow() warning
To: Qian Cai <cai@lca.pw>
Cc: Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	kasan-dev@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 2:36 PM Qian Cai <cai@lca.pw> wrote:
>
> Every so often recently, booting Intel CPU server on linux-next triggers this
> warning. Trying to figure out if  the commit 7cc7867fb061
> ("mm/devm_memremap_pages: enable sub-section remap") is the culprit here.
>
> # ./scripts/faddr2line vmlinux devm_memremap_pages+0x894/0xc70
> devm_memremap_pages+0x894/0xc70:
> devm_memremap_pages at mm/memremap.c:307

Previously the forced section alignment in devm_memremap_pages() would
cause the implementation to never violate the KASAN_SHADOW_SCALE_SIZE
(12K on x86) constraint.

Can you provide a dump of /proc/iomem? I'm curious what resource is
triggering such a small alignment granularity.

Is it truly only linux-next or does latest mainline have this issue as well?

