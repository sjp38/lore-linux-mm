Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81450C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 386F020851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:01:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 386F020851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C07608E0003; Thu, 17 Jan 2019 06:01:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB7268E0002; Thu, 17 Jan 2019 06:01:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA5508E0003; Thu, 17 Jan 2019 06:01:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0758E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:01:06 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id m52so4766961otc.13
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:01:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=gIA+Ukehi0waRescaoYbJ1AUOp6HQMBv7yTnbtoQPHs=;
        b=KXLLpoEQP9OFime9tsC79zjY6XhDcFLO2DumzHNXQBrEWjfWXX3w8hFOawBZIVPHPP
         gplZbE3TVu4aDJVoLqcNKMxYZ2/SBnPeitDmuHbTLd+sp/LQ002VUugNdqbT61ToUmzV
         G1LNt+TsRtB080q/+FAlKAc+x10D+OiI6b/YWd7gPiTA1hPopmUHDKVGhBhHOQc0EVjk
         wStYt/dgy2k/9KG4Kl3fnUKCSGY4komoH3BzLbxtVZtGUJM0GtvuKJCO54ajwnyaVszM
         Ro9byCNo+VEM/gx3N/4rRpa3g9MWdjZDnuxLPgCu0ksDdWstpElnVGWKP1DE6V+kl2tk
         IvSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdjad5f7HRdZMXDYNW4inEK55RVljkNpD/kAww1p3h8l5O5Kev1
	DiRL0HOpGUp7e1lsox8V5bbYmp8z0V4DQDXQHkWwODsLmOhDfXvrY5Lzdy2jQu/yF6IrEv3b2yU
	WKBjhc8VXycwv+yiLNOXl2H1+YPG/EtQChBYqiEzlrDntGiIpUZmRFuxxqEqD6IkEO1jljGFlLa
	6ziB47F8I90U6YPa9EKN/Z4oxbI0FmLXogy/J5pPqNoMX8NKqbwDXvNILBlf/VL86KtUzWrmw5Y
	rRRohI+93CFjAsn+RwpLzycQzMGvkI0BbfnE7k9nlUNevpg6oN1anC8TD8tauug6U5LQsHYtB7t
	EUNwcXiXJJ02YmdtEN5zQvlthwHsQtQMVO8fq0Q1jAa2Xx4W837D3dU+6WWDWvbcmfFPzP5VLQ=
	=
X-Received: by 2002:a9d:3d42:: with SMTP id a60mr8247347otc.285.1547722866246;
        Thu, 17 Jan 2019 03:01:06 -0800 (PST)
X-Received: by 2002:a9d:3d42:: with SMTP id a60mr8247295otc.285.1547722865275;
        Thu, 17 Jan 2019 03:01:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547722865; cv=none;
        d=google.com; s=arc-20160816;
        b=PDtg+hans0lGOWAon+cZuNeQpg/dG1zYL9hCaEjhvDnRavFi22I1vFe2th4ycKaNNj
         6Rh3DpSHtTV7YH7M0UKK3ybnRbNV4POA10K0yVksOrEYAokuRan4gFcpF2IfilZmaWZr
         sI2j4WX4Y1+OFhD4+YsDFdruJRzDrMdqH+3BB17wPPtqMgTbmDWc4OyZTROUfhSE+99G
         EaMvMOaOzjgzmb40RyoJikFK6r83n+TymU5wgZGroJb4Wi/lZa5wSSMxm84xB0p5V286
         Y0wTYj/APU7ssaezYtEfbQwbHPKh2XG+iWz/lYc+4SKhMkeKQYCjiVT6XEqck7/skrBQ
         so4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=gIA+Ukehi0waRescaoYbJ1AUOp6HQMBv7yTnbtoQPHs=;
        b=M2i6mWDPqMwX9ZQ3Qq8YT2uC0yprREcebUXtgtV7N6zWrZ6n0J8JCSqgbUj/XMf173
         BbKYp+5EfbYUicZZvoIh6VeJoejSQD9Ym6cvyIqmHClgP/w3/aeJd/PLy4kPNrNXMYv3
         ArnHpFNqMrl45S42OKNijlGeDPMr2vTwOVUyZYnaPCwdrBROLzAHAU45qGhHagqP96PC
         wLgZ0P7xO8W5msn87GAGhmwHfa4rBcuzey2luJHHAt2YDt850A+4l/fF3CCEH1zP65cv
         usiDQbxTi+DHXFn8l7AKmjnOeehypN6HUhHU/eOcxuseSJjl6Tzzn8GXKF3bSFhRsLga
         0YsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i62sor588163oia.56.2019.01.17.03.01.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 03:01:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7OZT03eKoLNgehBIyi9rWPmEOfBIDWwLN6Ndl9ybgkk9BCn+XDCsztOR5+yAY0s0c8GttNhsJMxR1y+ev59nU=
X-Received: by 2002:a54:4d01:: with SMTP id v1mr132879oix.246.1547722864498;
 Thu, 17 Jan 2019 03:01:04 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-4-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-4-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 12:00:53 +0100
Message-ID:
 <CAJZ5v0hEg3V7FoE6arwTTodVQ4uUZNLpwdOpjzh7PjqB3jguGw@mail.gmail.com>
Subject: Re: [PATCHv4 03/13] acpi/hmat: Parse and report heterogeneous memory
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
Message-ID: <20190117110053.LZPFDHm7A3RNxWvFo_sNiQZpl1XiPKp6n9IkZG1vakU@z>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Systems may provide different memory types and export this information
> in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> tables provided by the platform and report the memory access and caching
> attributes.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/Kconfig       |   1 +
>  drivers/acpi/Makefile      |   1 +
>  drivers/acpi/hmat/Kconfig  |   8 ++
>  drivers/acpi/hmat/Makefile |   1 +
>  drivers/acpi/hmat/hmat.c   | 180 +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 191 insertions(+)
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
> index 7c6afc111d76..bff8fbe5a6ab 100644
> --- a/drivers/acpi/Makefile
> +++ b/drivers/acpi/Makefile
> @@ -79,6 +79,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)  += processor.o
>  obj-$(CONFIG_ACPI)             += container.o
>  obj-$(CONFIG_ACPI_THERMAL)     += thermal.o
>  obj-$(CONFIG_ACPI_NFIT)                += nfit/
> +obj-$(CONFIG_ACPI_HMAT)                += hmat/

Yes, I prefer it to go into a separate directory.

Who do you want to maintain it, me or Dan?

>  obj-$(CONFIG_ACPI)             += acpi_memhotplug.o
>  obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
>  obj-$(CONFIG_ACPI_BATTERY)     += battery.o
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> new file mode 100644
> index 000000000000..a4034d37a311
> --- /dev/null
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -0,0 +1,8 @@
> +# SPDX-License-Identifier: GPL-2.0
> +config ACPI_HMAT
> +       bool "ACPI Heterogeneous Memory Attribute Table Support"
> +       depends on ACPI_NUMA
> +       help
> +        Parses representation of the ACPI Heterogeneous Memory Attributes
> +        Table (HMAT) and set the memory node relationships and access
> +        attributes.

What about:

"If set, this option causes the kernel to set the memory NUMA node
relationships and access attributes in accordance with ACPI HMAT
(Heterogeneous Memory Attributes Table)."

> diff --git a/drivers/acpi/hmat/Makefile b/drivers/acpi/hmat/Makefile
> new file mode 100644
> index 000000000000..e909051d3d00
> --- /dev/null
> +++ b/drivers/acpi/hmat/Makefile
> @@ -0,0 +1 @@
> +obj-$(CONFIG_ACPI_HMAT) := hmat.o
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> new file mode 100644
> index 000000000000..833a783868d5
> --- /dev/null
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -0,0 +1,180 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Heterogeneous Memory Attributes Table (HMAT) representation
> + *
> + * Copyright (c) 2018, Intel Corporation.

Can you put a comment describing the code somewhat in here?

> + */
> +
> +#include <acpi/acpi_numa.h>
> +#include <linux/acpi.h>
> +#include <linux/bitops.h>
> +#include <linux/cpu.h>
> +#include <linux/device.h>
> +#include <linux/init.h>
> +#include <linux/list.h>
> +#include <linux/module.h>
> +#include <linux/node.h>
> +#include <linux/slab.h>
> +#include <linux/sysfs.h>

Are all of the headers above really necessary to build the code?

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
> +       struct acpi_hmat_locality *loc = (void *)header;
> +       unsigned int init, targ, total_size, ipds, tpds;
> +       u32 *inits, *targs, value;
> +       u16 *entries;
> +       u8 type;
> +
> +       if (loc->header.length < sizeof(*loc)) {
> +               pr_err("HMAT: Unexpected locality header length: %d\n",
> +                       loc->header.length);

Why pr_err()?  Is the error really high-prio?

Same below.

> +               return -EINVAL;
> +       }
> +
> +       type = loc->data_type;
> +       ipds = loc->number_of_initiator_Pds;
> +       tpds = loc->number_of_target_Pds;
> +       total_size = sizeof(*loc) + sizeof(*entries) * ipds * tpds +
> +                    sizeof(*inits) * ipds + sizeof(*targs) * tpds;
> +       if (loc->header.length < total_size) {
> +               pr_err("HMAT: Unexpected locality header length:%d, minimum required:%d\n",
> +                       loc->header.length, total_size);
> +               return -EINVAL;
> +       }
> +
> +       pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
> +               loc->flags, hmat_data_type(type), ipds, tpds,
> +               loc->entry_base_unit);
> +
> +       inits = (u32 *)(loc + 1);
> +       targs = &inits[ipds];
> +       entries = (u16 *)(&targs[tpds]);
> +       for (targ = 0; targ < tpds; targ++) {
> +               for (init = 0; init < ipds; init++) {
> +                       value = entries[init * tpds + targ];
> +                       value = (value * loc->entry_base_unit) / 10;
> +                       pr_info("  Initiator-Target[%d-%d]:%d%s\n",
> +                               inits[init], targs[targ], value,
> +                               hmat_data_type_suffix(type));
> +               }
> +       }
> +       return 0;
> +}

The format and meaning of what is printed into the log should be
documented somewhere IMO.

Of course, that applies to the functions below as well.

> +
> +static __init int hmat_parse_cache(union acpi_subtable_headers *header,
> +                                  const unsigned long end)
> +{
> +       struct acpi_hmat_cache *cache = (void *)header;
> +       u32 attrs;
> +
> +       if (cache->header.length < sizeof(*cache)) {
> +               pr_err("HMAT: Unexpected cache header length: %d\n",
> +                       cache->header.length);
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
> +               pr_err("HMAT: Unexpected address range header length: %d\n",
> +                       spa->header.length);
> +               return -EINVAL;
> +       }
> +       pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
> +               spa->physical_address_base, spa->physical_address_length,
> +               spa->flags, spa->processor_PD, spa->memory_PD);
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

It looks like this particular patch only causes some extra messages to
be printed into the log, no attributes setting etc yet.

I would like the changelog to mention that.

