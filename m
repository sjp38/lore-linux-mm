Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF2A8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:42:41 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id r131so3635405oia.7
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:42:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f14sor1273415oib.5.2019.01.17.09.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 09:42:40 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-13-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-13-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 18:42:28 +0100
Message-ID: <CAJZ5v0gu0zcyZtHv4mDioS6j4WMsz_59bYdzuGtOPXfKVNOX+g@mail.gmail.com>
Subject: Re: [PATCHv4 12/13] acpi/hmat: Register memory side cache attributes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Register memory side cache attributes with the memory's node if HMAT
> provides the side cache iniformation table.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 45e20dc677f9..9efdd0a63a79 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -206,6 +206,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>                                    const unsigned long end)
>  {
>         struct acpi_hmat_cache *cache = (void *)header;
> +       struct node_cache_attrs cache_attrs;
>         u32 attrs;
>
>         if (cache->header.length < sizeof(*cache)) {
> @@ -219,6 +220,37 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>                 cache->memory_PD, cache->cache_size, attrs,
>                 cache->number_of_SMBIOShandles);
>
> +       cache_attrs.size = cache->cache_size;
> +       cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
> +       cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
> +
> +       switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
> +       case ACPI_HMAT_CA_DIRECT_MAPPED:
> +               cache_attrs.associativity = NODE_CACHE_DIRECT_MAP;
> +               break;
> +       case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
> +               cache_attrs.associativity = NODE_CACHE_INDEXED;
> +               break;
> +       case ACPI_HMAT_CA_NONE:
> +       default:

This looks slightly odd as "default" covers the other case as well.
Maybe say what other case is covered by "default" in particular in a
comment?

> +               cache_attrs.associativity = NODE_CACHE_OTHER;
> +               break;
> +       }
> +
> +       switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
> +       case ACPI_HMAT_CP_WB:
> +               cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
> +               break;
> +       case ACPI_HMAT_CP_WT:
> +               cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
> +               break;
> +       case ACPI_HMAT_CP_NONE:
> +       default:

And analogously here.

> +               cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
> +               break;
> +       }
> +
> +       node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
>         return 0;
>  }
>
> --
