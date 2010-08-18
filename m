Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 36B976B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:01:38 -0400 (EDT)
Received: by wyg36 with SMTP id 36so220830wyg.14
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:01:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cover.1281100495.git.m.nazarewicz@samsung.com>
References: <cover.1281100495.git.m.nazarewicz@samsung.com>
Date: Wed, 18 Aug 2010 12:01:35 +0900
Message-ID: <AANLkTikp49oOny-vrtRTsJvA3Sps08=w7__JjdA3FE8t@mail.gmail.com>
Subject: Re: [PATCH/RFCv3 0/6] The Contiguous Memory Allocator framework
From: Kyungmin Park <kyungmin.park@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, Hiremath Vaibhav <hvaibhav@ti.com>, Hans Verkuil <hverkuil@xs4all.nl>, kgene.kim@samsung.com, Zach Pfeffer <zpfeffer@codeaurora.org>, jaeryul.oh@samsung.com, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

Are there any comments or ack?

We hope this method included at mainline kernel if possible.
It's really needed feature for our multimedia frameworks.

Thank you,
Kyungmin Park

On Fri, Aug 6, 2010 at 10:22 PM, Michal Nazarewicz
<m.nazarewicz@samsung.com> wrote:
> Hello everyone,
>
> The following patchset implements a Contiguous Memory Allocator. =A0For
> those who have not yet stumbled across CMA an excerpt from
> documentation:
>
> =A0 The Contiguous Memory Allocator (CMA) is a framework, which allows
> =A0 setting up a machine-specific configuration for physically-contiguous
> =A0 memory management. Memory for devices is then allocated according
> =A0 to that configuration.
>
> =A0 The main role of the framework is not to allocate memory, but to
> =A0 parse and manage memory configurations, as well as to act as an
> =A0 in-between between device drivers and pluggable allocators. It is
> =A0 thus not tied to any memory allocation method or strategy.
>
> For more information please refer to the second patch from the
> patchset which contains the documentation.
>
>
> Links to the previous versions of the patchsets:
> v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986/>
> v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669/>
>
>
> This is the third version of the patchset. =A0All of the changes are
> concentrated in the second, the third and the fourth patch -- the
> other patches are almost identical.
>
>
> Major observable changes between the second (the previous) and the
> third (this) versions are:
>
> 1. The command line parameters have been removed (and moved to
> =A0 a separate patch, the fourth one). =A0As a consequence, the
> =A0 cma_set_defaults() function has been changed -- it no longer
> =A0 accepts a string with list of regions but an array of regions.
>
> 2. The "asterisk" attribute has been removed. =A0Now, each region has an
> =A0 "asterisk" flag which lets one specify whether this region should
> =A0 by considered "asterisk" region.
>
> 3. SysFS support has been moved to a separate patch (the third one in
> =A0 the series) and now also includes list of regions.
>
>
> Major observable changes between the first and the second versions
> are:
>
> 1. The "cma_map" command line have been removed. =A0In exchange, a SysFS
> =A0 entry has been created under kernel/mm/contiguous.
>
> =A0 The intended way of specifying the attributes is
> =A0 a cma_set_defaults() function called by platform initialisation
> =A0 code. =A0"regions" attribute (the string specified by "cma" command
> =A0 line parameter) can be overwritten with command line parameter; the
> =A0 other attributes can be changed during run-time using the SysFS
> =A0 entries.
>
> 2. The behaviour of the "map" attribute has been modified slightly.
> =A0 Currently, if no rule matches given device it is assigned regions
> =A0 specified by the "asterisk" attribute. =A0It is by default built from
> =A0 the region names given in "regions" attribute.
>
> 3. Devices can register private regions as well as regions that can be
> =A0 shared but are not reserved using standard CMA mechanisms.
> =A0 A private region has no name and can be accessed only by devices
> =A0 that have the pointer to it.
>
> 4. The way allocators are registered has changed. =A0Currently,
> =A0 a cma_allocator_register() function is used for that purpose.
> =A0 Moreover, allocators are attached to regions the first time memory
> =A0 is registered from the region or when allocator is registered which
> =A0 means that allocators can be dynamic modules that are loaded after
> =A0 the kernel booted (of course, it won't be possible to allocate
> =A0 a chunk of memory from a region if allocator is not loaded).
>
> 5. Index of new functions:
>
> +static inline dma_addr_t __must_check
> +cma_alloc_from(const char *regions, size_t size, dma_addr_t alignment)
>
> +static inline int
> +cma_info_about(struct cma_info *info, const const char *regions)
>
> +int __must_check cma_region_register(struct cma_region *reg);
>
> +dma_addr_t __must_check
> +cma_alloc_from_region(struct cma_region *reg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, dma_addr_t alignme=
nt);
>
> +static inline dma_addr_t __must_check
> +cma_alloc_from(const char *regions,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, dma_addr_t alignment);
>
> +int cma_allocator_register(struct cma_allocator *alloc);
>
>
> Michal Nazarewicz (6):
> =A0lib: rbtree: rb_root_init() function added
> =A0mm: cma: Contiguous Memory Allocator added
> =A0mm: cma: Added SysFS support
> =A0mm: cma: Added command line parameters support
> =A0mm: cma: Test device and application added
> =A0arm: Added CMA to Aquila and Goni
>
> =A0Documentation/00-INDEX =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 =A02 +
> =A0.../ABI/testing/sysfs-kernel-mm-contiguous =A0 =A0 =A0 =A0 | =A0 58 +
> =A0Documentation/contiguous-memory.txt =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0651 +++++++++
> =A0Documentation/kernel-parameters.txt =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A04 +
> =A0arch/arm/mach-s5pv210/mach-aquila.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 31 +
> =A0arch/arm/mach-s5pv210/mach-goni.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 31 +
> =A0drivers/misc/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 | =A0 =A08 +
> =A0drivers/misc/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0| =A0 =A01 +
> =A0drivers/misc/cma-dev.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0184 +++
> =A0include/linux/cma.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0| =A0475 +++++++
> =A0include/linux/rbtree.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 11 +
> =A0mm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 | =A0 54 +
> =A0mm/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
> =A0mm/cma-best-fit.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0| =A0407 ++++++
> =A0mm/cma.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 | 1446 ++++++++++++++++++++
> =A0tools/cma/cma-test.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 | =A0373 +++++
> =A016 files changed, 3738 insertions(+), 0 deletions(-)
> =A0create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-contiguou=
s
> =A0create mode 100644 Documentation/contiguous-memory.txt
> =A0create mode 100644 drivers/misc/cma-dev.c
> =A0create mode 100644 include/linux/cma.h
> =A0create mode 100644 mm/cma-best-fit.c
> =A0create mode 100644 mm/cma.c
> =A0create mode 100644 tools/cma/cma-test.c
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
