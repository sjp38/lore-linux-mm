Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B26CC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:07:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5F3B2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:07:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="fR9U+EFo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5F3B2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 606126B0003; Tue, 21 May 2019 12:07:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B68C6B0006; Tue, 21 May 2019 12:07:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4578C6B0007; Tue, 21 May 2019 12:07:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19CDB6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:07:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 73so9871811oty.2
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:07:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qHnInBfAX+GoWjJM5B+1a+Vw2rTdSHZyw1ZFE7z7NrY=;
        b=VHhMdm54pzjQPWe65BVt6yaauz2FFvozSrNuv/35y008J5gDeAJvyOnkaci0urcBJ9
         st2+FJ0hdSf2umCiLpxjQACjFAJ0QxqBrNgF94QG/iWdZY6am/Dszg034QBgGCvsBZ6o
         qVR4dF8Tv/qo/NDL/0RZ9UBi/Pt4ak6BHBHw1+QlKjwL2/QlCBMSJ+5miufjP0IVq7Eo
         J87TJZwRxKsUEqBiNUr1poQIz+BWWaC63vaSViDkzG83+GLyINdQd+fBAs0LE5ijKSof
         BRTEueT7Jc2Wt9VeRbygAa126AKp2b0d/Us9PomfhWihB9+O6cYq089nbZu+KhiJpZyb
         kIOA==
X-Gm-Message-State: APjAAAVxwG+f5jKoc/30fdepNhdX+SQ+JG1wxc5xhERTV/e1Fuhmv9a+
	UZ+u5KbRxXA1xa6sxb0466JBAgSpPp61UskLZKrAqyv90CSIz4j/3KcYZ54v8Fkle/b3c5SAZ3M
	q3JMM0TWfM8gX4fv0+fhNYOdOm5WpZepIIznXIfO5WQNCJmfXl0WI3+chP9MozswxtQ==
X-Received: by 2002:a9d:7d9a:: with SMTP id j26mr5629038otn.102.1558454834725;
        Tue, 21 May 2019 09:07:14 -0700 (PDT)
X-Received: by 2002:a9d:7d9a:: with SMTP id j26mr5628955otn.102.1558454833635;
        Tue, 21 May 2019 09:07:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558454833; cv=none;
        d=google.com; s=arc-20160816;
        b=EclFemG4mLbpwVeuWVghoo5WgpGNJrVmo2Xr/Vjo3qDuifY5b6k3M1se/09lbIDFrk
         ymzeSOGLK0jbmykTLRYnAsKyuuqI503bY/5bBH3C9zrEx8t5X7wkA2gW8uU7227GJ9ok
         mcjeyxI/2Or6qJX0QdJw1PwqSxa/vdXrIhKrPuYuttDvPAEAlnA80WCSbWkG8Se1pKwe
         /lmsGU8uYBJx/R8tJlEhHwFFnRpASdGP2bZTB8r/AKU/A+QJOnMNTPFCIM34ZzEB4LDs
         2Ozpe9og9H7/GeP0AfCecjVw00/sPrqOr+f4ne2PAzdRr7C9ucxfaNUJ0Bq9cCUYEude
         YYxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qHnInBfAX+GoWjJM5B+1a+Vw2rTdSHZyw1ZFE7z7NrY=;
        b=brJmBte6THuy5NQI3IknzPM9E6s08ZlLAllRvdJWud7krmbslju3zsEniQHp/o4mxj
         MmgOyPlmLTEIbSuivA30Hvg50/0a7ijY5X8UBOIlRTUErcmGLqH6uH8U5++NL0geYq8c
         Uo6/pDOV3uUsehpHR1ussxju9RPyfRDKolhNCCTpsBGUyQMgXZ5/fOKOfx9rqQwzkcbS
         iuMMMDC0kpfG01Dxs49Zy+SW8BwPIWoEV8k2o3lAK9MgKK/NwHl9W2xu+g2kz9S0+0tb
         ZXsX7JHYxf9nBoRP5QOQod0/MtIYFg3kL2HnIvbEq4OfxaG1yWV0L56GKM5wUn5Ux10c
         RCHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=fR9U+EFo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e75sor8848111oib.55.2019.05.21.09.07.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 09:07:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=fR9U+EFo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qHnInBfAX+GoWjJM5B+1a+Vw2rTdSHZyw1ZFE7z7NrY=;
        b=fR9U+EFoXp6HhXYT9l+xkijMGif7K3fz6bincJ22ZbB0d6OaUaMGrTRXdelLknFbfs
         W+ZLsKJExrH5KaDHoKhSWCC0/MjPf0uktzpjdZekcC4BUpuM8dhQqEakhcSRzwfEdR3W
         jdIEyi0RF68bIxCaFkl2lXnmRjr9DXLFTvqkBJCMLZxu0mjAr03gDUfxrgObVP4QkZIe
         XwmJkmntN9CT1/uHTWvoG53gNa+73/obZEpIGYFxHczx8aaM2A6Zmax3vR9Zc+q3Ft8s
         Qob6I/4L4bOjfPB2cVs9qYt4TPBKLg2RM962LdsC2KdYawUOqjKbIHg4YRO45qE0w3Wz
         MrMw==
X-Google-Smtp-Source: APXvYqyu5x5mrKlEIasKp1NxpDGYmQJsGvrx6mxQiUGAiiyjZAOGd76nwvRmcYQhvDtlfylqQ/dEPb7N7a77yrnQFHQ=
X-Received: by 2002:aca:ab07:: with SMTP id u7mr3889695oie.73.1558454833247;
 Tue, 21 May 2019 09:07:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
 <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com> <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com>
 <02d1d14d-650b-da38-0828-1af330f594d5@linux.ibm.com> <CAPcyv4jcSgg0wxY9FAM4ke9JzVc9Pu3qe6dviS3seNgHfG2oNw@mail.gmail.com>
 <87mujgcf0h.fsf@linux.ibm.com>
In-Reply-To: <87mujgcf0h.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 May 2019 09:07:02 -0700
Message-ID: <CAPcyv4j5Y+AFkbvYjDnfqTdmN_Sq=O0qfGUorgpjAE8Ww7vH=A@mail.gmail.com>
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

On Tue, May 21, 2019 at 2:51 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > On Mon, May 13, 2019 at 9:46 PM Aneesh Kumar K.V
> > <aneesh.kumar@linux.ibm.com> wrote:
> >>
> >> On 5/14/19 9:42 AM, Dan Williams wrote:
> >> > On Mon, May 13, 2019 at 9:05 PM Aneesh Kumar K.V
> >> > <aneesh.kumar@linux.ibm.com> wrote:
> >> >>
> >> >> On 5/14/19 9:28 AM, Dan Williams wrote:
> >> >>> On Mon, May 13, 2019 at 7:56 PM Aneesh Kumar K.V
> >> >>> <aneesh.kumar@linux.ibm.com> wrote:
> >> >>>>
> >> >>>> The nfpn related change is needed to fix the kernel message
> >> >>>>
> >> >>>> "number of pfns truncated from 2617344 to 163584"
> >> >>>>
> >> >>>> The change makes sure the nfpns stored in the superblock is right value.
> >> >>>>
> >> >>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> >> >>>> ---
> >> >>>>    drivers/nvdimm/pfn_devs.c    | 6 +++---
> >> >>>>    drivers/nvdimm/region_devs.c | 8 ++++----
> >> >>>>    2 files changed, 7 insertions(+), 7 deletions(-)
> >> >>>>
> >> >>>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> >> >>>> index 347cab166376..6751ff0296ef 100644
> >> >>>> --- a/drivers/nvdimm/pfn_devs.c
> >> >>>> +++ b/drivers/nvdimm/pfn_devs.c
> >> >>>> @@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> >> >>>>                    * when populating the vmemmap. This *should* be equal to
> >> >>>>                    * PMD_SIZE for most architectures.
> >> >>>>                    */
> >> >>>> -               offset = ALIGN(start + reserve + 64 * npfns,
> >> >>>> -                               max(nd_pfn->align, PMD_SIZE)) - start;
> >> >>>> +               offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
> >> >>>> +                              max(nd_pfn->align, PMD_SIZE)) - start;
> >> >>>
> >> >>> No, I think we need to record the page-size into the superblock format
> >> >>> otherwise this breaks in debug builds where the struct-page size is
> >> >>> extended.
> >> >>>
> >> >>>>           } else if (nd_pfn->mode == PFN_MODE_RAM)
> >> >>>>                   offset = ALIGN(start + reserve, nd_pfn->align) - start;
> >> >>>>           else
> >> >>>> @@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> >> >>>>                   return -ENXIO;
> >> >>>>           }
> >> >>>>
> >> >>>> -       npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
> >> >>>> +       npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
> >> >>>
> >> >>> Similar comment, if the page size is variable then the superblock
> >> >>> needs to explicitly account for it.
> >> >>>
> >> >>
> >> >> PAGE_SIZE is not really variable. What we can run into is the issue you
> >> >> mentioned above. The size of struct page can change which means the
> >> >> reserved space for keeping vmemmap in device may not be sufficient for
> >> >> certain kernel builds.
> >> >>
> >> >> I was planning to add another patch that fails namespace init if we
> >> >> don't have enough space to keep the struct page.
> >> >>
> >> >> Why do you suggest we need to have PAGE_SIZE as part of pfn superblock?
> >> >
> >> > So that the kernel has a chance to identify cases where the superblock
> >> > it is handling was created on a system with different PAGE_SIZE
> >> > assumptions.
> >> >
> >>
> >> The reason to do that is we don't have enough space to keep struct page
> >> backing the total number of pfns? If so, what i suggested above should
> >> handle that.
> >>
> >> or are you finding any other reason why we should fail a namespace init
> >> with a different PAGE_SIZE value?
> >
> > I want the kernel to be able to start understand cross-architecture
> > and cross-configuration geometries. Which to me means incrementing the
> > info-block version and recording PAGE_SIZE and sizeof(struct page) in
> > the info-block directly.
> >
> >> My another patch handle the details w.r.t devdax alignment for which
> >> devdax got created with PAGE_SIZE 4K but we are now trying to load that
> >> in a kernel with PAGE_SIZE 64k.
> >
> > Sure, but what about the reverse? These info-block format assumptions
> > are as fundamental as the byte-order of the info-block, it needs to be
> > cross-arch compatible and the x86 assumptions need to be fully lifted.
>
> Something like the below (Not tested). I am not sure what we will init the page_size
> for minor version < 3. This will mark the namespace disabled if the
> PAGE_SIZE and sizeof(struct page) doesn't match with the values used
> during namespace create.

Yes, this is on the right track.

I would special-case page_size == 0 as 4096 and page_struct_size == 0
as 64. If either of those is non-zero then the info-block version
needs to be revved and it needs to be crafted to make older kernels
fail to parse it.

There was an earlier attempt to implement minimum info-block versions here:

https://lore.kernel.org/lkml/155000670159.348031.17631616775326330606.stgit@dwillia2-desk3.amr.corp.intel.com/

...but that was dropped in favor of the the "sub-section" patches.

