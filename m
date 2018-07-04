Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDCBA6B0275
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 10:50:19 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 61-v6so430793otj.11
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 07:50:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186-v6sor2469449oia.99.2018.07.04.07.50.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 07:50:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5c7996b8e6d31541f3185f8e4064ff97582c86f8.1530716899.git.yi.z.zhang@linux.intel.com>
References: <cover.1530716899.git.yi.z.zhang@linux.intel.com> <5c7996b8e6d31541f3185f8e4064ff97582c86f8.1530716899.git.yi.z.zhang@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Jul 2018 07:50:18 -0700
Message-ID: <CAPcyv4gjFVG7tHv65Z=FsZ9=5wXDxNWawFJqO8MkyMudch4zDw@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, "Zhang, Yi Z" <yi.z.zhang@intel.com>

On Wed, Jul 4, 2018 at 8:30 AM, Zhang Yi <yi.z.zhang@linux.intel.com> wrote:
> Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
> other reserved PFNs, pages on NVDIMM shall still behave like normal ones
> in many cases, i.e. when used as backend memory of KVM guest. This patch
> introduces a new memory type, MEMORY_DEVICE_DEV_DAX. Together with the
> existing type MEMORY_DEVICE_FS_DAX, we can differentiate the pages on
> NVDIMM with the normal reserved pages.
>
> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
> ---
>  drivers/dax/pmem.c       | 1 +
>  include/linux/memremap.h | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
> index fd49b24..fb3f363 100644
> --- a/drivers/dax/pmem.c
> +++ b/drivers/dax/pmem.c
> @@ -111,6 +111,7 @@ static int dax_pmem_probe(struct device *dev)
>                 return rc;
>
>         dax_pmem->pgmap.ref = &dax_pmem->ref;
> +       dax_pmem->pgmap.type = MEMORY_DEVICE_DEV_DAX;
>         addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
>         if (IS_ERR(addr))
>                 return PTR_ERR(addr);
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 5ebfff6..4127bf7 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -58,6 +58,7 @@ enum memory_type {
>         MEMORY_DEVICE_PRIVATE = 1,
>         MEMORY_DEVICE_PUBLIC,
>         MEMORY_DEVICE_FS_DAX,
> +       MEMORY_DEVICE_DEV_DAX,

Please add documentation for this new type to the comment block about
this definition.
