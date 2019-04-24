Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DFB3C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:14:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03E142089F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:14:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="jydYgmEc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03E142089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F8A36B0007; Wed, 24 Apr 2019 14:14:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A8AD6B0008; Wed, 24 Apr 2019 14:14:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 287C96B000A; Wed, 24 Apr 2019 14:14:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3F286B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:14:00 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id j5so7935926oif.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 11:14:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BhVsIoAU0KmMQwQooFIbVLABg6RqRAt0bXCVdPk8wQg=;
        b=bL3XdnyKQueANoCP6GjFpX85oBHrZDn3r/wVgLTME9utIsXritsNeainyQlmjccy/F
         YME2LKRmYAfi0rXUKvFjCfg0UViMEcSYFsjfKr6eqn/H2f1jVEzyy8ccW0nhgdZrEcrA
         PKST/307iBMQSYfOVtr3yYAXzpypjURRsbiWKXY7HMpfEr4HqT7BgEPuv+2sIWTjF/C0
         fGX75X+oC3vvLNn49rCv31aJG10gXbVnefRK8/JZZIoc4DsjoPWmBMUdmJFA4U7LwC4g
         KmAhf1CjfXgdx/9jLWbH1KY/ACbFhQAyUnysJmuYlP87kefkkUlHlV9rSNgKMkAP6/6G
         QPTA==
X-Gm-Message-State: APjAAAWAQCuvXWqPVa2GHFM/5zJbaLEtBCT5XJeLkLQ5fNv355FDucH9
	wQleAAe2hUozwo7Nwwmu+KOULen78Myj8rcgl/cBYatMgR34n5+UlqSoFt61KK7piN75X33Bf9u
	W1OWLbFUs91ujK+mbhtpv7iMjPs6UWw8Q3jH7uHP4LcZ2CwKqSDhWNyMim+lfDRExJw==
X-Received: by 2002:a9d:7dda:: with SMTP id k26mr21270092otn.354.1556129640389;
        Wed, 24 Apr 2019 11:14:00 -0700 (PDT)
X-Received: by 2002:a9d:7dda:: with SMTP id k26mr21270005otn.354.1556129639187;
        Wed, 24 Apr 2019 11:13:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556129639; cv=none;
        d=google.com; s=arc-20160816;
        b=KdXgrHA/nMmtDnIXJIMlMT52DRnZROj9LsfQSHt9fNVkr4ttGLCoC4i17eEaKfAurQ
         jQMCUJIxsVezTc6dJ5Pfm7NAHbFmIVUlwn/HuVs+V3UJoKAGDvq8px76jFIamZNCPcmm
         ucIU5z38Y/VtERlaNRoqrKhFE3Uh4CUmcvF3zEM3FqkdtFuiTWEUEWo+pJF10rz58UqD
         erb60DnZ3RIS6fi5fjPFnyLamBf5scfyqJp3hrgmpIVar8M8KbaFaMowyLYcJqTKbAlS
         eWh25qeBWBZ+Yf7ZOq0QsAZnuBIahV6JFbghKbmhm2LYKLV3MoCau38H/m2WKA+VIj2f
         1Gew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BhVsIoAU0KmMQwQooFIbVLABg6RqRAt0bXCVdPk8wQg=;
        b=eLDY58cQdIuKCpBdcmbViE7ZtgEDnNfMvk12eUVz7Bj9xTBcZ+CahplHyGRXntQJRD
         6QRHrNYL8boMZASTHiipf/zdtrvzFXHTtro670gu7GuOwgIuEnfCDpnZsL0qp1n0IKH2
         u8jj10ZR31EJFG6VgJ2zHmOelYJXztsS/892bqFQkfvbgAUA6fu3AfLChGnC1SfX92Ls
         cECChwfPmVMUMebnaxz1Yygoi1ThTlsHvN1a29U3F1kCoqACyLjhPCx53485KEeAWiBj
         VXGFEJNnKsfa82Y1IEYoR5ZihIqvevpEVb5Oo5KP+2lGq7S16knMjwDzcdZ9b8TkNhdO
         Z39Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=jydYgmEc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q206sor9058422oib.172.2019.04.24.11.13.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 11:13:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=jydYgmEc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BhVsIoAU0KmMQwQooFIbVLABg6RqRAt0bXCVdPk8wQg=;
        b=jydYgmEcLg5IMUxEQPjYpc4DgbIaXE24fhOcITjx0qkXUHk//riuR0/LhemjcKcSWP
         RP4GtyjPGwp9EuPB5qNyFUVayVB4P9BiMkogYrUvmsoydY+ojeDF/VVh/Q/DKJOBflVi
         T31b0QzpIuB4I+iapiWeXld/gFrM22Nl9lTAPBwohGpDQz2Jly6tCAfI0ncKMwrK36VQ
         9bE8rrq4w/wPkzhIaBkY3t08nM3VlvUDYfP2BcAGGPuuBLy6nGWigDas69mhU3FzJbjg
         0KFRWfoDP7SOk6RkLZJppbZYEdvO2izZTiRoZEGJ2ADyq3lPGpHdXTbEvR74ESSr8DIX
         dBVg==
X-Google-Smtp-Source: APXvYqwN3H2piW0geeJm1fy7MdumeKyfzQXRx8tCi9JDjwMK7cOgh+Mt7+7fybL28IH9qG0F0B+c8mreTuoq/TY1uPQ=
X-Received: by 2002:aca:de57:: with SMTP id v84mr272169oig.149.1556129638917;
 Wed, 24 Apr 2019 11:13:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com> <20190424173833.GE19031@bombadil.infradead.org>
In-Reply-To: <20190424173833.GE19031@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Apr 2019 11:13:48 -0700
Message-ID: <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by insert_pfn_pmd()
To: Matthew Wilcox <willy@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, stable <stable@vger.kernel.org>, 
	Chandan Rajendra <chandan@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 10:38 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Apr 24, 2019 at 10:13:15AM -0700, Dan Williams wrote:
> > I think unaligned addresses have always been passed to
> > vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
> > the only change needed is the following, thoughts?
> >
> > diff --git a/fs/dax.c b/fs/dax.c
> > index ca0671d55aa6..82aee9a87efa 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
> > vm_fault *vmf, pfn_t *pfnp,
> >                 }
> >
> >                 trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> > -               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> > +               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
> >                                             write);
>
> We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
> that need to change too?

It wasn't clear to me that it was a problem. I think that one already
happens to be pmd-aligned.

