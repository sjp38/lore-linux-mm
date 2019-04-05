Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0BBBC10F00
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:43:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B7CA21852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:43:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qWxjCJ2C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B7CA21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F9E06B0008; Fri,  5 Apr 2019 11:43:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A9A06B000D; Fri,  5 Apr 2019 11:43:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7981E6B0269; Fri,  5 Apr 2019 11:43:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB546B0008
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 11:43:16 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id q82so2934637oif.7
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 08:43:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sj5ur8Cq/BuzaN2ifegKjnKHNZadsvVGhfJ737scZtM=;
        b=MgQZ4NKb2rC9Isi3LPuqZhyUhfmJLfWbaG+r4wQEW9YBYaBdLrBf+9EMMklhEsuIPm
         nKi7QhDn1J+kebWYPnGPo5nZP1UXu4cyqmPDI8+awEU2QjGTQitskao8jzBW1c9erR4z
         4ZQMpp2ZdykhW90eDCyDZoZWjCqG2e1S+zXcJX+w/ChjaSAkzZTgrl704RWdOj4RrrT+
         CptZfsDBg7CyjN3T4yJou57wWnYNn4d3b3hHwxi+XX5AcWd/t5OZ0sq/FvSPW5RQXwxm
         zxJuMcYTeS3Q2bsZP+CzJd+xkEH0iWOZmW6Iq8uXpBi1XfH3A3pDM+z7WR/Lx5E0p1mW
         QnMA==
X-Gm-Message-State: APjAAAUFjrYVbHnNWKnmjhusgf55Gn0NDWcdiMASJREx+f9NL3Mx5UZA
	bl6CNI92fjMnw57DHxg7d1b6iIpLeHCrxWilCW/hCJ2rI3SFknovZbw6iR+HzTKhOnipLvGZP/+
	U26qTNEgx7i7EfvSCwQ3NQDlM4BOvq7+9+k74UCVxiwDBcqeb5aiOfxC1w+feIz7N0g==
X-Received: by 2002:aca:ab82:: with SMTP id u124mr7395031oie.41.1554478995919;
        Fri, 05 Apr 2019 08:43:15 -0700 (PDT)
X-Received: by 2002:aca:ab82:: with SMTP id u124mr7394998oie.41.1554478995148;
        Fri, 05 Apr 2019 08:43:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554478995; cv=none;
        d=google.com; s=arc-20160816;
        b=mBf6DX1tn3p/Gic7N+7QyjkJH920m8WzhZWaGHuthWoRGm2iNbuXacUygdGjSxGxEh
         +wy8FuYaZYiBgmPNHJy7l7d+A9mMqJqA7XoGRvzpKuxUlqiFHqnAnJvkNamB+WGGygyd
         7kgfNg0oQqy6rW+jnJoIU9iK4g8CAci8weRZ2Pn067ixEf0LKleKHRDQGtiMLemiMTkR
         26oY+sW8WYkQn0I0CXEWoBGqmI6hZQvNAFD93hvc5TgL34Yo7qPIIk57d71Zm6nIKiEb
         jyslvTi9uss1hxlIja/rJAktQzohi3fwxGib4BdyRdhdUMt/YIXVaurcRN2cNvqihZGv
         WbBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sj5ur8Cq/BuzaN2ifegKjnKHNZadsvVGhfJ737scZtM=;
        b=NEGDdF1+HlTycwnykY68Btgs8yF89Aq7IQn7ubyBQzVBBAOPy4SUmhtHjuyvfN6lOJ
         SKuBy6vTJmp+1k7ZkbxS3Cm1klJhrC7VvOC7eaolzt9gDbBMlgxGUNsoPRxhaqjYapfI
         mWqs0qKWWHzYRfmrzbtVL4UE74LHx3uwg5a/BFwDAWkfd/5M3Nr8b6AolhhqPVfzWcbK
         AdKoY0AKpZFRwGw2zLkAlXIBGrCFMkfNpN+2+x+F9vWYYjU5xjmAoaUaB5lXGjYrXSq4
         l7CDf7orgv+r+rgoZNQjqn9y/pRQVFVu6sYJglY6FejTdAV4cIN/LcWY99CR3HAwlIWW
         Tx7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qWxjCJ2C;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q206sor13025593oib.172.2019.04.05.08.43.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 08:43:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qWxjCJ2C;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sj5ur8Cq/BuzaN2ifegKjnKHNZadsvVGhfJ737scZtM=;
        b=qWxjCJ2C4YTGaRB9VBshlOczs86lXXi96/4MUM4KFNW57aHk+Y9NUay569AN2AVEAO
         Ew58BrpoYq3qi38QUMzCX4V3c6JMBwOQsD8Q/e6wvqNwRgeBKSLn5/AGWqh7sXQAyVFk
         MhYEexjZPJHL4F9KNMa+iE7I2xdyjpQ8lLA/rQjxnIZtVIhmnI3Tj/YRPtO2jUVyHBYV
         O8ZeJpoyAuDCVbZmR1CDJoKl4dtDEI2cMii1Vo/Jrz19wwDwZhGpZ7O4iApIt+QJwvDQ
         R0lacbsDF32fVMi22CzeDw38/8YGXp0LzKsO5dOflq27gqrNcwTw0QvEONmv7tyuEvaj
         X4RA==
X-Google-Smtp-Source: APXvYqwQIzEcgHJH2g95bHHSuUp6aFniNQQWMvFvEkdIRFFMM2bkcnOv77ZAMvXPrUVmGRcaUKHxXOM3RDJblZB6Pkg=
X-Received: by 2002:aca:aa57:: with SMTP id t84mr7929156oie.149.1554478994621;
 Fri, 05 Apr 2019 08:43:14 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190405121857.0000718a@huawei.com>
In-Reply-To: <20190405121857.0000718a@huawei.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 5 Apr 2019 08:43:03 -0700
Message-ID: <CAPcyv4hpKkWm0x2jecvmtLNgmwUnAZn3jM_9sKyBAUFaRLj=cQ@mail.gmail.com>
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

On Fri, Apr 5, 2019 at 4:19 AM Jonathan Cameron
<jonathan.cameron@huawei.com> wrote:
>
> On Thu, 4 Apr 2019 12:08:49 -0700
> Dan Williams <dan.j.williams@intel.com> wrote:
>
> > Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
> > properties described by the ACPI HMAT is expected to have an application
> > specific consumer.
> >
> > Those consumers may want 100% of the memory capacity to be reserved from
> > any usage by the kernel. By default, with this enabling, a platform
> > device is created to represent this differentiated resource.
> >
> > A follow on change arranges for device-dax to claim these devices by
> > default and provide an mmap interface for the target application.
> > However, if the administrator prefers that some or all of the special
> > purpose memory is made available to the core-mm the device-dax hotplug
> > facility can be used to online the memory with its own numa node.
> >
> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > Cc: Len Brown <lenb@kernel.org>
> > Cc: Keith Busch <keith.busch@intel.com>
> > Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Hi Dan,
>
> Great to see you getting this discussion going so fast and in
> general the approach makes sense to me.
>
> I'm a little confused why HMAT has anything to do with this.
> SPM is defined either via the attribute in SRAT SPA entries,
> EF_MEMORY_SP or via the EFI memory map.
>
> Whether it is in HMAT or not isn't all that relevant.
> Back in the days of the reservation hint (so before yesterday :)
> it was relevant obviously but that's no longer true.
>
> So what am I missing?

It's a good question, and an assumption I should have explicitly
declared in the changelog. The problem with EFI_MEMORY_SP is the same
as the problem with the EfiPersistentMemory type, it isn't precise
enough on its own for the kernel to delineate 'type' or
device/replaceable-unit boundaries. For example, I expect one
EFI_MEMORY_SP range of a specific type may be contiguous with another
range of a different type. Similar to the NFIT there is no requirement
in the specification that platform firmware inject multiple range
entries. Instead that precision is left to the SRAT + HMAT, or the
NFIT in the case of PMEM.

Conversely, and thinking through this a bit more, if a memory range is
"special", but the platform fails to enumerate it in HMAT I think
Linux should scream loudly that the firmware is broken and leave the
range alone. The "scream loudly" piece is missing in the current set,
but the "leave the range alone" functionality is included.

