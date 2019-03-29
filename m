Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08918C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:15:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B553D2184C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:15:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="D0jFPgrd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B553D2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 314DC6B0007; Fri, 29 Mar 2019 17:15:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4186B0008; Fri, 29 Mar 2019 17:15:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18AB86B000A; Fri, 29 Mar 2019 17:15:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E18FA6B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 17:15:16 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id r23so2077611ota.17
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:15:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fr4m467rBB5Oh9X9hIyfmtCEuwGt8t/C6nshHo6m7qI=;
        b=Udjr2Lc2MyTQvV+vCgtByeO8ppYRcJ3q2jl7nzC1B0hJphu6dryhV2TIN8pVDkBMky
         9VV6bCQJJN3bygJn55N+Zf6wtWvITVEaDwxdxcqtTiIxV9v+lsJ5mxwZnMUsuBsFj5X2
         eI/0L2CS3Ar1qytZYw5JMPZSKoPSOGiSn3dY0R23+nvk63vrgQvm9FLBsEsUIKZVASUv
         PzNJXhNK612bS1SEkouPeilsn/5h7Tdpa+pJARjQNzP2/K6WH59XPS47kHtDJSoKOcBD
         wD93KLbp/Cgvg8JjaLRssNtCgJ8qGatCSsgh1Am9dTuy+8K57gRTDPHBtQW8+owxlkTO
         ZZoQ==
X-Gm-Message-State: APjAAAXrU/u0Mqs0KghjhYsM4Ouifse94lrEI8c3T457TX/lHtGVL/kt
	j4zxrtdrG+DWCP4sC0G75pBf7cgQJZJMAkvf4QejPRScdcnY+C69PEh98JrpcupH2JMANFxab5r
	+TKWXzKdHqkJKeMGDwAoCPzLLhg0KtuOvnNsgoee8KIWuVg0flHpI5vCZlg+Edpx1CQ==
X-Received: by 2002:aca:b607:: with SMTP id g7mr4906743oif.6.1553894116329;
        Fri, 29 Mar 2019 14:15:16 -0700 (PDT)
X-Received: by 2002:aca:b607:: with SMTP id g7mr4906690oif.6.1553894115460;
        Fri, 29 Mar 2019 14:15:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553894115; cv=none;
        d=google.com; s=arc-20160816;
        b=DmSTjlF+VWn5chriYXwDT44lM9XFOXTd6E+HO0AjbE5UltiuOdsiOHLqZRXg7gGaDy
         5YsTzkCLv4CWAsI6jmF7zaqKIJ2Ppyl2WRdjgAqikmV/eJoxjFRiQT9WcQT5KqaWsxFg
         iZOVRHoSCQvsV6uvqI/eBJHbdMiVtXdgRe8lrjfafuHi9DMy5R3fRFeZ+PB22T2XuCuD
         9+3XzWrZDjqjWeydmU02P5HVWiZ2kd86E2tkt3AFglxXntDNQQ+ihIsLU1hytl/rSH3C
         UgAKrXA/6gzPsYr7lVEh+yZZeysWhyjYwXOJuz3HEZPi2r8gf5El4gMu4FuaSLcdiFUA
         81pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fr4m467rBB5Oh9X9hIyfmtCEuwGt8t/C6nshHo6m7qI=;
        b=IBeC6EHIB+vQOUIkE5hMWksw41L7BgBM1jNjpzO6a69PDgIe2mQ+f/dqQ0MM6Y13W8
         DYvcPmvhlJtDbjhkQ0AmgEORv+EExPz9jyaGSFhppz85cRFmB+JrSVAgdAiSXokmTlhy
         AWI3Br0Wc6ozSnsM+aUUYANcvL0NUqaKa1hsJNCyOYM8jiyYYWLPhIkExGmQdArojVtm
         9U/PQQHs9m/OVA4NC765aqe/s1Nc8R9sbCdpogX9WkSrq2ipm8WFy30p4rCdkx+d+ji8
         Onk/m4zzyEYQ+RZUWaq7tXPYjuOCMbZ91xwtWp7xOLkOKjvP2zBP1Dw4DUBjp7SoYGeR
         ne0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=D0jFPgrd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h19sor2055628otj.124.2019.03.29.14.15.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 14:15:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=D0jFPgrd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fr4m467rBB5Oh9X9hIyfmtCEuwGt8t/C6nshHo6m7qI=;
        b=D0jFPgrdoX/w7QKQrtXXVxhEJBNKAm4MGQcDwHmWaOi3yAC04/LaXOTOWbdEcNw31h
         XuqsqgjuOspa16mZmBg9jWGtICjW9TUg8B6+bgE5ICgkEQjm+stpkTRlY+vP+3jhe0jq
         FCixCURzko0lKDjKYZPQfZu3tU9wdbEuNoTZFO60FN5gtx6E36ufLwG92MVhuvC/ZAm6
         xQxSFO3jukm+v47JMLmDQmRiMf+ekT2wO+4jPie1kQLoYi5gFMDgJ4frSBj6gApjf78H
         5zUKCnJQQ/zxD6p31gDPqTlTC2l+mKdcM9boUrX4L4m2dxkoW9ec8kOLyfVmqkGsudMH
         q37w==
X-Google-Smtp-Source: APXvYqygoTKjZ45FfFhTEE8Yxqw9f4CDP9yNPRjO5bWzq9gcMdknY3cWGKUkOooR3w8qGo75vLXsinSJHaRvK93E5Ic=
X-Received: by 2002:a9d:27e3:: with SMTP id c90mr11192297otb.214.1553894114951;
 Fri, 29 Mar 2019 14:15:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190311205606.11228-1-keith.busch@intel.com> <20190311205606.11228-8-keith.busch@intel.com>
In-Reply-To: <20190311205606.11228-8-keith.busch@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 29 Mar 2019 14:15:03 -0700
Message-ID: <CAPcyv4j5bLiUtmjdnjt7KNOtNm4sRHWp=5T3m1bWD=U1zBXeqQ@mail.gmail.com>
Subject: Re: [PATCHv8 07/10] acpi/hmat: Register processor domain to its memory
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, Jonathan Cameron <jonathan.cameron@huawei.com>, 
	Brice Goglin <Brice.Goglin@inria.fr>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 1:55 PM Keith Busch <keith.busch@intel.com> wrote:
>
> If the HMAT Subsystem Address Range provides a valid processor proximity
> domain for a memory domain, or a processor domain matches the performance
> access of the valid processor proximity domain, register the memory
> target with that initiator so this relationship will be visible under
> the node's sysfs directory.
>
> Since HMAT requires valid address ranges have an equivalent SRAT entry,
> verify each memory target satisfies this requirement.
>
> Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/Kconfig |   3 +-
>  drivers/acpi/hmat/hmat.c  | 392 +++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 393 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index 2f7111b7af62..13cddd612a52 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -4,4 +4,5 @@ config ACPI_HMAT
>         depends on ACPI_NUMA
>         help
>          If set, this option has the kernel parse and report the
> -        platform's ACPI HMAT (Heterogeneous Memory Attributes Table).
> +        platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
> +        and register memory initiators with their targets.
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 4758beb3b2c1..01a6eddac6f7 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -13,11 +13,105 @@
>  #include <linux/device.h>
>  #include <linux/init.h>
>  #include <linux/list.h>
> +#include <linux/list_sort.h>
>  #include <linux/node.h>
>  #include <linux/sysfs.h>
>
>  static __initdata u8 hmat_revision;
>
> +static __initdata LIST_HEAD(targets);
> +static __initdata LIST_HEAD(initiators);
> +static __initdata LIST_HEAD(localities);
> +
> +/*
> + * The defined enum order is used to prioritize attributes to break ties when
> + * selecting the best performing node.
> + */
> +enum locality_types {
> +       WRITE_LATENCY,
> +       READ_LATENCY,
> +       WRITE_BANDWIDTH,
> +       READ_BANDWIDTH,
> +};
> +
> +static struct memory_locality *localities_types[4];
> +
> +struct memory_target {
> +       struct list_head node;
> +       unsigned int memory_pxm;
> +       unsigned int processor_pxm;
> +       struct node_hmem_attrs hmem_attrs;
> +};
> +
> +struct memory_initiator {
> +       struct list_head node;
> +       unsigned int processor_pxm;
> +};
> +
> +struct memory_locality {
> +       struct list_head node;
> +       struct acpi_hmat_locality *hmat_loc;
> +};
> +
> +static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
> +{
> +       struct memory_initiator *initiator;
> +
> +       list_for_each_entry(initiator, &initiators, node)
> +               if (initiator->processor_pxm == cpu_pxm)
> +                       return initiator;
> +       return NULL;
> +}
> +
> +static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
> +{
> +       struct memory_target *target;
> +
> +       list_for_each_entry(target, &targets, node)
> +               if (target->memory_pxm == mem_pxm)
> +                       return target;
> +       return NULL;

The above implementation assumes that every SRAT entry has a unique
@mem_pxm. I don't think that's valid if the memory map is sparse,
right?

