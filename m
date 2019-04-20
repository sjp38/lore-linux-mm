Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F38DC282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:18:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0796120854
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:18:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="dBBqRo5x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0796120854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73A0D6B0003; Sat, 20 Apr 2019 12:18:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C1D56B0006; Sat, 20 Apr 2019 12:18:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58AE76B0007; Sat, 20 Apr 2019 12:18:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2539F6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 12:18:30 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id s184so3347443oig.19
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 09:18:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cJN6otCh8mhys26P8h5FkPQRQ5riYty4NiN3tBK+gLo=;
        b=nyBu+/VGnPjwdN7t6ZqZvQpBm760tiKMYYtqPVB+bLd9eyTca/hzEhjYfFGjnSzYRd
         bnRcP0wD7HvPTT8Ua9PSvLlue/PTKBwn7dFy63QCUNFb4aFjFUQAC6TfkP80hrAilDWF
         G9KIsguHqtwkhTwZDDa1PRtQaQVYNQdYZED+JszsUeEdQcYOj30fwb54bgisC+fEp8e/
         2g7pErND6pB1sUT2Z+6CqFZVrU1/NqQBCbBDEEwjgRNcgVfGGv4+F98QdeslFY8cqY2X
         DYcT57UfR8hgEh5rwJxtFr7Weujo6SP8kL3OYlzJu3KEgKxLRglTWoJr88p5zmJBSNyA
         F2yQ==
X-Gm-Message-State: APjAAAW/Ql+TcbT0lqrePbGDWLp0/UojAiy7g0yKiPvZEfLI91FFmqv/
	AFLXsHGd3r4sBXoVXStQA2Hs9kOLgMxukBBpfNYZc7E0Cgk0ZMx+ImxyHNMo1YJsMx8RG8r9/x6
	mgQuz350KUmscSbb0bHo64gJCzLa1lcrLtTiHW20Eyv34pCDDs81bdfYJyRNsm+Lkwg==
X-Received: by 2002:a05:6830:1107:: with SMTP id w7mr6079877otq.14.1555777109590;
        Sat, 20 Apr 2019 09:18:29 -0700 (PDT)
X-Received: by 2002:a05:6830:1107:: with SMTP id w7mr6079836otq.14.1555777108679;
        Sat, 20 Apr 2019 09:18:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555777108; cv=none;
        d=google.com; s=arc-20160816;
        b=xPEyoxg8OPs69s1y7yv5a38UPLEZuuWGupnsxab4VGOE+MiWtLOJYUK98/oznKNqAW
         +b8DRtJRV3RFX4AMFfrMg7MJR08FlJlbxHTASnxu6jUq7ButPevQhkZc/AQfvlhglCOm
         ugjKhT3mJ5wIbh+IOu4tM/pmCCPci1CGKzGw9jfY7dKO2bZ/yrWPg7i9x2jNdIUMWCIg
         MpNl6J3i4pAPX4o9btFVYiHITK/p3TLxivMURPDz/xYgTS5tgzX27aexE3scgHpnkq0b
         iO3u7In/3GFnan01u99L74k78nUIRjcB8OvG19PjwpHyOS3yj5eYfoG+t7tRKraSG+eS
         uq5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cJN6otCh8mhys26P8h5FkPQRQ5riYty4NiN3tBK+gLo=;
        b=Gepn7Mh6w5INk3E2dMMIdb2l4nCo3zHsHZmZeFc7DLVomnnjqjhfayXWddM6yoyDe2
         5+VhCvjWmLpGpZtMVBF37x4pii0LjTrvrjqUw5E+MQZ3h66kRFSLhmINgKiqlqT33pIR
         wXP539DgBqC8fn1m1BTmZO0PLvGkJ+ziRdVwjDwU1Agj2k0pIBToSOfefd6KXZbgbjVI
         IsZZ8uzK+NQIcrRA795BXNhLhZJmUKXs4s338D4eI09m8ipNT0/o9K9FPmJ2SWC/CZhE
         4R3ipC/duMPq/ZXRrf/bily80LSOz/tHp9bYzOWpC5PW719ZTrKs+2qvi/OQDlP7ukXk
         3TBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=dBBqRo5x;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22sor3703763otn.50.2019.04.20.09.18.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 09:18:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=dBBqRo5x;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cJN6otCh8mhys26P8h5FkPQRQ5riYty4NiN3tBK+gLo=;
        b=dBBqRo5xaNfsV65MZBeymXv/NSTESmTl3+fwmssTwZNQ0DDa0tnjbuffQOVu5qCvnG
         AG0VrOm4le3e+LX0JifIfOiuhEFvhKUUSN4039SOYLKauDfj1YVSe6s3yICiYmPeLG10
         PpR77q2mmZSO7IfFzQnmN61txzK05CNUgJ7hIh0osSPhkkRe9xHAejpjk+obuFyl91Ea
         jqB8dqVcVidO5NVOQwunL0nyFBTZNu4VnnB2MGhV4fub6mYPICSFjjGc4/iD7scI+mfL
         bxPnEMInGsg92KgtQL43DNw8s96ppM0p4V72EtLQFKKx4PfoMrHYIL/Ze6leYix4Tnqr
         6jTw==
X-Google-Smtp-Source: APXvYqz2wCGHjhO+pn/eM92vfjTkdPXmx9hD0C9qPGAa4bPwoPEXhsRYteLJiJI+bs/h1798PltDHVLFtDj5+musWq0=
X-Received: by 2002:a9d:7749:: with SMTP id t9mr5687797otl.229.1555777107880;
 Sat, 20 Apr 2019 09:18:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com> <20190420153148.21548-3-pasha.tatashin@soleen.com>
In-Reply-To: <20190420153148.21548-3-pasha.tatashin@soleen.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 20 Apr 2019 09:18:16 -0700
Message-ID: <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
Subject: Re: [v1 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 20, 2019 at 8:36 AM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> It is now allowed to use persistent memory like a regular RAM, but
> currently there is no way to remove this memory until machine is
> rebooted.
>
> This work expands the functionality to also allow hot removing
> previously hotplugged persistent memory, and recover the device for use
> for other purposes.
>
> To hotremove persistent memory, the management software must unbind it
> from device-dax/kmem driver:
>
>             echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
>
> Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> ---
>  drivers/dax/dax-private.h |  2 +
>  drivers/dax/kmem.c        | 77 +++++++++++++++++++++++++++++++++++++--
>  2 files changed, 75 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
> index a45612148ca0..999aaf3a29b3 100644
> --- a/drivers/dax/dax-private.h
> +++ b/drivers/dax/dax-private.h
> @@ -53,6 +53,7 @@ struct dax_region {
>   * @pgmap - pgmap for memmap setup / lifetime (driver owned)
>   * @ref: pgmap reference count (driver owned)
>   * @cmp: @ref final put completion (driver owned)
> + * @dax_mem_res: physical address range of hotadded DAX memory
>   */
>  struct dev_dax {
>         struct dax_region *region;
> @@ -62,6 +63,7 @@ struct dev_dax {
>         struct dev_pagemap pgmap;
>         struct percpu_ref ref;
>         struct completion cmp;
> +       struct resource *dax_kmem_res;
>  };
>
>  static inline struct dev_dax *to_dev_dax(struct device *dev)
> diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> index 4c0131857133..026c34f93df5 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -71,21 +71,90 @@ int dev_dax_kmem_probe(struct device *dev)
>                 kfree(new_res);
>                 return rc;
>         }
> +       dev_dax->dax_kmem_res = new_res;
>
>         return 0;
>  }
>
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +/*
> + * Offline device-dax's memory_blocks. If a memory_block cannot be offlined
> + * a warning is printed and an error is returned. dax hotremove can succeed
> + * only when every memory_block is offline.
> + */
> +static int
> +offline_memblock_cb(struct memory_block *mem, void *arg)
> +{
> +       struct device *dev = (struct device *)arg;
> +       int rc = device_offline(&mem->dev);
> +
> +       if (rc < 0) {
> +               unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
> +               unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
> +               phys_addr_t spa = spfn << PAGE_SHIFT;
> +               phys_addr_t epa = epfn << PAGE_SHIFT;
> +
> +               dev_warn(dev, "could not offline memory block [%pa-%pa]\n",
> +                        &spa, &epa);
> +
> +               return rc;
> +       }
> +
> +       return 0;
> +}
> +
> +static int dev_dax_kmem_remove(struct device *dev)
> +{
> +       struct dev_dax *dev_dax = to_dev_dax(dev);
> +       struct resource *res = dev_dax->dax_kmem_res;
> +       resource_size_t kmem_start;
> +       resource_size_t kmem_size;
> +       unsigned long start_pfn;
> +       unsigned long end_pfn;
> +       int rc;
> +
> +       /*
> +        * dax kmem resource does not exist, means memory was never hotplugged.
> +        * So, nothing to do here.
> +        */
> +       if (!res)
> +               return 0;
> +
> +       kmem_start = res->start;
> +       kmem_size = resource_size(res);
> +       start_pfn = kmem_start >> PAGE_SHIFT;
> +       end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
> +
> +       /* Walk and offline every singe memory_block of the dax region. */
> +       lock_device_hotplug();
> +       rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
> +       unlock_device_hotplug();
> +       if (rc)
> +               return rc;

This potential early return is the reason why memory hotremove is not
reliable vs the driver-core. If this walk fails to offline the memory
it will still be online, but the driver-core has no consideration for
device-unbind failing. The ubind will proceed while the memory stays
pinned.

