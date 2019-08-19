Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5E6EC3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:57:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B10222CEA
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:57:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="W8kT6Fr/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B10222CEA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 473946B0005; Mon, 19 Aug 2019 12:57:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FD9C6B0006; Mon, 19 Aug 2019 12:57:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C5476B0007; Mon, 19 Aug 2019 12:57:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0007.hostedemail.com [216.40.44.7])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9A36B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:57:32 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9DE88181AC9B4
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:57:31 +0000 (UTC)
X-FDA: 75839783502.03.note67_7bd7b67997100
X-HE-Tag: note67_7bd7b67997100
X-Filterd-Recvd-Size: 7736
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:57:30 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id z17so2295408otk.13
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:57:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pJz5TWO3HqyvAXE4n+BERy8lXD9ov5MYFtm7ShaG7iE=;
        b=W8kT6Fr/sEKxeSab1zBTk5JmxeNrMn3Y1y9/NC6skSJLvVLBpW2ELhqcqg2h/if0uo
         0e8cjTy1LAF1Gp91oUKURmAqKMUXzQV99WjzHQAckRWlWwZydwlX4OAE7w5BXV4Gck6w
         GiAIVZOWzO9pzIRCQsQGroFmdMWbCV+OXwt4Dr3D/b8p/Qgjbg1z1NnBqPE5Th27Iwbb
         i338YQEJW6ag0i7lkkgY8YnQ7DkrhkfUCVp03brb7sfSpLA7e1XuEBndRU1OztKXhSBQ
         fsd5RglSvHSgc9joGVk9HozoM7cGL+u/Hfjrw8aAZuNaWmcC4QRxznSAAWCjivAlSDZc
         DXLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=pJz5TWO3HqyvAXE4n+BERy8lXD9ov5MYFtm7ShaG7iE=;
        b=DKhhZv+0otNPf0sbx5GZgzabOHPnpkpeIm+H3O5MsuC+tj5JuiNPFvsDagvyIiMhu2
         fwn+zAknfWK0MHNOAQ3QgGQA0prgJF+FerDWuCmQAY16H3WOOHh7Kkejs+8LJwBP6tkD
         bwBGqqRptnAr6rOmrW2v3hRdLB0BZ0HCRxl1crONo0p1X2UuxXYrGunfdZPWovIHnrc+
         C6AfwyMeAu7t3iB4bKVrnvrqjBl6YSIbZT8ud1hCei3BNgrY4ZVJuSpcQiGuYXeI5E0o
         f47gKHUHdfYSittyvHge2cnNAn8LapKifXxwfP/+djfIdriRbdnC8ExdQ97bWLz9/KcT
         9uig==
X-Gm-Message-State: APjAAAWTPDrNirfVxQQhN44xRQI3oqWJ09A0T/2auZjwENtY7w9qCr3K
	4wLFcvX+mHJX9rpPeF/OsSIpj2m7a5fZvXsFGdJAQg==
X-Google-Smtp-Source: APXvYqxvT1ZhKsDRbIwEX3IPiYRXr1CqtbSoNIsXLF0FOsAY+MiDfaUIE2LkS31VaEmcuGd2KBhyxsoTwTJiAVryN6M=
X-Received: by 2002:a9d:6b96:: with SMTP id b22mr19649081otq.363.1566233849670;
 Mon, 19 Aug 2019 09:57:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com>
 <20190809074520.27115-2-aneesh.kumar@linux.ibm.com> <CAPcyv4jmxKPkTh0_Bbu2tRXm4vcBHonZJ6UcKrOBnPGCG2_i1A@mail.gmail.com>
 <CAPcyv4hxo4HvtqZ-B6JG5iATo_vEAKPzO5EU5Lugs2_edEbW7Q@mail.gmail.com> <87y2zp1vph.fsf@linux.ibm.com>
In-Reply-To: <87y2zp1vph.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 19 Aug 2019 09:57:17 -0700
Message-ID: <CAPcyv4hWpFs6Q8VM35ip+DQ4thhzu6gaGxpdtkkMvj=xYb+eag@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] nvdimm: Consider probe return -EOPNOTSUPP as success
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 12:07 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > On Tue, Aug 13, 2019 at 9:22 PM Dan Williams <dan.j.williams@intel.com> wrote:
> >>
> >> Hi Aneesh, logic looks correct but there are some cleanups I'd like to
> >> see and a lead-in patch that I attached.
> >>
> >> I've started prefixing nvdimm patches with:
> >>
> >>     libnvdimm/$component:
> >>
> >> ...since this patch mostly impacts the pmem driver lets prefix it
> >> "libnvdimm/pmem: "
> >>
> >> On Fri, Aug 9, 2019 at 12:45 AM Aneesh Kumar K.V
> >> <aneesh.kumar@linux.ibm.com> wrote:
> >> >
> >> > This patch add -EOPNOTSUPP as return from probe callback to
> >>
> >> s/This patch add/Add/
> >>
> >> No need to say "this patch" it's obviously a patch.
> >>
> >> > indicate we were not able to initialize a namespace due to pfn superblock
> >> > feature/version mismatch. We want to consider this a probe success so that
> >> > we can create new namesapce seed and there by avoid marking the failed
> >> > namespace as the seed namespace.
> >>
> >> Please replace usage of "we" with the exact agent involved as which
> >> "we" is being referred to gets confusing for the reader.
> >>
> >> i.e. "indicate that the pmem driver was not..." "The nvdimm core wants
> >> to consider this...".
> >>
> >> >
> >> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> >> > ---
> >> >  drivers/nvdimm/bus.c  |  2 +-
> >> >  drivers/nvdimm/pmem.c | 26 ++++++++++++++++++++++----
> >> >  2 files changed, 23 insertions(+), 5 deletions(-)
> >> >
> >> > diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
> >> > index 798c5c4aea9c..16c35e6446a7 100644
> >> > --- a/drivers/nvdimm/bus.c
> >> > +++ b/drivers/nvdimm/bus.c
> >> > @@ -95,7 +95,7 @@ static int nvdimm_bus_probe(struct device *dev)
> >> >         rc = nd_drv->probe(dev);
> >> >         debug_nvdimm_unlock(dev);
> >> >
> >> > -       if (rc == 0)
> >> > +       if (rc == 0 || rc == -EOPNOTSUPP)
> >> >                 nd_region_probe_success(nvdimm_bus, dev);
> >>
> >> This now makes the nd_region_probe_success() helper obviously misnamed
> >> since it now wants to take actions on non-probe success. I attached a
> >> lead-in cleanup that you can pull into your series that renames that
> >> routine to nd_region_advance_seeds().
> >>
> >> When you rebase this needs a comment about why EOPNOTSUPP has special handling.
> >>
> >> >         else
> >> >                 nd_region_disable(nvdimm_bus, dev);
> >> > diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> >> > index 4c121dd03dd9..3f498881dd28 100644
> >> > --- a/drivers/nvdimm/pmem.c
> >> > +++ b/drivers/nvdimm/pmem.c
> >> > @@ -490,6 +490,7 @@ static int pmem_attach_disk(struct device *dev,
> >> >
> >> >  static int nd_pmem_probe(struct device *dev)
> >> >  {
> >> > +       int ret;
> >> >         struct nd_namespace_common *ndns;
> >> >
> >> >         ndns = nvdimm_namespace_common_probe(dev);
> >> > @@ -505,12 +506,29 @@ static int nd_pmem_probe(struct device *dev)
> >> >         if (is_nd_pfn(dev))
> >> >                 return pmem_attach_disk(dev, ndns);
> >> >
> >> > -       /* if we find a valid info-block we'll come back as that personality */
> >> > -       if (nd_btt_probe(dev, ndns) == 0 || nd_pfn_probe(dev, ndns) == 0
> >> > -                       || nd_dax_probe(dev, ndns) == 0)
> >>
> >> Similar need for an updated comment here to explain the special
> >> translation of error codes.
> >>
> >> > +       ret = nd_btt_probe(dev, ndns);
> >> > +       if (ret == 0)
> >> >                 return -ENXIO;
> >> > +       else if (ret == -EOPNOTSUPP)
> >>
> >> Are there cases where the btt driver needs to return EOPNOTSUPP? I'd
> >> otherwise like to keep this special casing constrained to the pfn /
> >> dax info block cases.
> >
> > In fact I think EOPNOTSUPP is only something that the device-dax case
> > would be concerned with because that's the only interface that
> > attempts to guarantee a given mapping granularity.
>
> We need to do similar error handling w.r.t fsdax when the pfn superblock
> indicates different PAGE_SIZE and struct page size?

Only in the case where PAGE_SIZE is less than the pfn superblock page
size, the memmap is stored on pmem, and the reservation is too small.
Otherwise the PAGE_SIZE difference does not matter in practice for the
fsdax case... unless I'm overlooking another failure case?

> I don't think btt
> needs to support EOPNOTSUPP. But we can keep it for consistency?

That's not a sufficient argument in my mind. The comment about why
EOPNOTSUPP is treated specially should have a note about the known
usages, and since there is no BTT case for it lets leave it out.

