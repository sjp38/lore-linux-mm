Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 794446B027B
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:38:24 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so4026900oib.4
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:38:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20-v6sor6791125oic.223.2018.07.06.12.38.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 12:38:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180706082911.13405-2-aneesh.kumar@linux.ibm.com>
References: <20180706082911.13405-1-aneesh.kumar@linux.ibm.com> <20180706082911.13405-2-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Jul 2018 12:38:22 -0700
Message-ID: <CAPcyv4gjrsswcakSog7jxT+agH7NrBEvwxe9jT0ycU3RZV5sWA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm/pmem: Add memblock based e820 platform driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oliver <oohall@gmail.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jul 6, 2018 at 1:29 AM, Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
> This patch steal system RAM and use that to emulate pmem device using the
> e820 platform driver.
>
> This adds a new kernel command line 'pmemmap' which takes the format <size[KMG]>
> to allocate memory early in the boot. This memory is later registered as
> persistent memory range.
>
> Based on original patch from Oliver OHalloran <oliveroh@au1.ibm.com>
>
> Not-Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/Kconfig        |  13 ++++
>  drivers/nvdimm/Makefile       |   1 +
>  drivers/nvdimm/memblockpmem.c | 115 ++++++++++++++++++++++++++++++++++
>  3 files changed, 129 insertions(+)
>  create mode 100644 drivers/nvdimm/memblockpmem.c
>
[..]
> +/*
> + * pmemmap=ss[KMG]
> + *
> + * This is similar to the memremap=offset[KMG]!size[KMG] paramater
> + * for adding a legacy pmem range to the e820 map on x86, but it's
> + * platform agnostic.

The current memmap=ss!nn option is a non-stop source of bugs and
fragility. The fact that this lets the kernel specify the base address
helps, but then this is purely just a debug facility because
memmap=ss!nn is there to cover platform firmware implementations that
fail to mark a given address range as persistent.

If this is just for debug, why not use qemu? If this is not for debug
what are these systems that don't have proper firmware support?
