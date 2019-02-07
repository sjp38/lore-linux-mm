Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAED9C4151A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:34:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 654382077B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:34:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LqyOFZTg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 654382077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 024828E003D; Thu,  7 Feb 2019 10:34:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F16EA8E0002; Thu,  7 Feb 2019 10:34:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E07618E003D; Thu,  7 Feb 2019 10:34:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8858E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:34:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so175280pff.5
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:34:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8zLBuc0sBo52O4bloIqQvrcyfDP4dPfYY5yzFr1WIjY=;
        b=XT69dG0QXYaf0nua3Ce9/hrsg0wx/j3q3nSRfVNoW4VQJO0AwoHRT4SGJMEDltgH40
         J065rWeU2nSwgR5A2gUQj1bu8uYcn8938Fd+yDAItQxd8GuojjDB1G4zDDsvVaAeqoFE
         uqDrgT5D0DcduRicyLA8MwAIqLRhFaLkoYZCQpBZfcCpJLUOgu2I/kL2P53h4KIgZ1IS
         YODEu9fmNLv8UgzGzWWI3JnwzxLUe81/JlOfSvPpHWEvQsmomWlEsJsL/a6d5TyLZvGF
         i8+pC+JKzulk3bmTJpyEcqshVk4Im35AgesWXA1NS92nmNIuHYKLQM7FdbnXL4kat9gC
         z8mQ==
X-Gm-Message-State: AHQUAuZRp29mswmNf05WKfM9GwN9g8iH39m6b47w6WPPw32TcgzU1xNI
	wV+FuUQCzFDDnsqSPI5/tNCu2r9A+nqDUq5NYVGq6Fsh6pw3Rc/+RTWBsiylGcgNZ7DE/xOAs+H
	v+h5f0YIyUdxVK37zAUzHYxLyeMd7aqOxEDOmot/rMfwpNFBUIf2eGMjqTBQosv3RmXnTydItSR
	1guTQIQvkJ6LHn2a8Gay2RiN/V/7gn7SetNnfpfhpbnuCq73PD1J2ES4Dl+2PlEVoXPd+BvMLst
	P26pH8nDpLt581u2c/Rb+OKvjLPQe3To3Rc2VD1jCUmI/muqQ27gYN3AOETyZPM/7tEeuLZP53c
	mk02MTR51WgKGL49FbaSmBnBN2sL+eUOF+scOi1PSPdTp6f61x9vzx4uv2jb+7PIM7HYATgz6HY
	u
X-Received: by 2002:a63:c503:: with SMTP id f3mr15044254pgd.431.1549553660250;
        Thu, 07 Feb 2019 07:34:20 -0800 (PST)
X-Received: by 2002:a63:c503:: with SMTP id f3mr15044211pgd.431.1549553659619;
        Thu, 07 Feb 2019 07:34:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549553659; cv=none;
        d=google.com; s=arc-20160816;
        b=MfcjuNRnzJnhWGx7IgBJjBcwtm+BSAio6kuvGBlLAJmKL+cVAWhEk4MISL1uqXCARB
         SKT4bFRrpUJwfFlQeMUa3IEtnY75Toc82+ygrifK80rfL5qi8ypH88I8l8q0bVGKwZP0
         9jOPiKnpYj2MJ33jQWMGvcC1e1J/WkODP8ebAJF1n1RudhbninfediQrUFPl4eq+FGtw
         ZKZ7QAV0/k1VWtmPtXyjpCNPE7g0AkWrgGTi/HZL9vRtCPKkbBflsfVXub5YYJe1Scy+
         Iuifh0eKmHyKB0s4OC4cY72EUQNcIt79PvvLEXkcIAB3kQu0gRnnIeojobbxtYKdNc7+
         6ZWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8zLBuc0sBo52O4bloIqQvrcyfDP4dPfYY5yzFr1WIjY=;
        b=PDQeJ3PUKuUTvsLFkOxLiork0mMcWuPqs1WI0jgzCblhT9aFJ93+lQVLS4Rc6nhnlr
         vzhLw9woBNUm0MhqNDrCq4QY03RgX1JdipO7Hh3/fCx95y1nt6n5nt33XVZckhLDu00w
         lfUM1TwRb6v703tXmr6KrHws311YmVW3ZbiQhS4HLfZcEXJQQKDHREl/1emnalvEoIVb
         Wjhk9N+GMAtQPREcPmj9FIYZpkxXDL9yVODCZEhI9cH69DpMsTLJpFLVI0lzfzbIr1SU
         CPRL/w2YTJM0+H0ryIlhOyTaahJ5hBGzRZdvQ1jCM6TJcmHlCw/tsw1umtG/BBDfbDA6
         j4mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LqyOFZTg;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor13921031plf.73.2019.02.07.07.34.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 07:34:19 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LqyOFZTg;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8zLBuc0sBo52O4bloIqQvrcyfDP4dPfYY5yzFr1WIjY=;
        b=LqyOFZTgpwimtcg6h/ifQ1jy7jMNg8xS54lUMHN7OO8i2ohbAmeK8nOG++3dGbHUih
         cEurY7rJCDqAhQWAPQ63GToV8NK+KhKPEY50YNZOeqRDVZILlwdorLPv+WrxIK406uwa
         cRgP2cpu4+NCeOxdYKeXESNmumtxrSxsy+Yo/ucpmHz2xEIXN1hHkuBfqKGCbozJmTca
         ujQW5p+PQNeWO+tKk07FLT9zc4fSLR7LfvKBtmjt7Hecd8OX3vzz9bMzcPQLziS1XB9E
         lgKaPET3teay1WoaYU9CMZP+PVsboqyv6H7cRVbhRrk8Y6MwP1zPAW89crO3RM0psxi+
         bh+Q==
X-Google-Smtp-Source: AHgI3IZdDWszJGx7zQzLD8P5tmlbNuB2twIL3Lxhj+0O61Ipu9AXNAoqooq6906pDqScfxcNWeTRRnzsnSOCjIn2ank=
X-Received: by 2002:a17:902:8303:: with SMTP id bd3mr9087825plb.10.1549553659042;
 Thu, 07 Feb 2019 07:34:19 -0800 (PST)
MIME-Version: 1.0
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw> <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
 <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw>
In-Reply-To: <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 7 Feb 2019 16:34:06 +0100
Message-ID: <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
Subject: Re: CONFIG_KASAN_SW_TAGS=y NULL pointer dereference at freelist_dereference()
To: Qian Cai <cai@lca.pw>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: multipart/mixed; boundary="00000000000068e02505814f9370"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000068e02505814f9370
Content-Type: text/plain; charset="UTF-8"

On Thu, Feb 7, 2019 at 2:27 PM Qian Cai <cai@lca.pw> wrote:
>
>
>
> On 2/7/19 7:58 AM, Andrey Konovalov wrote:
> > On Thu, Feb 7, 2019 at 5:04 AM Qian Cai <cai@lca.pw> wrote:
> >>
> >> The kernel was compiled by clang-7.0.1 on a ThunderX2 server, and it fails to
> >> boot. CONFIG_KASAN_GENERIC=y works fine.
> >
> > Hi Qian,
> >
> > Could you share the kernel commit id and .config that you use?
>
> v5.0-rc5
>
> https://git.sr.ht/~cai/linux-debug/tree/master/config
>
> # cat /proc/cmdline
> page_poison=on crashkernel=768M earlycon page_owner=on numa_balancing=enable
> slub_debug=-

Reproduced, looks like a conflict with CONFIG_SLAB_FREELIST_HARDENED.
Could you try the attached patch?

--00000000000068e02505814f9370
Content-Type: text/x-patch; charset="US-ASCII"; name="kasan-hardened-freelist-fix.patch"
Content-Disposition: attachment; 
	filename="kasan-hardened-freelist-fix.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jrus7qij0>
X-Attachment-Id: f_jrus7qij0

ZGlmZiAtLWdpdCBhL21tL3NsdWIuYyBiL21tL3NsdWIuYwppbmRleCAxZTNkMGVjNGUyMDAuLjVm
Yjc1MDdlYjhkMSAxMDA2NDQKLS0tIGEvbW0vc2x1Yi5jCisrKyBiL21tL3NsdWIuYwpAQCAtMjQ5
LDcgKzI0OSw4IEBAIHN0YXRpYyBpbmxpbmUgdm9pZCAqZnJlZWxpc3RfcHRyKGNvbnN0IHN0cnVj
dCBrbWVtX2NhY2hlICpzLCB2b2lkICpwdHIsCiAJCQkJIHVuc2lnbmVkIGxvbmcgcHRyX2FkZHIp
CiB7CiAjaWZkZWYgQ09ORklHX1NMQUJfRlJFRUxJU1RfSEFSREVORUQKLQlyZXR1cm4gKHZvaWQg
KikoKHVuc2lnbmVkIGxvbmcpcHRyIF4gcy0+cmFuZG9tIF4gcHRyX2FkZHIpOworCXJldHVybiAo
dm9pZCAqKSgodW5zaWduZWQgbG9uZylwdHIgXiBzLT5yYW5kb20gXgorCQkJKHVuc2lnbmVkIGxv
bmcpa2FzYW5fcmVzZXRfdGFnKCh2b2lkICopcHRyX2FkZHIpKTsKICNlbHNlCiAJcmV0dXJuIHB0
cjsKICNlbmRpZgo=
--00000000000068e02505814f9370--

