Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1694AC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 07:47:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C544D2173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 07:47:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="atFNJxGK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C544D2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 532826B0003; Tue, 21 May 2019 03:47:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E1E46B0005; Tue, 21 May 2019 03:47:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D08C6B0006; Tue, 21 May 2019 03:47:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4316B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 03:47:49 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f18so9273584otf.22
        for <linux-mm@kvack.org>; Tue, 21 May 2019 00:47:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VnNxGfo8OcqUG0djFgBhBET2kQpbkm/tIE8oQa/BNZw=;
        b=FGV1ykmFcBOUG3EIk3eqj5VaXMWwIf+lYtdRAp4xLX5PAwyUglrgafulpfZLe8hNkJ
         F0e8ODGOYNPpVaOT/WB+v5qswOhG/kiVHoFLAay9ofnWRXOX/TLleU13ozTsYShR/2KB
         vIpSfftnWkpLx0I1tBww6Bpg4DXPmciqqUJ20P7RJHCbUMt8CXUw1qBILJe+aYDYdWRA
         bdsEsEQLC17ehvukPCVt35BY4niNO66wnSuduf+y9e+iZkaKul1iq16VoH/ZuHgYyuBx
         4Yi81bRzC5v3de/qvUDUV3v3DuksKrvgO3bNzw9dsX9hU4dO4RDtSMAJH4USYXWf4568
         7LHA==
X-Gm-Message-State: APjAAAVgJORxkiUshk5TgGfJSReQB0tX8cEWNN7B4EkHR0vfGjLAS11A
	dnkm2TnfRZ7OHvXCsxHg79i/XOsm1RpqQAWCP3UfWIL/1BC6g3LHrQOaLP96OFJGQCcD6cuVKcK
	TYQ6FmsAnpk3ewk9byS64qfg9Oq4jgmyVVEOf46+ZwzsBZj0n8lHJjd4MsyzbILJGXA==
X-Received: by 2002:a05:6830:104b:: with SMTP id b11mr54107otp.146.1558424868624;
        Tue, 21 May 2019 00:47:48 -0700 (PDT)
X-Received: by 2002:a05:6830:104b:: with SMTP id b11mr54077otp.146.1558424867810;
        Tue, 21 May 2019 00:47:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558424867; cv=none;
        d=google.com; s=arc-20160816;
        b=AObnykc1oadSnlrwVsI2NNHoL32oh5Xt+0WR3nc4xQ4OtmH1Ssdpd6eySJVn/NDyAj
         o6N/XXOvLp1ALb/Xm14r/xOZwYepfqWv763NEaK3dFGrorVHIOXLg7KyX37pLF+WF1nH
         vjBAd/TGaP5N5vyd1PiEFYKqrvdFbcBo7WXs/DI5b9eDiusbR48DTy6PT08O//wGgKIL
         5pFEYbaKt2iSCw0CEbe2H6ZMYDkeNNZllmEjXBXrvZ4HQsWkbSa3smBubk1+1JaNhlEB
         aoz4KXOUo/J2apZc3a1k+dM34R9s7e0kxR0qPDu/u1qI5eD2UW2PafI4XpH1PReMnhiM
         dGVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VnNxGfo8OcqUG0djFgBhBET2kQpbkm/tIE8oQa/BNZw=;
        b=r7QlLqZrQ5m2bvabmCAERZCi+R/a8cKMJsE8cz8jiFJXf0xVdQk9ztxkYTYx9EXlrS
         0Q0i05g6tkW0Y1O3D1i1W1MYu303MaLnaQA2Z7ZbWGESogsoYpxH+VN+KgIoUw2JoNzc
         7qlplvixw0J7j0/DikViT6h37uF4DdO1RaWWugYpcKfxQqR7pecOKtmxTGcV7HX6H5vu
         nWgZkkDRb20uyFHnXHqJxfblEBu0UW0jcGJ77QQCSyiN0c8W8Q36ZxSMpsISQnxSZRxu
         Ie4WWrkGQ+cdaDcE+HYkFeHqoehMGgvGp/W0vYCwJLQJA6jEIfCbwKX+vZstFQFvFAtI
         xdfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=atFNJxGK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y19sor8214471oie.145.2019.05.21.00.47.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 00:47:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=atFNJxGK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VnNxGfo8OcqUG0djFgBhBET2kQpbkm/tIE8oQa/BNZw=;
        b=atFNJxGKx5nr0wfgMSn6a0RTyfq2Fh7KOKEYPxov5zlzNFhhIYe1dDNUgjJWatnVu3
         TQY7uuBSU/kDC6jobnCJYnj/QC+XChDwidnJlVmLT+MQmUmFq1bEEchLhCjWuzgKwyju
         A+qqR0Oh6V+JS6PRPujGPjIyVyL+OoUBTYAMMcVVJFycuEmeOjMY+4s6bfyLPECB8sfq
         LACDTc/1TBb3ba22twzTF60fVdcTjQgaSNGrXT7IOZ01fPet6WWPb3T1jtZ9Y1dHCtQL
         JAXyMeMqcCl+bNQjZkMKAndf7SfNg7p/q7JyueeAO1zPLX2PEzfzLbMoYqMvaB232JBG
         1OFg==
X-Google-Smtp-Source: APXvYqyMSmQsHlkHNQttDiH4AI9D7Vum2+q5m/RkOEYGvfvIfr5P741zQF/NrlP+XEOoZIXxeRZzuwTUqFQl8EEQY58=
X-Received: by 2002:aca:6087:: with SMTP id u129mr453263oib.70.1558424867222;
 Tue, 21 May 2019 00:47:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
 <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com> <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com>
 <02d1d14d-650b-da38-0828-1af330f594d5@linux.ibm.com>
In-Reply-To: <02d1d14d-650b-da38-0828-1af330f594d5@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 May 2019 00:47:33 -0700
Message-ID: <CAPcyv4jcSgg0wxY9FAM4ke9JzVc9Pu3qe6dviS3seNgHfG2oNw@mail.gmail.com>
Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 9:46 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 5/14/19 9:42 AM, Dan Williams wrote:
> > On Mon, May 13, 2019 at 9:05 PM Aneesh Kumar K.V
> > <aneesh.kumar@linux.ibm.com> wrote:
> >>
> >> On 5/14/19 9:28 AM, Dan Williams wrote:
> >>> On Mon, May 13, 2019 at 7:56 PM Aneesh Kumar K.V
> >>> <aneesh.kumar@linux.ibm.com> wrote:
> >>>>
> >>>> The nfpn related change is needed to fix the kernel message
> >>>>
> >>>> "number of pfns truncated from 2617344 to 163584"
> >>>>
> >>>> The change makes sure the nfpns stored in the superblock is right value.
> >>>>
> >>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> >>>> ---
> >>>>    drivers/nvdimm/pfn_devs.c    | 6 +++---
> >>>>    drivers/nvdimm/region_devs.c | 8 ++++----
> >>>>    2 files changed, 7 insertions(+), 7 deletions(-)
> >>>>
> >>>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> >>>> index 347cab166376..6751ff0296ef 100644
> >>>> --- a/drivers/nvdimm/pfn_devs.c
> >>>> +++ b/drivers/nvdimm/pfn_devs.c
> >>>> @@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> >>>>                    * when populating the vmemmap. This *should* be equal to
> >>>>                    * PMD_SIZE for most architectures.
> >>>>                    */
> >>>> -               offset = ALIGN(start + reserve + 64 * npfns,
> >>>> -                               max(nd_pfn->align, PMD_SIZE)) - start;
> >>>> +               offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
> >>>> +                              max(nd_pfn->align, PMD_SIZE)) - start;
> >>>
> >>> No, I think we need to record the page-size into the superblock format
> >>> otherwise this breaks in debug builds where the struct-page size is
> >>> extended.
> >>>
> >>>>           } else if (nd_pfn->mode == PFN_MODE_RAM)
> >>>>                   offset = ALIGN(start + reserve, nd_pfn->align) - start;
> >>>>           else
> >>>> @@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> >>>>                   return -ENXIO;
> >>>>           }
> >>>>
> >>>> -       npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
> >>>> +       npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
> >>>
> >>> Similar comment, if the page size is variable then the superblock
> >>> needs to explicitly account for it.
> >>>
> >>
> >> PAGE_SIZE is not really variable. What we can run into is the issue you
> >> mentioned above. The size of struct page can change which means the
> >> reserved space for keeping vmemmap in device may not be sufficient for
> >> certain kernel builds.
> >>
> >> I was planning to add another patch that fails namespace init if we
> >> don't have enough space to keep the struct page.
> >>
> >> Why do you suggest we need to have PAGE_SIZE as part of pfn superblock?
> >
> > So that the kernel has a chance to identify cases where the superblock
> > it is handling was created on a system with different PAGE_SIZE
> > assumptions.
> >
>
> The reason to do that is we don't have enough space to keep struct page
> backing the total number of pfns? If so, what i suggested above should
> handle that.
>
> or are you finding any other reason why we should fail a namespace init
> with a different PAGE_SIZE value?

I want the kernel to be able to start understand cross-architecture
and cross-configuration geometries. Which to me means incrementing the
info-block version and recording PAGE_SIZE and sizeof(struct page) in
the info-block directly.

> My another patch handle the details w.r.t devdax alignment for which
> devdax got created with PAGE_SIZE 4K but we are now trying to load that
> in a kernel with PAGE_SIZE 64k.

Sure, but what about the reverse? These info-block format assumptions
are as fundamental as the byte-order of the info-block, it needs to be
cross-arch compatible and the x86 assumptions need to be fully lifted.

