Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A4E4C31E51
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 18:09:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A536921841
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 18:09:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="EY/IUPVb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A536921841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1342F6B0003; Sat, 15 Jun 2019 14:09:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5D86B0005; Sat, 15 Jun 2019 14:09:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3E268E0001; Sat, 15 Jun 2019 14:09:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDFFC6B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 14:09:22 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 80so2830454otv.1
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 11:09:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Cb0Hmo2zAZrYDyoCgAidl3UeL9kc8+XrLoGdt6CrXZE=;
        b=MVVX7TBGRlTGWzVGJyu5PVA3GZXqw9m2OwS+uxLpJN1Mdd6nad0CXOwI4M55KlGgVq
         ZvhlGPGoy9KD0a8t4TtaKATKHMEzppWWtP+Wpc8jR3slC001ms1FT8tQlqunuENCIV2/
         15BIoPVxaCtokIml9GWRxaAVid/ncOTMKOcKAapAnJwJSOVuvEChxbQwQ/n92rM7odlM
         vwq4tggDAGF6RI4hhQK3AIX5y+gURqIzFanDfiGaivgAc0FGhdW52fVrYRpBAS3rrYIr
         3I3h1DWU3VsvRLnSjbteNqwg+c5Ru3bYgRlqYesJV4Dt9rF48MOfh34EZBLbn/Ubn8TN
         9bCA==
X-Gm-Message-State: APjAAAUCNAYPxCBljsyvqhaF0j+iErTBtah++PwjArwdnelS5wMFc2jl
	1ajy96+VWiP0UR5/kkyFFVvLk430P5nncsGX/L4s08cVfqfpTPE7r5md9q0Bl2q4Gms91TIg6cF
	b47rdwwn7lP4Jw2JDWbQtwP3C/VrTLJqB6ewFV84L7DM2TPr8AjgzzGSkolZDqd9BPw==
X-Received: by 2002:aca:811:: with SMTP id 17mr5715776oii.161.1560622162382;
        Sat, 15 Jun 2019 11:09:22 -0700 (PDT)
X-Received: by 2002:aca:811:: with SMTP id 17mr5715732oii.161.1560622161418;
        Sat, 15 Jun 2019 11:09:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560622161; cv=none;
        d=google.com; s=arc-20160816;
        b=F5T0Ckq2s39ePgxbO8fWYbAuWC3kJXXZWRIIubhjJlFjX0PXTdrS2Cg1HNsI/5OR/+
         MEbXSEi55AqO4PZMvdnbx84AfWaLjfN8ju/Mmwspz0AzBD9dKlCvpAIjx/rY3vrt/gJ2
         M4GFJppX0Ruvim+8O+0M5JvBKrXDgnSqovZ70jHtZ1ziJQFAkfgykgVDtmrg6PDPEkjy
         5BVjv4Jql8nMUnqT9+rFE85+RcfP6o98iOgTkigRWKhLU8DU7TGa8Dkj+l4sbCUAK2yE
         iZXKlJSLpBnj1VPKDoIPF7CRybpDYn2QbT/zVYTMO2ezTnk8eCFsBomZY9Utf4MdS5uR
         xxDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Cb0Hmo2zAZrYDyoCgAidl3UeL9kc8+XrLoGdt6CrXZE=;
        b=lCt20yIRF0PXZrDOQM7qFvWbg0i8mwu8CD7n3ObnwdWGzi0WSRuxI8Y6PMRGciX7dV
         dEfeGYQJv5570gRb/2JcCbKOeDiYaw8F3Nd5jXiBZcIvq0GFQwrYsE/j6Wq9JZDSK0Em
         C32IIr9Xlj+m0zMqB/aAUMbhTpRHlUrej+c9768baHbJz5A+ASPrGVTzLDjUkfU/fJZa
         0btmGLDE+oGAitb9HprZgkzeH8tlw+LL76YqPDCsxK0ySNUA3V7EBp8SuOQ59OtmcwF8
         KpX5qEdf777BKLsu/VdAR6Uj8FYNbpLAAnJUUaO5+23IIQoA6tRObn/cMy47pX0530yn
         WD5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="EY/IUPVb";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3sor3390962otp.87.2019.06.15.11.09.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 11:09:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="EY/IUPVb";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Cb0Hmo2zAZrYDyoCgAidl3UeL9kc8+XrLoGdt6CrXZE=;
        b=EY/IUPVbu+1KTXp5GI53vNwR2z9Nvu64XsQUizbEMMU+aGYsXWtd2lTzv6Rx3V/2OG
         ZCHaTlatz8Y6DgkD78CATBQ1yUSjk/05HpPEqetVEj/+F5+Kom/9e7XbdGpDgyQQCBnL
         yj7evXXPdyreGRqDjU90YAS5Z/xg/+W8t5onIf68LdBa/3dqW/rLtaWBvtaURMP28S5L
         ACzapU9ov4J0F0u3SlQrs+vm8YDjsJurYg/jGuJheOXTmxVlf3qQXGWQIp1J0v1wmtf3
         4CKVxNLpNlkzY6vy0HsyUqk2Hkklo6bAEUB4ced5+znlBd2UCAgiXhA0LcanxooGfjdt
         jtDg==
X-Google-Smtp-Source: APXvYqxK2ja20GipaVbp7qq4Oaf290msf2s3XleRazQ4mdHqmcalk7o8VyutGF6B5iu+bOwCwwdJPEhdvYDhbnFupMs=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr44930666otn.71.1560622160642;
 Sat, 15 Jun 2019 11:09:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
 <20190614061333.GC7246@lst.de> <CAPcyv4jmk6OBpXkuwjMn0Ovtv__2LBNMyEOWx9j5LWvWnr8f_A@mail.gmail.com>
 <20190615083356.GB23406@lst.de>
In-Reply-To: <20190615083356.GB23406@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 15 Jun 2019 11:09:09 -0700
Message-ID: <CAPcyv4jkDC3hRt_pj1e8j_OmzJ-wdumy-o1bN0ab=JVE_gfKdg@mail.gmail.com>
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

On Sat, Jun 15, 2019 at 1:34 AM Christoph Hellwig <hch@lst.de> wrote:
>
> On Fri, Jun 14, 2019 at 06:14:45PM -0700, Dan Williams wrote:
> > On Thu, Jun 13, 2019 at 11:14 PM Christoph Hellwig <hch@lst.de> wrote:
> > >
> > > On Thu, Jun 13, 2019 at 11:27:39AM -0700, Dan Williams wrote:
> > > > It also turns out the nvdimm unit tests crash with this signature on
> > > > that branch where base v5.2-rc3 passes:
> > >
> > > How do you run that test?
> >
> > This is the unit test suite that gets kicked off by running "make
> > check" from the ndctl source repository. In this case it requires the
> > nfit_test set of modules to create a fake nvdimm environment.
> >
> > The setup instructions are in the README, but feel free to send me
> > branches and I can kick off a test. One of these we'll get around to
> > making it automated for patch submissions to the linux-nvdimm mailing
> > list.
>
> Oh, now I remember, and that was the bummer as anything requiring modules
> just does not fit at all into my normal test flows that just inject
> kernel images and use otherwise static images.

Yeah... although we do have some changes being proposed from non-x86
devs to allow a subset of the tests to run without the nfit_test
modules: https://patchwork.kernel.org/patch/10980779/

...so this prompts me to go review that patch.

