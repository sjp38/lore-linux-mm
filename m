Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E98A6C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:29:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAA1620843
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:29:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ca7lJ9q1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAA1620843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B77F6B0003; Tue, 14 May 2019 00:29:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 369106B0005; Tue, 14 May 2019 00:29:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20A1E6B0007; Tue, 14 May 2019 00:29:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA3456B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:29:40 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id h4so8542084otl.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:29:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6vL7R6NOOH4/SZmC8qbbcIighH9Rr6CdIXeg8QuQUhw=;
        b=HlsFQnU2bvWymgDXXapX746YPSzgRRx9NPXeNazZ2D88qd2r2o/t6B7CDoBTMccnYj
         Nn60d1JglqQ6P0YdKAAS6SoU+yq6P8CYVhbJdG11lG118ZkhqPrkfHMzk7pnRcYvGr2x
         A+uHjCb6MleXoMv75N+alJdsGxsaIau+c1wD5YyUmA9TvvLr8XFKXVdZ95+tjI/Ot3qR
         zlzQQQO4uxeE7TWIg7GYrTVA8uzpNmx4ihMVEgvGP87dGw8vy03/8WnoADQrO3LfY/N2
         K1j0bfPr/uBR5/e8I8YBYAWbv+y12lp5tC94e/xjK2DjX514U5Rzum+tTpCoMZuLVMxm
         Q51g==
X-Gm-Message-State: APjAAAWvZRU7Plh0QxvQIDKp3vIvE33tXTPALY/ODnBxDP8hyUb58i7x
	td30Sh9l/HP5QKMQMLzNjxy0Lr1LAT+1bJBeDYFA1FgJQwlnvohvWerMVHnvblpwgGUOU36+pBt
	EJ+y8P1V/LT23jP/Q7u8fpukZSTQfMr9S/pk4XduR+9x1KLIrAmzP7qWvNHYVS2xTAQ==
X-Received: by 2002:a9d:67d0:: with SMTP id c16mr2247836otn.177.1557808180663;
        Mon, 13 May 2019 21:29:40 -0700 (PDT)
X-Received: by 2002:a9d:67d0:: with SMTP id c16mr2247816otn.177.1557808180066;
        Mon, 13 May 2019 21:29:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557808180; cv=none;
        d=google.com; s=arc-20160816;
        b=cHJnR8LFnhK7OOYOSer49ZqZebhVgnP3QadhuXZZrlSLw0eFzpeq8La7+Ml2pbeqKK
         i0/UWR+9AdOCPl+7Cn5mqhOl9SyPYUA28G9rgQ3OGwKLzk02IB5NsqgOk5nYBSEITi2/
         O9PjPPElNC3Rkst+OR1Cg1uBk+1V02l15Wcanc8j7yZoX53+5WS5lC8zWU8GBxc1oVt0
         MKU29OLQegMcGSmDbzfkC7a+cQzAKAu6PkUdH1FkCPe2NJQhc0PnjNVAFhCQbd5pLia3
         8QGubsxD8uVltDBDUjprU7oeCn9f5LOdKMAcAm+p0VLVAP5+aZzE4+OL+7jYSdwuvtG6
         2N7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6vL7R6NOOH4/SZmC8qbbcIighH9Rr6CdIXeg8QuQUhw=;
        b=A8IYnfrqtyFKHXhwMqvR+AgXrbmGu1UDsQ2KNIRgg/EZdhioqgQX4GgvqAPWbKAsfO
         C06IumS8HLNr5mpL4OyzaMjp4J2JwfA6XEGOexh+VEx2Wx+nMcC4rjlkvXaXYqFs3g8P
         C41Bll+HWaILyU1nHSKs1k615Z6dBuIpxRqIbYtmvE97bMtCsEWR72ioCtsFYlvAfTUI
         7nvod2LoIETCs41+mH4nXhsqx6Aj8v7pdN346o6ZgMlPEBat6k1T40HMlKA6OQdhUOqQ
         zfz/MLIhh8SrZDdFK0T0PX2inZcgPFK5emgiZz1kEo2Gugobu44ugXXyW/O8NOgy42iB
         URgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ca7lJ9q1;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k196sor6634272oih.99.2019.05.13.21.29.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 21:29:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ca7lJ9q1;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6vL7R6NOOH4/SZmC8qbbcIighH9Rr6CdIXeg8QuQUhw=;
        b=ca7lJ9q1TJHOspurY5SiG+tHkkdWZroHZnYXr6E1fYxTHIglIKUUCOOdV0IxjunZzr
         +zcp8l1ucKONHdlsOcEiB2Zy9W9Pni/ehn3I2g/oEjDJLcZKRAb2UaLPO8k8MQCtRQX+
         ygYmAqQCzVfQKkhtwKl8RVXgOpV9BbBWb1iCf1p9juBMVTtoRq7zo9b79O9kM9J+q+yt
         9KC4mIC5sgRMvbh0rjBGPLV87kAnDQ7Y0Cf+VI9uvMjJjlqzD51foAlUir32+gYxLWsB
         k7wTsfd4zq5WbTXDUqS9sBC7lUUFQo5ZjJZQcy6DReMx5iYolN0vSuVSggR2SNCwWpDB
         R4ZQ==
X-Google-Smtp-Source: APXvYqzLwmq4m9vHhU9l+xYTiYeGeku1c2XDiTm1WK0D+0mp/qoqdLnVFB1/BBjQKk2+37HqJ9cVipeEEeNJglytCCU=
X-Received: by 2002:aca:4208:: with SMTP id p8mr1834968oia.105.1557808179717;
 Mon, 13 May 2019 21:29:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190514025512.9670-1-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190514025512.9670-1-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 13 May 2019 21:29:28 -0700
Message-ID: <CAPcyv4hgNUDxjgYNkxOXJ9hfLb6z2+E1yasNoZNDKFUxkCzWLA@mail.gmail.com>
Subject: Re: [PATCH] mm/nvdimm: Use correct alignment when looking at first
 pfn from a region
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 7:55 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> We already add the start_pad to the resource->start but fails to section
> align the start. This make sure with altmap we compute the right first
> pfn when start_pad is zero and we are doing an align down of start address.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  kernel/memremap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index a856cb5ff192..23d77b60e728 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -59,9 +59,9 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
>  {
>         const struct resource *res = &pgmap->res;
>         struct vmem_altmap *altmap = &pgmap->altmap;
> -       unsigned long pfn;
> +       unsigned long pfn = PHYS_PFN(res->start);
>
> -       pfn = res->start >> PAGE_SHIFT;
> +       pfn = SECTION_ALIGN_DOWN(pfn);

This does not seem right to me it breaks the assumptions of where the
first expected valid pfn occurs in the passed in range.

