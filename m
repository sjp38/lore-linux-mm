Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78372C5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D0F42083B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:08:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="aWEsAGzc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D0F42083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC3066B0003; Fri, 28 Jun 2019 13:08:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C73E88E0003; Fri, 28 Jun 2019 13:08:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B62B18E0002; Fri, 28 Jun 2019 13:08:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8987F6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 13:08:42 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id a198so2816886oii.15
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:08:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LA7BcUYMgiPM4LhkTkot3xLWQxZ9GymJ/I3cshi8054=;
        b=kemHhHVXIVJe/lfNHWWCp82SPwwukCSOIiBm8FxWE2xD6hf+QIqZuMWLkUJ/CXTsQX
         8yw9qOJcIZzorbCKMnt/rJH53VqJmLeLENlNR++kO64UfP3v7zb+kN57X6WioEHEX2AQ
         rySbY/C4VcgT0v4z9r7R13OVx+SfI4iaQXFsulL07KccdapjvOcU8o0iYskrdQbel5zT
         xf5LgyxrH6oJgecV1ntCsshdw8OXTc/lToqV9LBB6IgNc+9j8bWOVweY2TOPMhX2mKP5
         ku4H67lHRuIz9c+Yzq4EiRnRIIeB3p11EkF8Sdk4Km6Y1DzploJVfk5QkNszedQVDv9U
         pCYw==
X-Gm-Message-State: APjAAAVejELWRmOmAIjBgBkJciU+zrdTFaTv/G8fA60fJJHf8O8aqnLY
	4pniLL8t4I3gFoaoB+iblHFXCTvZqoxrelh8J419Erak4El0RUizptlLK+u/Pq8YSI+V51/+XNl
	osNZjBIccXVsSY9BbHmu+CVzu9FsL+Bb8Q0svNG6rfH3aNr/wezX3mLZ8wzLhiEXXzg==
X-Received: by 2002:aca:aad3:: with SMTP id t202mr2504545oie.158.1561741722204;
        Fri, 28 Jun 2019 10:08:42 -0700 (PDT)
X-Received: by 2002:aca:aad3:: with SMTP id t202mr2504502oie.158.1561741721503;
        Fri, 28 Jun 2019 10:08:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561741721; cv=none;
        d=google.com; s=arc-20160816;
        b=SuslgfvuFqfRY2pdVL73aTn8DGH/Kei35Uk/OKI46dfJWdDUkFdbMmDX97dErOv2s8
         HhGpMHdrU2zSP1JWo0cTLDz9rUOenJ0uUQ7yIV+G5qW8c+IlR4ObsfOxoSoRUYZtF5FT
         mTo9kWtgJOpSAZkrE+/3oXDkIf1MVyndwNRNsVggXEceaNT24qr+pMqEaZ8B+uNsI2as
         SkSqum8HPwO/VBd9ACQULleTS1g/SnQDdkEMXCn6xlZks5Jhu9og8CM8R/NOxs+PutR8
         2y84v3gpv9+rhC86GsEdSDDcKMU5RedVKynE/6+qX1c49Hos34o9+j772BgEgSdehL2c
         wOrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LA7BcUYMgiPM4LhkTkot3xLWQxZ9GymJ/I3cshi8054=;
        b=lqH2qt2FvSUB0VZRXYPtT+Yc/pVQA3hlQubZx901ftTUpckEhp4a3kKXRR5cdSGuBx
         GJep8iieSdoROyNt8IWE5f4TPLyjIYwkwzutFg4UF8pveZTlxy1rLrfmFGrVdzdSENhQ
         9gt3u7zwh/vRzuzGwtaXTEUG5nvt6Fq4Q6RKdH0cszpKaop2L8z4zwieIpt6ANNlnVUK
         qQ4H2+EiwTO7cLlgARXVAtUFSN0iES9yW+7bU7RYWO/m/QgB0OpHv0GfXZJkidTQTglY
         12lNi2T5sH/tKh9foFLs931vgAf0SJ0McoTDVGgyzUVNdbHBbS0gqu2/AvXeYfpGRYD/
         xBOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aWEsAGzc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor1546091otj.6.2019.06.28.10.08.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 10:08:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aWEsAGzc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LA7BcUYMgiPM4LhkTkot3xLWQxZ9GymJ/I3cshi8054=;
        b=aWEsAGzc2Yh3JREBeLfqCnbjuH6gFhlIwpqtRUdyIB6fGEGjp0c/9cteoNu7mVTPYk
         k7v3tmKRFxuMhqWzggOKwBghog33HajwgNHqZGgt7yBZssqkujvFSdmZ6oFP073o8bd1
         ZFWE8m7Q/mY3rKQ0JO12vTiImwp/mNsQn0+1FPDFmxgJqZwFVHptf+HajNjWmdXZdyi/
         sXfT7o1lOMP8oP6O1xqR5I5TKSGwy+YYZ/aXoZ4EnNCmm8t/FhivsI3LpEb/JP77AiWP
         Hl/nPelTzud50IIzNwJksYSVmktcqKvzLaRjqqynqcF7HJ5XeVfEHEzsPm9koUpO7D/j
         z+yA==
X-Google-Smtp-Source: APXvYqx9NDQoyUwfceLcBzkU2NvzJ3YM6qn8RS5E95TlC5H3OILwJGHGUQARUz+LN1VfbIDPOiU7HWfaHbo1PzKN6QA=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr8719655oto.207.1561741721035;
 Fri, 28 Jun 2019 10:08:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-17-hch@lst.de>
 <20190628153827.GA5373@mellanox.com> <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
 <20190628170219.GA3608@mellanox.com>
In-Reply-To: <20190628170219.GA3608@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Jun 2019 10:08:30 -0700
Message-ID: <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:02 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Fri, Jun 28, 2019 at 09:27:44AM -0700, Dan Williams wrote:
> > On Fri, Jun 28, 2019 at 8:39 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> > >
> > > On Wed, Jun 26, 2019 at 02:27:15PM +0200, Christoph Hellwig wrote:
> > > > The functionality is identical to the one currently open coded in
> > > > device-dax.
> > > >
> > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > > >  drivers/dax/dax-private.h |  4 ----
> > > >  drivers/dax/device.c      | 43 ---------------------------------------
> > > >  2 files changed, 47 deletions(-)
> > >
> > > DanW: I think this series has reached enough review, did you want
> > > to ack/test any further?
> > >
> > > This needs to land in hmm.git soon to make the merge window.
> >
> > I was awaiting a decision about resolving the collision with Ira's
> > patch before testing the final result again [1]. You can go ahead and
> > add my reviewed-by for the series, but my tested-by should be on the
> > final state of the series.
>
> The conflict looks OK to me, I think we can let Andrew and Linus
> resolve it.
>

Andrew's tree effectively always rebases since it's a quilt series.
I'd recommend pulling Ira's patch out of -mm and applying it with the
rest of hmm reworks. Any other git tree I'd agree with just doing the
late conflict resolution, but I'm not clear on what's the best
practice when conflicting with -mm.

