Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 063DBC4CEC5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 11:12:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B45FA208C0
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 11:12:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="ENeynBjX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B45FA208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AAF06B0007; Fri, 13 Sep 2019 07:12:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4345F6B0008; Fri, 13 Sep 2019 07:12:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FBA46B000A; Fri, 13 Sep 2019 07:12:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 05CA06B0007
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:12:11 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 86B356D79
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 11:12:11 +0000 (UTC)
X-FDA: 75929633262.03.rake28_12deae800c633
X-HE-Tag: rake28_12deae800c633
X-Filterd-Recvd-Size: 8529
Received: from pio-pvt-msa1.bahnhof.se (pio-pvt-msa1.bahnhof.se [79.136.2.40])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 11:12:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTP id CD26C3F8D3;
	Fri, 13 Sep 2019 13:12:07 +0200 (CEST)
Authentication-Results: pio-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b="ENeynBjX";
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id niRmrq4Fp0ZP; Fri, 13 Sep 2019 13:12:05 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id D7E663F7CA;
	Fri, 13 Sep 2019 13:12:00 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id D2013360195;
	Fri, 13 Sep 2019 13:11:59 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568373119; bh=oVO0huRC63nNaAcmPyXTeKnX14VYqMTwWij4ToHPRag=;
	h=Subject:From:To:Cc:References:Date:In-Reply-To:From;
	b=ENeynBjXKPO+fu/mcg8v1dkU/vWW8JjcTx8ukBdSUdk5jJC1HPptRwsH49bhKicFO
	 1VLaQdDL15HW94NgLRR2PeF6lyMYwdHmKq7fIwgZJFYjlDW/IPztyvoEhVYbjuUJXk
	 Gg9PDdUJJr5dI+AMYZy+R/AayqJyLv1/xHWla2Tg=
Subject: Re: [RFC PATCH 1/7] mm: Add write-protect and clean utilities for
 address space ranges
From: =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?= <thomas_os@shipmail.org>
To: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org
Cc: Thomas Hellstrom <thellstrom@vmware.com>, Michal Hocko <mhocko@suse.com>,
 Rik van Riel <riel@surriel.com>, pv-drivers@vmware.com,
 Minchan Kim <minchan@kernel.org>, Will Deacon <will.deacon@arm.com>,
 Ralph Campbell <rcampbell@nvidia.com>, Matthew Wilcox <willy@infradead.org>,
 Peter Zijlstra <peterz@infradead.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, linux-graphics-maintainer@vmware.com,
 Souptick Joarder <jrdr.linux@gmail.com>, Huang Ying <ying.huang@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190913093213.27254-1-thomas_os@shipmail.org>
 <20190913093213.27254-2-thomas_os@shipmail.org>
Organization: VMware Inc.
Message-ID: <a70b7de4-32bf-2c78-4d15-21473be6842b@shipmail.org>
Date: Fri, 13 Sep 2019 13:11:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190913093213.27254-2-thomas_os@shipmail.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/13/19 11:32 AM, Thomas Hellstr=C3=B6m (VMware) wrote:
> From: Thomas Hellstrom <thellstrom@vmware.com>
>
> Add two utilities to a) write-protect and b) clean all ptes pointing in=
to
> a range of an address space.
> The utilities are intended to aid in tracking dirty pages (either
> driver-allocated system memory or pci device memory).
> The write-protect utility should be used in conjunction with
> page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
> accesses. Typically one would want to use this on sparse accesses into
> large memory regions. The clean utility should be used to utilize
> hardware dirtying functionality and avoid the overhead of page-faults,
> typically on large accesses into small memory regions.
>
> The added file "as_dirty_helpers.c" is initially listed as maintained b=
y
> VMware under our DRM driver. If somebody would like it elsewhere,
> that's of course no problem.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
>
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
> ---
>   MAINTAINERS           |   1 +
>   include/linux/mm.h    |  13 +-
>   mm/Kconfig            |   3 +
>   mm/Makefile           |   1 +
>   mm/as_dirty_helpers.c | 392 +++++++++++++++++++++++++++++++++++++++++=
+
>   5 files changed, 409 insertions(+), 1 deletion(-)
>   create mode 100644 mm/as_dirty_helpers.c
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index c2d975da561f..b596c7cf4a85 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5287,6 +5287,7 @@ T:	git git://people.freedesktop.org/~thomash/linu=
x
>   S:	Supported
>   F:	drivers/gpu/drm/vmwgfx/
>   F:	include/uapi/drm/vmwgfx_drm.h
> +F:	mm/as_dirty_helpers.c
>  =20
>   DRM DRIVERS
>   M:	David Airlie <airlied@linux.ie>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..27ff341ecbdc 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2657,7 +2657,6 @@ typedef int (*pte_fn_t)(pte_t *pte, unsigned long=
 addr, void *data);
>   extern int apply_to_page_range(struct mm_struct *mm, unsigned long ad=
dress,
>   			       unsigned long size, pte_fn_t fn, void *data);
>  =20
> -
>   #ifdef CONFIG_PAGE_POISONING
>   extern bool page_poisoning_enabled(void);
>   extern void kernel_poison_pages(struct page *page, int numpages, int =
enable);
> @@ -2891,5 +2890,17 @@ void __init setup_nr_node_ids(void);
>   static inline void setup_nr_node_ids(void) {}
>   #endif
>  =20
> +#ifdef CONFIG_AS_DIRTY_HELPERS
> +unsigned long apply_as_clean(struct address_space *mapping,
> +			     pgoff_t first_index, pgoff_t nr,
> +			     pgoff_t bitmap_pgoff,
> +			     unsigned long *bitmap,
> +			     pgoff_t *start,
> +			     pgoff_t *end);
> +
> +unsigned long apply_as_wrprotect(struct address_space *mapping,
> +				 pgoff_t first_index, pgoff_t nr);
> +#endif
> +
>   #endif /* __KERNEL__ */
>   #endif /* _LINUX_MM_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 56cec636a1fc..594350e9d78e 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -736,4 +736,7 @@ config ARCH_HAS_PTE_SPECIAL
>   config ARCH_HAS_HUGEPD
>   	bool
>  =20
> +config AS_DIRTY_HELPERS
> +        bool
> +
>   endmenu
> diff --git a/mm/Makefile b/mm/Makefile
> index d0b295c3b764..4086f1eefbc6 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -105,3 +105,4 @@ obj-$(CONFIG_PERCPU_STATS) +=3D percpu-stats.o
>   obj-$(CONFIG_ZONE_DEVICE) +=3D memremap.o
>   obj-$(CONFIG_HMM_MIRROR) +=3D hmm.o
>   obj-$(CONFIG_MEMFD_CREATE) +=3D memfd.o
> +obj-$(CONFIG_AS_DIRTY_HELPERS) +=3D as_dirty_helpers.o
> diff --git a/mm/as_dirty_helpers.c b/mm/as_dirty_helpers.c
> new file mode 100644
> index 000000000000..3be06fe8f1d2
> --- /dev/null
> +++ b/mm/as_dirty_helpers.c
> @@ -0,0 +1,392 @@
> +// SPDX-License-Identifier: GPL-2.0
> +#include <linux/mm.h>
> +#include <linux/mm_types.h>
> +#include <linux/hugetlb.h>
> +#include <linux/bitops.h>
> +#include <linux/mmu_notifier.h>
> +#include <asm/cacheflush.h>
> +#include <asm/tlbflush.h>
> +
> +/**
> + * struct as_walk - Argument to as_pte_fn_t

Argument to struct as_walk_ops callbacks

> + * @vma: Pointer to the struct vmw_area_struct currently being walked.
> + *
> + * Embeddable argument to struct as__pte_fn_t

Here as well.


> + */
> +struct as_walk {
> +	struct vm_area_struct *vma;
> +};
> +
> +/**
> + * struct as_walk_ops - Callbacks for entries of various page table le=
vels.
> + * extend for additional level support.
> + */
> +struct as_walk_ops {
> +	/**
> +	 * pte-entry: Callback for PTEs
> +	 * @pte: Pointer to the PTE.
> +	 * @addr: Virtual address.
> +	 * @asw: Struct as_walk argument for the walk. Embed for additional
> +	 * data.
> +	 */
> +	void (*const pte_entry) (pte_t *pte, unsigned long addr,
> +				 struct as_walk *asw);
> +};


