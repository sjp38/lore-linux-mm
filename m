Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D385C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40EE120861
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:00:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="aTNnToCY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40EE120861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF0078E0005; Mon, 17 Jun 2019 14:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9F478E0001; Mon, 17 Jun 2019 14:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDCC58E0005; Mon, 17 Jun 2019 14:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9729F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:00:21 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id h184so3828715oif.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:00:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=GjmvPRW/EB2UZMiXQmlwdUn3cNZy7MEt9OXtWGJNxz0=;
        b=th6e4myh3+wFpK2bXlNWlBmLuLA9VUSSC+B9eHQ1H5Nto134dUasuN3a6X+e/OvX7L
         jesVD+dOmHG1LdtUT0MAfQ0pos+ljtJo2y5lYTQkHmFSFXvdA94DtKqKy/ddDoYvrwai
         pisdHRuU84LXsECaq9r/pexlrqcYLvi6R/Y2/6XXe5gqZLxwtlHM4eUdELn2nqZYbblC
         qjtmJ6lnMv9OKz8dbuyncjiIhGBJxEJdgoWltextvWOKlQ4ifwPMmPhAr5GZpXTN+Vjs
         zSXfP9XFQd+lAw329Q5PGp4wbT/HJRbEa1V5PvvAee0xfOJDZ/uRpENqFioN7K74l4vu
         SZKQ==
X-Gm-Message-State: APjAAAUXHXsb3DuBeGygYVdE9b1YYUg+jC+barLIY5NmbpD+cm+/dBqE
	CZz1ZuLFPY1hIdFL973705YabuN41GCnEvEiF5FuLIMMOeGD9l+RCDL71ZXTKisu5bQ54z+MV38
	qUgVjKE3CWjue8Wc0wZiR8UzEPy6mFhvBYPgrghJbfkAelgQancukjISdGLjwCitRPQ==
X-Received: by 2002:a9d:661:: with SMTP id 88mr57343086otn.214.1560794421185;
        Mon, 17 Jun 2019 11:00:21 -0700 (PDT)
X-Received: by 2002:a9d:661:: with SMTP id 88mr57343018otn.214.1560794420262;
        Mon, 17 Jun 2019 11:00:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560794420; cv=none;
        d=google.com; s=arc-20160816;
        b=vmFt3O+DDZC36yzgX7itagLvTgIZ8sqSYa5EQ5kdafm6PsesB+2xbyqaHMACkL2yPv
         SDT1wJV9nV1KfhzE1Zock+/Wh/krL3dn3MkdAwidKt5LumPfDCoGbe4eLotYmQQkInKO
         EKStXqdVoaFXtvrRjU4AVkF31mtSMpI/Iu5UTP6hXYuw1Z6tGMcWbMrXyKkl4Zt6lU15
         7dCxBu+4JLx48wmipH/Fq7frAQ+NmNJJy72OpQ6ZVtR25oG4WwvbIm6LMtcJEx34PlGE
         NRslQPY24BhD1ifJPV2kDXjDSNRgeiC5Zc8PXiN8EyL1AaKmyv34K8XfURfHyoepHQ5M
         2Ibw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=GjmvPRW/EB2UZMiXQmlwdUn3cNZy7MEt9OXtWGJNxz0=;
        b=FMo4AuiTS6BS6F6Ts9BwbHU5dK8SIaKz5QcnrQ6P2i+DkANGLPhV3tToh6i6l6SAbM
         pNVpJRJE7P0vwFJMIE+Eyla+Dk7jIP4/topTqK4LKfEon+Nlb9hp4oPa8Qvvf+bCURaD
         j8pRIdpIAfUwRfTBH8s5Jts4sd4LAbz/qlK9CvdUY9dSYKhroVxjGv31V+thxqVlk4/e
         G1V79JbxOFcYNnjKp9Qv2ATWbhEjwdG2cpAYgCjeivZgmAs6FldFwDecBEFB3tjursS+
         6okgpl6OEjNYvxFmuSRrpE2DKRPY5P0D4a54RR90cZ2LM9fTcx60vfrgHo+ktYwiVMRy
         50vg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aTNnToCY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g19sor5618586oti.100.2019.06.17.11.00.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 11:00:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aTNnToCY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=GjmvPRW/EB2UZMiXQmlwdUn3cNZy7MEt9OXtWGJNxz0=;
        b=aTNnToCYbt/RLgFmZg1PIvrCe0JVP4C32RN5cfyMVp2zYXXYY11JnD0P5Xn5tfOK6Y
         voW3Syk7UYIIG5SF4LSMDVtOlpmEa0YxFfvlu8+J6wAb/HPFiX2GuYxqo+V2fpMpF+jS
         NlrpFBkRARTzBSJzVDZzE7bQS2UMHOvFRAjYRiT9xL8/lOeALYe1ebk8LfMUYkoFpZaD
         PAFxFM2FYNf4FyGaTFye24KEnD9WdtERxcyZTxLFaidHht03PVJNbu4TuZbdbzHMaWbM
         oEiXMcpcSzAKgjPufMTuJybkt3G4uT6kQCK3aNOgUOJV87J/VA4uKxPCVrEi1MqSqx3i
         hB9A==
X-Google-Smtp-Source: APXvYqyhtBEP50oerFZs8TdK9nCsvOJRWYCWzRd2vhiNPfCpga0Ba5N2yHiBCHm+W4K6XflHhEhbg4A9IXDkc+ucm/c=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr54836696otn.247.1560793907524;
 Mon, 17 Jun 2019 10:51:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-9-hch@lst.de>
In-Reply-To: <20190617122733.22432-9-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 10:51:35 -0700
Message-ID: <CAPcyv4i_0wUJHDqY91R=x5M2o_De+_QKZxPyob5=E9CCv8rM7A@mail.gmail.com>
Subject: Re: [PATCH 08/25] memremap: move dev_pagemap callbacks into a
 separate structure
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Logan Gunthorpe <logang@deltatee.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 5:27 AM Christoph Hellwig <hch@lst.de> wrote:
>
> The dev_pagemap is a growing too many callbacks.  Move them into a
> separate ops structure so that they are not duplicated for multiple
> instances, and an attacker can't easily overwrite them.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
>  drivers/dax/device.c              | 11 ++++++----
>  drivers/dax/pmem/core.c           |  2 +-
>  drivers/nvdimm/pmem.c             | 19 +++++++++-------
>  drivers/pci/p2pdma.c              |  9 +++++---
>  include/linux/memremap.h          | 36 +++++++++++++++++--------------
>  kernel/memremap.c                 | 18 ++++++++--------
>  mm/hmm.c                          | 10 ++++++---
>  tools/testing/nvdimm/test/iomap.c |  9 ++++----
>  8 files changed, 65 insertions(+), 49 deletions(-)
>
[..]
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/tes=
t/iomap.c
> index 219dd0a1cb08..a667d974155e 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -106,11 +106,10 @@ EXPORT_SYMBOL(__wrap_devm_memremap);
>
>  static void nfit_test_kill(void *_pgmap)
>  {
> -       struct dev_pagemap *pgmap =3D _pgmap;

Whoops, needed to keep this line to avoid:

tools/testing/nvdimm/test/iomap.c:109:11: error: =E2=80=98pgmap=E2=80=99 un=
declared
(first use in this function); did you mean =E2=80=98_pgmap=E2=80=99?

