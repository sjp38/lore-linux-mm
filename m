Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B85266B1A12
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:58:25 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id h135-v6so16901441oic.2
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 01:58:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t26sor21756173ote.58.2018.11.19.01.58.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 01:58:24 -0800 (PST)
MIME-Version: 1.0
References: <20181114224921.12123-2-keith.busch@intel.com> <20181114224921.12123-7-keith.busch@intel.com>
In-Reply-To: <20181114224921.12123-7-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 19 Nov 2018 10:58:12 +0100
Message-ID: <CAJZ5v0gQCpmRHdSS=xxLSx-+1xbexSFQb_ZxMvZuKUjk6+w5ww@mail.gmail.com>
Subject: Re: [PATCH 6/7] acpi: Create subtable parsing infrastructure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Nov 14, 2018 at 11:53 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Parsing entries in an ACPI table had assumed a generic header structure
> that is most common. There is no standard ACPI header, though, so less
> common types would need custom parsers if they want go walk their
> subtable entry list.
>
> Create the infrastructure for adding different table types so parsing
> the entries array may be more reused for all ACPI system tables.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/tables.c | 75 ++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 65 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> index 61203eebf3a1..15ee77780f68 100644
> --- a/drivers/acpi/tables.c
> +++ b/drivers/acpi/tables.c
> @@ -49,6 +49,19 @@ static struct acpi_table_desc initial_tables[ACPI_MAX_TABLES] __initdata;
>
>  static int acpi_apic_instance __initdata;
>
> +enum acpi_subtable_type {
> +       ACPI_SUBTABLE_COMMON,
> +};
> +
> +union acpi_subtable_headers {
> +       struct acpi_subtable_header common;
> +};
> +
> +struct acpi_subtable_entry {
> +       union acpi_subtable_headers *hdr;
> +       enum acpi_subtable_type type;
> +};
> +
>  /*
>   * Disable table checksum verification for the early stage due to the size
>   * limitation of the current x86 early mapping implementation.
> @@ -217,6 +230,45 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
>         }
>  }
>
> +static unsigned long __init
> +acpi_get_entry_type(struct acpi_subtable_entry *entry)
> +{
> +       switch (entry->type) {
> +       case ACPI_SUBTABLE_COMMON:
> +               return entry->hdr->common.type;
> +       }
> +       WARN_ONCE(1, "invalid acpi type\n");
> +       return 0;
> +}
> +
> +static unsigned long __init
> +acpi_get_entry_length(struct acpi_subtable_entry *entry)
> +{
> +       switch (entry->type) {
> +       case ACPI_SUBTABLE_COMMON:
> +               return entry->hdr->common.length;
> +       }
> +       WARN_ONCE(1, "invalid acpi type\n");

AFAICS this does a WARN_ONCE() on information obtained from firmware.

That is not a kernel problem, so generating traces in that case is not
a good idea IMO.  Moreover, users can't really do much about this in
the majority of cases, so a pr_info() message should be sufficient.

And similarly below.
