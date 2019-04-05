Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FA0CC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 11:19:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E465521850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 11:19:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E465521850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7733C6B0269; Fri,  5 Apr 2019 07:19:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74A1E6B026A; Fri,  5 Apr 2019 07:19:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 612C66B026B; Fri,  5 Apr 2019 07:19:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34B5C6B0269
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 07:19:17 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id f11so2789920otl.20
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 04:19:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=16pvh7dsOn1USHP44X+8RYU0uL920arAR58JiS+RMgg=;
        b=HoUhLLB1BhJIa/vHP1UXrA3shBvGAaKhoPuj8gVINZbP6Oogr+VBPQSKqos9kQ2xvK
         DaMB+DfyCeq0GkbsXMRhi0KEBaY2NBLI7d72tyrr+I3myUWO0GAgM9q/lYL6wRUen+5b
         rsZEE8nCtiE3UN/F+gqBUnT34wCmwedKM9Vt1tzS8mabAEYmkrvdPVFf66oED37vRldg
         CiXUb/tLtAqnBjop2OSVQX7GHajJO3BwTU4vT4ogIs08B8l3dgmFYLfnwS9LeC8cCabw
         pAi507x/89MDikX/DYLJReQlkKY7nxoXzIai5PCZbUy2XeDcAhQHUWx/W2jfn1Frb0KR
         hMhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAXf+7VBJyMPndRIz0hXfwdjWIBnT5xlDXdy+/Vx8tAI1F70GdXC
	RjTIBJoRu9jhEhFhVy1Pft79uSPOze4ksHDjvz9SQULjJ1BrzEYyhR+WYm4DEcPKwhGQL2h+618
	WYkYYb4Ic72T6kbjp778Hl+tfzila2qHmouffKO0pQkYNPhs6dWBjam31szb82mYXQw==
X-Received: by 2002:aca:b7c5:: with SMTP id h188mr6677845oif.130.1554463156696;
        Fri, 05 Apr 2019 04:19:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAwI2Z5iG+bLAt2oRZWNRZXu+zTy63hbkx6LKt2ppRKo4syOP5Dt9LLtt5ctNqjz9zuqT/
X-Received: by 2002:aca:b7c5:: with SMTP id h188mr6677770oif.130.1554463155050;
        Fri, 05 Apr 2019 04:19:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554463155; cv=none;
        d=google.com; s=arc-20160816;
        b=wEPdMt3FrXKy28dWe3GfvWGMUOCTQ4MGsXmbUCUfExU7fFpgCn143ISZXEcnB+RRZ0
         Duarwf1GlZZlPadHAfRIoYw4Nsz6uMSW6HZOl5xj/HKhN+hZZ5Vt24e0woBmr0tPF9jV
         JHGOJPrVWwdZcPadOs2jTfw+rnuCHOE74421u2oHSYYaHPzzZbsjDvKKY7wTeZLfELfA
         sz7Rv1y5ECiFGmauUzEE/7Rm3oc/taGwQa2FXp6Ven2nzz0gEWTm7nkqEr5N9VJU3wYH
         G6T2ipTbbl2Z/p/9o5OkcmAmOhoHbWOGqF+b8uRw0Pbme7tFvUqXvIfdCQFNFMBJu3+s
         RJAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=16pvh7dsOn1USHP44X+8RYU0uL920arAR58JiS+RMgg=;
        b=Z8GP/STSVD7mal0l2TzfWNjMXrUJTDgirFF4NQiOVHhOS8Ho/Dbf+bZ0GmqDun6IZN
         aZQCT5tTB19uXIcDNMTfppcOInYytRGIcibcpLXhCrGGCR/nO6n7TyFb7oxR99dYK7Vq
         2U6KxyOFg9FciOuAR+KpggFKCGWJ4+MLv463u4Ez+QXZQgwX1q5+2oUsEemqw9Aap14u
         3mZapOGdHk42UmHkjydy+6xf1NuTE41ZdHfMk93Ge/33o2P7RRAeJRMoI+R8WuZVzj9b
         gqwY14KTn9Xv5LKawGPydTyDs23eOdmjK/VBamkzYm3RsfmWGKIj2ABwYYlun/y5kf+x
         Ye4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id n2si9249678otl.276.2019.04.05.04.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 04:19:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 1975FDF69102902D2836;
	Fri,  5 Apr 2019 19:19:10 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.408.0; Fri, 5 Apr 2019
 19:19:08 +0800
Date: Fri, 5 Apr 2019 12:18:57 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>,
	<vishal.l.verma@intel.com>, <x86@kernel.org>, <linux-mm@kvack.org>,
	<linux-nvdimm@lists.01.org>
Subject: Re: [RFC PATCH 4/5] acpi/hmat: Register special purpose memory as a
 device
Message-ID: <20190405121857.0000718a@huawei.com>
In-Reply-To: <155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Apr 2019 12:08:49 -0700
Dan Williams <dan.j.williams@intel.com> wrote:

> Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
> properties described by the ACPI HMAT is expected to have an application
> specific consumer.
> 
> Those consumers may want 100% of the memory capacity to be reserved from
> any usage by the kernel. By default, with this enabling, a platform
> device is created to represent this differentiated resource.
> 
> A follow on change arranges for device-dax to claim these devices by
> default and provide an mmap interface for the target application.
> However, if the administrator prefers that some or all of the special
> purpose memory is made available to the core-mm the device-dax hotplug
> facility can be used to online the memory with its own numa node.
> 
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Len Brown <lenb@kernel.org>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Hi Dan,

Great to see you getting this discussion going so fast and in
general the approach makes sense to me.

I'm a little confused why HMAT has anything to do with this.
SPM is defined either via the attribute in SRAT SPA entries,
EF_MEMORY_SP or via the EFI memory map.

Whether it is in HMAT or not isn't all that relevant.
Back in the days of the reservation hint (so before yesterday :)
it was relevant obviously but that's no longer true.

So what am I missing?

Thanks,

Jonathan


> ---
>  drivers/acpi/hmat/Kconfig |    1 +
>  drivers/acpi/hmat/hmat.c  |   63 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/memregion.h |    3 ++
>  3 files changed, 67 insertions(+)
> 
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index 95a29964dbea..4fcf76e8aa1d 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -3,6 +3,7 @@ config ACPI_HMAT
>  	bool "ACPI Heterogeneous Memory Attribute Table Support"
>  	depends on ACPI_NUMA
>  	select HMEM_REPORTING
> +	select MEMREGION
>  	help
>  	 If set, this option has the kernel parse and report the
>  	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index e7ae44c8d359..482360004ea0 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -13,6 +13,9 @@
>  #include <linux/device.h>
>  #include <linux/init.h>
>  #include <linux/list.h>
> +#include <linux/mm.h>
> +#include <linux/memregion.h>
> +#include <linux/platform_device.h>
>  #include <linux/list_sort.h>
>  #include <linux/node.h>
>  #include <linux/sysfs.h>
> @@ -612,6 +615,65 @@ static __init void hmat_register_target_perf(struct memory_target *target)
>  	node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
>  }
>  
> +static __init void hmat_register_target_device(struct memory_target *target)
> +{
> +	struct memregion_info info;
> +	struct resource res = {
> +		.start = target->start,
> +		.end = target->start + target->size - 1,
> +		.flags = IORESOURCE_MEM,
> +		.desc = IORES_DESC_APPLICATION_RESERVED,
> +	};
> +	struct platform_device *pdev;
> +	int rc, id;
> +
> +	if (region_intersects(target->start, target->size, IORESOURCE_MEM,
> +				IORES_DESC_APPLICATION_RESERVED)
> +			!= REGION_INTERSECTS)
> +		return;
> +
> +	id = memregion_alloc();
> +	if (id < 0) {
> +		pr_err("acpi/hmat: memregion allocation failure for %pr\n", &res);
> +		return;
> +	}
> +
> +	pdev = platform_device_alloc("hmem", id);
> +	if (!pdev) {
> +		pr_err("acpi/hmat: hmem device allocation failure for %pr\n", &res);
> +		goto out_pdev;
> +	}
> +
> +	pdev->dev.numa_node = acpi_map_pxm_to_online_node(target->processor_pxm);
> +	info = (struct memregion_info) {
> +		.target_node = acpi_map_pxm_to_node(target->memory_pxm),
> +	};
> +	rc = platform_device_add_data(pdev, &info, sizeof(info));
> +	if (rc < 0) {
> +		pr_err("acpi/hmat: hmem memregion_info allocation failure for %pr\n", &res);
> +		goto out_pdev;
> +	}
> +
> +	rc = platform_device_add_resources(pdev, &res, 1);
> +	if (rc < 0) {
> +		pr_err("acpi/hmat: hmem resource allocation failure for %pr\n", &res);
> +		goto out_resource;
> +	}
> +
> +	rc = platform_device_add(pdev);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "acpi/hmat: device add failed for %pr\n", &res);
> +		goto out_resource;
> +	}
> +
> +	return;
> +
> +out_resource:
> +	put_device(&pdev->dev);
> +out_pdev:
> +	memregion_free(id);
> +}
> +
>  static __init void hmat_register_targets(void)
>  {
>  	struct memory_target *target;
> @@ -619,6 +681,7 @@ static __init void hmat_register_targets(void)
>  	list_for_each_entry(target, &targets, node) {
>  		hmat_register_target_initiators(target);
>  		hmat_register_target_perf(target);
> +		hmat_register_target_device(target);
>  	}
>  }
>  
> diff --git a/include/linux/memregion.h b/include/linux/memregion.h
> index 99fa47793b49..5de2ac7fcf5e 100644
> --- a/include/linux/memregion.h
> +++ b/include/linux/memregion.h
> @@ -1,6 +1,9 @@
>  // SPDX-License-Identifier: GPL-2.0
>  #ifndef _MEMREGION_H_
>  #define _MEMREGION_H_
> +struct memregion_info {
> +	int target_node;
> +};
>  int memregion_alloc(void);
>  void memregion_free(int id);
>  #endif /* _MEMREGION_H_ */
> 


