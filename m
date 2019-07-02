Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DD33C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:18:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1AF021BE2
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:18:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="OuN/4pti"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1AF021BE2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CEF06B0003; Tue,  2 Jul 2019 19:18:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A70B8E0003; Tue,  2 Jul 2019 19:18:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BD3D8E0001; Tue,  2 Jul 2019 19:18:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02CE06B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 19:18:01 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w123so228980oie.21
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 16:18:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=u5UwRiHjXkEAlhFHmvxN8ePNlS4fXC/47jr2WEGpIzo=;
        b=l7eH8R4Y3a5doiQsBHTkrwGcMCjmI/0s0S1JMenTKbietz4G2YJTuQM2kFiujdQYEa
         oC4MW2D+iLObEerH4agSrSo0dZeJlpOte9R5xgaDKrI60dLN78Du1sQU6n/JdJ6l73zA
         zZsq/koQ1w/IYTyC4uwRnnOZ2jFe39/DEHpaqCw1Gl1ILm8eVu+wqt2Obt7eJDzV/Rva
         eK4ILr9sh1i+qohjRy6wSidJ2/likSbbMW1fw7BKbzUV3WLnwyZhQENXQKVIBGDKOq4X
         wh6BRSza2vnjpnIxGI1Url9fWyzoZCslRATYXFHCnKX0pZRVPT6h/zvmPfdjFVj3E9Zk
         mkdg==
X-Gm-Message-State: APjAAAU6f1wc5xT8M/rBX3d/Jx9mxbyyi6ipJLv7mq9ZEPb7X5l8uDAq
	HEtJaQ+Ga6ZNJIbigu4mpdCMR+Aiygxe2ewgohBGKxKrWKBFMd6FNqQiuyVHGxcEQPRVydtOL7H
	iWaZRnLFpxkajpxUnzaF9tMKxCB2J6YcsuDPpVeWgRNZmIflGErYEAa+I98PQxq9gww==
X-Received: by 2002:aca:ac4d:: with SMTP id v74mr1390883oie.66.1562109480612;
        Tue, 02 Jul 2019 16:18:00 -0700 (PDT)
X-Received: by 2002:aca:ac4d:: with SMTP id v74mr1390853oie.66.1562109479861;
        Tue, 02 Jul 2019 16:17:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562109479; cv=none;
        d=google.com; s=arc-20160816;
        b=k3Zbxs1mwAY+FFhVzx9conYW3+V4bLS4dbWlyLX5sofFb5u+cp9VHyXH2B3wdpBNeV
         BAQJyZ44HaKp4IQiTEEEr9FgebYQX4fYpuWYIfSv78hlTefS/ZOvk4EoIZU7PStFsxXC
         RFVKL+rRLKAsjg9PW4MjQZxfamvHPN9P7vTZCFebrtqLExP30lZ7EB9l3K5XCf4iCJS1
         gAohfZ7YlQZes44mMXzES9xb9eDSqYYtYib30MZgHzOuLhTymHxb0Gp8ZSDalRdeV/VM
         iTJIkuT8zhsIyn2vQ6jKlxYhDFTktNaV8APyHy6tFMz66uATKlpQhf9u6KGVqrrStx/g
         gysg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=u5UwRiHjXkEAlhFHmvxN8ePNlS4fXC/47jr2WEGpIzo=;
        b=ltpYRfOu8aMznacu/y0OJ/9yCYjvD0CCYYEeZ9luNVOz/Hpm/GY1oNkoxqv2RPFxU0
         6nJEiQmvek97nHwQDAfIsLF5P1Yi9/DfHsW5c56cXtmiyiu3CuU/kF5Y/zx9FH0zV0xr
         3FI1gF7LARr/A6MvBPef2GVN0ScIR6b3lQwFXfKIxw5gotS82r/rfsfBlITj4eGs5l+r
         2s48lFDopaHl0cS6zV/mBWPPhDpCoqf9LBS9MYe5fK0wFIRCR+/n+auJvgd6e4fTgaz/
         v8PlfAuycBbCcSfs2CCUp3DfpIIG6o/DBwrOu4wkexgizLH3GYfiJ8i8x1UhHVGEY1h4
         iJdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="OuN/4pti";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor76421oig.161.2019.07.02.16.17.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 16:17:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="OuN/4pti";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=u5UwRiHjXkEAlhFHmvxN8ePNlS4fXC/47jr2WEGpIzo=;
        b=OuN/4ptiyR+plJoUbh14HMfrLiUOlvumFP0tzROycbsFqfygYxNO3xqFi028k9qP6U
         2hsxYQ/2r3+ffTRQvqv/sCf8RYf+3AvuvLqH7ogDKbeVFyv/k7MsfBkCxG4uRyEvLytD
         3hBMhCKOWYcfttKhsfT8Y19T3NlQHBTeuu1o3bC0SKi1LDuyTUAXjHnls8TPzw595KLC
         nNTom92Iwyk5ROjrmSXSDkHChpxbNbnGWGRWyw3laBL4fIp/E7U50dYgr8AGkfNKV1ux
         j9NiIvFe4orlhguGifJ7Su4YhO973/sL8kBVtipoBIsWxN1zYFyjnK/YO/aROHHw66yH
         203w==
X-Google-Smtp-Source: APXvYqyLlYpHy9+AMc/X38t5BFMinZJQ01XTqDg0vHmjdWTN0eXoTzXdkzMkhqYvcnewmJArWXl9rZoSGD4d6S4ISik=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr4183998oih.73.1562109479302;
 Tue, 02 Jul 2019 16:17:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190701062020.19239-1-hch@lst.de> <20190701082517.GA22461@lst.de>
 <20190702184201.GO31718@mellanox.com>
In-Reply-To: <20190702184201.GO31718@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 2 Jul 2019 16:17:48 -0700
Message-ID: <CAPcyv4iWXJ-c7LahPD=Qt4RuDNTU7w_8HjsitDuj3cxngzb56g@mail.gmail.com>
Subject: Re: dev_pagemap related cleanups v4
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 11:42 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Mon, Jul 01, 2019 at 10:25:17AM +0200, Christoph Hellwig wrote:
> > And I've demonstrated that I can't send patch series..  While this
> > has all the right patches, it also has the extra patches already
> > in the hmm tree, and four extra patches I wanted to send once
> > this series is merged.  I'll give up for now, please use the git
> > url for anything serious, as it contains the right thing.
>
> Okay, I sorted it all out and temporarily put it here:
>
> https://github.com/jgunthorpe/linux/commits/hmm
>
> Bit involved job:
> - Took Ira's v4 patch into hmm.git and confirmed it matches what
>   Andrew has in linux-next after all the fixups
> - Checked your github v4 and the v3 that hit the mailing list were
>   substantially similar (I never did get a clean v4) and largely
>   went with the github version
> - Based CH's v4 series on -rc7 and put back the removal hunk in swap.c
>   so it compiles
> - Merge'd CH's series to hmm.git and fixed all the conflicts with Ira
>   and Ralph's patches (such that swap.c remains unchanged)
> - Added Dan's ack's and tested-by's

Looks good. Test merge (with some collisions, see below) also passes
my test suite.

>
> I think this fairly closely follows what was posted to the mailing
> list.
>
> As it was more than a simple 'git am', I'll let it sit on github until
> I hear OK's then I'll move it to kernel.org's hmm.git and it will hit
> linux-next. 0-day should also run on this whole thing from my github.
>
> What I know is outstanding:
>  - The conflicting ARM patches, I understand Andrew will handle these
>    post-linux-next
>  - The conflict with AMD GPU in -next, I am waiting to hear from AMD

Just a heads up that this also collides with the "sub-section" patches
in Andrew's tree. The resolution is straightforward, mostly just
colliding updates to arch_{add,remove}_memory() call sites in
kernel/memremap.c and collisions with pgmap_altmap() usage.

