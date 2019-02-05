Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E81D1C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:12:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A06D020821
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:12:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A06D020821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D8C28E0085; Tue,  5 Feb 2019 07:12:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 385518E0083; Tue,  5 Feb 2019 07:12:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2291F8E0085; Tue,  5 Feb 2019 07:12:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id E17D08E0083
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 07:12:23 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id r24so2735588otk.7
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 04:12:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=TqwDRd3S+vQTQKMSBao5/XjRBpR/yrOFiU9e8EKfsRU=;
        b=TFwL6Mu1Cfp5oOAakjfLIXKEr2C9vE1+VBNq3PmumS71YnyMCStA62X9l9k4c57EOg
         K+RJ52tF7UrM5zJKKGHGmO73u1UZ1mhewwbDOla0DeDCNjJrS1zzNaB92YLdIryKBXDm
         +ec/XBqa2b2OKBwZO5tvmZZYVGzDOAXAVUxz23hZu/1XVEIwSHRcvaBRXKudna4fyr57
         e43x0UHavfhz0HYLGdsMErmElNTZGRYOujbn2hFgU74CPfwwc0Z0cjYcVjw5grT6/ola
         MLHYOAAcCkpAzccCj9ul+XKLH/p6KCzKwRFctxzH5cfP/shL6hp8fHzLyTDEguEoghNg
         vWmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaBdyILBSQFcqBxtObB7hmWH64wenBIvmUh7i9WH2Rg6pkxBrl3
	OgFntEg53+2/5TkjAgvwqSSNTlqH7HKgDPA8iTsiVm7lUPT9K6fgT5NO8o7BDVDrtcpov767Pu7
	KZ2EKD70dlrSV+82rV8L9D0Hg4YdYGunKH28W46AFJD9SuMGwj6BY0X/J9wFHDBtyYXvF4ddiYD
	TjMXoJnY5pPk+rL/hOUPHA4vsMu8IlssskJTX7Yzv5V23LSktP+Vv/u804rBmiBtasNYBxA6ZY3
	o7DNZsFlduPnKcY+i1kLeh1b69Cm6EIxP0MdOuNfnjFNoOgmzOLMd5bIsjvF4fhXNrrK95e7V9r
	gxeBlKDA1nL88sYR+KTFLqIXn+FzekR4JU7dEktYwWknw10nybA22JJf/SaS94iiYyTUQnXCuQ=
	=
X-Received: by 2002:a9d:1ee2:: with SMTP id n89mr2504140otn.262.1549368743536;
        Tue, 05 Feb 2019 04:12:23 -0800 (PST)
X-Received: by 2002:a9d:1ee2:: with SMTP id n89mr2504068otn.262.1549368741997;
        Tue, 05 Feb 2019 04:12:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549368741; cv=none;
        d=google.com; s=arc-20160816;
        b=za3eX6NbObmiq6ToNcS0mOF9vtHFmNmmu/vUxDnIUxNpX+z3KSbN53hCHL9pFWzhfc
         kLtrwy8MUy0Vsk8gil4R6Je1nUXjrKwrPUypBAtQoP8aEjcaB05g/ZbbtjDp4CT80UTo
         3/pdFJCXz3szYfAq6uC0Ele3ivQew14KRvMmwHihjDspcBly/GDCmPh76X3gXZSWL/j4
         yUe1dZ9UIAHRGqq/tST9CX4V24Wpw+2U7/VtT+hNcw6HfD7gve6xKajlBo/BQ2YSJZMe
         rTlACGc7/U7Zx/Sz/OfQhtzG2ewGuL/zL6DrVROGyLjze7SkoCybuCZ2n9KsQKrVp9pO
         mmjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=TqwDRd3S+vQTQKMSBao5/XjRBpR/yrOFiU9e8EKfsRU=;
        b=aJHpzgS+8+EvtTc02lVD8LISCy+GME2Ne78LHYA51kmK4JlokUSyiZ5ksjTdUSfc6i
         Aj8dz7pVMJwSjBBiPIEulaZ2UfvJ+9QA8yqMAV7AdD+mGMqNNHKyA2RP9EnFhOpNtuAu
         Q+cJrVn8zkdjwfRV2gM1bvmjxRqQ9BQRetOObf27EvqQo31kiIHbYLliV5NZY7rcdFD4
         rn29TztS7oawU6YCYKASqw+tzoH/zujFjL501elnxLVByoApVODV38OVhFYYyKcpYE+6
         UStwBtva9MTqStp2ro2C6N+Z599GXC2xqQQ62OIb3+FEGRvb3E+P+UWeRnLTpNoKt85z
         lnYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i20sor12260287otc.68.2019.02.05.04.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 04:12:21 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3Iaq6TfcWn6v8MYhvMCHHXi+TfZu0sx4kGro/cmBTrZhFpl8fBz9XcCWHaGxmVd6BUXxq2ufjsP+qVIUdLKGH0w=
X-Received: by 2002:a9d:588c:: with SMTP id x12mr2502594otg.139.1549368741499;
 Tue, 05 Feb 2019 04:12:21 -0800 (PST)
MIME-Version: 1.0
References: <20190124230724.10022-1-keith.busch@intel.com> <20190124230724.10022-4-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-4-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 5 Feb 2019 13:12:09 +0100
Message-ID: <CAJZ5v0iOESR+51j03FkqANKiNujQu-en8+D2L1F5LTJD0Owjuw@mail.gmail.com>
Subject: Re: [PATCHv5 03/10] acpi/hmat: Parse and report heterogeneous memory
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 25, 2019 at 12:08 AM Keith Busch <keith.busch@intel.com> wrote:
>
> Systems may provide different memory types and export this information
> in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> tables provided by the platform and report the memory access and caching
> attributes to the kernel messages.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

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
>           If you are unsure what to do, do not enable this option.
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
> @@ -80,6 +80,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)  += processor.o
>  obj-$(CONFIG_ACPI)             += container.o
>  obj-$(CONFIG_ACPI_THERMAL)     += thermal.o
>  obj-$(CONFIG_ACPI_NFIT)                += nfit/
> +obj-$(CONFIG_ACPI_HMAT)                += hmat/
>  obj-$(CONFIG_ACPI)             += acpi_memhotplug.o
>  obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
>  obj-$(CONFIG_ACPI_BATTERY)     += battery.o
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> new file mode 100644
> index 000000000000..c9637e2e7514
> --- /dev/null
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -0,0 +1,8 @@
> +# SPDX-License-Identifier: GPL-2.0
> +config ACPI_HMAT
> +       bool "ACPI Heterogeneous Memory Attribute Table Support"
> +       depends on ACPI_NUMA
> +       help
> +        If set, this option causes the kernel to set the memory NUMA node
> +        relationships and access attributes in accordance with ACPI HMAT
> +        (Heterogeneous Memory Attributes Table).
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
> +       switch (type) {
> +       case ACPI_HMAT_ACCESS_LATENCY:
> +               return "Access Latency";
> +       case ACPI_HMAT_READ_LATENCY:
> +               return "Read Latency";
> +       case ACPI_HMAT_WRITE_LATENCY:
> +               return "Write Latency";
> +       case ACPI_HMAT_ACCESS_BANDWIDTH:
> +               return "Access Bandwidth";
> +       case ACPI_HMAT_READ_BANDWIDTH:
> +               return "Read Bandwidth";
> +       case ACPI_HMAT_WRITE_BANDWIDTH:
> +               return "Write Bandwidth";
> +       default:
> +               return "Reserved";
> +       };
> +}
> +
> +static __init const char *hmat_data_type_suffix(u8 type)
> +{
> +       switch (type) {
> +       case ACPI_HMAT_ACCESS_LATENCY:
> +       case ACPI_HMAT_READ_LATENCY:
> +       case ACPI_HMAT_WRITE_LATENCY:
> +               return " nsec";
> +       case ACPI_HMAT_ACCESS_BANDWIDTH:
> +       case ACPI_HMAT_READ_BANDWIDTH:
> +       case ACPI_HMAT_WRITE_BANDWIDTH:
> +               return " MB/s";
> +       default:
> +               return "";
> +       };
> +}
> +
> +static __init int hmat_parse_locality(union acpi_subtable_headers *header,
> +                                     const unsigned long end)
> +{
> +       struct acpi_hmat_locality *hmat_loc = (void *)header;
> +       unsigned int init, targ, total_size, ipds, tpds;
> +       u32 *inits, *targs, value;
> +       u16 *entries;
> +       u8 type;
> +
> +       if (hmat_loc->header.length < sizeof(*hmat_loc)) {
> +               pr_debug("HMAT: Unexpected locality header length: %d\n",
> +                        hmat_loc->header.length);
> +               return -EINVAL;
> +       }
> +
> +       type = hmat_loc->data_type;
> +       ipds = hmat_loc->number_of_initiator_Pds;
> +       tpds = hmat_loc->number_of_target_Pds;
> +       total_size = sizeof(*hmat_loc) + sizeof(*entries) * ipds * tpds +
> +                    sizeof(*inits) * ipds + sizeof(*targs) * tpds;
> +       if (hmat_loc->header.length < total_size) {
> +               pr_debug("HMAT: Unexpected locality header length:%d, minimum required:%d\n",
> +                        hmat_loc->header.length, total_size);
> +               return -EINVAL;
> +       }
> +
> +       pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
> +               hmat_loc->flags, hmat_data_type(type), ipds, tpds,
> +               hmat_loc->entry_base_unit);
> +
> +       inits = (u32 *)(hmat_loc + 1);
> +       targs = &inits[ipds];
> +       entries = (u16 *)(&targs[tpds]);
> +       for (init = 0; init < ipds; init++) {
> +               for (targ = 0; targ < tpds; targ++) {
> +                       value = entries[init * tpds + targ];
> +                       value = (value * hmat_loc->entry_base_unit) / 10;
> +                       pr_info("  Initiator-Target[%d-%d]:%d%s\n",
> +                               inits[init], targs[targ], value,
> +                               hmat_data_type_suffix(type));
> +               }
> +       }
> +
> +       return 0;
> +}
> +
> +static __init int hmat_parse_cache(union acpi_subtable_headers *header,
> +                                  const unsigned long end)
> +{
> +       struct acpi_hmat_cache *cache = (void *)header;
> +       u32 attrs;
> +
> +       if (cache->header.length < sizeof(*cache)) {
> +               pr_debug("HMAT: Unexpected cache header length: %d\n",
> +                        cache->header.length);
> +               return -EINVAL;
> +       }
> +
> +       attrs = cache->cache_attributes;
> +       pr_info("HMAT: Cache: Domain:%d Size:%llu Attrs:%08x SMBIOS Handles:%d\n",
> +               cache->memory_PD, cache->cache_size, attrs,
> +               cache->number_of_SMBIOShandles);
> +
> +       return 0;
> +}
> +
> +static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
> +                                          const unsigned long end)
> +{
> +       struct acpi_hmat_address_range *spa = (void *)header;
> +
> +       if (spa->header.length != sizeof(*spa)) {
> +               pr_debug("HMAT: Unexpected address range header length: %d\n",
> +                        spa->header.length);
> +               return -EINVAL;
> +       }
> +       pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
> +               spa->physical_address_base, spa->physical_address_length,
> +               spa->flags, spa->processor_PD, spa->memory_PD);
> +
> +       return 0;
> +}
> +
> +static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
> +                                     const unsigned long end)
> +{
> +       struct acpi_hmat_structure *hdr = (void *)header;
> +
> +       if (!hdr)
> +               return -EINVAL;
> +
> +       switch (hdr->type) {
> +       case ACPI_HMAT_TYPE_ADDRESS_RANGE:
> +               return hmat_parse_address_range(header, end);
> +       case ACPI_HMAT_TYPE_LOCALITY:
> +               return hmat_parse_locality(header, end);
> +       case ACPI_HMAT_TYPE_CACHE:
> +               return hmat_parse_cache(header, end);
> +       default:
> +               return -EINVAL;
> +       }
> +}
> +
> +static __init int hmat_init(void)
> +{
> +       struct acpi_table_header *tbl;
> +       enum acpi_hmat_type i;
> +       acpi_status status;
> +
> +       if (srat_disabled())
> +               return 0;
> +
> +       status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
> +       if (ACPI_FAILURE(status))
> +               return 0;
> +
> +       for (i = ACPI_HMAT_TYPE_ADDRESS_RANGE; i < ACPI_HMAT_TYPE_RESERVED; i++) {
> +               if (acpi_table_parse_entries(ACPI_SIG_HMAT,
> +                                            sizeof(struct acpi_table_hmat), i,
> +                                            hmat_parse_subtable, 0) < 0)
> +                       goto out_put;
> +       }
> +out_put:
> +       acpi_put_table(tbl);
> +       return 0;
> +}
> +subsys_initcall(hmat_init);
> --
> 2.14.4
>

