Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BEFCC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:14:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B77E20859
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:14:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="uZRKdTAp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B77E20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE3698E003A; Wed, 20 Feb 2019 17:14:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB8E68E0002; Wed, 20 Feb 2019 17:14:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA9858E003A; Wed, 20 Feb 2019 17:14:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B35C8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:14:06 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id d25so22215611otq.2
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:14:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CVjBnSUI6LhspCqy+73O1/b+atYXeJzMReN5ofxv4gU=;
        b=f6dQMKhRe036UND2Ryjfut38TZJvqbv36FlW1NASw57h7i14kum/M28lOm/1S1wIJS
         IJ2EgtmpOO829LgNhDGIpAfZB8cId/k/ahJKTx5TGDpaLKh2XczfPjzgZboH3SbpMneM
         zEye7tQ+894rXj6mWDkcnIDQ4/8EZUFdzA/8ZH1EI1gxdFoOcsay6Spb7Zx8rHSGaxgQ
         BxKg2W0Fl68Ml94FatRks8Ho+gjvFHpWuGyQL6gPvS5lKRHdnYz9PmHFi4TKHtun9QRX
         /6xRvZWx6PVWIOpsAZi7OeG1UqY3dnUv14jDTVlJuuNqGRags8AatBTBto+HpHVqSfiK
         6BVA==
X-Gm-Message-State: AHQUAuY7UYiI2e1nADDcRnbi7ZHZifWUR1/L/mJaLvHs1AGBUWc0odYp
	D80xuNy85N7XsKQSjLOOXLKlOnDYOjTquKKry38hGlv6tfwEudzSqLAoprLB/agFgW+Emw2LD1K
	BVriNxrBpbaMVQLiS/0/ue4uFtm7pB2qEeFVE7JnCHlYQ7Y9yEm1dD3oJsK2M3fdDrenhTShiCI
	XGbXTsFVgRDA6f8otTAdn1IyUn99e5RlDlNPG+mg3V7n1HQ9JdlSmFp7qFEIcSN7glw4EaUSR0M
	LxXx2iYo/q5y6KDPGy2MGk3wGaFU18QgOtv4H/qhW9Fvezv9tOHNo+RjYeMoUgE6erlQUCoAsvE
	sbWyQlur7PtFY74NwiZVHE60eHmUmolYgChpe/VR3eujnG7qMRuWxztJJpkJoHJGBBShX2gpLbE
	Y
X-Received: by 2002:a05:6830:1292:: with SMTP id z18mr22582970otp.161.1550700846228;
        Wed, 20 Feb 2019 14:14:06 -0800 (PST)
X-Received: by 2002:a05:6830:1292:: with SMTP id z18mr22582942otp.161.1550700845651;
        Wed, 20 Feb 2019 14:14:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550700845; cv=none;
        d=google.com; s=arc-20160816;
        b=nQXadxWDJnfwY3+BadQtD/ACyN9Atbj7wtyOERXNpEKifoD6emIe47OAztj8yoGkJj
         wYXeS/yU/OkaY18pSKz8zzzYFAK0BzGERCD8UJ76w4AOPisu+YBOHIFkAt2veUsZidbD
         lcj1sLWF2lWYSp2IcG8cplEuhxtrHgNaHfDXJlkgqjiOm5s02UsjCzX7o8S+8Whkc6bw
         /vYKh9IPIA86qlkY4yZR79f1c1wmvWoR5pMzMZqCX280d6VQXFMyYAcc35NSATejHnht
         bTESkso3+OmDnw7KllYZ/WtRL9BSB5UTAx/pGwmeiZBirMn9Tt8a36WC/7JFVQITqmQ+
         rjTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CVjBnSUI6LhspCqy+73O1/b+atYXeJzMReN5ofxv4gU=;
        b=FfjsvsNaVDnngxSogT4akLL023ryiYo2CDaxdStlaZquptTPpYi1zjRuirAcS1B65b
         g47Ik4DCdhCCr84wy6l+RzIdUybqmYNhs863L2RwR9DmLiza5YBeIYjCamjjB4qk8lam
         ZvH1b3+sERW2dhAtQSTXhaprG3gpgtKIJB68ZwXRpx2QxyHnmhqrZ/c6t4cwcNnk/20p
         sdXs9NP+nZmLMGt/f23mko5Xt7yPjt7/hxLeFyscAYAdrPylEC7OlDjSexq8EiyYNGrX
         U6riIQ2u4q+mcOZ5IlaUDmx0N0WqbEAEoAMjk7vfanLcIsy+laYeU3SVjp1S7j+s5Ubv
         XCuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=uZRKdTAp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g13sor10124511otn.127.2019.02.20.14.14.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:14:05 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=uZRKdTAp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CVjBnSUI6LhspCqy+73O1/b+atYXeJzMReN5ofxv4gU=;
        b=uZRKdTApkbIvtfeHSNDjyAhSJ4BWOMaxzfeM4Z1KuDX5H9f8P/nNvwKiE+kRHCpWQo
         Pzzb8KHWZ2VnG/ITfw2dP7KQ7RX5uNV+ZJpXTaDp4yfG3VLORJdVv4AJNzl39NWjy20V
         bYPkPod9XP5K2AluOq25assvrlESWBmEs+10hqobdZX0Rr0IKEuEZ2TpY+L2qVVDGrtW
         jLuR5/oylrEgiR/2eMJ9MbgqLWjg6QyWBEpUazDYmiC4jkdLmyjnsKnj6aCCN5Rkd1b/
         nOCO5ydPM6xlBo0b9rxwC3a+4g2Ut+35mDt3GLBSRGZ2t06FAGm9awZyVSVvFwWAAejA
         DIwQ==
X-Google-Smtp-Source: AHgI3IY0GyUmAI/F9u0gGK3DKJZ+Md1zuqirUF+1bxatdGk67V7iWwe2Co33YIOqW9sjrBC59CPTREFBBrgJ5hH/5nw=
X-Received: by 2002:a9d:37b7:: with SMTP id x52mr24320675otb.214.1550700845305;
 Wed, 20 Feb 2019 14:14:05 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com> <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com>
In-Reply-To: <9ab5d6ba-4cb6-a6f1-894d-d79b77c8bc21@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 20 Feb 2019 14:13:53 -0800
Message-ID: <CAPcyv4iP032bqAgCZ8czRXkJ_gXz0H1EVC+ypf6NhKQ65aKczg@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 2:11 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/20/19 2:02 PM, Rafael J. Wysocki wrote:
> >> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> >> index c9637e2e7514..08e972ead159 100644
> >> --- a/drivers/acpi/hmat/Kconfig
> >> +++ b/drivers/acpi/hmat/Kconfig
> >> @@ -2,6 +2,7 @@
> >>  config ACPI_HMAT
> >>         bool "ACPI Heterogeneous Memory Attribute Table Support"
> >>         depends on ACPI_NUMA
> >> +       select HMEM_REPORTING
> > If you want to do this here, I'm not sure that defining HMEM_REPORTING
> > as a user-selectable option is a good idea.  In particular, I don't
> > really think that setting ACPI_HMAT without it makes a lot of sense.
> > Apart from this, the patch looks reasonable to me.
>
> I guess the question is whether we would want to allow folks to consume
> the HMAT inside the kernel while not reporting it out via
> HMEM_REPORTING.  We have some in-kernel users of the HMAT lined up like
> mitigations for memory-side caches.
>
> It's certainly possible that folks would want to consume those
> mitigations without anything in sysfs.  They might not even want or need
> NUMA support itself, for instance.
>
> So, what should we do?
>
> config HMEM_REPORTING
>         bool # no user-visible prompt
>         default y if ACPI_HMAT
>
> So folks can override in their .config, but they don't see a prompt?

I would add an "&& ACPI_NUMA" to that default as well.

