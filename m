Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42C886B030B
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 14:35:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so699613pff.7
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 11:35:51 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id p68si198361pfk.196.2017.09.07.11.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Sep 2017 11:35:49 -0700 (PDT)
From: Ralph Campbell <rcampbell@nvidia.com>
Subject: RE: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Date: Thu, 7 Sep 2017 18:33:09 +0000
Message-ID: <c08ca2d4ac7f4b9a8987f282e697d30c@HQMAIL105.nvidia.com>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, "x86@kernel.org" <x86@kernel.org>



> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Tycho Andersen
> Sent: Thursday, September 7, 2017 10:36 AM
> To: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org; kernel-hardening@lists.openwall.com; Marco Benatt=
o
> <marco.antonio.780@gmail.com>; Juerg Haefliger
> <juerg.haefliger@canonical.com>; x86@kernel.org; Tycho Andersen
> <tycho@docker.com>
> Subject: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
> Ownership (XPFO)
>=20
> From: Juerg Haefliger <juerg.haefliger@canonical.com>
>=20
> This patch adds support for XPFO which protects against 'ret2dir' kernel =
attacks.
> The basic idea is to enforce exclusive ownership of page frames by either=
 the
> kernel or userspace, unless explicitly requested by the kernel. Whenever =
a page
> destined for userspace is allocated, it is unmapped from physmap (the ker=
nel's
> page table). When such a page is reclaimed from userspace, it is mapped b=
ack to
> physmap.
>=20
> Additional fields in the page_ext struct are used for XPFO housekeeping,
> specifically:
>   - two flags to distinguish user vs. kernel pages and to tag unmapped
>     pages.
>   - a reference counter to balance kmap/kunmap operations.
>   - a lock to serialize access to the XPFO fields.
>=20
> This patch is based on the work of Vasileios P. Kemerlis et al. who publi=
shed their
> work in this paper:
>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf
>=20
> v6: * use flush_tlb_kernel_range() instead of __flush_tlb_one, so we flus=
h
>       the tlb entry on all CPUs when unmapping it in kunmap
>     * handle lookup_page_ext()/lookup_xpfo() returning NULL
>     * drop lots of BUG()s in favor of WARN()
>     * don't disable irqs in xpfo_kmap/xpfo_kunmap, export
>       __split_large_page so we can do our own alloc_pages(GFP_ATOMIC) to
>       pass it
>=20
> CC: x86@kernel.org
> Suggested-by: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> Signed-off-by: Tycho Andersen <tycho@docker.com>
> Signed-off-by: Marco Benatto <marco.antonio.780@gmail.com>
> ---
>  Documentation/admin-guide/kernel-parameters.txt |   2 +
>  arch/x86/Kconfig                                |   1 +
>  arch/x86/include/asm/pgtable.h                  |  25 +++
>  arch/x86/mm/Makefile                            |   1 +
>  arch/x86/mm/pageattr.c                          |  22 +--
>  arch/x86/mm/xpfo.c                              | 114 ++++++++++++
>  include/linux/highmem.h                         |  15 +-
>  include/linux/xpfo.h                            |  42 +++++
>  mm/Makefile                                     |   1 +
>  mm/page_alloc.c                                 |   2 +
>  mm/page_ext.c                                   |   4 +
>  mm/xpfo.c                                       | 222 ++++++++++++++++++=
++++++
>  security/Kconfig                                |  19 ++
>  13 files changed, 449 insertions(+), 21 deletions(-)
>=20
> diff --git a/Documentation/admin-guide/kernel-parameters.txt
> b/Documentation/admin-guide/kernel-parameters.txt
> index d9c171ce4190..444d83183f75 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2736,6 +2736,8 @@
>=20
>  	nox2apic	[X86-64,APIC] Do not enable x2APIC mode.
>=20
> +	noxpfo		[X86-64] Disable XPFO when CONFIG_XPFO is on.
> +
>  	cpu0_hotplug	[X86] Turn on CPU0 hotplug feature when
>  			CONFIG_BOOTPARAM_HOTPLUG_CPU0 is off.
>  			Some features depend on CPU0. Known dependencies
<... snip>

A bit more description for system administrators would be very useful.
Perhaps something like:

noxpfo		[XPFO,X86-64] Disable eXclusive Page Frame Ownership (XPFO)
                             Physical pages mapped into user applications w=
ill also be mapped
                             in the kernel's address space as if CONFIG_XPF=
O was not enabled.

Patch 05 should also update kernel-parameters.txt and add "ARM64" to the co=
nfig option list for noxpfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
