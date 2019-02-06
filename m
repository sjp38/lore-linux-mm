Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F27AC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:28:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04D33218A3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:28:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04D33218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A60F8E00BD; Wed,  6 Feb 2019 07:28:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92ECA8E00AA; Wed,  6 Feb 2019 07:28:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F7208E00BD; Wed,  6 Feb 2019 07:28:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48A368E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:28:34 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id l202so1872045vke.1
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:28:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=fqKOmSzTo3ociiwy537HhxKc6e9NkW/a8Gqn0RlL0L0=;
        b=l9OjJynhvBjylpM5miNcmpNYCYI+kfBGY+n8b9pr+MoTi4WW9RJJwUMip08mhb0hT5
         XU46RQBOblYYI0Lmfn6fkxle+S+qMrrCuwbW/WS563IOnnVWlYEzEfF/cLxwbi7ano8H
         xaFGk8RZJmhZV1pCyBseq5PktOHSaq8+ZQ2ErCCGW8LkFS0QOL8elB5Iyh7mGrlqYgkH
         Y7eIzYMzxNa23PuCpEtm9y08Q9J3c+80eyGdNJWXKD2qwj3vO3H5V2E08rbJXrQYgZjR
         QM4EKk4OlmmJ+Wavr/rJ/ER+VpO1DT+vrCO65UbOzUOqbJ4r4vXNAaD62ZEsqEWPa2WQ
         XRzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAub/gkNzbtlN0ELmmqm9BImpzxyswogF84mzzlw5ojLKwvPfn8oB
	7cplfEKEbE5xxLFqWoZeGOgVcwRs9IkX57Ih1vzwL/pOssmMNMAcYczuWcFZC2NqUZXWjAWgYxI
	gkMXecUeU2eOIg/gHp9jSNOQaP2Rcc36isRFHcyPgMeVaNtqB9eLlgSZRvf/pnm4nPw==
X-Received: by 2002:a1f:9b8b:: with SMTP id d133mr4122249vke.59.1549456113503;
        Wed, 06 Feb 2019 04:28:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZGaGoJVtRY22+pPsZZijOZ0wuuBl+EngzZYXPFyByvocpfhRsmhKrxY6uwzFABiRj51KjU
X-Received: by 2002:a1f:9b8b:: with SMTP id d133mr4122225vke.59.1549456112555;
        Wed, 06 Feb 2019 04:28:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549456112; cv=none;
        d=google.com; s=arc-20160816;
        b=I5UxsCZDnsuBJ8/uTOVUwVHJBMxAXPlNcKGRVXCjVC/g90G8tUIKe9kF5oTEMuLK9L
         i9PVeRgWItSgzdHwx5RxHRB1nWWk8sJMqmYyomlQVT4WW4E5lmq6uXhCkmnbCI3NxCu7
         Sq45byeFEveZjl6JmpH/u4cPOl2NIawlc0FF7Icsnrb1STs65ZHi63q0WaDcHw/LB5/u
         01fj9y2jGX5nCa7IoFWwdDpgG06C9SQxBkNrMzJ/T7cDkxuRVpTTvvD1Pgr44Gnw2RHo
         CZ3c9AJBIzdjTS6eNHuxiaZH5Z83iuINPsO2h+z+WbgnuXeQ+wm6VEFcXvRrGMQBoC+H
         ZHKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=fqKOmSzTo3ociiwy537HhxKc6e9NkW/a8Gqn0RlL0L0=;
        b=tfusRb7iX598R0XxHOTz6IrayxWzMYSE822xNTFEDMaGiGNRsSkfAb54jDc/lrCnjS
         9bp2JQ+I22V58PGbRVehM8PPFQ85N374P6xiMDyFfpk6yxYqj5geN6vX6LNOuqszzD0k
         NReijNdgEKULdbXEM6DRC+IOC+iL/nG1w0PEd3Zeh9OHMZfOwpya+ux9oZRlFvGXG8Gz
         8xx147NDCBQfmi0FF4Bnd1Wp2OgJh4FJJjoTKH+BObMUNUQwkhWz0c1OWQq4oUX3gC5h
         ALHbwPZYDl84J2JFLxtbsTAHhvH4UDq8XVn/MJ5AiWS6JJ0H0bUbSVkqopsF5vbJJGD5
         Qftg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id 1si1077621vsz.211.2019.02.06.04.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:28:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 5097475ACFCE20AB5B4F;
	Wed,  6 Feb 2019 20:28:27 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 20:28:24 +0800
Date: Wed, 6 Feb 2019 12:28:14 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 03/10] acpi/hmat: Parse and report heterogeneous
 memory
Message-ID: <20190206122814.00000127@huawei.com>
In-Reply-To: <20190124230724.10022-4-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-4-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jan 2019 16:07:17 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Systems may provide different memory types and export this information
> in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> tables provided by the platform and report the memory access and caching
> attributes to the kernel messages.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
Minor comments inline.

One question for reviewers in general. Should this be a lot 'louder' on
failures.

I'd really like the kernel to moan a lot on all occasions if we start getting
bad HMAT tables out there.  This feels to me too silent by default!

Jonathan
> ---
>  drivers/acpi/Kconfig       |   1 +
>  drivers/acpi/Makefile      |   1 +
>  drivers/acpi/hmat/Kconfig  |   8 ++
>  drivers/acpi/hmat/Makefile |   1 +
>  drivers/acpi/hmat/hmat.c   | 181 +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 192 insertions(+)
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/hmat.c
> 
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index 90ff0a47c12e..b377f970adfd 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -465,6 +465,7 @@ config ACPI_REDUCED_HARDWARE_ONLY
>  	  If you are unsure what to do, do not enable this option.
>  
>  source "drivers/acpi/nfit/Kconfig"
> +source "drivers/acpi/hmat/Kconfig"
>  
>  source "drivers/acpi/apei/Kconfig"
>  source "drivers/acpi/dptf/Kconfig"
> diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
> index bb857421c2e8..5d361e4e3405 100644
> --- a/drivers/acpi/Makefile
> +++ b/drivers/acpi/Makefile
> @@ -80,6 +80,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
>  obj-$(CONFIG_ACPI)		+= container.o
>  obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
>  obj-$(CONFIG_ACPI_NFIT)		+= nfit/
> +obj-$(CONFIG_ACPI_HMAT)		+= hmat/
>  obj-$(CONFIG_ACPI)		+= acpi_memhotplug.o
>  obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
>  obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> new file mode 100644
> index 000000000000..c9637e2e7514
> --- /dev/null
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -0,0 +1,8 @@
> +# SPDX-License-Identifier: GPL-2.0
> +config ACPI_HMAT
> +	bool "ACPI Heterogeneous Memory Attribute Table Support"
> +	depends on ACPI_NUMA
> +	help
> +	 If set, this option causes the kernel to set the memory NUMA node
> +	 relationships and access attributes in accordance with ACPI HMAT
> +	 (Heterogeneous Memory Attributes Table).
> diff --git a/drivers/acpi/hmat/Makefile b/drivers/acpi/hmat/Makefile
> new file mode 100644
> index 000000000000..e909051d3d00
> --- /dev/null
> +++ b/drivers/acpi/hmat/Makefile
> @@ -0,0 +1 @@
> +obj-$(CONFIG_ACPI_HMAT) := hmat.o
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> new file mode 100644
> index 000000000000..1741bf30d87f
> --- /dev/null
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -0,0 +1,181 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Copyright (c) 2019, Intel Corporation.
> + *
> + * Heterogeneous Memory Attributes Table (HMAT) representation
> + *
> + * This program parses and reports the platform's HMAT tables, and registers
> + * the applicable attributes with the node's interfaces.
> + */
> +
> +#include <linux/acpi.h>
> +#include <linux/bitops.h>
> +#include <linux/device.h>
> +#include <linux/init.h>
> +#include <linux/list.h>
> +#include <linux/node.h>
> +#include <linux/sysfs.h>
> +
> +static __init const char *hmat_data_type(u8 type)
> +{
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +		return "Access Latency";
> +	case ACPI_HMAT_READ_LATENCY:
> +		return "Read Latency";
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		return "Write Latency";
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +		return "Access Bandwidth";
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +		return "Read Bandwidth";
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		return "Write Bandwidth";
> +	default:
> +		return "Reserved";
> +	};
> +}
> +
> +static __init const char *hmat_data_type_suffix(u8 type)
> +{
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +	case ACPI_HMAT_READ_LATENCY:
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		return " nsec";
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		return " MB/s";
> +	default:
> +		return "";
> +	};
> +}
> +
> +static __init int hmat_parse_locality(union acpi_subtable_headers *header,
> +				      const unsigned long end)
> +{
> +	struct acpi_hmat_locality *hmat_loc = (void *)header;
> +	unsigned int init, targ, total_size, ipds, tpds;
> +	u32 *inits, *targs, value;
> +	u16 *entries;
> +	u8 type;
> +
> +	if (hmat_loc->header.length < sizeof(*hmat_loc)) {
> +		pr_debug("HMAT: Unexpected locality header length: %d\n",
> +			 hmat_loc->header.length);
> +		return -EINVAL;
> +	}
> +
> +	type = hmat_loc->data_type;
> +	ipds = hmat_loc->number_of_initiator_Pds;
> +	tpds = hmat_loc->number_of_target_Pds;
> +	total_size = sizeof(*hmat_loc) + sizeof(*entries) * ipds * tpds +
> +		     sizeof(*inits) * ipds + sizeof(*targs) * tpds;
> +	if (hmat_loc->header.length < total_size) {
> +		pr_debug("HMAT: Unexpected locality header length:%d, minimum required:%d\n",
> +			 hmat_loc->header.length, total_size);
> +		return -EINVAL;
> +	}
> +
> +	pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
> +		hmat_loc->flags, hmat_data_type(type), ipds, tpds,
> +		hmat_loc->entry_base_unit);
> +
> +	inits = (u32 *)(hmat_loc + 1);
> +	targs = &inits[ipds];
This line is a bit of an oddity as it's indexing off the end of the data.
	targs = inits + ipds;
would be nicer to my mind as doesn't even hint that we are in inits still.


> +	entries = (u16 *)(&targs[tpds]);

As above I'd prefer we did the pointer arithmetic explicitly rather
than used an index off the end of the array.

> +	for (init = 0; init < ipds; init++) {
> +		for (targ = 0; targ < tpds; targ++) {
> +			value = entries[init * tpds + targ];
> +			value = (value * hmat_loc->entry_base_unit) / 10;
> +			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
> +				inits[init], targs[targ], value,
> +				hmat_data_type_suffix(type));

Worth checking at this early stage that the domains exist in SRAT?
+ screaming if they don't.
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static __init int hmat_parse_cache(union acpi_subtable_headers *header,
> +				   const unsigned long end)
> +{
> +	struct acpi_hmat_cache *cache = (void *)header;
> +	u32 attrs;
> +
> +	if (cache->header.length < sizeof(*cache)) {
> +		pr_debug("HMAT: Unexpected cache header length: %d\n",
> +			 cache->header.length);
> +		return -EINVAL;
> +	}
> +
> +	attrs = cache->cache_attributes;
> +	pr_info("HMAT: Cache: Domain:%d Size:%llu Attrs:%08x SMBIOS Handles:%d\n",
> +		cache->memory_PD, cache->cache_size, attrs,
> +		cache->number_of_SMBIOShandles);

Can we sanity check those smbios handles actually match anything?

> +
> +	return 0;
> +}
> +
> +static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
> +					   const unsigned long end)
> +{
> +	struct acpi_hmat_address_range *spa = (void *)header;
> +
> +	if (spa->header.length != sizeof(*spa)) {
> +		pr_debug("HMAT: Unexpected address range header length: %d\n",
> +			 spa->header.length);

My gut feeling is that it's much more useful to make this always print rather
than debug.  Same with other error paths above.  Given the number of times
broken ACPI tables show up, it's nice to complain really loudly!

Perhaps others prefer to not do so though so I'll defer to subsystem norms.

> +		return -EINVAL;
> +	}
> +	pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
> +		spa->physical_address_base, spa->physical_address_length,
> +		spa->flags, spa->processor_PD, spa->memory_PD);
> +
> +	return 0;
> +}
> +
> +static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
> +				      const unsigned long end)
> +{
> +	struct acpi_hmat_structure *hdr = (void *)header;
> +
> +	if (!hdr)
> +		return -EINVAL;
> +
> +	switch (hdr->type) {
> +	case ACPI_HMAT_TYPE_ADDRESS_RANGE:
> +		return hmat_parse_address_range(header, end);
> +	case ACPI_HMAT_TYPE_LOCALITY:
> +		return hmat_parse_locality(header, end);
> +	case ACPI_HMAT_TYPE_CACHE:
> +		return hmat_parse_cache(header, end);
> +	default:
> +		return -EINVAL;
> +	}
> +}
> +
> +static __init int hmat_init(void)
> +{
> +	struct acpi_table_header *tbl;
> +	enum acpi_hmat_type i;
> +	acpi_status status;
> +
> +	if (srat_disabled())
> +		return 0;
> +
> +	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
> +	if (ACPI_FAILURE(status))
> +		return 0;
> +
> +	for (i = ACPI_HMAT_TYPE_ADDRESS_RANGE; i < ACPI_HMAT_TYPE_RESERVED; i++) {
> +		if (acpi_table_parse_entries(ACPI_SIG_HMAT,
> +					     sizeof(struct acpi_table_hmat), i,
> +					     hmat_parse_subtable, 0) < 0)
> +			goto out_put;
> +	}
> +out_put:
> +	acpi_put_table(tbl);
> +	return 0;
> +}
> +subsys_initcall(hmat_init);


