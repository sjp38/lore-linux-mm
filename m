Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F160C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 21:03:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E83C3218D3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 21:03:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="NAukeeOG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E83C3218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D4186B0005; Wed, 24 Apr 2019 17:03:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 783F36B0006; Wed, 24 Apr 2019 17:03:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69B956B0007; Wed, 24 Apr 2019 17:03:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40BB16B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 17:03:01 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id o13so11416552otk.12
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:03:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eTUb+CyGt59nJq65ekUidQk0sRQ1YJ2war5KMG5VlY8=;
        b=S4QuY66+NgVjoJr6vdneA4u28sU2hdmudTtrmxb+ChFQI+ZpT7WNcWuv1Cm22q9zyk
         jF6iI3XYZwo0R4cALyhDUsn19sOV21ypHm8Ztd9c65Af8A4ENPez0MhcVh0DGPVRNBOO
         A1Q0S1Ea/LLLDplESPAVdI7pGjU8NJpjBW9q/z+up6BeiJi6uQ/kCG/gB0BZXTB3UpQC
         l3TPu254GyjwqZ29FRT1t3Xuabn5R+G9ILShpikpHTgaUF0pNGpBtQYj5PNDZzK3rqDW
         aJum/04QpAeiW39/Wr8BRqWwA0akfM0OxNh8PrV5lpHDNoXrNX4JRaCTG5IBRW8GH2k6
         6DVA==
X-Gm-Message-State: APjAAAU10VwoHaUllLOLtVJilKtjASkiya9qovfFG4W5M9uUyq9jVAwx
	up6IFaiXeqEcDL2FI1IG7JF+ppkXr6TYq8JFGrS9K3ZY07dZdzsYhAx3dSJ1Okm1LhsSSLMoYtU
	GOELuJYImhegsNwnxSXY0Bnhzbe/QoVzf4tlF0ChuUNUs7XCHwZt7TW4HtSRDa5TAVA==
X-Received: by 2002:a05:6830:10c5:: with SMTP id z5mr21474171oto.107.1556139780855;
        Wed, 24 Apr 2019 14:03:00 -0700 (PDT)
X-Received: by 2002:a05:6830:10c5:: with SMTP id z5mr21474088oto.107.1556139779547;
        Wed, 24 Apr 2019 14:02:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556139779; cv=none;
        d=google.com; s=arc-20160816;
        b=rJ000AeTx5bxf9eNYsvenbGnYHvORbCiY4mbaYJG1eG2zjqnPY3VXzn1Fcu4iTKmxO
         KjdIUnj/tLFVaBl/VnpnlgAduAljtxZA9xwt+tzyb0pKAxOTryUPFHyP7CMGoz/IqlJC
         QRWFihgurUpizoV26I7Th6uA7SWz/lRbzrLPYJuE+zg94lxtUl1PkRCfMp+EXCNJj/a1
         2Y0pDvLrcyi8ERY71mmwT8cuChA7ntmnT+8hV/KyWNT+AP4CFrZbMNtGtONWsQi7jR6L
         MJsDp4HwQIgqPN/Pue7QZ14TKWtTcEQ/1Z0kHQTKIFhTQx6MpywjpgZyAohf+6l49nVs
         Gs8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eTUb+CyGt59nJq65ekUidQk0sRQ1YJ2war5KMG5VlY8=;
        b=ztEVeAAWkDluCL7gBp8qtydRjEFLaW7E3shr/vwqwOJdl09gRLr7WUaa3m5oODKNT9
         m/Ajs2BVfrWuVHhLdnKTtP5C0YFrKU9taBj5E+/3zwIWssYE+g5rsSs5A2tULjwq4YrS
         BV26D620l0p+kCAYKa05vVN5H/EmV/59xAy3IIdtfyquQd2peJ/Q0hU72u+lwuya+Woq
         YlPfpJSRY2XAgpvhON1UMfWtkh1lHHNiJCVnB7PZ8WlRIsl+nNrBWmyjNc8Y2MQp+Mpr
         1X8/7EATpC3+dvP5c8lKY7CWrcbnL6Q+DJGKIAybLLQQmQ8gO+sOGGgaRtqhe0E9RASi
         wGxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NAukeeOG;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i131sor9281079oia.132.2019.04.24.14.02.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 14:02:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NAukeeOG;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eTUb+CyGt59nJq65ekUidQk0sRQ1YJ2war5KMG5VlY8=;
        b=NAukeeOG6PbboHAPn1y1UFhEcWiGec24JJlVopk+XSNycRMcGZtbORw6U3suxwh23o
         vl7A4sfheYJ3vqN0x3G32UCVuOV8JUY8kJuyDE2e25G54lbJ/ehswWI2Y1uLJz0OeD5I
         AttC7/G1yWgM35Uiya9P6IYV/R2B0cXitG0i4NMh1xI33LraHDjpUoZbt5S6OMGjYTHh
         U6qkJSk1++rj9NKQt+wQ/csWHyPSEguzpXNhR09OaffSUROEraRjVMamRZmF6X03C7hO
         fl8BwpjCPKHYDEpuBuJ2SYb89XlzNRWE3jrnf5kij+3aZbBSpcY6jt27cEFSXSTJ1sK3
         B8wA==
X-Google-Smtp-Source: APXvYqxgZEdpnQTx7nG5QXoQG3hhm4UWprKyTLs5l7hvH2jUZXoc+vH22rNc5zwYf1mIkKXbN2A6923qXQYp9zpO4lo=
X-Received: by 2002:aca:de57:: with SMTP id v84mr801588oig.149.1556139779187;
 Wed, 24 Apr 2019 14:02:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
 <20190421014429.31206-3-pasha.tatashin@soleen.com> <4ad3c587-6ab8-1307-5a13-a3e73cf569a5@redhat.com>
In-Reply-To: <4ad3c587-6ab8-1307-5a13-a3e73cf569a5@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Apr 2019 14:02:48 -0700
Message-ID: <CAPcyv4h3+hU=MmB=RCc5GZmjLW_ALoVg_C4Z7aw8NQ=1LzPKaw@mail.gmail.com>
Subject: Re: [v2 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, 
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

On Wed, Apr 24, 2019 at 1:55 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 21.04.19 03:44, Pavel Tatashin wrote:
> > It is now allowed to use persistent memory like a regular RAM, but
> > currently there is no way to remove this memory until machine is
> > rebooted.
> >
> > This work expands the functionality to also allows hotremoving
> > previously hotplugged persistent memory, and recover the device for use
> > for other purposes.
> >
> > To hotremove persistent memory, the management software must first
> > offline all memory blocks of dax region, and than unbind it from
> > device-dax/kmem driver. So, operations should look like this:
> >
> > echo offline > echo offline > /sys/devices/system/memory/memoryN/state
> > ...
> > echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
> >
> > Note: if unbind is done without offlining memory beforehand, it won't be
> > possible to do dax0.0 hotremove, and dax's memory is going to be part of
> > System RAM until reboot.
> >
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> > ---
> >  drivers/dax/dax-private.h |  2 +
> >  drivers/dax/kmem.c        | 91 +++++++++++++++++++++++++++++++++++++--
> >  2 files changed, 89 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
> > index a45612148ca0..999aaf3a29b3 100644
> > --- a/drivers/dax/dax-private.h
> > +++ b/drivers/dax/dax-private.h
> > @@ -53,6 +53,7 @@ struct dax_region {
> >   * @pgmap - pgmap for memmap setup / lifetime (driver owned)
> >   * @ref: pgmap reference count (driver owned)
> >   * @cmp: @ref final put completion (driver owned)
> > + * @dax_mem_res: physical address range of hotadded DAX memory
> >   */
> >  struct dev_dax {
> >       struct dax_region *region;
> > @@ -62,6 +63,7 @@ struct dev_dax {
> >       struct dev_pagemap pgmap;
> >       struct percpu_ref ref;
> >       struct completion cmp;
> > +     struct resource *dax_kmem_res;
> >  };
> >
> >  static inline struct dev_dax *to_dev_dax(struct device *dev)
> > diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> > index 4c0131857133..d4896b281036 100644
> > --- a/drivers/dax/kmem.c
> > +++ b/drivers/dax/kmem.c
> > @@ -71,21 +71,104 @@ int dev_dax_kmem_probe(struct device *dev)
> >               kfree(new_res);
> >               return rc;
> >       }
> > +     dev_dax->dax_kmem_res = new_res;
> >
> >       return 0;
> >  }
> >
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +/*
> > + * Check that device-dax's memory_blocks are offline. If a memory_block is not
> > + * offline a warning is printed and an error is returned. dax hotremove can
> > + * succeed only when every memory_block is offlined beforehand.
> > + */
> > +static int
> > +offline_memblock_cb(struct memory_block *mem, void *arg)
>
> Function name suggests that you are actually trying to offline memory
> here. Maybe check_memblocks_offline_cb(), just like we have in
> mm/memory_hotplug.c.
>
> > +{
> > +     struct device *mem_dev = &mem->dev;
> > +     bool is_offline;
> > +
> > +     device_lock(mem_dev);
> > +     is_offline = mem_dev->offline;
> > +     device_unlock(mem_dev);
> > +
> > +     if (!is_offline) {
> > +             struct device *dev = (struct device *)arg;
> > +             unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
> > +             unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
> > +             phys_addr_t spa = spfn << PAGE_SHIFT;
> > +             phys_addr_t epa = epfn << PAGE_SHIFT;
> > +
> > +             dev_warn(dev, "memory block [%pa-%pa] is not offline\n",
> > +                      &spa, &epa);
> > +
> > +             return -EBUSY;
> > +     }
> > +
> > +     return 0;
> > +}
> > +
> > +static int dev_dax_kmem_remove(struct device *dev)
> > +{
> > +     struct dev_dax *dev_dax = to_dev_dax(dev);
> > +     struct resource *res = dev_dax->dax_kmem_res;
> > +     resource_size_t kmem_start;
> > +     resource_size_t kmem_size;
> > +     unsigned long start_pfn;
> > +     unsigned long end_pfn;
> > +     int rc;
> > +
> > +     /*
> > +      * dax kmem resource does not exist, means memory was never hotplugged.
> > +      * So, nothing to do here.
> > +      */
> > +     if (!res)
> > +             return 0;
> > +
> > +     kmem_start = res->start;
> > +     kmem_size = resource_size(res);
> > +     start_pfn = kmem_start >> PAGE_SHIFT;
> > +     end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
> > +
> > +     /*
> > +      * Walk and check that every singe memory_block of dax region is
> > +      * offline
> > +      */
> > +     lock_device_hotplug();
> > +     rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
> > +     unlock_device_hotplug();
> > +
> > +     /*
> > +      * If admin has not offlined memory beforehand, we cannot hotremove dax.
> > +      * Unfortunately, because unbind will still succeed there is no way for
> > +      * user to hotremove dax after this.
> > +      */
> > +     if (rc)
> > +             return rc;
>
> Can't it happen that there is a race between you checking if memory is
> offline and an admin onlining memory again? maybe pull the
> remove_memory() into the locked region, using __remove_memory() instead.

I think the race is ok. The admin gets to keep the pieces of allowing
racing updates to the state and the kernel will keep the range active
until the next reboot.

