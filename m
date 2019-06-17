Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3651C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C9F12084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:44:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="GEy6EGCL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C9F12084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1D8C8E0002; Mon, 17 Jun 2019 13:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA6FF8E0001; Mon, 17 Jun 2019 13:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6EAA8E0002; Mon, 17 Jun 2019 13:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9D2E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:44:30 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f14so5185442otl.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gBoBuo4G3FSgEhDC+FoktVJNloMg07m1kebASNjaow0=;
        b=h17K7HVZPGWcm6ddwK9uu9V+izUPs/wIp8Sr9CkcFA/owOUtWg8Egw5DR8+8R/XFxL
         GHGAF/BCpoPgSPkWEWwDYdClB18j8THNYcO0mw6ALoamC1AH1hVUSazBWOZ/JvM8NFGr
         cikot3NGDSGkXAtALkSlIzIoOjPIQqybV8UglONRdXVevvNTcX5PUSe40gZRf8IRjcRs
         wN8j0aIC+/BRDdErwqQ80iOwTHyFyYNPBI37QR7fCfbFcXjW/Q08Nd9bVEDd9koNt3BD
         DswJQxYTroacSnvMxzHhYekfHDS5XPzDVxqPJCaofTdCkum50R/3MJtltG+kFDynVUNm
         gtLQ==
X-Gm-Message-State: APjAAAUabDK7pJau1bWdmzTzC0dOWvv2GECgue0NtJ8qZ8LP/dSwNEF5
	Gh+UkphSt+02MJEJL0HMI7MOXUT7427rJwi7LHRvYkGLxreMJZKIeHYfb+bASOsx8HPQKvRto9o
	meaQaHkyRpcecWP3c9MNY5kamwIS9LUk1SIkrqmUvA/xjonQS9qNpKOhIHJ4JcueIhQ==
X-Received: by 2002:a05:6830:93:: with SMTP id a19mr28850953oto.127.1560793470127;
        Mon, 17 Jun 2019 10:44:30 -0700 (PDT)
X-Received: by 2002:a05:6830:93:: with SMTP id a19mr28832389oto.127.1560793045314;
        Mon, 17 Jun 2019 10:37:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560793045; cv=none;
        d=google.com; s=arc-20160816;
        b=KZMwQRb/FNDe127jFTAi/J1ZhjKEHXL+fwQdN/c6ZLDXY6weLSymqEWPS24LSjRC3z
         /a6Yij1P1xYBVsbvg5PRax3Zi8rYP2p7HO1CLMadJJF9jdYl12IvkLDU+Ws84VfL3Nq9
         9AR6DsvxAFVfqZGcXQT/faXOBkgfVfZyAjWqx9Fy/PgU7lFubRMmJNvESBuJl4iLRI60
         yR17ppM0G9vWeH6e2paJfFCp16p84KmA//7n4U6fKw4yUe4GwekXq8FdxjULyCa6jZaT
         nEJwjvAN1nGm3TBwFzckrdXJNMyWmRS6JQKtuIRHESrYirawiLcLtQ2XqPSWQuG9yAm3
         pcIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gBoBuo4G3FSgEhDC+FoktVJNloMg07m1kebASNjaow0=;
        b=vtC/u22SGfmAHZxiZriLMExBVndNb54cgntQibWCFTIxzm6arBW+XAbz8E0ubdr4Kb
         fbWFxKAWQPQzTckG2HNl6F8Htcm+lfRuuksYEW4U5ONOxN5qsTSX8VeXs13lnEr3eOa9
         sFx2kkCYdsgW7ggI8o8CI/1GNXootonGqpdGOvg7J+wy56MqGYKpoMD9LsvCMgQaz52M
         OhSNPTObnjbQg8n0jdIa5cbiiBIFX1blS5ZVuqYwsg/sM6f3amY4z5saDbDif86EOwkE
         29mYU62H2Gbg3+addIwGgcNE6yVNmjGLgbq0Yone3PaFDQuWCkXnVxyrNNFrdPEpTDAW
         FvHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GEy6EGCL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor1831425otf.164.2019.06.17.10.37.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 10:37:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GEy6EGCL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gBoBuo4G3FSgEhDC+FoktVJNloMg07m1kebASNjaow0=;
        b=GEy6EGCLZL0UwYQ9PkUNByAPZFrQNOY55J4Isr3tPIqQ98XVq0fsFEiJHE9y337UnR
         z0ckb3F0Q8bUBMwOxk3FMovLMeLeRhGzCH4bMfXl//v4SZneAiWL2E3nXGQ0kfcbkMQ5
         r05Q0aOOGSCIoONjGAUc0NUdIqrqwt9uOKpttnI5/W0wpWZ0UjI/eMzHv96YMzDyw6ea
         Iw2XLIDHbY2xAKMBDynID8VFE/XZYZnxY6Kobfxb5Ee621xVhNNWauS73uuIqKg8WlP8
         DC4G2oI80ceWohUqqQoEpsB1uZSHUXQoqzfwbmLCxnomOs9Nh6gRUrBB4UmmNwcz2q++
         zoow==
X-Google-Smtp-Source: APXvYqy6UHQ+8+yRan8DQxrtjWFO0AeHWuMCd0MZM6YFNNcDvh4g1h/fJSpQjjAZ+ZTnayEmtlW26P14xfxTxsyl170=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr25335686otf.126.1560793043776;
 Mon, 17 Jun 2019 10:37:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-7-hch@lst.de>
In-Reply-To: <20190617122733.22432-7-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 10:37:12 -0700
Message-ID: <CAPcyv4hoRR6gzTSkWnwMiUtX6jCKz2NMOhCUfXTji8f2H1v+rg@mail.gmail.com>
Subject: Re: [PATCH 06/25] mm: factor out a devm_request_free_mem_region helper
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 5:27 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Keep the physical address allocation that hmm_add_device does with the
> rest of the resource code, and allow future reuse of it without the hmm
> wrapper.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/ioport.h |  2 ++
>  kernel/resource.c      | 39 +++++++++++++++++++++++++++++++++++++++
>  mm/hmm.c               | 33 ++++-----------------------------
>  3 files changed, 45 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index da0ebaec25f0..76a33ae3bf6c 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -286,6 +286,8 @@ static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
>         return (r1->start <= r2->end && r1->end >= r2->start);
>  }
>
> +struct resource *devm_request_free_mem_region(struct device *dev,
> +               struct resource *base, unsigned long size);

This appears to need a 'static inline' helper stub in the
CONFIG_DEVICE_PRIVATE=n case, otherwise this compile error triggers:

ld: mm/hmm.o: in function `hmm_devmem_add':
/home/dwillia2/git/linux/mm/hmm.c:1427: undefined reference to
`devm_request_free_mem_region'

