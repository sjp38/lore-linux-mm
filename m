Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32BE76B0390
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 21:38:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u202so55299427pgb.9
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 18:38:00 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id r64si3317957pfr.263.2017.04.06.18.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 18:37:59 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 79so11725472pgf.0
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 18:37:59 -0700 (PDT)
Message-ID: <1491529054.12351.16.camel@gmail.com>
Subject: Re: [HMM 14/16] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE
From: Balbir Singh <bsingharora@gmail.com>
In-Reply-To: <20170405204026.3940-15-jglisse@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
	 <20170405204026.3940-15-jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 07 Apr 2017 11:37:34 +1000
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Wed, 2017-04-05 at 16:40 -0400, JA(C)rA'me Glisse wrote:
> This introduce a simple struct and associated helpers for device driver
> to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
> will find a unuse physical address range and trigger memory hotplug for
> it which allocates and initialize struct page for the device memory.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> ---
>  include/linux/hmm.h | 114 +++++++++++++++
>  mm/Kconfig          |   9 ++
>  mm/hmm.c            | 398 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 521 insertions(+)
> 
> +/*
> + * To add (hotplug) device memory, HMM assumes that there is no real resource
> + * that reserves a range in the physical address space (this is intended to be
> + * use by unaddressable device memory). It will reserve a physical range big
> + * enough and allocate struct page for it.

I've found that the implementation of this is quite non-portable, in that
starting from iomem_resource.end+1-size (which is effectively -size) on
my platform (powerpc) does not give expected results. It could be that
additional changes are needed to arch_add_memory() to support this
use case.

> +
> +	size = ALIGN(size, SECTION_SIZE);
> +	addr = (iomem_resource.end + 1ULL) - size;


Why don't we allocate_resource() with the right constraints and get a new
unused region?

Thanks,
Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
