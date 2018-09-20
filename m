Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA5D8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 18:59:47 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id c46-v6so10186214otd.12
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 15:59:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f14-v6sor16988430oth.32.2018.09.20.15.59.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 15:59:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180920215824.19464.8884.stgit@localhost.localdomain> <20180920222951.19464.39241.stgit@localhost.localdomain>
In-Reply-To: <20180920222951.19464.39241.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Sep 2018 15:59:34 -0700
Message-ID: <CAPcyv4hAEOUOBU4GENaFOb-xXi33g_ugCexfmY3DrLH27Z6MKg@mail.gmail.com>
Subject: Re: [PATCH v4 5/5] nvdimm: Schedule device registration on node local
 to the device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Sep 20, 2018 at 3:31 PM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> This patch is meant to force the device registration for nvdimm devices to
> be closer to the actual device. This is achieved by using either the NUMA
> node ID of the region, or of the parent. By doing this we can have
> everything above the region based on the region, and everything below the
> region based on the nvdimm bus.
>
> One additional change I made is that we hold onto a reference to the parent
> while we are going through registration. By doing this we can guarantee we
> can complete the registration before we have the parent device removed.
>
> By guaranteeing NUMA locality I see an improvement of as high as 25% for
> per-node init of a system with 12TB of persistent memory.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  drivers/nvdimm/bus.c |   19 +++++++++++++++++--
>  1 file changed, 17 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
> index 8aae6dcc839f..ca935296d55e 100644
> --- a/drivers/nvdimm/bus.c
> +++ b/drivers/nvdimm/bus.c
> @@ -487,7 +487,9 @@ static void nd_async_device_register(void *d, async_cookie_t cookie)
>                 dev_err(dev, "%s: failed\n", __func__);
>                 put_device(dev);
>         }
> +
>         put_device(dev);
> +       put_device(dev->parent);

Good catch. The child does not pin the parent until registration, but
we need to make sure the parent isn't gone while were waiting for the
registration work to run.

Let's break this reference count fix out into its own separate patch,
because this looks to be covering a gap that may need to be
recommended for -stable.


>
>  static void nd_async_device_unregister(void *d, async_cookie_t cookie)
> @@ -504,12 +506,25 @@ static void nd_async_device_unregister(void *d, async_cookie_t cookie)
>
>  void __nd_device_register(struct device *dev)
>  {
> +       int node;
> +
>         if (!dev)
>                 return;
> +
>         dev->bus = &nvdimm_bus_type;
> +       get_device(dev->parent);
>         get_device(dev);
> -       async_schedule_domain(nd_async_device_register, dev,
> -                       &nd_async_domain);
> +
> +       /*
> +        * For a region we can break away from the parent node,
> +        * otherwise for all other devices we just inherit the node from
> +        * the parent.
> +        */
> +       node = is_nd_region(dev) ? to_nd_region(dev)->numa_node :
> +                                  dev_to_node(dev->parent);

Devices already automatically inherit the node of their parent, so I'm
not understanding why this is needed?
