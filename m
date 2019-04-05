Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56691C282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:56:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05FD220989
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:56:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="tFbxiFCj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05FD220989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9883F6B0010; Fri,  5 Apr 2019 12:56:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90ECE6B026A; Fri,  5 Apr 2019 12:56:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5EE6B026B; Fri,  5 Apr 2019 12:56:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4186B0010
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:56:35 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 70so3313673otn.15
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:56:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xavCft+C6hfoU6dVK4RbtLhBzX2Anxg99S9rWxDEYx0=;
        b=TpoA9lWsr9RlhACRVB0RjWivIq62MRXaRGoPaYMBjOgQ+MpXHEZGACcGaZQVbVlRnv
         oJmxnlDLUOwIzTTemNYR9avAWjvofShi9tg1y8oUGlzmadkLUbVfhPX9ZjP5V3yAKkMI
         5DX0P0/zLKNxywGwGq14MxO7SRC/TL1l+I11ol+Q8PqsZhuzU/u4a4G0OcAZBYacAyqV
         nIZ70JdyLKro6U+WIORMt8pha2B9GXs3K0fhK2y134gHnOUr1bz7akthfn7odKWIcb6Y
         DRoaVHNJ947RJrUFj9IouCO9ymVc/It6dRPdEVTXicfx/3jSUQEWIwmJQgVzu3FgD+vZ
         jNSA==
X-Gm-Message-State: APjAAAUi778bpeV+mRuApFL64sX7BuoXSiPwAaDnMiOr59wmVt2Qd7eu
	Wbf16EOHhlyW5LS+l0H580JWn4uPYKQ5YCdyxJVZtoOVJPI26MNOFABQZTLy10hxlrUlSu3XNge
	8h5/vfZVclN8aJxssTS/jFpY7owavvYlo8+B6yXaQ1ZRecjImgFBg2uRdXBOhaneoKw==
X-Received: by 2002:aca:ba54:: with SMTP id k81mr7859690oif.32.1554483394850;
        Fri, 05 Apr 2019 09:56:34 -0700 (PDT)
X-Received: by 2002:aca:ba54:: with SMTP id k81mr7859664oif.32.1554483394099;
        Fri, 05 Apr 2019 09:56:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554483394; cv=none;
        d=google.com; s=arc-20160816;
        b=RfEPjFxTli3hDh/sp/YR73ICSsvD7JLS7yjSdBVZa1fc/Rl5hsJrMDuM+f853uH23X
         g2aopEXFvuqS9gFhcqrMbHazSQmXOXqM6xMy49x/+Hk0FeFXFxebEEa+iyOun5MkxVNa
         RN8PWt7zaY4V/QXYY+z3EPPAF+f12I2snj8y3s+H/JPlT63v5y6N6hhmD4+9de5HsnZQ
         b2BBHDLQeFq+Q9VBciu3BSVaKIZFIjP4t1y7r8dZ8mEzjtRAIJn1KCr8BFK/9vGQdURh
         5ldJXPTI1cgOev1Hotl80sZujNZ2dAGEsNOCcK6McqeK7eKoLwWulIFp00CjHwk7xO7u
         BF7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xavCft+C6hfoU6dVK4RbtLhBzX2Anxg99S9rWxDEYx0=;
        b=NCsMNfPnqlbA2TpyTd9ZVIB8t0pyIqC18rWov5oaMG+VhirQPtVO1HIO7smIOPrVAK
         lwtM28kwzAQ03wa/JMzJlIXd6WqxTsnGTB8b2sts3UY/vaVOt05SPl9UmqpqoIF7UmNx
         /7HCKsk81yJ8sP+tYDkyrTuzN3eyoXe81tQbXPQb+1PWDoN9oZvKh3s0oacbz5eBTQ7/
         g+wBkVztb54LH1i0zmD3MlhC+j1dB/tWZIwHk0PlwklvmVTaXLKZTkfno24n2Fd8ha7/
         74a2BaqGjRmTuVbnZyYJq2jtl+SlAAXCltJawVU5fY9dp95/L5aTyLqmywQfdX1GTi/5
         PhwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tFbxiFCj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b83sor8782013oif.63.2019.04.05.09.56.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 09:56:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tFbxiFCj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xavCft+C6hfoU6dVK4RbtLhBzX2Anxg99S9rWxDEYx0=;
        b=tFbxiFCj5OvH6SJQqvHiAcjrMt5420iIjxgkILb1RM44b50Hjp33zCOaEC5xyj3KqT
         5Ll2LohthpbLBhxt1bJa1rwmN/4K2IB2YEcqVqbEn/DSpS59gBFy/B/hc0eFUDxaPu9J
         N884im08a3qquWjvqFxOvDe63X8T4h3IQ6v6JirVrBDd43mUL4bxO4y85XdfhPqmgAnF
         aCCjQFKNmXTdrMkkLZmfSV9N+S7bwwBVl+HNgCZdUE8s2s0JdEZ8gV0JEOOL5oqaEG3S
         U9DMqbfD68OfH3E4iYFyo8jmWEMK5rh8fNOAW1y8f+gy/8fGTWo4JTUyepMASxcIvC1Y
         wMfQ==
X-Google-Smtp-Source: APXvYqwBHpXfBFhHch+BoQ2/9YwlCAStfJv2kGHIns1Jas0uMBB5rQNTCvAIXmb/6bBYetz/3sIH2fwI0z826ndqqUI=
X-Received: by 2002:aca:e64f:: with SMTP id d76mr8406772oih.105.1554483393559;
 Fri, 05 Apr 2019 09:56:33 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190405121857.0000718a@huawei.com> <CAPcyv4hpKkWm0x2jecvmtLNgmwUnAZn3jM_9sKyBAUFaRLj=cQ@mail.gmail.com>
 <20190405172342.00006a56@huawei.com>
In-Reply-To: <20190405172342.00006a56@huawei.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 5 Apr 2019 09:56:22 -0700
Message-ID: <CAPcyv4hxBFcJKbVVgNiE4UYXZS4XY9hfE8W9mN+VrcWS9AvJLw@mail.gmail.com>
Subject: Re: [RFC PATCH 4/5] acpi/hmat: Register special purpose memory as a device
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, 
	Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 5, 2019 at 9:24 AM Jonathan Cameron
<jonathan.cameron@huawei.com> wrote:
>
> On Fri, 5 Apr 2019 08:43:03 -0700
> Dan Williams <dan.j.williams@intel.com> wrote:
>
> > On Fri, Apr 5, 2019 at 4:19 AM Jonathan Cameron
> > <jonathan.cameron@huawei.com> wrote:
> > >
> > > On Thu, 4 Apr 2019 12:08:49 -0700
> > > Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > > Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
> > > > properties described by the ACPI HMAT is expected to have an application
> > > > specific consumer.
> > > >
> > > > Those consumers may want 100% of the memory capacity to be reserved from
> > > > any usage by the kernel. By default, with this enabling, a platform
> > > > device is created to represent this differentiated resource.
> > > >
> > > > A follow on change arranges for device-dax to claim these devices by
> > > > default and provide an mmap interface for the target application.
> > > > However, if the administrator prefers that some or all of the special
> > > > purpose memory is made available to the core-mm the device-dax hotplug
> > > > facility can be used to online the memory with its own numa node.
> > > >
> > > > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > > > Cc: Len Brown <lenb@kernel.org>
> > > > Cc: Keith Busch <keith.busch@intel.com>
> > > > Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> > > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > >
> > > Hi Dan,
> > >
> > > Great to see you getting this discussion going so fast and in
> > > general the approach makes sense to me.
> > >
> > > I'm a little confused why HMAT has anything to do with this.
> > > SPM is defined either via the attribute in SRAT SPA entries,
> > > EF_MEMORY_SP or via the EFI memory map.
> > >
> > > Whether it is in HMAT or not isn't all that relevant.
> > > Back in the days of the reservation hint (so before yesterday :)
> > > it was relevant obviously but that's no longer true.
> > >
> > > So what am I missing?
> >
> > It's a good question, and an assumption I should have explicitly
> > declared in the changelog. The problem with EFI_MEMORY_SP is the same
> > as the problem with the EfiPersistentMemory type, it isn't precise
> > enough on its own for the kernel to delineate 'type' or
> > device/replaceable-unit boundaries. For example, I expect one
> > EFI_MEMORY_SP range of a specific type may be contiguous with another
> > range of a different type. Similar to the NFIT there is no requirement
> > in the specification that platform firmware inject multiple range
> > entries. Instead that precision is left to the SRAT + HMAT, or the
> > NFIT in the case of PMEM.
>
> Absolutely, as long as they are all SPM, they could be anywhere in
> the system.
>
> >
> > Conversely, and thinking through this a bit more, if a memory range is
> > "special", but the platform fails to enumerate it in HMAT I think
> > Linux should scream loudly that the firmware is broken and leave the
> > range alone. The "scream loudly" piece is missing in the current set,
> > but the "leave the range alone" functionality is included.
>
> I am certainly keen on screaming if the various entries are inconsistent
> but am not sure they necessarily are here.
>
> So there are a couple of ways we could get an SPM range defined.
> The key thing here is that firmware should be attempting to describe
> what it has to some degree somewhere.  If not it won't get a good
> result ;)  So if there is no SRAT then you are on your own. SCREAM!
>
> 1. Directly in the memory map.  If there is no other information then
>    tough luck the kernel can only sensibly handle it as one device.
>    Or not at all, which seems like a reasonable decision to me.
>    SCREAM
>
> 2. In memory map + a proximity domain entry in SRAT.  Given memory
>    with different characteristics should be in different proximity
>    domains anyway - this should be fairly precise. The slight snag
>    here is that the fine grained nature of SRAT is actually a side
>    effect of HMAT, so not sure well platforms have traditional
>    describe their more subtle differences.
>
> 3. In NFIT as NFIT SPA carries the memory attribute.  Not sure if
>    we should scream if this disagrees with the memory map.
>
> 4. In HMAT?  Now this changed in ACPI 6.3 to clean up the 'messy'
>    prior relationship between it and SRAT.  Now HMAT no longer has
>    memory address ranges as you observed.  That means, to describe
>    properties of memory, it has to use the proximity domains of
>    SRAT.  It provides lots of additional info about those domains
>    but it is SRAT that defines them.
>
> So I would argue that HMAT itself doesn't tell us anything useful.
> SRAT certainly does though so I think this should be coming from
> SRAT (or NFIT as that also defines the required precision)

I agree, yes, SRAT by itself is sufficient for this "precision"
concern. However, do we, core Linux developers, really want to
encourage platform vendors that they can ignore deploying HMAT data
and get Linux to honor that sub-case for EFI_MEMORY_SP? My personal
experience is that platform firmware will take advantage of almost any
opportunity to minimize the data it provides to the OS. The only hard
lever Linux has to encourage platform firmware to give complete data
is to decline to support configurations that have incomplete data.

