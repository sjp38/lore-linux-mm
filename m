Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66E4EC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1217A20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:22:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="iGTfGVa/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1217A20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EFB16B0269; Thu, 11 Apr 2019 16:22:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89EFB6B026A; Thu, 11 Apr 2019 16:22:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 766E36B026B; Thu, 11 Apr 2019 16:22:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAB36B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:22:40 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r84so3440008oia.9
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:22:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VUHJ1TIXCvXmT3GI7LoOGpDhaRQ0yHBgfaQJjVlgFKc=;
        b=UKOSJj8HXxMKQ+OAapmaRcOxf20DDOm37R1L00rHR6Rr2xGnfQoXUMPElUBvynZ1On
         7RrDZppXL069EyHT769QbW7S5ZgdW+75f8Ig2fNEhKTFnBfDScU45s5HWkr3G9Hyxxkp
         ICJZVMcE2JlX0IGrKAFu7dnnww90DRJRtZ6IbQcK2gvNgml7AKct2SMzSTsf52nloiHw
         eMIIpsmBhNHiKJG9tR5zWZaeG221Ay5ZADRt7AFW4344V+FXJYfWUi6hHximUXAa2vVg
         kAvuD2N46CiwfjriRkVETJ2AmPv6kq9OGmZT72DaiM+vHkEexXxS+0HqqF8q7RHPYRhx
         ycVA==
X-Gm-Message-State: APjAAAWJAxskOn/5yyFXBKb6EKKZHysOPHHjzD8eNFwzINpZsM8TNfCc
	M+mByVmOGK3KdFCbWN7wbezZQAfegSQIr/FhJ2BfXxq7S3C1r7vQmY52QZX7V0wjCqMWw4KSLTJ
	WQK0Y2oHL0hvxL8Y5dNUQCeYyQNpopyKzzS/tPOj4gx+6XPwy4jkpJu30TyBepq4f1Q==
X-Received: by 2002:aca:ba0b:: with SMTP id k11mr7642075oif.57.1555014159957;
        Thu, 11 Apr 2019 13:22:39 -0700 (PDT)
X-Received: by 2002:aca:ba0b:: with SMTP id k11mr7642043oif.57.1555014159239;
        Thu, 11 Apr 2019 13:22:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555014159; cv=none;
        d=google.com; s=arc-20160816;
        b=xaWOJ2CCyLzEdEieFoaYgABI3MuJh5OL6nJ+LGXJVwEHWmS+LWRExfE1S01fg+Ppt9
         T/0wiTk+GWFZUn04lkI0anT25ThxDQpo9JLC6BsM8+BywBbARlZGNasakPb0cb+JOqzN
         Lh/RjwS2XSRaTDbjxtUpFYm98x38AuAyfwmt/Agn4lZNOzBZyKAozjxzlduT1t+rMF32
         ckm2e2/2O2C4rxHVOTM4eGrRQZhxgXHa984V67TVYotMy1GwI2qfOcn0QgNlNNSp+Qup
         LCs5255/K8W13BhPwsktckQ0P3U0cOXExFYbTPfn1CH6PsbB5dqpom+KPSuKxEFQbfJZ
         sQhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VUHJ1TIXCvXmT3GI7LoOGpDhaRQ0yHBgfaQJjVlgFKc=;
        b=FD/KxptR9VmtqOf4PkTDuLzyBUDyvlOETB0f+ZL+gY87gmelwaeen5+WDWfSoP7KIs
         5TSSxetvA9YsGqPOk0BjEc0+IiB220lPQVVMNPVU7rvHE8jK+3BSfeb5JJIrCN7I1IyZ
         m0xWhPyjQFMiCaEioGkg9KjZqUly1QuiX+qDf63VIm4Ua+FKcRiJdMxVvP7XHorzKPkz
         mDbsp0Qj1YTvEqwzzP3Mf3952lr9nPdXmL0MBsFD6QhHFr5qAjRyEH/0tHS4i6a32nv+
         CZxERMfEw2QjAezgN/OKmDCPHpYv2JJ1Uv+R1nk7+smnwE1mdZ1vjZJM9iXvddngniWU
         tv4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="iGTfGVa/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13sor20576787oih.174.2019.04.11.13.22.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 13:22:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="iGTfGVa/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VUHJ1TIXCvXmT3GI7LoOGpDhaRQ0yHBgfaQJjVlgFKc=;
        b=iGTfGVa/iCd//+/eSY+LjGsgPNiemp5bROhTJmrOUgMix31u1QqcXJm02g8O3ewky5
         5xOSUGSZuG7M8Mk2LRIdiMDT626+2x5Ox8D0hR47qJS7tmYPD7EDiZNaTtOiAr/PJ/HR
         hMelAIfQ+Oq5bJ6jPAUxMgAQTH5jWPLTz8OfZasIXrt00NGSzXLsx0btLTXI2nNseEch
         BwzDa/1l8V1QwoJp41DJjGjKyHE65c8Latqs3xSRKOleFMjZ7WmeQX4xHgi9mevHoYIn
         Cl4AkYFX4tH/1ymSRjI2Rll/LSr6TPW/Ze8wGPBTKdi1bQT5C4Cq3uw7JY6HgDJYZNeB
         S9Vw==
X-Google-Smtp-Source: APXvYqynFTxt5ZPvH52KHUBPpBZSkhfJWm+GY05mVgf4q2YjMg354p7Od2ETL2NP+t5fKsv64DOpIAF10Bn1WEd8t/4=
X-Received: by 2002:aca:f581:: with SMTP id t123mr8129669oih.0.1555014158568;
 Thu, 11 Apr 2019 13:22:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com> <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
 <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com> <CAPcyv4hMNiiM11ULjbOnOf=9N=yCABCRsAYLpjXs+98bRoRpCA@mail.gmail.com>
 <36faea07-139c-b97d-3585-f7d6d362abc3@collabora.com> <20190306140529.GG3549@rapoport-lnx>
 <21d138a5-13e4-9e83-d7fe-e0639a8d180a@collabora.com> <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
 <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
 <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com>
 <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com> <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com>
In-Reply-To: <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 11 Apr 2019 13:22:27 -0700
Message-ID: <CAPcyv4i8xhA6B5e=YBq2Z5kooyUpYZ8Bv9qov-mvqm4Uz=KLWQ@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Guenter Roeck <groeck@google.com>
Cc: Kees Cook <keescook@chromium.org>, kernelci@groups.io, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Adrian Reber <adrian@lisas.de>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Linux MM <linux-mm@kvack.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Richard Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 1:08 PM Guenter Roeck <groeck@google.com> wrote:
>
> On Thu, Apr 11, 2019 at 10:35 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Thu, Apr 11, 2019 at 9:42 AM Guenter Roeck <groeck@google.com> wrote:
> > >
> > > On Thu, Apr 11, 2019 at 9:19 AM Kees Cook <keescook@chromium.org> wrote:
> > > >
> > > > On Thu, Mar 7, 2019 at 7:43 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > > > > I went ahead and acquired one of these boards to see if I can can
> > > > > debug this locally.
> > > >
> > > > Hi! Any progress on this? Might it be possible to unblock this series
> > > > for v5.2 by adding a temporary "not on ARM" flag?
> > > >
> > >
> > > Can someone send me a pointer to the series in question ? I would like
> > > to run it through my testbed.
> >
> > It's already in -mm and linux-next (",mm: shuffle initial free memory
> > to improve memory-side-cache utilization") but it gets enabled with
> > CONFIG_SHUFFLE_PAGE_ALLOCATOR=y (which was made the default briefly in
> > -mm which triggered problems on ARM as was reverted).
> >
>
> Boot tests report
>
> Qemu test results:
>     total: 345 pass: 345 fail: 0
>
> This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
> and the known crashes fixed.

In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
kernel command line option "page_alloc.shuffle=1"

...so I doubt you are running with shuffling enabled. Another way to
double check is:

   cat /sys/module/page_alloc/parameters/shuffle

