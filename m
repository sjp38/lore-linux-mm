Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8546EC04A6B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:04:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C8912086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:04:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C8912086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B449B6B0003; Tue, 14 May 2019 00:04:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF5116B0005; Tue, 14 May 2019 00:04:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C5B06B0007; Tue, 14 May 2019 00:04:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCEA6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:04:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i3so21250943edr.12
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:04:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=kOrUJ2IQfms7No9IJ6qvL0WH3Pj2kqV3rUYuu0GkG6s=;
        b=eZasAGaK+TTll0atexF/HPn696h5Gi6BNpdKm8Xrk2q1q8jx50lC5FURaxZ+yXKLuz
         AY/eAnKG+b7PH/fBpapRKMBBxM7u/Kv3JlVrrpOFDF4g+cI/mT6FJ27ub5jFMl5fpRSr
         h56pfAa8w3g/gjVXta+RKLRxKMZbetsI9ncapLPsU0JmAFi/depiQfQCKXiRY5MA7Lxz
         CV9gde6XFqjQGQFV0ofZWYFf6eXpByCXR21wgQG48RuvFj22aT4TzZi+LCWcYBYGVn4W
         OEP55R6A5By6zBSR7mkoOmACQDcl/cvXMK21McCzu6w2SF7Vqq1+PlEwMOkb6mtfdKi/
         e9tA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX6zdsToU6DBW4YzhzH7bVP1GLFxRUgZ/bC4G+xzwPpeTc+gRd8
	sMCY6Ewzntz8GTyw0qGUmk/ebafgO6gXyB/R1tOaiMbDESlFBXPSZr617o8fRTnTNmNJ3o4TKvv
	k3uwlARoKT6QxPnMk3Chb1atFSEl2+i1kpnrfP1sOojoVuSW1hOoCkDtCY2ESm3Ihnw==
X-Received: by 2002:a17:906:5e10:: with SMTP id n16mr25039510eju.143.1557806697820;
        Mon, 13 May 2019 21:04:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfNS9M7kQpGCyz1sSyUSyjROD9vLbB4v0SRMvvS1vgiMABvAVNE+qQCjtsA985cpOt1lQI
X-Received: by 2002:a17:906:5e10:: with SMTP id n16mr25039471eju.143.1557806696859;
        Mon, 13 May 2019 21:04:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557806696; cv=none;
        d=google.com; s=arc-20160816;
        b=TV/sI5xN5uT2dJz3aCd7Asxr0UEhFC+57SOMwzDgG6bqdGsjRvNGvCmiu4ZB8lMWOt
         W9U+eTnj3I901JskDvh9/xX9nuCq/6cAZqk6Rwp1YB/npae1cguRKyYhifmcGqlMWMFb
         PWnvPKVIceBizN6pSXRP/WL7Od4k7uwVKYAe2AHlAKHNyie++AphN4jN37wXVhxHLt1H
         7p6QUQGJv+HfLbgwtS0+Wq7KjOXjBob6mbJs+JqQlry0QZxKdI3Z4DSSA0nr0VM3Dlz9
         IeSObpzlqD+4NbM9s68pIXAQgKXQIQN8Ql1V6iUiM/griv0al0Z0I11AHA+Dp/MXrlof
         KM/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=kOrUJ2IQfms7No9IJ6qvL0WH3Pj2kqV3rUYuu0GkG6s=;
        b=zoI/yuePWOwOpE/pbMaiNX8ByWGdXH/55ukCGF3k8yTavWvqs/yJjtmCFmNEQ5U/RC
         NSTxO+wyVjno6T5oFQOxFbwAFUzdMwDi2zhk1nJIQG2GFBV9Be6ifc+XiPcKDz/9LJ32
         tzr/AF7OrCV35Zis20P40FI8NvS1l0cmnnpKXQuNp9SQbcYD1D3BWc13RBgeGczfv+Nv
         /RsbDw2dGJpFnN9hCQPgMuUPUkZF+SaystNP02bg6NuwhcdtsyQ9/dYWnIAq5FTNTjrm
         gZ2ON7jUJnGrL3K4NMbEd0q21aYOtE31r2iCHyjcDC3tfmsXGkJuUjtPG32Hlsns9leA
         SCCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j2si4456903ejt.260.2019.05.13.21.04.56
        for <linux-mm@kvack.org>;
        Mon, 13 May 2019 21:04:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 78EBB341;
	Mon, 13 May 2019 21:04:55 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8AD423F71E;
	Mon, 13 May 2019 21:04:52 -0700 (PDT)
Subject: Re: [RFC PATCH] mm/nvdimm: Fix kernel crash on
 devm_mremap_pages_release
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org
References: <20190514025354.9108-1-aneesh.kumar@linux.ibm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <2f08e63e-5ff9-b036-1212-9345894cca26@arm.com>
Date: Tue, 14 May 2019 09:35:01 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190514025354.9108-1-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/14/2019 08:23 AM, Aneesh Kumar K.V wrote:
> When we initialize the namespace, if we support altmap, we don't initialize all the
> backing struct page where as while releasing the namespace we look at some of
> these uninitilized struct page. This results in a kernel crash as below.
Yes this has been problematic which I have also previously encountered but in a bit
different way (while searching memory resources).

> 
> kernel BUG at include/linux/mm.h:1034!
What that would be ? Did not see a corresponding BUG_ON() line in the file.

> cpu 0x2: Vector: 700 (Program Check) at [c00000024146b870]
>     pc: c0000000003788f8: devm_memremap_pages_release+0x258/0x3a0
>     lr: c0000000003788f4: devm_memremap_pages_release+0x254/0x3a0
>     sp: c00000024146bb00
>    msr: 800000000282b033
>   current = 0xc000000241382f00
>   paca    = 0xc00000003fffd680   irqmask: 0x03   irq_happened: 0x01
>     pid   = 4114, comm = ndctl
>  c0000000009bf8c0 devm_action_release+0x30/0x50
>  c0000000009c0938 release_nodes+0x268/0x2d0
>  c0000000009b95b4 device_release_driver_internal+0x164/0x230
>  c0000000009b638c unbind_store+0x13c/0x190
>  c0000000009b4f44 drv_attr_store+0x44/0x60
>  c00000000058ccc0 sysfs_kf_write+0x70/0xa0
>  c00000000058b52c kernfs_fop_write+0x1ac/0x290
>  c0000000004a415c __vfs_write+0x3c/0x70
>  c0000000004a85ac vfs_write+0xec/0x200
>  c0000000004a8920 ksys_write+0x80/0x130
>  c00000000000bee4 system_call+0x5c/0x70

I saw this as memory hotplug problem with respect to ZONE_DEVICE based device memory.
Hence a bit different explanation which I never posted. I guess parts of the commit
message here can be used for a better comprehensive explanation of the problem.

mm/hotplug: Initialize struct pages for vmem_altmap reserved areas

The following ZONE_DEVICE ranges (altmap) have valid struct pages allocated
from within device memory memmap range.

A. Driver reserved area	[BASE -> BASE + RESV)
B. Device mmap area	[BASE + RESV -> BASE + RESV + FREE]
C. Device usable area	[BASE + RESV + FREE -> END]

BASE - pgmap->altmap.base_pfn (pgmap->res.start >> PAGE_SHIFT)
RESV - pgmap->altmap.reserve
FREE - pgmap->altmap.free
END  - pgmap->res->end >> PAGE_SHIFT

Struct page init for all areas happens in two phases which detects altmap
use case and init parts of the device range in each phase.

1. memmap_init_zone		(Device mmap area)
2. memmap_init_zone_device	(Device usable area)

memmap_init_zone() skips driver reserved area and does not init the
struct pages. This is problematic primarily for two reasons.

Though NODE_DATA(device_node(dev))->node_zones[ZONE_DEVICE] contains the
device memory range in it's entirety (in zone->spanned_pages) parts of this
range does not have zone set to ZONE_DEVICE in their struct page.

__remove_pages() called directly or from within arch_remove_memory() during
ZONE_DEVICE tear down procedure (devm_memremap_pages_release) hits an error
(like below) if there are reserved pages. This is because the first pfn of
the device range (invariably also the first pfn from reserved area) cannot
be identified belonging to ZONE_DEVICE. This erroneously leads range search
within iomem_resource region which never had this device memory region. So
this eventually ends up flashing the following error.

Unable to release resource <0x0000000680000000-0x00000006bfffffff> (-22)

Initialize struct pages for the driver reserved range while still staying
clear from it's contents.

> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  mm/page_alloc.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 59661106da16..892eabe1ec13 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5740,8 +5740,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  
>  #ifdef CONFIG_ZONE_DEVICE
>  	/*
> -	 * Honor reservation requested by the driver for this ZONE_DEVICE
> -	 * memory. We limit the total number of pages to initialize to just
> +	 * We limit the total number of pages to initialize to just
Comment needs bit change to reflect on the fact that both driver reserved as
well as mapped area (containing altmap struct pages) needs init here.

