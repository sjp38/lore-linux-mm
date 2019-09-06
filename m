Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13729C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:06:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1DAB208C3
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:06:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1DAB208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E6D16B0003; Fri,  6 Sep 2019 08:06:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46F7F6B0006; Fri,  6 Sep 2019 08:06:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35DF16B0007; Fri,  6 Sep 2019 08:06:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5626B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:06:28 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9F5CD181AC9B4
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:06:27 +0000 (UTC)
X-FDA: 75904368414.16.jar32_556afc7bf0638
X-HE-Tag: jar32_556afc7bf0638
X-Filterd-Recvd-Size: 4858
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:06:26 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 462F1AC6E;
	Fri,  6 Sep 2019 12:06:25 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org
Cc: f.fainelli@gmail.com,
	will@kernel.org,
	robin.murphy@arm.com,
	nsaenzjulienne@suse.de,
	linux-kernel@vger.kernel.org,
	mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org,
	phill@raspberrypi.org,
	m.szyprowski@samsung.com
Subject: [PATCH v4 0/4] Raspberry Pi 4 DMA addressing support
Date: Fri,  6 Sep 2019 14:06:11 +0200
Message-Id: <20190906120617.18836-1-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,
this series attempts to address some issues we found while bringing up
the new Raspberry Pi 4 in arm64 and it's intended to serve as a follow
up of these discussions:
v3: https://lkml.org/lkml/2019/9/2/589
v2: https://lkml.org/lkml/2019/8/20/767
v1: https://lkml.org/lkml/2019/7/31/922
RFC: https://lkml.org/lkml/2019/7/17/476

The new Raspberry Pi 4 has up to 4GB of memory but most peripherals can
only address the first GB: their DMA address range is
0xc0000000-0xfc000000 which is aliased to the first GB of physical
memory 0x00000000-0x3c000000. Note that only some peripherals have these
limitations: the PCIe, V3D, GENET, and 40-bit DMA channels have a wider
view of the address space by virtue of being hooked up trough a second
interconnect.

Part of this is solved on arm32 by setting up the machine specific
'.dma_zone_size =3D SZ_1G', which takes care of reserving the coherent
memory area at the right spot. That said no buffer bouncing (needed for
dma streaming) is available at the moment, but that's a story for
another series.

Unfortunately there is no such thing as 'dma_zone_size' in arm64. Only
ZONE_DMA32 is created which is interpreted by dma-direct and the arm64
arch code as if all peripherals where be able to address the first 4GB
of memory.

In the light of this, the series implements the following changes:

- Create both DMA zones in arm64, ZONE_DMA will contain the first 1G
  area and ZONE_DMA32 the rest of the 32 bit addressable memory. So far
  the RPi4 is the only arm64 device with such DMA addressing limitations
  so this hardcoded solution was deemed preferable.

- Properly set ARCH_ZONE_DMA_BITS.

- Reserve the CMA area in a place suitable for all peripherals.

This series has been tested on multiple devices both by checking the
zones setup matches the expectations and by double-checking physical
addresses on pages allocated on the three relevant areas GFP_DMA,
GFP_DMA32, GFP_KERNEL:

- On an RPi4 with variations on the ram memory size. But also forcing
  the situation where all three memory zones are nonempty by setting a 3G
  ZONE_DMA32 ceiling on a 4G setup. Both with and without NUMA support.

- On a Synquacer box[1] with 32G of memory.

- On an ACPI based Huawei TaiShan server[2] with 256G of memory.

- On a QEMU virtual machine running arm64's OpenSUSE Tumbleweed.

That's all.

Regards,
Nicolas

[1] https://www.96boards.org/product/developerbox/
[2] https://e.huawei.com/en/products/cloud-computing-dc/servers/taishan-s=
erver/taishan-2280-v2

---

Changes in v4:
- Rebased to linux-next
- Fix issue when NUMA=3Dn and ZONE_DMA=3Dn
- Merge two max_zone_dma*_phys() functions

Changes in v3:
- Fixed ZONE_DMA's size to 1G
- Update mmzone.h's comment to match changes in arm64
- Remove all dma-direct patches

Changes in v2:
- Update comment to reflect new zones split
- ZONE_DMA will never be left empty
- Try another approach merging both ZONE_DMA comments into one
- Address Christoph's comments
- If this approach doesn't get much traction I'll just drop the patch
  from the series as it's not really essential

Nicolas Saenz Julienne (4):
  arm64: mm: use arm64_dma_phys_limit instead of calling
    max_zone_dma_phys()
  arm64: rename variables used to calculate ZONE_DMA32's size
  arm64: use both ZONE_DMA and ZONE_DMA32
  mm: refresh ZONE_DMA and ZONE_DMA32 comments in 'enum zone_type'

 arch/arm64/Kconfig            |  4 ++
 arch/arm64/include/asm/page.h |  2 +
 arch/arm64/mm/init.c          | 71 +++++++++++++++++++++++++----------
 include/linux/mmzone.h        | 45 ++++++++++++----------
 4 files changed, 83 insertions(+), 39 deletions(-)

--=20
2.23.0


