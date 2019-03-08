Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E90E4C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 13:28:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA1C5208E4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 13:28:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m6OBewAW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA1C5208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 413188E0003; Fri,  8 Mar 2019 08:28:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C0028E0002; Fri,  8 Mar 2019 08:28:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B0358E0003; Fri,  8 Mar 2019 08:28:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDFA08E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 08:28:26 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a72so21986402pfj.19
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 05:28:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FyjpcBkC3+QXgBsEHjZu+57owpddRjqMxQQ5rKRaBBs=;
        b=aJ0PLU7L80d5Rv8acwFA6lvBC0pQaKf2TnwJ92a//IQurqh7jLi5cPyHQGDaf9EaC/
         OAxRbtLTkqSbqMF9wET15uCmu58ILbNDH8dypGcZl0yXh+bfeFF2MB5nTnWihUQ71I5n
         EzBCc/hTIbs8v8eqqXIUkG/wQryrV6p/PxE96qzuZHqKDlBboKu5TZXRrON2sQVVNxL6
         chDLWp9s5Eg5z12laAgVmHTqzjaoF3dndvuiiZMFyLohaDtP9mlHoCduQOFYYya3yvTy
         kPzsqcXE1zNGxv1khmSauZtv6lQUoPnyj2LM4j7wWoKo/LWuzK7iaxSkiiGzDP3UGZnA
         MS7g==
X-Gm-Message-State: APjAAAV9j70OtPPgaUglHId89MdWjemlhKrJghzqBN9fJQROE3uavQb5
	ZUMLDTwdYnmmg74/MlfZEes5bMw32lekhJlWG4rODJkci0W5+oSWSrB0oSKa01rHydpbapU9oAz
	fJCCHHftPcj4tJSnzXJnKrHlttVMLkUwBkynJr1o0rm+hOhTaacfMwZMGp4ByYT/f/scL9kFeAH
	3Z7zIg2YVPLp6Yviyx56zlgHo3zvMaAL8jFJhdrId6xSJUboDHEb1uClrNlJm4F0PdytCrdOa5Q
	I1AsVcSYG/JwSHVhhtAp2nWV1PQkz5ejI94v1G23catrpIHBwSD6mCplJX9DEuEhyf95zTZQjrV
	u8ugJPNsJBXDP69j+lGHgzGf1r+sGw6CmInC2kw+JTobzMH3nkzKaLbaC9YvDAuz/KaJ/W7RbqI
	7
X-Received: by 2002:a17:902:9f94:: with SMTP id g20mr19062725plq.0.1552051706437;
        Fri, 08 Mar 2019 05:28:26 -0800 (PST)
X-Received: by 2002:a17:902:9f94:: with SMTP id g20mr19062653plq.0.1552051705492;
        Fri, 08 Mar 2019 05:28:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552051705; cv=none;
        d=google.com; s=arc-20160816;
        b=PmPrOXcuyA9Sut3Ib7QhV2E0J8BXMXDfvYwrDGLxN+j+r33VWWt+i9wF0ZjAmEz3bD
         sGySI5pIlR29CL+xa9TBIPTSvunIGJhbQWqIY8LkmOGvPbsw1YGOQsf3WXSomYQmnvWg
         eCATpCuKUjWz3XbyuryFXwgA06tRYS9fMS1qnNhrO0Y3Uhaer7Q0B8Fi5oI9RkI6jooU
         j2o4ELSBZY9v7YThkohS934QmFUVN7OJNHr1UVxTgbeYrnLABq6kK7z4SxkErEhtyT3Y
         ywPLs29QcXGG6ALHMJ2r1zY52lz3K4zjPZrqmtghb53UzoVrzKKhx6UwzkqGe7oyMJGh
         NZXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FyjpcBkC3+QXgBsEHjZu+57owpddRjqMxQQ5rKRaBBs=;
        b=JtUkh9FFOkzbm23exCnKRTFLnweSc6RX2swnU9gkbLpoCaaawNLyPU5xhqaS5eNx99
         AtgBr90jDd3N7jDs9MkoK6cd4MUmbdXw1/b0AqhoTTMDZORqKOSC2WjaINyjB+o2Px7L
         5/DosqAHEQzJZ1pfpXYi8NH/JT96KmuiZpy5ZLk4DPmIC4ZKJzSDmWisaMFYpG/mzw04
         fppFDwP/HymJRjWqDR5Zq+d9zDvWwta82ipBqkaMXB7RecslGYywGJf23B3XHF0bbEEv
         55wbNRL0rnPG9s9Adve9B0QZAPP2o+TNrXrMdIzrfh2YKf57GPYOCmRDWA+0kzCzDP2m
         czgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m6OBewAW;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j31sor12483555pgb.10.2019.03.08.05.28.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 05:28:25 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m6OBewAW;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FyjpcBkC3+QXgBsEHjZu+57owpddRjqMxQQ5rKRaBBs=;
        b=m6OBewAWjkywbpCPTSZabjiZXhK9buy+zAMSO87deXEe85TsdqiOb82Ps2UO9CaQwj
         SdTfU95zwNKBM3pwRRNO/1GwzPAygbEFDWXL2MRjqR5MtUcp6OZ6P88u36nSn3uQYkk5
         Iw7dypPK0jor2LxLRL4mOcoIqGjdpVOrdGaPhkCY7cZRbiVfKcszX4i9YDVZrbAjb3Uk
         8PAylcobfSsQ73t/dXOTVgoUorAjAbtXboW+Pr3fPMDS9KiIDS50MFl5h39BwdlVlA2K
         GrLLBo1K/6nu1mtaxtwg3b+/P8ByJI5Yrwg5awMFQ7W121ITksrDtw2gYsmvfeO6OQa9
         GhPw==
X-Google-Smtp-Source: APXvYqyu0BPW0Y9CUwYxR0k8WbBupMRI6PneB77HpPmxRnIqWxoBwJhmZog67CqS6mTUUH4Fzm4ztWenK+uQk7wDVBI=
X-Received: by 2002:a65:6651:: with SMTP id z17mr15878595pgv.95.1552051704883;
 Fri, 08 Mar 2019 05:28:24 -0800 (PST)
MIME-Version: 1.0
References: <20190307185244.54648-1-cai@lca.pw>
In-Reply-To: <20190307185244.54648-1-cai@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 8 Mar 2019 14:28:14 +0100
Message-ID: <CAAeHK+xdGubYXJiJi7J=1NH+-iB_yhXgoMWqacf=xh5UnugO1A@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix variable 'tag' set but not used warning
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 7:53 PM Qian Cai <cai@lca.pw> wrote:
>
> set_tag() compiles away when CONFIG_KASAN_SW_TAGS=n, so make
> arch_kasan_set_tag() a static inline function to fix warnings below.
>
> mm/kasan/common.c: In function '__kasan_kmalloc':
> mm/kasan/common.c:475:5: warning: variable 'tag' set but not used
> [-Wunused-but-set-variable]
>   u8 tag;
>      ^~~
>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/kasan/kasan.h | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 3e0c11f7d7a1..3ce956efa0cb 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -163,7 +163,10 @@ static inline u8 random_tag(void)
>  #endif
>
>  #ifndef arch_kasan_set_tag
> -#define arch_kasan_set_tag(addr, tag)  ((void *)(addr))
> +static inline const void *arch_kasan_set_tag(const void *addr, u8 tag)
> +{
> +       return addr;
> +}
>  #endif
>  #ifndef arch_kasan_reset_tag
>  #define arch_kasan_reset_tag(addr)     ((void *)(addr))
> --
> 2.17.2 (Apple Git-113)
>

Reviewed-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

