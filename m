Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54A15C468BE
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:10:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D2712133D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:10:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="brKoMC2Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D2712133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 945356B026B; Fri,  7 Jun 2019 16:10:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F5816B026C; Fri,  7 Jun 2019 16:10:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BDE46B026E; Fri,  7 Jun 2019 16:10:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 505936B026B
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:10:11 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d204so1003507oib.9
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:10:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QlVygW5HX3gMOqI9iagu+o2KfHmRD4CVE+mKAqVQHDc=;
        b=p7cJhDxNbJ1YTkZiRdNtU5wsKoALAfSLafF+LjmxBMYXAqL22b+AuPnZ4x+KTz6TZL
         MAq5V4zG+p8IbxfhxJHFdkg+UkTeflbiGOBz9QvszSx+u4Pp9M89z27APvQYtJ/fMKSw
         /n6r5ZA10ejMJbvYVqv+rt1Y+2hC0ppE0xw4nW3m666oPMIHB6QjKAkfgyNf/Y5t1I7M
         /E5+cjllCOovuqyI7OX10wBdqoxkBKiRzTlLj0qECQQ+zY02r4lI+Bu7rcedDKwoy7rM
         oyzaV568ekfvDduoBx+XUEfo94Dx+aKypGyrvzIJ30JuZ79arTE3u3G/dC1UmzVQxgRu
         qLAg==
X-Gm-Message-State: APjAAAUeWmZNTvjZGrL4E1hl/Nl8ETtrq1xq4gN2MvN6wAwe0KOArK/1
	0MlZ6wrX0R+h7wuxoU9JDp1+9Ybjerb0X04HW5kpT0ArpOwqo7KjvUTPQogrF72oV7S8JWck2fM
	JJC/VO/psUwV1u8OYJwrQzyWU/CAVT8k0I+i/AKOJc1pkfraLYV05EfD9YqcWUrnKXQ==
X-Received: by 2002:a9d:68c5:: with SMTP id i5mr960764oto.224.1559938210959;
        Fri, 07 Jun 2019 13:10:10 -0700 (PDT)
X-Received: by 2002:a9d:68c5:: with SMTP id i5mr960716oto.224.1559938210146;
        Fri, 07 Jun 2019 13:10:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559938210; cv=none;
        d=google.com; s=arc-20160816;
        b=moxmxkTJ8sckLPnoLeBftlrz952rdsElfTgp8ZlRebZvJXYc72llOD2ShnggTwW016
         ODOJKgMYN1u/b5D+MaSr/c4jAX9XmR7dv7OA5BlRWabRZSCIhS58IxmWAEuPrfpvmFna
         /p8GaALIJrKuhNSuUPedShgEajPWqJX6dJFOXkF725J4vEGgpD4hDxyBlpVDK1nl9JLR
         mjSASxej1d6x45gPh8wTPpLP9SoKjZB56JSSYxS4dMuaibexKv6FBECUWti8r07vxKLC
         WTZx+/IjnXQRepELYYKjlVvgmEeE4N2/My/7iiNK86WjY7Jnm69g//zQ77IcrYrwWrZm
         gzwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QlVygW5HX3gMOqI9iagu+o2KfHmRD4CVE+mKAqVQHDc=;
        b=mCPZbQ3iqOkQMeUirFU2GAuqerms/1Yfz1f8slhWxYCWJp97f4XG6KlUKWAdkWOz1t
         mQ8I/gdXEZmskE19fEKIL2r+ath2FSWfZ4diAJ6Gv5fUcXTDoMjU8IGS+63O19Xk39VB
         RnKtdXR9/i2Ou00d4xxjPVVTCpWxt0GfBa1F4QM7wBSjeAizMca9NFD6qKanLJyUWlHv
         GbFEQv8SUmCslbDIA5Gw4j54+9wQwEr0TYK84OWArRXM/e19/1g0OvQo5ML7iiuSnVkX
         F2BUpOPtNg3dA1Pq0N3BatIodAdTixi8NmCDuBsKS3RrvM0+wNUTFkZYD5QHBvnNCqHW
         qNJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=brKoMC2Y;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i15sor1459122otf.145.2019.06.07.13.10.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:10:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=brKoMC2Y;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QlVygW5HX3gMOqI9iagu+o2KfHmRD4CVE+mKAqVQHDc=;
        b=brKoMC2YNPiZDdbuJUJptjoM9KaSU8S4ObGocQkg1KQo4JtkdYErEgLDttxwqmD1JH
         dL/IlNi9BXKIc8G2/scgxlh4GMR1LPlSwT1q5vcXHrdpTfXILVnLCPxnCBYk7gUFnfFF
         NdgiE59NbaWDqNP5wfElrVabi+k2yJJyvfJduho23fxEAZDaN8S5AlfdlL96Y1r7QtR1
         A3okrfILjOgYAttOW90Hvjo0YcQe/1HvRH2+1CnF6pxcSFE6miNDAwBkMxuMaeftbxpC
         eVrIbhAE3WWKVoxN2mrCw1iTp9wy3oCPHn39dU3YvYz4bSqNGMa2gZQYQQPeD7kvC730
         R67Q==
X-Google-Smtp-Source: APXvYqza6PFTcS6UhXtsr41/gRao+O5Nm4kLPIDhyAJGiSy5KNxsRBiCwJGc9Q8H+D6BnJ2xLKRvXnTj8YRz1komqIE=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr20388166otk.363.1559938209740;
 Fri, 07 Jun 2019 13:10:09 -0700 (PDT)
MIME-Version: 1.0
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977193862.2443951.10284714500308539570.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190606144643.4f3363db9499ebbf8f76e62e@linux-foundation.org>
 <CAPcyv4hHs75hYs+Ye+NHHiU31C6CnBqCFdo=2c5seN7kvxKOrw@mail.gmail.com> <20190607125430.81e63cd56590ab3fea37a635@linux-foundation.org>
In-Reply-To: <20190607125430.81e63cd56590ab3fea37a635@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 7 Jun 2019 13:09:58 -0700
Message-ID: <CAPcyv4iSndjxgQZq1HtsyY5=h837b-MY3FNDzAdrBGiKJGwOvw@mail.gmail.com>
Subject: Re: [PATCH v9 11/12] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>, 
	Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 7, 2019 at 12:54 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Thu, 6 Jun 2019 15:06:26 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > On Thu, Jun 6, 2019 at 2:46 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > On Wed, 05 Jun 2019 14:58:58 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > > At namespace creation time there is the potential for the "expected to
> > > > be zero" fields of a 'pfn' info-block to be filled with indeterminate
> > > > data. While the kernel buffer is zeroed on allocation it is immediately
> > > > overwritten by nd_pfn_validate() filling it with the current contents of
> > > > the on-media info-block location. For fields like, 'flags' and the
> > > > 'padding' it potentially means that future implementations can not rely
> > > > on those fields being zero.
> > > >
> > > > In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> > > > section alignment, arrange for fields that are not explicitly
> > > > initialized to be guaranteed zero. Bump the minor version to indicate it
> > > > is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> > > > corruption is expected to benign since all other critical fields are
> > > > explicitly initialized.
> > > >
> > > > Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
> > > > Cc: <stable@vger.kernel.org>
> > > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > >
> > > The cc:stable in [11/12] seems odd.  Is this independent of the other
> > > patches?  If so, shouldn't it be a standalone thing which can be
> > > prioritized?
> > >
> >
> > The cc: stable is about spreading this new policy to as many kernels
> > as possible not fixing an issue in those kernels. It's not until patch
> > 12 "libnvdimm/pfn: Stop padding pmem namespaces to section alignment"
> > as all previous kernel do initialize all fields.
> >
> > I'd be ok to drop that cc: stable, my concern is distros that somehow
> > pickup and backport patch 12 and miss patch 11.
>
> Could you please propose a changelog paragraph which explains all this
> to those who will be considering this patch for backports?
>

Will do. I'll resend the series with this and the fixups proposed by Oscar.

