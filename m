Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5326A8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:03:53 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id w128so7421650oie.20
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 22:03:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i17sor7194797otp.65.2018.12.10.22.03.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 22:03:52 -0800 (PST)
MIME-Version: 1.0
References: <20181211010310.8551-1-keith.busch@intel.com> <20181211010310.8551-3-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-3-keith.busch@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 10 Dec 2018 22:03:40 -0800
Message-ID: <CAPcyv4gEpxigPqc0PgDE0YCL3Ot+wPfvChAZqUTtdYR2WDxaJg@mail.gmail.com>
Subject: Re: [PATCHv2 02/12] acpi/hmat: Parse and report heterogeneous memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Mon, Dec 10, 2018 at 5:05 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Systems may provide different memory types and export this information
> in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> tables provided by the platform and report the memory access and caching
> attributes.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/Kconfig  |   8 +++
>  drivers/acpi/Makefile |   1 +
>  drivers/acpi/hmat.c   | 192 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/acpi/tables.c |   9 +++
>  include/linux/acpi.h  |   1 +
>  5 files changed, 211 insertions(+)
>  create mode 100644 drivers/acpi/hmat.c
>
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index 7cea769c37df..9a05af3a18cf 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -327,6 +327,14 @@ config ACPI_NUMA
>         depends on (X86 || IA64 || ARM64)
>         default y if IA64_GENERIC || IA64_SGI_SN2 || ARM64
>
> +config ACPI_HMAT
> +       bool "ACPI Heterogeneous Memory Attribute Table Support"
> +       depends on ACPI_NUMA
> +       help
> +        Parses representation of the ACPI Heterogeneous Memory Attributes
> +        Table (HMAT) and set the memory node relationships and access
> +        attributes.
> +
>  config ACPI_CUSTOM_DSDT_FILE
>         string "Custom DSDT Table file to include"
>         default ""
> diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
> index edc039313cd6..b5e13499f88b 100644
> --- a/drivers/acpi/Makefile
> +++ b/drivers/acpi/Makefile
> @@ -55,6 +55,7 @@ acpi-$(CONFIG_X86)            += x86/apple.o
>  acpi-$(CONFIG_X86)             += x86/utils.o
>  acpi-$(CONFIG_DEBUG_FS)                += debugfs.o
>  acpi-$(CONFIG_ACPI_NUMA)       += numa.o
> +acpi-$(CONFIG_ACPI_HMAT)       += hmat.o
>  acpi-$(CONFIG_ACPI_PROCFS_POWER) += cm_sbs.o
>  acpi-y                         += acpi_lpat.o
>  acpi-$(CONFIG_ACPI_LPIT)       += acpi_lpit.o
> diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
> new file mode 100644
> index 000000000000..ef3881f0f370
> --- /dev/null
> +++ b/drivers/acpi/hmat.c
[..]
> +static __init int hmat_init(void)
> +{
> +       struct acpi_subtable_proc subtable_proc;
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
> +       if (acpi_table_parse(ACPI_SIG_HMAT, parse_noop))
> +               goto out_put;
> +
> +       memset(&subtable_proc, 0, sizeof(subtable_proc));
> +       subtable_proc.handler = hmat_parse_subtable;
> +       for (i = ACPI_HMAT_TYPE_ADDRESS_RANGE; i < ACPI_HMAT_TYPE_RESERVED; i++) {
> +               subtable_proc.id = i;
> +               if (acpi_table_parse_entries_array(ACPI_SIG_HMAT,
> +                                       sizeof(struct acpi_table_hmat),
> +                                       &subtable_proc, 1, 0) < 0)
> +                       goto out_put;
> +       }
> + out_put:
> +       acpi_put_table(tbl);
> +       return 0;
> +}
> +subsys_initcall(hmat_init);

I have a use case to detect the presence of a memory-side-cache early
at init time [1]. To me this means that hmat_init() needs to happen as
a part of acpi_numa_init(). Subsequently I think that also means that
the sysfs portion needs to be broken out to its own init path that can
probably run at module_init() priority.

Perhaps we should split this patch set into two? The table parsing
with an in-kernel user is a bit easier to reason about and can go in
first. Towards that end can I steal / refllow patches 1 & 2 into the
memory randomization series? Other ideas how to handle this?

[1]: https://lkml.org/lkml/2018/10/12/309
