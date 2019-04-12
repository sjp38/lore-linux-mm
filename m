Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D51C0C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:13:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 923A7218C3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:13:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qOPiNtjh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 923A7218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18EB56B000C; Fri, 12 Apr 2019 15:13:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 166016B000D; Fri, 12 Apr 2019 15:13:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02D146B0010; Fri, 12 Apr 2019 15:13:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB4746B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 15:13:02 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id n63so5375140ota.2
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:13:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Cjb/Jw1kYT3CwdkCeHpw/B4B9pOzyujTUh9p8dSWf7g=;
        b=JX4qP4Lgoi0vOm4DFuBFxq3IYDy0CqZyRut/f5AJnOztHj3UN/LBxZ2tRLehVBkTIt
         GVbytocuaZaQMHhwiAEgMfEbugCx2WTxhAMRu4Eaym0jKyfAH8ubzI2NBWuVOU/seB8H
         IEEzqqK5m6tJeFxYART8URMutidt46QREQsXKCLy6LUP7RcnXxlQg+uyASUjNqVNkPaQ
         VwTl7y/7pIt8M76hfS/fzcyGZ9GALTDb3fYUeQ7e6yvpqxBQOuydqMQDYeg9pLvtvaWx
         ykvfCDvpiI0MWMVnsXoIfd/8Hn61gIXH0cjZJxt5sQ5yUuIfGGv0yfQxKc0Y45+DTqRY
         xdFA==
X-Gm-Message-State: APjAAAW/tVAOvijbUYCcp4kfbaSpZYWPDZlHyjSNEkvW2rNpaQmPYXZu
	V+pbNeEoHpmR5LGbJeyhYLkoHATIcYWxWcTu4ogrZsTtKOGCciHmfKJWk562xki3wOVVBkk+vSZ
	Eggf8M2j6y0FU2xqS6Q0EK9XP344Upv/gNNAV30mOeS1DyIyQgF/NVidyeBBG0ia9MQ==
X-Received: by 2002:aca:4b56:: with SMTP id y83mr10976976oia.63.1555096382401;
        Fri, 12 Apr 2019 12:13:02 -0700 (PDT)
X-Received: by 2002:aca:4b56:: with SMTP id y83mr10976940oia.63.1555096381758;
        Fri, 12 Apr 2019 12:13:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555096381; cv=none;
        d=google.com; s=arc-20160816;
        b=Qf9f823BHMxxgG6LU9In0Y1UYajFJOmsLy+p0UQS81B7ITX6dh7HSQocckOxdaSWpY
         egHdWMDdHcmoGGqMZMMdH1z/GgEC01nDhzX8KleFk6Ya50laihAxR98nHVa12lI82oYZ
         AxymW1UBHe8mEh2yoScEidh1XbxGqbmsn/B2HuLkSVb1O4YbbS65kxMkGFY8PRFZld0Y
         LC9rb1tkffjM2YbLBWR6kW0Q2mJYiYtEbZxFa4ZoYSyZs8KF37WPgENRmuX1QZZBPl10
         9I9rlquMdK2frw5+RMY+faUdjgPU3ji3YpP8ab0PfSpvmc91MvCkgcTIBpaaphU2iXac
         zdyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Cjb/Jw1kYT3CwdkCeHpw/B4B9pOzyujTUh9p8dSWf7g=;
        b=dLnWMvFucdCHA1npW9Q4bl+aPreH+KzSlKO4HreQQ6bU0N14mFbniVEEbRGUKc64D8
         ZRMVs0qwD5el+zj8B23sCusBfHl0nwJwxqkjv/m3PcRgHQnIz+6CkxmcrlqP99hQxeyM
         U4zDXEPyAZOY9uel234UReRtOcuobfm91i70FP5YKo1H40ckwfSCTB75Vfbl03IFl6n+
         t3JzNZej46a9FmMQE+7lKIcMG17dHJFqD3kuHQIu0DMK0twDnwMEZ1ivnSeL+gEn46vR
         ovn4e/YGH8o/X0ifMw7IURJCljXPF4QdGJ8pDumz6CNtKdv6v0NftJLzk2TsSXIikdI+
         HV4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qOPiNtjh;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e83sor24347329oif.122.2019.04.12.12.13.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 12:13:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qOPiNtjh;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Cjb/Jw1kYT3CwdkCeHpw/B4B9pOzyujTUh9p8dSWf7g=;
        b=qOPiNtjhfsHHrcivyLQFuR8OxLUM441a/pqFDJ7Ihm23VNLXYRnNEf5ZCadtXfy1Bb
         bH/+WtbDeAv1BI5bE2bCLzjj6MAW7Lz9sN0irIl+eFKNM/AireWatNsg9DoUgJDe97AH
         x50W6yKuoX4s6Z/mmGcke/PvP+TGPwFvXhujik17ueQj3kGTVkrsqO0h0CCfZWpXDG1L
         VCJnD5jSlG00/ERDeLIJaK7KW/12x8qrzv3rxm3B1Upq9Dty1k30Zoil2MhCZzsziSLX
         Rdlygg4wxhOGAXpvC7j3dNN96kNtrI8bfA1b99bLzW6Q7EwqIABx3SYH/3W7XCF3/Bbp
         Nrfg==
X-Google-Smtp-Source: APXvYqyTMfUJpFFuq8fWP7BFdKu7wN/l6+qXM5aSFSP3dYO5Xa1B6man/nth6r/rgs3JIUo7K4mVyjLLDGZmpOQzsOM=
X-Received: by 2002:aca:f581:: with SMTP id t123mr11899459oih.0.1555096381187;
 Fri, 12 Apr 2019 12:13:01 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1555093412.git.robin.murphy@arm.com> <029d4af64642019a6d73c804d362d840f4eb0941.1555093412.git.robin.murphy@arm.com>
In-Reply-To: <029d4af64642019a6d73c804d362d840f4eb0941.1555093412.git.robin.murphy@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 12 Apr 2019 12:12:49 -0700
Message-ID: <CAPcyv4iYgwPJZpwUzM-ehc5F3gjO5TJ4AOz3f21ou8NrRCsEKA@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/memremap: Rename and consolidate SECTION_SIZE
To: Robin Murphy <robin.murphy@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, "Weiny, Ira" <ira.weiny@intel.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, ohall@gmail.com, 
	X86 ML <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	Anshuman Khandual <anshuman.khandual@arm.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 11:57 AM Robin Murphy <robin.murphy@arm.com> wrote:
>
> Trying to activatee ZONE_DEVICE for arm64 reveals that memremap's

s/activatee/activate/

> internal helpers for sparsemem sections conflict with and arm64's
> definitions for hugepages, which inherit the name of "sections" from
> earlier versions of the ARM architecture.
>
> Disambiguate memremap (and now HMM too) by propagating sparsemem's PA_
> prefix, to clarify that these values are in terms of addresses rather
> than PFNs (and because it's a heck of a lot easier than changing all the
> arch code). SECTION_MASK is unused, so it can just go.

Looks good to me. So good that it collides with a similar change in
the "sub-section" support series.

Acked-by: Dan Williams <dan.j.williams@intel.com>

