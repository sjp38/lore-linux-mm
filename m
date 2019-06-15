Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACA7CC31E51
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 01:14:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E76921841
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 01:14:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="tJmg62m5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E76921841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05CDB6B0006; Fri, 14 Jun 2019 21:14:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E2D6B0007; Fri, 14 Jun 2019 21:14:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E17D26B0008; Fri, 14 Jun 2019 21:14:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9C206B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 21:14:57 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id u8so1556289oie.5
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 18:14:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YXA5bt0DRqq3Y8upnzIrF6REEJIQ3rcT1NgkB5rI0Pk=;
        b=BhCNaLMFLmuUVgznKh4YNSBW5TU2BzliNhracy+AEetW9PbGWQXrvYyOoMd36gRE6M
         fByWRpXyXOE8zFPcuOH8zOduaIs3DMqU8G08qxYu49ul0DxBhkfvFenFgua8y7NKMEe8
         UJYFNEOfQhhNE+MAEYasKwFThUbdjEk6mIzdPSlcfZ5BheuLKsUHeklZHiDE1OhUywbM
         VAw+IsYzl7aoMMylzDjGSoFqx0vrHbgcnmHrLknzur81VjTn+NK0+jvgFPgTJGIecnnR
         qBMp7gdJWlXzu+vLESiYKTDMqpDkH+jWlTwjmDlr7MbMGzQM4i98PxwuGcaXxj0XqiNv
         kR/g==
X-Gm-Message-State: APjAAAXEWiaaks60GFmXKvoIP0o4qvoWPKx6AVGXM9cClD9hZRm4z9MT
	jcyGbZ6pkimXZb3PMLtBPyZt2KVqLq9WopClCNiCnjMqfcyoOrASE0W9EFGdCl7zrG1AJ+gyO0g
	2HaG1f8rHANYDAYHiEv0FW6FsWJqIaAS3Xj7dvMnf6tQuBlYoDEtURLpcDD+BvsCsyw==
X-Received: by 2002:a9d:7b43:: with SMTP id f3mr32242599oto.337.1560561297330;
        Fri, 14 Jun 2019 18:14:57 -0700 (PDT)
X-Received: by 2002:a9d:7b43:: with SMTP id f3mr32242570oto.337.1560561296672;
        Fri, 14 Jun 2019 18:14:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560561296; cv=none;
        d=google.com; s=arc-20160816;
        b=Ag+4hBAHnjt5WanBxI5CNjB0ldo7F8D/0KebhURm+yJJe1/4Ux4nZOjf/sNzHOwHK2
         KTmF3E8Jy1AcFD0wk/dcatjaJZQgfKrNgTSU6dslLssKQHa+TqoMevAXEyrqoU4o5cQI
         mtp9Yq/3E+tbkKwDwNEPvluWB8a9Vs2BvFOZl4SLQo3Z9fuEP0CQhdtQWBgJbu0QPgvw
         s0+SPAG1J5OxhDBk0qnbxVTeeV9qpqMN1PXiZrhfIghPJDT18J9twlJEy9MnO6ItheQW
         kKZxT4BV0HZqEPEJ3aFgkWZuWPD2KKpv8rjHrDoR/Cr5yl3h8QO7/YxI9nJwFp+PKpAf
         ow1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YXA5bt0DRqq3Y8upnzIrF6REEJIQ3rcT1NgkB5rI0Pk=;
        b=CbwJCC9E2U0ymCjT2xTIa5wgC752HvopjXyOGmiNf61yTYyLyIlTkjlK+3vNeiNy6s
         nAJ22iqrTL7kAA5+IYiCNuKhjHXQJhsHr/emSRq+UGS7dnEtONALMjMU7VpcgTRWr6gB
         CPyRTGcOi5VicHaP37r1iNbDg0x1csPWPj1sOy7kB4QlshXkweTdRrHhp6hm7IWaqNkj
         3Mi4oUGua7yyl9F8kltRQrXoTy8L1mO4PvGZi74PKVWQDFLFnFx+rKdxRvQNdk8CroPf
         Uma35iZ4uTyodbuViJfbzaV7YrqELHBeoN0fa4x47ZVhRRtWsdRppCsMh6pUaV5NcpDd
         RkhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tJmg62m5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u185sor1956852oia.144.2019.06.14.18.14.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 18:14:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tJmg62m5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YXA5bt0DRqq3Y8upnzIrF6REEJIQ3rcT1NgkB5rI0Pk=;
        b=tJmg62m5f5wzjStc/29QDsRE/q4PtUR7a07UcT9A+LpofKKbxhtlmCVhtiJ8URAGLA
         9oK9DJH98vQawRs0h37hjqVTMVMJWvmn1NENWEvQcKiDXa/4ypd31CJaKcQrvB78GOhr
         Qbbk6j3mpA6d1cD9ylhgqzPJxlzijRmQqwiLfaMhhoWCiFA/gFjJw+5MiA0tc2pV/9+G
         Sl4Xc+lFQQumGmBwoeyeK0hlQsDN5BV8kkty0G0+AiFUxphY9dfVKR5wzwo5PVFTO/Jr
         4+9iaNMvBJSAm3MKHtVibI6ZPeuLK1e7+r9sLGzVfNA1FoAErnV7xkbqVG7OP5TKANBO
         dkKQ==
X-Google-Smtp-Source: APXvYqxqBHyqynWE7/sHeR/K8H8EClnUTPV3/T7OxCVIwp/PZVwUGw1nUJBb42vXH0k1fSGr8eACLhIRKFpd++U1+Gw=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr3500913oih.73.1560561295806;
 Fri, 14 Jun 2019 18:14:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
 <20190614061333.GC7246@lst.de>
In-Reply-To: <20190614061333.GC7246@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Jun 2019 18:14:45 -0700
Message-ID: <CAPcyv4jmk6OBpXkuwjMn0Ovtv__2LBNMyEOWx9j5LWvWnr8f_A@mail.gmail.com>
Subject: Re: dev_pagemap related cleanups
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:14 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Thu, Jun 13, 2019 at 11:27:39AM -0700, Dan Williams wrote:
> > It also turns out the nvdimm unit tests crash with this signature on
> > that branch where base v5.2-rc3 passes:
>
> How do you run that test?

This is the unit test suite that gets kicked off by running "make
check" from the ndctl source repository. In this case it requires the
nfit_test set of modules to create a fake nvdimm environment.

The setup instructions are in the README, but feel free to send me
branches and I can kick off a test. One of these we'll get around to
making it automated for patch submissions to the linux-nvdimm mailing
list.

https://github.com/pmem/ndctl/blob/master/README.md

