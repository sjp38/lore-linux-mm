Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30511C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 09:41:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E49BB2054F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 09:41:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AJAnkSq9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E49BB2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85E1D6B0003; Mon, 24 Jun 2019 05:41:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E8B38E0003; Mon, 24 Jun 2019 05:41:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 688CE8E0002; Mon, 24 Jun 2019 05:41:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 492FE6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:41:40 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id l1so12282326ybj.18
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 02:41:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=u7V8Y/svVqpZMFRwTixoQtso+KwwiAflO76wYwcLCwc=;
        b=S7tjykxq3spZ7mdPkM4S+6IogAjOkUH7CvC1LfZK8G0Lr1ATYKDCOJhhuzyxkWI7p0
         4QHpfC4YKR5V2tszrQ0FqATELchrFVhIx+NOw/E9DK82JgVHnkGo1hRWZj5zejrrz4ud
         lbqLDIO0LUdrerreX+wbiGHpa3vMakZQMNccCAigWRIuGuEFTEHMUiVSPKJE1DFroteZ
         kemGqUJVOtJ1lVlBcEuW7VKoa6ZORGqkWaXIOsKjyW4lCsziLgbmNWC99kfZtGp/Nn4p
         VIRd9Ka5fYSvjQJ2g5dwZ0vTIA0j9mSXuh3sJtTfi6sE+X/i0IjY6liVzbzp4Y4BOC5Z
         p36g==
X-Gm-Message-State: APjAAAVq8l+HWL+e/sivzuwZl75NA66d9Qdy2lFuMs3AXQzV929W8dQN
	VytdlSSIeinhYe1GGlCZ0JvIsuOt6BD6iArY7umWjeWKlwO3++js6ClpcJUJGkr1PLH0+CnTbfa
	/9Psy+SzJy7VeM3qAS3OVWRH3Lz2/RtxzM4ogoFoSppaktSgtltxqbjw1XKknp1On2w==
X-Received: by 2002:a0d:c306:: with SMTP id f6mr3003431ywd.214.1561369300065;
        Mon, 24 Jun 2019 02:41:40 -0700 (PDT)
X-Received: by 2002:a0d:c306:: with SMTP id f6mr3003418ywd.214.1561369299601;
        Mon, 24 Jun 2019 02:41:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561369299; cv=none;
        d=google.com; s=arc-20160816;
        b=v4dH9JGwg/8mG/w7PlopL92ZWFV+7E6yInfnwLduqzwl/OJf/66HOAQ4xX6/9FxzsN
         gZf7767PjMaI6g4wICB5rTt7DNHfSLWXH+ODxLFgFcZn2cdV8rOiWfxz2rxyv0aFh8U5
         FaIcgo727h+y3UyEzW+NECPUdS4SR1seg/n78MUBX38CPOxY2MBkxag7QF+fyu6e+KDk
         Ounk1NQFfcRQIbRE7/lhmEWpLz0nnm5ft+RlElJMR3I1fFP8fjl3PGRAJ06jBBfFKXZK
         5r83ddBnacRTyModZaQ//uAU6QBLuA+5LL4OYGlHIy+mki9CPXpvkK6iqVvTRolJeeBK
         iT/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=u7V8Y/svVqpZMFRwTixoQtso+KwwiAflO76wYwcLCwc=;
        b=nWVYD+pabNfCD3QcHrOLR8XMmytFRtv6aKnsXe8kMp+6C+ef2YMbI/tl1rIfAA+dMN
         EH/ZfjR/Z9/OrOcuIObyf1cBUZd54SKx5LRtoHEwybQHuIsHW7HXGYJM1YKb30q2D2+f
         sZXfV/Jz8wm0OE47zMB77R+Y8Z3kfWL5di+DN03e3Qz4UOEBemq81HzvVbWaZrmf8QCe
         c1gKeNHIqg5U9TUinkOknmLWDy92TgfL3n5GXxUkqBWiAWaE9hJeGzUtp8kPQ2CQd3ge
         mU54fGZTJ2vAHbtnIT+5EV7om5cDHvY/fnFeGO7cLyPYr8ctWaeTwuL/TgDpXDWH9YAb
         0gUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AJAnkSq9;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11sor5776711ywg.9.2019.06.24.02.41.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 02:41:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AJAnkSq9;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=u7V8Y/svVqpZMFRwTixoQtso+KwwiAflO76wYwcLCwc=;
        b=AJAnkSq9urX/SgB0iyZYZ3sYrMhkBQbukYZV9Tk0Q8YPBamjJueRwljXf0tlIb9GTS
         vKOnQh36JFOo9tlUIfmufWeXo7VMM7ZNYZL+zX29WjYRNh88l9Kk+9lp5LZzPQx1cvJI
         wwA0nT7R/ywdSw1wPOQGMYhAi5syDHaQ2cXHDlY2M+jqVI0DsynY9yTQKAV73r1xScR8
         s2/jyMheB4ubCIUkEDEPXsF+pIGy8Y+sWNKSLvMtTqbWgkRhUlvOzWZtcvvk56cKMvQj
         XECr1nWzZhjRNseymLXV9rZe0hw9AafFPvkGCDNUbvStkh6NuKMhfCPTziG2/i88Jvtl
         tPgQ==
X-Google-Smtp-Source: APXvYqzCtMpSgY48T3u1VN3+5omx2myWrqHuWpKYIdbGpQAXuo+geGpyiy7nfmKnmoYZYTH/0r4k4Ek8y8eMikufcaE=
X-Received: by 2002:a81:1bc5:: with SMTP id b188mr46386195ywb.232.1561369299261;
 Mon, 24 Jun 2019 02:41:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190624050937.6977-1-houweitaoo@gmail.com>
In-Reply-To: <20190624050937.6977-1-houweitaoo@gmail.com>
From: Uladzislau Rezki <urezki@gmail.com>
Date: Mon, 24 Jun 2019 11:41:28 +0200
Message-ID: <CA+KHdyWTst1GFUC3JqHAieuV19UdR67LEPhvDKYZ569u2L1qbA@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: fix a compile warning in mm
To: Weitao Hou <houweitaoo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Penyaev <rpenyaev@suse.de>, 
	Roman Gushchin <guro@fb.com>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Hou.

It has already been fixed. Please have a look at:

https://ozlabs.org/~akpm/mmotm/broken-out/mm-vmalloc-avoid-bogus-wmaybe-uni=
nitialized-warning.patch
https://ozlabs.org/~akpm/mmotm/broken-out/mm-vmalloc-avoid-bogus-wmaybe-uni=
nitialized-warning-fix.patch

--
Vlad Rezki

On Mon, Jun 24, 2019 at 7:09 AM Weitao Hou <houweitaoo@gmail.com> wrote:
>
> mm/vmalloc.c: In function =E2=80=98pcpu_get_vm_areas=E2=80=99:
> mm/vmalloc.c:976:4: warning: =E2=80=98lva=E2=80=99 may be used uninitiali=
zed in
> this function [-Wmaybe-uninitialized]
> insert_vmap_area_augment(lva, &va->rb_node,
>
> Signed-off-by: Weitao Hou <houweitaoo@gmail.com>
> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 4c9e150e5ad3..78c5617fdf3f 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -913,7 +913,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
>         unsigned long nva_start_addr, unsigned long size,
>         enum fit_type type)
>  {
> -       struct vmap_area *lva;
> +       struct vmap_area *lva =3D NULL;
>
>         if (type =3D=3D FL_FIT_TYPE) {
>                 /*
> --
> 2.18.0
>


--=20
Uladzislau Rezki

