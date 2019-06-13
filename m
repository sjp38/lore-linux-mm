Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AC09C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59DE2173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:05:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qc01olia"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59DE2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DD936B0006; Thu, 13 Jun 2019 09:05:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 667776B000C; Thu, 13 Jun 2019 09:05:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 508796B000E; Thu, 13 Jun 2019 09:05:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0496B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:05:36 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id p12so15006414iog.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:05:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=COMq1DZp1tUFDOVJCz+Oc5oRle5W+TVy2bbvRpSIdF4=;
        b=Y6RiOWPhwU4ALsgiIY/0H6mzVPz+D1uOFeC93kyX2HA95EFBe5Bv2fjZLhV8QuI/k8
         Y3cs78zTD7y/CqcLopn30Sg01Cv3sBrYGi0CtdZKfBIun8YHf5+cuK0SS5UHZCQL5Qfz
         1d5tQJi/bqwjpKMB8Kh12sReiO1lNTYRnhEt/7AtF/c0K/LYL951+96wis355jfCZ4gN
         igUpOJ+LUaKiB2SR0dukeHGhNN6C0d8uEk62zC3r7GTzoTArfO9RE0xA0v/ISqlW5H7u
         TuYY0nkHCLRcgL4t8FahuLVl5n0bFFNTfAGMYBgHpuyl/lFi/+ut5IdM5hfqXCqeJt3C
         PudQ==
X-Gm-Message-State: APjAAAVpww48/nPhIYTZb6tiI+TG/kNI+kVRnqFh5MFV12u1uBbtNtTV
	T7fP49g/ZYMm/IgFg1d1F5Ys46hU8y+dlzqkcnhzthn7uoLLRCjvQgqNKhxvxmQk2bvWKoyL8Km
	iA1Ps8de9dkWPBWumeHaidaN9T5Jjsel+SryeZ00SdaLgrQxNBYlWgZpxU/C+7Ot8tg==
X-Received: by 2002:a02:40c8:: with SMTP id n191mr31843719jaa.14.1560431135907;
        Thu, 13 Jun 2019 06:05:35 -0700 (PDT)
X-Received: by 2002:a02:40c8:: with SMTP id n191mr31843602jaa.14.1560431134951;
        Thu, 13 Jun 2019 06:05:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560431116; cv=none;
        d=google.com; s=arc-20160816;
        b=v5HLibmDCdY2o46XE/2TdM01+tJItcTNCHGoE7YW5V0YshKTgmkwGX7AZVcwh2Kf4K
         u+o4D2jsfU1aHB/jQQdB48C6Hb5/S2yHrb5hxT+oWq2rUiQOE0tlkz7rsUh+OsnePHbI
         ncTsXbTBZvTpbn+9rL8c/dqx5YLrs3Qay8n20yo2KSPU0nwD+0KEPdefOhPoZHVLYVKr
         3bz0CyTU05bd+5h4sM+WD/mFwwRYq6ooz1vN6RXHfwLDwcWRr24pZHU9sHCk6SvkzsVU
         rKG4NJRDv8qJpO0xwlqNOr9rlO7cajgppi2I8Kvbng5alK4CQMQYPZZbWEuVu/fqLgjq
         AjyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=COMq1DZp1tUFDOVJCz+Oc5oRle5W+TVy2bbvRpSIdF4=;
        b=0+mjxoVeZjyZ0M3HsaH/b3LSTi7oc+YJ14sU4bDmt/0TS+riV/vJjKs7B5N5k32WuI
         hsy1shFyKzXziZrHGvEUL+BsCZdNUTlwwXMROvZIg6P0BgfMzt/CC8XVzdcN5LmnjqCG
         2cma8GLgTyjH97RA8SOpZZtKd/PMhovNCrjJrlFdx06Un7wQdM7A4Mcp7JOySSezYczo
         C8APZsGAyyJ2IhejKwsmiK726+VT4sQnThCI5v7YhzLJqlU3mBoztP9AISyESVl/tMOA
         4Z8IdBQMk1hP9STVbaAeIJwP7Zgjf0E73StxETp+eFwxVjTjcuR9NaWZO6oDJ/aIwmCq
         Pyow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qc01olia;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n200sor1707165iod.116.2019.06.13.06.05.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 06:05:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qc01olia;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=COMq1DZp1tUFDOVJCz+Oc5oRle5W+TVy2bbvRpSIdF4=;
        b=qc01olia4cmwrnoPTe2ZFrmw8g/xeegnMkBjI6b5n3TIdaetazObaCuOVxxJGxztfx
         UWxdZDvZDFYmTfiHnlGPUNiNlz24GdHLSttZMTJdYvj6tFmu3BtHAev5gqLNhXvSPYnM
         NsXWoj0lkbckrxBeZEJgG5KoxPDrFhBmupApL0hfeJS3hCMIKbbkjYDoZCw2sNnAkwZQ
         6cKSZeJReF8wUT0bqEHGB7mByLnj/TeKWcvCjWas4NwnEgzQpNFuh3wA5GgvZBs88li2
         oNEgWYm244rN1o23TzoBUZ+n2kFqLpUW00bU/764tbCeMtdqKf/ChMz/FSj1569Oj9Ra
         UQvg==
X-Google-Smtp-Source: APXvYqx+Wyo9dQ01vmbb1QVMUlNB4LxKek/Z4JsplxvhFxRKIXJWRUTg5jAa3SaPJ4zJ8mK/k/T7Pj1+pIKN6neeKaQ=
X-Received: by 2002:a5d:80d6:: with SMTP id h22mr6100497ior.231.1560431115386;
 Thu, 13 Jun 2019 06:05:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com> <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
In-Reply-To: <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 13 Jun 2019 15:05:04 +0200
Message-ID: <CACT4Y+ZGEmGE2LFmRfPGgtUGwBqyL+s_CSp5DCpWGanTJCRcXw@mail.gmail.com>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Walter Wu <walter-zh.wu@mediatek.com>, Alexander Potapenko <glider@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, 
	Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, 
	"Jason A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	linux-mediatek@lists.infradead.org, wsd_upstream <wsd_upstream@mediatek.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 2:27 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 6/13/19 11:13 AM, Walter Wu wrote:
> > This patch adds memory corruption identification at bug report for
> > software tag-based mode, the report show whether it is "use-after-free"
> > or "out-of-bound" error instead of "invalid-access" error.This will make
> > it easier for programmers to see the memory corruption problem.
> >
> > Now we extend the quarantine to support both generic and tag-based kasan.
> > For tag-based kasan, the quarantine stores only freed object information
> > to check if an object is freed recently. When tag-based kasan reports an
> > error, we can check if the tagged addr is in the quarantine and make a
> > good guess if the object is more like "use-after-free" or "out-of-bound".
> >
>
>
> We already have all the information and don't need the quarantine to make such guess.
> Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> otherwise it's use-after-free.
>
> In pseudo-code it's something like this:
>
> u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
>
> if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
>         // out-of-bounds
> else
>         // use-after-free

But we don't have redzones in tag mode (intentionally), so unless I am
missing something we don't have the necessary info. Both cases look
the same -- we hit a different tag.
There may only be a small trailer for kmalloc-allocated objects that
is painted with a different tag. I don't remember if we actually use a
different tag for the trailer. Since tag mode granularity is 16 bytes,
for smaller objects the trailer is impossible at all.

