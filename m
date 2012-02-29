Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 26A3A6B007E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 04:36:04 -0500 (EST)
Received: by bkwq16 with SMTP id q16so120855bkw.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:36:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
From: Barry Song <21cnbao@gmail.com>
Date: Wed, 29 Feb 2012 17:35:42 +0800
Message-ID: <CAGsJ_4wgVcVjtAa6Qpki=8jSON7MfwJ8yumJ1YXE5p8L3PqUzw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv23 00/16] Contiguous Memory Allocator
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, DL-SHA-WorkGroupLinux <workgroup.linux@csr.com>

2012/2/23 Marek Szyprowski <m.szyprowski@samsung.com>:
> Hi,
>
> This is (yet another) quick update of CMA patches. I've rebased them
> onto next-20120222 tree from
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git and
> fixed the bug pointed by Aaro Koskinen.

For the whole series:

Tested-by: Barry Song <Baohua.Song@csr.com>

and i also write a simple kernel helper to test the CMA:

/*
 * kernek module helper for testing CMA
 *
 * Copyright (c) 2011 Cambridge Silicon Radio Limited, a CSR plc group comp=
any.
 *
 * Licensed under GPLv2 or later.
 */

#include <linux/module.h>
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/miscdevice.h>
#include <linux/dma-mapping.h>

#define CMA_NUM  10
static struct device *cma_dev;
static dma_addr_t dma_phys[CMA_NUM];
static void *dma_virt[CMA_NUM];

/* any read request will free coherent memory, eg.
 * cat /dev/cma_test
 */
static ssize_t
cma_test_read(struct file *file, char __user *buf, size_t count, loff_t *pp=
os)
{
	int i;

	for (i =3D 0; i < CMA_NUM; i++) {
		if (dma_virt[i]) {
			dma_free_coherent(cma_dev, (i + 1) * SZ_1M, dma_virt[i], dma_phys[i]);
			_dev_info(cma_dev, "free virt: %p phys: %p\n", dma_virt[i], (void
*)dma_phys[i]);
			dma_virt[i] =3D NULL;
			break;
		}
	}
	return 0;
}

/*
 * any write request will alloc coherent memory, eg.
 * echo 0 > /dev/cma_test
 */
static ssize_t
cma_test_write(struct file *file, const char __user *buf, size_t
count, loff_t *ppos)
{
	int i;
	int ret;

	for (i =3D 0; i < CMA_NUM; i++) {
		if (!dma_virt[i]) {
			dma_virt[i] =3D dma_alloc_coherent(cma_dev, (i + 1) * SZ_1M,
&dma_phys[i], GFP_KERNEL);

			if (dma_virt[i])
				_dev_info(cma_dev, "alloc virt: %p phys: %p\n", dma_virt[i], (void
*)dma_phys[i]);
			else {
				dev_err(cma_dev, "no mem in CMA area\n");
				ret =3D -ENOMEM;
			}
			break;
		}
	}

	return count;
}

static const struct file_operations cma_test_fops =3D {
	.owner =3D    THIS_MODULE,
	.read  =3D    cma_test_read,
	.write =3D    cma_test_write,
};

static struct miscdevice cma_test_misc =3D {
	.name =3D "cma_test",
	.fops =3D &cma_test_fops,
};

static int __init cma_test_init(void)
{
	int ret =3D 0;

	ret =3D misc_register(&cma_test_misc);
	if (unlikely(ret)) {
		pr_err("failed to register cma test misc device!\n");
		return ret;
	}
	cma_dev =3D cma_test_misc.this_device;
	cma_dev->coherent_dma_mask =3D ~0;
	_dev_info(cma_dev, "registered.\n");

	return ret;
}
module_init(cma_test_init);

static void __exit cma_test_exit(void)
{
	misc_deregister(&cma_test_misc);
}
module_exit(cma_test_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Barry Song <Baohua.Song@csr.com>");
MODULE_DESCRIPTION("kernel module to help the test of CMA");
MODULE_ALIAS("CMA test");

While fulfilling "dd if=3D/dev/mmcblk0 of=3D/dev/null bs=3D4096
count=3D1024000000 &" and "dd if=3D/dev/zero of=3D/data/1 bs=3D4096
count=3D1024000000 &" to exhaust memory at background,
i alloc the contiguous memories using the cma_test driver:
$echo 0 > /dev/cma_test
[   16.582216] misc cma_test: alloc virt: ceb00000 phys: 0eb00000
$echo 0 > /dev/cma_test
[   20.843395] misc cma_test: alloc virt: cec00000 phys: 0ec00000
$echo 0 > /dev/cma_test
[   21.774601] misc cma_test: alloc virt: cee00000 phys: 0ee00000
$echo 0 > /dev/cma_test
[   22.925633] misc cma_test: alloc virt: cf100000 phys: 0f100000

i did see the page write back is executed and contiguous memories are
always available.

P.S. the whole series was also back ported to 2.6.38.8 which our
release is based on.

>
> Best regards
> Marek Szyprowski
> Samsung Poland R&D Center
>
> Links to previous versions of the patchset:
> v22: <http://www.spinics.net/lists/linux-media/msg44370.html>
> v21: <http://www.spinics.net/lists/linux-media/msg44155.html>
> v20: <http://www.spinics.net/lists/linux-mm/msg29145.html>
> v19: <http://www.spinics.net/lists/linux-mm/msg29145.html>
> v18: <http://www.spinics.net/lists/linux-mm/msg28125.html>
> v17: <http://www.spinics.net/lists/arm-kernel/msg148499.html>
> v16: <http://www.spinics.net/lists/linux-mm/msg25066.html>
> v15: <http://www.spinics.net/lists/linux-mm/msg23365.html>
> v14: <http://www.spinics.net/lists/linux-media/msg36536.html>
> v13: (internal, intentionally not released)
> v12: <http://www.spinics.net/lists/linux-media/msg35674.html>
> v11: <http://www.spinics.net/lists/linux-mm/msg21868.html>
> v10: <http://www.spinics.net/lists/linux-mm/msg20761.html>
> =C2=A0v9: <http://article.gmane.org/gmane.linux.kernel.mm/60787>
> =C2=A0v8: <http://article.gmane.org/gmane.linux.kernel.mm/56855>
> =C2=A0v7: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
> =C2=A0v6: <http://article.gmane.org/gmane.linux.kernel.mm/55626>
> =C2=A0v5: (intentionally left out as CMA v5 was identical to CMA v4)
> =C2=A0v4: <http://article.gmane.org/gmane.linux.kernel.mm/52010>
> =C2=A0v3: <http://article.gmane.org/gmane.linux.kernel.mm/51573>
> =C2=A0v2: <http://article.gmane.org/gmane.linux.kernel.mm/50986>
> =C2=A0v1: <http://article.gmane.org/gmane.linux.kernel.mm/50669>
>
>
> Changelog:
>
> v23:
> =C2=A0 =C2=A01. fixed bug spotted by Aaro Koskinen (incorrect check insid=
e VM_BUG_ON)
>
> =C2=A0 =C2=A02. rebased onto next-20120222 tree from
> =C2=A0 =C2=A0 =C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/next/l=
inux-next.git
>
> v22:
> =C2=A0 =C2=A01. Fixed compilation break caused by missing fixup patch in =
v21
>
> =C2=A0 =C2=A02. Fixed typos in the comments
>
> =C2=A0 =C2=A03. Removed superfluous #include entries
>
> v21:
> =C2=A0 =C2=A01. Fixed incorrect check which broke memory compaction code
>
> =C2=A0 =C2=A02. Fixed hacky and racy min_free_kbytes handling
>
> =C2=A0 =C2=A03. Added serialization patch to watermark calculation
>
> =C2=A0 =C2=A04. Fixed typos here and there in the comments
>
> v20 and earlier - see previous patchsets.
>
>
> Patches in this patchset:
>
> Marek Szyprowski (6):
> =C2=A0mm: extract reclaim code from __alloc_pages_direct_reclaim()
> =C2=A0mm: trigger page reclaim in alloc_contig_range() to stabilise
> =C2=A0 =C2=A0watermarks
> =C2=A0drivers: add Contiguous Memory Allocator
> =C2=A0X86: integrate CMA with DMA-mapping subsystem
> =C2=A0ARM: integrate CMA with DMA-mapping subsystem
> =C2=A0ARM: Samsung: use CMA for 2 memory banks for s5p-mfc device
>
> Mel Gorman (1):
> =C2=A0mm: Serialize access to min_free_kbytes
>
> Michal Nazarewicz (9):
> =C2=A0mm: page_alloc: remove trailing whitespace
> =C2=A0mm: compaction: introduce isolate_migratepages_range()
> =C2=A0mm: compaction: introduce map_pages()
> =C2=A0mm: compaction: introduce isolate_freepages_range()
> =C2=A0mm: compaction: export some of the functions
> =C2=A0mm: page_alloc: introduce alloc_contig_range()
> =C2=A0mm: page_alloc: change fallbacks array handling
> =C2=A0mm: mmzone: MIGRATE_CMA migration type added
> =C2=A0mm: page_isolation: MIGRATE_CMA isolation functions added
>
> =C2=A0Documentation/kernel-parameters.txt =C2=A0 | =C2=A0 =C2=A09 +
> =C2=A0arch/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A03 +
> =C2=A0arch/arm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +
> =C2=A0arch/arm/include/asm/dma-contiguous.h | =C2=A0 15 ++
> =C2=A0arch/arm/include/asm/mach/map.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A01 +
> =C2=A0arch/arm/kernel/setup.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | =C2=A0 =C2=A09 +-
> =C2=A0arch/arm/mm/dma-mapping.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0369 ++++++++++++++++++++++++------
> =C2=A0arch/arm/mm/init.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0| =C2=A0 23 ++-
> =C2=A0arch/arm/mm/mm.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A03 +
> =C2=A0arch/arm/mm/mmu.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 | =C2=A0 31 ++-
> =C2=A0arch/arm/plat-s5p/dev-mfc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 51 +----
> =C2=A0arch/x86/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
> =C2=A0arch/x86/include/asm/dma-contiguous.h | =C2=A0 13 +
> =C2=A0arch/x86/include/asm/dma-mapping.h =C2=A0 =C2=A0| =C2=A0 =C2=A04 +
> =C2=A0arch/x86/kernel/pci-dma.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0 18 ++-
> =C2=A0arch/x86/kernel/pci-nommu.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 =C2=A08 +-
> =C2=A0arch/x86/kernel/setup.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | =C2=A0 =C2=A02 +
> =C2=A0drivers/base/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| =C2=A0 89 +++++++
> =C2=A0drivers/base/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0drivers/base/dma-contiguous.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A04=
01 +++++++++++++++++++++++++++++++
> =C2=A0include/asm-generic/dma-contiguous.h =C2=A0| =C2=A0 28 +++
> =C2=A0include/linux/device.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0 =C2=A04 +
> =C2=A0include/linux/dma-contiguous.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A01=
10 +++++++++
> =C2=A0include/linux/gfp.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0 12 +
> =C2=A0include/linux/mmzone.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0 47 +++-
> =C2=A0include/linux/page-isolation.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =
18 +-
> =C2=A0mm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0mm/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A03 +-
> =C2=A0mm/compaction.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0418 +++++++++++++++++++++------------
> =C2=A0mm/internal.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 33 +++
> =C2=A0mm/memory-failure.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +-
> =C2=A0mm/memory_hotplug.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A06 +-
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0409 ++++++++++++++++++++++++++++----
> =C2=A0mm/page_isolation.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0 15 +-
> =C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A03 +
> =C2=A035 files changed, 1790 insertions(+), 373 deletions(-)
> =C2=A0create mode 100644 arch/arm/include/asm/dma-contiguous.h
> =C2=A0create mode 100644 arch/x86/include/asm/dma-contiguous.h
> =C2=A0create mode 100644 drivers/base/dma-contiguous.c
> =C2=A0create mode 100644 include/asm-generic/dma-contiguous.h
> =C2=A0create mode 100644 include/linux/dma-contiguous.h
>
> --
> 1.7.1.569.g6f426

Thanks
barry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
