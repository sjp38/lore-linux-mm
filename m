Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 086CCC46460
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:29:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3B292177B
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:29:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fHGovjx4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3B292177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AC766B0003; Mon, 20 May 2019 12:29:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45D846B0005; Mon, 20 May 2019 12:29:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34D626B0006; Mon, 20 May 2019 12:29:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id F347B6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 12:29:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so9457529plb.3
        for <linux-mm@kvack.org>; Mon, 20 May 2019 09:29:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=byKYPTND9YCeJJHnLBgAwQB4XeP+2knzrQ48PDwWxpg=;
        b=jP+F7LzLN65B1WGyn87w/XQXScJ49YHq7xsn+d3LUBaPxEBYpMKw+4MJeBCnyGeYvv
         dY8bTFsYeMioRPjrk5Kf/HnID3PXjY/0DH7duz7WFfLrp6MwI4KUhjo7VrH/Oh+Zlk+x
         TTVSeFZhoZr+NUaMHUxiZPlDFwBl/7MbEKZ3F2EueX5gzrs4g/Nh8zJxfYAPxjpbYYPU
         e2G2E7k/u7t5UdQu4mTlScKOX1q0cxILokDvqyjlarCRhNfu3FgdquhW8kMx7ga+XSYG
         cK5/t0hvdB2phHC8i5RXf9MlQQ4b6jfT2utRdlX5BfAKJB/GJvJ71H7jHrZ6XIU6Gq2h
         T00A==
X-Gm-Message-State: APjAAAUbQCjCiIP6nC/IoSf4ZmJxbrMaJIB31IwYjVCIGmCCthMuCqGR
	dFx4n2jbOqDA02JFKlLk1Xlpmu794V0VUbZtdUFU7Qe6Iwbs/j39ompqIuPPKQKI1GixmbW6Szs
	w59RWPmU2QdfE4XjajfOg3ynzTPbNiEmUc6k/ZouJNNnT5TinAo9blymaclWkGJM28A==
X-Received: by 2002:a17:902:850a:: with SMTP id bj10mr8898843plb.196.1558369755681;
        Mon, 20 May 2019 09:29:15 -0700 (PDT)
X-Received: by 2002:a17:902:850a:: with SMTP id bj10mr8898748plb.196.1558369754681;
        Mon, 20 May 2019 09:29:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558369754; cv=none;
        d=google.com; s=arc-20160816;
        b=j5TW6rmBBin1hBEUBaSMdxAos0qmHM1SLrnk0j3O2GorSfLpBTqXx/OmfxghmRUCrG
         jMgIQhM0dVytfBvewGUdOES0XrUepuxJ0Cddfp87i1175dH97RjhLrOsKrdjTdxwsZnG
         MvR1lUD/atlFCpw+8Ey8kg0J4Ch+xehbLTsiTfmPi6Skoq1qddY7QzVebyeUhKU4LreD
         o/Kd/fAEM7eZRa5FmopIxkc6GNWUuDeukJ7MOrejM6T5cFPGm96sFW1PzTVT54qNMj8O
         5WAqWy4uVRyycXIh95o2QDQCdVUqLV6AvoloNMjKhoi2X8GCxkUXA3oSKayUNbAnaDxM
         +H5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=byKYPTND9YCeJJHnLBgAwQB4XeP+2knzrQ48PDwWxpg=;
        b=nUtFEXBBRLGdlfsi7hBIMqHR+FQ5bfvw7L1Z3r22byIZPg0BB4+MRFqCLeGIbP8nPg
         4+05qFpH+Ke5prnVDNN33yVn4th1hGX+18Zjnn6Vip4Qvf8aLabBtrQZtLGN+ONzolEW
         F2DlnTeXYym5uhtPP4ZMFJbzQdUYWo63BjF8CTPdhJpDz5U3Q1RsJQUT1Xf1dON8pxpi
         Haf74IVzdQ/Ya7HVrETiFFEZND80x5HLIi/MJ1DC4PP8sXoSTZz8SBHG5e9J7XI4WBqt
         7F8CcuTaG2x63nkAd2h6+GtjzlIUq18ReVmFtTVntUdzFMJhvcTwwHxXZjH2L3gnWMeI
         IqYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fHGovjx4;
       spf=pass (google.com: domain of akinobu.mita@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=akinobu.mita@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9sor17274456plc.24.2019.05.20.09.29.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 09:29:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of akinobu.mita@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fHGovjx4;
       spf=pass (google.com: domain of akinobu.mita@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=akinobu.mita@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=byKYPTND9YCeJJHnLBgAwQB4XeP+2knzrQ48PDwWxpg=;
        b=fHGovjx4PpiC1jOvqzA/Ecf1EzMl3NrIClO5m2ir+OpwlV6DW+ZDfHON7wTNel3tfm
         Ue5BC+Zij3L1zQ6a3ZH9N4C/YCBBSs//PV5Fyu+JbV/RnsCh5PIKWT9C6ugPIsLluGSt
         j02IcyMU6A+xKgrSrfN8TjytKlMLK1g+W+8+pYSgoK0/1RCW38cP/257Ikp1JNvsVpvM
         Z9IOZuDzlOEc64sFHlFVqojo0yJhwmBRhJko+CCsW93nz3GklGebuvSJiKsXJHJmJkHT
         jlJKvkINej8mN8Gu/86wRJDVuQ1qkMRMRTrra0E18so6glYg9gvvwEEfrgKj+DKLRuU1
         Gsxg==
X-Google-Smtp-Source: APXvYqyyaw5zpahyX3bKiYjur5LZoFYK15o3299Pf26i/dwF+cCH7jBL37QqVKzb7ETz0LCWzP3ry3IGEelO7Dy7wJI=
X-Received: by 2002:a17:902:24c7:: with SMTP id l7mr27106129plg.192.1558369754339;
 Mon, 20 May 2019 09:29:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190520044951.248096-1-drinkcat@chromium.org>
In-Reply-To: <20190520044951.248096-1-drinkcat@chromium.org>
From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Tue, 21 May 2019 01:29:03 +0900
Message-ID: <CAC5umygGsW3Nju-mA-qE8kNBd9SSXeO=YXMkgFsFaceCytoAww@mail.gmail.com>
Subject: Re: [PATCH] mm/failslab: By default, do not fail allocations with
 direct reclaim only
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, 
	Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

2019=E5=B9=B45=E6=9C=8820=E6=97=A5(=E6=9C=88) 13:49 Nicolas Boichat <drinkc=
at@chromium.org>:
>
> When failslab was originally written, the intention of the
> "ignore-gfp-wait" flag default value ("N") was to fail
> GFP_ATOMIC allocations. Those were defined as (__GFP_HIGH),
> and the code would test for __GFP_WAIT (0x10u).
>
> However, since then, __GFP_WAIT was replaced by __GFP_RECLAIM
> (___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM), and GFP_ATOMIC is
> now defined as (__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM).
>
> This means that when the flag is false, almost no allocation
> ever fails (as even GFP_ATOMIC allocations contain
> __GFP_KSWAPD_RECLAIM).
>
> Restore the original intent of the code, by ignoring calls
> that directly reclaim only (___GFP_DIRECT_RECLAIM), and thus,
> failing GFP_ATOMIC calls again by default.
>
> Fixes: 71baba4b92dc1fa1 ("mm, page_alloc: rename __GFP_WAIT to __GFP_RECL=
AIM")
> Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>

Good catch.

Reviewed-by: Akinobu Mita <akinobu.mita@gmail.com>

> ---
>  mm/failslab.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/failslab.c b/mm/failslab.c
> index ec5aad211c5be97..33efcb60e633c0a 100644
> --- a/mm/failslab.c
> +++ b/mm/failslab.c
> @@ -23,7 +23,8 @@ bool __should_failslab(struct kmem_cache *s, gfp_t gfpf=
lags)
>         if (gfpflags & __GFP_NOFAIL)
>                 return false;
>
> -       if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
> +       if (failslab.ignore_gfp_reclaim &&
> +                       (gfpflags & ___GFP_DIRECT_RECLAIM))
>                 return false;

Should we use __GFP_DIRECT_RECLAIM instead of ___GFP_DIRECT_RECLAIM?
Because I found the following comment in gfp.h

/* Plain integer GFP bitmasks. Do not use this directly. */

