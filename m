Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C2F4C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51D37206A3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:36:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="iFGJR2KH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51D37206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97E176B0003; Thu, 25 Apr 2019 16:36:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92BE36B0005; Thu, 25 Apr 2019 16:36:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81AD76B0006; Thu, 25 Apr 2019 16:36:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 580326B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:36:51 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f11so574059otl.20
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:36:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FIihDTK21B8LlTx+JlrSJxI6Wvq3SVEClJ0fa68DRhs=;
        b=dAbkXe7Rnmj9czyKml5+043Tx/zBFyDTYy8FkrL6v3EUnvMcBGkHqQJWiKmkPdrtYm
         DN5jGPXHdSg0OqsYphdvBGDIKInTg33KYY4vtUysFoF8WA0tBepN56IcNpacRtNNAxPo
         x03f+eTs0/AtWFUOyIIA33qG3mboDSn5d/8rR2vTVc6vuJFuuU5Fr2x4aMIWTh0IVVIg
         1fB+Wi7Yyl1qrhcM4prNUoDQzZdoNnqTZWsYfCWExMw9M3UE9h9ZWrB1jIYYWhKoHn8v
         cEdfpqmNDPHM3ClJX8fJas0n+Dk9xMq8bg9iWlaVzacZqHOS8NdG8AtYXK+rTIEDX1Ix
         lK9Q==
X-Gm-Message-State: APjAAAXwDDC7+utlF/rvV/TNQ5Mtm3/D+QIYjO/V4jgSX13pzTi6EHqx
	NR+12DNKn126L5hslClSrlRxeXf6kO9SCiKrv3DzIhsg5JzHJcqL0GkvTQDQs7YBHGJug9zXZkd
	9bP7AGd0424/+5owQseBbUd+s9kEMfIKsFxGBlNIpTZ4tzkMcKyUUEkjL8f8dVKDQLg==
X-Received: by 2002:aca:2314:: with SMTP id e20mr3126446oie.70.1556224610828;
        Thu, 25 Apr 2019 13:36:50 -0700 (PDT)
X-Received: by 2002:aca:2314:: with SMTP id e20mr3126420oie.70.1556224610307;
        Thu, 25 Apr 2019 13:36:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556224610; cv=none;
        d=google.com; s=arc-20160816;
        b=NKiDIFG58iodyNUMMsi7kOGZOztxLWoxucMkmsTZ4EKIXv0nyk+Mu3eqt6ZK6ifLkW
         Abka7jsdXvLivu/zf4k1uJntokrrTkq/zaXXDL4Fh+xVDL5O5Sefnv4VHl6eh4okWNFm
         nInbk4DfhRN4vws5KLx8rXUM3wOJroUgoLpf7H4s6lZYEbTtslr/LVyZ5xmxJ+pukZBB
         SlkzdowNlN92hO33XXSzQALxPMX4t/4yKvT4jnKIAdgtY/Uy0OHGg/DFILrzKe79lnes
         xh4akGmw5X3oDAYTWnmrn8h605IE4aSqIVERz+buRzRuAQrAqQIB8ob8vr40fP1GBvg7
         QusQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FIihDTK21B8LlTx+JlrSJxI6Wvq3SVEClJ0fa68DRhs=;
        b=W+oGWzz1y75hulKmXFGs3v3gbdnXNu6ACl/FuJUkXsDQf+m176WW6rI86/1i9kqWUY
         lkVPH0Tk6ZMB5E55koq2TImtL/zEMvuaBTwCm2tECCrec4vxRgybVnw0C6VkiHSLSlCB
         gT6PO+jvfnPkaoDKipJ1fAhf7etncncsWta+pfQwuiaVUeMpdzr4pIekXqzUbK0toDTa
         xxjVLNjetzMNkL/JdMzjeceD3hDrc/4SYl6K87q9DktaJF8vFj9f+4VX9x2mNNk5KZGJ
         OGEowKPBRfbJ4pVVJK4irSO85kHEknion09lXQx2yxT9PWrAYyZ9HVetjr2fLzVLIebt
         P3qw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=iFGJR2KH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r67sor2655697oif.49.2019.04.25.13.36.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:36:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=iFGJR2KH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FIihDTK21B8LlTx+JlrSJxI6Wvq3SVEClJ0fa68DRhs=;
        b=iFGJR2KHFK9leoBqnnLpU/4keINmAOFvijp+ij5OkhF+MG4Angz3Lm73+/JwBgSydL
         qZ75LZKGRYopvHsRBOBgcmzKY0Q2gm8nHO50otZ/4JqOJF3SYlozP4ft1ZUImYnQ8Hsb
         /kzia1VTTXitglhQGIUZVylqerW7SjlHURbeyjl68R9vBsi866Yqx82Vtj8Th9pPwVyp
         C0a2rCFlZIqZ3MIBAbIIutnOvnkmc1WPQPJxC82FOlxUMU/oRn2+b/gZ8pBUjkxIMbRE
         AC7nWEdnHznaNR7/q2YWv+E6Kepww9T+eW1dLQiw/zRFBPWsyn6sAdVrI/kEWid1O1Jc
         EsiA==
X-Google-Smtp-Source: APXvYqw7liLk4ou5W44g+Vn73s5BeUO+nIX8KBkB3nRUILCGFgw8gxzZ+jcOy6BSA5NNmhCBbab6BbgoYUI9IusP740=
X-Received: by 2002:aca:e64f:: with SMTP id d76mr4924428oih.105.1556224609760;
 Thu, 25 Apr 2019 13:36:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190425201300.75650-1-cai@lca.pw>
In-Reply-To: <20190425201300.75650-1-cai@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 25 Apr 2019 13:36:38 -0700
Message-ID: <CAPcyv4hxdyo=_9B3HtkBsCS-UdLR2CnoVqbaf8bBF6t_rRmMWA@mail.gmail.com>
Subject: Re: [PATCH -mmotm] mm: fix SHUFFLE_PAGE_ALLOCATOR help texts
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 1:13 PM Qian Cai <cai@lca.pw> wrote:
>
> The help texts for SHUFFLE_PAGE_ALLOCATOR makes a wrong assumption that
> a page size is 4KB everywhere.
>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>
> Fix mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch.
>
>  init/Kconfig | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index b050890f69dc..d96a910369c7 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1764,8 +1764,9 @@ config SHUFFLE_PAGE_ALLOCATOR
>           the presence of a memory-side-cache. There are also incidental
>           security benefits as it reduces the predictability of page
>           allocations to compliment SLAB_FREELIST_RANDOM, but the
> -         default granularity of shuffling on 4MB (MAX_ORDER) pages is
> -         selected based on cache utilization benefits.
> +         default granularity of shuffling on the "MAX_ORDER - 1" i.e,
> +         10th order of pages is selected based on cache utilization
> +         benefits on x86.
>
>           While the randomization improves cache utilization it may
>           negatively impact workloads on platforms without a cache. For

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

