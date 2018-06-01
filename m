Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7CB06B0274
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:44:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7-v6so13485533pfi.8
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:44:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor14860230pfh.53.2018.05.31.17.43.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:43:57 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 13/16] treewide: Use array_size() for kmalloc()-family, leftovers
Date: Thu, 31 May 2018 17:42:30 -0700
Message-Id: <20180601004233.37822-14-keescook@chromium.org>
In-Reply-To: <20180601004233.37822-1-keescook@chromium.org>
References: <20180601004233.37822-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Several odd cases where multiple expressions remain as array_size()
arguments:

Unchecked addition:

  +1 is very very common:
    new = kmalloc(array_size((valid_extensions + 1), EDID_LENGTH),

  plenty of others:
    ptr = kmalloc(array_size(obj->package.count + ACPI_VIDEO_FIRST_LEVEL,
			     sizeof(*br->levels)), GFP_KERNEL);

Single-byte values:
    array_size(sizeof(char *), E1)
    array_size(E1, sizeof(char *))

other glitches, e.g. should use array3_size():
    ptr = kzalloc(array_size(sizeof(void *), (NUM_CT_SUMS * CHN_NUM)),
		  GFP_KERNEL);

However, things are now improved by capturing these expressions within
array_size() and can be examined in future passes.

Generated with the following Coccinelle script:

// Any remaining multi-factor products, first at least 3-factor products...
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP, E1, E2, E3;
@@

- alloc(E1 * E2 * E3, GFP)
+ alloc(array3_size(E1, E2, E3), GFP)

// ... and then all remaining 2 factors products.
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP, E1, E2;
@@

- alloc(E1 * E2, GFP)
+ alloc(array_size(E1, E2), GFP)

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/mach-omap2/hsmmc.c                   |  3 +-
 arch/arm64/kernel/armv8_deprecated.c          |  4 +--
 arch/arm64/mm/context.c                       |  2 +-
 arch/ia64/kernel/mca_drv.c                    |  3 +-
 arch/ia64/mm/tlb.c                            |  4 +--
 arch/ia64/sn/pci/pcibr/pcibr_provider.c       |  3 +-
 arch/mips/alchemy/common/clock.c              |  2 +-
 arch/mips/alchemy/common/platform.c           |  2 +-
 arch/mips/bmips/dma.c                         |  2 +-
 arch/powerpc/kernel/vdso.c                    |  4 +--
 arch/powerpc/mm/numa.c                        |  2 +-
 arch/powerpc/net/bpf_jit_comp.c               |  2 +-
 arch/powerpc/net/bpf_jit_comp64.c             |  2 +-
 arch/powerpc/oprofile/cell/spu_profiler.c     |  4 +--
 arch/powerpc/platforms/4xx/msi.c              |  3 +-
 arch/powerpc/sysdev/mpic.c                    |  2 +-
 arch/powerpc/sysdev/xive/native.c             |  2 +-
 arch/s390/hypfs/hypfs_diag0c.c                |  3 +-
 arch/s390/kernel/vdso.c                       |  4 +--
 arch/sparc/kernel/sys_sparc_64.c              |  5 +--
 arch/um/drivers/vector_kern.c                 | 12 +++----
 arch/unicore32/kernel/pm.c                    |  4 +--
 arch/x86/events/amd/iommu.c                   |  3 +-
 arch/x86/events/intel/uncore.c                |  2 +-
 arch/x86/kernel/cpu/mcheck/mce_amd.c          |  2 +-
 arch/x86/kernel/hpet.c                        |  2 +-
 arch/x86/kvm/svm.c                            |  3 +-
 arch/x86/kvm/x86.c                            |  2 +-
 arch/x86/net/bpf_jit_comp.c                   |  2 +-
 arch/x86/pci/xen.c                            |  2 +-
 crypto/tcrypt.c                               |  2 +-
 crypto/testmgr.c                              |  3 +-
 drivers/acpi/acpi_video.c                     |  4 +--
 drivers/acpi/processor_perflib.c              |  2 +-
 drivers/acpi/processor_throttling.c           |  2 +-
 drivers/acpi/sysfs.c                          |  6 ++--
 drivers/android/binder_alloc.c                |  3 +-
 drivers/atm/he.c                              |  2 +-
 drivers/atm/iphase.c                          |  2 +-
 drivers/atm/solos-pci.c                       |  3 +-
 drivers/block/DAC960.c                        |  4 +--
 drivers/block/amiflop.c                       |  2 +-
 drivers/block/null_blk.c                      |  7 ++--
 drivers/block/rsxx/core.c                     |  3 +-
 drivers/block/rsxx/dma.c                      |  2 +-
 drivers/block/xen-blkback/xenbus.c            |  3 +-
 drivers/block/xen-blkfront.c                  |  9 +++--
 drivers/block/z2ram.c                         |  4 +--
 drivers/char/agp/amd-k7-agp.c                 |  3 +-
 drivers/char/agp/ati-agp.c                    |  3 +-
 drivers/char/agp/compat_ioctl.c               |  6 ++--
 drivers/char/agp/sworks-agp.c                 |  2 +-
 drivers/char/agp/uninorth-agp.c               |  3 +-
 drivers/char/ipmi/ipmi_ssif.c                 |  3 +-
 drivers/clk/st/clkgen-pll.c                   |  2 +-
 drivers/clk/sunxi/clk-usb.c                   |  3 +-
 drivers/clk/tegra/clk.c                       |  4 +--
 drivers/clk/ti/apll.c                         |  3 +-
 drivers/clk/ti/divider.c                      |  5 +--
 drivers/clk/ti/dpll.c                         |  3 +-
 drivers/clocksource/sh_cmt.c                  |  2 +-
 drivers/clocksource/sh_mtu2.c                 |  2 +-
 drivers/clocksource/sh_tmu.c                  |  2 +-
 drivers/cpufreq/acpi-cpufreq.c                |  4 +--
 drivers/cpufreq/bmips-cpufreq.c               |  3 +-
 drivers/cpufreq/cppc_cpufreq.c                |  3 +-
 drivers/cpufreq/ia64-acpi-cpufreq.c           |  5 ++-
 drivers/cpufreq/longhaul.c                    |  4 +--
 drivers/cpufreq/pxa3xx-cpufreq.c              |  2 +-
 drivers/cpufreq/sfi-cpufreq.c                 |  4 +--
 drivers/cpufreq/spear-cpufreq.c               |  3 +-
 drivers/crypto/amcc/crypto4xx_core.c          |  4 +--
 drivers/crypto/caam/ctrl.c                    |  4 +--
 drivers/crypto/inside-secure/safexcel_hash.c  |  2 +-
 drivers/crypto/marvell/hash.c                 |  2 +-
 drivers/crypto/qat/qat_common/qat_uclo.c      |  4 +--
 drivers/crypto/stm32/stm32-hash.c             |  2 +-
 drivers/dma/coh901318.c                       |  2 +-
 drivers/dma/pl330.c                           |  4 +--
 drivers/dma/sh/shdma-base.c                   |  4 +--
 drivers/edac/amd64_edac.c                     |  3 +-
 drivers/edac/i7core_edac.c                    |  2 +-
 drivers/extcon/extcon.c                       | 16 ++++-----
 drivers/firmware/efi/runtime-map.c            |  3 +-
 .../gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v7.c |  6 ++--
 .../gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v8.c |  6 ++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_dpm.c       |  3 +-
 drivers/gpu/drm/amd/amdgpu/atom.c             |  4 +--
 drivers/gpu/drm/amd/amdgpu/ci_dpm.c           |  4 +--
 drivers/gpu/drm/amd/amdgpu/kv_dpm.c           |  4 +--
 drivers/gpu/drm/amd/amdgpu/si_dpm.c           |  4 +--
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c      |  4 +--
 .../drm/amd/display/dc/dce/dce_clock_source.c |  4 +--
 .../amd/display/modules/color/color_gamma.c   | 36 ++++++++++---------
 .../gpu/drm/amd/display/modules/stats/stats.c |  4 +--
 drivers/gpu/drm/ast/ast_main.c                |  3 +-
 drivers/gpu/drm/drm_edid.c                    |  3 +-
 drivers/gpu/drm/gma500/mid_bios.c             |  2 +-
 drivers/gpu/drm/i915/selftests/intel_uncore.c |  2 +-
 drivers/gpu/drm/nouveau/nvif/mmu.c            |  9 +++--
 drivers/gpu/drm/nouveau/nvif/object.c         |  3 +-
 drivers/gpu/drm/nouveau/nvif/vmm.c            |  3 +-
 .../gpu/drm/nouveau/nvkm/engine/fifo/gk104.c  |  2 +-
 .../gpu/drm/nouveau/nvkm/engine/gr/ctxnv40.c  |  2 +-
 .../gpu/drm/nouveau/nvkm/engine/gr/ctxnv50.c  |  2 +-
 drivers/gpu/drm/omapdrm/omap_dmm_tiler.c      |  2 +-
 drivers/gpu/drm/qxl/qxl_kms.c                 |  2 +-
 drivers/gpu/drm/radeon/atom.c                 |  4 +--
 drivers/gpu/drm/radeon/ci_dpm.c               |  4 +--
 drivers/gpu/drm/radeon/kv_dpm.c               |  4 +--
 drivers/gpu/drm/radeon/ni_dpm.c               |  4 +--
 drivers/gpu/drm/radeon/r600_dpm.c             |  3 +-
 drivers/gpu/drm/radeon/radeon_atombios.c      | 16 ++++-----
 drivers/gpu/drm/radeon/rs780_dpm.c            |  4 +--
 drivers/gpu/drm/radeon/rv6xx_dpm.c            |  4 +--
 drivers/gpu/drm/radeon/rv770_dpm.c            |  4 +--
 drivers/gpu/drm/radeon/si_dpm.c               |  4 +--
 drivers/gpu/drm/radeon/sumo_dpm.c             |  4 +--
 drivers/gpu/drm/radeon/trinity_dpm.c          |  4 +--
 drivers/gpu/drm/savage/savage_bci.c           |  4 +--
 drivers/gpu/drm/selftests/test-drm_mm.c       |  4 +--
 drivers/gpu/drm/tinydrm/repaper.c             |  2 +-
 drivers/gpu/drm/vc4/vc4_plane.c               |  2 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_surface.c       |  3 +-
 drivers/hid/hid-core.c                        |  4 +--
 drivers/hid/hid-picolcd_fb.c                  |  3 +-
 drivers/hv/hv_util.c                          |  2 +-
 drivers/hv/ring_buffer.c                      |  2 +-
 drivers/hwmon/acpi_power_meter.c              |  6 ++--
 drivers/hwmon/ibmpex.c                        |  2 +-
 drivers/i2c/i2c-stub.c                        |  4 +--
 drivers/ide/hpt366.c                          |  3 +-
 drivers/ide/ide-ioctls.c                      |  2 +-
 drivers/ide/ide-probe.c                       |  2 +-
 drivers/iio/imu/adis_buffer.c                 |  3 +-
 drivers/iio/inkern.c                          |  2 +-
 drivers/infiniband/core/cache.c               |  4 +--
 drivers/infiniband/core/cma.c                 |  2 +-
 drivers/infiniband/core/device.c              |  3 +-
 drivers/infiniband/hw/cxgb4/device.c          |  4 +--
 drivers/infiniband/hw/cxgb4/id_table.c        |  4 +--
 drivers/infiniband/hw/cxgb4/qp.c              |  8 ++---
 drivers/infiniband/hw/mlx4/main.c             |  3 +-
 drivers/infiniband/hw/mlx4/qp.c               |  2 +-
 drivers/infiniband/hw/mlx5/srq.c              |  3 +-
 drivers/infiniband/hw/mthca/mthca_allocator.c |  2 +-
 drivers/infiniband/hw/mthca/mthca_cmd.c       |  3 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c   |  3 +-
 drivers/infiniband/hw/mthca/mthca_mr.c        |  2 +-
 drivers/infiniband/hw/mthca/mthca_qp.c        |  2 +-
 drivers/infiniband/hw/mthca/mthca_srq.c       |  2 +-
 drivers/infiniband/hw/nes/nes_hw.c            |  4 +--
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c   | 15 ++++----
 drivers/infiniband/hw/qedr/verbs.c            |  4 +--
 drivers/infiniband/hw/qib/qib_iba6120.c       |  8 ++---
 drivers/infiniband/hw/qib/qib_iba7220.c       |  8 ++---
 drivers/infiniband/hw/qib/qib_iba7322.c       | 12 +++----
 drivers/infiniband/hw/qib/qib_init.c          |  4 +--
 drivers/infiniband/hw/usnic/usnic_ib_qp_grp.c |  4 +--
 drivers/infiniband/ulp/iser/iser_initiator.c  |  4 +--
 drivers/infiniband/ulp/srp/ib_srp.c           |  6 ++--
 drivers/iommu/omap-iommu.c                    |  3 +-
 drivers/irqchip/irq-alpine-msi.c              |  2 +-
 drivers/irqchip/irq-gic-v2m.c                 |  2 +-
 drivers/irqchip/irq-gic-v3-its.c              |  6 ++--
 drivers/irqchip/irq-partition-percpu.c        |  2 +-
 drivers/isdn/capi/capidrv.c                   |  3 +-
 drivers/isdn/gigaset/capi.c                   |  6 ++--
 drivers/isdn/gigaset/i4l.c                    |  3 +-
 drivers/isdn/hisax/fsm.c                      |  3 +-
 drivers/isdn/i4l/isdn_common.c                |  3 +-
 drivers/isdn/mISDN/fsm.c                      |  4 +--
 drivers/lightnvm/pblk-init.c                  |  8 ++---
 drivers/md/bcache/super.c                     |  5 ++-
 drivers/md/dm-crypt.c                         |  4 +--
 drivers/md/dm-integrity.c                     | 12 ++++---
 drivers/md/dm-stats.c                         |  3 +-
 drivers/md/dm-verity-target.c                 |  4 +--
 drivers/md/md-cluster.c                       |  5 ++-
 drivers/md/md-multipath.c                     |  2 +-
 drivers/md/raid0.c                            |  7 ++--
 drivers/md/raid1.c                            |  9 +++--
 drivers/md/raid10.c                           | 10 ++----
 drivers/md/raid5.c                            |  6 ++--
 drivers/media/pci/bt8xx/bttv-risc.c           |  2 +-
 drivers/media/pci/ivtv/ivtv-yuv.c             |  3 +-
 drivers/media/pci/saa7164/saa7164-fw.c        |  2 +-
 drivers/media/pci/zoran/zoran_card.c          |  2 +-
 drivers/media/pci/zoran/zoran_driver.c        |  2 +-
 drivers/media/platform/vivid/vivid-core.c     |  4 +--
 drivers/media/spi/cxd2880-spi.c               |  2 +-
 drivers/media/usb/cx231xx/cx231xx-audio.c     |  3 +-
 drivers/media/usb/go7007/go7007-fw.c          |  2 +-
 drivers/media/usb/gspca/t613.c                |  2 +-
 drivers/media/usb/pvrusb2/pvrusb2-hdw.c       |  2 +-
 drivers/media/usb/stk1160/stk1160-core.c      |  4 +--
 drivers/media/usb/usbvision/usbvision-video.c |  3 +-
 drivers/media/usb/uvc/uvc_video.c             |  2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c     |  3 +-
 drivers/memstick/core/ms_block.c              |  3 +-
 drivers/message/fusion/mptlan.c               |  5 +--
 drivers/mfd/cros_ec_dev.c                     |  6 ++--
 drivers/mfd/mfd-core.c                        |  3 +-
 drivers/misc/eeprom/idt_89hpesx.c             |  3 +-
 drivers/misc/genwqe/card_ddcb.c               |  8 ++---
 drivers/misc/sgi-xp/xpnet.c                   |  4 +--
 drivers/misc/sram.c                           |  2 +-
 drivers/mtd/chips/cfi_cmdset_0001.c           |  7 ++--
 drivers/mtd/chips/cfi_cmdset_0002.c           |  4 +--
 drivers/mtd/chips/cfi_cmdset_0020.c           |  4 +--
 drivers/mtd/ftl.c                             | 12 +++----
 drivers/mtd/inftlmount.c                      |  6 ++--
 drivers/mtd/lpddr/lpddr_cmds.c                |  4 +--
 drivers/mtd/maps/physmap_of_core.c            |  2 +-
 drivers/mtd/maps/vmu-flash.c                  |  8 ++---
 drivers/mtd/mtdswap.c                         |  2 +-
 drivers/mtd/nand/onenand/onenand_base.c       |  4 +--
 drivers/mtd/nftlmount.c                       |  6 ++--
 drivers/mtd/sm_ftl.c                          | 11 +++---
 drivers/mtd/ssfdc.c                           |  4 +--
 drivers/mtd/tests/pagetest.c                  |  2 +-
 drivers/mtd/ubi/eba.c                         |  4 +--
 drivers/mtd/ubi/wl.c                          |  3 +-
 drivers/net/bonding/bond_main.c               |  3 +-
 drivers/net/can/grcan.c                       |  5 +--
 .../ethernet/atheros/atl1c/atl1c_ethtool.c    |  4 +--
 .../ethernet/atheros/atl1e/atl1e_ethtool.c    |  4 +--
 drivers/net/ethernet/atheros/atlx/atl2.c      |  4 +--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c  |  4 +--
 .../net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  4 +--
 drivers/net/ethernet/broadcom/cnic.c          |  7 ++--
 drivers/net/ethernet/brocade/bna/bnad.c       |  2 +-
 .../ethernet/cavium/thunder/nicvf_queues.c    |  4 +--
 .../net/ethernet/chelsio/cxgb4/cxgb4_main.c   |  4 +--
 drivers/net/ethernet/freescale/ucc_geth.c     |  6 ++--
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |  2 +-
 drivers/net/ethernet/ibm/ibmveth.c            |  3 +-
 .../net/ethernet/intel/e1000/e1000_ethtool.c  |  4 +--
 drivers/net/ethernet/intel/e1000e/ethtool.c   |  2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c    |  3 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |  6 ++--
 drivers/net/ethernet/intel/igb/igb_main.c     |  6 ++--
 .../net/ethernet/intel/ixgb/ixgb_ethtool.c    |  4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  3 +-
 drivers/net/ethernet/jme.c                    |  8 ++---
 drivers/net/ethernet/mellanox/mlx4/alloc.c    |  4 +--
 drivers/net/ethernet/mellanox/mlx4/cmd.c      | 17 +++++----
 drivers/net/ethernet/mellanox/mlx4/eq.c       |  2 +-
 .../ethernet/mellanox/mlx4/resource_tracker.c | 21 +++++------
 .../ethernet/mellanox/mlx5/core/fpga/conn.c   |  8 ++---
 .../ethernet/mellanox/mlx5/core/fpga/ipsec.c  |  2 +-
 .../ethernet/mellanox/mlx5/core/lib/clock.c   |  4 +--
 drivers/net/ethernet/micrel/ksz884x.c         |  2 +-
 drivers/net/ethernet/moxa/moxart_ether.c      |  4 +--
 .../net/ethernet/neterion/vxge/vxge-main.c    |  4 +--
 drivers/net/ethernet/nvidia/forcedeth.c       |  6 ++--
 drivers/net/ethernet/qlogic/qed/qed_debug.c   |  6 ++--
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 12 +++----
 .../net/ethernet/qlogic/qed/qed_init_ops.c    |  3 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c      |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c     |  3 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c  |  3 +-
 drivers/net/usb/asix_common.c                 |  4 +--
 drivers/net/usb/ax88179_178a.c                |  2 +-
 drivers/net/usb/usbnet.c                      |  2 +-
 drivers/net/virtio_net.c                      |  6 ++--
 drivers/net/wan/fsl_ucc_hdlc.c                |  4 +--
 drivers/net/wireless/ath/ath10k/htt_rx.c      |  2 +-
 drivers/net/wireless/ath/ath5k/phy.c          |  4 +--
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c |  2 +-
 drivers/net/wireless/ath/carl9170/main.c      |  4 +--
 .../broadcom/brcm80211/brcmfmac/msgbuf.c      |  4 +--
 .../broadcom/brcm80211/brcmsmac/phy/phy_n.c   |  3 +-
 drivers/net/wireless/intel/iwlegacy/common.c  |  8 ++---
 drivers/net/wireless/intersil/p54/eeprom.c    |  4 +--
 .../net/wireless/intersil/prism54/oid_mgt.c   |  3 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c   |  8 ++---
 drivers/net/wireless/mediatek/mt7601u/init.c  |  4 +--
 .../net/wireless/quantenna/qtnfmac/commands.c |  2 +-
 .../net/wireless/ralink/rt2x00/rt2x00debug.c  |  7 ++--
 drivers/net/wireless/realtek/rtlwifi/efuse.c  |  4 +--
 drivers/net/wireless/rsi/rsi_91x_mgmt.c       |  2 +-
 drivers/net/wireless/st/cw1200/queue.c        |  4 +--
 drivers/net/wireless/st/cw1200/scan.c         |  5 ++-
 drivers/net/wireless/ti/wlcore/spi.c          |  3 +-
 drivers/nvmem/sunxi_sid.c                     |  2 +-
 drivers/of/platform.c                         |  3 +-
 drivers/opp/ti-opp-supply.c                   |  4 +--
 drivers/pci/msi.c                             |  3 +-
 drivers/pinctrl/bcm/pinctrl-bcm2835.c         |  4 +--
 drivers/pinctrl/pinctrl-lantiq.c              |  3 +-
 drivers/pinctrl/vt8500/pinctrl-wmt.c          |  2 +-
 drivers/platform/x86/alienware-wmi.c          |  6 ++--
 drivers/platform/x86/panasonic-laptop.c       |  3 +-
 drivers/rapidio/rio-scan.c                    |  5 ++-
 drivers/s390/block/dasd_eer.c                 |  2 +-
 drivers/s390/block/dcssblk.c                  |  5 ++-
 drivers/s390/char/vmur.c                      |  2 +-
 drivers/s390/char/zcore.c                     |  3 +-
 drivers/s390/crypto/pkey_api.c                |  2 +-
 drivers/s390/net/qeth_core_main.c             | 18 +++++-----
 drivers/scsi/aacraid/linit.c                  |  3 +-
 drivers/scsi/aic7xxx/aic79xx_core.c           |  3 +-
 drivers/scsi/aic94xx/aic94xx_hwi.c            |  9 ++---
 drivers/scsi/aic94xx/aic94xx_init.c           |  2 +-
 drivers/scsi/be2iscsi/be_main.c               | 31 +++++++---------
 drivers/scsi/bfa/bfad_bsg.c                   |  4 +--
 drivers/scsi/csiostor/csio_wr.c               |  6 ++--
 drivers/scsi/dpt_i2o.c                        |  2 +-
 drivers/scsi/esas2r/esas2r_init.c             |  4 +--
 drivers/scsi/hpsa.c                           | 23 ++++++------
 drivers/scsi/ipr.c                            |  4 +--
 drivers/scsi/libiscsi.c                       |  3 +-
 drivers/scsi/libsas/sas_expander.c            |  3 +-
 drivers/scsi/lpfc/lpfc_sli.c                  |  5 ++-
 drivers/scsi/lpfc/lpfc_vport.c                |  2 +-
 drivers/scsi/mac53c94.c                       |  4 +--
 drivers/scsi/megaraid/megaraid_mm.c           |  8 ++---
 drivers/scsi/pm8001/pm8001_ctl.c              |  2 +-
 drivers/scsi/qedi/qedi_main.c                 |  3 +-
 drivers/scsi/qla2xxx/qla_init.c               |  8 ++---
 drivers/scsi/qla2xxx/qla_isr.c                |  4 +--
 drivers/scsi/qla2xxx/qla_os.c                 | 12 +++----
 drivers/scsi/qla2xxx/qla_target.c             |  4 +--
 drivers/scsi/smartpqi/smartpqi_init.c         |  4 +--
 drivers/sh/intc/core.c                        | 10 +++---
 drivers/sh/maple/maple.c                      |  2 +-
 drivers/soc/fsl/qbman/qman_test_stash.c       |  2 +-
 drivers/staging/lustre/lustre/lov/lov_io.c    |  5 ++-
 .../staging/lustre/lustre/lov/lov_object.c    |  4 +--
 .../staging/lustre/lustre/ptlrpc/sec_bulk.c   |  5 ++-
 .../pci/atomisp2/css2400/sh_css_firmware.c    |  5 ++-
 drivers/staging/rtl8192u/r8192U_core.c        |  2 +-
 .../staging/rtl8723bs/os_dep/ioctl_linux.c    |  2 +-
 drivers/staging/rtlwifi/efuse.c               |  4 +--
 drivers/staging/rts5208/ms.c                  |  2 +-
 drivers/target/target_core_user.c             |  4 +--
 .../int340x_thermal/acpi_thermal_rel.c        |  4 +--
 drivers/thermal/of-thermal.c                  |  6 ++--
 drivers/tty/hvc/hvc_iucv.c                    |  2 +-
 drivers/tty/isicom.c                          |  2 +-
 drivers/tty/serial/serial_core.c              |  3 +-
 drivers/tty/vt/selection.c                    |  3 +-
 drivers/usb/core/message.c                    |  3 +-
 drivers/usb/gadget/udc/fsl_udc_core.c         |  3 +-
 drivers/usb/host/ehci-sched.c                 |  4 +--
 drivers/usb/host/imx21-hcd.c                  |  4 +--
 drivers/usb/host/isp1362-hcd.c                |  2 +-
 drivers/usb/host/xhci-mem.c                   |  8 ++---
 drivers/usb/misc/ldusb.c                      |  6 ++--
 drivers/usb/mon/mon_bin.c                     |  3 +-
 drivers/usb/storage/alauda.c                  |  3 +-
 drivers/usb/storage/ene_ub6250.c              | 12 ++++---
 drivers/usb/storage/isd200.c                  |  2 +-
 drivers/usb/storage/sddr55.c                  |  2 +-
 drivers/usb/wusbcore/wa-rpipe.c               |  2 +-
 drivers/uwb/est.c                             |  2 +-
 drivers/uwb/i1480/dfu/usb.c                   |  2 +-
 drivers/video/console/sticore.c               |  2 +-
 drivers/video/fbdev/core/bitblit.c            |  5 +--
 drivers/video/fbdev/core/fbcon.c              |  3 +-
 drivers/video/fbdev/core/fbcon_ccw.c          |  8 +++--
 drivers/video/fbdev/core/fbcon_cw.c           |  8 +++--
 drivers/video/fbdev/core/fbcon_ud.c           |  5 +--
 drivers/video/fbdev/core/fbmem.c              |  9 ++---
 drivers/video/fbdev/core/fbmon.c              |  4 +--
 drivers/video/fbdev/i810/i810_main.c          |  4 +--
 drivers/video/fbdev/intelfb/intelfbdrv.c      |  2 +-
 drivers/video/fbdev/matrox/g450_pll.c         |  3 +-
 drivers/video/fbdev/mb862xx/mb862xxfb_accel.c |  2 +-
 drivers/video/fbdev/nvidia/nvidia.c           |  5 +--
 drivers/video/fbdev/riva/fbdev.c              |  5 +--
 drivers/video/fbdev/uvesafb.c                 |  7 ++--
 drivers/video/of_display_timing.c             |  4 +--
 drivers/virt/vboxguest/vboxguest_core.c       |  3 +-
 drivers/xen/xen-pciback/pciback_ops.c         |  2 +-
 fs/afs/cmservice.c                            |  3 +-
 fs/btrfs/check-integrity.c                    |  5 ++-
 fs/ceph/mds_client.c                          |  4 +--
 fs/cifs/smb2pdu.c                             |  2 +-
 fs/cifs/transport.c                           |  4 +--
 fs/ext4/extents.c                             |  8 ++---
 fs/ext4/resize.c                              |  6 ++--
 fs/fuse/dev.c                                 |  6 ++--
 fs/gfs2/dir.c                                 |  2 +-
 fs/gfs2/rgrp.c                                |  2 +-
 fs/hpfs/dnode.c                               |  2 +-
 fs/hpfs/map.c                                 |  2 +-
 fs/jffs2/wbuf.c                               |  3 +-
 fs/jfs/jfs_dtree.c                            | 14 ++++----
 fs/jfs/jfs_unicode.c                          |  2 +-
 fs/nfsd/export.c                              |  4 +--
 fs/ocfs2/journal.c                            |  2 +-
 fs/ocfs2/sysfile.c                            |  4 +--
 fs/overlayfs/namei.c                          |  2 +-
 fs/proc/proc_sysctl.c                         |  2 +-
 fs/proc/task_mmu.c                            |  2 +-
 fs/reiserfs/inode.c                           |  3 +-
 fs/reiserfs/journal.c                         |  8 ++---
 fs/select.c                                   |  2 +-
 fs/ubifs/lpt.c                                |  7 ++--
 fs/ubifs/tnc.c                                |  2 +-
 fs/ubifs/tnc_commit.c                         |  3 +-
 fs/udf/super.c                                |  4 +--
 fs/ufs/super.c                                |  2 +-
 kernel/bpf/lpm_trie.c                         |  2 +-
 kernel/bpf/verifier.c                         |  3 +-
 kernel/cgroup/cpuset.c                        |  2 +-
 kernel/debug/kdb/kdb_main.c                   |  9 ++---
 kernel/events/uprobes.c                       |  3 +-
 kernel/fail_function.c                        |  2 +-
 kernel/locking/locktorture.c                  | 10 +++---
 kernel/relay.c                                |  3 +-
 kernel/sysctl.c                               |  2 +-
 kernel/trace/trace.c                          |  5 +--
 lib/argv_split.c                              |  2 +-
 lib/reed_solomon/reed_solomon.c               |  9 +++--
 lib/test_string.c                             |  6 ++--
 lib/test_user_copy.c                          |  2 +-
 mm/slab.c                                     |  3 +-
 mm/slub.c                                     | 12 +++----
 mm/swapfile.c                                 |  2 +-
 net/9p/protocol.c                             |  5 ++-
 net/can/bcm.c                                 |  6 ++--
 net/ceph/osdmap.c                             |  2 +-
 net/core/ethtool.c                            |  2 +-
 net/ipv4/fib_frontend.c                       |  2 +-
 net/mac80211/util.c                           |  4 +--
 net/netfilter/xt_dccp.c                       |  2 +-
 net/netlink/genetlink.c                       |  8 ++---
 net/rds/ib.c                                  |  2 +-
 net/sched/sch_fq_codel.c                      |  7 ++--
 net/smc/smc_wr.c                              |  5 ++-
 net/sunrpc/auth_gss/auth_gss.c                |  4 +--
 net/sunrpc/auth_gss/gss_krb5_crypto.c         |  2 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c          |  3 +-
 net/sunrpc/cache.c                            |  2 +-
 net/tipc/netlink_compat.c                     |  4 +--
 security/keys/trusted.c                       |  2 +-
 sound/core/pcm_native.c                       |  4 +--
 sound/firewire/dice/dice-transaction.c        |  4 +--
 sound/pci/cs46xx/cs46xx_lib.c                 |  6 ++--
 sound/pci/ctxfi/ctatc.c                       |  2 +-
 sound/pci/ctxfi/ctdaio.c                      |  3 +-
 sound/pci/ctxfi/ctmixer.c                     |  5 +--
 sound/pci/ctxfi/ctsrc.c                       |  2 +-
 sound/pci/emu10k1/emufx.c                     |  6 ++--
 sound/pci/hda/hda_codec.c                     |  3 +-
 sound/soc/codecs/wm8904.c                     |  4 +--
 sound/soc/codecs/wm8958-dsp2.c                | 16 ++++-----
 sound/soc/codecs/wm_adsp.c                    |  2 +-
 sound/soc/soc-core.c                          |  5 ++-
 sound/soc/soc-dapm.c                          |  5 ++-
 sound/soc/soc-topology.c                      |  2 +-
 sound/usb/format.c                            |  3 +-
 sound/usb/line6/capture.c                     |  4 +--
 sound/usb/line6/pcm.c                         |  4 +--
 sound/usb/line6/playback.c                    |  4 +--
 sound/usb/mixer.c                             |  3 +-
 sound/usb/usx2y/usbusx2yaudio.c               |  3 +-
 460 files changed, 1015 insertions(+), 925 deletions(-)

diff --git a/arch/arm/mach-omap2/hsmmc.c b/arch/arm/mach-omap2/hsmmc.c
index b064066d431c..34d7b3a50ab7 100644
--- a/arch/arm/mach-omap2/hsmmc.c
+++ b/arch/arm/mach-omap2/hsmmc.c
@@ -35,7 +35,8 @@ static int __init omap_hsmmc_pdata_init(struct omap2_hsmmc_info *c,
 {
 	char *hc_name;
 
-	hc_name = kzalloc(sizeof(char) * (HSMMC_NAME_LEN + 1), GFP_KERNEL);
+	hc_name = kzalloc(array_size(sizeof(char), (HSMMC_NAME_LEN + 1)),
+			  GFP_KERNEL);
 	if (!hc_name) {
 		kfree(hc_name);
 		return -ENOMEM;
diff --git a/arch/arm64/kernel/armv8_deprecated.c b/arch/arm64/kernel/armv8_deprecated.c
index 6e47fc3ab549..869f98e0c114 100644
--- a/arch/arm64/kernel/armv8_deprecated.c
+++ b/arch/arm64/kernel/armv8_deprecated.c
@@ -235,8 +235,8 @@ static void __init register_insn_emulation_sysctl(void)
 	struct insn_emulation *insn;
 	struct ctl_table *insns_sysctl, *sysctl;
 
-	insns_sysctl = kzalloc(sizeof(*sysctl) * (nr_insn_emulated + 1),
-			      GFP_KERNEL);
+	insns_sysctl = kzalloc(array_size(sizeof(*sysctl), (nr_insn_emulated + 1)),
+			       GFP_KERNEL);
 
 	raw_spin_lock_irqsave(&insn_emulation_lock, flags);
 	list_for_each_entry(insn, &insn_emulation, node) {
diff --git a/arch/arm64/mm/context.c b/arch/arm64/mm/context.c
index 301417ae2ba8..aa98ad0a70e2 100644
--- a/arch/arm64/mm/context.c
+++ b/arch/arm64/mm/context.c
@@ -263,7 +263,7 @@ static int asids_init(void)
 	 */
 	WARN_ON(NUM_USER_ASIDS - 1 <= num_possible_cpus());
 	atomic64_set(&asid_generation, ASID_FIRST_VERSION);
-	asid_map = kzalloc(BITS_TO_LONGS(NUM_USER_ASIDS) * sizeof(*asid_map),
+	asid_map = kzalloc(array_size(BITS_TO_LONGS(NUM_USER_ASIDS), sizeof(*asid_map)),
 			   GFP_KERNEL);
 	if (!asid_map)
 		panic("Failed to allocate bitmap for %lu ASIDs\n",
diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 94f8bf777afa..820857c09048 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -350,7 +350,8 @@ init_record_index_pools(void)
 	/* - 3 - */
 	slidx_pool.max_idx = (rec_max_size/sect_min_size) * 2 + 1;
 	slidx_pool.buffer =
-		kmalloc(slidx_pool.max_idx * sizeof(slidx_list_t), GFP_KERNEL);
+		kmalloc(array_size(slidx_pool.max_idx, sizeof(slidx_list_t)),
+			GFP_KERNEL);
 
 	return slidx_pool.buffer ? 0 : -ENOMEM;
 }
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 46ecc5d948aa..b39c9f62b7ac 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -430,8 +430,8 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
 	int cpu = smp_processor_id();
 
 	if (!ia64_idtrs[cpu]) {
-		ia64_idtrs[cpu] = kmalloc(2 * IA64_TR_ALLOC_MAX *
-				sizeof (struct ia64_tr_entry), GFP_KERNEL);
+		ia64_idtrs[cpu] = kmalloc(array3_size(2, IA64_TR_ALLOC_MAX, sizeof(struct ia64_tr_entry)),
+					  GFP_KERNEL);
 		if (!ia64_idtrs[cpu])
 			return -ENOMEM;
 	}
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
index 8dbbef4a4f47..49a7b23f5fc9 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -184,7 +184,8 @@ pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
 	/* Setup the PMU ATE map */
 	soft->pbi_int_ate_resource.lowest_free_index = 0;
 	soft->pbi_int_ate_resource.ate =
-	    kzalloc(soft->pbi_int_ate_size * sizeof(u64), GFP_KERNEL);
+	    kzalloc(array_size(soft->pbi_int_ate_size, sizeof(u64)),
+		    GFP_KERNEL);
 
 	if (!soft->pbi_int_ate_resource.ate) {
 		kfree(soft);
diff --git a/arch/mips/alchemy/common/clock.c b/arch/mips/alchemy/common/clock.c
index 6b6f6851df92..de5237f930c4 100644
--- a/arch/mips/alchemy/common/clock.c
+++ b/arch/mips/alchemy/common/clock.c
@@ -985,7 +985,7 @@ static int __init alchemy_clk_setup_imux(int ctype)
 		return -ENODEV;
 	}
 
-	a = kzalloc((sizeof(*a)) * 6, GFP_KERNEL);
+	a = kzalloc(array_size((sizeof(*a)), 6), GFP_KERNEL);
 	if (!a)
 		return -ENOMEM;
 
diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
index cb2c316a2165..c83ed99c7d96 100644
--- a/arch/mips/alchemy/common/platform.c
+++ b/arch/mips/alchemy/common/platform.c
@@ -115,7 +115,7 @@ static void __init alchemy_setup_uarts(int ctype)
 	uartclk = clk_get_rate(clk);
 	clk_put(clk);
 
-	ports = kzalloc(s * (c + 1), GFP_KERNEL);
+	ports = kzalloc(array_size(s, (c + 1)), GFP_KERNEL);
 	if (!ports) {
 		printk(KERN_INFO "Alchemy: no memory for UART data\n");
 		return;
diff --git a/arch/mips/bmips/dma.c b/arch/mips/bmips/dma.c
index 04790f4e1805..52f630b9b289 100644
--- a/arch/mips/bmips/dma.c
+++ b/arch/mips/bmips/dma.c
@@ -94,7 +94,7 @@ static int __init bmips_init_dma_ranges(void)
 		goto out_bad;
 
 	/* add a dummy (zero) entry at the end as a sentinel */
-	bmips_dma_ranges = kzalloc(sizeof(struct bmips_dma_range) * (len + 1),
+	bmips_dma_ranges = kzalloc(array_size(sizeof(struct bmips_dma_range), (len + 1)),
 				   GFP_KERNEL);
 	if (!bmips_dma_ranges)
 		goto out_bad;
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index b44ec104a5a1..3d5dfa77c824 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -791,7 +791,7 @@ static int __init vdso_init(void)
 
 #ifdef CONFIG_VDSO32
 	/* Make sure pages are in the correct state */
-	vdso32_pagelist = kzalloc(sizeof(struct page *) * (vdso32_pages + 2),
+	vdso32_pagelist = kzalloc(array_size(sizeof(struct page *), (vdso32_pages + 2)),
 				  GFP_KERNEL);
 	BUG_ON(vdso32_pagelist == NULL);
 	for (i = 0; i < vdso32_pages; i++) {
@@ -805,7 +805,7 @@ static int __init vdso_init(void)
 #endif
 
 #ifdef CONFIG_PPC64
-	vdso64_pagelist = kzalloc(sizeof(struct page *) * (vdso64_pages + 2),
+	vdso64_pagelist = kzalloc(array_size(sizeof(struct page *), (vdso64_pages + 2)),
 				  GFP_KERNEL);
 	BUG_ON(vdso64_pagelist == NULL);
 	for (i = 0; i < vdso64_pages; i++) {
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 57a5029b4521..fcd62435e0d1 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -1316,7 +1316,7 @@ int numa_update_cpu_topology(bool cpus_locked)
 	if (!weight)
 		return 0;
 
-	updates = kzalloc(weight * (sizeof(*updates)), GFP_KERNEL);
+	updates = kzalloc(array_size(weight, (sizeof(*updates))), GFP_KERNEL);
 	if (!updates)
 		return 0;
 
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index a9636d8cba15..df5cb33130ea 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -566,7 +566,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 	if (!bpf_jit_enable)
 		return;
 
-	addrs = kzalloc((flen+1) * sizeof(*addrs), GFP_KERNEL);
+	addrs = kzalloc(array_size((flen + 1), sizeof(*addrs)), GFP_KERNEL);
 	if (addrs == NULL)
 		return;
 
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 0ef3d9580e98..356ffc113bf8 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -999,7 +999,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 	}
 
 	flen = fp->len;
-	addrs = kzalloc((flen+1) * sizeof(*addrs), GFP_KERNEL);
+	addrs = kzalloc(array_size((flen + 1), sizeof(*addrs)), GFP_KERNEL);
 	if (addrs == NULL) {
 		fp = org_fp;
 		goto out;
diff --git a/arch/powerpc/oprofile/cell/spu_profiler.c b/arch/powerpc/oprofile/cell/spu_profiler.c
index 5182f2936af2..872527c79282 100644
--- a/arch/powerpc/oprofile/cell/spu_profiler.c
+++ b/arch/powerpc/oprofile/cell/spu_profiler.c
@@ -210,8 +210,8 @@ int start_spu_profiling_cycles(unsigned int cycles_reset)
 	timer.function = profile_spus;
 
 	/* Allocate arrays for collecting SPU PC samples */
-	samples = kzalloc(SPUS_PER_NODE *
-			  TRACE_ARRAY_SIZE * sizeof(u32), GFP_KERNEL);
+	samples = kzalloc(array3_size(SPUS_PER_NODE, TRACE_ARRAY_SIZE, sizeof(u32)),
+			  GFP_KERNEL);
 
 	if (!samples)
 		return -ENOMEM;
diff --git a/arch/powerpc/platforms/4xx/msi.c b/arch/powerpc/platforms/4xx/msi.c
index 96aaae678928..0cc7a90a67c7 100644
--- a/arch/powerpc/platforms/4xx/msi.c
+++ b/arch/powerpc/platforms/4xx/msi.c
@@ -89,7 +89,8 @@ static int ppc4xx_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 	if (type == PCI_CAP_ID_MSIX)
 		pr_debug("ppc4xx msi: MSI-X untested, trying anyway.\n");
 
-	msi_data->msi_virqs = kmalloc((msi_irqs) * sizeof(int), GFP_KERNEL);
+	msi_data->msi_virqs = kmalloc(array_size((msi_irqs), sizeof(int)),
+				      GFP_KERNEL);
 	if (!msi_data->msi_virqs)
 		return -ENOMEM;
 
diff --git a/arch/powerpc/sysdev/mpic.c b/arch/powerpc/sysdev/mpic.c
index 0e9920e6ab9b..dac268bd2db6 100644
--- a/arch/powerpc/sysdev/mpic.c
+++ b/arch/powerpc/sysdev/mpic.c
@@ -1641,7 +1641,7 @@ void __init mpic_init(struct mpic *mpic)
 
 #ifdef CONFIG_PM
 	/* allocate memory to save mpic state */
-	mpic->save_data = kmalloc(mpic->num_sources * sizeof(*mpic->save_data),
+	mpic->save_data = kmalloc(array_size(mpic->num_sources, sizeof(*mpic->save_data)),
 				  GFP_KERNEL);
 	BUG_ON(mpic->save_data == NULL);
 #endif
diff --git a/arch/powerpc/sysdev/xive/native.c b/arch/powerpc/sysdev/xive/native.c
index b48454be5b98..8ee92bfcf9ea 100644
--- a/arch/powerpc/sysdev/xive/native.c
+++ b/arch/powerpc/sysdev/xive/native.c
@@ -489,7 +489,7 @@ static bool xive_parse_provisioning(struct device_node *np)
 	if (rc == 0)
 		return true;
 
-	xive_provision_chips = kzalloc(4 * xive_provision_chip_count,
+	xive_provision_chips = kzalloc(array_size(4, xive_provision_chip_count),
 				       GFP_KERNEL);
 	if (WARN_ON(!xive_provision_chips))
 		return false;
diff --git a/arch/s390/hypfs/hypfs_diag0c.c b/arch/s390/hypfs/hypfs_diag0c.c
index dce87f1bec94..4d02d768811d 100644
--- a/arch/s390/hypfs/hypfs_diag0c.c
+++ b/arch/s390/hypfs/hypfs_diag0c.c
@@ -49,7 +49,8 @@ static void *diag0c_store(unsigned int *count)
 
 	get_online_cpus();
 	cpu_count = num_online_cpus();
-	cpu_vec = kmalloc(sizeof(*cpu_vec) * num_possible_cpus(), GFP_KERNEL);
+	cpu_vec = kmalloc(array_size(sizeof(*cpu_vec), num_possible_cpus()),
+			  GFP_KERNEL);
 	if (!cpu_vec)
 		goto fail_put_online_cpus;
 	/* Note: Diag 0c needs 8 byte alignment and real storage */
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index f3a1c7c6824e..430670401eac 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -285,7 +285,7 @@ static int __init vdso_init(void)
 			 + PAGE_SIZE - 1) >> PAGE_SHIFT) + 1;
 
 	/* Make sure pages are in the correct state */
-	vdso32_pagelist = kzalloc(sizeof(struct page *) * (vdso32_pages + 1),
+	vdso32_pagelist = kzalloc(array_size(sizeof(struct page *), (vdso32_pages + 1)),
 				  GFP_KERNEL);
 	BUG_ON(vdso32_pagelist == NULL);
 	for (i = 0; i < vdso32_pages - 1; i++) {
@@ -303,7 +303,7 @@ static int __init vdso_init(void)
 			 + PAGE_SIZE - 1) >> PAGE_SHIFT) + 1;
 
 	/* Make sure pages are in the correct state */
-	vdso64_pagelist = kzalloc(sizeof(struct page *) * (vdso64_pages + 1),
+	vdso64_pagelist = kzalloc(array_size(sizeof(struct page *), (vdso64_pages + 1)),
 				  GFP_KERNEL);
 	BUG_ON(vdso64_pagelist == NULL);
 	for (i = 0; i < vdso64_pages - 1; i++) {
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 9ef8de63f28b..241442c731a7 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -571,7 +571,8 @@ SYSCALL_DEFINE5(utrap_install, utrap_entry_t, type,
 	}
 	if (!current_thread_info()->utraps) {
 		current_thread_info()->utraps =
-			kzalloc((UT_TRAP_INSTRUCTION_31+1)*sizeof(long), GFP_KERNEL);
+			kzalloc(array_size((UT_TRAP_INSTRUCTION_31 + 1), sizeof(long)),
+				GFP_KERNEL);
 		if (!current_thread_info()->utraps)
 			return -ENOMEM;
 		current_thread_info()->utraps[0] = 1;
@@ -581,7 +582,7 @@ SYSCALL_DEFINE5(utrap_install, utrap_entry_t, type,
 			unsigned long *p = current_thread_info()->utraps;
 
 			current_thread_info()->utraps =
-				kmalloc((UT_TRAP_INSTRUCTION_31+1)*sizeof(long),
+				kmalloc(array_size((UT_TRAP_INSTRUCTION_31 + 1), sizeof(long)),
 					GFP_KERNEL);
 			if (!current_thread_info()->utraps) {
 				current_thread_info()->utraps = p;
diff --git a/arch/um/drivers/vector_kern.c b/arch/um/drivers/vector_kern.c
index 02168fe25105..8d4abf6b7043 100644
--- a/arch/um/drivers/vector_kern.c
+++ b/arch/um/drivers/vector_kern.c
@@ -527,15 +527,11 @@ static struct vector_queue *create_queue(
 	result->max_iov_frags = num_extra_frags;
 	for (i = 0; i < max_size; i++) {
 		if (vp->header_size > 0)
-			iov = kmalloc(
-				sizeof(struct iovec) * (3 + num_extra_frags),
-				GFP_KERNEL
-			);
+			iov = kmalloc(array_size(sizeof(struct iovec), (3 + num_extra_frags)),
+				      GFP_KERNEL);
 		else
-			iov = kmalloc(
-				sizeof(struct iovec) * (2 + num_extra_frags),
-				GFP_KERNEL
-			);
+			iov = kmalloc(array_size(sizeof(struct iovec), (2 + num_extra_frags)),
+				      GFP_KERNEL);
 		if (iov == NULL)
 			goto out_fail;
 		mmsg_vector->msg_hdr.msg_iov = iov;
diff --git a/arch/unicore32/kernel/pm.c b/arch/unicore32/kernel/pm.c
index 784bc2db3b28..e7be768c9875 100644
--- a/arch/unicore32/kernel/pm.c
+++ b/arch/unicore32/kernel/pm.c
@@ -109,8 +109,8 @@ static int __init puv3_pm_init(void)
 		return -EINVAL;
 	}
 
-	sleep_save = kmalloc(puv3_cpu_pm_fns->save_count
-				* sizeof(unsigned long), GFP_KERNEL);
+	sleep_save = kmalloc(array_size(puv3_cpu_pm_fns->save_count, sizeof(unsigned long)),
+			     GFP_KERNEL);
 	if (!sleep_save) {
 		printk(KERN_ERR "failed to alloc memory for pm save\n");
 		return -ENOMEM;
diff --git a/arch/x86/events/amd/iommu.c b/arch/x86/events/amd/iommu.c
index 38b5d41b0c37..7f5346239593 100644
--- a/arch/x86/events/amd/iommu.c
+++ b/arch/x86/events/amd/iommu.c
@@ -387,7 +387,8 @@ static __init int _init_events_attrs(void)
 	while (amd_iommu_v2_event_descs[i].attr.attr.name)
 		i++;
 
-	attrs = kzalloc(sizeof(struct attribute **) * (i + 1), GFP_KERNEL);
+	attrs = kzalloc(array_size(sizeof(struct attribute **), (i + 1)),
+			GFP_KERNEL);
 	if (!attrs)
 		return -ENOMEM;
 
diff --git a/arch/x86/events/intel/uncore.c b/arch/x86/events/intel/uncore.c
index a7956fc7ca1d..8a8c70312cdc 100644
--- a/arch/x86/events/intel/uncore.c
+++ b/arch/x86/events/intel/uncore.c
@@ -810,7 +810,7 @@ static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
 	size_t size;
 	int i, j;
 
-	pmus = kzalloc(sizeof(*pmus) * type->num_boxes, GFP_KERNEL);
+	pmus = kzalloc(array_size(sizeof(*pmus), type->num_boxes), GFP_KERNEL);
 	if (!pmus)
 		return -ENOMEM;
 
diff --git a/arch/x86/kernel/cpu/mcheck/mce_amd.c b/arch/x86/kernel/cpu/mcheck/mce_amd.c
index f7666eef4a87..b003b9a9ff88 100644
--- a/arch/x86/kernel/cpu/mcheck/mce_amd.c
+++ b/arch/x86/kernel/cpu/mcheck/mce_amd.c
@@ -1386,7 +1386,7 @@ int mce_threshold_create_device(unsigned int cpu)
 	if (bp)
 		return 0;
 
-	bp = kzalloc(sizeof(struct threshold_bank *) * mca_cfg.banks,
+	bp = kzalloc(array_size(sizeof(struct threshold_bank *), mca_cfg.banks),
 		     GFP_KERNEL);
 	if (!bp)
 		return -ENOMEM;
diff --git a/arch/x86/kernel/hpet.c b/arch/x86/kernel/hpet.c
index 29345edb485a..2289a9319a57 100644
--- a/arch/x86/kernel/hpet.c
+++ b/arch/x86/kernel/hpet.c
@@ -967,7 +967,7 @@ int __init hpet_enable(void)
 #endif
 
 	cfg = hpet_readl(HPET_CFG);
-	hpet_boot_cfg = kmalloc((last + 2) * sizeof(*hpet_boot_cfg),
+	hpet_boot_cfg = kmalloc(array_size((last + 2), sizeof(*hpet_boot_cfg)),
 				GFP_KERNEL);
 	if (hpet_boot_cfg)
 		*hpet_boot_cfg = cfg;
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 1fc05e428aba..27e6fb051792 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -995,7 +995,8 @@ static int svm_cpu_init(int cpu)
 
 	if (svm_sev_enabled()) {
 		r = -ENOMEM;
-		sd->sev_vmcbs = kmalloc((max_sev_asid + 1) * sizeof(void *), GFP_KERNEL);
+		sd->sev_vmcbs = kmalloc(array_size((max_sev_asid + 1), sizeof(void *)),
+					GFP_KERNEL);
 		if (!sd->sev_vmcbs)
 			goto err_1;
 	}
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 3b706eb0bde9..be133bc82a41 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8608,7 +8608,7 @@ int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
 	} else
 		static_key_slow_inc(&kvm_no_apic_vcpu);
 
-	vcpu->arch.mce_banks = kzalloc(KVM_MAX_MCE_BANKS * sizeof(u64) * 4,
+	vcpu->arch.mce_banks = kzalloc(array3_size(KVM_MAX_MCE_BANKS, sizeof(u64), 4),
 				       GFP_KERNEL);
 	if (!vcpu->arch.mce_banks) {
 		r = -ENOMEM;
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 263c8453815e..e0523123adbc 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1212,7 +1212,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 		extra_pass = true;
 		goto skip_init_addrs;
 	}
-	addrs = kmalloc(prog->len * sizeof(*addrs), GFP_KERNEL);
+	addrs = kmalloc(array_size(prog->len, sizeof(*addrs)), GFP_KERNEL);
 	if (!addrs) {
 		prog = orig_prog;
 		goto out_addrs;
diff --git a/arch/x86/pci/xen.c b/arch/x86/pci/xen.c
index 9542a746dc50..70eef70f00e6 100644
--- a/arch/x86/pci/xen.c
+++ b/arch/x86/pci/xen.c
@@ -168,7 +168,7 @@ static int xen_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 	if (type == PCI_CAP_ID_MSI && nvec > 1)
 		return 1;
 
-	v = kzalloc(sizeof(int) * max(1, nvec), GFP_KERNEL);
+	v = kzalloc(array_size(sizeof(int), max(1, nvec)), GFP_KERNEL);
 	if (!v)
 		return -ENOMEM;
 
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 51fe7c8744ae..52bcfe7a9dc5 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -547,7 +547,7 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 	if (testmgr_alloc_buf(xoutbuf))
 		goto out_nooutbuf;
 
-	sg = kmalloc(sizeof(*sg) * 9 * 2, GFP_KERNEL);
+	sg = kmalloc(array3_size(sizeof(*sg), 9, 2), GFP_KERNEL);
 	if (!sg)
 		goto out_nosg;
 	sgout = &sg[9];
diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index af4a01c5037b..a7a9baf8a227 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -605,7 +605,8 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 		goto out_nooutbuf;
 
 	/* avoid "the frame size is larger than 1024 bytes" compiler warning */
-	sg = kmalloc(sizeof(*sg) * 8 * (diff_dst ? 4 : 2), GFP_KERNEL);
+	sg = kmalloc(array3_size(sizeof(*sg), 8, (diff_dst ? 4 : 2)),
+		     GFP_KERNEL);
 	if (!sg)
 		goto out_nosg;
 	sgout = &sg[16];
diff --git a/drivers/acpi/acpi_video.c b/drivers/acpi/acpi_video.c
index 2f2e737be0f8..4435e7f34ac6 100644
--- a/drivers/acpi/acpi_video.c
+++ b/drivers/acpi/acpi_video.c
@@ -832,8 +832,8 @@ int acpi_video_get_levels(struct acpi_device *device,
 	 * in order to account for buggy BIOS which don't export the first two
 	 * special levels (see below)
 	 */
-	br->levels = kmalloc((obj->package.count + ACPI_VIDEO_FIRST_LEVEL) *
-	                     sizeof(*br->levels), GFP_KERNEL);
+	br->levels = kmalloc(array_size((obj->package.count + ACPI_VIDEO_FIRST_LEVEL), sizeof(*br->levels)),
+			     GFP_KERNEL);
 	if (!br->levels) {
 		result = -ENOMEM;
 		goto out_free;
diff --git a/drivers/acpi/processor_perflib.c b/drivers/acpi/processor_perflib.c
index a651ab3490d8..59051c6b11e9 100644
--- a/drivers/acpi/processor_perflib.c
+++ b/drivers/acpi/processor_perflib.c
@@ -343,7 +343,7 @@ static int acpi_processor_get_performance_states(struct acpi_processor *pr)
 
 	pr->performance->state_count = pss->package.count;
 	pr->performance->states =
-	    kmalloc(sizeof(struct acpi_processor_px) * pss->package.count,
+	    kmalloc(array_size(sizeof(struct acpi_processor_px), pss->package.count),
 		    GFP_KERNEL);
 	if (!pr->performance->states) {
 		result = -ENOMEM;
diff --git a/drivers/acpi/processor_throttling.c b/drivers/acpi/processor_throttling.c
index 7f9aff4b8d62..40720a67eba9 100644
--- a/drivers/acpi/processor_throttling.c
+++ b/drivers/acpi/processor_throttling.c
@@ -534,7 +534,7 @@ static int acpi_processor_get_throttling_states(struct acpi_processor *pr)
 
 	pr->throttling.state_count = tss->package.count;
 	pr->throttling.states_tss =
-	    kmalloc(sizeof(struct acpi_processor_tx_tss) * tss->package.count,
+	    kmalloc(array_size(sizeof(struct acpi_processor_tx_tss), tss->package.count),
 		    GFP_KERNEL);
 	if (!pr->throttling.states_tss) {
 		result = -ENOMEM;
diff --git a/drivers/acpi/sysfs.c b/drivers/acpi/sysfs.c
index 4fc59c3bc673..63851d391278 100644
--- a/drivers/acpi/sysfs.c
+++ b/drivers/acpi/sysfs.c
@@ -857,12 +857,12 @@ void acpi_irq_stats_init(void)
 	num_gpes = acpi_current_gpe_count;
 	num_counters = num_gpes + ACPI_NUM_FIXED_EVENTS + NUM_COUNTERS_EXTRA;
 
-	all_attrs = kzalloc(sizeof(struct attribute *) * (num_counters + 1),
+	all_attrs = kzalloc(array_size(sizeof(struct attribute *), (num_counters + 1)),
 			    GFP_KERNEL);
 	if (all_attrs == NULL)
 		return;
 
-	all_counters = kzalloc(sizeof(struct event_counter) * (num_counters),
+	all_counters = kzalloc(array_size(sizeof(struct event_counter), (num_counters)),
 			       GFP_KERNEL);
 	if (all_counters == NULL)
 		goto fail;
@@ -871,7 +871,7 @@ void acpi_irq_stats_init(void)
 	if (ACPI_FAILURE(status))
 		goto fail;
 
-	counter_attrs = kzalloc(sizeof(struct kobj_attribute) * (num_counters),
+	counter_attrs = kzalloc(array_size(sizeof(struct kobj_attribute), (num_counters)),
 				GFP_KERNEL);
 	if (counter_attrs == NULL)
 		goto fail;
diff --git a/drivers/android/binder_alloc.c b/drivers/android/binder_alloc.c
index 5a426c877dfb..3dbb1bcbe555 100644
--- a/drivers/android/binder_alloc.c
+++ b/drivers/android/binder_alloc.c
@@ -692,8 +692,7 @@ int binder_alloc_mmap_handler(struct binder_alloc *alloc,
 		}
 	}
 #endif
-	alloc->pages = kzalloc(sizeof(alloc->pages[0]) *
-				   ((vma->vm_end - vma->vm_start) / PAGE_SIZE),
+	alloc->pages = kzalloc(array_size(sizeof(alloc->pages[0]), ((vma->vm_end - vma->vm_start) / PAGE_SIZE)),
 			       GFP_KERNEL);
 	if (alloc->pages == NULL) {
 		ret = -ENOMEM;
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 29f102dcfec4..c8d12ab7a57b 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -656,7 +656,7 @@ static int he_init_cs_block_rcm(struct he_dev *he_dev)
 	unsigned long long rate_cps;
 	int mult, buf, buf_limit = 4;
 
-	rategrid = kmalloc( sizeof(unsigned) * 16 * 16, GFP_KERNEL);
+	rategrid = kmalloc(array3_size(sizeof(unsigned), 16, 16), GFP_KERNEL);
 	if (!rategrid)
 		return -ENOMEM;
 
diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index be076606d30e..fa14b364e206 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1618,7 +1618,7 @@ static int rx_init(struct atm_dev *dev)
 	skb_queue_head_init(&iadev->rx_dma_q);  
 	iadev->rx_free_desc_qhead = NULL;   
 
-	iadev->rx_open = kzalloc(4 * iadev->num_vc, GFP_KERNEL);
+	iadev->rx_open = kzalloc(array_size(4, iadev->num_vc), GFP_KERNEL);
 	if (!iadev->rx_open) {
 		printk(KERN_ERR DEV_LABEL "itf %d couldn't get free page\n",
 		dev->number);  
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 0df1a1c80b00..ccfca3af5f86 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1291,7 +1291,8 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		card->using_dma = 1;
 		if (1) { /* All known FPGA versions so far */
 			card->dma_alignment = 3;
-			card->dma_bounce = kmalloc(card->nr_ports * BUF_SIZE, GFP_KERNEL);
+			card->dma_bounce = kmalloc(array_size(card->nr_ports, BUF_SIZE),
+						   GFP_KERNEL);
 			if (!card->dma_bounce) {
 				dev_warn(&card->dev->dev, "Failed to allocate DMA bounce buffers\n");
 				err = -ENOMEM;
diff --git a/drivers/block/DAC960.c b/drivers/block/DAC960.c
index f781eff7d23e..92f4b6d846dd 100644
--- a/drivers/block/DAC960.c
+++ b/drivers/block/DAC960.c
@@ -5724,8 +5724,8 @@ static bool DAC960_CheckStatusBuffer(DAC960_Controller_T *Controller,
       Controller->CombinedStatusBufferLength = NewStatusBufferLength;
       return true;
     }
-  NewStatusBuffer = kmalloc(2 * Controller->CombinedStatusBufferLength,
-			     GFP_ATOMIC);
+  NewStatusBuffer = kmalloc(array_size(2, Controller->CombinedStatusBufferLength),
+                            GFP_ATOMIC);
   if (NewStatusBuffer == NULL)
     {
       DAC960_Warning("Unable to expand Combined Status Buffer - Truncating\n",
diff --git a/drivers/block/amiflop.c b/drivers/block/amiflop.c
index 3aaf6af3ec23..4b55783d76ae 100644
--- a/drivers/block/amiflop.c
+++ b/drivers/block/amiflop.c
@@ -1727,7 +1727,7 @@ static int __init fd_probe_drives(void)
 		}
 
 		drives++;
-		if ((unit[drive].trackbuf = kmalloc(FLOPPY_MAX_SECTORS * 512, GFP_KERNEL)) == NULL) {
+		if ((unit[drive].trackbuf = kmalloc(array_size(FLOPPY_MAX_SECTORS, 512), GFP_KERNEL)) == NULL) {
 			printk("no mem for ");
 			unit[drive].type = &drive_types[num_dr_types - 1]; /* FD_NODRIVE */
 			drives--;
diff --git a/drivers/block/null_blk.c b/drivers/block/null_blk.c
index df02a9211ae3..bd285a55d765 100644
--- a/drivers/block/null_blk.c
+++ b/drivers/block/null_blk.c
@@ -1573,7 +1573,8 @@ static int setup_commands(struct nullb_queue *nq)
 	struct nullb_cmd *cmd;
 	int i, tag_size;
 
-	nq->cmds = kzalloc(nq->queue_depth * sizeof(*cmd), GFP_KERNEL);
+	nq->cmds = kzalloc(array_size(nq->queue_depth, sizeof(*cmd)),
+			   GFP_KERNEL);
 	if (!nq->cmds)
 		return -ENOMEM;
 
@@ -1597,8 +1598,8 @@ static int setup_commands(struct nullb_queue *nq)
 
 static int setup_queues(struct nullb *nullb)
 {
-	nullb->queues = kzalloc(nullb->dev->submit_queues *
-		sizeof(struct nullb_queue), GFP_KERNEL);
+	nullb->queues = kzalloc(array_size(nullb->dev->submit_queues, sizeof(struct nullb_queue)),
+				GFP_KERNEL);
 	if (!nullb->queues)
 		return -ENOMEM;
 
diff --git a/drivers/block/rsxx/core.c b/drivers/block/rsxx/core.c
index 34997df132e2..2b0e5277fb46 100644
--- a/drivers/block/rsxx/core.c
+++ b/drivers/block/rsxx/core.c
@@ -873,7 +873,8 @@ static int rsxx_pci_probe(struct pci_dev *dev,
 		dev_info(CARD_TO_DEV(card),
 			"Failed reading the number of DMA targets\n");
 
-	card->ctrl = kzalloc(card->n_targets * sizeof(*card->ctrl), GFP_KERNEL);
+	card->ctrl = kzalloc(array_size(card->n_targets, sizeof(*card->ctrl)),
+			     GFP_KERNEL);
 	if (!card->ctrl) {
 		st = -ENOMEM;
 		goto failed_dma_setup;
diff --git a/drivers/block/rsxx/dma.c b/drivers/block/rsxx/dma.c
index beaccf197a5a..42e914fdd4de 100644
--- a/drivers/block/rsxx/dma.c
+++ b/drivers/block/rsxx/dma.c
@@ -1038,7 +1038,7 @@ int rsxx_eeh_save_issued_dmas(struct rsxx_cardinfo *card)
 	struct rsxx_dma *dma;
 	struct list_head *issued_dmas;
 
-	issued_dmas = kzalloc(sizeof(*issued_dmas) * card->n_targets,
+	issued_dmas = kzalloc(array_size(sizeof(*issued_dmas), card->n_targets),
 			      GFP_KERNEL);
 	if (!issued_dmas)
 		return -ENOMEM;
diff --git a/drivers/block/xen-blkback/xenbus.c b/drivers/block/xen-blkback/xenbus.c
index 21c1be1eb226..e2af6ad48c88 100644
--- a/drivers/block/xen-blkback/xenbus.c
+++ b/drivers/block/xen-blkback/xenbus.c
@@ -139,7 +139,8 @@ static int xen_blkif_alloc_rings(struct xen_blkif *blkif)
 {
 	unsigned int r;
 
-	blkif->rings = kzalloc(blkif->nr_rings * sizeof(struct xen_blkif_ring), GFP_KERNEL);
+	blkif->rings = kzalloc(array_size(blkif->nr_rings, sizeof(struct xen_blkif_ring)),
+			       GFP_KERNEL);
 	if (!blkif->rings)
 		return -ENOMEM;
 
diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index c6469b956520..e955f092534d 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -1907,7 +1907,8 @@ static int negotiate_mq(struct blkfront_info *info)
 	if (!info->nr_rings)
 		info->nr_rings = 1;
 
-	info->rinfo = kzalloc(sizeof(struct blkfront_ring_info) * info->nr_rings, GFP_KERNEL);
+	info->rinfo = kzalloc(array_size(sizeof(struct blkfront_ring_info), info->nr_rings),
+			      GFP_KERNEL);
 	if (!info->rinfo) {
 		xenbus_dev_fatal(info->xbdev, -ENOMEM, "allocating ring_info structure");
 		return -ENOMEM;
@@ -2222,10 +2223,8 @@ static int blkfront_setup_indirect(struct blkfront_ring_info *rinfo)
 		rinfo->shadow[i].sg = kzalloc(array_size(psegs, sizeof(rinfo->shadow[i].sg[0])),
 					      GFP_NOIO);
 		if (info->max_indirect_segments)
-			rinfo->shadow[i].indirect_grants = kzalloc(
-				sizeof(rinfo->shadow[i].indirect_grants[0]) *
-				INDIRECT_GREFS(grants),
-				GFP_NOIO);
+			rinfo->shadow[i].indirect_grants = kzalloc(array_size(sizeof(rinfo->shadow[i].indirect_grants[0]), INDIRECT_GREFS(grants)),
+								   GFP_NOIO);
 		if ((rinfo->shadow[i].grants_used == NULL) ||
 			(rinfo->shadow[i].sg == NULL) ||
 		     (info->max_indirect_segments &&
diff --git a/drivers/block/z2ram.c b/drivers/block/z2ram.c
index 8f9130ab5887..f7dc10f80c74 100644
--- a/drivers/block/z2ram.c
+++ b/drivers/block/z2ram.c
@@ -197,8 +197,8 @@ static int z2_open(struct block_device *bdev, fmode_t mode)
 		vaddr = (unsigned long)z_remap_nocache_nonser(paddr, size);
 #endif
 		z2ram_map = 
-			kmalloc((size/Z2RAM_CHUNKSIZE)*sizeof(z2ram_map[0]),
-				GFP_KERNEL);
+			kmalloc(array_size((size / Z2RAM_CHUNKSIZE), sizeof(z2ram_map[0])),
+                                GFP_KERNEL);
 		if ( z2ram_map == NULL )
 		{
 		    printk( KERN_ERR DEVICE_NAME
diff --git a/drivers/char/agp/amd-k7-agp.c b/drivers/char/agp/amd-k7-agp.c
index b450544dcaf0..a5fc089d47ca 100644
--- a/drivers/char/agp/amd-k7-agp.c
+++ b/drivers/char/agp/amd-k7-agp.c
@@ -85,7 +85,8 @@ static int amd_create_gatt_pages(int nr_tables)
 	int retval = 0;
 	int i;
 
-	tables = kzalloc((nr_tables + 1) * sizeof(struct amd_page_map *),GFP_KERNEL);
+	tables = kzalloc(array_size((nr_tables + 1), sizeof(struct amd_page_map *)),
+			 GFP_KERNEL);
 	if (tables == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/char/agp/ati-agp.c b/drivers/char/agp/ati-agp.c
index 88b4cbee4dac..38427afc096b 100644
--- a/drivers/char/agp/ati-agp.c
+++ b/drivers/char/agp/ati-agp.c
@@ -108,7 +108,8 @@ static int ati_create_gatt_pages(int nr_tables)
 	int retval = 0;
 	int i;
 
-	tables = kzalloc((nr_tables + 1) * sizeof(struct ati_page_map *),GFP_KERNEL);
+	tables = kzalloc(array_size((nr_tables + 1), sizeof(struct ati_page_map *)),
+			 GFP_KERNEL);
 	if (tables == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/char/agp/compat_ioctl.c b/drivers/char/agp/compat_ioctl.c
index 2053f70ef66b..05223a10f41d 100644
--- a/drivers/char/agp/compat_ioctl.c
+++ b/drivers/char/agp/compat_ioctl.c
@@ -98,11 +98,13 @@ static int compat_agpioc_reserve_wrap(struct agp_file_private *priv, void __user
 		if (ureserve.seg_count >= 16384)
 			return -EINVAL;
 
-		usegment = kmalloc(sizeof(*usegment) * ureserve.seg_count, GFP_KERNEL);
+		usegment = kmalloc(array_size(sizeof(*usegment), ureserve.seg_count),
+				   GFP_KERNEL);
 		if (!usegment)
 			return -ENOMEM;
 
-		ksegment = kmalloc(sizeof(*ksegment) * kreserve.seg_count, GFP_KERNEL);
+		ksegment = kmalloc(array_size(sizeof(*ksegment), kreserve.seg_count),
+				   GFP_KERNEL);
 		if (!ksegment) {
 			kfree(usegment);
 			return -ENOMEM;
diff --git a/drivers/char/agp/sworks-agp.c b/drivers/char/agp/sworks-agp.c
index 4dbdd3bc9bb8..1eac07936a93 100644
--- a/drivers/char/agp/sworks-agp.c
+++ b/drivers/char/agp/sworks-agp.c
@@ -96,7 +96,7 @@ static int serverworks_create_gatt_pages(int nr_tables)
 	int retval = 0;
 	int i;
 
-	tables = kzalloc((nr_tables + 1) * sizeof(struct serverworks_page_map *),
+	tables = kzalloc(array_size((nr_tables + 1), sizeof(struct serverworks_page_map *)),
 			 GFP_KERNEL);
 	if (tables == NULL)
 		return -ENOMEM;
diff --git a/drivers/char/agp/uninorth-agp.c b/drivers/char/agp/uninorth-agp.c
index c381c8e396fc..f6511937a77d 100644
--- a/drivers/char/agp/uninorth-agp.c
+++ b/drivers/char/agp/uninorth-agp.c
@@ -402,7 +402,8 @@ static int uninorth_create_gatt_table(struct agp_bridge_data *bridge)
 	if (table == NULL)
 		return -ENOMEM;
 
-	uninorth_priv.pages_arr = kmalloc((1 << page_order) * sizeof(struct page*), GFP_KERNEL);
+	uninorth_priv.pages_arr = kmalloc(array_size((1 << page_order), sizeof(struct page *)),
+					  GFP_KERNEL);
 	if (uninorth_priv.pages_arr == NULL)
 		goto enomem;
 
diff --git a/drivers/char/ipmi/ipmi_ssif.c b/drivers/char/ipmi/ipmi_ssif.c
index 35a82f4bfd78..0d1932f5a5a5 100644
--- a/drivers/char/ipmi/ipmi_ssif.c
+++ b/drivers/char/ipmi/ipmi_ssif.c
@@ -1874,7 +1874,8 @@ static unsigned short *ssif_address_list(void)
 	list_for_each_entry(info, &ssif_infos, link)
 		count++;
 
-	address_list = kzalloc(sizeof(*address_list) * (count + 1), GFP_KERNEL);
+	address_list = kzalloc(array_size(sizeof(*address_list), (count + 1)),
+			       GFP_KERNEL);
 	if (!address_list)
 		return NULL;
 
diff --git a/drivers/clk/st/clkgen-pll.c b/drivers/clk/st/clkgen-pll.c
index 25bda48a5d35..78d366344882 100644
--- a/drivers/clk/st/clkgen-pll.c
+++ b/drivers/clk/st/clkgen-pll.c
@@ -738,7 +738,7 @@ static void __init clkgen_c32_pll_setup(struct device_node *np,
 		return;
 
 	clk_data->clk_num = num_odfs;
-	clk_data->clks = kzalloc(clk_data->clk_num * sizeof(struct clk *),
+	clk_data->clks = kzalloc(array_size(clk_data->clk_num, sizeof(struct clk *)),
 				 GFP_KERNEL);
 
 	if (!clk_data->clks)
diff --git a/drivers/clk/sunxi/clk-usb.c b/drivers/clk/sunxi/clk-usb.c
index fe0c3d169377..513d16c2e4c5 100644
--- a/drivers/clk/sunxi/clk-usb.c
+++ b/drivers/clk/sunxi/clk-usb.c
@@ -122,7 +122,8 @@ static void __init sunxi_usb_clk_setup(struct device_node *node,
 	if (!clk_data)
 		return;
 
-	clk_data->clks = kzalloc((qty+1) * sizeof(struct clk *), GFP_KERNEL);
+	clk_data->clks = kzalloc(array_size((qty + 1), sizeof(struct clk *)),
+				 GFP_KERNEL);
 	if (!clk_data->clks) {
 		kfree(clk_data);
 		return;
diff --git a/drivers/clk/tegra/clk.c b/drivers/clk/tegra/clk.c
index 2115110745c5..0502647ff921 100644
--- a/drivers/clk/tegra/clk.c
+++ b/drivers/clk/tegra/clk.c
@@ -216,8 +216,8 @@ struct clk ** __init tegra_clk_init(void __iomem *regs, int num, int banks)
 	if (WARN_ON(banks > ARRAY_SIZE(periph_regs)))
 		return NULL;
 
-	periph_clk_enb_refcnt = kzalloc(32 * banks *
-				sizeof(*periph_clk_enb_refcnt), GFP_KERNEL);
+	periph_clk_enb_refcnt = kzalloc(array3_size(32, banks, sizeof(*periph_clk_enb_refcnt)),
+					GFP_KERNEL);
 	if (!periph_clk_enb_refcnt)
 		return NULL;
 
diff --git a/drivers/clk/ti/apll.c b/drivers/clk/ti/apll.c
index 9498e9363b57..999e90a1e9aa 100644
--- a/drivers/clk/ti/apll.c
+++ b/drivers/clk/ti/apll.c
@@ -206,7 +206,8 @@ static void __init of_dra7_apll_setup(struct device_node *node)
 		goto cleanup;
 	}
 
-	parent_names = kzalloc(sizeof(char *) * init->num_parents, GFP_KERNEL);
+	parent_names = kzalloc(array_size(sizeof(char *), init->num_parents),
+			       GFP_KERNEL);
 	if (!parent_names)
 		goto cleanup;
 
diff --git a/drivers/clk/ti/divider.c b/drivers/clk/ti/divider.c
index aaa277dd6d99..e06cc4074595 100644
--- a/drivers/clk/ti/divider.c
+++ b/drivers/clk/ti/divider.c
@@ -366,7 +366,7 @@ int ti_clk_parse_divider_data(int *div_table, int num_dividers, int max_div,
 
 	num_dividers = i;
 
-	tmp = kzalloc(sizeof(*tmp) * (valid_div + 1), GFP_KERNEL);
+	tmp = kzalloc(array_size(sizeof(*tmp), (valid_div + 1)), GFP_KERNEL);
 	if (!tmp)
 		return -ENOMEM;
 
@@ -496,7 +496,8 @@ __init ti_clk_get_div_table(struct device_node *node)
 		return ERR_PTR(-EINVAL);
 	}
 
-	table = kzalloc(sizeof(*table) * (valid_div + 1), GFP_KERNEL);
+	table = kzalloc(array_size(sizeof(*table), (valid_div + 1)),
+			GFP_KERNEL);
 
 	if (!table)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/clk/ti/dpll.c b/drivers/clk/ti/dpll.c
index 7d33ca9042cb..357b136525d4 100644
--- a/drivers/clk/ti/dpll.c
+++ b/drivers/clk/ti/dpll.c
@@ -309,7 +309,8 @@ static void __init of_ti_dpll_setup(struct device_node *node,
 		goto cleanup;
 	}
 
-	parent_names = kzalloc(sizeof(char *) * init->num_parents, GFP_KERNEL);
+	parent_names = kzalloc(array_size(sizeof(char *), init->num_parents),
+			       GFP_KERNEL);
 	if (!parent_names)
 		goto cleanup;
 
diff --git a/drivers/clocksource/sh_cmt.c b/drivers/clocksource/sh_cmt.c
index 70b3cf8e23d0..6a015d2e3a72 100644
--- a/drivers/clocksource/sh_cmt.c
+++ b/drivers/clocksource/sh_cmt.c
@@ -1000,7 +1000,7 @@ static int sh_cmt_setup(struct sh_cmt_device *cmt, struct platform_device *pdev)
 
 	/* Allocate and setup the channels. */
 	cmt->num_channels = hweight8(cmt->hw_channels);
-	cmt->channels = kzalloc(cmt->num_channels * sizeof(*cmt->channels),
+	cmt->channels = kzalloc(array_size(cmt->num_channels, sizeof(*cmt->channels)),
 				GFP_KERNEL);
 	if (cmt->channels == NULL) {
 		ret = -ENOMEM;
diff --git a/drivers/clocksource/sh_mtu2.c b/drivers/clocksource/sh_mtu2.c
index 53aa7e92a7d7..06229dd18d82 100644
--- a/drivers/clocksource/sh_mtu2.c
+++ b/drivers/clocksource/sh_mtu2.c
@@ -418,7 +418,7 @@ static int sh_mtu2_setup(struct sh_mtu2_device *mtu,
 	/* Allocate and setup the channels. */
 	mtu->num_channels = 3;
 
-	mtu->channels = kzalloc(sizeof(*mtu->channels) * mtu->num_channels,
+	mtu->channels = kzalloc(array_size(sizeof(*mtu->channels), mtu->num_channels),
 				GFP_KERNEL);
 	if (mtu->channels == NULL) {
 		ret = -ENOMEM;
diff --git a/drivers/clocksource/sh_tmu.c b/drivers/clocksource/sh_tmu.c
index 31d881621e41..cf3039867d3f 100644
--- a/drivers/clocksource/sh_tmu.c
+++ b/drivers/clocksource/sh_tmu.c
@@ -569,7 +569,7 @@ static int sh_tmu_setup(struct sh_tmu_device *tmu, struct platform_device *pdev)
 	}
 
 	/* Allocate and setup the channels. */
-	tmu->channels = kzalloc(sizeof(*tmu->channels) * tmu->num_channels,
+	tmu->channels = kzalloc(array_size(sizeof(*tmu->channels), tmu->num_channels),
 				GFP_KERNEL);
 	if (tmu->channels == NULL) {
 		ret = -ENOMEM;
diff --git a/drivers/cpufreq/acpi-cpufreq.c b/drivers/cpufreq/acpi-cpufreq.c
index 9449657d72f0..f9cb7947f417 100644
--- a/drivers/cpufreq/acpi-cpufreq.c
+++ b/drivers/cpufreq/acpi-cpufreq.c
@@ -759,8 +759,8 @@ static int acpi_cpufreq_cpu_init(struct cpufreq_policy *policy)
 		goto err_unreg;
 	}
 
-	freq_table = kzalloc(sizeof(*freq_table) *
-		    (perf->state_count+1), GFP_KERNEL);
+	freq_table = kzalloc(array_size(sizeof(*freq_table), (perf->state_count + 1)),
+			     GFP_KERNEL);
 	if (!freq_table) {
 		result = -ENOMEM;
 		goto err_unreg;
diff --git a/drivers/cpufreq/bmips-cpufreq.c b/drivers/cpufreq/bmips-cpufreq.c
index 1653151b77df..c626c7e35c79 100644
--- a/drivers/cpufreq/bmips-cpufreq.c
+++ b/drivers/cpufreq/bmips-cpufreq.c
@@ -71,7 +71,8 @@ bmips_cpufreq_get_freq_table(const struct cpufreq_policy *policy)
 
 	cpu_freq = htp_freq_to_cpu_freq(priv->clk_mult);
 
-	table = kmalloc((priv->max_freqs + 1) * sizeof(*table), GFP_KERNEL);
+	table = kmalloc(array_size((priv->max_freqs + 1), sizeof(*table)),
+			GFP_KERNEL);
 	if (!table)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/cpufreq/cppc_cpufreq.c b/drivers/cpufreq/cppc_cpufreq.c
index b15115a48775..4596e17faf6b 100644
--- a/drivers/cpufreq/cppc_cpufreq.c
+++ b/drivers/cpufreq/cppc_cpufreq.c
@@ -257,7 +257,8 @@ static int __init cppc_cpufreq_init(void)
 	if (acpi_disabled)
 		return -ENODEV;
 
-	all_cpu_data = kzalloc(sizeof(void *) * num_possible_cpus(), GFP_KERNEL);
+	all_cpu_data = kzalloc(array_size(sizeof(void *), num_possible_cpus()),
+			       GFP_KERNEL);
 	if (!all_cpu_data)
 		return -ENOMEM;
 
diff --git a/drivers/cpufreq/ia64-acpi-cpufreq.c b/drivers/cpufreq/ia64-acpi-cpufreq.c
index 7974a2fdb760..82c7b6cf1b1b 100644
--- a/drivers/cpufreq/ia64-acpi-cpufreq.c
+++ b/drivers/cpufreq/ia64-acpi-cpufreq.c
@@ -241,9 +241,8 @@ acpi_cpufreq_cpu_init (
 	}
 
 	/* alloc freq_table */
-	freq_table = kzalloc(sizeof(*freq_table) *
-	                           (data->acpi_data.state_count + 1),
-	                           GFP_KERNEL);
+	freq_table = kzalloc(array_size(sizeof(*freq_table), (data->acpi_data.state_count + 1)),
+			     GFP_KERNEL);
 	if (!freq_table) {
 		result = -ENOMEM;
 		goto err_unreg;
diff --git a/drivers/cpufreq/longhaul.c b/drivers/cpufreq/longhaul.c
index 61a4c5b08219..5baffe147876 100644
--- a/drivers/cpufreq/longhaul.c
+++ b/drivers/cpufreq/longhaul.c
@@ -474,8 +474,8 @@ static int longhaul_get_ranges(void)
 		return -EINVAL;
 	}
 
-	longhaul_table = kzalloc((numscales + 1) * sizeof(*longhaul_table),
-			GFP_KERNEL);
+	longhaul_table = kzalloc(array_size((numscales + 1), sizeof(*longhaul_table)),
+				 GFP_KERNEL);
 	if (!longhaul_table)
 		return -ENOMEM;
 
diff --git a/drivers/cpufreq/pxa3xx-cpufreq.c b/drivers/cpufreq/pxa3xx-cpufreq.c
index 7acc7fa4536d..3c5ececd350a 100644
--- a/drivers/cpufreq/pxa3xx-cpufreq.c
+++ b/drivers/cpufreq/pxa3xx-cpufreq.c
@@ -93,7 +93,7 @@ static int setup_freqs_table(struct cpufreq_policy *policy,
 	struct cpufreq_frequency_table *table;
 	int i;
 
-	table = kzalloc((num + 1) * sizeof(*table), GFP_KERNEL);
+	table = kzalloc(array_size((num + 1), sizeof(*table)), GFP_KERNEL);
 	if (table == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/cpufreq/sfi-cpufreq.c b/drivers/cpufreq/sfi-cpufreq.c
index 9767afe05da2..08a51615a2c5 100644
--- a/drivers/cpufreq/sfi-cpufreq.c
+++ b/drivers/cpufreq/sfi-cpufreq.c
@@ -95,8 +95,8 @@ static int __init sfi_cpufreq_init(void)
 	if (ret)
 		return ret;
 
-	freq_table = kzalloc(sizeof(*freq_table) *
-			(num_freq_table_entries + 1), GFP_KERNEL);
+	freq_table = kzalloc(array_size(sizeof(*freq_table), (num_freq_table_entries + 1)),
+			     GFP_KERNEL);
 	if (!freq_table) {
 		ret = -ENOMEM;
 		goto err_free_array;
diff --git a/drivers/cpufreq/spear-cpufreq.c b/drivers/cpufreq/spear-cpufreq.c
index 195f27f9c1cb..b6023a74fa51 100644
--- a/drivers/cpufreq/spear-cpufreq.c
+++ b/drivers/cpufreq/spear-cpufreq.c
@@ -195,7 +195,8 @@ static int spear_cpufreq_probe(struct platform_device *pdev)
 	cnt = prop->length / sizeof(u32);
 	val = prop->value;
 
-	freq_tbl = kzalloc(sizeof(*freq_tbl) * (cnt + 1), GFP_KERNEL);
+	freq_tbl = kzalloc(array_size(sizeof(*freq_tbl), (cnt + 1)),
+			   GFP_KERNEL);
 	if (!freq_tbl) {
 		ret = -ENOMEM;
 		goto out_put_node;
diff --git a/drivers/crypto/amcc/crypto4xx_core.c b/drivers/crypto/amcc/crypto4xx_core.c
index db1ce09759a5..b45f4755d1c3 100644
--- a/drivers/crypto/amcc/crypto4xx_core.c
+++ b/drivers/crypto/amcc/crypto4xx_core.c
@@ -140,11 +140,11 @@ static void crypto4xx_hw_init(struct crypto4xx_device *dev)
 
 int crypto4xx_alloc_sa(struct crypto4xx_ctx *ctx, u32 size)
 {
-	ctx->sa_in = kzalloc(size * 4, GFP_ATOMIC);
+	ctx->sa_in = kzalloc(array_size(size, 4), GFP_ATOMIC);
 	if (ctx->sa_in == NULL)
 		return -ENOMEM;
 
-	ctx->sa_out = kzalloc(size * 4, GFP_ATOMIC);
+	ctx->sa_out = kzalloc(array_size(size, 4), GFP_ATOMIC);
 	if (ctx->sa_out == NULL) {
 		kfree(ctx->sa_in);
 		ctx->sa_in = NULL;
diff --git a/drivers/crypto/caam/ctrl.c b/drivers/crypto/caam/ctrl.c
index e4cc636e1104..b6531f55d3f4 100644
--- a/drivers/crypto/caam/ctrl.c
+++ b/drivers/crypto/caam/ctrl.c
@@ -201,7 +201,7 @@ static int instantiate_rng(struct device *ctrldev, int state_handle_mask,
 	int ret = 0, sh_idx;
 
 	ctrl = (struct caam_ctrl __iomem *)ctrlpriv->ctrl;
-	desc = kmalloc(CAAM_CMD_SZ * 7, GFP_KERNEL);
+	desc = kmalloc(array_size(CAAM_CMD_SZ, 7), GFP_KERNEL);
 	if (!desc)
 		return -ENOMEM;
 
@@ -266,7 +266,7 @@ static int deinstantiate_rng(struct device *ctrldev, int state_handle_mask)
 	u32 *desc, status;
 	int sh_idx, ret = 0;
 
-	desc = kmalloc(CAAM_CMD_SZ * 3, GFP_KERNEL);
+	desc = kmalloc(array_size(CAAM_CMD_SZ, 3), GFP_KERNEL);
 	if (!desc)
 		return -ENOMEM;
 
diff --git a/drivers/crypto/inside-secure/safexcel_hash.c b/drivers/crypto/inside-secure/safexcel_hash.c
index 317b9e480312..0e6eaef50b71 100644
--- a/drivers/crypto/inside-secure/safexcel_hash.c
+++ b/drivers/crypto/inside-secure/safexcel_hash.c
@@ -935,7 +935,7 @@ static int safexcel_hmac_setkey(const char *alg, const u8 *key,
 	crypto_ahash_clear_flags(tfm, ~0);
 	blocksize = crypto_tfm_alg_blocksize(crypto_ahash_tfm(tfm));
 
-	ipad = kzalloc(2 * blocksize, GFP_KERNEL);
+	ipad = kzalloc(array_size(2, blocksize), GFP_KERNEL);
 	if (!ipad) {
 		ret = -ENOMEM;
 		goto free_request;
diff --git a/drivers/crypto/marvell/hash.c b/drivers/crypto/marvell/hash.c
index e61b08566093..1878e574d142 100644
--- a/drivers/crypto/marvell/hash.c
+++ b/drivers/crypto/marvell/hash.c
@@ -1198,7 +1198,7 @@ static int mv_cesa_ahmac_setkey(const char *hash_alg_name,
 
 	blocksize = crypto_tfm_alg_blocksize(crypto_ahash_tfm(tfm));
 
-	ipad = kzalloc(2 * blocksize, GFP_KERNEL);
+	ipad = kzalloc(array_size(2, blocksize), GFP_KERNEL);
 	if (!ipad) {
 		ret = -ENOMEM;
 		goto free_req;
diff --git a/drivers/crypto/qat/qat_common/qat_uclo.c b/drivers/crypto/qat/qat_common/qat_uclo.c
index 98d22c2096e3..775052106420 100644
--- a/drivers/crypto/qat/qat_common/qat_uclo.c
+++ b/drivers/crypto/qat/qat_common/qat_uclo.c
@@ -1162,8 +1162,8 @@ static int qat_uclo_map_suof(struct icp_qat_fw_loader_handle *handle,
 	suof_handle->img_table.num_simgs = suof_ptr->num_chunks - 1;
 
 	if (suof_handle->img_table.num_simgs != 0) {
-		suof_img_hdr = kzalloc(suof_handle->img_table.num_simgs *
-				       sizeof(img_header), GFP_KERNEL);
+		suof_img_hdr = kzalloc(array_size(suof_handle->img_table.num_simgs, sizeof(img_header)),
+				       GFP_KERNEL);
 		if (!suof_img_hdr)
 			return -ENOMEM;
 		suof_handle->img_table.simg_hdr = suof_img_hdr;
diff --git a/drivers/crypto/stm32/stm32-hash.c b/drivers/crypto/stm32/stm32-hash.c
index 981e45692695..e3d8c40b126d 100644
--- a/drivers/crypto/stm32/stm32-hash.c
+++ b/drivers/crypto/stm32/stm32-hash.c
@@ -970,7 +970,7 @@ static int stm32_hash_export(struct ahash_request *req, void *out)
 	while (!(stm32_hash_read(hdev, HASH_SR) & HASH_SR_DATA_INPUT_READY))
 		cpu_relax();
 
-	rctx->hw_context = kmalloc(sizeof(u32) * (3 + HASH_CSR_REGISTER_NUMBER),
+	rctx->hw_context = kmalloc(array_size(sizeof(u32), (3 + HASH_CSR_REGISTER_NUMBER)),
 				   GFP_KERNEL);
 
 	preg = rctx->hw_context;
diff --git a/drivers/dma/coh901318.c b/drivers/dma/coh901318.c
index da74fd74636b..8d25ce0fa65c 100644
--- a/drivers/dma/coh901318.c
+++ b/drivers/dma/coh901318.c
@@ -1345,7 +1345,7 @@ static ssize_t coh901318_debugfs_read(struct file *file, char __user *buf,
 	int ret;
 	int i;
 
-	dev_buf = kmalloc(4*1024, GFP_KERNEL);
+	dev_buf = kmalloc(array_size(4, 1024), GFP_KERNEL);
 	if (dev_buf == NULL)
 		return -ENOMEM;
 	tmp = dev_buf;
diff --git a/drivers/dma/pl330.c b/drivers/dma/pl330.c
index 96238a30e804..93b547f7829e 100644
--- a/drivers/dma/pl330.c
+++ b/drivers/dma/pl330.c
@@ -1763,8 +1763,8 @@ static int dmac_alloc_threads(struct pl330_dmac *pl330)
 	int i;
 
 	/* Allocate 1 Manager and 'chans' Channel threads */
-	pl330->channels = kzalloc((1 + chans) * sizeof(*thrd),
-					GFP_KERNEL);
+	pl330->channels = kzalloc(array_size((1 + chans), sizeof(*thrd)),
+				  GFP_KERNEL);
 	if (!pl330->channels)
 		return -ENOMEM;
 
diff --git a/drivers/dma/sh/shdma-base.c b/drivers/dma/sh/shdma-base.c
index 12fa48e380cf..2ced781731e1 100644
--- a/drivers/dma/sh/shdma-base.c
+++ b/drivers/dma/sh/shdma-base.c
@@ -1045,8 +1045,8 @@ EXPORT_SYMBOL(shdma_cleanup);
 
 static int __init shdma_enter(void)
 {
-	shdma_slave_used = kzalloc(DIV_ROUND_UP(slave_num, BITS_PER_LONG) *
-				    sizeof(long), GFP_KERNEL);
+	shdma_slave_used = kzalloc(array_size(DIV_ROUND_UP(slave_num, BITS_PER_LONG), sizeof(long)),
+				   GFP_KERNEL);
 	if (!shdma_slave_used)
 		return -ENOMEM;
 	return 0;
diff --git a/drivers/edac/amd64_edac.c b/drivers/edac/amd64_edac.c
index 329cb96f886f..5f87a26356fb 100644
--- a/drivers/edac/amd64_edac.c
+++ b/drivers/edac/amd64_edac.c
@@ -3451,7 +3451,8 @@ static int __init amd64_edac_init(void)
 	opstate_init();
 
 	err = -ENOMEM;
-	ecc_stngs = kzalloc(amd_nb_num() * sizeof(ecc_stngs[0]), GFP_KERNEL);
+	ecc_stngs = kzalloc(array_size(amd_nb_num(), sizeof(ecc_stngs[0])),
+			    GFP_KERNEL);
 	if (!ecc_stngs)
 		goto err_free;
 
diff --git a/drivers/edac/i7core_edac.c b/drivers/edac/i7core_edac.c
index 8c5540160a23..cbf0c0a650b7 100644
--- a/drivers/edac/i7core_edac.c
+++ b/drivers/edac/i7core_edac.c
@@ -461,7 +461,7 @@ static struct i7core_dev *alloc_i7core_dev(u8 socket,
 	if (!i7core_dev)
 		return NULL;
 
-	i7core_dev->pdev = kzalloc(sizeof(*i7core_dev->pdev) * table->n_devs,
+	i7core_dev->pdev = kzalloc(array_size(sizeof(*i7core_dev->pdev), table->n_devs),
 				   GFP_KERNEL);
 	if (!i7core_dev->pdev) {
 		kfree(i7core_dev);
diff --git a/drivers/extcon/extcon.c b/drivers/extcon/extcon.c
index 498b2d29d52f..929c20b81175 100644
--- a/drivers/extcon/extcon.c
+++ b/drivers/extcon/extcon.c
@@ -1126,8 +1126,8 @@ int extcon_dev_register(struct extcon_dev *edev)
 		char *str;
 		struct extcon_cable *cable;
 
-		edev->cables = kzalloc(sizeof(struct extcon_cable) *
-				       edev->max_supported, GFP_KERNEL);
+		edev->cables = kzalloc(array_size(sizeof(struct extcon_cable), edev->max_supported),
+				       GFP_KERNEL);
 		if (!edev->cables) {
 			ret = -ENOMEM;
 			goto err_sysfs_alloc;
@@ -1136,7 +1136,7 @@ int extcon_dev_register(struct extcon_dev *edev)
 			cable = &edev->cables[index];
 
 			snprintf(buf, 10, "cable.%d", index);
-			str = kzalloc(sizeof(char) * (strlen(buf) + 1),
+			str = kzalloc(array_size(sizeof(char), (strlen(buf) + 1)),
 				      GFP_KERNEL);
 			if (!str) {
 				for (index--; index >= 0; index--) {
@@ -1177,8 +1177,8 @@ int extcon_dev_register(struct extcon_dev *edev)
 		for (index = 0; edev->mutually_exclusive[index]; index++)
 			;
 
-		edev->attrs_muex = kzalloc(sizeof(struct attribute *) *
-					   (index + 1), GFP_KERNEL);
+		edev->attrs_muex = kzalloc(array_size(sizeof(struct attribute *), (index + 1)),
+					   GFP_KERNEL);
 		if (!edev->attrs_muex) {
 			ret = -ENOMEM;
 			goto err_muex;
@@ -1194,7 +1194,7 @@ int extcon_dev_register(struct extcon_dev *edev)
 
 		for (index = 0; edev->mutually_exclusive[index]; index++) {
 			sprintf(buf, "0x%x", edev->mutually_exclusive[index]);
-			name = kzalloc(sizeof(char) * (strlen(buf) + 1),
+			name = kzalloc(array_size(sizeof(char), (strlen(buf) + 1)),
 				       GFP_KERNEL);
 			if (!name) {
 				for (index--; index >= 0; index--) {
@@ -1220,8 +1220,8 @@ int extcon_dev_register(struct extcon_dev *edev)
 
 	if (edev->max_supported) {
 		edev->extcon_dev_type.groups =
-			kzalloc(sizeof(struct attribute_group *) *
-				(edev->max_supported + 2), GFP_KERNEL);
+			kzalloc(array_size(sizeof(struct attribute_group *), (edev->max_supported + 2)),
+				GFP_KERNEL);
 		if (!edev->extcon_dev_type.groups) {
 			ret = -ENOMEM;
 			goto err_alloc_groups;
diff --git a/drivers/firmware/efi/runtime-map.c b/drivers/firmware/efi/runtime-map.c
index f377609ff141..a95007d24d00 100644
--- a/drivers/firmware/efi/runtime-map.c
+++ b/drivers/firmware/efi/runtime-map.c
@@ -166,7 +166,8 @@ int __init efi_runtime_map_init(struct kobject *efi_kobj)
 	if (!efi_enabled(EFI_MEMMAP))
 		return 0;
 
-	map_entries = kzalloc(efi.memmap.nr_map * sizeof(entry), GFP_KERNEL);
+	map_entries = kzalloc(array_size(efi.memmap.nr_map, sizeof(entry)),
+			      GFP_KERNEL);
 	if (!map_entries) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v7.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v7.c
index ea54e53172b9..e690cb43cffe 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v7.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v7.c
@@ -417,7 +417,8 @@ static int kgd_hqd_dump(struct kgd_dev *kgd,
 		(*dump)[i++][1] = RREG32(addr);		\
 	} while (0)
 
-	*dump = kmalloc(HQD_N_REGS*2*sizeof(uint32_t), GFP_KERNEL);
+	*dump = kmalloc(array3_size(HQD_N_REGS, 2, sizeof(uint32_t)),
+			GFP_KERNEL);
 	if (*dump == NULL)
 		return -ENOMEM;
 
@@ -514,7 +515,8 @@ static int kgd_hqd_sdma_dump(struct kgd_dev *kgd,
 #undef HQD_N_REGS
 #define HQD_N_REGS (19+4)
 
-	*dump = kmalloc(HQD_N_REGS*2*sizeof(uint32_t), GFP_KERNEL);
+	*dump = kmalloc(array3_size(HQD_N_REGS, 2, sizeof(uint32_t)),
+			GFP_KERNEL);
 	if (*dump == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v8.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v8.c
index 89264c9a5e9f..a9e878f55df2 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v8.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gfx_v8.c
@@ -405,7 +405,8 @@ static int kgd_hqd_dump(struct kgd_dev *kgd,
 		(*dump)[i++][1] = RREG32(addr);		\
 	} while (0)
 
-	*dump = kmalloc(HQD_N_REGS*2*sizeof(uint32_t), GFP_KERNEL);
+	*dump = kmalloc(array3_size(HQD_N_REGS, 2, sizeof(uint32_t)),
+			GFP_KERNEL);
 	if (*dump == NULL)
 		return -ENOMEM;
 
@@ -501,7 +502,8 @@ static int kgd_hqd_sdma_dump(struct kgd_dev *kgd,
 #undef HQD_N_REGS
 #define HQD_N_REGS (19+4+2+3+7)
 
-	*dump = kmalloc(HQD_N_REGS*2*sizeof(uint32_t), GFP_KERNEL);
+	*dump = kmalloc(array3_size(HQD_N_REGS, 2, sizeof(uint32_t)),
+			GFP_KERNEL);
 	if (*dump == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_dpm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_dpm.c
index e997ebbe43ea..1271aea3899c 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_dpm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_dpm.c
@@ -432,8 +432,7 @@ int amdgpu_parse_extended_power_table(struct amdgpu_device *adev)
 			ATOM_PPLIB_PhaseSheddingLimits_Record *entry;
 
 			adev->pm.dpm.dyn_state.phase_shedding_limits_table.entries =
-				kzalloc(psl->ucNumEntries *
-					sizeof(struct amdgpu_phase_shedding_limits_entry),
+				kzalloc(array_size(psl->ucNumEntries, sizeof(struct amdgpu_phase_shedding_limits_entry)),
 					GFP_KERNEL);
 			if (!adev->pm.dpm.dyn_state.phase_shedding_limits_table.entries) {
 				amdgpu_free_extended_power_table(adev);
diff --git a/drivers/gpu/drm/amd/amdgpu/atom.c b/drivers/gpu/drm/amd/amdgpu/atom.c
index 69500a8b4e2d..5e30b23cc5c7 100644
--- a/drivers/gpu/drm/amd/amdgpu/atom.c
+++ b/drivers/gpu/drm/amd/amdgpu/atom.c
@@ -1221,7 +1221,7 @@ static int amdgpu_atom_execute_table_locked(struct atom_context *ctx, int index,
 	ectx.abort = false;
 	ectx.last_jump = 0;
 	if (ws)
-		ectx.ws = kzalloc(4 * ws, GFP_KERNEL);
+		ectx.ws = kzalloc(array_size(4, ws), GFP_KERNEL);
 	else
 		ectx.ws = NULL;
 
@@ -1282,7 +1282,7 @@ static int atom_iio_len[] = { 1, 2, 3, 3, 3, 3, 4, 4, 4, 3 };
 
 static void atom_index_iio(struct atom_context *ctx, int base)
 {
-	ctx->iio = kzalloc(2 * 256, GFP_KERNEL);
+	ctx->iio = kzalloc(array_size(2, 256), GFP_KERNEL);
 	if (!ctx->iio)
 		return;
 	while (CU8(base) == ATOM_IIO_START) {
diff --git a/drivers/gpu/drm/amd/amdgpu/ci_dpm.c b/drivers/gpu/drm/amd/amdgpu/ci_dpm.c
index 0c1e6ae61ff2..e839b1e1d4e6 100644
--- a/drivers/gpu/drm/amd/amdgpu/ci_dpm.c
+++ b/drivers/gpu/drm/amd/amdgpu/ci_dpm.c
@@ -5679,8 +5679,8 @@ static int ci_parse_power_table(struct amdgpu_device *adev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	adev->pm.dpm.ps = kzalloc(sizeof(struct amdgpu_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	adev->pm.dpm.ps = kzalloc(array_size(sizeof(struct amdgpu_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!adev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/amd/amdgpu/kv_dpm.c b/drivers/gpu/drm/amd/amdgpu/kv_dpm.c
index 26ba984ab2b7..75a33e3421d7 100644
--- a/drivers/gpu/drm/amd/amdgpu/kv_dpm.c
+++ b/drivers/gpu/drm/amd/amdgpu/kv_dpm.c
@@ -2727,8 +2727,8 @@ static int kv_parse_power_table(struct amdgpu_device *adev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	adev->pm.dpm.ps = kzalloc(sizeof(struct amdgpu_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	adev->pm.dpm.ps = kzalloc(array_size(sizeof(struct amdgpu_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!adev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/amd/amdgpu/si_dpm.c b/drivers/gpu/drm/amd/amdgpu/si_dpm.c
index 6e12d8f28859..f568915b5165 100644
--- a/drivers/gpu/drm/amd/amdgpu/si_dpm.c
+++ b/drivers/gpu/drm/amd/amdgpu/si_dpm.c
@@ -7242,8 +7242,8 @@ static int si_parse_power_table(struct amdgpu_device *adev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	adev->pm.dpm.ps = kzalloc(sizeof(struct amdgpu_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	adev->pm.dpm.ps = kzalloc(array_size(sizeof(struct amdgpu_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!adev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c b/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
index 59808a39ecf4..36a20c34b653 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
@@ -1296,7 +1296,7 @@ static int kfd_ioctl_map_memory_to_gpu(struct file *filep,
 		return -EINVAL;
 	}
 
-	devices_arr = kmalloc(args->n_devices * sizeof(*devices_arr),
+	devices_arr = kmalloc(array_size(args->n_devices, sizeof(*devices_arr)),
 			      GFP_KERNEL);
 	if (!devices_arr)
 		return -ENOMEM;
@@ -1405,7 +1405,7 @@ static int kfd_ioctl_unmap_memory_from_gpu(struct file *filep,
 		return -EINVAL;
 	}
 
-	devices_arr = kmalloc(args->n_devices * sizeof(*devices_arr),
+	devices_arr = kmalloc(array_size(args->n_devices, sizeof(*devices_arr)),
 			      GFP_KERNEL);
 	if (!devices_arr)
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/amd/display/dc/dce/dce_clock_source.c b/drivers/gpu/drm/amd/display/dc/dce/dce_clock_source.c
index 0aa2cda60890..cf71674f9e7d 100644
--- a/drivers/gpu/drm/amd/display/dc/dce/dce_clock_source.c
+++ b/drivers/gpu/drm/amd/display/dc/dce/dce_clock_source.c
@@ -1076,13 +1076,13 @@ static void get_ss_info_from_atombios(
 	if (*ss_entries_num == 0)
 		return;
 
-	ss_info = kzalloc(sizeof(struct spread_spectrum_info) * (*ss_entries_num),
+	ss_info = kzalloc(array_size(sizeof(struct spread_spectrum_info), (*ss_entries_num)),
 			  GFP_KERNEL);
 	ss_info_cur = ss_info;
 	if (ss_info == NULL)
 		return;
 
-	ss_data = kzalloc(sizeof(struct spread_spectrum_data) * (*ss_entries_num),
+	ss_data = kzalloc(array_size(sizeof(struct spread_spectrum_data), (*ss_entries_num)),
 			  GFP_KERNEL);
 	if (ss_data == NULL)
 		goto out_free_info;
diff --git a/drivers/gpu/drm/amd/display/modules/color/color_gamma.c b/drivers/gpu/drm/amd/display/modules/color/color_gamma.c
index e7e374f56864..123665a02759 100644
--- a/drivers/gpu/drm/amd/display/modules/color/color_gamma.c
+++ b/drivers/gpu/drm/amd/display/modules/color/color_gamma.c
@@ -1093,19 +1093,20 @@ bool mod_color_calculate_regamma_params(struct dc_transfer_func *output_tf,
 
 	output_tf->type = TF_TYPE_DISTRIBUTED_POINTS;
 
-	rgb_user = kzalloc(sizeof(*rgb_user) * (ramp->num_entries + _EXTRA_POINTS),
+	rgb_user = kzalloc(array_size(sizeof(*rgb_user), (ramp->num_entries + _EXTRA_POINTS)),
 			   GFP_KERNEL);
 	if (!rgb_user)
 		goto rgb_user_alloc_fail;
-	rgb_regamma = kzalloc(sizeof(*rgb_regamma) * (MAX_HW_POINTS + _EXTRA_POINTS),
-			GFP_KERNEL);
+	rgb_regamma = kzalloc(array_size(sizeof(*rgb_regamma), (MAX_HW_POINTS + _EXTRA_POINTS)),
+			      GFP_KERNEL);
 	if (!rgb_regamma)
 		goto rgb_regamma_alloc_fail;
-	axix_x = kzalloc(sizeof(*axix_x) * (ramp->num_entries + 3),
+	axix_x = kzalloc(array_size(sizeof(*axix_x), (ramp->num_entries + 3)),
 			 GFP_KERNEL);
 	if (!axix_x)
 		goto axix_x_alloc_fail;
-	coeff = kzalloc(sizeof(*coeff) * (MAX_HW_POINTS + _EXTRA_POINTS), GFP_KERNEL);
+	coeff = kzalloc(array_size(sizeof(*coeff), (MAX_HW_POINTS + _EXTRA_POINTS)),
+			GFP_KERNEL);
 	if (!coeff)
 		goto coeff_alloc_fail;
 
@@ -1192,19 +1193,20 @@ bool mod_color_calculate_degamma_params(struct dc_transfer_func *input_tf,
 
 	input_tf->type = TF_TYPE_DISTRIBUTED_POINTS;
 
-	rgb_user = kzalloc(sizeof(*rgb_user) * (ramp->num_entries + _EXTRA_POINTS),
+	rgb_user = kzalloc(array_size(sizeof(*rgb_user), (ramp->num_entries + _EXTRA_POINTS)),
 			   GFP_KERNEL);
 	if (!rgb_user)
 		goto rgb_user_alloc_fail;
-	curve = kzalloc(sizeof(*curve) * (MAX_HW_POINTS + _EXTRA_POINTS),
+	curve = kzalloc(array_size(sizeof(*curve), (MAX_HW_POINTS + _EXTRA_POINTS)),
 			GFP_KERNEL);
 	if (!curve)
 		goto curve_alloc_fail;
-	axix_x = kzalloc(sizeof(*axix_x) * (ramp->num_entries + _EXTRA_POINTS),
+	axix_x = kzalloc(array_size(sizeof(*axix_x), (ramp->num_entries + _EXTRA_POINTS)),
 			 GFP_KERNEL);
 	if (!axix_x)
 		goto axix_x_alloc_fail;
-	coeff = kzalloc(sizeof(*coeff) * (MAX_HW_POINTS + _EXTRA_POINTS), GFP_KERNEL);
+	coeff = kzalloc(array_size(sizeof(*coeff), (MAX_HW_POINTS + _EXTRA_POINTS)),
+			GFP_KERNEL);
 	if (!coeff)
 		goto coeff_alloc_fail;
 
@@ -1281,8 +1283,8 @@ bool  mod_color_calculate_curve(enum dc_transfer_func_predefined trans,
 		}
 		ret = true;
 	} else if (trans == TRANSFER_FUNCTION_PQ) {
-		rgb_regamma = kzalloc(sizeof(*rgb_regamma) * (MAX_HW_POINTS +
-						_EXTRA_POINTS), GFP_KERNEL);
+		rgb_regamma = kzalloc(array_size(sizeof(*rgb_regamma), (MAX_HW_POINTS + _EXTRA_POINTS)),
+				      GFP_KERNEL);
 		if (!rgb_regamma)
 			goto rgb_regamma_alloc_fail;
 		points->end_exponent = 7;
@@ -1305,8 +1307,8 @@ bool  mod_color_calculate_curve(enum dc_transfer_func_predefined trans,
 		kfree(rgb_regamma);
 	} else if (trans == TRANSFER_FUNCTION_SRGB ||
 			  trans == TRANSFER_FUNCTION_BT709) {
-		rgb_regamma = kzalloc(sizeof(*rgb_regamma) * (MAX_HW_POINTS +
-						_EXTRA_POINTS), GFP_KERNEL);
+		rgb_regamma = kzalloc(array_size(sizeof(*rgb_regamma), (MAX_HW_POINTS + _EXTRA_POINTS)),
+				      GFP_KERNEL);
 		if (!rgb_regamma)
 			goto rgb_regamma_alloc_fail;
 		points->end_exponent = 0;
@@ -1348,8 +1350,8 @@ bool  mod_color_calculate_degamma_curve(enum dc_transfer_func_predefined trans,
 		}
 		ret = true;
 	} else if (trans == TRANSFER_FUNCTION_PQ) {
-		rgb_degamma = kzalloc(sizeof(*rgb_degamma) * (MAX_HW_POINTS +
-						_EXTRA_POINTS), GFP_KERNEL);
+		rgb_degamma = kzalloc(array_size(sizeof(*rgb_degamma), (MAX_HW_POINTS + _EXTRA_POINTS)),
+				      GFP_KERNEL);
 		if (!rgb_degamma)
 			goto rgb_degamma_alloc_fail;
 
@@ -1367,8 +1369,8 @@ bool  mod_color_calculate_degamma_curve(enum dc_transfer_func_predefined trans,
 		kfree(rgb_degamma);
 	} else if (trans == TRANSFER_FUNCTION_SRGB ||
 			  trans == TRANSFER_FUNCTION_BT709) {
-		rgb_degamma = kzalloc(sizeof(*rgb_degamma) * (MAX_HW_POINTS +
-						_EXTRA_POINTS), GFP_KERNEL);
+		rgb_degamma = kzalloc(array_size(sizeof(*rgb_degamma), (MAX_HW_POINTS + _EXTRA_POINTS)),
+				      GFP_KERNEL);
 		if (!rgb_degamma)
 			goto rgb_degamma_alloc_fail;
 
diff --git a/drivers/gpu/drm/amd/display/modules/stats/stats.c b/drivers/gpu/drm/amd/display/modules/stats/stats.c
index 041f87b73d5f..39e04e2fca9e 100644
--- a/drivers/gpu/drm/amd/display/modules/stats/stats.c
+++ b/drivers/gpu/drm/amd/display/modules/stats/stats.c
@@ -125,8 +125,8 @@ struct mod_stats *mod_stats_create(struct dc *dc)
 			core_stats->entries = reg_data;
 	}
 
-	core_stats->time = kzalloc(sizeof(struct stats_time_cache) * core_stats->entries,
-					GFP_KERNEL);
+	core_stats->time = kzalloc(array_size(sizeof(struct stats_time_cache), core_stats->entries),
+				   GFP_KERNEL);
 
 	if (core_stats->time == NULL)
 		goto fail_construct;
diff --git a/drivers/gpu/drm/ast/ast_main.c b/drivers/gpu/drm/ast/ast_main.c
index dac355812adc..c4b79513242c 100644
--- a/drivers/gpu/drm/ast/ast_main.c
+++ b/drivers/gpu/drm/ast/ast_main.c
@@ -235,7 +235,8 @@ static int ast_detect_chip(struct drm_device *dev, bool *need_post)
 			ast->tx_chip_type = AST_TX_SIL164;
 			break;
 		case 0x08:
-			ast->dp501_fw_addr = kzalloc(32*1024, GFP_KERNEL);
+			ast->dp501_fw_addr = kzalloc(array_size(32, 1024),
+						     GFP_KERNEL);
 			if (ast->dp501_fw_addr) {
 				/* backup firmware */
 				if (ast_backup_fw(dev, ast->dp501_fw_addr, 32*1024)) {
diff --git a/drivers/gpu/drm/drm_edid.c b/drivers/gpu/drm/drm_edid.c
index 39f1db4acda4..7a5f5ba45ffb 100644
--- a/drivers/gpu/drm/drm_edid.c
+++ b/drivers/gpu/drm/drm_edid.c
@@ -1633,7 +1633,8 @@ struct edid *drm_do_get_edid(struct drm_connector *connector,
 		edid[EDID_LENGTH-1] += edid[0x7e] - valid_extensions;
 		edid[0x7e] = valid_extensions;
 
-		new = kmalloc((valid_extensions + 1) * EDID_LENGTH, GFP_KERNEL);
+		new = kmalloc(array_size((valid_extensions + 1), EDID_LENGTH),
+			      GFP_KERNEL);
 		if (!new)
 			goto out;
 
diff --git a/drivers/gpu/drm/gma500/mid_bios.c b/drivers/gpu/drm/gma500/mid_bios.c
index 7171b7475f58..b5c1bec74f02 100644
--- a/drivers/gpu/drm/gma500/mid_bios.c
+++ b/drivers/gpu/drm/gma500/mid_bios.c
@@ -239,7 +239,7 @@ static int mid_get_vbt_data_r10(struct drm_psb_private *dev_priv, u32 addr)
 	if (read_vbt_r10(addr, &vbt))
 		return -1;
 
-	gct = kmalloc(sizeof(*gct) * vbt.panel_count, GFP_KERNEL);
+	gct = kmalloc(array_size(sizeof(*gct), vbt.panel_count), GFP_KERNEL);
 	if (!gct)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/i915/selftests/intel_uncore.c b/drivers/gpu/drm/i915/selftests/intel_uncore.c
index f76f2597df5c..5a0fafdb15e0 100644
--- a/drivers/gpu/drm/i915/selftests/intel_uncore.c
+++ b/drivers/gpu/drm/i915/selftests/intel_uncore.c
@@ -137,7 +137,7 @@ static int intel_uncore_check_forcewake_domains(struct drm_i915_private *dev_pri
 	if (!IS_ENABLED(CONFIG_DRM_I915_SELFTEST_BROKEN))
 		return 0;
 
-	valid = kzalloc(BITS_TO_LONGS(FW_RANGE) * sizeof(*valid),
+	valid = kzalloc(array_size(BITS_TO_LONGS(FW_RANGE), sizeof(*valid)),
 			GFP_KERNEL);
 	if (!valid)
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/nouveau/nvif/mmu.c b/drivers/gpu/drm/nouveau/nvif/mmu.c
index 15d0dcbf7ab4..232dbced31f0 100644
--- a/drivers/gpu/drm/nouveau/nvif/mmu.c
+++ b/drivers/gpu/drm/nouveau/nvif/mmu.c
@@ -54,12 +54,15 @@ nvif_mmu_init(struct nvif_object *parent, s32 oclass, struct nvif_mmu *mmu)
 	mmu->type_nr = args.type_nr;
 	mmu->kind_nr = args.kind_nr;
 
-	mmu->heap = kmalloc(sizeof(*mmu->heap) * mmu->heap_nr, GFP_KERNEL);
-	mmu->type = kmalloc(sizeof(*mmu->type) * mmu->type_nr, GFP_KERNEL);
+	mmu->heap = kmalloc(array_size(sizeof(*mmu->heap), mmu->heap_nr),
+			    GFP_KERNEL);
+	mmu->type = kmalloc(array_size(sizeof(*mmu->type), mmu->type_nr),
+			    GFP_KERNEL);
 	if (ret = -ENOMEM, !mmu->heap || !mmu->type)
 		goto done;
 
-	mmu->kind = kmalloc(sizeof(*mmu->kind) * mmu->kind_nr, GFP_KERNEL);
+	mmu->kind = kmalloc(array_size(sizeof(*mmu->kind), mmu->kind_nr),
+			    GFP_KERNEL);
 	if (!mmu->kind && mmu->kind_nr)
 		goto done;
 
diff --git a/drivers/gpu/drm/nouveau/nvif/object.c b/drivers/gpu/drm/nouveau/nvif/object.c
index 40adfe9b334b..c744342cc21f 100644
--- a/drivers/gpu/drm/nouveau/nvif/object.c
+++ b/drivers/gpu/drm/nouveau/nvif/object.c
@@ -83,7 +83,8 @@ nvif_object_sclass_get(struct nvif_object *object, struct nvif_sclass **psclass)
 			return ret;
 	}
 
-	*psclass = kzalloc(sizeof(**psclass) * args->sclass.count, GFP_KERNEL);
+	*psclass = kzalloc(array_size(sizeof(**psclass), args->sclass.count),
+			   GFP_KERNEL);
 	if (*psclass) {
 		for (i = 0; i < args->sclass.count; i++) {
 			(*psclass)[i].oclass = args->sclass.oclass[i].oclass;
diff --git a/drivers/gpu/drm/nouveau/nvif/vmm.c b/drivers/gpu/drm/nouveau/nvif/vmm.c
index 31cdb2d2e1ff..aa5f205c856d 100644
--- a/drivers/gpu/drm/nouveau/nvif/vmm.c
+++ b/drivers/gpu/drm/nouveau/nvif/vmm.c
@@ -138,7 +138,8 @@ nvif_vmm_init(struct nvif_mmu *mmu, s32 oclass, u64 addr, u64 size,
 	vmm->limit = args->size;
 
 	vmm->page_nr = args->page_nr;
-	vmm->page = kmalloc(sizeof(*vmm->page) * vmm->page_nr, GFP_KERNEL);
+	vmm->page = kmalloc(array_size(sizeof(*vmm->page), vmm->page_nr),
+			    GFP_KERNEL);
 	if (!vmm->page) {
 		ret = -ENOMEM;
 		goto done;
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fifo/gk104.c b/drivers/gpu/drm/nouveau/nvkm/engine/fifo/gk104.c
index 84bd703dd897..11f2eb3a55a0 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/fifo/gk104.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/fifo/gk104.c
@@ -782,7 +782,7 @@ gk104_fifo_oneinit(struct nvkm_fifo *base)
 	nvkm_debug(subdev, "%d PBDMA(s)\n", fifo->pbdma_nr);
 
 	/* Read PBDMA->runlist(s) mapping from HW. */
-	if (!(map = kzalloc(sizeof(*map) * fifo->pbdma_nr, GFP_KERNEL)))
+	if (!(map = kzalloc(array_size(sizeof(*map), fifo->pbdma_nr), GFP_KERNEL)))
 		return -ENOMEM;
 
 	for (i = 0; i < fifo->pbdma_nr; i++)
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv40.c b/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv40.c
index 80a6b017af64..20aabddeebcc 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv40.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv40.c
@@ -670,7 +670,7 @@ nv40_grctx_fill(struct nvkm_device *device, struct nvkm_gpuobj *mem)
 int
 nv40_grctx_init(struct nvkm_device *device, u32 *size)
 {
-	u32 *ctxprog = kmalloc(256 * 4, GFP_KERNEL), i;
+	u32 *ctxprog = kmalloc(array_size(256, 4), GFP_KERNEL), i;
 	struct nvkm_grctx ctx = {
 		.device = device,
 		.mode = NVKM_GRCTX_PROG,
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv50.c b/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv50.c
index c8bb9191f9a2..bbbe3bfcdade 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv50.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxnv50.c
@@ -265,7 +265,7 @@ nv50_grctx_fill(struct nvkm_device *device, struct nvkm_gpuobj *mem)
 int
 nv50_grctx_init(struct nvkm_device *device, u32 *size)
 {
-	u32 *ctxprog = kmalloc(512 * 4, GFP_KERNEL), i;
+	u32 *ctxprog = kmalloc(array_size(512, 4), GFP_KERNEL), i;
 	struct nvkm_grctx ctx = {
 		.device = device,
 		.mode = NVKM_GRCTX_PROG,
diff --git a/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c b/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
index c6ad066c9ccf..70b6498808b1 100644
--- a/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
+++ b/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
@@ -937,7 +937,7 @@ int tiler_map_show(struct seq_file *s, void *arg)
 	w_adj = omap_dmm->container_width / xdiv;
 
 	map = kmalloc(array_size(h_adj, sizeof(*map)), GFP_KERNEL);
-	global_map = kmalloc((w_adj + 1) * h_adj, GFP_KERNEL);
+	global_map = kmalloc(array_size((w_adj + 1), h_adj), GFP_KERNEL);
 
 	if (!map || !global_map)
 		goto error;
diff --git a/drivers/gpu/drm/qxl/qxl_kms.c b/drivers/gpu/drm/qxl/qxl_kms.c
index c5716a0ca3b8..d6551eeda91c 100644
--- a/drivers/gpu/drm/qxl/qxl_kms.c
+++ b/drivers/gpu/drm/qxl/qxl_kms.c
@@ -200,7 +200,7 @@ int qxl_device_init(struct qxl_device *qdev,
 		(~(uint64_t)0) >> (qdev->slot_id_bits + qdev->slot_gen_bits);
 
 	qdev->mem_slots =
-		kmalloc(qdev->n_mem_slots * sizeof(struct qxl_memslot),
+		kmalloc(array_size(qdev->n_mem_slots, sizeof(struct qxl_memslot)),
 			GFP_KERNEL);
 
 	idr_init(&qdev->release_idr);
diff --git a/drivers/gpu/drm/radeon/atom.c b/drivers/gpu/drm/radeon/atom.c
index 6a2e091aa7b6..a88a40d595fd 100644
--- a/drivers/gpu/drm/radeon/atom.c
+++ b/drivers/gpu/drm/radeon/atom.c
@@ -1176,7 +1176,7 @@ static int atom_execute_table_locked(struct atom_context *ctx, int index, uint32
 	ectx.abort = false;
 	ectx.last_jump = 0;
 	if (ws)
-		ectx.ws = kzalloc(4 * ws, GFP_KERNEL);
+		ectx.ws = kzalloc(array_size(4, ws), GFP_KERNEL);
 	else
 		ectx.ws = NULL;
 
@@ -1246,7 +1246,7 @@ static int atom_iio_len[] = { 1, 2, 3, 3, 3, 3, 4, 4, 4, 3 };
 
 static void atom_index_iio(struct atom_context *ctx, int base)
 {
-	ctx->iio = kzalloc(2 * 256, GFP_KERNEL);
+	ctx->iio = kzalloc(array_size(2, 256), GFP_KERNEL);
 	if (!ctx->iio)
 		return;
 	while (CU8(base) == ATOM_IIO_START) {
diff --git a/drivers/gpu/drm/radeon/ci_dpm.c b/drivers/gpu/drm/radeon/ci_dpm.c
index bdefba5d7287..d315cebb9a6c 100644
--- a/drivers/gpu/drm/radeon/ci_dpm.c
+++ b/drivers/gpu/drm/radeon/ci_dpm.c
@@ -5568,8 +5568,8 @@ static int ci_parse_power_table(struct radeon_device *rdev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/radeon/kv_dpm.c b/drivers/gpu/drm/radeon/kv_dpm.c
index ae1529b0ef6f..41fd562df59a 100644
--- a/drivers/gpu/drm/radeon/kv_dpm.c
+++ b/drivers/gpu/drm/radeon/kv_dpm.c
@@ -2660,8 +2660,8 @@ static int kv_parse_power_table(struct radeon_device *rdev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/radeon/ni_dpm.c b/drivers/gpu/drm/radeon/ni_dpm.c
index 021ca86432b0..550d6326c0a3 100644
--- a/drivers/gpu/drm/radeon/ni_dpm.c
+++ b/drivers/gpu/drm/radeon/ni_dpm.c
@@ -3998,8 +3998,8 @@ static int ni_parse_power_table(struct radeon_device *rdev)
 		return -EINVAL;
 	power_info = (union power_info *)(mode_info->atom_context->bios + data_offset);
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  power_info->pplib.ucNumStates, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), power_info->pplib.ucNumStates),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/radeon/r600_dpm.c b/drivers/gpu/drm/radeon/r600_dpm.c
index 31d1b4710844..6abfe2411b0d 100644
--- a/drivers/gpu/drm/radeon/r600_dpm.c
+++ b/drivers/gpu/drm/radeon/r600_dpm.c
@@ -991,8 +991,7 @@ int r600_parse_extended_power_table(struct radeon_device *rdev)
 			ATOM_PPLIB_PhaseSheddingLimits_Record *entry;
 
 			rdev->pm.dpm.dyn_state.phase_shedding_limits_table.entries =
-				kzalloc(psl->ucNumEntries *
-					sizeof(struct radeon_phase_shedding_limits_entry),
+				kzalloc(array_size(psl->ucNumEntries, sizeof(struct radeon_phase_shedding_limits_entry)),
 					GFP_KERNEL);
 			if (!rdev->pm.dpm.dyn_state.phase_shedding_limits_table.entries) {
 				r600_free_extended_power_table(rdev);
diff --git a/drivers/gpu/drm/radeon/radeon_atombios.c b/drivers/gpu/drm/radeon/radeon_atombios.c
index 49693891ac9f..d52580198750 100644
--- a/drivers/gpu/drm/radeon/radeon_atombios.c
+++ b/drivers/gpu/drm/radeon/radeon_atombios.c
@@ -2589,8 +2589,8 @@ static int radeon_atombios_parse_power_table_4_5(struct radeon_device *rdev)
 	radeon_atombios_add_pplib_thermal_controller(rdev, &power_info->pplib.sThermalController);
 	if (power_info->pplib.ucNumStates == 0)
 		return state_index;
-	rdev->pm.power_state = kzalloc(sizeof(struct radeon_power_state) *
-				       power_info->pplib.ucNumStates, GFP_KERNEL);
+	rdev->pm.power_state = kzalloc(array_size(sizeof(struct radeon_power_state), power_info->pplib.ucNumStates),
+				       GFP_KERNEL);
 	if (!rdev->pm.power_state)
 		return state_index;
 	/* first mode is usually default, followed by low to high */
@@ -2605,9 +2605,7 @@ static int radeon_atombios_parse_power_table_4_5(struct radeon_device *rdev)
 			 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset) +
 			 (power_state->v1.ucNonClockStateIndex *
 			  power_info->pplib.ucNonClockSize));
-		rdev->pm.power_state[i].clock_info = kzalloc(sizeof(struct radeon_pm_clock_info) *
-							     ((power_info->pplib.ucStateEntrySize - 1) ?
-							      (power_info->pplib.ucStateEntrySize - 1) : 1),
+		rdev->pm.power_state[i].clock_info = kzalloc(array_size(sizeof(struct radeon_pm_clock_info), ((power_info->pplib.ucStateEntrySize - 1) ? (power_info->pplib.ucStateEntrySize - 1) : 1)),
 							     GFP_KERNEL);
 		if (!rdev->pm.power_state[i].clock_info)
 			return state_index;
@@ -2690,8 +2688,8 @@ static int radeon_atombios_parse_power_table_6(struct radeon_device *rdev)
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 	if (state_array->ucNumEntries == 0)
 		return state_index;
-	rdev->pm.power_state = kzalloc(sizeof(struct radeon_power_state) *
-				       state_array->ucNumEntries, GFP_KERNEL);
+	rdev->pm.power_state = kzalloc(array_size(sizeof(struct radeon_power_state), state_array->ucNumEntries),
+				       GFP_KERNEL);
 	if (!rdev->pm.power_state)
 		return state_index;
 	power_state_offset = (u8 *)state_array->states;
@@ -2701,9 +2699,7 @@ static int radeon_atombios_parse_power_table_6(struct radeon_device *rdev)
 		non_clock_array_index = power_state->v2.nonClockInfoIndex;
 		non_clock_info = (struct _ATOM_PPLIB_NONCLOCK_INFO *)
 			&non_clock_info_array->nonClockInfo[non_clock_array_index];
-		rdev->pm.power_state[i].clock_info = kzalloc(sizeof(struct radeon_pm_clock_info) *
-							     (power_state->v2.ucNumDPMLevels ?
-							      power_state->v2.ucNumDPMLevels : 1),
+		rdev->pm.power_state[i].clock_info = kzalloc(array_size(sizeof(struct radeon_pm_clock_info), (power_state->v2.ucNumDPMLevels ? power_state->v2.ucNumDPMLevels : 1)),
 							     GFP_KERNEL);
 		if (!rdev->pm.power_state[i].clock_info)
 			return state_index;
diff --git a/drivers/gpu/drm/radeon/rs780_dpm.c b/drivers/gpu/drm/radeon/rs780_dpm.c
index b5e4e09a8996..63db68c55f46 100644
--- a/drivers/gpu/drm/radeon/rs780_dpm.c
+++ b/drivers/gpu/drm/radeon/rs780_dpm.c
@@ -804,8 +804,8 @@ static int rs780_parse_power_table(struct radeon_device *rdev)
 		return -EINVAL;
 	power_info = (union power_info *)(mode_info->atom_context->bios + data_offset);
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  power_info->pplib.ucNumStates, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), power_info->pplib.ucNumStates),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/radeon/rv6xx_dpm.c b/drivers/gpu/drm/radeon/rv6xx_dpm.c
index d91aa3944593..4bc50fbe28f8 100644
--- a/drivers/gpu/drm/radeon/rv6xx_dpm.c
+++ b/drivers/gpu/drm/radeon/rv6xx_dpm.c
@@ -1888,8 +1888,8 @@ static int rv6xx_parse_power_table(struct radeon_device *rdev)
 		return -EINVAL;
 	power_info = (union power_info *)(mode_info->atom_context->bios + data_offset);
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  power_info->pplib.ucNumStates, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), power_info->pplib.ucNumStates),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/radeon/rv770_dpm.c b/drivers/gpu/drm/radeon/rv770_dpm.c
index cb2a7ec4e217..4180cef575af 100644
--- a/drivers/gpu/drm/radeon/rv770_dpm.c
+++ b/drivers/gpu/drm/radeon/rv770_dpm.c
@@ -2282,8 +2282,8 @@ int rv7xx_parse_power_table(struct radeon_device *rdev)
 		return -EINVAL;
 	power_info = (union power_info *)(mode_info->atom_context->bios + data_offset);
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  power_info->pplib.ucNumStates, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), power_info->pplib.ucNumStates),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/radeon/si_dpm.c b/drivers/gpu/drm/radeon/si_dpm.c
index 0e2a43220a23..14eb59ff6441 100644
--- a/drivers/gpu/drm/radeon/si_dpm.c
+++ b/drivers/gpu/drm/radeon/si_dpm.c
@@ -6832,8 +6832,8 @@ static int si_parse_power_table(struct radeon_device *rdev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/radeon/sumo_dpm.c b/drivers/gpu/drm/radeon/sumo_dpm.c
index fd4804829e46..e23d25f67f20 100644
--- a/drivers/gpu/drm/radeon/sumo_dpm.c
+++ b/drivers/gpu/drm/radeon/sumo_dpm.c
@@ -1482,8 +1482,8 @@ static int sumo_parse_power_table(struct radeon_device *rdev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/radeon/trinity_dpm.c b/drivers/gpu/drm/radeon/trinity_dpm.c
index 2ef7c4e5e495..3e9bc85392cf 100644
--- a/drivers/gpu/drm/radeon/trinity_dpm.c
+++ b/drivers/gpu/drm/radeon/trinity_dpm.c
@@ -1757,8 +1757,8 @@ static int trinity_parse_power_table(struct radeon_device *rdev)
 		(mode_info->atom_context->bios + data_offset +
 		 le16_to_cpu(power_info->pplib.usNonClockInfoArrayOffset));
 
-	rdev->pm.dpm.ps = kzalloc(sizeof(struct radeon_ps) *
-				  state_array->ucNumEntries, GFP_KERNEL);
+	rdev->pm.dpm.ps = kzalloc(array_size(sizeof(struct radeon_ps), state_array->ucNumEntries),
+				  GFP_KERNEL);
 	if (!rdev->pm.dpm.ps)
 		return -ENOMEM;
 	power_state_offset = (u8 *)state_array->states;
diff --git a/drivers/gpu/drm/savage/savage_bci.c b/drivers/gpu/drm/savage/savage_bci.c
index 2a5b8466d806..fd7e2eb84008 100644
--- a/drivers/gpu/drm/savage/savage_bci.c
+++ b/drivers/gpu/drm/savage/savage_bci.c
@@ -298,8 +298,8 @@ static int savage_dma_init(drm_savage_private_t * dev_priv)
 
 	dev_priv->nr_dma_pages = dev_priv->cmd_dma->size /
 	    (SAVAGE_DMA_PAGE_SIZE * 4);
-	dev_priv->dma_pages = kmalloc(sizeof(drm_savage_dma_page_t) *
-				      dev_priv->nr_dma_pages, GFP_KERNEL);
+	dev_priv->dma_pages = kmalloc(array_size(sizeof(drm_savage_dma_page_t), dev_priv->nr_dma_pages),
+				      GFP_KERNEL);
 	if (dev_priv->dma_pages == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/selftests/test-drm_mm.c b/drivers/gpu/drm/selftests/test-drm_mm.c
index 7cc935d7b7aa..12701321ce77 100644
--- a/drivers/gpu/drm/selftests/test-drm_mm.c
+++ b/drivers/gpu/drm/selftests/test-drm_mm.c
@@ -1631,7 +1631,7 @@ static int igt_topdown(void *ignored)
 	if (!nodes)
 		goto err;
 
-	bitmap = kzalloc(count / BITS_PER_LONG * sizeof(unsigned long),
+	bitmap = kzalloc(array_size(count / BITS_PER_LONG, sizeof(unsigned long)),
 			 GFP_KERNEL);
 	if (!bitmap)
 		goto err_nodes;
@@ -1745,7 +1745,7 @@ static int igt_bottomup(void *ignored)
 	if (!nodes)
 		goto err;
 
-	bitmap = kzalloc(count / BITS_PER_LONG * sizeof(unsigned long),
+	bitmap = kzalloc(array_size(count / BITS_PER_LONG, sizeof(unsigned long)),
 			 GFP_KERNEL);
 	if (!bitmap)
 		goto err_nodes;
diff --git a/drivers/gpu/drm/tinydrm/repaper.c b/drivers/gpu/drm/tinydrm/repaper.c
index 75740630c410..ac719fc27cec 100644
--- a/drivers/gpu/drm/tinydrm/repaper.c
+++ b/drivers/gpu/drm/tinydrm/repaper.c
@@ -554,7 +554,7 @@ static int repaper_fb_dirty(struct drm_framebuffer *fb,
 	DRM_DEBUG("Flushing [FB:%d] st=%ums\n", fb->base.id,
 		  epd->factored_stage_time);
 
-	buf = kmalloc(fb->width * fb->height, GFP_KERNEL);
+	buf = kmalloc(array_size(fb->width, fb->height), GFP_KERNEL);
 	if (!buf) {
 		ret = -ENOMEM;
 		goto out_unlock;
diff --git a/drivers/gpu/drm/vc4/vc4_plane.c b/drivers/gpu/drm/vc4/vc4_plane.c
index ce39390be389..ad0fe5526f9f 100644
--- a/drivers/gpu/drm/vc4/vc4_plane.c
+++ b/drivers/gpu/drm/vc4/vc4_plane.c
@@ -208,7 +208,7 @@ static void vc4_dlist_write(struct vc4_plane_state *vc4_state, u32 val)
 {
 	if (vc4_state->dlist_count == vc4_state->dlist_size) {
 		u32 new_size = max(4u, vc4_state->dlist_count * 2);
-		u32 *new_dlist = kmalloc(new_size * 4, GFP_KERNEL);
+		u32 *new_dlist = kmalloc(array_size(new_size, 4), GFP_KERNEL);
 
 		if (!new_dlist)
 			return;
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_surface.c b/drivers/gpu/drm/vmwgfx/vmwgfx_surface.c
index b236c48bf265..fd62883105b4 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_surface.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_surface.c
@@ -811,7 +811,8 @@ int vmw_surface_define_ioctl(struct drm_device *dev, void *data,
 	    srf->sizes[0].height == 64 &&
 	    srf->format == SVGA3D_A8R8G8B8) {
 
-		srf->snooper.image = kzalloc(64 * 64 * 4, GFP_KERNEL);
+		srf->snooper.image = kzalloc(array3_size(64, 64, 4),
+					     GFP_KERNEL);
 		if (!srf->snooper.image) {
 			DRM_ERROR("Failed to allocate cursor_image\n");
 			ret = -ENOMEM;
diff --git a/drivers/hid/hid-core.c b/drivers/hid/hid-core.c
index f82dc60d432e..82c52d4db552 100644
--- a/drivers/hid/hid-core.c
+++ b/drivers/hid/hid-core.c
@@ -131,8 +131,8 @@ static int open_collection(struct hid_parser *parser, unsigned type)
 	}
 
 	if (parser->device->maxcollection == parser->device->collection_size) {
-		collection = kmalloc(sizeof(struct hid_collection) *
-				parser->device->collection_size * 2, GFP_KERNEL);
+		collection = kmalloc(array3_size(sizeof(struct hid_collection), parser->device->collection_size, 2),
+				     GFP_KERNEL);
 		if (collection == NULL) {
 			hid_err(parser->device, "failed to reallocate collection array\n");
 			return -ENOMEM;
diff --git a/drivers/hid/hid-picolcd_fb.c b/drivers/hid/hid-picolcd_fb.c
index 7f965e231433..c3fd50d8ae6e 100644
--- a/drivers/hid/hid-picolcd_fb.c
+++ b/drivers/hid/hid-picolcd_fb.c
@@ -394,7 +394,8 @@ static int picolcd_set_par(struct fb_info *info)
 		return -EINVAL;
 
 	o_fb   = fbdata->bitmap;
-	tmp_fb = kmalloc(PICOLCDFB_SIZE*info->var.bits_per_pixel, GFP_KERNEL);
+	tmp_fb = kmalloc(array_size(PICOLCDFB_SIZE, info->var.bits_per_pixel),
+			 GFP_KERNEL);
 	if (!tmp_fb)
 		return -ENOMEM;
 
diff --git a/drivers/hv/hv_util.c b/drivers/hv/hv_util.c
index 14dce25c104f..3676eb44da0f 100644
--- a/drivers/hv/hv_util.c
+++ b/drivers/hv/hv_util.c
@@ -401,7 +401,7 @@ static int util_probe(struct hv_device *dev,
 		(struct hv_util_service *)dev_id->driver_data;
 	int ret;
 
-	srv->recv_buffer = kmalloc(PAGE_SIZE * 4, GFP_KERNEL);
+	srv->recv_buffer = kmalloc(array_size(PAGE_SIZE, 4), GFP_KERNEL);
 	if (!srv->recv_buffer)
 		return -ENOMEM;
 	srv->channel = dev->channel;
diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c
index 8699bb969e7e..e8dcc2f2e2f5 100644
--- a/drivers/hv/ring_buffer.c
+++ b/drivers/hv/ring_buffer.c
@@ -202,7 +202,7 @@ int hv_ringbuffer_init(struct hv_ring_buffer_info *ring_info,
 	 * First page holds struct hv_ring_buffer, do wraparound mapping for
 	 * the rest.
 	 */
-	pages_wraparound = kzalloc(sizeof(struct page *) * (page_cnt * 2 - 1),
+	pages_wraparound = kzalloc(array_size(sizeof(struct page *), (page_cnt * 2 - 1)),
 				   GFP_KERNEL);
 	if (!pages_wraparound)
 		return -ENOMEM;
diff --git a/drivers/hwmon/acpi_power_meter.c b/drivers/hwmon/acpi_power_meter.c
index 14a94d90c028..b4aefddce879 100644
--- a/drivers/hwmon/acpi_power_meter.c
+++ b/drivers/hwmon/acpi_power_meter.c
@@ -575,8 +575,8 @@ static int read_domain_devices(struct acpi_power_meter_resource *resource)
 	if (!pss->package.count)
 		goto end;
 
-	resource->domain_devices = kzalloc(sizeof(struct acpi_device *) *
-					   pss->package.count, GFP_KERNEL);
+	resource->domain_devices = kzalloc(array_size(sizeof(struct acpi_device *), pss->package.count),
+					   GFP_KERNEL);
 	if (!resource->domain_devices) {
 		res = -ENOMEM;
 		goto end;
@@ -796,7 +796,7 @@ static int read_capabilities(struct acpi_power_meter_resource *resource)
 			goto error;
 		}
 
-		*str = kzalloc(sizeof(u8) * (element->string.length + 1),
+		*str = kzalloc(array_size(sizeof(u8), (element->string.length + 1)),
 			       GFP_KERNEL);
 		if (!*str) {
 			res = -ENOMEM;
diff --git a/drivers/hwmon/ibmpex.c b/drivers/hwmon/ibmpex.c
index 21b9c72f16bd..cd88f6f52444 100644
--- a/drivers/hwmon/ibmpex.c
+++ b/drivers/hwmon/ibmpex.c
@@ -387,7 +387,7 @@ static int ibmpex_find_sensors(struct ibmpex_bmc_data *data)
 		return -ENOENT;
 	data->num_sensors = err;
 
-	data->sensors = kzalloc(data->num_sensors * sizeof(*data->sensors),
+	data->sensors = kzalloc(array_size(data->num_sensors, sizeof(*data->sensors)),
 				GFP_KERNEL);
 	if (!data->sensors)
 		return -ENOMEM;
diff --git a/drivers/i2c/i2c-stub.c b/drivers/i2c/i2c-stub.c
index 4a9ad91c5ba3..371910ff378d 100644
--- a/drivers/i2c/i2c-stub.c
+++ b/drivers/i2c/i2c-stub.c
@@ -338,8 +338,8 @@ static int __init i2c_stub_allocate_banks(int i)
 		chip->bank_mask >>= 1;
 	}
 
-	chip->bank_words = kzalloc(chip->bank_mask * chip->bank_size *
-				   sizeof(u16), GFP_KERNEL);
+	chip->bank_words = kzalloc(array3_size(chip->bank_mask, chip->bank_size, sizeof(u16)),
+				   GFP_KERNEL);
 	if (!chip->bank_words)
 		return -ENOMEM;
 
diff --git a/drivers/ide/hpt366.c b/drivers/ide/hpt366.c
index 4b5dc0162e67..eca23ccf9df2 100644
--- a/drivers/ide/hpt366.c
+++ b/drivers/ide/hpt366.c
@@ -1455,7 +1455,8 @@ static int hpt366_init_one(struct pci_dev *dev, const struct pci_device_id *id)
 	if (info == &hpt36x || info == &hpt374)
 		dev2 = pci_get_slot(dev->bus, dev->devfn + 1);
 
-	dyn_info = kzalloc(sizeof(*dyn_info) * (dev2 ? 2 : 1), GFP_KERNEL);
+	dyn_info = kzalloc(array_size(sizeof(*dyn_info), (dev2 ? 2 : 1)),
+			   GFP_KERNEL);
 	if (dyn_info == NULL) {
 		printk(KERN_ERR "%s %s: out of memory!\n",
 			d.name, pci_name(dev));
diff --git a/drivers/ide/ide-ioctls.c b/drivers/ide/ide-ioctls.c
index 3661abb16a5f..b6b5af433d6d 100644
--- a/drivers/ide/ide-ioctls.c
+++ b/drivers/ide/ide-ioctls.c
@@ -67,7 +67,7 @@ static int ide_get_identity_ioctl(ide_drive_t *drive, unsigned int cmd,
 	}
 
 	/* ata_id_to_hd_driveid() relies on 'id' to be fully allocated. */
-	id = kmalloc(ATA_ID_WORDS * 2, GFP_KERNEL);
+	id = kmalloc(array_size(ATA_ID_WORDS, 2), GFP_KERNEL);
 	if (id == NULL) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/drivers/ide/ide-probe.c b/drivers/ide/ide-probe.c
index 2019e66eada7..c3f8c67a73a4 100644
--- a/drivers/ide/ide-probe.c
+++ b/drivers/ide/ide-probe.c
@@ -989,7 +989,7 @@ static int hwif_init(ide_hwif_t *hwif)
 	if (!hwif->sg_max_nents)
 		hwif->sg_max_nents = PRD_ENTRIES;
 
-	hwif->sg_table = kmalloc(sizeof(struct scatterlist)*hwif->sg_max_nents,
+	hwif->sg_table = kmalloc(array_size(sizeof(struct scatterlist), hwif->sg_max_nents),
 				 GFP_KERNEL);
 	if (!hwif->sg_table) {
 		printk(KERN_ERR "%s: unable to allocate SG table.\n", hwif->name);
diff --git a/drivers/iio/imu/adis_buffer.c b/drivers/iio/imu/adis_buffer.c
index 36607d52fee0..f3f0650f3b74 100644
--- a/drivers/iio/imu/adis_buffer.c
+++ b/drivers/iio/imu/adis_buffer.c
@@ -38,7 +38,8 @@ int adis_update_scan_mode(struct iio_dev *indio_dev,
 	if (!adis->xfer)
 		return -ENOMEM;
 
-	adis->buffer = kzalloc(indio_dev->scan_bytes * 2, GFP_KERNEL);
+	adis->buffer = kzalloc(array_size(indio_dev->scan_bytes, 2),
+			       GFP_KERNEL);
 	if (!adis->buffer)
 		return -ENOMEM;
 
diff --git a/drivers/iio/inkern.c b/drivers/iio/inkern.c
index ec98790e2a28..5c3d7eeb8dc7 100644
--- a/drivers/iio/inkern.c
+++ b/drivers/iio/inkern.c
@@ -436,7 +436,7 @@ struct iio_channel *iio_channel_get_all(struct device *dev)
 	}
 
 	/* NULL terminated array to save passing size */
-	chans = kzalloc(sizeof(*chans)*(nummaps + 1), GFP_KERNEL);
+	chans = kzalloc(array_size(sizeof(*chans), (nummaps + 1)), GFP_KERNEL);
 	if (chans == NULL) {
 		ret = -ENOMEM;
 		goto error_ret;
diff --git a/drivers/infiniband/core/cache.c b/drivers/infiniband/core/cache.c
index e804c8586820..9beb2dbc8cf1 100644
--- a/drivers/infiniband/core/cache.c
+++ b/drivers/infiniband/core/cache.c
@@ -1248,8 +1248,8 @@ int ib_cache_setup_one(struct ib_device *device)
 	rwlock_init(&device->cache.lock);
 
 	device->cache.ports =
-		kzalloc(sizeof(*device->cache.ports) *
-			(rdma_end_port(device) - rdma_start_port(device) + 1), GFP_KERNEL);
+		kzalloc(array_size(sizeof(*device->cache.ports), (rdma_end_port(device) - rdma_start_port(device) + 1)),
+			GFP_KERNEL);
 	if (!device->cache.ports)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index a693fcd4c513..cc6acc84fe66 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1828,7 +1828,7 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 
 	rt = &id->route;
 	rt->num_paths = ib_event->param.req_rcvd.alternate_path ? 2 : 1;
-	rt->path_rec = kmalloc(sizeof *rt->path_rec * rt->num_paths,
+	rt->path_rec = kmalloc(array_size(sizeof *rt->path_rec, rt->num_paths),
 			       GFP_KERNEL);
 	if (!rt->path_rec)
 		goto err;
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index ea9fbcfb21bd..8fc80c3480a7 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -336,8 +336,7 @@ static int read_port_immutable(struct ib_device *device)
 	 * Therefore port_immutable is declared as a 1 based array with
 	 * potential empty slots at the beginning.
 	 */
-	device->port_immutable = kzalloc(sizeof(*device->port_immutable)
-					 * (end_port + 1),
+	device->port_immutable = kzalloc(array_size(sizeof(*device->port_immutable), (end_port + 1)),
 					 GFP_KERNEL);
 	if (!device->port_immutable)
 		return -ENOMEM;
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index ee3eca86b19e..55d9ea0951b1 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -859,8 +859,8 @@ static int c4iw_rdev_open(struct c4iw_rdev *rdev)
 	rdev->status_page->cq_size = rdev->lldi.vr->cq.size;
 
 	if (c4iw_wr_log) {
-		rdev->wr_log = kzalloc((1 << c4iw_wr_log_size_order) *
-				       sizeof(*rdev->wr_log), GFP_KERNEL);
+		rdev->wr_log = kzalloc(array_size((1 << c4iw_wr_log_size_order), sizeof(*rdev->wr_log)),
+				       GFP_KERNEL);
 		if (rdev->wr_log) {
 			rdev->wr_log_size = 1 << c4iw_wr_log_size_order;
 			atomic_set(&rdev->wr_log_idx, 0);
diff --git a/drivers/infiniband/hw/cxgb4/id_table.c b/drivers/infiniband/hw/cxgb4/id_table.c
index 5c2cfdea06ad..f937deb905a5 100644
--- a/drivers/infiniband/hw/cxgb4/id_table.c
+++ b/drivers/infiniband/hw/cxgb4/id_table.c
@@ -92,8 +92,8 @@ int c4iw_id_table_alloc(struct c4iw_id_table *alloc, u32 start, u32 num,
 		alloc->last = 0;
 	alloc->max  = num;
 	spin_lock_init(&alloc->lock);
-	alloc->table = kmalloc(BITS_TO_LONGS(num) * sizeof(long),
-				GFP_KERNEL);
+	alloc->table = kmalloc(array_size(BITS_TO_LONGS(num), sizeof(long)),
+			       GFP_KERNEL);
 	if (!alloc->table)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index ae167b686608..bb5a02c3010c 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -216,15 +216,15 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	}
 
 	if (!user) {
-		wq->sq.sw_sq = kzalloc(wq->sq.size * sizeof *wq->sq.sw_sq,
-				 GFP_KERNEL);
+		wq->sq.sw_sq = kzalloc(array_size(wq->sq.size, sizeof *wq->sq.sw_sq),
+				       GFP_KERNEL);
 		if (!wq->sq.sw_sq) {
 			ret = -ENOMEM;
 			goto free_rq_qid;
 		}
 
-		wq->rq.sw_rq = kzalloc(wq->rq.size * sizeof *wq->rq.sw_rq,
-				 GFP_KERNEL);
+		wq->rq.sw_rq = kzalloc(array_size(wq->rq.size, sizeof *wq->rq.sw_rq),
+				       GFP_KERNEL);
 		if (!wq->rq.sw_rq) {
 			ret = -ENOMEM;
 			goto free_sw_sq;
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index d449e1472d53..cc8f975c6c84 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2909,8 +2909,7 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 			goto err_counter;
 
 		ibdev->ib_uc_qpns_bitmap =
-			kmalloc(BITS_TO_LONGS(ibdev->steer_qpn_count) *
-				sizeof(long),
+			kmalloc(array_size(BITS_TO_LONGS(ibdev->steer_qpn_count), sizeof(long)),
 				GFP_KERNEL);
 		if (!ibdev->ib_uc_qpns_bitmap)
 			goto err_steer_qp_release;
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 199648adac74..249c3a8800a8 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -573,7 +573,7 @@ static int alloc_proxy_bufs(struct ib_device *dev, struct mlx4_ib_qp *qp)
 	int i;
 
 	qp->sqp_proxy_rcv =
-		kmalloc(sizeof (struct mlx4_ib_buf) * qp->rq.wqe_cnt,
+		kmalloc(array_size(sizeof(struct mlx4_ib_buf), qp->rq.wqe_cnt),
 			GFP_KERNEL);
 	if (!qp->sqp_proxy_rcv)
 		return -ENOMEM;
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 0148b8f559a4..1738ff09bb3f 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -189,7 +189,8 @@ static int create_srq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_srq *srq,
 	}
 
 	mlx5_ib_dbg(dev, "srq->buf.page_shift = %d\n", srq->buf.page_shift);
-	in->pas = kvzalloc(sizeof(*in->pas) * srq->buf.npages, GFP_KERNEL);
+	in->pas = kvzalloc(array_size(sizeof(*in->pas), srq->buf.npages),
+			   GFP_KERNEL);
 	if (!in->pas) {
 		err = -ENOMEM;
 		goto err_buf;
diff --git a/drivers/infiniband/hw/mthca/mthca_allocator.c b/drivers/infiniband/hw/mthca/mthca_allocator.c
index dfa35adf5b91..2ff4a4eb2eb4 100644
--- a/drivers/infiniband/hw/mthca/mthca_allocator.c
+++ b/drivers/infiniband/hw/mthca/mthca_allocator.c
@@ -90,7 +90,7 @@ int mthca_alloc_init(struct mthca_alloc *alloc, u32 num, u32 mask,
 	alloc->max  = num;
 	alloc->mask = mask;
 	spin_lock_init(&alloc->lock);
-	alloc->table = kmalloc(BITS_TO_LONGS(num) * sizeof (long),
+	alloc->table = kmalloc(array_size(BITS_TO_LONGS(num), sizeof(long)),
 			       GFP_KERNEL);
 	if (!alloc->table)
 		return -ENOMEM;
diff --git a/drivers/infiniband/hw/mthca/mthca_cmd.c b/drivers/infiniband/hw/mthca/mthca_cmd.c
index 419a2a20c047..a2519dbf6465 100644
--- a/drivers/infiniband/hw/mthca/mthca_cmd.c
+++ b/drivers/infiniband/hw/mthca/mthca_cmd.c
@@ -565,8 +565,7 @@ int mthca_cmd_use_events(struct mthca_dev *dev)
 {
 	int i;
 
-	dev->cmd.context = kmalloc(dev->cmd.max_cmds *
-				   sizeof (struct mthca_cmd_context),
+	dev->cmd.context = kmalloc(array_size(dev->cmd.max_cmds, sizeof(struct mthca_cmd_context)),
 				   GFP_KERNEL);
 	if (!dev->cmd.context)
 		return -ENOMEM;
diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 7a31be3c3e73..e4acaba9c53a 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -712,8 +712,7 @@ int mthca_init_db_tab(struct mthca_dev *dev)
 	dev->db_tab->max_group1 = 0;
 	dev->db_tab->min_group2 = dev->db_tab->npages - 1;
 
-	dev->db_tab->page = kmalloc(dev->db_tab->npages *
-				    sizeof *dev->db_tab->page,
+	dev->db_tab->page = kmalloc(array_size(dev->db_tab->npages, sizeof *dev->db_tab->page),
 				    GFP_KERNEL);
 	if (!dev->db_tab->page) {
 		kfree(dev->db_tab);
diff --git a/drivers/infiniband/hw/mthca/mthca_mr.c b/drivers/infiniband/hw/mthca/mthca_mr.c
index 88d3a53966e1..6c907f2756fc 100644
--- a/drivers/infiniband/hw/mthca/mthca_mr.c
+++ b/drivers/infiniband/hw/mthca/mthca_mr.c
@@ -144,7 +144,7 @@ static int mthca_buddy_init(struct mthca_buddy *buddy, int max_order)
 	buddy->max_order = max_order;
 	spin_lock_init(&buddy->lock);
 
-	buddy->bits = kzalloc((buddy->max_order + 1) * sizeof (long *),
+	buddy->bits = kzalloc(array_size((buddy->max_order + 1), sizeof(long *)),
 			      GFP_KERNEL);
 	buddy->num_free = kcalloc((buddy->max_order + 1), sizeof *buddy->num_free,
 				  GFP_KERNEL);
diff --git a/drivers/infiniband/hw/mthca/mthca_qp.c b/drivers/infiniband/hw/mthca/mthca_qp.c
index d21960cd9a49..c89f5766124b 100644
--- a/drivers/infiniband/hw/mthca/mthca_qp.c
+++ b/drivers/infiniband/hw/mthca/mthca_qp.c
@@ -1054,7 +1054,7 @@ static int mthca_alloc_wqe_buf(struct mthca_dev *dev,
 	size = PAGE_ALIGN(qp->send_wqe_offset +
 			  (qp->sq.max << qp->sq.wqe_shift));
 
-	qp->wrid = kmalloc((qp->rq.max + qp->sq.max) * sizeof (u64),
+	qp->wrid = kmalloc(array_size((qp->rq.max + qp->sq.max), sizeof(u64)),
 			   GFP_KERNEL);
 	if (!qp->wrid)
 		goto err_out;
diff --git a/drivers/infiniband/hw/mthca/mthca_srq.c b/drivers/infiniband/hw/mthca/mthca_srq.c
index d22f970480c0..18c97813c8f3 100644
--- a/drivers/infiniband/hw/mthca/mthca_srq.c
+++ b/drivers/infiniband/hw/mthca/mthca_srq.c
@@ -155,7 +155,7 @@ static int mthca_alloc_srq_buf(struct mthca_dev *dev, struct mthca_pd *pd,
 	if (pd->ibpd.uobject)
 		return 0;
 
-	srq->wrid = kmalloc(srq->max * sizeof (u64), GFP_KERNEL);
+	srq->wrid = kmalloc(array_size(srq->max, sizeof(u64)), GFP_KERNEL);
 	if (!srq->wrid)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw/nes/nes_hw.c
index 18a7de1c3923..71dd65806ac7 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -1001,8 +1001,8 @@ int nes_init_cqp(struct nes_device *nesdev)
 	}
 
 	/* Allocate a twice the number of CQP requests as the SQ size */
-	nesdev->nes_cqp_requests = kzalloc(sizeof(struct nes_cqp_request) *
-			2 * NES_CQP_SQ_SIZE, GFP_KERNEL);
+	nesdev->nes_cqp_requests = kzalloc(array3_size(sizeof(struct nes_cqp_request), 2, NES_CQP_SQ_SIZE),
+					   GFP_KERNEL);
 	if (!nesdev->nes_cqp_requests) {
 		pci_free_consistent(nesdev->pcidev, nesdev->cqp_mem_size, nesdev->cqp.sq_vbase,
 				nesdev->cqp.sq_pbase);
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
index 784ed6b09a46..1aea9f3f7a9f 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
@@ -843,8 +843,8 @@ static int ocrdma_build_pbl_tbl(struct ocrdma_dev *dev, struct ocrdma_hw_mr *mr)
 	void *va;
 	dma_addr_t pa;
 
-	mr->pbl_table = kzalloc(sizeof(struct ocrdma_pbl) *
-				mr->num_pbls, GFP_KERNEL);
+	mr->pbl_table = kzalloc(array_size(sizeof(struct ocrdma_pbl), mr->num_pbls),
+				GFP_KERNEL);
 
 	if (!mr->pbl_table)
 		return -ENOMEM;
@@ -1323,12 +1323,12 @@ static void ocrdma_set_qp_db(struct ocrdma_dev *dev, struct ocrdma_qp *qp,
 static int ocrdma_alloc_wr_id_tbl(struct ocrdma_qp *qp)
 {
 	qp->wqe_wr_id_tbl =
-	    kzalloc(sizeof(*(qp->wqe_wr_id_tbl)) * qp->sq.max_cnt,
+	    kzalloc(array_size(sizeof(*(qp->wqe_wr_id_tbl)), qp->sq.max_cnt),
 		    GFP_KERNEL);
 	if (qp->wqe_wr_id_tbl == NULL)
 		return -ENOMEM;
 	qp->rqe_wr_id_tbl =
-	    kzalloc(sizeof(u64) * qp->rq.max_cnt, GFP_KERNEL);
+	    kzalloc(array_size(sizeof(u64), qp->rq.max_cnt), GFP_KERNEL);
 	if (qp->rqe_wr_id_tbl == NULL)
 		return -ENOMEM;
 
@@ -1865,15 +1865,16 @@ struct ib_srq *ocrdma_create_srq(struct ib_pd *ibpd,
 
 	if (udata == NULL) {
 		status = -ENOMEM;
-		srq->rqe_wr_id_tbl = kzalloc(sizeof(u64) * srq->rq.max_cnt,
-			    GFP_KERNEL);
+		srq->rqe_wr_id_tbl = kzalloc(array_size(sizeof(u64), srq->rq.max_cnt),
+					     GFP_KERNEL);
 		if (srq->rqe_wr_id_tbl == NULL)
 			goto arm_err;
 
 		srq->bit_fields_len = (srq->rq.max_cnt / 32) +
 		    (srq->rq.max_cnt % 32 ? 1 : 0);
 		srq->idx_bit_fields =
-		    kmalloc(srq->bit_fields_len * sizeof(u32), GFP_KERNEL);
+		    kmalloc(array_size(srq->bit_fields_len, sizeof(u32)),
+			    GFP_KERNEL);
 		if (srq->idx_bit_fields == NULL)
 			goto arm_err;
 		memset(srq->idx_bit_fields, 0xff,
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index 7d3763b2e01c..3543de8dbb1b 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -1616,7 +1616,7 @@ static int qedr_create_kernel_qp(struct qedr_dev *dev,
 	qp->sq.max_wr = min_t(u32, attrs->cap.max_send_wr * dev->wq_multiplier,
 			      dev->attr.max_sqe);
 
-	qp->wqe_wr_id = kzalloc(qp->sq.max_wr * sizeof(*qp->wqe_wr_id),
+	qp->wqe_wr_id = kzalloc(array_size(qp->sq.max_wr, sizeof(*qp->wqe_wr_id)),
 				GFP_KERNEL);
 	if (!qp->wqe_wr_id) {
 		DP_ERR(dev, "create qp: failed SQ shadow memory allocation\n");
@@ -1634,7 +1634,7 @@ static int qedr_create_kernel_qp(struct qedr_dev *dev,
 	qp->rq.max_wr = (u16) max_t(u32, attrs->cap.max_recv_wr, 1);
 
 	/* Allocate driver internal RQ array */
-	qp->rqe_wr_id = kzalloc(qp->rq.max_wr * sizeof(*qp->rqe_wr_id),
+	qp->rqe_wr_id = kzalloc(array_size(qp->rq.max_wr, sizeof(*qp->rqe_wr_id)),
 				GFP_KERNEL);
 	if (!qp->rqe_wr_id) {
 		DP_ERR(dev,
diff --git a/drivers/infiniband/hw/qib/qib_iba6120.c b/drivers/infiniband/hw/qib/qib_iba6120.c
index 8a15e5c7dd91..dcaf5d5b23ca 100644
--- a/drivers/infiniband/hw/qib/qib_iba6120.c
+++ b/drivers/infiniband/hw/qib/qib_iba6120.c
@@ -2496,15 +2496,15 @@ static void init_6120_cntrnames(struct qib_devdata *dd)
 		dd->cspec->cntrnamelen = sizeof(cntr6120names) - 1;
 	else
 		dd->cspec->cntrnamelen = 1 + s - cntr6120names;
-	dd->cspec->cntrs = kmalloc(dd->cspec->ncntrs
-		* sizeof(u64), GFP_KERNEL);
+	dd->cspec->cntrs = kmalloc(array_size(dd->cspec->ncntrs, sizeof(u64)),
+				   GFP_KERNEL);
 
 	for (i = 0, s = (char *)portcntr6120names; s; i++)
 		s = strchr(s + 1, '\n');
 	dd->cspec->nportcntrs = i - 1;
 	dd->cspec->portcntrnamelen = sizeof(portcntr6120names) - 1;
-	dd->cspec->portcntrs = kmalloc(dd->cspec->nportcntrs
-		* sizeof(u64), GFP_KERNEL);
+	dd->cspec->portcntrs = kmalloc(array_size(dd->cspec->nportcntrs, sizeof(u64)),
+				       GFP_KERNEL);
 }
 
 static u32 qib_read_6120cntrs(struct qib_devdata *dd, loff_t pos, char **namep,
diff --git a/drivers/infiniband/hw/qib/qib_iba7220.c b/drivers/infiniband/hw/qib/qib_iba7220.c
index bdff2326731e..3b4439bc460b 100644
--- a/drivers/infiniband/hw/qib/qib_iba7220.c
+++ b/drivers/infiniband/hw/qib/qib_iba7220.c
@@ -3147,15 +3147,15 @@ static void init_7220_cntrnames(struct qib_devdata *dd)
 		dd->cspec->cntrnamelen = sizeof(cntr7220names) - 1;
 	else
 		dd->cspec->cntrnamelen = 1 + s - cntr7220names;
-	dd->cspec->cntrs = kmalloc(dd->cspec->ncntrs
-		* sizeof(u64), GFP_KERNEL);
+	dd->cspec->cntrs = kmalloc(array_size(dd->cspec->ncntrs, sizeof(u64)),
+				   GFP_KERNEL);
 
 	for (i = 0, s = (char *)portcntr7220names; s; i++)
 		s = strchr(s + 1, '\n');
 	dd->cspec->nportcntrs = i - 1;
 	dd->cspec->portcntrnamelen = sizeof(portcntr7220names) - 1;
-	dd->cspec->portcntrs = kmalloc(dd->cspec->nportcntrs
-		* sizeof(u64), GFP_KERNEL);
+	dd->cspec->portcntrs = kmalloc(array_size(dd->cspec->nportcntrs, sizeof(u64)),
+				       GFP_KERNEL);
 }
 
 static u32 qib_read_7220cntrs(struct qib_devdata *dd, loff_t pos, char **namep,
diff --git a/drivers/infiniband/hw/qib/qib_iba7322.c b/drivers/infiniband/hw/qib/qib_iba7322.c
index 57583362bf3e..01eb34949c6e 100644
--- a/drivers/infiniband/hw/qib/qib_iba7322.c
+++ b/drivers/infiniband/hw/qib/qib_iba7322.c
@@ -3648,8 +3648,8 @@ static int qib_do_7322_reset(struct qib_devdata *dd)
 
 	if (msix_entries) {
 		/* can be up to 512 bytes, too big for stack */
-		msix_vecsave = kmalloc(2 * dd->cspec->num_msix_entries *
-			sizeof(u64), GFP_KERNEL);
+		msix_vecsave = kmalloc(array3_size(2, dd->cspec->num_msix_entries, sizeof(u64)),
+				       GFP_KERNEL);
 	}
 
 	/*
@@ -5009,16 +5009,16 @@ static void init_7322_cntrnames(struct qib_devdata *dd)
 		dd->cspec->cntrnamelen = sizeof(cntr7322names) - 1;
 	else
 		dd->cspec->cntrnamelen = 1 + s - cntr7322names;
-	dd->cspec->cntrs = kmalloc(dd->cspec->ncntrs
-		* sizeof(u64), GFP_KERNEL);
+	dd->cspec->cntrs = kmalloc(array_size(dd->cspec->ncntrs, sizeof(u64)),
+				   GFP_KERNEL);
 
 	for (i = 0, s = (char *)portcntr7322names; s; i++)
 		s = strchr(s + 1, '\n');
 	dd->cspec->nportcntrs = i - 1;
 	dd->cspec->portcntrnamelen = sizeof(portcntr7322names) - 1;
 	for (i = 0; i < dd->num_pports; ++i) {
-		dd->pport[i].cpspec->portcntrs = kmalloc(dd->cspec->nportcntrs
-			* sizeof(u64), GFP_KERNEL);
+		dd->pport[i].cpspec->portcntrs = kmalloc(array_size(dd->cspec->nportcntrs, sizeof(u64)),
+							 GFP_KERNEL);
 	}
 }
 
diff --git a/drivers/infiniband/hw/qib/qib_init.c b/drivers/infiniband/hw/qib/qib_init.c
index 6c68f8a97018..aef7258fc768 100644
--- a/drivers/infiniband/hw/qib/qib_init.c
+++ b/drivers/infiniband/hw/qib/qib_init.c
@@ -1130,8 +1130,8 @@ struct qib_devdata *qib_alloc_devdata(struct pci_dev *pdev, size_t extra)
 	if (!qib_cpulist_count) {
 		u32 count = num_online_cpus();
 
-		qib_cpulist = kzalloc(BITS_TO_LONGS(count) *
-				      sizeof(long), GFP_KERNEL);
+		qib_cpulist = kzalloc(array_size(BITS_TO_LONGS(count), sizeof(long)),
+				      GFP_KERNEL);
 		if (qib_cpulist)
 			qib_cpulist_count = count;
 	}
diff --git a/drivers/infiniband/hw/usnic/usnic_ib_qp_grp.c b/drivers/infiniband/hw/usnic/usnic_ib_qp_grp.c
index 912d8ef04352..81f6d578cfe3 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_qp_grp.c
+++ b/drivers/infiniband/hw/usnic/usnic_ib_qp_grp.c
@@ -543,8 +543,8 @@ alloc_res_chunk_list(struct usnic_vnic *vnic,
 		/* Do Nothing */
 	}
 
-	res_chunk_list = kzalloc(sizeof(*res_chunk_list)*(res_lst_sz+1),
-					GFP_ATOMIC);
+	res_chunk_list = kzalloc(array_size(sizeof(*res_chunk_list), (res_lst_sz + 1)),
+				 GFP_ATOMIC);
 	if (!res_chunk_list)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/infiniband/ulp/iser/iser_initiator.c b/drivers/infiniband/ulp/iser/iser_initiator.c
index df49c4eb67f7..bab3bc3ff40f 100644
--- a/drivers/infiniband/ulp/iser/iser_initiator.c
+++ b/drivers/infiniband/ulp/iser/iser_initiator.c
@@ -258,8 +258,8 @@ int iser_alloc_rx_descriptors(struct iser_conn *iser_conn,
 		goto alloc_login_buf_fail;
 
 	iser_conn->num_rx_descs = session->cmds_max;
-	iser_conn->rx_descs = kmalloc(iser_conn->num_rx_descs *
-				sizeof(struct iser_rx_desc), GFP_KERNEL);
+	iser_conn->rx_descs = kmalloc(array_size(iser_conn->num_rx_descs, sizeof(struct iser_rx_desc)),
+				      GFP_KERNEL);
 	if (!iser_conn->rx_descs)
 		goto rx_desc_alloc_fail;
 
diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index c35d2cd37d70..da6b4fa10700 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -1035,7 +1035,7 @@ static int srp_alloc_req_data(struct srp_rdma_ch *ch)
 
 	for (i = 0; i < target->req_ring_size; ++i) {
 		req = &ch->req_ring[i];
-		mr_list = kmalloc(target->mr_per_cmd * sizeof(void *),
+		mr_list = kmalloc(array_size(target->mr_per_cmd, sizeof(void *)),
 				  GFP_KERNEL);
 		if (!mr_list)
 			goto out;
@@ -1043,8 +1043,8 @@ static int srp_alloc_req_data(struct srp_rdma_ch *ch)
 			req->fr_list = mr_list;
 		} else {
 			req->fmr_list = mr_list;
-			req->map_page = kmalloc(srp_dev->max_pages_per_mr *
-						sizeof(void *), GFP_KERNEL);
+			req->map_page = kmalloc(array_size(srp_dev->max_pages_per_mr, sizeof(void *)),
+						GFP_KERNEL);
 			if (!req->map_page)
 				goto out;
 		}
diff --git a/drivers/iommu/omap-iommu.c b/drivers/iommu/omap-iommu.c
index c33b7b104e72..4aad0dc2f25e 100644
--- a/drivers/iommu/omap-iommu.c
+++ b/drivers/iommu/omap-iommu.c
@@ -1455,7 +1455,8 @@ static int omap_iommu_add_device(struct device *dev)
 	if (num_iommus < 0)
 		return 0;
 
-	arch_data = kzalloc((num_iommus + 1) * sizeof(*arch_data), GFP_KERNEL);
+	arch_data = kzalloc(array_size((num_iommus + 1), sizeof(*arch_data)),
+			    GFP_KERNEL);
 	if (!arch_data)
 		return -ENOMEM;
 
diff --git a/drivers/irqchip/irq-alpine-msi.c b/drivers/irqchip/irq-alpine-msi.c
index 63d980995d17..f24b3d547dca 100644
--- a/drivers/irqchip/irq-alpine-msi.c
+++ b/drivers/irqchip/irq-alpine-msi.c
@@ -268,7 +268,7 @@ static int alpine_msix_init(struct device_node *node,
 		goto err_priv;
 	}
 
-	priv->msi_map = kzalloc(sizeof(*priv->msi_map) * BITS_TO_LONGS(priv->num_spis),
+	priv->msi_map = kzalloc(array_size(sizeof(*priv->msi_map), BITS_TO_LONGS(priv->num_spis)),
 				GFP_KERNEL);
 	if (!priv->msi_map) {
 		ret = -ENOMEM;
diff --git a/drivers/irqchip/irq-gic-v2m.c b/drivers/irqchip/irq-gic-v2m.c
index 1ff38aff9f29..6fb94d7bf75c 100644
--- a/drivers/irqchip/irq-gic-v2m.c
+++ b/drivers/irqchip/irq-gic-v2m.c
@@ -361,7 +361,7 @@ static int __init gicv2m_init_one(struct fwnode_handle *fwnode,
 		break;
 	}
 
-	v2m->bm = kzalloc(sizeof(long) * BITS_TO_LONGS(v2m->nr_spis),
+	v2m->bm = kzalloc(array_size(sizeof(long), BITS_TO_LONGS(v2m->nr_spis)),
 			  GFP_KERNEL);
 	if (!v2m->bm) {
 		ret = -ENOMEM;
diff --git a/drivers/irqchip/irq-gic-v3-its.c b/drivers/irqchip/irq-gic-v3-its.c
index d1a9972c4f58..4d526504e56a 100644
--- a/drivers/irqchip/irq-gic-v3-its.c
+++ b/drivers/irqchip/irq-gic-v3-its.c
@@ -1239,7 +1239,7 @@ static int its_vlpi_map(struct irq_data *d, struct its_cmd_info *info)
 	if (!its_dev->event_map.vm) {
 		struct its_vlpi_map *maps;
 
-		maps = kzalloc(sizeof(*maps) * its_dev->event_map.nr_lpis,
+		maps = kzalloc(array_size(sizeof(*maps), its_dev->event_map.nr_lpis),
 			       GFP_KERNEL);
 		if (!maps) {
 			ret = -ENOMEM;
@@ -1437,7 +1437,7 @@ static int __init its_lpi_init(u32 id_bits)
 {
 	lpi_chunks = its_lpi_to_chunk(1UL << id_bits);
 
-	lpi_bitmap = kzalloc(BITS_TO_LONGS(lpi_chunks) * sizeof(long),
+	lpi_bitmap = kzalloc(array_size(BITS_TO_LONGS(lpi_chunks), sizeof(long)),
 			     GFP_KERNEL);
 	if (!lpi_bitmap) {
 		lpi_chunks = 0;
@@ -1471,7 +1471,7 @@ static unsigned long *its_lpi_alloc_chunks(int nr_irqs, int *base, int *nr_ids)
 	if (!nr_chunks)
 		goto out;
 
-	bitmap = kzalloc(BITS_TO_LONGS(nr_chunks * IRQS_PER_CHUNK) * sizeof (long),
+	bitmap = kzalloc(array_size(BITS_TO_LONGS(nr_chunks * IRQS_PER_CHUNK), sizeof(long)),
 			 GFP_ATOMIC);
 	if (!bitmap)
 		goto out;
diff --git a/drivers/irqchip/irq-partition-percpu.c b/drivers/irqchip/irq-partition-percpu.c
index ccd72c2cbc23..b6fd0027b300 100644
--- a/drivers/irqchip/irq-partition-percpu.c
+++ b/drivers/irqchip/irq-partition-percpu.c
@@ -229,7 +229,7 @@ struct partition_desc *partition_create_desc(struct fwnode_handle *fwnode,
 		goto out;
 	desc->domain = d;
 
-	desc->bitmap = kzalloc(sizeof(long) * BITS_TO_LONGS(nr_parts),
+	desc->bitmap = kzalloc(array_size(sizeof(long), BITS_TO_LONGS(nr_parts)),
 			       GFP_KERNEL);
 	if (WARN_ON(!desc->bitmap))
 		goto out;
diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 49fef08858c5..0d137d918e21 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -2268,7 +2268,8 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 	strcpy(card->name, id);
 	card->contrnr = contr;
 	card->nbchan = profp->nbchannel;
-	card->bchans = kmalloc(sizeof(capidrv_bchan) * card->nbchan, GFP_ATOMIC);
+	card->bchans = kmalloc(array_size(sizeof(capidrv_bchan), card->nbchan),
+			       GFP_ATOMIC);
 	if (!card->bchans) {
 		printk(KERN_WARNING
 		       "capidrv: (%s) Could not allocate bchan-structs.\n", id);
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index ccec7778cad2..1b954e0072d4 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -252,7 +252,7 @@ static inline void dump_rawmsg(enum debuglevel level, const char *tag,
 		return;
 	if (l > 64)
 		l = 64; /* arbitrary limit */
-	dbgline = kmalloc(3 * l, GFP_ATOMIC);
+	dbgline = kmalloc(array_size(3, l), GFP_ATOMIC);
 	if (!dbgline)
 		return;
 	for (i = 0; i < l; i++) {
@@ -272,7 +272,7 @@ static inline void dump_rawmsg(enum debuglevel level, const char *tag,
 			return;
 		if (l > 64)
 			l = 64; /* arbitrary limit */
-		dbgline = kmalloc(3 * l, GFP_ATOMIC);
+		dbgline = kmalloc(array_size(3, l), GFP_ATOMIC);
 		if (!dbgline)
 			return;
 		data += CAPIMSG_LEN(data);
@@ -1370,7 +1370,7 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	cmsg->adr.adrPLCI |= (bcs->channel + 1) << 8;
 
 	/* build command table */
-	commands = kzalloc(AT_NUM * (sizeof *commands), GFP_KERNEL);
+	commands = kzalloc(array_size(AT_NUM, (sizeof *commands)), GFP_KERNEL);
 	if (!commands)
 		goto oom;
 
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 2d75329007f1..b7345c68c4a6 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -243,7 +243,8 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		dev_kfree_skb(bcs->rx_skb);
 		gigaset_new_rx_skb(bcs);
 
-		commands = kzalloc(AT_NUM * (sizeof *commands), GFP_ATOMIC);
+		commands = kzalloc(array_size(AT_NUM, (sizeof *commands)),
+				   GFP_ATOMIC);
 		if (!commands) {
 			gigaset_free_channel(bcs);
 			dev_err(cs->dev, "ISDN_CMD_DIAL: out of memory\n");
diff --git a/drivers/isdn/hisax/fsm.c b/drivers/isdn/hisax/fsm.c
index 3e020ec0f65e..5ed317482f3f 100644
--- a/drivers/isdn/hisax/fsm.c
+++ b/drivers/isdn/hisax/fsm.c
@@ -27,7 +27,8 @@ FsmNew(struct Fsm *fsm, struct FsmNode *fnlist, int fncount)
 	int i;
 
 	fsm->jumpmatrix =
-		kzalloc(sizeof(FSMFNPTR) * fsm->state_count * fsm->event_count, GFP_KERNEL);
+		kzalloc(array3_size(sizeof(FSMFNPTR), fsm->state_count, fsm->event_count),
+			GFP_KERNEL);
 	if (!fsm->jumpmatrix)
 		return -ENOMEM;
 
diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index b628da5e2d2e..fd136ec9028c 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -2103,7 +2103,8 @@ isdn_add_channels(isdn_driver_t *d, int drvidx, int n, int adding)
 
 	if ((adding) && (d->rcv_waitq))
 		kfree(d->rcv_waitq);
-	d->rcv_waitq = kmalloc(sizeof(wait_queue_head_t) * 2 * m, GFP_ATOMIC);
+	d->rcv_waitq = kmalloc(array3_size(sizeof(wait_queue_head_t), 2, m),
+			       GFP_ATOMIC);
 	if (!d->rcv_waitq) {
 		printk(KERN_WARNING "register_isdn: Could not alloc rcv_waitq\n");
 		if (!adding) {
diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
index cabcb906e0b5..0cf9ec54eca4 100644
--- a/drivers/isdn/mISDN/fsm.c
+++ b/drivers/isdn/mISDN/fsm.c
@@ -32,8 +32,8 @@ mISDN_FsmNew(struct Fsm *fsm,
 {
 	int i;
 
-	fsm->jumpmatrix = kzalloc(sizeof(FSMFNPTR) * fsm->state_count *
-				  fsm->event_count, GFP_KERNEL);
+	fsm->jumpmatrix = kzalloc(array3_size(sizeof(FSMFNPTR), fsm->state_count, fsm->event_count),
+				  GFP_KERNEL);
 	if (fsm->jumpmatrix == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/lightnvm/pblk-init.c b/drivers/lightnvm/pblk-init.c
index 91a5bc2556a3..ae92984028d8 100644
--- a/drivers/lightnvm/pblk-init.c
+++ b/drivers/lightnvm/pblk-init.c
@@ -366,8 +366,8 @@ static int pblk_core_init(struct pblk *pblk)
 		return -EINVAL;
 	}
 
-	pblk->pad_dist = kzalloc((pblk->min_write_pgs - 1) * sizeof(atomic64_t),
-								GFP_KERNEL);
+	pblk->pad_dist = kzalloc(array_size((pblk->min_write_pgs - 1), sizeof(atomic64_t)),
+				 GFP_KERNEL);
 	if (!pblk->pad_dist)
 		return -ENOMEM;
 
@@ -814,8 +814,8 @@ static int pblk_alloc_line_meta(struct pblk *pblk, struct pblk_line *line)
 		return -ENOMEM;
 	}
 
-	line->chks = kmalloc(lm->blk_per_line * sizeof(struct nvm_chk_meta),
-								GFP_KERNEL);
+	line->chks = kmalloc(array_size(lm->blk_per_line, sizeof(struct nvm_chk_meta)),
+			     GFP_KERNEL);
 	if (!line->chks) {
 		kfree(line->erase_bitmap);
 		kfree(line->blk_bitmap);
diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
index 3dea06b41d43..6572df9cecf0 100644
--- a/drivers/md/bcache/super.c
+++ b/drivers/md/bcache/super.c
@@ -1690,7 +1690,7 @@ struct cache_set *bch_cache_set_alloc(struct cache_sb *sb)
 	iter_size = (sb->bucket_size / sb->block_size + 1) *
 		sizeof(struct btree_iter_set);
 
-	if (!(c->devices = kzalloc(c->nr_uuids * sizeof(void *), GFP_KERNEL)) ||
+	if (!(c->devices = kzalloc(array_size(c->nr_uuids, sizeof(void *)), GFP_KERNEL)) ||
 	    !(c->bio_meta = mempool_create_kmalloc_pool(2,
 				sizeof(struct bbio) + sizeof(struct bio_vec) *
 				bucket_pages(c))) ||
@@ -2018,8 +2018,7 @@ static int cache_alloc(struct cache *ca)
 	    !init_heap(&ca->heap,	free << 3, GFP_KERNEL) ||
 	    !(ca->buckets	= vzalloc(sizeof(struct bucket) *
 					  ca->sb.nbuckets)) ||
-	    !(ca->prio_buckets	= kzalloc(sizeof(uint64_t) * prio_buckets(ca) *
-					  2, GFP_KERNEL)) ||
+	    !(ca->prio_buckets	= kzalloc(array3_size(sizeof(uint64_t), prio_buckets(ca), 2), GFP_KERNEL)) ||
 	    !(ca->disk_buckets	= alloc_bucket_pages(GFP_KERNEL, ca)))
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 44ff473dab3e..cb24b2cd8169 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1878,8 +1878,8 @@ static int crypt_alloc_tfms_skcipher(struct crypt_config *cc, char *ciphermode)
 	unsigned i;
 	int err;
 
-	cc->cipher_tfm.tfms = kzalloc(cc->tfms_count *
-				      sizeof(struct crypto_skcipher *), GFP_KERNEL);
+	cc->cipher_tfm.tfms = kzalloc(array_size(cc->tfms_count, sizeof(struct crypto_skcipher *)),
+				      GFP_KERNEL);
 	if (!cc->cipher_tfm.tfms)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-integrity.c b/drivers/md/dm-integrity.c
index 9c354be188d4..71ba1b1f8844 100644
--- a/drivers/md/dm-integrity.c
+++ b/drivers/md/dm-integrity.c
@@ -2448,7 +2448,8 @@ static struct scatterlist **dm_integrity_alloc_journal_scatterlist(struct dm_int
 	struct scatterlist **sl;
 	unsigned i;
 
-	sl = kvmalloc(ic->journal_sections * sizeof(struct scatterlist *), GFP_KERNEL | __GFP_ZERO);
+	sl = kvmalloc(array_size(ic->journal_sections, sizeof(struct scatterlist *)),
+		      GFP_KERNEL | __GFP_ZERO);
 	if (!sl)
 		return NULL;
 
@@ -2644,7 +2645,8 @@ static int create_journal(struct dm_integrity_c *ic, char **error)
 				goto bad;
 			}
 
-			sg = kvmalloc((ic->journal_pages + 1) * sizeof(struct scatterlist), GFP_KERNEL);
+			sg = kvmalloc(array_size((ic->journal_pages + 1), sizeof(struct scatterlist)),
+				      GFP_KERNEL);
 			if (!sg) {
 				*error = "Unable to allocate sg list";
 				r = -ENOMEM;
@@ -2710,7 +2712,8 @@ static int create_journal(struct dm_integrity_c *ic, char **error)
 				r = -ENOMEM;
 				goto bad;
 			}
-			ic->sk_requests = kvmalloc(ic->journal_sections * sizeof(struct skcipher_request *), GFP_KERNEL | __GFP_ZERO);
+			ic->sk_requests = kvmalloc(array_size(ic->journal_sections, sizeof(struct skcipher_request *)),
+						   GFP_KERNEL | __GFP_ZERO);
 			if (!ic->sk_requests) {
 				*error = "Unable to allocate sk requests";
 				r = -ENOMEM;
@@ -2744,7 +2747,8 @@ static int create_journal(struct dm_integrity_c *ic, char **error)
 					r = -ENOMEM;
 					goto bad;
 				}
-				section_req->iv = kmalloc(ivsize * 2, GFP_KERNEL);
+				section_req->iv = kmalloc(array_size(ivsize, 2),
+							  GFP_KERNEL);
 				if (!section_req->iv) {
 					skcipher_request_free(section_req);
 					*error = "Unable to allocate iv";
diff --git a/drivers/md/dm-stats.c b/drivers/md/dm-stats.c
index 56059fb56e2d..7e596d510539 100644
--- a/drivers/md/dm-stats.c
+++ b/drivers/md/dm-stats.c
@@ -915,7 +915,8 @@ static int parse_histogram(const char *h, unsigned *n_histogram_entries,
 		if (*q == ',')
 			(*n_histogram_entries)++;
 
-	*histogram_boundaries = kmalloc(*n_histogram_entries * sizeof(unsigned long long), GFP_KERNEL);
+	*histogram_boundaries = kmalloc(array_size(*n_histogram_entries, sizeof(unsigned long long)),
+					GFP_KERNEL);
 	if (!*histogram_boundaries)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-verity-target.c b/drivers/md/dm-verity-target.c
index fc893f636a98..a3c93bf054c6 100644
--- a/drivers/md/dm-verity-target.c
+++ b/drivers/md/dm-verity-target.c
@@ -797,8 +797,8 @@ static int verity_alloc_most_once(struct dm_verity *v)
 		return -E2BIG;
 	}
 
-	v->validated_blocks = kvzalloc(BITS_TO_LONGS(v->data_blocks) *
-				       sizeof(unsigned long), GFP_KERNEL);
+	v->validated_blocks = kvzalloc(array_size(BITS_TO_LONGS(v->data_blocks), sizeof(unsigned long)),
+				       GFP_KERNEL);
 	if (!v->validated_blocks) {
 		ti->error = "failed to allocate bitset for check_at_most_once";
 		return -ENOMEM;
diff --git a/drivers/md/md-cluster.c b/drivers/md/md-cluster.c
index 79bfbc840385..c65cc9986656 100644
--- a/drivers/md/md-cluster.c
+++ b/drivers/md/md-cluster.c
@@ -1380,9 +1380,8 @@ static int lock_all_bitmaps(struct mddev *mddev)
 	char str[64];
 	struct md_cluster_info *cinfo = mddev->cluster_info;
 
-	cinfo->other_bitmap_lockres = kzalloc((mddev->bitmap_info.nodes - 1) *
-					     sizeof(struct dlm_lock_resource *),
-					     GFP_KERNEL);
+	cinfo->other_bitmap_lockres = kzalloc(array_size((mddev->bitmap_info.nodes - 1), sizeof(struct dlm_lock_resource *)),
+					      GFP_KERNEL);
 	if (!cinfo->other_bitmap_lockres) {
 		pr_err("md: can't alloc mem for other bitmap locks\n");
 		return 0;
diff --git a/drivers/md/md-multipath.c b/drivers/md/md-multipath.c
index 0a7e99d62c69..7836a23f92d8 100644
--- a/drivers/md/md-multipath.c
+++ b/drivers/md/md-multipath.c
@@ -398,7 +398,7 @@ static int multipath_run (struct mddev *mddev)
 	if (!conf)
 		goto out;
 
-	conf->multipaths = kzalloc(sizeof(struct multipath_info)*mddev->raid_disks,
+	conf->multipaths = kzalloc(array_size(sizeof(struct multipath_info), mddev->raid_disks),
 				   GFP_KERNEL);
 	if (!conf->multipaths)
 		goto out_free_conf;
diff --git a/drivers/md/raid0.c b/drivers/md/raid0.c
index 584c10347267..a99f1e35a0a6 100644
--- a/drivers/md/raid0.c
+++ b/drivers/md/raid0.c
@@ -159,12 +159,11 @@ static int create_strip_zones(struct mddev *mddev, struct r0conf **private_conf)
 	}
 
 	err = -ENOMEM;
-	conf->strip_zone = kzalloc(sizeof(struct strip_zone)*
-				conf->nr_strip_zones, GFP_KERNEL);
+	conf->strip_zone = kzalloc(array_size(sizeof(struct strip_zone), conf->nr_strip_zones),
+				   GFP_KERNEL);
 	if (!conf->strip_zone)
 		goto abort;
-	conf->devlist = kzalloc(sizeof(struct md_rdev*)*
-				conf->nr_strip_zones*mddev->raid_disks,
+	conf->devlist = kzalloc(array3_size(sizeof(struct md_rdev *), conf->nr_strip_zones, mddev->raid_disks),
 				GFP_KERNEL);
 	if (!conf->devlist)
 		goto abort;
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index e9e3308cb0a7..13f74e2c9ef8 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -126,7 +126,7 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void *data)
 	if (!r1_bio)
 		return NULL;
 
-	rps = kmalloc(sizeof(struct resync_pages) * pi->raid_disks,
+	rps = kmalloc(array_size(sizeof(struct resync_pages), pi->raid_disks),
 		      gfp_flags);
 	if (!rps)
 		goto out_free_r1bio;
@@ -2939,9 +2939,8 @@ static struct r1conf *setup_conf(struct mddev *mddev)
 	if (!conf->barrier)
 		goto abort;
 
-	conf->mirrors = kzalloc(sizeof(struct raid1_info)
-				* mddev->raid_disks * 2,
-				 GFP_KERNEL);
+	conf->mirrors = kzalloc(array3_size(sizeof(struct raid1_info), mddev->raid_disks, 2),
+				GFP_KERNEL);
 	if (!conf->mirrors)
 		goto abort;
 
@@ -3243,7 +3242,7 @@ static int raid1_reshape(struct mddev *mddev)
 		kfree(newpoolinfo);
 		return -ENOMEM;
 	}
-	newmirrors = kzalloc(sizeof(struct raid1_info) * raid_disks * 2,
+	newmirrors = kzalloc(array3_size(sizeof(struct raid1_info), raid_disks, 2),
 			     GFP_KERNEL);
 	if (!newmirrors) {
 		kfree(newpoolinfo);
diff --git a/drivers/md/raid10.c b/drivers/md/raid10.c
index 2a7bd1000cb5..7bd1077d5986 100644
--- a/drivers/md/raid10.c
+++ b/drivers/md/raid10.c
@@ -3688,8 +3688,7 @@ static struct r10conf *setup_conf(struct mddev *mddev)
 		goto out;
 
 	/* FIXME calc properly */
-	conf->mirrors = kzalloc(sizeof(struct raid10_info)*(mddev->raid_disks +
-							    max(0,-mddev->delta_disks)),
+	conf->mirrors = kzalloc(array_size(sizeof(struct raid10_info), (mddev->raid_disks + max(0, -mddev->delta_disks))),
 				GFP_KERNEL);
 	if (!conf->mirrors)
 		goto out;
@@ -4130,11 +4129,8 @@ static int raid10_check_reshape(struct mddev *mddev)
 	conf->mirrors_new = NULL;
 	if (mddev->delta_disks > 0) {
 		/* allocate new 'mirrors' list */
-		conf->mirrors_new = kzalloc(
-			sizeof(struct raid10_info)
-			*(mddev->raid_disks +
-			  mddev->delta_disks),
-			GFP_KERNEL);
+		conf->mirrors_new = kzalloc(array_size(sizeof(struct raid10_info), (mddev->raid_disks + mddev->delta_disks)),
+					    GFP_KERNEL);
 		if (!conf->mirrors_new)
 			return -ENOMEM;
 	}
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index c08d83dcf1e2..7d0c5c6bcce5 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -6659,9 +6659,9 @@ static int alloc_thread_groups(struct r5conf *conf, int cnt,
 	}
 	*group_cnt = num_possible_nodes();
 	size = sizeof(struct r5worker) * cnt;
-	workers = kzalloc(size * *group_cnt, GFP_NOIO);
-	*worker_groups = kzalloc(sizeof(struct r5worker_group) *
-				*group_cnt, GFP_NOIO);
+	workers = kzalloc(array_size(size, *group_cnt), GFP_NOIO);
+	*worker_groups = kzalloc(array_size(sizeof(struct r5worker_group), *group_cnt),
+				 GFP_NOIO);
 	if (!*worker_groups || !workers) {
 		kfree(workers);
 		kfree(*worker_groups);
diff --git a/drivers/media/pci/bt8xx/bttv-risc.c b/drivers/media/pci/bt8xx/bttv-risc.c
index 3859dde98be2..3185c4ae2269 100644
--- a/drivers/media/pci/bt8xx/bttv-risc.c
+++ b/drivers/media/pci/bt8xx/bttv-risc.c
@@ -255,7 +255,7 @@ bttv_risc_overlay(struct bttv *btv, struct btcx_riscmem *risc,
 	u32 addr;
 
 	/* skip list for window clipping */
-	if (NULL == (skips = kmalloc(sizeof(*skips) * ov->nclips,GFP_KERNEL)))
+	if (NULL == (skips = kmalloc(array_size(sizeof(*skips), ov->nclips), GFP_KERNEL)))
 		return -ENOMEM;
 
 	/* estimate risc mem: worst case is (1.5*clip+1) * lines instructions
diff --git a/drivers/media/pci/ivtv/ivtv-yuv.c b/drivers/media/pci/ivtv/ivtv-yuv.c
index 44936d6d7c39..3a03251068b4 100644
--- a/drivers/media/pci/ivtv/ivtv-yuv.c
+++ b/drivers/media/pci/ivtv/ivtv-yuv.c
@@ -935,7 +935,8 @@ static void ivtv_yuv_init(struct ivtv *itv)
 	}
 
 	/* We need a buffer for blanking when Y plane is offset - non-fatal if we can't get one */
-	yi->blanking_ptr = kzalloc(720 * 16, GFP_KERNEL|__GFP_NOWARN);
+	yi->blanking_ptr = kzalloc(array_size(720, 16),
+				   GFP_KERNEL | __GFP_NOWARN);
 	if (yi->blanking_ptr) {
 		yi->blanking_dmaptr = pci_map_single(itv->pdev, yi->blanking_ptr, 720*16, PCI_DMA_TODEVICE);
 	} else {
diff --git a/drivers/media/pci/saa7164/saa7164-fw.c b/drivers/media/pci/saa7164/saa7164-fw.c
index ef4906406ebf..5d6b62cd39bd 100644
--- a/drivers/media/pci/saa7164/saa7164-fw.c
+++ b/drivers/media/pci/saa7164/saa7164-fw.c
@@ -89,7 +89,7 @@ static int saa7164_downloadimage(struct saa7164_dev *dev, u8 *src, u32 srcsize,
 		goto out;
 	}
 
-	srcbuf = kzalloc(4 * 1048576, GFP_KERNEL);
+	srcbuf = kzalloc(array_size(4, 1048576), GFP_KERNEL);
 	if (NULL == srcbuf) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/drivers/media/pci/zoran/zoran_card.c b/drivers/media/pci/zoran/zoran_card.c
index a6b9ebd20263..4efe363f96cf 100644
--- a/drivers/media/pci/zoran/zoran_card.c
+++ b/drivers/media/pci/zoran/zoran_card.c
@@ -1028,7 +1028,7 @@ static int zr36057_init (struct zoran *zr)
 
 	/* allocate memory *before* doing anything to the hardware
 	 * in case allocation fails */
-	zr->stat_com = kzalloc(BUZ_NUM_STAT_COM * 4, GFP_KERNEL);
+	zr->stat_com = kzalloc(array_size(BUZ_NUM_STAT_COM, 4), GFP_KERNEL);
 	zr->video_dev = video_device_alloc();
 	if (!zr->stat_com || !zr->video_dev) {
 		dprintk(1,
diff --git a/drivers/media/pci/zoran/zoran_driver.c b/drivers/media/pci/zoran/zoran_driver.c
index 14f9c0e26a1c..1296dafb7c4d 100644
--- a/drivers/media/pci/zoran/zoran_driver.c
+++ b/drivers/media/pci/zoran/zoran_driver.c
@@ -941,7 +941,7 @@ static int zoran_open(struct file *file)
 	/* used to be BUZ_MAX_WIDTH/HEIGHT, but that gives overflows
 	 * on norm-change! */
 	fh->overlay_mask =
-	    kmalloc(((768 + 31) / 32) * 576 * 4, GFP_KERNEL);
+	    kmalloc(array3_size(((768 + 31) / 32), 576, 4), GFP_KERNEL);
 	if (!fh->overlay_mask) {
 		dprintk(1,
 			KERN_ERR
diff --git a/drivers/media/platform/vivid/vivid-core.c b/drivers/media/platform/vivid/vivid-core.c
index 82ec216f2ad8..9042f17de0bc 100644
--- a/drivers/media/platform/vivid/vivid-core.c
+++ b/drivers/media/platform/vivid/vivid-core.c
@@ -859,8 +859,8 @@ static int vivid_create_instance(struct platform_device *pdev, int inst)
 	/* create a string array containing the names of all the preset timings */
 	while (v4l2_dv_timings_presets[dev->query_dv_timings_size].bt.width)
 		dev->query_dv_timings_size++;
-	dev->query_dv_timings_qmenu = kmalloc(dev->query_dv_timings_size *
-					   (sizeof(void *) + 32), GFP_KERNEL);
+	dev->query_dv_timings_qmenu = kmalloc(array_size(dev->query_dv_timings_size, (sizeof(void *) + 32)),
+					      GFP_KERNEL);
 	if (dev->query_dv_timings_qmenu == NULL)
 		goto free_dev;
 	for (i = 0; i < dev->query_dv_timings_size; i++) {
diff --git a/drivers/media/spi/cxd2880-spi.c b/drivers/media/spi/cxd2880-spi.c
index 4df3bd312f48..a86889992dc7 100644
--- a/drivers/media/spi/cxd2880-spi.c
+++ b/drivers/media/spi/cxd2880-spi.c
@@ -398,7 +398,7 @@ static int cxd2880_start_feed(struct dvb_demux_feed *feed)
 
 	if (dvb_spi->feed_count == 0) {
 		dvb_spi->ts_buf =
-			kmalloc(MAX_TRANS_PKT * 188,
+			kmalloc(array_size(MAX_TRANS_PKT, 188),
 				GFP_KERNEL | GFP_DMA);
 		if (!dvb_spi->ts_buf) {
 			pr_err("ts buffer allocate failed\n");
diff --git a/drivers/media/usb/cx231xx/cx231xx-audio.c b/drivers/media/usb/cx231xx/cx231xx-audio.c
index d96236d786d1..651f5381f3b3 100644
--- a/drivers/media/usb/cx231xx/cx231xx-audio.c
+++ b/drivers/media/usb/cx231xx/cx231xx-audio.c
@@ -710,7 +710,8 @@ static int cx231xx_audio_init(struct cx231xx *dev)
 	dev_info(dev->dev,
 		"audio EndPoint Addr 0x%x, Alternate settings: %i\n",
 		adev->end_point_addr, adev->num_alt);
-	adev->alt_max_pkt_size = kmalloc(32 * adev->num_alt, GFP_KERNEL);
+	adev->alt_max_pkt_size = kmalloc(array_size(32, adev->num_alt),
+					 GFP_KERNEL);
 	if (!adev->alt_max_pkt_size) {
 		err = -ENOMEM;
 		goto err_free_card;
diff --git a/drivers/media/usb/go7007/go7007-fw.c b/drivers/media/usb/go7007/go7007-fw.c
index 60bf5f0644d1..8ff27ee28703 100644
--- a/drivers/media/usb/go7007/go7007-fw.c
+++ b/drivers/media/usb/go7007/go7007-fw.c
@@ -1576,7 +1576,7 @@ int go7007_construct_fw_image(struct go7007 *go, u8 **fw, int *fwlen)
 			GO7007_FW_NAME);
 		return -1;
 	}
-	code = kzalloc(codespace * 2, GFP_KERNEL);
+	code = kzalloc(array_size(codespace, 2), GFP_KERNEL);
 	if (code == NULL)
 		goto fw_failed;
 
diff --git a/drivers/media/usb/gspca/t613.c b/drivers/media/usb/gspca/t613.c
index 0ae557cd15ef..36b87e714de4 100644
--- a/drivers/media/usb/gspca/t613.c
+++ b/drivers/media/usb/gspca/t613.c
@@ -363,7 +363,7 @@ static void reg_w_ixbuf(struct gspca_dev *gspca_dev,
 	if (len * 2 <= USB_BUF_SZ) {
 		p = tmpbuf = gspca_dev->usb_buf;
 	} else {
-		p = tmpbuf = kmalloc(len * 2, GFP_KERNEL);
+		p = tmpbuf = kmalloc(array_size(len, 2), GFP_KERNEL);
 		if (!tmpbuf) {
 			pr_err("Out of memory\n");
 			return;
diff --git a/drivers/media/usb/pvrusb2/pvrusb2-hdw.c b/drivers/media/usb/pvrusb2/pvrusb2-hdw.c
index e0353161ccd6..72dde82f3ade 100644
--- a/drivers/media/usb/pvrusb2/pvrusb2-hdw.c
+++ b/drivers/media/usb/pvrusb2/pvrusb2-hdw.c
@@ -2413,7 +2413,7 @@ struct pvr2_hdw *pvr2_hdw_create(struct usb_interface *intf,
 
 	hdw->control_cnt = CTRLDEF_COUNT;
 	hdw->control_cnt += MPEGDEF_COUNT;
-	hdw->controls = kzalloc(sizeof(struct pvr2_ctrl) * hdw->control_cnt,
+	hdw->controls = kzalloc(array_size(sizeof(struct pvr2_ctrl), hdw->control_cnt),
 				GFP_KERNEL);
 	if (!hdw->controls) goto fail;
 	hdw->hdw_desc = hdw_desc;
diff --git a/drivers/media/usb/stk1160/stk1160-core.c b/drivers/media/usb/stk1160/stk1160-core.c
index bea8bbbb84fb..93a0daaaf03f 100644
--- a/drivers/media/usb/stk1160/stk1160-core.c
+++ b/drivers/media/usb/stk1160/stk1160-core.c
@@ -288,8 +288,8 @@ static int stk1160_probe(struct usb_interface *interface,
 		return -ENODEV;
 
 	/* Alloc an array for all possible max_pkt_size */
-	alt_max_pkt_size = kmalloc(sizeof(alt_max_pkt_size[0]) *
-			interface->num_altsetting, GFP_KERNEL);
+	alt_max_pkt_size = kmalloc(array_size(sizeof(alt_max_pkt_size[0]), interface->num_altsetting),
+				   GFP_KERNEL);
 	if (alt_max_pkt_size == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/media/usb/usbvision/usbvision-video.c b/drivers/media/usb/usbvision/usbvision-video.c
index 0f5954a1fea2..fd54491c1c0c 100644
--- a/drivers/media/usb/usbvision/usbvision-video.c
+++ b/drivers/media/usb/usbvision/usbvision-video.c
@@ -1492,7 +1492,8 @@ static int usbvision_probe(struct usb_interface *intf,
 
 	usbvision->num_alt = uif->num_altsetting;
 	PDEBUG(DBG_PROBE, "Alternate settings: %i", usbvision->num_alt);
-	usbvision->alt_max_pkt_size = kmalloc(32 * usbvision->num_alt, GFP_KERNEL);
+	usbvision->alt_max_pkt_size = kmalloc(array_size(32, usbvision->num_alt),
+					      GFP_KERNEL);
 	if (!usbvision->alt_max_pkt_size) {
 		ret = -ENOMEM;
 		goto err_pkt;
diff --git a/drivers/media/usb/uvc/uvc_video.c b/drivers/media/usb/uvc/uvc_video.c
index aa0082fe5833..22dbc3067e33 100644
--- a/drivers/media/usb/uvc/uvc_video.c
+++ b/drivers/media/usb/uvc/uvc_video.c
@@ -501,7 +501,7 @@ static int uvc_video_clock_init(struct uvc_streaming *stream)
 	spin_lock_init(&clock->lock);
 	clock->size = 32;
 
-	clock->samples = kmalloc(clock->size * sizeof(*clock->samples),
+	clock->samples = kmalloc(array_size(clock->size, sizeof(*clock->samples)),
 				 GFP_KERNEL);
 	if (clock->samples == NULL)
 		return -ENOMEM;
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 7770034aae28..631fe7aa2784 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -175,7 +175,8 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 	dma->offset = data & ~PAGE_MASK;
 	dma->size = size;
 	dma->nr_pages = last-first+1;
-	dma->pages = kmalloc(dma->nr_pages * sizeof(struct page *), GFP_KERNEL);
+	dma->pages = kmalloc(array_size(dma->nr_pages, sizeof(struct page *)),
+			     GFP_KERNEL);
 	if (NULL == dma->pages)
 		return -ENOMEM;
 
diff --git a/drivers/memstick/core/ms_block.c b/drivers/memstick/core/ms_block.c
index a3db881094e1..be04ccd7cd84 100644
--- a/drivers/memstick/core/ms_block.c
+++ b/drivers/memstick/core/ms_block.c
@@ -1342,7 +1342,8 @@ static int msb_ftl_initialize(struct msb_data *msb)
 	msb->used_blocks_bitmap = kzalloc(msb->block_count / 8, GFP_KERNEL);
 	msb->erased_blocks_bitmap = kzalloc(msb->block_count / 8, GFP_KERNEL);
 	msb->lba_to_pba_table =
-		kmalloc(msb->logical_block_count * sizeof(u16), GFP_KERNEL);
+		kmalloc(array_size(msb->logical_block_count, sizeof(u16)),
+			GFP_KERNEL);
 
 	if (!msb->used_blocks_bitmap || !msb->lba_to_pba_table ||
 						!msb->erased_blocks_bitmap) {
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index 55dd71bbdc2a..a2b1766e52fb 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -394,7 +394,8 @@ mpt_lan_open(struct net_device *dev)
 				"a moment.\n");
 	}
 
-	priv->mpt_txfidx = kmalloc(priv->tx_max_out * sizeof(int), GFP_KERNEL);
+	priv->mpt_txfidx = kmalloc(array_size(priv->tx_max_out, sizeof(int)),
+				   GFP_KERNEL);
 	if (priv->mpt_txfidx == NULL)
 		goto out;
 	priv->mpt_txfidx_tail = -1;
@@ -408,7 +409,7 @@ mpt_lan_open(struct net_device *dev)
 
 	dlprintk((KERN_INFO MYNAM "@lo: Finished initializing SendCtl\n"));
 
-	priv->mpt_rxfidx = kmalloc(priv->max_buckets_out * sizeof(int),
+	priv->mpt_rxfidx = kmalloc(array_size(priv->max_buckets_out, sizeof(int)),
 				   GFP_KERNEL);
 	if (priv->mpt_rxfidx == NULL)
 		goto out_SendCtl;
diff --git a/drivers/mfd/cros_ec_dev.c b/drivers/mfd/cros_ec_dev.c
index eafd06f62a3a..8fdb6d491ecc 100644
--- a/drivers/mfd/cros_ec_dev.c
+++ b/drivers/mfd/cros_ec_dev.c
@@ -306,13 +306,13 @@ static void cros_ec_sensors_register(struct cros_ec_dev *ec)
 	resp = (struct ec_response_motion_sense *)msg->data;
 	sensor_num = resp->dump.sensor_count;
 	/* Allocate 1 extra sensors in FIFO are needed */
-	sensor_cells = kzalloc(sizeof(struct mfd_cell) * (sensor_num + 1),
+	sensor_cells = kzalloc(array_size(sizeof(struct mfd_cell), (sensor_num + 1)),
 			       GFP_KERNEL);
 	if (sensor_cells == NULL)
 		goto error;
 
-	sensor_platforms = kzalloc(sizeof(struct cros_ec_sensor_platform) *
-		  (sensor_num + 1), GFP_KERNEL);
+	sensor_platforms = kzalloc(array_size(sizeof(struct cros_ec_sensor_platform), (sensor_num + 1)),
+				   GFP_KERNEL);
 	if (sensor_platforms == NULL)
 		goto error_platforms;
 
diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
index c57e407020f1..1af9c406b192 100644
--- a/drivers/mfd/mfd-core.c
+++ b/drivers/mfd/mfd-core.c
@@ -158,7 +158,8 @@ static int mfd_add_device(struct device *parent, int id,
 	if (!pdev)
 		goto fail_alloc;
 
-	res = kzalloc(sizeof(*res) * cell->num_resources, GFP_KERNEL);
+	res = kzalloc(array_size(sizeof(*res), cell->num_resources),
+		      GFP_KERNEL);
 	if (!res)
 		goto fail_device;
 
diff --git a/drivers/misc/eeprom/idt_89hpesx.c b/drivers/misc/eeprom/idt_89hpesx.c
index 34a5a41578d7..967f522a22a8 100644
--- a/drivers/misc/eeprom/idt_89hpesx.c
+++ b/drivers/misc/eeprom/idt_89hpesx.c
@@ -964,7 +964,8 @@ static ssize_t idt_dbgfs_csr_write(struct file *filep, const char __user *ubuf,
 	if (colon_ch != NULL) {
 		csraddr_len = colon_ch - buf;
 		csraddr_str =
-			kmalloc(sizeof(char)*(csraddr_len + 1), GFP_KERNEL);
+			kmalloc(array_size(sizeof(char), (csraddr_len + 1)),
+				GFP_KERNEL);
 		if (csraddr_str == NULL) {
 			ret = -ENOMEM;
 			goto free_buf;
diff --git a/drivers/misc/genwqe/card_ddcb.c b/drivers/misc/genwqe/card_ddcb.c
index b7f8d35c17a9..f9c05dd7b7dc 100644
--- a/drivers/misc/genwqe/card_ddcb.c
+++ b/drivers/misc/genwqe/card_ddcb.c
@@ -1048,15 +1048,15 @@ static int setup_ddcb_queue(struct genwqe_dev *cd, struct ddcb_queue *queue)
 			"[%s] **err: could not allocate DDCB **\n", __func__);
 		return -ENOMEM;
 	}
-	queue->ddcb_req = kzalloc(sizeof(struct ddcb_requ *) *
-				  queue->ddcb_max, GFP_KERNEL);
+	queue->ddcb_req = kzalloc(array_size(sizeof(struct ddcb_requ *), queue->ddcb_max),
+				  GFP_KERNEL);
 	if (!queue->ddcb_req) {
 		rc = -ENOMEM;
 		goto free_ddcbs;
 	}
 
-	queue->ddcb_waitqs = kzalloc(sizeof(wait_queue_head_t) *
-				     queue->ddcb_max, GFP_KERNEL);
+	queue->ddcb_waitqs = kzalloc(array_size(sizeof(wait_queue_head_t), queue->ddcb_max),
+				     GFP_KERNEL);
 	if (!queue->ddcb_waitqs) {
 		rc = -ENOMEM;
 		goto free_requs;
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 0c26eaf5f62b..1f4595132820 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -520,8 +520,8 @@ xpnet_init(void)
 
 	dev_info(xpnet, "registering network device %s\n", XPNET_DEVICE_NAME);
 
-	xpnet_broadcast_partitions = kzalloc(BITS_TO_LONGS(xp_max_npartitions) *
-					     sizeof(long), GFP_KERNEL);
+	xpnet_broadcast_partitions = kzalloc(array_size(BITS_TO_LONGS(xp_max_npartitions), sizeof(long)),
+					     GFP_KERNEL);
 	if (xpnet_broadcast_partitions == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/misc/sram.c b/drivers/misc/sram.c
index fc0415771c00..a9d217c9afcc 100644
--- a/drivers/misc/sram.c
+++ b/drivers/misc/sram.c
@@ -185,7 +185,7 @@ static int sram_reserve_regions(struct sram_dev *sram, struct resource *res)
 	 * after the reserved blocks from the dt are processed.
 	 */
 	nblocks = (np) ? of_get_available_child_count(np) + 1 : 1;
-	rblocks = kzalloc((nblocks) * sizeof(*rblocks), GFP_KERNEL);
+	rblocks = kzalloc(array_size((nblocks), sizeof(*rblocks)), GFP_KERNEL);
 	if (!rblocks)
 		return -ENOMEM;
 
diff --git a/drivers/mtd/chips/cfi_cmdset_0001.c b/drivers/mtd/chips/cfi_cmdset_0001.c
index f5695be14499..cb1f2b1bfbac 100644
--- a/drivers/mtd/chips/cfi_cmdset_0001.c
+++ b/drivers/mtd/chips/cfi_cmdset_0001.c
@@ -608,8 +608,8 @@ static struct mtd_info *cfi_intelext_setup(struct mtd_info *mtd)
 	mtd->size = devsize * cfi->numchips;
 
 	mtd->numeraseregions = cfi->cfiq->NumEraseRegions * cfi->numchips;
-	mtd->eraseregions = kzalloc(sizeof(struct mtd_erase_region_info)
-			* mtd->numeraseregions, GFP_KERNEL);
+	mtd->eraseregions = kzalloc(array_size(sizeof(struct mtd_erase_region_info), mtd->numeraseregions),
+				    GFP_KERNEL);
 	if (!mtd->eraseregions)
 		goto setup_err;
 
@@ -758,7 +758,8 @@ static int cfi_intelext_partition_fixup(struct mtd_info *mtd,
 		newcfi = kmalloc(sizeof(struct cfi_private) + numvirtchips * sizeof(struct flchip), GFP_KERNEL);
 		if (!newcfi)
 			return -ENOMEM;
-		shared = kmalloc(sizeof(struct flchip_shared) * cfi->numchips, GFP_KERNEL);
+		shared = kmalloc(array_size(sizeof(struct flchip_shared), cfi->numchips),
+				 GFP_KERNEL);
 		if (!shared) {
 			kfree(newcfi);
 			return -ENOMEM;
diff --git a/drivers/mtd/chips/cfi_cmdset_0002.c b/drivers/mtd/chips/cfi_cmdset_0002.c
index 8f23b305bf83..f4c250e692af 100644
--- a/drivers/mtd/chips/cfi_cmdset_0002.c
+++ b/drivers/mtd/chips/cfi_cmdset_0002.c
@@ -692,8 +692,8 @@ static struct mtd_info *cfi_amdstd_setup(struct mtd_info *mtd)
 	mtd->size = devsize * cfi->numchips;
 
 	mtd->numeraseregions = cfi->cfiq->NumEraseRegions * cfi->numchips;
-	mtd->eraseregions = kmalloc(sizeof(struct mtd_erase_region_info)
-				    * mtd->numeraseregions, GFP_KERNEL);
+	mtd->eraseregions = kmalloc(array_size(sizeof(struct mtd_erase_region_info), mtd->numeraseregions),
+				    GFP_KERNEL);
 	if (!mtd->eraseregions)
 		goto setup_err;
 
diff --git a/drivers/mtd/chips/cfi_cmdset_0020.c b/drivers/mtd/chips/cfi_cmdset_0020.c
index 7b7658a05036..9375f7aa4135 100644
--- a/drivers/mtd/chips/cfi_cmdset_0020.c
+++ b/drivers/mtd/chips/cfi_cmdset_0020.c
@@ -184,8 +184,8 @@ static struct mtd_info *cfi_staa_setup(struct map_info *map)
 	mtd->size = devsize * cfi->numchips;
 
 	mtd->numeraseregions = cfi->cfiq->NumEraseRegions * cfi->numchips;
-	mtd->eraseregions = kmalloc(sizeof(struct mtd_erase_region_info)
-			* mtd->numeraseregions, GFP_KERNEL);
+	mtd->eraseregions = kmalloc(array_size(sizeof(struct mtd_erase_region_info), mtd->numeraseregions),
+				    GFP_KERNEL);
 	if (!mtd->eraseregions) {
 		kfree(cfi->cmdset_priv);
 		kfree(mtd);
diff --git a/drivers/mtd/ftl.c b/drivers/mtd/ftl.c
index ef6ad2551d57..75d0acf73395 100644
--- a/drivers/mtd/ftl.c
+++ b/drivers/mtd/ftl.c
@@ -201,15 +201,15 @@ static int build_maps(partition_t *part)
     /* Set up erase unit maps */
     part->DataUnits = le16_to_cpu(part->header.NumEraseUnits) -
 	part->header.NumTransferUnits;
-    part->EUNInfo = kmalloc(part->DataUnits * sizeof(struct eun_info_t),
-			    GFP_KERNEL);
+    part->EUNInfo = kmalloc(array_size(part->DataUnits, sizeof(struct eun_info_t)),
+                            GFP_KERNEL);
     if (!part->EUNInfo)
 	    goto out;
     for (i = 0; i < part->DataUnits; i++)
 	part->EUNInfo[i].Offset = 0xffffffff;
     part->XferInfo =
-	kmalloc(part->header.NumTransferUnits * sizeof(struct xfer_info_t),
-		GFP_KERNEL);
+	kmalloc(array_size(part->header.NumTransferUnits, sizeof(struct xfer_info_t)),
+                GFP_KERNEL);
     if (!part->XferInfo)
 	    goto out_EUNInfo;
 
@@ -269,8 +269,8 @@ static int build_maps(partition_t *part)
     memset(part->VirtualBlockMap, 0xff, blocks * sizeof(uint32_t));
     part->BlocksPerUnit = (1 << header.EraseUnitSize) >> header.BlockSize;
 
-    part->bam_cache = kmalloc(part->BlocksPerUnit * sizeof(uint32_t),
-			      GFP_KERNEL);
+    part->bam_cache = kmalloc(array_size(part->BlocksPerUnit, sizeof(uint32_t)),
+                              GFP_KERNEL);
     if (!part->bam_cache)
 	    goto out_VirtualBlockMap;
 
diff --git a/drivers/mtd/inftlmount.c b/drivers/mtd/inftlmount.c
index aab4f68bd36f..c5b8e5c54ac6 100644
--- a/drivers/mtd/inftlmount.c
+++ b/drivers/mtd/inftlmount.c
@@ -270,7 +270,8 @@ static int find_boot_record(struct INFTLrecord *inftl)
 		inftl->nb_blocks = ip->lastUnit + 1;
 
 		/* Memory alloc */
-		inftl->PUtable = kmalloc(inftl->nb_blocks * sizeof(u16), GFP_KERNEL);
+		inftl->PUtable = kmalloc(array_size(inftl->nb_blocks, sizeof(u16)),
+					 GFP_KERNEL);
 		if (!inftl->PUtable) {
 			printk(KERN_WARNING "INFTL: allocation of PUtable "
 				"failed (%zd bytes)\n",
@@ -278,7 +279,8 @@ static int find_boot_record(struct INFTLrecord *inftl)
 			return -ENOMEM;
 		}
 
-		inftl->VUtable = kmalloc(inftl->nb_blocks * sizeof(u16), GFP_KERNEL);
+		inftl->VUtable = kmalloc(array_size(inftl->nb_blocks, sizeof(u16)),
+					 GFP_KERNEL);
 		if (!inftl->VUtable) {
 			kfree(inftl->PUtable);
 			printk(KERN_WARNING "INFTL: allocation of VUtable "
diff --git a/drivers/mtd/lpddr/lpddr_cmds.c b/drivers/mtd/lpddr/lpddr_cmds.c
index 5c5ba3c7c79d..fc11a0c6b20f 100644
--- a/drivers/mtd/lpddr/lpddr_cmds.c
+++ b/drivers/mtd/lpddr/lpddr_cmds.c
@@ -78,8 +78,8 @@ struct mtd_info *lpddr_cmdset(struct map_info *map)
 	mtd->erasesize = 1 << lpddr->qinfo->UniformBlockSizeShift;
 	mtd->writesize = 1 << lpddr->qinfo->BufSizeShift;
 
-	shared = kmalloc(sizeof(struct flchip_shared) * lpddr->numchips,
-						GFP_KERNEL);
+	shared = kmalloc(array_size(sizeof(struct flchip_shared), lpddr->numchips),
+			 GFP_KERNEL);
 	if (!shared) {
 		kfree(lpddr);
 		kfree(mtd);
diff --git a/drivers/mtd/maps/physmap_of_core.c b/drivers/mtd/maps/physmap_of_core.c
index 8f859b488a98..a064ff24dc83 100644
--- a/drivers/mtd/maps/physmap_of_core.c
+++ b/drivers/mtd/maps/physmap_of_core.c
@@ -124,7 +124,7 @@ static const char * const *of_get_probes(struct device_node *dp)
 	if (count < 0)
 		return part_probe_types_def;
 
-	res = kzalloc((count + 1) * sizeof(*res), GFP_KERNEL);
+	res = kzalloc(array_size((count + 1), sizeof(*res)), GFP_KERNEL);
 	if (!res)
 		return NULL;
 
diff --git a/drivers/mtd/maps/vmu-flash.c b/drivers/mtd/maps/vmu-flash.c
index 6b223cfe92b7..45a7fb236905 100644
--- a/drivers/mtd/maps/vmu-flash.c
+++ b/drivers/mtd/maps/vmu-flash.c
@@ -629,15 +629,15 @@ static int vmu_connect(struct maple_device *mdev)
 	* Not sure there are actually any multi-partition devices in the
 	* real world, but the hardware supports them, so, so will we
 	*/
-	card->parts = kmalloc(sizeof(struct vmupart) * card->partitions,
-		GFP_KERNEL);
+	card->parts = kmalloc(array_size(sizeof(struct vmupart), card->partitions),
+			      GFP_KERNEL);
 	if (!card->parts) {
 		error = -ENOMEM;
 		goto fail_partitions;
 	}
 
-	card->mtd = kmalloc(sizeof(struct mtd_info) * card->partitions,
-		GFP_KERNEL);
+	card->mtd = kmalloc(array_size(sizeof(struct mtd_info), card->partitions),
+			    GFP_KERNEL);
 	if (!card->mtd) {
 		error = -ENOMEM;
 		goto fail_mtd_info;
diff --git a/drivers/mtd/mtdswap.c b/drivers/mtd/mtdswap.c
index 7161f8a17f62..239668f07916 100644
--- a/drivers/mtd/mtdswap.c
+++ b/drivers/mtd/mtdswap.c
@@ -1340,7 +1340,7 @@ static int mtdswap_init(struct mtdswap_dev *d, unsigned int eblocks,
 	if (!d->page_buf)
 		goto page_buf_fail;
 
-	d->oob_buf = kmalloc(2 * mtd->oobavail, GFP_KERNEL);
+	d->oob_buf = kmalloc(array_size(2, mtd->oobavail), GFP_KERNEL);
 	if (!d->oob_buf)
 		goto oob_buf_fail;
 
diff --git a/drivers/mtd/nand/onenand/onenand_base.c b/drivers/mtd/nand/onenand/onenand_base.c
index b7105192cb12..153a8a280878 100644
--- a/drivers/mtd/nand/onenand/onenand_base.c
+++ b/drivers/mtd/nand/onenand/onenand_base.c
@@ -3721,8 +3721,8 @@ static int onenand_probe(struct mtd_info *mtd)
 		this->dies = ONENAND_IS_DDP(this) ? 2 : 1;
 		/* Maximum possible erase regions */
 		mtd->numeraseregions = this->dies << 1;
-		mtd->eraseregions = kzalloc(sizeof(struct mtd_erase_region_info)
-					* (this->dies << 1), GFP_KERNEL);
+		mtd->eraseregions = kzalloc(array_size(sizeof(struct mtd_erase_region_info), (this->dies << 1)),
+					    GFP_KERNEL);
 		if (!mtd->eraseregions)
 			return -ENOMEM;
 	}
diff --git a/drivers/mtd/nftlmount.c b/drivers/mtd/nftlmount.c
index a6fbfa4e5799..37e8fcdc268c 100644
--- a/drivers/mtd/nftlmount.c
+++ b/drivers/mtd/nftlmount.c
@@ -199,13 +199,15 @@ device is already correct.
 		nftl->lastEUN = nftl->nb_blocks - 1;
 
 		/* memory alloc */
-		nftl->EUNtable = kmalloc(nftl->nb_blocks * sizeof(u16), GFP_KERNEL);
+		nftl->EUNtable = kmalloc(array_size(nftl->nb_blocks, sizeof(u16)),
+					 GFP_KERNEL);
 		if (!nftl->EUNtable) {
 			printk(KERN_NOTICE "NFTL: allocation of EUNtable failed\n");
 			return -ENOMEM;
 		}
 
-		nftl->ReplUnitTable = kmalloc(nftl->nb_blocks * sizeof(u16), GFP_KERNEL);
+		nftl->ReplUnitTable = kmalloc(array_size(nftl->nb_blocks, sizeof(u16)),
+					      GFP_KERNEL);
 		if (!nftl->ReplUnitTable) {
 			kfree(nftl->EUNtable);
 			printk(KERN_NOTICE "NFTL: allocation of ReplUnitTable failed\n");
diff --git a/drivers/mtd/sm_ftl.c b/drivers/mtd/sm_ftl.c
index 79636349df96..389057bdd5e8 100644
--- a/drivers/mtd/sm_ftl.c
+++ b/drivers/mtd/sm_ftl.c
@@ -82,8 +82,8 @@ static struct attribute_group *sm_create_sysfs_attributes(struct sm_ftl *ftl)
 
 
 	/* Create array of pointers to the attributes */
-	attributes = kzalloc(sizeof(struct attribute *) * (NUM_ATTRIBUTES + 1),
-								GFP_KERNEL);
+	attributes = kzalloc(array_size(sizeof(struct attribute *), (NUM_ATTRIBUTES + 1)),
+			     GFP_KERNEL);
 	if (!attributes)
 		goto error3;
 	attributes[0] = &vendor_attribute->dev_attr.attr;
@@ -750,7 +750,8 @@ static int sm_init_zone(struct sm_ftl *ftl, int zone_num)
 	dbg("initializing zone %d", zone_num);
 
 	/* Allocate memory for FTL table */
-	zone->lba_to_phys_table = kmalloc(ftl->max_lba * 2, GFP_KERNEL);
+	zone->lba_to_phys_table = kmalloc(array_size(ftl->max_lba, 2),
+					  GFP_KERNEL);
 
 	if (!zone->lba_to_phys_table)
 		return -ENOMEM;
@@ -1137,8 +1138,8 @@ static void sm_add_mtd(struct mtd_blktrans_ops *tr, struct mtd_info *mtd)
 		goto error2;
 
 	/* Allocate zone array, it will be initialized on demand */
-	ftl->zones = kzalloc(sizeof(struct ftl_zone) * ftl->zone_count,
-								GFP_KERNEL);
+	ftl->zones = kzalloc(array_size(sizeof(struct ftl_zone), ftl->zone_count),
+			     GFP_KERNEL);
 	if (!ftl->zones)
 		goto error3;
 
diff --git a/drivers/mtd/ssfdc.c b/drivers/mtd/ssfdc.c
index 95f0bf95f095..aa363182e012 100644
--- a/drivers/mtd/ssfdc.c
+++ b/drivers/mtd/ssfdc.c
@@ -332,8 +332,8 @@ static void ssfdcr_add_mtd(struct mtd_blktrans_ops *tr, struct mtd_info *mtd)
 				(long)ssfdc->sectors;
 
 	/* Allocate logical block map */
-	ssfdc->logic_block_map = kmalloc(sizeof(ssfdc->logic_block_map[0]) *
-					 ssfdc->map_len, GFP_KERNEL);
+	ssfdc->logic_block_map = kmalloc(array_size(sizeof(ssfdc->logic_block_map[0]), ssfdc->map_len),
+                                         GFP_KERNEL);
 	if (!ssfdc->logic_block_map)
 		goto out_err;
 	memset(ssfdc->logic_block_map, 0xff, sizeof(ssfdc->logic_block_map[0]) *
diff --git a/drivers/mtd/tests/pagetest.c b/drivers/mtd/tests/pagetest.c
index bc303cac9f43..71c34bfdfc68 100644
--- a/drivers/mtd/tests/pagetest.c
+++ b/drivers/mtd/tests/pagetest.c
@@ -127,7 +127,7 @@ static int crosstest(void)
 	unsigned char *pp1, *pp2, *pp3, *pp4;
 
 	pr_info("crosstest\n");
-	pp1 = kzalloc(pgsize * 4, GFP_KERNEL);
+	pp1 = kzalloc(array_size(pgsize, 4), GFP_KERNEL);
 	if (!pp1)
 		return -ENOMEM;
 	pp2 = pp1 + pgsize;
diff --git a/drivers/mtd/ubi/eba.c b/drivers/mtd/ubi/eba.c
index 5d09fde485e5..763c8e0fbd28 100644
--- a/drivers/mtd/ubi/eba.c
+++ b/drivers/mtd/ubi/eba.c
@@ -1443,14 +1443,14 @@ int self_check_eba(struct ubi_device *ubi, struct ubi_attach_info *ai_fastmap,
 		if (!vol)
 			continue;
 
-		scan_eba[i] = kmalloc(vol->reserved_pebs * sizeof(**scan_eba),
+		scan_eba[i] = kmalloc(array_size(vol->reserved_pebs, sizeof(**scan_eba)),
 				      GFP_KERNEL);
 		if (!scan_eba[i]) {
 			ret = -ENOMEM;
 			goto out_free;
 		}
 
-		fm_eba[i] = kmalloc(vol->reserved_pebs * sizeof(**fm_eba),
+		fm_eba[i] = kmalloc(array_size(vol->reserved_pebs, sizeof(**fm_eba)),
 				    GFP_KERNEL);
 		if (!fm_eba[i]) {
 			ret = -ENOMEM;
diff --git a/drivers/mtd/ubi/wl.c b/drivers/mtd/ubi/wl.c
index 2052a647220e..12f9f9254e3f 100644
--- a/drivers/mtd/ubi/wl.c
+++ b/drivers/mtd/ubi/wl.c
@@ -1594,7 +1594,8 @@ int ubi_wl_init(struct ubi_device *ubi, struct ubi_attach_info *ai)
 	sprintf(ubi->bgt_name, UBI_BGT_NAME_PATTERN, ubi->ubi_num);
 
 	err = -ENOMEM;
-	ubi->lookuptbl = kzalloc(ubi->peb_count * sizeof(void *), GFP_KERNEL);
+	ubi->lookuptbl = kzalloc(array_size(ubi->peb_count, sizeof(void *)),
+				 GFP_KERNEL);
 	if (!ubi->lookuptbl)
 		return err;
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 718e4914e3a0..deb0230a1f0a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2390,7 +2390,8 @@ struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
 	struct list_head  *iter;
 
 	if (start_dev == end_dev) {
-		tags = kzalloc(sizeof(*tags) * (level + 1), GFP_ATOMIC);
+		tags = kzalloc(array_size(sizeof(*tags), (level + 1)),
+			       GFP_ATOMIC);
 		if (!tags)
 			return ERR_PTR(-ENOMEM);
 		tags[level].vlan_proto = VLAN_N_VID;
diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index 2d3046afa80d..65656aa8758f 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -1057,7 +1057,7 @@ static int grcan_open(struct net_device *dev)
 		return err;
 	}
 
-	priv->echo_skb = kzalloc(dma->tx.size * sizeof(*priv->echo_skb),
+	priv->echo_skb = kzalloc(array_size(dma->tx.size, sizeof(*priv->echo_skb)),
 				 GFP_KERNEL);
 	if (!priv->echo_skb) {
 		err = -ENOMEM;
@@ -1066,7 +1066,8 @@ static int grcan_open(struct net_device *dev)
 	priv->can.echo_skb_max = dma->tx.size;
 	priv->can.echo_skb = priv->echo_skb;
 
-	priv->txdlc = kzalloc(dma->tx.size * sizeof(*priv->txdlc), GFP_KERNEL);
+	priv->txdlc = kzalloc(array_size(dma->tx.size, sizeof(*priv->txdlc)),
+			      GFP_KERNEL);
 	if (!priv->txdlc) {
 		err = -ENOMEM;
 		goto exit_free_echo_skb;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index cfe86a20c899..fc0b0680d498 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -209,8 +209,8 @@ static int atl1c_get_eeprom(struct net_device *netdev,
 	first_dword = eeprom->offset >> 2;
 	last_dword = (eeprom->offset + eeprom->len - 1) >> 2;
 
-	eeprom_buff = kmalloc(sizeof(u32) *
-			(last_dword - first_dword + 1), GFP_KERNEL);
+	eeprom_buff = kmalloc(array_size(sizeof(u32), (last_dword - first_dword + 1)),
+			      GFP_KERNEL);
 	if (eeprom_buff == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
index cb489e7e8374..c56e89304b0e 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
@@ -236,8 +236,8 @@ static int atl1e_get_eeprom(struct net_device *netdev,
 	first_dword = eeprom->offset >> 2;
 	last_dword = (eeprom->offset + eeprom->len - 1) >> 2;
 
-	eeprom_buff = kmalloc(sizeof(u32) *
-			(last_dword - first_dword + 1), GFP_KERNEL);
+	eeprom_buff = kmalloc(array_size(sizeof(u32), (last_dword - first_dword + 1)),
+			      GFP_KERNEL);
 	if (eeprom_buff == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index db4bcc51023a..d714a93bb31d 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1941,8 +1941,8 @@ static int atl2_get_eeprom(struct net_device *netdev,
 	first_dword = eeprom->offset >> 2;
 	last_dword = (eeprom->offset + eeprom->len - 1) >> 2;
 
-	eeprom_buff = kmalloc(sizeof(u32) * (last_dword - first_dword + 1),
-		GFP_KERNEL);
+	eeprom_buff = kmalloc(array_size(sizeof(u32), (last_dword - first_dword + 1)),
+			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 14a59e51db67..338e2c891b0c 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -2150,7 +2150,7 @@ static int bcm_enetsw_open(struct net_device *dev)
 	priv->tx_desc_alloc_size = size;
 	priv->tx_desc_cpu = p;
 
-	priv->tx_skb = kzalloc(sizeof(struct sk_buff *) * priv->tx_ring_size,
+	priv->tx_skb = kzalloc(array_size(sizeof(struct sk_buff *), priv->tx_ring_size),
 			       GFP_KERNEL);
 	if (!priv->tx_skb) {
 		dev_err(kdev, "cannot allocate rx skb queue\n");
@@ -2164,7 +2164,7 @@ static int bcm_enetsw_open(struct net_device *dev)
 	spin_lock_init(&priv->tx_lock);
 
 	/* init & fill rx ring with skbs */
-	priv->rx_skb = kzalloc(sizeof(struct sk_buff *) * priv->rx_ring_size,
+	priv->rx_skb = kzalloc(array_size(sizeof(struct sk_buff *), priv->rx_ring_size),
 			       GFP_KERNEL);
 	if (!priv->rx_skb) {
 		dev_err(kdev, "cannot allocate rx skb queue\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 5d1d54478ef2..1ba2eba7795c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1253,8 +1253,8 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 	   num_vfs_param, iov->nr_virtfn);
 
 	/* allocate the vf array */
-	bp->vfdb->vfs = kzalloc(sizeof(struct bnx2x_virtf) *
-				BNX2X_NR_VIRTFN(bp), GFP_KERNEL);
+	bp->vfdb->vfs = kzalloc(array_size(sizeof(struct bnx2x_virtf), BNX2X_NR_VIRTFN(bp)),
+				GFP_KERNEL);
 	if (!bp->vfdb->vfs) {
 		BNX2X_ERR("failed to allocate vf array\n");
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index f23611362756..2fb2b30383f2 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -660,7 +660,8 @@ static int cnic_init_id_tbl(struct cnic_id_tbl *id_tbl, u32 size, u32 start_id,
 	id_tbl->max = size;
 	id_tbl->next = next;
 	spin_lock_init(&id_tbl->lock);
-	id_tbl->table = kzalloc(DIV_ROUND_UP(size, 32) * 4, GFP_KERNEL);
+	id_tbl->table = kzalloc(array_size(DIV_ROUND_UP(size, 32), 4),
+				GFP_KERNEL);
 	if (!id_tbl->table)
 		return -ENOMEM;
 
@@ -1260,8 +1261,8 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	if (!cp->iscsi_tbl)
 		goto error;
 
-	cp->ctx_tbl = kzalloc(sizeof(struct cnic_context) *
-				cp->max_cid_space, GFP_KERNEL);
+	cp->ctx_tbl = kzalloc(array_size(sizeof(struct cnic_context), cp->max_cid_space),
+			      GFP_KERNEL);
 	if (!cp->ctx_tbl)
 		goto error;
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 30685a7e27ff..198cca6c7ee2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3182,7 +3182,7 @@ bnad_set_rx_mcast_fltr(struct bnad *bnad)
 	if (mc_count > bna_attr(&bnad->bna)->num_mcmac)
 		goto mode_allmulti;
 
-	mac_list = kzalloc((mc_count + 1) * ETH_ALEN, GFP_ATOMIC);
+	mac_list = kzalloc(array_size((mc_count + 1), ETH_ALEN), GFP_ATOMIC);
 
 	if (mac_list == NULL)
 		goto mode_allmulti;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index d42704d07484..871826b2a143 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -292,8 +292,8 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 		rbdr->is_xdp = true;
 	}
 	rbdr->pgcnt = roundup_pow_of_two(rbdr->pgcnt);
-	rbdr->pgcache = kzalloc(sizeof(*rbdr->pgcache) *
-				rbdr->pgcnt, GFP_KERNEL);
+	rbdr->pgcache = kzalloc(array_size(sizeof(*rbdr->pgcache), rbdr->pgcnt),
+				GFP_KERNEL);
 	if (!rbdr->pgcache)
 		return -ENOMEM;
 	rbdr->pgidx = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 24d2865b8806..480d0a472bed 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -708,7 +708,7 @@ int cxgb4_write_rss(const struct port_info *pi, const u16 *queues)
 	const struct sge_eth_rxq *rxq;
 
 	rxq = &adapter->sge.ethrxq[pi->first_qset];
-	rss = kmalloc(pi->rss_size * sizeof(u16), GFP_KERNEL);
+	rss = kmalloc(array_size(pi->rss_size, sizeof(u16)), GFP_KERNEL);
 	if (!rss)
 		return -ENOMEM;
 
@@ -4948,7 +4948,7 @@ static int enable_msix(struct adapter *adap)
 		max_ingq += (MAX_OFLD_QSETS * adap->num_uld);
 	if (is_offload(adap))
 		max_ingq += (MAX_OFLD_QSETS * adap->num_ofld_uld);
-	entries = kmalloc(sizeof(*entries) * (max_ingq + 1),
+	entries = kmalloc(array_size(sizeof(*entries), (max_ingq + 1)),
 			  GFP_KERNEL);
 	if (!entries)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index a96b838cffce..787487a64409 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -2253,8 +2253,7 @@ static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
 	/* Init Tx bds */
 	for (j = 0; j < ug_info->numQueuesTx; j++) {
 		/* Setup the skbuff rings */
-		ugeth->tx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
-					      ugeth->ug_info->bdRingLenTx[j],
+		ugeth->tx_skbuff[j] = kmalloc(array_size(sizeof(struct sk_buff *), ugeth->ug_info->bdRingLenTx[j]),
 					      GFP_KERNEL);
 
 		if (ugeth->tx_skbuff[j] == NULL) {
@@ -2326,8 +2325,7 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
 	/* Init Rx bds */
 	for (j = 0; j < ug_info->numQueuesRx; j++) {
 		/* Setup the skbuff rings */
-		ugeth->rx_skbuff[j] = kmalloc(sizeof(struct sk_buff *) *
-					      ugeth->ug_info->bdRingLenRx[j],
+		ugeth->rx_skbuff[j] = kmalloc(array_size(sizeof(struct sk_buff *), ugeth->ug_info->bdRingLenRx[j]),
 					      GFP_KERNEL);
 
 		if (ugeth->rx_skbuff[j] == NULL) {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 1ccb6443d2ed..f676cab05cf9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -2197,7 +2197,7 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 		return -EINVAL;
 	}
 
-	priv->ring_data = kzalloc(h->q_num * sizeof(*priv->ring_data) * 2,
+	priv->ring_data = kzalloc(array3_size(h->q_num, sizeof(*priv->ring_data), 2),
 				  GFP_KERNEL);
 	if (!priv->ring_data)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index c1b51edaaf62..2e30b088acb1 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -171,7 +171,8 @@ static int ibmveth_alloc_buffer_pool(struct ibmveth_buff_pool *pool)
 {
 	int i;
 
-	pool->free_map = kmalloc(sizeof(u16) * pool->size, GFP_KERNEL);
+	pool->free_map = kmalloc(array_size(sizeof(u16), pool->size),
+				 GFP_KERNEL);
 
 	if (!pool->free_map)
 		return -1;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 3e80ca170dd7..2414180c49e9 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -456,8 +456,8 @@ static int e1000_get_eeprom(struct net_device *netdev,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(u16) *
-			(last_word - first_word + 1), GFP_KERNEL);
+	eeprom_buff = kmalloc(array_size(sizeof(u16), (last_word - first_word + 1)),
+			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 64dc0c11147f..1ba1cd9a7a59 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -528,7 +528,7 @@ static int e1000_get_eeprom(struct net_device *netdev,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(u16) * (last_word - first_word + 1),
+	eeprom_buff = kmalloc(array_size(sizeof(u16), (last_word - first_word + 1)),
 			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ec4a9759a6f2..11791980e815 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3331,7 +3331,8 @@ static int e1000e_write_mc_addr_list(struct net_device *netdev)
 		return 0;
 	}
 
-	mta_list = kzalloc(netdev_mc_count(netdev) * ETH_ALEN, GFP_ATOMIC);
+	mta_list = kzalloc(array_size(netdev_mc_count(netdev), ETH_ALEN),
+			   GFP_ATOMIC);
 	if (!mta_list)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e77ba0d5866d..7c96a34c1460 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -757,8 +757,8 @@ static int igb_get_eeprom(struct net_device *netdev,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(u16) *
-			(last_word - first_word + 1), GFP_KERNEL);
+	eeprom_buff = kmalloc(array_size(sizeof(u16), (last_word - first_word + 1)),
+			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
 
@@ -3203,7 +3203,7 @@ static int igb_get_module_eeprom(struct net_device *netdev,
 	first_word = ee->offset >> 1;
 	last_word = (ee->offset + ee->len - 1) >> 1;
 
-	dataword = kmalloc(sizeof(u16) * (last_word - first_word + 1),
+	dataword = kmalloc(array_size(sizeof(u16), (last_word - first_word + 1)),
 			   GFP_KERNEL);
 	if (!dataword)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index cce7ada89255..c5471a95702b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3533,8 +3533,8 @@ static int igb_sw_init(struct igb_adapter *adapter)
 	/* Assume MSI-X interrupts, will be checked during IRQ allocation */
 	adapter->flags |= IGB_FLAG_HAS_MSIX;
 
-	adapter->mac_table = kzalloc(sizeof(struct igb_mac_addr) *
-				     hw->mac.rar_entry_count, GFP_ATOMIC);
+	adapter->mac_table = kzalloc(array_size(sizeof(struct igb_mac_addr), hw->mac.rar_entry_count),
+				     GFP_ATOMIC);
 	if (!adapter->mac_table)
 		return -ENOMEM;
 
@@ -4518,7 +4518,7 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 		return 0;
 	}
 
-	mta_list = kzalloc(netdev_mc_count(netdev) * 6, GFP_ATOMIC);
+	mta_list = kzalloc(array_size(netdev_mc_count(netdev), 6), GFP_ATOMIC);
 	if (!mta_list)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index d10a0d242dda..d432c70dc77d 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -400,8 +400,8 @@ ixgb_get_eeprom(struct net_device *netdev,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(__le16) *
-			(last_word - first_word + 1), GFP_KERNEL);
+	eeprom_buff = kmalloc(array_size(sizeof(__le16), (last_word - first_word + 1)),
+			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index afadba99f7b8..4786e236cb90 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6136,8 +6136,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter,
 	for (i = 1; i < IXGBE_MAX_LINK_HANDLE; i++)
 		adapter->jump_tables[i] = NULL;
 
-	adapter->mac_table = kzalloc(sizeof(struct ixgbe_mac_addr) *
-				     hw->mac.num_rar_entries,
+	adapter->mac_table = kzalloc(array_size(sizeof(struct ixgbe_mac_addr), hw->mac.num_rar_entries),
 				     GFP_ATOMIC);
 	if (!adapter->mac_table)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 8a165842fa85..2b12e4bf2087 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -589,8 +589,8 @@ jme_setup_tx_resources(struct jme_adapter *jme)
 	atomic_set(&txring->next_to_clean, 0);
 	atomic_set(&txring->nr_free, jme->tx_ring_size);
 
-	txring->bufinf		= kzalloc(sizeof(struct jme_buffer_info) *
-					jme->tx_ring_size, GFP_ATOMIC);
+	txring->bufinf		= kzalloc(array_size(sizeof(struct jme_buffer_info), jme->tx_ring_size),
+						GFP_ATOMIC);
 	if (unlikely(!(txring->bufinf)))
 		goto err_free_txring;
 
@@ -838,8 +838,8 @@ jme_setup_rx_resources(struct jme_adapter *jme)
 	rxring->next_to_use	= 0;
 	atomic_set(&rxring->next_to_clean, 0);
 
-	rxring->bufinf		= kzalloc(sizeof(struct jme_buffer_info) *
-					jme->rx_ring_size, GFP_ATOMIC);
+	rxring->bufinf		= kzalloc(array_size(sizeof(struct jme_buffer_info), jme->rx_ring_size),
+						GFP_ATOMIC);
 	if (unlikely(!(rxring->bufinf)))
 		goto err_free_rxring;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index 6dabd983e7e0..37a3d1d24700 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -185,8 +185,8 @@ int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 	bitmap->avail = num - reserved_top - reserved_bot;
 	bitmap->effective_len = bitmap->avail;
 	spin_lock_init(&bitmap->lock);
-	bitmap->table = kzalloc(BITS_TO_LONGS(bitmap->max) *
-				sizeof(long), GFP_KERNEL);
+	bitmap->table = kzalloc(array_size(BITS_TO_LONGS(bitmap->max), sizeof(long)),
+				GFP_KERNEL);
 	if (!bitmap->table)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 6a9086dc1e92..3c0156c1c236 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2377,20 +2377,20 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 		struct mlx4_vf_admin_state *vf_admin;
 
 		priv->mfunc.master.slave_state =
-			kzalloc(dev->num_slaves *
-				sizeof(struct mlx4_slave_state), GFP_KERNEL);
+			kzalloc(array_size(dev->num_slaves, sizeof(struct mlx4_slave_state)),
+				GFP_KERNEL);
 		if (!priv->mfunc.master.slave_state)
 			goto err_comm;
 
 		priv->mfunc.master.vf_admin =
-			kzalloc(dev->num_slaves *
-				sizeof(struct mlx4_vf_admin_state), GFP_KERNEL);
+			kzalloc(array_size(dev->num_slaves, sizeof(struct mlx4_vf_admin_state)),
+				GFP_KERNEL);
 		if (!priv->mfunc.master.vf_admin)
 			goto err_comm_admin;
 
 		priv->mfunc.master.vf_oper =
-			kzalloc(dev->num_slaves *
-				sizeof(struct mlx4_vf_oper_state), GFP_KERNEL);
+			kzalloc(array_size(dev->num_slaves, sizeof(struct mlx4_vf_oper_state)),
+				GFP_KERNEL);
 		if (!priv->mfunc.master.vf_oper)
 			goto err_comm_oper;
 
@@ -2636,9 +2636,8 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 	int i;
 	int err = 0;
 
-	priv->cmd.context = kmalloc(priv->cmd.max_cmds *
-				   sizeof(struct mlx4_cmd_context),
-				   GFP_KERNEL);
+	priv->cmd.context = kmalloc(array_size(priv->cmd.max_cmds, sizeof(struct mlx4_cmd_context)),
+				    GFP_KERNEL);
 	if (!priv->cmd.context)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 6f57c052053e..a956094e0706 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1211,7 +1211,7 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 	}
 
 	priv->eq_table.irq_names =
-		kmalloc(MLX4_IRQNAME_SIZE * (dev->caps.num_comp_vectors + 1),
+		kmalloc(array_size(MLX4_IRQNAME_SIZE, (dev->caps.num_comp_vectors + 1)),
 			GFP_KERNEL);
 	if (!priv->eq_table.irq_names) {
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 29e50f787349..5bd7975ff870 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -487,7 +487,7 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 	int max_vfs_guarantee_counter = get_max_gauranteed_vfs_counter(dev);
 
 	priv->mfunc.master.res_tracker.slave_list =
-		kzalloc(dev->num_slaves * sizeof(struct slave_list),
+		kzalloc(array_size(dev->num_slaves, sizeof(struct slave_list)),
 			GFP_KERNEL);
 	if (!priv->mfunc.master.res_tracker.slave_list)
 		return -ENOMEM;
@@ -507,19 +507,16 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 	for (i = 0; i < MLX4_NUM_OF_RESOURCE_TYPE; i++) {
 		struct resource_allocator *res_alloc =
 			&priv->mfunc.master.res_tracker.res_alloc[i];
-		res_alloc->quota = kmalloc((dev->persist->num_vfs + 1) *
-					   sizeof(int), GFP_KERNEL);
-		res_alloc->guaranteed = kmalloc((dev->persist->num_vfs + 1) *
-						sizeof(int), GFP_KERNEL);
+		res_alloc->quota = kmalloc(array_size((dev->persist->num_vfs + 1), sizeof(int)),
+					   GFP_KERNEL);
+		res_alloc->guaranteed = kmalloc(array_size((dev->persist->num_vfs + 1), sizeof(int)),
+						GFP_KERNEL);
 		if (i == RES_MAC || i == RES_VLAN)
-			res_alloc->allocated = kzalloc(MLX4_MAX_PORTS *
-						       (dev->persist->num_vfs
-						       + 1) *
-						       sizeof(int), GFP_KERNEL);
+			res_alloc->allocated = kzalloc(array3_size(MLX4_MAX_PORTS, (dev->persist->num_vfs + 1), sizeof(int)),
+						       GFP_KERNEL);
 		else
-			res_alloc->allocated = kzalloc((dev->persist->
-							num_vfs + 1) *
-						       sizeof(int), GFP_KERNEL);
+			res_alloc->allocated = kzalloc(array_size((dev->persist->num_vfs + 1), sizeof(int)),
+						       GFP_KERNEL);
 		/* Reduce the sink counter */
 		if (i == RES_COUNTER)
 			res_alloc->res_free = dev->caps.max_counters - 1;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.c
index de7fe087d6fe..195718dd133e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.c
@@ -549,15 +549,15 @@ static int mlx5_fpga_conn_create_qp(struct mlx5_fpga_conn *conn,
 	if (err)
 		goto out;
 
-	conn->qp.rq.bufs = kvzalloc(sizeof(conn->qp.rq.bufs[0]) *
-				    conn->qp.rq.size, GFP_KERNEL);
+	conn->qp.rq.bufs = kvzalloc(array_size(sizeof(conn->qp.rq.bufs[0]), conn->qp.rq.size),
+				    GFP_KERNEL);
 	if (!conn->qp.rq.bufs) {
 		err = -ENOMEM;
 		goto err_wq;
 	}
 
-	conn->qp.sq.bufs = kvzalloc(sizeof(conn->qp.sq.bufs[0]) *
-				    conn->qp.sq.size, GFP_KERNEL);
+	conn->qp.sq.bufs = kvzalloc(array_size(sizeof(conn->qp.sq.bufs[0]), conn->qp.sq.size),
+				    GFP_KERNEL);
 	if (!conn->qp.sq.bufs) {
 		err = -ENOMEM;
 		goto err_rq_bufs;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c
index 0f5da499a223..3e53cd7834fa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c
@@ -386,7 +386,7 @@ int mlx5_fpga_ipsec_counters_read(struct mlx5_core_dev *mdev, u64 *counters,
 
 	count = mlx5_fpga_ipsec_counters_count(mdev);
 
-	data = kzalloc(sizeof(*data) * count * 2, GFP_KERNEL);
+	data = kzalloc(array3_size(sizeof(*data), count, 2), GFP_KERNEL);
 	if (!data) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lib/clock.c b/drivers/net/ethernet/mellanox/mlx5/core/lib/clock.c
index 857035583ccd..e4688b35ca55 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lib/clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lib/clock.c
@@ -394,8 +394,8 @@ static int mlx5_init_pin_config(struct mlx5_clock *clock)
 	int i;
 
 	clock->ptp_info.pin_config =
-			kzalloc(sizeof(*clock->ptp_info.pin_config) *
-				clock->ptp_info.n_pins, GFP_KERNEL);
+			kzalloc(array_size(sizeof(*clock->ptp_info.pin_config), clock->ptp_info.n_pins),
+				GFP_KERNEL);
 	if (!clock->ptp_info.pin_config)
 		return -ENOMEM;
 	clock->ptp_info.enable = mlx5_ptp_enable;
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 52207508744c..ed029b96eac3 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4372,7 +4372,7 @@ static void ksz_update_timer(struct ksz_timer_info *info)
  */
 static int ksz_alloc_soft_desc(struct ksz_desc_info *desc_info, int transmit)
 {
-	desc_info->ring = kzalloc(sizeof(struct ksz_desc) * desc_info->alloc,
+	desc_info->ring = kzalloc(array_size(sizeof(struct ksz_desc), desc_info->alloc),
 				  GFP_KERNEL);
 	if (!desc_info->ring)
 		return 1;
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 2e4effa9fe45..61199e478248 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -507,14 +507,14 @@ static int moxart_mac_probe(struct platform_device *pdev)
 		goto init_fail;
 	}
 
-	priv->tx_buf_base = kmalloc(priv->tx_buf_size * TX_DESC_NUM,
+	priv->tx_buf_base = kmalloc(array_size(priv->tx_buf_size, TX_DESC_NUM),
 				    GFP_ATOMIC);
 	if (!priv->tx_buf_base) {
 		ret = -ENOMEM;
 		goto init_fail;
 	}
 
-	priv->rx_buf_base = kmalloc(priv->rx_buf_size * RX_DESC_NUM,
+	priv->rx_buf_base = kmalloc(array_size(priv->rx_buf_size, RX_DESC_NUM),
 				    GFP_ATOMIC);
 	if (!priv->rx_buf_base) {
 		ret = -ENOMEM;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index b2299f2b2155..e51040939b3b 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3429,8 +3429,8 @@ static int vxge_device_register(struct __vxge_hw_device *hldev,
 	vxge_initialize_ethtool_ops(ndev);
 
 	/* Allocate memory for vpath */
-	vdev->vpaths = kzalloc((sizeof(struct vxge_vpath)) *
-				no_of_vpath, GFP_KERNEL);
+	vdev->vpaths = kzalloc(array_size((sizeof(struct vxge_vpath)), no_of_vpath),
+			       GFP_KERNEL);
 	if (!vdev->vpaths) {
 		vxge_debug_init(VXGE_ERR,
 			"%s: vpath memory allocation failed",
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 66c665d0b926..d2ceb214174d 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4630,8 +4630,10 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 					       ring->tx_pending),
 					       &ring_addr, GFP_ATOMIC);
 	}
-	rx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->rx_pending, GFP_KERNEL);
-	tx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->tx_pending, GFP_KERNEL);
+	rx_skbuff = kmalloc(array_size(sizeof(struct nv_skb_map), ring->rx_pending),
+			    GFP_KERNEL);
+	tx_skbuff = kmalloc(array_size(sizeof(struct nv_skb_map), ring->tx_pending),
+			    GFP_KERNEL);
 	if (!rxtx_ring || !rx_skbuff || !tx_skbuff) {
 		/* fall back to old rings */
 		if (!nv_optimized(np)) {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_debug.c b/drivers/net/ethernet/qlogic/qed/qed_debug.c
index 4926c5532fba..a3c6b98f75e4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_debug.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_debug.c
@@ -6558,7 +6558,8 @@ static enum dbg_status qed_mcp_trace_alloc_meta(struct qed_hwfn *p_hwfn,
 
 	/* Read no. of modules and allocate memory for their pointers */
 	meta->modules_num = qed_read_byte_from_buf(meta_buf_bytes, &offset);
-	meta->modules = kzalloc(meta->modules_num * sizeof(char *), GFP_KERNEL);
+	meta->modules = kzalloc(array_size(meta->modules_num, sizeof(char *)),
+				GFP_KERNEL);
 	if (!meta->modules)
 		return DBG_STATUS_VIRT_MEM_ALLOC_FAILED;
 
@@ -6586,8 +6587,7 @@ static enum dbg_status qed_mcp_trace_alloc_meta(struct qed_hwfn *p_hwfn,
 
 	/* Read number of formats and allocate memory for all formats */
 	meta->formats_num = qed_read_dword_from_buf(meta_buf_bytes, &offset);
-	meta->formats = kzalloc(meta->formats_num *
-				sizeof(struct mcp_trace_format),
+	meta->formats = kzalloc(array_size(meta->formats_num, sizeof(struct mcp_trace_format)),
 				GFP_KERNEL);
 	if (!meta->formats)
 		return DBG_STATUS_VIRT_MEM_ALLOC_FAILED;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index d2ad5e92c74f..c9f804bf8ef3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -814,26 +814,22 @@ static int qed_alloc_qm_data(struct qed_hwfn *p_hwfn)
 	if (rc)
 		goto alloc_err;
 
-	qm_info->qm_pq_params = kzalloc(sizeof(*qm_info->qm_pq_params) *
-					qed_init_qm_get_num_pqs(p_hwfn),
+	qm_info->qm_pq_params = kzalloc(array_size(sizeof(*qm_info->qm_pq_params), qed_init_qm_get_num_pqs(p_hwfn)),
 					GFP_KERNEL);
 	if (!qm_info->qm_pq_params)
 		goto alloc_err;
 
-	qm_info->qm_vport_params = kzalloc(sizeof(*qm_info->qm_vport_params) *
-					   qed_init_qm_get_num_vports(p_hwfn),
+	qm_info->qm_vport_params = kzalloc(array_size(sizeof(*qm_info->qm_vport_params), qed_init_qm_get_num_vports(p_hwfn)),
 					   GFP_KERNEL);
 	if (!qm_info->qm_vport_params)
 		goto alloc_err;
 
-	qm_info->qm_port_params = kzalloc(sizeof(*qm_info->qm_port_params) *
-					  p_hwfn->cdev->num_ports_in_engine,
+	qm_info->qm_port_params = kzalloc(array_size(sizeof(*qm_info->qm_port_params), p_hwfn->cdev->num_ports_in_engine),
 					  GFP_KERNEL);
 	if (!qm_info->qm_port_params)
 		goto alloc_err;
 
-	qm_info->wfq_data = kzalloc(sizeof(*qm_info->wfq_data) *
-				    qed_init_qm_get_num_vports(p_hwfn),
+	qm_info->wfq_data = kzalloc(array_size(sizeof(*qm_info->wfq_data), qed_init_qm_get_num_vports(p_hwfn)),
 				    GFP_KERNEL);
 	if (!qm_info->wfq_data)
 		goto alloc_err;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
index 06b1fad88360..3dc5f70656be 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
@@ -498,7 +498,8 @@ int qed_init_run(struct qed_hwfn *p_hwfn,
 	num_init_ops = cdev->fw_data->init_ops_size;
 	init_ops = cdev->fw_data->init_ops;
 
-	p_hwfn->unzip_buf = kzalloc(MAX_ZIPPED_SIZE * 4, GFP_ATOMIC);
+	p_hwfn->unzip_buf = kzalloc(array_size(MAX_ZIPPED_SIZE, 4),
+				    GFP_ATOMIC);
 	if (!p_hwfn->unzip_buf)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index e874504e8b28..9fcf8fd81f66 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -98,7 +98,7 @@ int qed_l2_alloc(struct qed_hwfn *p_hwfn)
 		p_l2_info->queues = max_t(u8, rx, tx);
 	}
 
-	pp_qids = kzalloc(sizeof(unsigned long *) * p_l2_info->queues,
+	pp_qids = kzalloc(array_size(sizeof(unsigned long *), p_l2_info->queues),
 			  GFP_KERNEL);
 	if (!pp_qids)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index ec0d425766a7..41d650dff539 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -2497,8 +2497,7 @@ int qed_mcp_nvm_info_populate(struct qed_hwfn *p_hwfn)
 		goto err0;
 	}
 
-	nvm_info->image_att = kmalloc(nvm_info->num_images *
-				      sizeof(struct bist_nvm_image_att),
+	nvm_info->image_att = kmalloc(array_size(nvm_info->num_images, sizeof(struct bist_nvm_image_att)),
 				      GFP_KERNEL);
 	if (!nvm_info->image_att) {
 		rc = -ENOMEM;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 8293c2028002..4fc20aa7114e 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2810,7 +2810,8 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 		goto pci_alloc_err;
 
 	tx_ring->q =
-	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
+	    kmalloc(array_size(tx_ring->wq_len, sizeof(struct tx_ring_desc)),
+		    GFP_KERNEL);
 	if (tx_ring->q == NULL)
 		goto err;
 
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index f4d7362eb325..d19e868afe25 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -640,7 +640,7 @@ int asix_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(u16) * (last_word - first_word + 1),
+	eeprom_buff = kmalloc(array_size(sizeof(u16), (last_word - first_word + 1)),
 			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
@@ -680,7 +680,7 @@ int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(u16) * (last_word - first_word + 1),
+	eeprom_buff = kmalloc(array_size(sizeof(u16), (last_word - first_word + 1)),
 			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index a6ef75907ae9..c09c93153de7 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -599,7 +599,7 @@ ax88179_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
 
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
-	eeprom_buff = kmalloc(sizeof(u16) * (last_word - first_word + 1),
+	eeprom_buff = kmalloc(array_size(sizeof(u16), (last_word - first_word + 1)),
 			      GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index d9eea8cfe6cb..9e0530468102 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1323,7 +1323,7 @@ static int build_dma_sg(const struct sk_buff *skb, struct urb *urb)
 		return 0;
 
 	/* reserve one for zero packet */
-	urb->sg = kmalloc((num_sgs + 1) * sizeof(struct scatterlist),
+	urb->sg = kmalloc(array_size((num_sgs + 1), sizeof(struct scatterlist)),
 			  GFP_ATOMIC);
 	if (!urb->sg)
 		return -ENOMEM;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fb627b35ae1b..d9fb409a2bcd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2559,10 +2559,12 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 	vi->ctrl = kzalloc(sizeof(*vi->ctrl), GFP_KERNEL);
 	if (!vi->ctrl)
 		goto err_ctrl;
-	vi->sq = kzalloc(sizeof(*vi->sq) * vi->max_queue_pairs, GFP_KERNEL);
+	vi->sq = kzalloc(array_size(sizeof(*vi->sq), vi->max_queue_pairs),
+			 GFP_KERNEL);
 	if (!vi->sq)
 		goto err_sq;
-	vi->rq = kzalloc(sizeof(*vi->rq) * vi->max_queue_pairs, GFP_KERNEL);
+	vi->rq = kzalloc(array_size(sizeof(*vi->rq), vi->max_queue_pairs),
+			 GFP_KERNEL);
 	if (!vi->rq)
 		goto err_rq;
 
diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 33df76405b86..0bbf1c6b7828 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -198,12 +198,12 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 		goto free_tx_bd;
 	}
 
-	priv->rx_skbuff = kzalloc(priv->rx_ring_size * sizeof(*priv->rx_skbuff),
+	priv->rx_skbuff = kzalloc(array_size(priv->rx_ring_size, sizeof(*priv->rx_skbuff)),
 				  GFP_KERNEL);
 	if (!priv->rx_skbuff)
 		goto free_ucc_pram;
 
-	priv->tx_skbuff = kzalloc(priv->tx_ring_size * sizeof(*priv->tx_skbuff),
+	priv->tx_skbuff = kzalloc(array_size(priv->tx_ring_size, sizeof(*priv->tx_skbuff)),
 				  GFP_KERNEL);
 	if (!priv->tx_skbuff)
 		goto free_rx_skbuff;
diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wireless/ath/ath10k/htt_rx.c
index 5e02e26158f6..3fc68f060fe9 100644
--- a/drivers/net/wireless/ath/ath10k/htt_rx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
@@ -581,7 +581,7 @@ int ath10k_htt_rx_alloc(struct ath10k_htt *htt)
 	}
 
 	htt->rx_ring.netbufs_ring =
-		kzalloc(htt->rx_ring.size * sizeof(struct sk_buff *),
+		kzalloc(array_size(htt->rx_ring.size, sizeof(struct sk_buff *)),
 			GFP_KERNEL);
 	if (!htt->rx_ring.netbufs_ring)
 		goto err_netbuf;
diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/ath/ath5k/phy.c
index 641b13a279e1..3e7e4ae829ee 100644
--- a/drivers/net/wireless/ath/ath5k/phy.c
+++ b/drivers/net/wireless/ath/ath5k/phy.c
@@ -890,8 +890,8 @@ ath5k_hw_rfregs_init(struct ath5k_hw *ah,
 	 * ah->ah_rf_banks based on ah->ah_rf_banks_size
 	 * we set above */
 	if (ah->ah_rf_banks == NULL) {
-		ah->ah_rf_banks = kmalloc(sizeof(u32) * ah->ah_rf_banks_size,
-								GFP_KERNEL);
+		ah->ah_rf_banks = kmalloc(array_size(sizeof(u32), ah->ah_rf_banks_size),
+					  GFP_KERNEL);
 		if (ah->ah_rf_banks == NULL) {
 			ATH5K_ERR(ah, "out of memory\n");
 			return -ENOMEM;
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
index 6343cc91953e..1dcd5cc57abd 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
@@ -925,7 +925,7 @@ int ar9003_paprd_create_curve(struct ath_hw *ah,
 
 	memset(caldata->pa_table[chain], 0, sizeof(caldata->pa_table[chain]));
 
-	buf = kmalloc(2 * 48 * sizeof(u32), GFP_KERNEL);
+	buf = kmalloc(array3_size(2, 48, sizeof(u32)), GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 04cfdd6bef55..f4a00dc294d9 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1989,8 +1989,8 @@ int carl9170_register(struct ar9170 *ar)
 	if (WARN_ON(ar->mem_bitmap))
 		return -EINVAL;
 
-	ar->mem_bitmap = kzalloc(roundup(ar->fw.mem_blocks, BITS_PER_LONG) *
-				 sizeof(unsigned long), GFP_KERNEL);
+	ar->mem_bitmap = kzalloc(array_size(roundup(ar->fw.mem_blocks, BITS_PER_LONG), sizeof(unsigned long)),
+				 GFP_KERNEL);
 
 	if (!ar->mem_bitmap)
 		return -ENOMEM;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
index 49d37ad96958..57063218f7f4 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/msgbuf.c
@@ -1486,8 +1486,8 @@ int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr)
 		(struct brcmf_commonring **)if_msgbuf->commonrings;
 	msgbuf->flowrings = (struct brcmf_commonring **)if_msgbuf->flowrings;
 	msgbuf->max_flowrings = if_msgbuf->max_flowrings;
-	msgbuf->flowring_dma_handle = kzalloc(msgbuf->max_flowrings *
-		sizeof(*msgbuf->flowring_dma_handle), GFP_KERNEL);
+	msgbuf->flowring_dma_handle = kzalloc(array_size(msgbuf->max_flowrings, sizeof(*msgbuf->flowring_dma_handle)),
+					      GFP_KERNEL);
 	if (!msgbuf->flowring_dma_handle)
 		goto fail;
 
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
index 88eb34244caa..fc2cc7cecdd2 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
@@ -24665,7 +24665,8 @@ wlc_phy_a1_nphy(struct brcms_phy *pi, u8 core, u32 winsz, u32 start,
 
 	sz = end - start + 1;
 
-	buf = kmalloc(2 * sizeof(u32) * NPHY_PAPD_EPS_TBL_SIZE, GFP_ATOMIC);
+	buf = kmalloc(array3_size(2, sizeof(u32), NPHY_PAPD_EPS_TBL_SIZE),
+		      GFP_ATOMIC);
 	if (NULL == buf)
 		return;
 
diff --git a/drivers/net/wireless/intel/iwlegacy/common.c b/drivers/net/wireless/intel/iwlegacy/common.c
index a5d5748f5d30..093fac4694e8 100644
--- a/drivers/net/wireless/intel/iwlegacy/common.c
+++ b/drivers/net/wireless/intel/iwlegacy/common.c
@@ -922,7 +922,7 @@ il_init_channel_map(struct il_priv *il)
 	D_EEPROM("Parsing data for %d channels.\n", il->channel_count);
 
 	il->channel_info =
-	    kzalloc(sizeof(struct il_channel_info) * il->channel_count,
+	    kzalloc(array_size(sizeof(struct il_channel_info), il->channel_count),
 		    GFP_KERNEL);
 	if (!il->channel_info) {
 		IL_ERR("Could not allocate channel_info\n");
@@ -3457,7 +3457,7 @@ il_init_geos(struct il_priv *il)
 	}
 
 	channels =
-	    kzalloc(sizeof(struct ieee80211_channel) * il->channel_count,
+	    kzalloc(array_size(sizeof(struct ieee80211_channel), il->channel_count),
 		    GFP_KERNEL);
 	if (!channels)
 		return -ENOMEM;
@@ -4656,8 +4656,8 @@ il_alloc_txq_mem(struct il_priv *il)
 {
 	if (!il->txq)
 		il->txq =
-		    kzalloc(sizeof(struct il_tx_queue) *
-			    il->cfg->num_of_queues, GFP_KERNEL);
+		    kzalloc(array_size(sizeof(struct il_tx_queue), il->cfg->num_of_queues),
+			    GFP_KERNEL);
 	if (!il->txq) {
 		IL_ERR("Not enough memory for txq\n");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/intersil/p54/eeprom.c b/drivers/net/wireless/intersil/p54/eeprom.c
index b792fe1eda66..aa4d83e0b0b4 100644
--- a/drivers/net/wireless/intersil/p54/eeprom.c
+++ b/drivers/net/wireless/intersil/p54/eeprom.c
@@ -161,8 +161,8 @@ static int p54_generate_band(struct ieee80211_hw *dev,
 	if (!tmp)
 		goto err_out;
 
-	tmp->channels = kzalloc(sizeof(struct ieee80211_channel) *
-				list->band_channel_num[band], GFP_KERNEL);
+	tmp->channels = kzalloc(array_size(sizeof(struct ieee80211_channel), list->band_channel_num[band]),
+				GFP_KERNEL);
 	if (!tmp->channels)
 		goto err_out;
 
diff --git a/drivers/net/wireless/intersil/prism54/oid_mgt.c b/drivers/net/wireless/intersil/prism54/oid_mgt.c
index 6528ed5b9b1d..9b26131745b0 100644
--- a/drivers/net/wireless/intersil/prism54/oid_mgt.c
+++ b/drivers/net/wireless/intersil/prism54/oid_mgt.c
@@ -244,8 +244,7 @@ mgt_init(islpci_private *priv)
 	/* Alloc the cache */
 	for (i = 0; i < OID_NUM_LAST; i++) {
 		if (isl_oid[i].flags & OID_FLAG_CACHED) {
-			priv->mib[i] = kzalloc(isl_oid[i].size *
-					       (isl_oid[i].range + 1),
+			priv->mib[i] = kzalloc(array_size(isl_oid[i].size, (isl_oid[i].range + 1)),
 					       GFP_KERNEL);
 			if (!priv->mib[i])
 				return -ENOMEM;
diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index a82880132af4..a69c8018e549 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -2094,15 +2094,15 @@ static int mwifiex_init_sdio(struct mwifiex_adapter *adapter)
 		return -ENOMEM;
 
 	/* Allocate skb pointer buffers */
-	card->mpa_rx.skb_arr = kzalloc((sizeof(void *)) *
-				       card->mp_agg_pkt_limit, GFP_KERNEL);
+	card->mpa_rx.skb_arr = kzalloc(array_size((sizeof(void *)), card->mp_agg_pkt_limit),
+				       GFP_KERNEL);
 	if (!card->mpa_rx.skb_arr) {
 		kfree(card->mp_regs);
 		return -ENOMEM;
 	}
 
-	card->mpa_rx.len_arr = kzalloc(sizeof(*card->mpa_rx.len_arr) *
-				       card->mp_agg_pkt_limit, GFP_KERNEL);
+	card->mpa_rx.len_arr = kzalloc(array_size(sizeof(*card->mpa_rx.len_arr), card->mp_agg_pkt_limit),
+				       GFP_KERNEL);
 	if (!card->mpa_rx.len_arr) {
 		kfree(card->mp_regs);
 		kfree(card->mpa_rx.skb_arr);
diff --git a/drivers/net/wireless/mediatek/mt7601u/init.c b/drivers/net/wireless/mediatek/mt7601u/init.c
index d3b611aaf061..1b1014e9afcd 100644
--- a/drivers/net/wireless/mediatek/mt7601u/init.c
+++ b/drivers/net/wireless/mediatek/mt7601u/init.c
@@ -182,7 +182,7 @@ static int mt7601u_init_wcid_mem(struct mt7601u_dev *dev)
 	u32 *vals;
 	int i, ret;
 
-	vals = kmalloc(sizeof(*vals) * N_WCIDS * 2, GFP_KERNEL);
+	vals = kmalloc(array3_size(sizeof(*vals), N_WCIDS, 2), GFP_KERNEL);
 	if (!vals)
 		return -ENOMEM;
 
@@ -211,7 +211,7 @@ static int mt7601u_init_wcid_attr_mem(struct mt7601u_dev *dev)
 	u32 *vals;
 	int i, ret;
 
-	vals = kmalloc(sizeof(*vals) * N_WCIDS * 2, GFP_KERNEL);
+	vals = kmalloc(array3_size(sizeof(*vals), N_WCIDS, 2), GFP_KERNEL);
 	if (!vals)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/quantenna/qtnfmac/commands.c b/drivers/net/wireless/quantenna/qtnfmac/commands.c
index deca0060eb27..4cb71b3d9f3e 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/commands.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/commands.c
@@ -1193,7 +1193,7 @@ static int qtnf_parse_variable_mac_info(struct qtnf_wmac *mac,
 				return -EINVAL;
 			}
 
-			limits = kzalloc(sizeof(*limits) * rec->n_limits,
+			limits = kzalloc(array_size(sizeof(*limits), rec->n_limits),
 					 GFP_KERNEL);
 			if (!limits)
 				return -ENOMEM;
diff --git a/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c b/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
index 0eee479583b8..645436c5d515 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
@@ -397,7 +397,8 @@ static ssize_t rt2x00debug_read_crypto_stats(struct file *file,
 	if (*offset)
 		return 0;
 
-	data = kzalloc((1 + CIPHER_MAX) * MAX_LINE_LENGTH, GFP_KERNEL);
+	data = kzalloc(array_size((1 + CIPHER_MAX), MAX_LINE_LENGTH),
+		       GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
@@ -597,7 +598,7 @@ static struct dentry *rt2x00debug_create_file_driver(const char *name,
 {
 	char *data;
 
-	data = kzalloc(3 * MAX_LINE_LENGTH, GFP_KERNEL);
+	data = kzalloc(array_size(3, MAX_LINE_LENGTH), GFP_KERNEL);
 	if (!data)
 		return NULL;
 
@@ -619,7 +620,7 @@ static struct dentry *rt2x00debug_create_file_chipset(const char *name,
 	const struct rt2x00debug *debug = intf->debug;
 	char *data;
 
-	data = kzalloc(9 * MAX_LINE_LENGTH, GFP_KERNEL);
+	data = kzalloc(array_size(9, MAX_LINE_LENGTH), GFP_KERNEL);
 	if (!data)
 		return NULL;
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/efuse.c b/drivers/net/wireless/realtek/rtlwifi/efuse.c
index fd13d4ef53b8..6d8d58589e06 100644
--- a/drivers/net/wireless/realtek/rtlwifi/efuse.c
+++ b/drivers/net/wireless/realtek/rtlwifi/efuse.c
@@ -258,8 +258,8 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	}
 
 	/* allocate memory for efuse_tbl and efuse_word */
-	efuse_tbl = kzalloc(rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE] *
-			    sizeof(u8), GFP_ATOMIC);
+	efuse_tbl = kzalloc(array_size(rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE], sizeof(u8)),
+			    GFP_ATOMIC);
 	if (!efuse_tbl)
 		return;
 	efuse_word = kcalloc(EFUSE_MAX_WORD_UNIT, sizeof(u16 *), GFP_ATOMIC);
diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
index c21fca750fd4..daa5f8573f37 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -1194,7 +1194,7 @@ static int rsi_send_auto_rate_request(struct rsi_common *common,
 		return -ENOMEM;
 	}
 
-	selected_rates = kzalloc(2 * RSI_TBL_SZ, GFP_KERNEL);
+	selected_rates = kzalloc(array_size(2, RSI_TBL_SZ), GFP_KERNEL);
 	if (!selected_rates) {
 		rsi_dbg(ERR_ZONE, "%s: Failed in allocation of mem\n",
 			__func__);
diff --git a/drivers/net/wireless/st/cw1200/queue.c b/drivers/net/wireless/st/cw1200/queue.c
index 8b8453fac571..5a0da3d63721 100644
--- a/drivers/net/wireless/st/cw1200/queue.c
+++ b/drivers/net/wireless/st/cw1200/queue.c
@@ -186,8 +186,8 @@ int cw1200_queue_init(struct cw1200_queue *queue,
 	if (!queue->pool)
 		return -ENOMEM;
 
-	queue->link_map_cache = kzalloc(sizeof(int) * stats->map_capacity,
-			GFP_KERNEL);
+	queue->link_map_cache = kzalloc(array_size(sizeof(int), stats->map_capacity),
+					GFP_KERNEL);
 	if (!queue->link_map_cache) {
 		kfree(queue->pool);
 		queue->pool = NULL;
diff --git a/drivers/net/wireless/st/cw1200/scan.c b/drivers/net/wireless/st/cw1200/scan.c
index cc2ce60f4f09..1474b0280665 100644
--- a/drivers/net/wireless/st/cw1200/scan.c
+++ b/drivers/net/wireless/st/cw1200/scan.c
@@ -230,9 +230,8 @@ void cw1200_scan_work(struct work_struct *work)
 			scan.type = WSM_SCAN_TYPE_BACKGROUND;
 			scan.flags = WSM_SCAN_FLAG_FORCE_BACKGROUND;
 		}
-		scan.ch = kzalloc(
-			sizeof(struct wsm_scan_ch) * (it - priv->scan.curr),
-			GFP_KERNEL);
+		scan.ch = kzalloc(array_size(sizeof(struct wsm_scan_ch), (it - priv->scan.curr)),
+				  GFP_KERNEL);
 		if (!scan.ch) {
 			priv->scan.status = -ENOMEM;
 			goto fail;
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index 62ce54a949e9..a811388d8979 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -321,7 +321,8 @@ static int __wl12xx_spi_raw_write(struct device *child, int addr,
 	int i;
 
 	/* SPI write buffers - 2 for each chunk */
-	t = kzalloc(sizeof(*t) * 2 * WSPI_MAX_NUM_OF_CHUNKS, GFP_KERNEL);
+	t = kzalloc(array3_size(sizeof(*t), 2, WSPI_MAX_NUM_OF_CHUNKS),
+		    GFP_KERNEL);
 	if (!t)
 		return -ENOMEM;
 
diff --git a/drivers/nvmem/sunxi_sid.c b/drivers/nvmem/sunxi_sid.c
index 26bb637afe92..a796c5582f3f 100644
--- a/drivers/nvmem/sunxi_sid.c
+++ b/drivers/nvmem/sunxi_sid.c
@@ -185,7 +185,7 @@ static int sunxi_sid_probe(struct platform_device *pdev)
 	if (IS_ERR(nvmem))
 		return PTR_ERR(nvmem);
 
-	randomness = kzalloc(sizeof(u8) * (size), GFP_KERNEL);
+	randomness = kzalloc(array_size(sizeof(u8), (size)), GFP_KERNEL);
 	if (!randomness) {
 		ret = -EINVAL;
 		goto err_unreg_nvmem;
diff --git a/drivers/of/platform.c b/drivers/of/platform.c
index c00d81dfac0b..ae23aa217dd1 100644
--- a/drivers/of/platform.c
+++ b/drivers/of/platform.c
@@ -124,7 +124,8 @@ struct platform_device *of_device_alloc(struct device_node *np,
 
 	/* Populate the resource table */
 	if (num_irq || num_reg) {
-		res = kzalloc(sizeof(*res) * (num_irq + num_reg), GFP_KERNEL);
+		res = kzalloc(array_size(sizeof(*res), (num_irq + num_reg)),
+			      GFP_KERNEL);
 		if (!res) {
 			platform_device_put(dev);
 			return NULL;
diff --git a/drivers/opp/ti-opp-supply.c b/drivers/opp/ti-opp-supply.c
index 370eff3acd8a..1f4c5a308701 100644
--- a/drivers/opp/ti-opp-supply.c
+++ b/drivers/opp/ti-opp-supply.c
@@ -122,8 +122,8 @@ static int _store_optimized_voltages(struct device *dev,
 		goto out;
 	}
 
-	table = kzalloc(sizeof(*data->vdd_table) *
-				  data->num_vdd_table, GFP_KERNEL);
+	table = kzalloc(array_size(sizeof(*data->vdd_table), data->num_vdd_table),
+			GFP_KERNEL);
 	if (!table) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 82d241f5bf3b..8512c7c11ef1 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -474,7 +474,8 @@ static int populate_msi_sysfs(struct pci_dev *pdev)
 		return 0;
 
 	/* Dynamically create the MSI attributes for the PCI device */
-	msi_attrs = kzalloc(sizeof(void *) * (num_msi + 1), GFP_KERNEL);
+	msi_attrs = kzalloc(array_size(sizeof(void *), (num_msi + 1)),
+			    GFP_KERNEL);
 	if (!msi_attrs)
 		return -ENOMEM;
 	for_each_pci_msi_entry(entry, pdev) {
diff --git a/drivers/pinctrl/bcm/pinctrl-bcm2835.c b/drivers/pinctrl/bcm/pinctrl-bcm2835.c
index 785c366fd6d6..3974f48a3bd5 100644
--- a/drivers/pinctrl/bcm/pinctrl-bcm2835.c
+++ b/drivers/pinctrl/bcm/pinctrl-bcm2835.c
@@ -775,8 +775,8 @@ static int bcm2835_pctl_dt_node_to_map(struct pinctrl_dev *pctldev,
 		maps_per_pin++;
 	if (num_pulls)
 		maps_per_pin++;
-	cur_map = maps = kzalloc(num_pins * maps_per_pin * sizeof(*maps),
-				GFP_KERNEL);
+	cur_map = maps = kzalloc(array3_size(num_pins, maps_per_pin, sizeof(*maps)),
+				 GFP_KERNEL);
 	if (!maps)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-lantiq.c b/drivers/pinctrl/pinctrl-lantiq.c
index 41dc39c7a7b1..81632af3a86a 100644
--- a/drivers/pinctrl/pinctrl-lantiq.c
+++ b/drivers/pinctrl/pinctrl-lantiq.c
@@ -158,7 +158,8 @@ static int ltq_pinctrl_dt_node_to_map(struct pinctrl_dev *pctldev,
 
 	for_each_child_of_node(np_config, np)
 		max_maps += ltq_pinctrl_dt_subnode_size(np);
-	*map = kzalloc(max_maps * sizeof(struct pinctrl_map) * 2, GFP_KERNEL);
+	*map = kzalloc(array3_size(max_maps, sizeof(struct pinctrl_map), 2),
+		       GFP_KERNEL);
 	if (!*map)
 		return -ENOMEM;
 	tmp = *map;
diff --git a/drivers/pinctrl/vt8500/pinctrl-wmt.c b/drivers/pinctrl/vt8500/pinctrl-wmt.c
index d73956bdc211..291d29734c52 100644
--- a/drivers/pinctrl/vt8500/pinctrl-wmt.c
+++ b/drivers/pinctrl/vt8500/pinctrl-wmt.c
@@ -352,7 +352,7 @@ static int wmt_pctl_dt_node_to_map(struct pinctrl_dev *pctldev,
 	if (num_pulls)
 		maps_per_pin++;
 
-	cur_map = maps = kzalloc(num_pins * maps_per_pin * sizeof(*maps),
+	cur_map = maps = kzalloc(array3_size(num_pins, maps_per_pin, sizeof(*maps)),
 				 GFP_KERNEL);
 	if (!maps)
 		return -ENOMEM;
diff --git a/drivers/platform/x86/alienware-wmi.c b/drivers/platform/x86/alienware-wmi.c
index 9d7dbd925065..4c3d24ddbdd9 100644
--- a/drivers/platform/x86/alienware-wmi.c
+++ b/drivers/platform/x86/alienware-wmi.c
@@ -458,19 +458,19 @@ static int alienware_zone_init(struct platform_device *dev)
 	 *      - zone_data num_zones is for the distinct zones
 	 */
 	zone_dev_attrs =
-	    kzalloc(sizeof(struct device_attribute) * (quirks->num_zones + 1),
+	    kzalloc(array_size(sizeof(struct device_attribute), (quirks->num_zones + 1)),
 		    GFP_KERNEL);
 	if (!zone_dev_attrs)
 		return -ENOMEM;
 
 	zone_attrs =
-	    kzalloc(sizeof(struct attribute *) * (quirks->num_zones + 2),
+	    kzalloc(array_size(sizeof(struct attribute *), (quirks->num_zones + 2)),
 		    GFP_KERNEL);
 	if (!zone_attrs)
 		return -ENOMEM;
 
 	zone_data =
-	    kzalloc(sizeof(struct platform_zone) * (quirks->num_zones),
+	    kzalloc(array_size(sizeof(struct platform_zone), (quirks->num_zones)),
 		    GFP_KERNEL);
 	if (!zone_data)
 		return -ENOMEM;
diff --git a/drivers/platform/x86/panasonic-laptop.c b/drivers/platform/x86/panasonic-laptop.c
index 5c39b3211709..9d103996582d 100644
--- a/drivers/platform/x86/panasonic-laptop.c
+++ b/drivers/platform/x86/panasonic-laptop.c
@@ -571,7 +571,8 @@ static int acpi_pcc_hotkey_add(struct acpi_device *device)
 		return -ENOMEM;
 	}
 
-	pcc->sinf = kzalloc(sizeof(u32) * (num_sifr + 1), GFP_KERNEL);
+	pcc->sinf = kzalloc(array_size(sizeof(u32), (num_sifr + 1)),
+			    GFP_KERNEL);
 	if (!pcc->sinf) {
 		result = -ENOMEM;
 		goto out_hotkey;
diff --git a/drivers/rapidio/rio-scan.c b/drivers/rapidio/rio-scan.c
index 161b927d9de1..7582badc41a1 100644
--- a/drivers/rapidio/rio-scan.c
+++ b/drivers/rapidio/rio-scan.c
@@ -425,9 +425,8 @@ static struct rio_dev *rio_setup_device(struct rio_net *net,
 		rswitch = rdev->rswitch;
 		rswitch->port_ok = 0;
 		spin_lock_init(&rswitch->lock);
-		rswitch->route_table = kzalloc(sizeof(u8)*
-					RIO_MAX_ROUTE_ENTRIES(port->sys_size),
-					GFP_KERNEL);
+		rswitch->route_table = kzalloc(array_size(sizeof(u8), RIO_MAX_ROUTE_ENTRIES(port->sys_size)),
+					       GFP_KERNEL);
 		if (!rswitch->route_table)
 			goto cleanup;
 		/* Initialize switch route table */
diff --git a/drivers/s390/block/dasd_eer.c b/drivers/s390/block/dasd_eer.c
index fb2c3599d95c..f9a22546c347 100644
--- a/drivers/s390/block/dasd_eer.c
+++ b/drivers/s390/block/dasd_eer.c
@@ -561,7 +561,7 @@ static int dasd_eer_open(struct inode *inp, struct file *filp)
 		return -EINVAL;
 	}
 	eerb->buffersize = eerb->buffer_page_count * PAGE_SIZE;
-	eerb->buffer = kmalloc(eerb->buffer_page_count * sizeof(char *),
+	eerb->buffer = kmalloc(array_size(eerb->buffer_page_count, sizeof(char *)),
 			       GFP_KERNEL);
         if (!eerb->buffer) {
 		kfree(eerb);
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 0a312e450207..be861315be77 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -231,9 +231,8 @@ dcssblk_is_continuous(struct dcssblk_dev_info *dev_info)
 	if (dev_info->num_of_segments <= 1)
 		return 0;
 
-	sort_list = kzalloc(
-			sizeof(struct segment_info) * dev_info->num_of_segments,
-			GFP_KERNEL);
+	sort_list = kzalloc(array_size(sizeof(struct segment_info), dev_info->num_of_segments),
+			    GFP_KERNEL);
 	if (sort_list == NULL)
 		return -ENOMEM;
 	i = 0;
diff --git a/drivers/s390/char/vmur.c b/drivers/s390/char/vmur.c
index 52aa89424318..c594dc9efab8 100644
--- a/drivers/s390/char/vmur.c
+++ b/drivers/s390/char/vmur.c
@@ -242,7 +242,7 @@ static struct ccw1 *alloc_chan_prog(const char __user *ubuf, int rec_count,
 	 * That means we allocate room for CCWs to cover count/reclen
 	 * records plus a NOP.
 	 */
-	cpa = kzalloc((rec_count + 1) * sizeof(struct ccw1),
+	cpa = kzalloc(array_size((rec_count + 1), sizeof(struct ccw1)),
 		      GFP_KERNEL | GFP_DMA);
 	if (!cpa)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/s390/char/zcore.c b/drivers/s390/char/zcore.c
index 4369662cfff5..68689ee669d6 100644
--- a/drivers/s390/char/zcore.c
+++ b/drivers/s390/char/zcore.c
@@ -152,7 +152,8 @@ static int zcore_memmap_open(struct inode *inode, struct file *filp)
 	char *buf;
 	int i = 0;
 
-	buf = kzalloc(memblock.memory.cnt * CHUNK_INFO_SIZE, GFP_KERNEL);
+	buf = kzalloc(array_size(memblock.memory.cnt, CHUNK_INFO_SIZE),
+		      GFP_KERNEL);
 	if (!buf) {
 		return -ENOMEM;
 	}
diff --git a/drivers/s390/crypto/pkey_api.c b/drivers/s390/crypto/pkey_api.c
index 2dfe566c208a..3ec3cb27885a 100644
--- a/drivers/s390/crypto/pkey_api.c
+++ b/drivers/s390/crypto/pkey_api.c
@@ -121,7 +121,7 @@ static int alloc_and_prep_cprbmem(size_t paramblen,
 	 * allocate consecutive memory for request CPRB, request param
 	 * block, reply CPRB and reply param block
 	 */
-	cprbmem = kzalloc(2 * cprbplusparamblen, GFP_KERNEL);
+	cprbmem = kzalloc(array_size(2, cprbplusparamblen), GFP_KERNEL);
 	if (!cprbmem)
 		return -ENOMEM;
 
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index a04dafbe3bf2..079655c43188 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -374,9 +374,8 @@ static int qeth_alloc_cq(struct qeth_card *card)
 		}
 		card->qdio.no_in_queues = 2;
 		card->qdio.out_bufstates =
-			kzalloc(card->qdio.no_out_queues *
-				QDIO_MAX_BUFFERS_PER_Q *
-				sizeof(struct qdio_outbuf_state), GFP_KERNEL);
+			kzalloc(array3_size(card->qdio.no_out_queues, QDIO_MAX_BUFFERS_PER_Q, sizeof(struct qdio_outbuf_state)),
+				GFP_KERNEL);
 		outbuf_states = card->qdio.out_bufstates;
 		if (outbuf_states == NULL) {
 			rc = -1;
@@ -2538,8 +2537,8 @@ static int qeth_alloc_qdio_buffers(struct qeth_card *card)
 
 	/* outbound */
 	card->qdio.out_qs =
-		kzalloc(card->qdio.no_out_queues *
-			sizeof(struct qeth_qdio_out_q *), GFP_KERNEL);
+		kzalloc(array_size(card->qdio.no_out_queues, sizeof(struct qeth_qdio_out_q *)),
+			GFP_KERNEL);
 	if (!card->qdio.out_qs)
 		goto out_freepool;
 	for (i = 0; i < card->qdio.no_out_queues; ++i) {
@@ -4976,8 +4975,7 @@ static int qeth_qdio_establish(struct qeth_card *card)
 	qeth_create_qib_param_field(card, qib_param_field);
 	qeth_create_qib_param_field_blkt(card, qib_param_field);
 
-	in_sbal_ptrs = kzalloc(card->qdio.no_in_queues *
-			       QDIO_MAX_BUFFERS_PER_Q * sizeof(void *),
+	in_sbal_ptrs = kzalloc(array3_size(card->qdio.no_in_queues, QDIO_MAX_BUFFERS_PER_Q, sizeof(void *)),
 			       GFP_KERNEL);
 	if (!in_sbal_ptrs) {
 		rc = -ENOMEM;
@@ -4988,7 +4986,7 @@ static int qeth_qdio_establish(struct qeth_card *card)
 			virt_to_phys(card->qdio.in_q->bufs[i].buffer);
 	}
 
-	queue_start_poll = kzalloc(sizeof(void *) * card->qdio.no_in_queues,
+	queue_start_poll = kzalloc(array_size(sizeof(void *), card->qdio.no_in_queues),
 				   GFP_KERNEL);
 	if (!queue_start_poll) {
 		rc = -ENOMEM;
@@ -5000,8 +4998,8 @@ static int qeth_qdio_establish(struct qeth_card *card)
 	qeth_qdio_establish_cq(card, in_sbal_ptrs, queue_start_poll);
 
 	out_sbal_ptrs =
-		kzalloc(card->qdio.no_out_queues * QDIO_MAX_BUFFERS_PER_Q *
-			sizeof(void *), GFP_KERNEL);
+		kzalloc(array3_size(card->qdio.no_out_queues, QDIO_MAX_BUFFERS_PER_Q, sizeof(void *)),
+			GFP_KERNEL);
 	if (!out_sbal_ptrs) {
 		rc = -ENOMEM;
 		goto out_free_queue_start_poll;
diff --git a/drivers/scsi/aacraid/linit.c b/drivers/scsi/aacraid/linit.c
index f24fb942065d..ce1409e2eb94 100644
--- a/drivers/scsi/aacraid/linit.c
+++ b/drivers/scsi/aacraid/linit.c
@@ -1681,7 +1681,8 @@ static int aac_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (aac_reset_devices || reset_devices)
 		aac->init_reset = true;
 
-	aac->fibs = kzalloc(sizeof(struct fib) * (shost->can_queue + AAC_NUM_MGT_FIB), GFP_KERNEL);
+	aac->fibs = kzalloc(array_size(sizeof(struct fib), (shost->can_queue + AAC_NUM_MGT_FIB)),
+			    GFP_KERNEL);
 	if (!aac->fibs)
 		goto out_free_host;
 	spin_lock_init(&aac->fib_lock);
diff --git a/drivers/scsi/aic7xxx/aic79xx_core.c b/drivers/scsi/aic7xxx/aic79xx_core.c
index 034f4eebb160..52584ccc41a5 100644
--- a/drivers/scsi/aic7xxx/aic79xx_core.c
+++ b/drivers/scsi/aic7xxx/aic79xx_core.c
@@ -7063,7 +7063,8 @@ ahd_init(struct ahd_softc *ahd)
 	AHD_ASSERT_MODES(ahd, AHD_MODE_SCSI_MSK, AHD_MODE_SCSI_MSK);
 
 	ahd->stack_size = ahd_probe_stack_size(ahd);
-	ahd->saved_stack = kmalloc(ahd->stack_size * sizeof(uint16_t), GFP_ATOMIC);
+	ahd->saved_stack = kmalloc(array_size(ahd->stack_size, sizeof(uint16_t)),
+				   GFP_ATOMIC);
 	if (ahd->saved_stack == NULL)
 		return (ENOMEM);
 
diff --git a/drivers/scsi/aic94xx/aic94xx_hwi.c b/drivers/scsi/aic94xx/aic94xx_hwi.c
index 2dbc8330d7d3..a63338f3eb7e 100644
--- a/drivers/scsi/aic94xx/aic94xx_hwi.c
+++ b/drivers/scsi/aic94xx/aic94xx_hwi.c
@@ -220,8 +220,8 @@ static int asd_init_scbs(struct asd_ha_struct *asd_ha)
 
 	/* allocate the index array and bitmap */
 	asd_ha->seq.tc_index_bitmap_bits = asd_ha->hw_prof.max_scbs;
-	asd_ha->seq.tc_index_array = kzalloc(asd_ha->seq.tc_index_bitmap_bits*
-					     sizeof(void *), GFP_KERNEL);
+	asd_ha->seq.tc_index_array = kzalloc(array_size(asd_ha->seq.tc_index_bitmap_bits, sizeof(void *)),
+					     GFP_KERNEL);
 	if (!asd_ha->seq.tc_index_array)
 		return -ENOMEM;
 
@@ -291,7 +291,8 @@ static int asd_alloc_edbs(struct asd_ha_struct *asd_ha, gfp_t gfp_flags)
 	struct asd_seq_data *seq = &asd_ha->seq;
 	int i;
 
-	seq->edb_arr = kmalloc(seq->num_edbs*sizeof(*seq->edb_arr), gfp_flags);
+	seq->edb_arr = kmalloc(array_size(seq->num_edbs, sizeof(*seq->edb_arr)),
+			       gfp_flags);
 	if (!seq->edb_arr)
 		return -ENOMEM;
 
@@ -323,7 +324,7 @@ static int asd_alloc_escbs(struct asd_ha_struct *asd_ha,
 	struct asd_ascb *escb;
 	int i, escbs;
 
-	seq->escb_arr = kmalloc(seq->num_escbs*sizeof(*seq->escb_arr),
+	seq->escb_arr = kmalloc(array_size(seq->num_escbs, sizeof(*seq->escb_arr)),
 				gfp_flags);
 	if (!seq->escb_arr)
 		return -ENOMEM;
diff --git a/drivers/scsi/aic94xx/aic94xx_init.c b/drivers/scsi/aic94xx/aic94xx_init.c
index 6c838865ac5a..c926944663ad 100644
--- a/drivers/scsi/aic94xx/aic94xx_init.c
+++ b/drivers/scsi/aic94xx/aic94xx_init.c
@@ -350,7 +350,7 @@ static ssize_t asd_store_update_bios(struct device *dev,
 	int flash_command = FLASH_CMD_NONE;
 	int err = 0;
 
-	cmd_ptr = kzalloc(count*2, GFP_KERNEL);
+	cmd_ptr = kzalloc(array_size(count, 2), GFP_KERNEL);
 
 	if (!cmd_ptr) {
 		err = FAIL_OUT_MEMORY;
diff --git a/drivers/scsi/be2iscsi/be_main.c b/drivers/scsi/be2iscsi/be_main.c
index ac7fbc7a9465..34d3cf37cdfc 100644
--- a/drivers/scsi/be2iscsi/be_main.c
+++ b/drivers/scsi/be2iscsi/be_main.c
@@ -2467,8 +2467,7 @@ static int beiscsi_alloc_mem(struct beiscsi_hba *phba)
 
 	/* Allocate memory for wrb_context */
 	phwi_ctrlr = phba->phwi_ctrlr;
-	phwi_ctrlr->wrb_context = kzalloc(sizeof(struct hwi_wrb_context) *
-					  phba->params.cxns_per_ctrl,
+	phwi_ctrlr->wrb_context = kzalloc(array_size(sizeof(struct hwi_wrb_context), phba->params.cxns_per_ctrl),
 					  GFP_KERNEL);
 	if (!phwi_ctrlr->wrb_context) {
 		kfree(phba->phwi_ctrlr);
@@ -2620,8 +2619,7 @@ static int beiscsi_init_wrb_handle(struct beiscsi_hba *phba)
 
 	/* Allocate memory for WRBQ */
 	phwi_ctxt = phwi_ctrlr->phwi_ctxt;
-	phwi_ctxt->be_wrbq = kzalloc(sizeof(struct be_queue_info) *
-				     phba->params.cxns_per_ctrl,
+	phwi_ctxt->be_wrbq = kzalloc(array_size(sizeof(struct be_queue_info), phba->params.cxns_per_ctrl),
 				     GFP_KERNEL);
 	if (!phwi_ctxt->be_wrbq) {
 		beiscsi_log(phba, KERN_ERR, BEISCSI_LOG_INIT,
@@ -2632,16 +2630,16 @@ static int beiscsi_init_wrb_handle(struct beiscsi_hba *phba)
 	for (index = 0; index < phba->params.cxns_per_ctrl; index++) {
 		pwrb_context = &phwi_ctrlr->wrb_context[index];
 		pwrb_context->pwrb_handle_base =
-				kzalloc(sizeof(struct wrb_handle *) *
-					phba->params.wrbs_per_cxn, GFP_KERNEL);
+				kzalloc(array_size(sizeof(struct wrb_handle *), phba->params.wrbs_per_cxn),
+					GFP_KERNEL);
 		if (!pwrb_context->pwrb_handle_base) {
 			beiscsi_log(phba, KERN_ERR, BEISCSI_LOG_INIT,
 				    "BM_%d : Mem Alloc Failed. Failing to load\n");
 			goto init_wrb_hndl_failed;
 		}
 		pwrb_context->pwrb_handle_basestd =
-				kzalloc(sizeof(struct wrb_handle *) *
-					phba->params.wrbs_per_cxn, GFP_KERNEL);
+				kzalloc(array_size(sizeof(struct wrb_handle *), phba->params.wrbs_per_cxn),
+					GFP_KERNEL);
 		if (!pwrb_context->pwrb_handle_basestd) {
 			beiscsi_log(phba, KERN_ERR, BEISCSI_LOG_INIT,
 				    "BM_%d : Mem Alloc Failed. Failing to load\n");
@@ -3353,7 +3351,7 @@ beiscsi_create_wrb_rings(struct beiscsi_hba *phba,
 	idx = 0;
 	mem_descr = phba->init_mem;
 	mem_descr += HWI_MEM_WRB;
-	pwrb_arr = kmalloc(sizeof(*pwrb_arr) * phba->params.cxns_per_ctrl,
+	pwrb_arr = kmalloc(array_size(sizeof(*pwrb_arr), phba->params.cxns_per_ctrl),
 			   GFP_KERNEL);
 	if (!pwrb_arr) {
 		beiscsi_log(phba, KERN_ERR, BEISCSI_LOG_INIT,
@@ -3894,17 +3892,14 @@ static int beiscsi_init_sgl_handle(struct beiscsi_hba *phba)
 	mem_descr_sglh = phba->init_mem;
 	mem_descr_sglh += HWI_MEM_SGLH;
 	if (1 == mem_descr_sglh->num_elements) {
-		phba->io_sgl_hndl_base = kzalloc(sizeof(struct sgl_handle *) *
-						 phba->params.ios_per_ctrl,
+		phba->io_sgl_hndl_base = kzalloc(array_size(sizeof(struct sgl_handle *), phba->params.ios_per_ctrl),
 						 GFP_KERNEL);
 		if (!phba->io_sgl_hndl_base) {
 			beiscsi_log(phba, KERN_ERR, BEISCSI_LOG_INIT,
 				    "BM_%d : Mem Alloc Failed. Failing to load\n");
 			return -ENOMEM;
 		}
-		phba->eh_sgl_hndl_base = kzalloc(sizeof(struct sgl_handle *) *
-						 (phba->params.icds_per_ctrl -
-						 phba->params.ios_per_ctrl),
+		phba->eh_sgl_hndl_base = kzalloc(array_size(sizeof(struct sgl_handle *), (phba->params.icds_per_ctrl - phba->params.ios_per_ctrl)),
 						 GFP_KERNEL);
 		if (!phba->eh_sgl_hndl_base) {
 			kfree(phba->io_sgl_hndl_base);
@@ -4032,8 +4027,8 @@ static int hba_setup_cid_tbls(struct beiscsi_hba *phba)
 			phba->cid_array_info[ulp_num] = ptr_cid_info;
 		}
 	}
-	phba->ep_array = kzalloc(sizeof(struct iscsi_endpoint *) *
-				 phba->params.cxns_per_ctrl, GFP_KERNEL);
+	phba->ep_array = kzalloc(array_size(sizeof(struct iscsi_endpoint *), phba->params.cxns_per_ctrl),
+				 GFP_KERNEL);
 	if (!phba->ep_array) {
 		beiscsi_log(phba, KERN_ERR, BEISCSI_LOG_INIT,
 			    "BM_%d : Failed to allocate memory in "
@@ -4043,8 +4038,8 @@ static int hba_setup_cid_tbls(struct beiscsi_hba *phba)
 		goto free_memory;
 	}
 
-	phba->conn_table = kzalloc(sizeof(struct beiscsi_conn *) *
-				   phba->params.cxns_per_ctrl, GFP_KERNEL);
+	phba->conn_table = kzalloc(array_size(sizeof(struct beiscsi_conn *), phba->params.cxns_per_ctrl),
+				   GFP_KERNEL);
 	if (!phba->conn_table) {
 		beiscsi_log(phba, KERN_ERR, BEISCSI_LOG_INIT,
 			    "BM_%d : Failed to allocate memory in"
diff --git a/drivers/scsi/bfa/bfad_bsg.c b/drivers/scsi/bfa/bfad_bsg.c
index 7c884f881180..ad6ae5d1ca25 100644
--- a/drivers/scsi/bfa/bfad_bsg.c
+++ b/drivers/scsi/bfa/bfad_bsg.c
@@ -3252,8 +3252,8 @@ bfad_fcxp_map_sg(struct bfad_s *bfad, void *payload_kbuf,
 	struct bfa_sge_s	*sg_table;
 	int sge_num = 1;
 
-	buf_base = kzalloc((sizeof(struct bfad_buf_info) +
-			   sizeof(struct bfa_sge_s)) * sge_num, GFP_KERNEL);
+	buf_base = kzalloc(array_size((sizeof(struct bfad_buf_info) + sizeof(struct bfa_sge_s)), sge_num),
+			   GFP_KERNEL);
 	if (!buf_base)
 		return NULL;
 
diff --git a/drivers/scsi/csiostor/csio_wr.c b/drivers/scsi/csiostor/csio_wr.c
index c0a17789752f..6dd3742d575f 100644
--- a/drivers/scsi/csiostor/csio_wr.c
+++ b/drivers/scsi/csiostor/csio_wr.c
@@ -276,8 +276,7 @@ csio_wr_alloc_q(struct csio_hw *hw, uint32_t qsize, uint32_t wrsize,
 			q->un.iq.flq_idx = flq_idx;
 
 			flq = wrm->q_arr[q->un.iq.flq_idx];
-			flq->un.fl.bufs = kzalloc(flq->credits *
-						  sizeof(struct csio_dma_buf),
+			flq->un.fl.bufs = kzalloc(array_size(flq->credits, sizeof(struct csio_dma_buf)),
 						  GFP_KERNEL);
 			if (!flq->un.fl.bufs) {
 				csio_err(hw,
@@ -1579,7 +1578,8 @@ csio_wrm_init(struct csio_wrm *wrm, struct csio_hw *hw)
 		return -EINVAL;
 	}
 
-	wrm->q_arr = kzalloc(sizeof(struct csio_q *) * wrm->num_q, GFP_KERNEL);
+	wrm->q_arr = kzalloc(array_size(sizeof(struct csio_q *), wrm->num_q),
+			     GFP_KERNEL);
 	if (!wrm->q_arr)
 		goto err;
 
diff --git a/drivers/scsi/dpt_i2o.c b/drivers/scsi/dpt_i2o.c
index 5ceea8da7bb6..24af766ca1cb 100644
--- a/drivers/scsi/dpt_i2o.c
+++ b/drivers/scsi/dpt_i2o.c
@@ -1739,7 +1739,7 @@ static int adpt_i2o_passthru(adpt_hba* pHba, u32 __user *arg)
 		reply_size = REPLY_FRAME_SIZE;
 	}
 	reply_size *= 4;
-	reply = kzalloc(REPLY_FRAME_SIZE*4, GFP_KERNEL);
+	reply = kzalloc(array_size(REPLY_FRAME_SIZE, 4), GFP_KERNEL);
 	if(reply == NULL) {
 		printk(KERN_WARNING"%s: Could not allocate reply buffer\n",pHba->name);
 		return -ENOMEM;
diff --git a/drivers/scsi/esas2r/esas2r_init.c b/drivers/scsi/esas2r/esas2r_init.c
index ed2dd0d23a2a..99033d53570b 100644
--- a/drivers/scsi/esas2r/esas2r_init.c
+++ b/drivers/scsi/esas2r/esas2r_init.c
@@ -854,8 +854,8 @@ bool esas2r_init_adapter_struct(struct esas2r_adapter *a,
 
 	/* allocate the request table */
 	a->req_table =
-		kzalloc((num_requests + num_ae_requests +
-			 1) * sizeof(struct esas2r_request *), GFP_KERNEL);
+		kzalloc(array_size((num_requests + num_ae_requests + 1), sizeof(struct esas2r_request *)),
+			GFP_KERNEL);
 
 	if (a->req_table == NULL) {
 		esas2r_log(ESAS2R_LOG_CRIT,
diff --git a/drivers/scsi/hpsa.c b/drivers/scsi/hpsa.c
index 307344abc722..614ce0c52b81 100644
--- a/drivers/scsi/hpsa.c
+++ b/drivers/scsi/hpsa.c
@@ -2173,14 +2173,14 @@ static int hpsa_allocate_ioaccel2_sg_chain_blocks(struct ctlr_info *h)
 		return 0;
 
 	h->ioaccel2_cmd_sg_list =
-		kzalloc(sizeof(*h->ioaccel2_cmd_sg_list) * h->nr_cmds,
-					GFP_KERNEL);
+		kzalloc(array_size(sizeof(*h->ioaccel2_cmd_sg_list), h->nr_cmds),
+			GFP_KERNEL);
 	if (!h->ioaccel2_cmd_sg_list)
 		return -ENOMEM;
 	for (i = 0; i < h->nr_cmds; i++) {
 		h->ioaccel2_cmd_sg_list[i] =
-			kmalloc(sizeof(*h->ioaccel2_cmd_sg_list[i]) *
-					h->maxsgentries, GFP_KERNEL);
+			kmalloc(array_size(sizeof(*h->ioaccel2_cmd_sg_list[i]), h->maxsgentries),
+				GFP_KERNEL);
 		if (!h->ioaccel2_cmd_sg_list[i])
 			goto clean;
 	}
@@ -2212,14 +2212,14 @@ static int hpsa_alloc_sg_chain_blocks(struct ctlr_info *h)
 	if (h->chainsize <= 0)
 		return 0;
 
-	h->cmd_sg_list = kzalloc(sizeof(*h->cmd_sg_list) * h->nr_cmds,
-				GFP_KERNEL);
+	h->cmd_sg_list = kzalloc(array_size(sizeof(*h->cmd_sg_list), h->nr_cmds),
+				 GFP_KERNEL);
 	if (!h->cmd_sg_list)
 		return -ENOMEM;
 
 	for (i = 0; i < h->nr_cmds; i++) {
-		h->cmd_sg_list[i] = kmalloc(sizeof(*h->cmd_sg_list[i]) *
-						h->chainsize, GFP_KERNEL);
+		h->cmd_sg_list[i] = kmalloc(array_size(sizeof(*h->cmd_sg_list[i]), h->chainsize),
+					    GFP_KERNEL);
 		if (!h->cmd_sg_list[i])
 			goto clean;
 
@@ -7156,7 +7156,7 @@ static int controller_reset_failed(struct CfgTable __iomem *cfgtable)
 	char *driver_ver, *old_driver_ver;
 	int rc, size = sizeof(cfgtable->driver_version);
 
-	old_driver_ver = kmalloc(2 * size, GFP_KERNEL);
+	old_driver_ver = kmalloc(array_size(2, size), GFP_KERNEL);
 	if (!old_driver_ver)
 		return -ENOMEM;
 	driver_ver = old_driver_ver + size;
@@ -7936,9 +7936,8 @@ static void hpsa_free_cmd_pool(struct ctlr_info *h)
 
 static int hpsa_alloc_cmd_pool(struct ctlr_info *h)
 {
-	h->cmd_pool_bits = kzalloc(
-		DIV_ROUND_UP(h->nr_cmds, BITS_PER_LONG) *
-		sizeof(unsigned long), GFP_KERNEL);
+	h->cmd_pool_bits = kzalloc(array_size(DIV_ROUND_UP(h->nr_cmds, BITS_PER_LONG), sizeof(unsigned long)),
+				   GFP_KERNEL);
 	h->cmd_pool = pci_alloc_consistent(h->pdev,
 		    h->nr_cmds * sizeof(*h->cmd_pool),
 		    &(h->cmd_pool_dhandle));
diff --git a/drivers/scsi/ipr.c b/drivers/scsi/ipr.c
index d28b68c0d25d..45b9469cb963 100644
--- a/drivers/scsi/ipr.c
+++ b/drivers/scsi/ipr.c
@@ -9711,8 +9711,8 @@ static int ipr_alloc_mem(struct ipr_ioa_cfg *ioa_cfg)
 	int i, rc = -ENOMEM;
 
 	ENTER;
-	ioa_cfg->res_entries = kzalloc(sizeof(struct ipr_resource_entry) *
-				       ioa_cfg->max_devs_supported, GFP_KERNEL);
+	ioa_cfg->res_entries = kzalloc(array_size(sizeof(struct ipr_resource_entry), ioa_cfg->max_devs_supported),
+				       GFP_KERNEL);
 
 	if (!ioa_cfg->res_entries)
 		goto out;
diff --git a/drivers/scsi/libiscsi.c b/drivers/scsi/libiscsi.c
index 15a2fef51e38..5016c429bbe1 100644
--- a/drivers/scsi/libiscsi.c
+++ b/drivers/scsi/libiscsi.c
@@ -2576,7 +2576,8 @@ iscsi_pool_init(struct iscsi_pool *q, int max, void ***items, int item_size)
 	 * the array. */
 	if (items)
 		num_arrays++;
-	q->pool = kvzalloc(num_arrays * max * sizeof(void*), GFP_KERNEL);
+	q->pool = kvzalloc(array3_size(num_arrays, max, sizeof(void *)),
+			   GFP_KERNEL);
 	if (q->pool == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/libsas/sas_expander.c b/drivers/scsi/libsas/sas_expander.c
index 8b7114348def..a8e185db1900 100644
--- a/drivers/scsi/libsas/sas_expander.c
+++ b/drivers/scsi/libsas/sas_expander.c
@@ -443,7 +443,8 @@ static int sas_expander_discover(struct domain_device *dev)
 	struct expander_device *ex = &dev->ex_dev;
 	int res = -ENOMEM;
 
-	ex->ex_phy = kzalloc(sizeof(*ex->ex_phy)*ex->num_phys, GFP_KERNEL);
+	ex->ex_phy = kzalloc(array_size(sizeof(*ex->ex_phy), ex->num_phys),
+			     GFP_KERNEL);
 	if (!ex->ex_phy)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/lpfc/lpfc_sli.c b/drivers/scsi/lpfc/lpfc_sli.c
index ac999abb4466..87f2616e7a65 100644
--- a/drivers/scsi/lpfc/lpfc_sli.c
+++ b/drivers/scsi/lpfc/lpfc_sli.c
@@ -5121,9 +5121,8 @@ lpfc_sli_hba_setup(struct lpfc_hba *phba)
 				goto lpfc_sli_hba_setup_error;
 			}
 
-			phba->vpi_ids = kzalloc(
-					(phba->max_vpi+1) * sizeof(uint16_t),
-					GFP_KERNEL);
+			phba->vpi_ids = kzalloc(array_size((phba->max_vpi + 1), sizeof(uint16_t)),
+						GFP_KERNEL);
 			if (!phba->vpi_ids) {
 				kfree(phba->vpi_bmask);
 				rc = -ENOMEM;
diff --git a/drivers/scsi/lpfc/lpfc_vport.c b/drivers/scsi/lpfc/lpfc_vport.c
index c9d33b1268cb..068c5d7a5ee2 100644
--- a/drivers/scsi/lpfc/lpfc_vport.c
+++ b/drivers/scsi/lpfc/lpfc_vport.c
@@ -840,7 +840,7 @@ lpfc_create_vport_work_array(struct lpfc_hba *phba)
 	struct lpfc_vport *port_iterator;
 	struct lpfc_vport **vports;
 	int index = 0;
-	vports = kzalloc((phba->max_vports + 1) * sizeof(struct lpfc_vport *),
+	vports = kzalloc(array_size((phba->max_vports + 1), sizeof(struct lpfc_vport *)),
 			 GFP_KERNEL);
 	if (vports == NULL)
 		return NULL;
diff --git a/drivers/scsi/mac53c94.c b/drivers/scsi/mac53c94.c
index 8c4d3003b68b..e3d8fab8bd08 100644
--- a/drivers/scsi/mac53c94.c
+++ b/drivers/scsi/mac53c94.c
@@ -464,8 +464,8 @@ static int mac53c94_probe(struct macio_dev *mdev, const struct of_device_id *mat
        	 * +1 to allow for aligning.
 	 * XXX FIXME: Use DMA consistent routines
 	 */
-       	dma_cmd_space = kmalloc((host->sg_tablesize + 2) *
-       				sizeof(struct dbdma_cmd), GFP_KERNEL);
+       	dma_cmd_space = kmalloc(array_size((host->sg_tablesize + 2), sizeof(struct dbdma_cmd)),
+				       GFP_KERNEL);
        	if (dma_cmd_space == 0) {
        		printk(KERN_ERR "mac53c94: couldn't allocate dma "
        		       "command space for %pOF\n", node);
diff --git a/drivers/scsi/megaraid/megaraid_mm.c b/drivers/scsi/megaraid/megaraid_mm.c
index bb802b0c12b8..747bf93ad8f0 100644
--- a/drivers/scsi/megaraid/megaraid_mm.c
+++ b/drivers/scsi/megaraid/megaraid_mm.c
@@ -935,10 +935,10 @@ mraid_mm_register_adp(mraid_mmadp_t *lld_adp)
 	 * Allocate single blocks of memory for all required kiocs,
 	 * mailboxes and passthru structures.
 	 */
-	adapter->kioc_list	= kmalloc(sizeof(uioc_t) * lld_adp->max_kioc,
-						GFP_KERNEL);
-	adapter->mbox_list	= kmalloc(sizeof(mbox64_t) * lld_adp->max_kioc,
-						GFP_KERNEL);
+	adapter->kioc_list	= kmalloc(array_size(sizeof(uioc_t), lld_adp->max_kioc),
+					    GFP_KERNEL);
+	adapter->mbox_list	= kmalloc(array_size(sizeof(mbox64_t), lld_adp->max_kioc),
+					    GFP_KERNEL);
 	adapter->pthru_dma_pool = dma_pool_create("megaraid mm pthru pool",
 						&adapter->pdev->dev,
 						sizeof(mraid_passthru_t),
diff --git a/drivers/scsi/pm8001/pm8001_ctl.c b/drivers/scsi/pm8001/pm8001_ctl.c
index 596f3ff965f5..4bdbcaf4929c 100644
--- a/drivers/scsi/pm8001/pm8001_ctl.c
+++ b/drivers/scsi/pm8001/pm8001_ctl.c
@@ -705,7 +705,7 @@ static ssize_t pm8001_store_update_fw(struct device *cdev,
 		return -EINPROGRESS;
 	pm8001_ha->fw_status = FLASH_IN_PROGRESS;
 
-	cmd_ptr = kzalloc(count*2, GFP_KERNEL);
+	cmd_ptr = kzalloc(array_size(count, 2), GFP_KERNEL);
 	if (!cmd_ptr) {
 		pm8001_ha->fw_status = FAIL_OUT_MEMORY;
 		return -ENOMEM;
diff --git a/drivers/scsi/qedi/qedi_main.c b/drivers/scsi/qedi/qedi_main.c
index 4da3592aec0f..05017a3be374 100644
--- a/drivers/scsi/qedi/qedi_main.c
+++ b/drivers/scsi/qedi/qedi_main.c
@@ -523,7 +523,8 @@ static int qedi_init_id_tbl(struct qedi_portid_tbl *id_tbl, u16 size,
 	id_tbl->max = size;
 	id_tbl->next = next;
 	spin_lock_init(&id_tbl->lock);
-	id_tbl->table = kzalloc(DIV_ROUND_UP(size, 32) * 4, GFP_KERNEL);
+	id_tbl->table = kzalloc(array_size(DIV_ROUND_UP(size, 32), 4),
+				GFP_KERNEL);
 	if (!id_tbl->table)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/qla2xxx/qla_init.c b/drivers/scsi/qla2xxx/qla_init.c
index 8f55dd44adae..95ad539cd3b6 100644
--- a/drivers/scsi/qla2xxx/qla_init.c
+++ b/drivers/scsi/qla2xxx/qla_init.c
@@ -3118,8 +3118,8 @@ qla2x00_alloc_outstanding_cmds(struct qla_hw_data *ha, struct req_que *req)
 			req->num_outstanding_cmds = ha->cur_fw_iocb_count;
 	}
 
-	req->outstanding_cmds = kzalloc(sizeof(srb_t *) *
-	    req->num_outstanding_cmds, GFP_KERNEL);
+	req->outstanding_cmds = kzalloc(array_size(sizeof(srb_t *), req->num_outstanding_cmds),
+					GFP_KERNEL);
 
 	if (!req->outstanding_cmds) {
 		/*
@@ -3127,8 +3127,8 @@ qla2x00_alloc_outstanding_cmds(struct qla_hw_data *ha, struct req_que *req)
 		 * initialization.
 		 */
 		req->num_outstanding_cmds = MIN_OUTSTANDING_COMMANDS;
-		req->outstanding_cmds = kzalloc(sizeof(srb_t *) *
-		    req->num_outstanding_cmds, GFP_KERNEL);
+		req->outstanding_cmds = kzalloc(array_size(sizeof(srb_t *), req->num_outstanding_cmds),
+						GFP_KERNEL);
 
 		if (!req->outstanding_cmds) {
 			ql_log(ql_log_fatal, NULL, 0x0126,
diff --git a/drivers/scsi/qla2xxx/qla_isr.c b/drivers/scsi/qla2xxx/qla_isr.c
index a3dc83f9444d..c59401b4503f 100644
--- a/drivers/scsi/qla2xxx/qla_isr.c
+++ b/drivers/scsi/qla2xxx/qla_isr.c
@@ -3434,8 +3434,8 @@ qla24xx_enable_msix(struct qla_hw_data *ha, struct rsp_que *rsp)
 			    "Adjusted Max no of queues pairs: %d.\n", ha->max_qpairs);
 		}
 	}
-	ha->msix_entries = kzalloc(sizeof(struct qla_msix_entry) *
-				ha->msix_count, GFP_KERNEL);
+	ha->msix_entries = kzalloc(array_size(sizeof(struct qla_msix_entry), ha->msix_count),
+				   GFP_KERNEL);
 	if (!ha->msix_entries) {
 		ql_log(ql_log_fatal, vha, 0x00c8,
 		    "Failed to allocate memory for ha->msix_entries.\n");
diff --git a/drivers/scsi/qla2xxx/qla_os.c b/drivers/scsi/qla2xxx/qla_os.c
index 15eaa6dded04..db39396bfaa0 100644
--- a/drivers/scsi/qla2xxx/qla_os.c
+++ b/drivers/scsi/qla2xxx/qla_os.c
@@ -410,7 +410,7 @@ static int qla2x00_alloc_queues(struct qla_hw_data *ha, struct req_que *req,
 				struct rsp_que *rsp)
 {
 	scsi_qla_host_t *vha = pci_get_drvdata(ha->pdev);
-	ha->req_q_map = kzalloc(sizeof(struct req_que *) * ha->max_req_queues,
+	ha->req_q_map = kzalloc(array_size(sizeof(struct req_que *), ha->max_req_queues),
 				GFP_KERNEL);
 	if (!ha->req_q_map) {
 		ql_log(ql_log_fatal, vha, 0x003b,
@@ -418,7 +418,7 @@ static int qla2x00_alloc_queues(struct qla_hw_data *ha, struct req_que *req,
 		goto fail_req_map;
 	}
 
-	ha->rsp_q_map = kzalloc(sizeof(struct rsp_que *) * ha->max_rsp_queues,
+	ha->rsp_q_map = kzalloc(array_size(sizeof(struct rsp_que *), ha->max_rsp_queues),
 				GFP_KERNEL);
 	if (!ha->rsp_q_map) {
 		ql_log(ql_log_fatal, vha, 0x003c,
@@ -4045,8 +4045,8 @@ qla2x00_mem_alloc(struct qla_hw_data *ha, uint16_t req_len, uint16_t rsp_len,
 	    (*rsp)->ring);
 	/* Allocate memory for NVRAM data for vports */
 	if (ha->nvram_npiv_size) {
-		ha->npiv_info = kzalloc(sizeof(struct qla_npiv_entry) *
-		    ha->nvram_npiv_size, GFP_KERNEL);
+		ha->npiv_info = kzalloc(array_size(sizeof(struct qla_npiv_entry), ha->nvram_npiv_size),
+					GFP_KERNEL);
 		if (!ha->npiv_info) {
 			ql_log_pci(ql_log_fatal, ha->pdev, 0x002d,
 			    "Failed to allocate memory for npiv_info.\n");
@@ -4080,8 +4080,8 @@ qla2x00_mem_alloc(struct qla_hw_data *ha, uint16_t req_len, uint16_t rsp_len,
 	INIT_LIST_HEAD(&ha->vp_list);
 
 	/* Allocate memory for our loop_id bitmap */
-	ha->loop_id_map = kzalloc(BITS_TO_LONGS(LOOPID_MAP_SIZE) * sizeof(long),
-	    GFP_KERNEL);
+	ha->loop_id_map = kzalloc(array_size(BITS_TO_LONGS(LOOPID_MAP_SIZE), sizeof(long)),
+				  GFP_KERNEL);
 	if (!ha->loop_id_map)
 		goto fail_loop_id_map;
 	else {
diff --git a/drivers/scsi/qla2xxx/qla_target.c b/drivers/scsi/qla2xxx/qla_target.c
index 09997a1b1ec3..58ec467834b2 100644
--- a/drivers/scsi/qla2xxx/qla_target.c
+++ b/drivers/scsi/qla2xxx/qla_target.c
@@ -6166,8 +6166,8 @@ int qlt_add_target(struct qla_hw_data *ha, struct scsi_qla_host *base_vha)
 		return -ENOMEM;
 	}
 
-	tgt->qphints = kzalloc((ha->max_qpairs + 1) *
-	    sizeof(struct qla_qpair_hint), GFP_KERNEL);
+	tgt->qphints = kzalloc(array_size((ha->max_qpairs + 1), sizeof(struct qla_qpair_hint)),
+			       GFP_KERNEL);
 	if (!tgt->qphints) {
 		kfree(tgt);
 		ql_log(ql_log_warn, base_vha, 0x0197,
diff --git a/drivers/scsi/smartpqi/smartpqi_init.c b/drivers/scsi/smartpqi/smartpqi_init.c
index 060bf5a27df8..cea66df27781 100644
--- a/drivers/scsi/smartpqi/smartpqi_init.c
+++ b/drivers/scsi/smartpqi/smartpqi_init.c
@@ -4251,8 +4251,8 @@ static int pqi_alloc_io_resources(struct pqi_ctrl_info *ctrl_info)
 	struct device *dev;
 	struct pqi_io_request *io_request;
 
-	ctrl_info->io_request_pool = kzalloc(ctrl_info->max_io_slots *
-		sizeof(ctrl_info->io_request_pool[0]), GFP_KERNEL);
+	ctrl_info->io_request_pool = kzalloc(array_size(ctrl_info->max_io_slots, sizeof(ctrl_info->io_request_pool[0])),
+					     GFP_KERNEL);
 
 	if (!ctrl_info->io_request_pool) {
 		dev_err(&ctrl_info->pci_dev->dev,
diff --git a/drivers/sh/intc/core.c b/drivers/sh/intc/core.c
index 8e72bcbd3d6d..60dccb04ebc0 100644
--- a/drivers/sh/intc/core.c
+++ b/drivers/sh/intc/core.c
@@ -203,7 +203,7 @@ int __init register_intc_controller(struct intc_desc *desc)
 
 	if (desc->num_resources) {
 		d->nr_windows = desc->num_resources;
-		d->window = kzalloc(d->nr_windows * sizeof(*d->window),
+		d->window = kzalloc(array_size(d->nr_windows, sizeof(*d->window)),
 				    GFP_NOWAIT);
 		if (!d->window)
 			goto err1;
@@ -230,12 +230,12 @@ int __init register_intc_controller(struct intc_desc *desc)
 	d->nr_reg += hw->ack_regs ? hw->nr_ack_regs : 0;
 	d->nr_reg += hw->subgroups ? hw->nr_subgroups : 0;
 
-	d->reg = kzalloc(d->nr_reg * sizeof(*d->reg), GFP_NOWAIT);
+	d->reg = kzalloc(array_size(d->nr_reg, sizeof(*d->reg)), GFP_NOWAIT);
 	if (!d->reg)
 		goto err2;
 
 #ifdef CONFIG_SMP
-	d->smp = kzalloc(d->nr_reg * sizeof(*d->smp), GFP_NOWAIT);
+	d->smp = kzalloc(array_size(d->nr_reg, sizeof(*d->smp)), GFP_NOWAIT);
 	if (!d->smp)
 		goto err3;
 #endif
@@ -253,7 +253,7 @@ int __init register_intc_controller(struct intc_desc *desc)
 	}
 
 	if (hw->prio_regs) {
-		d->prio = kzalloc(hw->nr_vectors * sizeof(*d->prio),
+		d->prio = kzalloc(array_size(hw->nr_vectors, sizeof(*d->prio)),
 				  GFP_NOWAIT);
 		if (!d->prio)
 			goto err4;
@@ -269,7 +269,7 @@ int __init register_intc_controller(struct intc_desc *desc)
 	}
 
 	if (hw->sense_regs) {
-		d->sense = kzalloc(hw->nr_vectors * sizeof(*d->sense),
+		d->sense = kzalloc(array_size(hw->nr_vectors, sizeof(*d->sense)),
 				   GFP_NOWAIT);
 		if (!d->sense)
 			goto err5;
diff --git a/drivers/sh/maple/maple.c b/drivers/sh/maple/maple.c
index 7525039d812c..476aff20a67e 100644
--- a/drivers/sh/maple/maple.c
+++ b/drivers/sh/maple/maple.c
@@ -161,7 +161,7 @@ int maple_add_packet(struct maple_device *mdev, u32 function, u32 command,
 	void *sendbuf = NULL;
 
 	if (length) {
-		sendbuf = kzalloc(length * 4, GFP_KERNEL);
+		sendbuf = kzalloc(array_size(length, 4), GFP_KERNEL);
 		if (!sendbuf) {
 			ret = -ENOMEM;
 			goto out;
diff --git a/drivers/soc/fsl/qbman/qman_test_stash.c b/drivers/soc/fsl/qbman/qman_test_stash.c
index e87b65403b67..e39356db13aa 100644
--- a/drivers/soc/fsl/qbman/qman_test_stash.c
+++ b/drivers/soc/fsl/qbman/qman_test_stash.c
@@ -221,7 +221,7 @@ static int allocate_frame_data(void)
 
 	pcfg = qman_get_qm_portal_config(qman_dma_portal);
 
-	__frame_ptr = kmalloc(4 * HP_NUM_WORDS, GFP_KERNEL);
+	__frame_ptr = kmalloc(array_size(4, HP_NUM_WORDS), GFP_KERNEL);
 	if (!__frame_ptr)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index b823f8a21856..406ecaf64930 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -243,9 +243,8 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 	 * when writing a page. -jay
 	 */
 	lio->lis_subs =
-		kvzalloc(lsm->lsm_stripe_count *
-				sizeof(lio->lis_subs[0]),
-				GFP_NOFS);
+		kvzalloc(array_size(lsm->lsm_stripe_count, sizeof(lio->lis_subs[0])),
+			 GFP_NOFS);
 	if (lio->lis_subs) {
 		lio->lis_nr_subios = lio->lis_stripe_count;
 		lio->lis_single_subio_index = -1;
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index f7c69680cb7d..6aab63bc1063 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -242,8 +242,8 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	r0->lo_nr  = lsm->lsm_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
-	r0->lo_sub = kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
-				     GFP_NOFS);
+	r0->lo_sub = kvzalloc(array_size(r0->lo_nr, sizeof(r0->lo_sub[0])),
+			      GFP_NOFS);
 	if (r0->lo_sub) {
 		int psz = 0;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 625b9520d78f..ce1c152f79bb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -375,9 +375,8 @@ static inline void enc_pools_alloc(void)
 {
 	LASSERT(page_pools.epp_max_pools);
 	page_pools.epp_pools =
-		kvzalloc(page_pools.epp_max_pools *
-				sizeof(*page_pools.epp_pools),
-				GFP_KERNEL);
+		kvzalloc(array_size(page_pools.epp_max_pools, sizeof(*page_pools.epp_pools)),
+			 GFP_KERNEL);
 }
 
 static inline void enc_pools_free(void)
diff --git a/drivers/staging/media/atomisp/pci/atomisp2/css2400/sh_css_firmware.c b/drivers/staging/media/atomisp/pci/atomisp2/css2400/sh_css_firmware.c
index 8158ea40d069..bf2d6aa5db36 100644
--- a/drivers/staging/media/atomisp/pci/atomisp2/css2400/sh_css_firmware.c
+++ b/drivers/staging/media/atomisp/pci/atomisp2/css2400/sh_css_firmware.c
@@ -226,9 +226,8 @@ sh_css_load_firmware(const char *fw_data,
 	sh_css_num_binaries = file_header->binary_nr;
 	/* Only allocate memory for ISP blob info */
 	if (sh_css_num_binaries > NUM_OF_SPS) {
-		sh_css_blob_info = kmalloc(
-					(sh_css_num_binaries - NUM_OF_SPS) *
-					sizeof(*sh_css_blob_info), GFP_KERNEL);
+		sh_css_blob_info = kmalloc(array_size((sh_css_num_binaries - NUM_OF_SPS), sizeof(*sh_css_blob_info)),
+					   GFP_KERNEL);
 		if (!sh_css_blob_info)
 			return IA_CSS_ERR_CANNOT_ALLOCATE_MEMORY;
 	} else {
diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index d607c59761cf..0d4b85246210 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -1679,7 +1679,7 @@ static short rtl8192_usb_initendpoints(struct net_device *dev)
 {
 	struct r8192_priv *priv = ieee80211_priv(dev);
 
-	priv->rx_urb = kmalloc(sizeof(struct urb *) * (MAX_RX_URB + 1),
+	priv->rx_urb = kmalloc(array_size(sizeof(struct urb *), (MAX_RX_URB + 1)),
 			       GFP_KERNEL);
 	if (!priv->rx_urb)
 		return -ENOMEM;
diff --git a/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c b/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c
index b26533983864..12474855c806 100644
--- a/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8723bs/os_dep/ioctl_linux.c
@@ -321,7 +321,7 @@ static char *translate_scan(struct adapter *padapter,
 		RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_wx_get_scan: ssid =%s\n", pnetwork->network.Ssid.Ssid));
 		RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_, ("rtw_wx_get_scan: wpa_len =%d rsn_len =%d\n", wpa_len, rsn_len));
 
-		buf = kzalloc(MAX_WPA_IE_LEN*2, GFP_KERNEL);
+		buf = kzalloc(array_size(MAX_WPA_IE_LEN, 2), GFP_KERNEL);
 		if (!buf)
 			return start;
 		if (wpa_len > 0) {
diff --git a/drivers/staging/rtlwifi/efuse.c b/drivers/staging/rtlwifi/efuse.c
index d74c80d512c9..99f1f22505d4 100644
--- a/drivers/staging/rtlwifi/efuse.c
+++ b/drivers/staging/rtlwifi/efuse.c
@@ -248,8 +248,8 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	}
 
 	/* allocate memory for efuse_tbl and efuse_word */
-	efuse_tbl = kzalloc(rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE] *
-			    sizeof(u8), GFP_ATOMIC);
+	efuse_tbl = kzalloc(array_size(rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE], sizeof(u8)),
+			    GFP_ATOMIC);
 	if (!efuse_tbl)
 		return;
 	efuse_word = kcalloc(EFUSE_MAX_WORD_UNIT, sizeof(u16 *), GFP_ATOMIC);
diff --git a/drivers/staging/rts5208/ms.c b/drivers/staging/rts5208/ms.c
index 821256b95e22..126fa860a919 100644
--- a/drivers/staging/rts5208/ms.c
+++ b/drivers/staging/rts5208/ms.c
@@ -1049,7 +1049,7 @@ static int ms_read_attribute_info(struct rtsx_chip *chip)
 		return STATUS_FAIL;
 	}
 
-	buf = kmalloc(64 * 512, GFP_KERNEL);
+	buf = kmalloc(array_size(64, 512), GFP_KERNEL);
 	if (!buf) {
 		rtsx_trace(chip);
 		return STATUS_ERROR;
diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 4ad89ea71a70..63a62ff5a868 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -1692,8 +1692,8 @@ static int tcmu_configure_device(struct se_device *dev)
 
 	info = &udev->uio_info;
 
-	udev->data_bitmap = kzalloc(BITS_TO_LONGS(udev->max_blocks) *
-				    sizeof(unsigned long), GFP_KERNEL);
+	udev->data_bitmap = kzalloc(array_size(BITS_TO_LONGS(udev->max_blocks), sizeof(unsigned long)),
+				    GFP_KERNEL);
 	if (!udev->data_bitmap) {
 		ret = -ENOMEM;
 		goto err_bitmap_alloc;
diff --git a/drivers/thermal/int340x_thermal/acpi_thermal_rel.c b/drivers/thermal/int340x_thermal/acpi_thermal_rel.c
index c719167e9f28..832bd6d61db6 100644
--- a/drivers/thermal/int340x_thermal/acpi_thermal_rel.c
+++ b/drivers/thermal/int340x_thermal/acpi_thermal_rel.c
@@ -96,7 +96,7 @@ int acpi_parse_trt(acpi_handle handle, int *trt_count, struct trt **trtp,
 	}
 
 	*trt_count = p->package.count;
-	trts = kzalloc(*trt_count * sizeof(struct trt), GFP_KERNEL);
+	trts = kzalloc(array_size(*trt_count, sizeof(struct trt)), GFP_KERNEL);
 	if (!trts) {
 		result = -ENOMEM;
 		goto end;
@@ -178,7 +178,7 @@ int acpi_parse_art(acpi_handle handle, int *art_count, struct art **artp,
 
 	/* ignore p->package.elements[0], as this is _ART Revision field */
 	*art_count = p->package.count - 1;
-	arts = kzalloc(*art_count * sizeof(struct art), GFP_KERNEL);
+	arts = kzalloc(array_size(*art_count, sizeof(struct art)), GFP_KERNEL);
 	if (!arts) {
 		result = -ENOMEM;
 		goto end;
diff --git a/drivers/thermal/of-thermal.c b/drivers/thermal/of-thermal.c
index e09f0354a4bc..d758d7f7aa07 100644
--- a/drivers/thermal/of-thermal.c
+++ b/drivers/thermal/of-thermal.c
@@ -870,7 +870,8 @@ __init *thermal_of_build_thermal_zone(struct device_node *np)
 	if (tz->ntrips == 0) /* must have at least one child */
 		goto finish;
 
-	tz->trips = kzalloc(tz->ntrips * sizeof(*tz->trips), GFP_KERNEL);
+	tz->trips = kzalloc(array_size(tz->ntrips, sizeof(*tz->trips)),
+			    GFP_KERNEL);
 	if (!tz->trips) {
 		ret = -ENOMEM;
 		goto free_tz;
@@ -896,7 +897,8 @@ __init *thermal_of_build_thermal_zone(struct device_node *np)
 	if (tz->num_tbps == 0)
 		goto finish;
 
-	tz->tbps = kzalloc(tz->num_tbps * sizeof(*tz->tbps), GFP_KERNEL);
+	tz->tbps = kzalloc(array_size(tz->num_tbps, sizeof(*tz->tbps)),
+			   GFP_KERNEL);
 	if (!tz->tbps) {
 		ret = -ENOMEM;
 		goto free_trips;
diff --git a/drivers/tty/hvc/hvc_iucv.c b/drivers/tty/hvc/hvc_iucv.c
index a74680729825..825331079061 100644
--- a/drivers/tty/hvc/hvc_iucv.c
+++ b/drivers/tty/hvc/hvc_iucv.c
@@ -1252,7 +1252,7 @@ static int hvc_iucv_setup_filter(const char *val)
 	if (size > MAX_VMID_FILTER)
 		return -ENOSPC;
 
-	array = kzalloc(size * 8, GFP_KERNEL);
+	array = kzalloc(array_size(size, 8), GFP_KERNEL);
 	if (!array)
 		return -ENOMEM;
 
diff --git a/drivers/tty/isicom.c b/drivers/tty/isicom.c
index bdd3027ef01b..10c39cf042c9 100644
--- a/drivers/tty/isicom.c
+++ b/drivers/tty/isicom.c
@@ -1477,7 +1477,7 @@ static int load_firmware(struct pci_dev *pdev,
 			goto errrelfw;
 		}
 
-		data = kmalloc(word_count * 2, GFP_KERNEL);
+		data = kmalloc(array_size(word_count, 2), GFP_KERNEL);
 		if (data == NULL) {
 			dev_err(&pdev->dev, "Card%d, firmware upload "
 				"failed, not enough memory\n", index + 1);
diff --git a/drivers/tty/serial/serial_core.c b/drivers/tty/serial/serial_core.c
index 0466f9f08a91..be8f348da37f 100644
--- a/drivers/tty/serial/serial_core.c
+++ b/drivers/tty/serial/serial_core.c
@@ -2458,7 +2458,8 @@ int uart_register_driver(struct uart_driver *drv)
 	 * Maybe we should be using a slab cache for this, especially if
 	 * we have a large number of ports to handle.
 	 */
-	drv->state = kzalloc(sizeof(struct uart_state) * drv->nr, GFP_KERNEL);
+	drv->state = kzalloc(array_size(sizeof(struct uart_state), drv->nr),
+			     GFP_KERNEL);
 	if (!drv->state)
 		goto out;
 
diff --git a/drivers/tty/vt/selection.c b/drivers/tty/vt/selection.c
index 7851383fbd6c..b521a6732f72 100644
--- a/drivers/tty/vt/selection.c
+++ b/drivers/tty/vt/selection.c
@@ -280,7 +280,8 @@ int set_selection(const struct tiocl_selection __user *sel, struct tty_struct *t
 
 	/* Allocate a new buffer before freeing the old one ... */
 	multiplier = use_unicode ? 3 : 1;  /* chars can take up to 3 bytes */
-	bp = kmalloc(((sel_end-sel_start)/2+1)*multiplier, GFP_KERNEL);
+	bp = kmalloc(array_size(((sel_end - sel_start) / 2 + 1), multiplier),
+		     GFP_KERNEL);
 	if (!bp) {
 		printk(KERN_WARNING "selection: kmalloc() failed\n");
 		clear_selection();
diff --git a/drivers/usb/core/message.c b/drivers/usb/core/message.c
index f6fdc9f54ec7..2adf21e65a58 100644
--- a/drivers/usb/core/message.c
+++ b/drivers/usb/core/message.c
@@ -390,7 +390,8 @@ int usb_sg_init(struct usb_sg_request *io, struct usb_device *dev,
 	}
 
 	/* initialize all the urbs we'll use */
-	io->urbs = kmalloc(io->entries * sizeof(*io->urbs), mem_flags);
+	io->urbs = kmalloc(array_size(io->entries, sizeof(*io->urbs)),
+			   mem_flags);
 	if (!io->urbs)
 		goto nomem;
 
diff --git a/drivers/usb/gadget/udc/fsl_udc_core.c b/drivers/usb/gadget/udc/fsl_udc_core.c
index 56b517a38865..c00d610ed648 100644
--- a/drivers/usb/gadget/udc/fsl_udc_core.c
+++ b/drivers/usb/gadget/udc/fsl_udc_core.c
@@ -2259,7 +2259,8 @@ static int struct_udc_setup(struct fsl_udc *udc,
 	pdata = dev_get_platdata(&pdev->dev);
 	udc->phy_mode = pdata->phy_mode;
 
-	udc->eps = kzalloc(sizeof(struct fsl_ep) * udc->max_ep, GFP_KERNEL);
+	udc->eps = kzalloc(array_size(sizeof(struct fsl_ep), udc->max_ep),
+			   GFP_KERNEL);
 	if (!udc->eps)
 		return -1;
 
diff --git a/drivers/usb/host/ehci-sched.c b/drivers/usb/host/ehci-sched.c
index e56db44708bc..962285c95151 100644
--- a/drivers/usb/host/ehci-sched.c
+++ b/drivers/usb/host/ehci-sched.c
@@ -117,8 +117,8 @@ static struct ehci_tt *find_tt(struct usb_device *udev)
 	if (utt->multi) {
 		tt_index = utt->hcpriv;
 		if (!tt_index) {		/* Create the index array */
-			tt_index = kzalloc(utt->hub->maxchild *
-					sizeof(*tt_index), GFP_ATOMIC);
+			tt_index = kzalloc(array_size(utt->hub->maxchild, sizeof(*tt_index)),
+					   GFP_ATOMIC);
 			if (!tt_index)
 				return ERR_PTR(-ENOMEM);
 			utt->hcpriv = tt_index;
diff --git a/drivers/usb/host/imx21-hcd.c b/drivers/usb/host/imx21-hcd.c
index 3a8bbfe43a8e..26c816133de7 100644
--- a/drivers/usb/host/imx21-hcd.c
+++ b/drivers/usb/host/imx21-hcd.c
@@ -741,8 +741,8 @@ static int imx21_hc_urb_enqueue_isoc(struct usb_hcd *hcd,
 	if (urb_priv == NULL)
 		return -ENOMEM;
 
-	urb_priv->isoc_td = kzalloc(
-		sizeof(struct td) * urb->number_of_packets, mem_flags);
+	urb_priv->isoc_td = kzalloc(array_size(sizeof(struct td), urb->number_of_packets),
+				    mem_flags);
 	if (urb_priv->isoc_td == NULL) {
 		ret = -ENOMEM;
 		goto alloc_td_failed;
diff --git a/drivers/usb/host/isp1362-hcd.c b/drivers/usb/host/isp1362-hcd.c
index b21c386e6a46..c054b52148e5 100644
--- a/drivers/usb/host/isp1362-hcd.c
+++ b/drivers/usb/host/isp1362-hcd.c
@@ -2400,7 +2400,7 @@ static int isp1362_chip_test(struct isp1362_hcd *isp1362_hcd)
 	u16 *ref;
 	unsigned long flags;
 
-	ref = kmalloc(2 * ISP1362_BUF_SIZE, GFP_KERNEL);
+	ref = kmalloc(array_size(2, ISP1362_BUF_SIZE), GFP_KERNEL);
 	if (ref) {
 		int offset;
 		u16 *tst = &ref[ISP1362_BUF_SIZE / 2];
diff --git a/drivers/usb/host/xhci-mem.c b/drivers/usb/host/xhci-mem.c
index 0b0d4893715e..8b32d7261b57 100644
--- a/drivers/usb/host/xhci-mem.c
+++ b/drivers/usb/host/xhci-mem.c
@@ -2310,8 +2310,8 @@ static int xhci_setup_port_arrays(struct xhci_hcd *xhci, gfp_t flags)
 	 * Not sure how the USB core will handle a hub with no ports...
 	 */
 	if (xhci->num_usb2_ports) {
-		xhci->usb2_ports = kmalloc(sizeof(*xhci->usb2_ports)*
-				xhci->num_usb2_ports, flags);
+		xhci->usb2_ports = kmalloc(array_size(sizeof(*xhci->usb2_ports), xhci->num_usb2_ports),
+					   flags);
 		if (!xhci->usb2_ports)
 			return -ENOMEM;
 
@@ -2335,8 +2335,8 @@ static int xhci_setup_port_arrays(struct xhci_hcd *xhci, gfp_t flags)
 		}
 	}
 	if (xhci->num_usb3_ports) {
-		xhci->usb3_ports = kmalloc(sizeof(*xhci->usb3_ports)*
-				xhci->num_usb3_ports, flags);
+		xhci->usb3_ports = kmalloc(array_size(sizeof(*xhci->usb3_ports), xhci->num_usb3_ports),
+					   flags);
 		if (!xhci->usb3_ports)
 			return -ENOMEM;
 
diff --git a/drivers/usb/misc/ldusb.c b/drivers/usb/misc/ldusb.c
index 236a60f53099..55f13e665a86 100644
--- a/drivers/usb/misc/ldusb.c
+++ b/drivers/usb/misc/ldusb.c
@@ -695,7 +695,8 @@ static int ld_usb_probe(struct usb_interface *intf, const struct usb_device_id *
 		dev_warn(&intf->dev, "Interrupt out endpoint not found (using control endpoint instead)\n");
 
 	dev->interrupt_in_endpoint_size = usb_endpoint_maxp(dev->interrupt_in_endpoint);
-	dev->ring_buffer = kmalloc(ring_buffer_size*(sizeof(size_t)+dev->interrupt_in_endpoint_size), GFP_KERNEL);
+	dev->ring_buffer = kmalloc(array_size(ring_buffer_size, (sizeof(size_t) + dev->interrupt_in_endpoint_size)),
+				   GFP_KERNEL);
 	if (!dev->ring_buffer)
 		goto error;
 	dev->interrupt_in_buffer = kmalloc(dev->interrupt_in_endpoint_size, GFP_KERNEL);
@@ -706,7 +707,8 @@ static int ld_usb_probe(struct usb_interface *intf, const struct usb_device_id *
 		goto error;
 	dev->interrupt_out_endpoint_size = dev->interrupt_out_endpoint ? usb_endpoint_maxp(dev->interrupt_out_endpoint) :
 									 udev->descriptor.bMaxPacketSize0;
-	dev->interrupt_out_buffer = kmalloc(write_buffer_size*dev->interrupt_out_endpoint_size, GFP_KERNEL);
+	dev->interrupt_out_buffer = kmalloc(array_size(write_buffer_size, dev->interrupt_out_endpoint_size),
+					    GFP_KERNEL);
 	if (!dev->interrupt_out_buffer)
 		goto error;
 	dev->interrupt_out_urb = usb_alloc_urb(0, GFP_KERNEL);
diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
index 2761fad66b95..d3bb24dc2be2 100644
--- a/drivers/usb/mon/mon_bin.c
+++ b/drivers/usb/mon/mon_bin.c
@@ -1024,7 +1024,8 @@ static long mon_bin_ioctl(struct file *file, unsigned int cmd, unsigned long arg
 			return -EINVAL;
 
 		size = CHUNK_ALIGN(arg);
-		vec = kzalloc(sizeof(struct mon_pgmap) * (size / CHUNK_SIZE), GFP_KERNEL);
+		vec = kzalloc(array_size(sizeof(struct mon_pgmap), (size / CHUNK_SIZE)),
+			      GFP_KERNEL);
 		if (vec == NULL) {
 			ret = -ENOMEM;
 			break;
diff --git a/drivers/usb/storage/alauda.c b/drivers/usb/storage/alauda.c
index 900591df8bb2..cd1fe1e87125 100644
--- a/drivers/usb/storage/alauda.c
+++ b/drivers/usb/storage/alauda.c
@@ -1025,7 +1025,8 @@ static int alauda_write_data(struct us_data *us, unsigned long address,
 	 * We also need a temporary block buffer, where we read in the old data,
 	 * overwrite parts with the new data, and manipulate the redundancy data
 	 */
-	blockbuffer = kmalloc((pagesize + 64) * blocksize, GFP_NOIO);
+	blockbuffer = kmalloc(array_size((pagesize + 64), blocksize),
+			      GFP_NOIO);
 	if (!blockbuffer) {
 		kfree(buffer);
 		return USB_STOR_TRANSPORT_ERROR;
diff --git a/drivers/usb/storage/ene_ub6250.c b/drivers/usb/storage/ene_ub6250.c
index 93cf57ac47d6..1b96afbc1b0d 100644
--- a/drivers/usb/storage/ene_ub6250.c
+++ b/drivers/usb/storage/ene_ub6250.c
@@ -807,8 +807,10 @@ static int ms_lib_alloc_logicalmap(struct us_data *us)
 	u32  i;
 	struct ene_ub6250_info *info = (struct ene_ub6250_info *) us->extra;
 
-	info->MS_Lib.Phy2LogMap = kmalloc(info->MS_Lib.NumberOfPhyBlock * sizeof(u16), GFP_KERNEL);
-	info->MS_Lib.Log2PhyMap = kmalloc(info->MS_Lib.NumberOfLogBlock * sizeof(u16), GFP_KERNEL);
+	info->MS_Lib.Phy2LogMap = kmalloc(array_size(info->MS_Lib.NumberOfPhyBlock, sizeof(u16)),
+					  GFP_KERNEL);
+	info->MS_Lib.Log2PhyMap = kmalloc(array_size(info->MS_Lib.NumberOfLogBlock, sizeof(u16)),
+					  GFP_KERNEL);
 
 	if ((info->MS_Lib.Phy2LogMap == NULL) || (info->MS_Lib.Log2PhyMap == NULL)) {
 		ms_lib_free_logicalmap(us);
@@ -1113,8 +1115,10 @@ static int ms_lib_alloc_writebuf(struct us_data *us)
 
 	info->MS_Lib.wrtblk = (u16)-1;
 
-	info->MS_Lib.blkpag = kmalloc(info->MS_Lib.PagesPerBlock * info->MS_Lib.BytesPerSector, GFP_KERNEL);
-	info->MS_Lib.blkext = kmalloc(info->MS_Lib.PagesPerBlock * sizeof(struct ms_lib_type_extdat), GFP_KERNEL);
+	info->MS_Lib.blkpag = kmalloc(array_size(info->MS_Lib.PagesPerBlock, info->MS_Lib.BytesPerSector),
+				      GFP_KERNEL);
+	info->MS_Lib.blkext = kmalloc(array_size(info->MS_Lib.PagesPerBlock, sizeof(struct ms_lib_type_extdat)),
+				      GFP_KERNEL);
 
 	if ((info->MS_Lib.blkpag == NULL) || (info->MS_Lib.blkext == NULL)) {
 		ms_lib_free_writebuf(us);
diff --git a/drivers/usb/storage/isd200.c b/drivers/usb/storage/isd200.c
index f5e4500d9970..6938f096f3c8 100644
--- a/drivers/usb/storage/isd200.c
+++ b/drivers/usb/storage/isd200.c
@@ -1458,7 +1458,7 @@ static int isd200_init_info(struct us_data *us)
 	if (!info)
 		return ISD200_ERROR;
 
-	info->id = kzalloc(ATA_ID_WORDS * 2, GFP_KERNEL);
+	info->id = kzalloc(array_size(ATA_ID_WORDS, 2), GFP_KERNEL);
 	info->RegsBuf = kmalloc(sizeof(info->ATARegs), GFP_KERNEL);
 	info->srb.sense_buffer = kmalloc(SCSI_SENSE_BUFFERSIZE, GFP_KERNEL);
 
diff --git a/drivers/usb/storage/sddr55.c b/drivers/usb/storage/sddr55.c
index 306fa78a026d..4295621ed796 100644
--- a/drivers/usb/storage/sddr55.c
+++ b/drivers/usb/storage/sddr55.c
@@ -651,7 +651,7 @@ static int sddr55_read_map(struct us_data *us) {
 
 	numblocks = info->capacity >> (info->blockshift + info->pageshift);
 	
-	buffer = kmalloc( numblocks * 2, GFP_NOIO );
+	buffer = kmalloc(array_size(numblocks, 2), GFP_NOIO);
 	
 	if (!buffer)
 		return -1;
diff --git a/drivers/usb/wusbcore/wa-rpipe.c b/drivers/usb/wusbcore/wa-rpipe.c
index d0f1a6698460..0e9e30436f37 100644
--- a/drivers/usb/wusbcore/wa-rpipe.c
+++ b/drivers/usb/wusbcore/wa-rpipe.c
@@ -470,7 +470,7 @@ int rpipe_get_by_ep(struct wahc *wa, struct usb_host_endpoint *ep,
 int wa_rpipes_create(struct wahc *wa)
 {
 	wa->rpipes = le16_to_cpu(wa->wa_descr->wNumRPipes);
-	wa->rpipe_bm = kzalloc(BITS_TO_LONGS(wa->rpipes)*sizeof(unsigned long),
+	wa->rpipe_bm = kzalloc(array_size(BITS_TO_LONGS(wa->rpipes), sizeof(unsigned long)),
 			       GFP_KERNEL);
 	if (wa->rpipe_bm == NULL)
 		return -ENOMEM;
diff --git a/drivers/uwb/est.c b/drivers/uwb/est.c
index f3e232584284..7c9ba8195c2c 100644
--- a/drivers/uwb/est.c
+++ b/drivers/uwb/est.c
@@ -217,7 +217,7 @@ static
 int uwb_est_grow(void)
 {
 	size_t actual_size = uwb_est_size * sizeof(uwb_est[0]);
-	void *new = kmalloc(2 * actual_size, GFP_ATOMIC);
+	void *new = kmalloc(array_size(2, actual_size), GFP_ATOMIC);
 	if (new == NULL)
 		return -ENOMEM;
 	memcpy(new, uwb_est, actual_size);
diff --git a/drivers/uwb/i1480/dfu/usb.c b/drivers/uwb/i1480/dfu/usb.c
index a50cf45e530f..4a511052dd13 100644
--- a/drivers/uwb/i1480/dfu/usb.c
+++ b/drivers/uwb/i1480/dfu/usb.c
@@ -376,7 +376,7 @@ int i1480_usb_probe(struct usb_interface *iface, const struct usb_device_id *id)
 
 	i1480 = &i1480_usb->i1480;
 	i1480->buf_size = 512;
-	i1480->cmd_buf = kmalloc(2 * i1480->buf_size, GFP_KERNEL);
+	i1480->cmd_buf = kmalloc(array_size(2, i1480->buf_size), GFP_KERNEL);
 	if (i1480->cmd_buf == NULL) {
 		dev_err(dev, "Cannot allocate transfer buffers\n");
 		result = -ENOMEM;
diff --git a/drivers/video/console/sticore.c b/drivers/video/console/sticore.c
index 08b822656846..34f508444a27 100644
--- a/drivers/video/console/sticore.c
+++ b/drivers/video/console/sticore.c
@@ -649,7 +649,7 @@ static void *sti_bmode_font_raw(struct sti_cooked_font *f)
 	unsigned char *n, *p, *q;
 	int size = f->raw->bytes_per_char*256+sizeof(struct sti_rom_font);
 	
-	n = kzalloc(4*size, STI_LOWMEM);
+	n = kzalloc(array_size(4, size), STI_LOWMEM);
 	if (!n)
 		return NULL;
 	p = n + 3;
diff --git a/drivers/video/fbdev/core/bitblit.c b/drivers/video/fbdev/core/bitblit.c
index 790900d646c0..85dd4278a0b7 100644
--- a/drivers/video/fbdev/core/bitblit.c
+++ b/drivers/video/fbdev/core/bitblit.c
@@ -269,7 +269,7 @@ static void bit_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	if (attribute) {
 		u8 *dst;
 
-		dst = kmalloc(w * vc->vc_font.height, GFP_ATOMIC);
+		dst = kmalloc(array_size(w, vc->vc_font.height), GFP_ATOMIC);
 		if (!dst)
 			return;
 		kfree(ops->cursor_data);
@@ -312,7 +312,8 @@ static void bit_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	    vc->vc_cursor_type != ops->p->cursor_shape ||
 	    ops->cursor_state.mask == NULL ||
 	    ops->cursor_reset) {
-		char *mask = kmalloc(w*vc->vc_font.height, GFP_ATOMIC);
+		char *mask = kmalloc(array_size(w, vc->vc_font.height),
+				     GFP_ATOMIC);
 		int cur_height, size, i = 0;
 		u8 msk = 0xff;
 
diff --git a/drivers/video/fbdev/core/fbcon.c b/drivers/video/fbdev/core/fbcon.c
index 3e330e0f56ed..c910e74d46ff 100644
--- a/drivers/video/fbdev/core/fbcon.c
+++ b/drivers/video/fbdev/core/fbcon.c
@@ -591,7 +591,8 @@ static void fbcon_prepare_logo(struct vc_data *vc, struct fb_info *info,
 		if (scr_readw(r) != vc->vc_video_erase_char)
 			break;
 	if (r != q && new_rows >= rows + logo_lines) {
-		save = kmalloc(logo_lines * new_cols * 2, GFP_KERNEL);
+		save = kmalloc(array3_size(logo_lines, new_cols, 2),
+			       GFP_KERNEL);
 		if (save) {
 			int i = cols < new_cols ? cols : new_cols;
 			scr_memsetw(save, erase, logo_lines * new_cols * 2);
diff --git a/drivers/video/fbdev/core/fbcon_ccw.c b/drivers/video/fbdev/core/fbcon_ccw.c
index 37a8b0b22566..8267510f3125 100644
--- a/drivers/video/fbdev/core/fbcon_ccw.c
+++ b/drivers/video/fbdev/core/fbcon_ccw.c
@@ -258,7 +258,7 @@ static void ccw_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	if (attribute) {
 		u8 *dst;
 
-		dst = kmalloc(w * vc->vc_font.width, GFP_ATOMIC);
+		dst = kmalloc(array_size(w, vc->vc_font.width), GFP_ATOMIC);
 		if (!dst)
 			return;
 		kfree(ops->cursor_data);
@@ -304,14 +304,16 @@ static void ccw_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	    vc->vc_cursor_type != ops->p->cursor_shape ||
 	    ops->cursor_state.mask == NULL ||
 	    ops->cursor_reset) {
-		char *tmp, *mask = kmalloc(w*vc->vc_font.width, GFP_ATOMIC);
+		char *tmp, *mask = kmalloc(array_size(w, vc->vc_font.width),
+					   GFP_ATOMIC);
 		int cur_height, size, i = 0;
 		int width = (vc->vc_font.width + 7)/8;
 
 		if (!mask)
 			return;
 
-		tmp = kmalloc(width * vc->vc_font.height, GFP_ATOMIC);
+		tmp = kmalloc(array_size(width, vc->vc_font.height),
+			      GFP_ATOMIC);
 
 		if (!tmp) {
 			kfree(mask);
diff --git a/drivers/video/fbdev/core/fbcon_cw.c b/drivers/video/fbdev/core/fbcon_cw.c
index 1888f8c866e8..1a770f970c3f 100644
--- a/drivers/video/fbdev/core/fbcon_cw.c
+++ b/drivers/video/fbdev/core/fbcon_cw.c
@@ -241,7 +241,7 @@ static void cw_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	if (attribute) {
 		u8 *dst;
 
-		dst = kmalloc(w * vc->vc_font.width, GFP_ATOMIC);
+		dst = kmalloc(array_size(w, vc->vc_font.width), GFP_ATOMIC);
 		if (!dst)
 			return;
 		kfree(ops->cursor_data);
@@ -287,14 +287,16 @@ static void cw_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	    vc->vc_cursor_type != ops->p->cursor_shape ||
 	    ops->cursor_state.mask == NULL ||
 	    ops->cursor_reset) {
-		char *tmp, *mask = kmalloc(w*vc->vc_font.width, GFP_ATOMIC);
+		char *tmp, *mask = kmalloc(array_size(w, vc->vc_font.width),
+					   GFP_ATOMIC);
 		int cur_height, size, i = 0;
 		int width = (vc->vc_font.width + 7)/8;
 
 		if (!mask)
 			return;
 
-		tmp = kmalloc(width * vc->vc_font.height, GFP_ATOMIC);
+		tmp = kmalloc(array_size(width, vc->vc_font.height),
+			      GFP_ATOMIC);
 
 		if (!tmp) {
 			kfree(mask);
diff --git a/drivers/video/fbdev/core/fbcon_ud.c b/drivers/video/fbdev/core/fbcon_ud.c
index f98eee263597..0d9fded15f3a 100644
--- a/drivers/video/fbdev/core/fbcon_ud.c
+++ b/drivers/video/fbdev/core/fbcon_ud.c
@@ -289,7 +289,7 @@ static void ud_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	if (attribute) {
 		u8 *dst;
 
-		dst = kmalloc(w * vc->vc_font.height, GFP_ATOMIC);
+		dst = kmalloc(array_size(w, vc->vc_font.height), GFP_ATOMIC);
 		if (!dst)
 			return;
 		kfree(ops->cursor_data);
@@ -335,7 +335,8 @@ static void ud_cursor(struct vc_data *vc, struct fb_info *info, int mode,
 	    vc->vc_cursor_type != ops->p->cursor_shape ||
 	    ops->cursor_state.mask == NULL ||
 	    ops->cursor_reset) {
-		char *mask = kmalloc(w*vc->vc_font.height, GFP_ATOMIC);
+		char *mask = kmalloc(array_size(w, vc->vc_font.height),
+				     GFP_ATOMIC);
 		int cur_height, size, i = 0;
 		u8 msk = 0xff;
 
diff --git a/drivers/video/fbdev/core/fbmem.c b/drivers/video/fbdev/core/fbmem.c
index f741ba8df01b..e5620d065866 100644
--- a/drivers/video/fbdev/core/fbmem.c
+++ b/drivers/video/fbdev/core/fbmem.c
@@ -475,7 +475,7 @@ static int fb_show_logo_line(struct fb_info *info, int rotate,
 
 	if (fb_logo.needs_truepalette ||
 	    fb_logo.needs_directpalette) {
-		palette = kmalloc(256 * 4, GFP_KERNEL);
+		palette = kmalloc(array_size(256, 4), GFP_KERNEL);
 		if (palette == NULL)
 			return 0;
 
@@ -489,7 +489,8 @@ static int fb_show_logo_line(struct fb_info *info, int rotate,
 	}
 
 	if (fb_logo.depth <= 4) {
-		logo_new = kmalloc(logo->width * logo->height, GFP_KERNEL);
+		logo_new = kmalloc(array_size(logo->width, logo->height),
+				   GFP_KERNEL);
 		if (logo_new == NULL) {
 			kfree(palette);
 			if (saved_pseudo_palette)
@@ -506,8 +507,8 @@ static int fb_show_logo_line(struct fb_info *info, int rotate,
 	image.height = logo->height;
 
 	if (rotate) {
-		logo_rotate = kmalloc(logo->width *
-				      logo->height, GFP_KERNEL);
+		logo_rotate = kmalloc(array_size(logo->width, logo->height),
+				      GFP_KERNEL);
 		if (logo_rotate)
 			fb_rotate_logo(info, logo_rotate, &image, rotate);
 	}
diff --git a/drivers/video/fbdev/core/fbmon.c b/drivers/video/fbdev/core/fbmon.c
index 24642cd9d25b..1b5c49e0923c 100644
--- a/drivers/video/fbdev/core/fbmon.c
+++ b/drivers/video/fbdev/core/fbmon.c
@@ -1056,8 +1056,8 @@ void fb_edid_add_monspecs(unsigned char *edid, struct fb_monspecs *specs)
 	if (!(num + svd_n))
 		return;
 
-	m = kzalloc((specs->modedb_len + num + svd_n) *
-		       sizeof(struct fb_videomode), GFP_KERNEL);
+	m = kzalloc(array_size((specs->modedb_len + num + svd_n), sizeof(struct fb_videomode)),
+		    GFP_KERNEL);
 
 	if (!m)
 		return;
diff --git a/drivers/video/fbdev/i810/i810_main.c b/drivers/video/fbdev/i810/i810_main.c
index d18f7b31932c..aac30cfaaf5e 100644
--- a/drivers/video/fbdev/i810/i810_main.c
+++ b/drivers/video/fbdev/i810/i810_main.c
@@ -1513,7 +1513,7 @@ static int i810fb_cursor(struct fb_info *info, struct fb_cursor *cursor)
 		int size = ((cursor->image.width + 7) >> 3) *
 			cursor->image.height;
 		int i;
-		u8 *data = kmalloc(64 * 8, GFP_ATOMIC);
+		u8 *data = kmalloc(array_size(64, 8), GFP_ATOMIC);
 
 		if (data == NULL)
 			return -ENOMEM;
@@ -2023,7 +2023,7 @@ static int i810fb_init_pci(struct pci_dev *dev,
 	par = info->par;
 	par->dev = dev;
 
-	if (!(info->pixmap.addr = kzalloc(8*1024, GFP_KERNEL))) {
+	if (!(info->pixmap.addr = kzalloc(array_size(8, 1024), GFP_KERNEL))) {
 		i810fb_release_resource(info, par);
 		return -ENOMEM;
 	}
diff --git a/drivers/video/fbdev/intelfb/intelfbdrv.c b/drivers/video/fbdev/intelfb/intelfbdrv.c
index d7463a2a5d83..b1f4b68967d6 100644
--- a/drivers/video/fbdev/intelfb/intelfbdrv.c
+++ b/drivers/video/fbdev/intelfb/intelfbdrv.c
@@ -506,7 +506,7 @@ static int intelfb_pci_register(struct pci_dev *pdev,
 	dinfo->pdev  = pdev;
 
 	/* Reserve pixmap space. */
-	info->pixmap.addr = kzalloc(64 * 1024, GFP_KERNEL);
+	info->pixmap.addr = kzalloc(array_size(64, 1024), GFP_KERNEL);
 	if (info->pixmap.addr == NULL) {
 		ERR_MSG("Cannot reserve pixmap memory.\n");
 		goto err_out_pixmap;
diff --git a/drivers/video/fbdev/matrox/g450_pll.c b/drivers/video/fbdev/matrox/g450_pll.c
index c15f8a57498e..6adf58736da6 100644
--- a/drivers/video/fbdev/matrox/g450_pll.c
+++ b/drivers/video/fbdev/matrox/g450_pll.c
@@ -518,7 +518,8 @@ int matroxfb_g450_setclk(struct matrox_fb_info *minfo, unsigned int fout,
 {
 	unsigned int* arr;
 	
-	arr = kmalloc(sizeof(*arr) * MNP_TABLE_SIZE * 2, GFP_KERNEL);
+	arr = kmalloc(array3_size(sizeof(*arr), MNP_TABLE_SIZE, 2),
+		      GFP_KERNEL);
 	if (arr) {
 		int r;
 
diff --git a/drivers/video/fbdev/mb862xx/mb862xxfb_accel.c b/drivers/video/fbdev/mb862xx/mb862xxfb_accel.c
index fe92eed6da70..f7012a88af34 100644
--- a/drivers/video/fbdev/mb862xx/mb862xxfb_accel.c
+++ b/drivers/video/fbdev/mb862xx/mb862xxfb_accel.c
@@ -245,7 +245,7 @@ static void mb86290fb_imageblit(struct fb_info *info,
 		return;
 	}
 
-	cmd = kmalloc(cmdlen * 4, GFP_DMA);
+	cmd = kmalloc(array_size(cmdlen, 4), GFP_DMA);
 	if (!cmd)
 		return cfb_imageblit(info, image);
 	cmdfn(cmd, step, dx, dy, width, height, fgcolor, bgcolor, image, info);
diff --git a/drivers/video/fbdev/nvidia/nvidia.c b/drivers/video/fbdev/nvidia/nvidia.c
index 418a2d0d06a9..d35970a8887c 100644
--- a/drivers/video/fbdev/nvidia/nvidia.c
+++ b/drivers/video/fbdev/nvidia/nvidia.c
@@ -566,7 +566,8 @@ static int nvidiafb_cursor(struct fb_info *info, struct fb_cursor *cursor)
 		u8 *msk = (u8 *) cursor->mask;
 		u8 *src;
 
-		src = kmalloc(s_pitch * cursor->image.height, GFP_ATOMIC);
+		src = kmalloc(array_size(s_pitch, cursor->image.height),
+			      GFP_ATOMIC);
 
 		if (src) {
 			switch (cursor->rop) {
@@ -1284,7 +1285,7 @@ static int nvidiafb_probe(struct pci_dev *pd, const struct pci_device_id *ent)
 
 	par = info->par;
 	par->pci_dev = pd;
-	info->pixmap.addr = kzalloc(8 * 1024, GFP_KERNEL);
+	info->pixmap.addr = kzalloc(array_size(8, 1024), GFP_KERNEL);
 
 	if (info->pixmap.addr == NULL)
 		goto err_out_kfree;
diff --git a/drivers/video/fbdev/riva/fbdev.c b/drivers/video/fbdev/riva/fbdev.c
index ff8282374f37..1a7f7a3fc93a 100644
--- a/drivers/video/fbdev/riva/fbdev.c
+++ b/drivers/video/fbdev/riva/fbdev.c
@@ -1615,7 +1615,8 @@ static int rivafb_cursor(struct fb_info *info, struct fb_cursor *cursor)
 		u8 *msk = (u8 *) cursor->mask;
 		u8 *src;
 		
-		src = kmalloc(s_pitch * cursor->image.height, GFP_ATOMIC);
+		src = kmalloc(array_size(s_pitch, cursor->image.height),
+			      GFP_ATOMIC);
 
 		if (src) {
 			switch (cursor->rop) {
@@ -1909,7 +1910,7 @@ static int rivafb_probe(struct pci_dev *pd, const struct pci_device_id *ent)
 	default_par = info->par;
 	default_par->pdev = pd;
 
-	info->pixmap.addr = kzalloc(8 * 1024, GFP_KERNEL);
+	info->pixmap.addr = kzalloc(array_size(8, 1024), GFP_KERNEL);
 	if (info->pixmap.addr == NULL) {
 	    	ret = -ENOMEM;
 		goto err_framebuffer_release;
diff --git a/drivers/video/fbdev/uvesafb.c b/drivers/video/fbdev/uvesafb.c
index 889a3dee98e9..06a408fd6f2e 100644
--- a/drivers/video/fbdev/uvesafb.c
+++ b/drivers/video/fbdev/uvesafb.c
@@ -486,8 +486,8 @@ static int uvesafb_vbe_getmodes(struct uvesafb_ktask *task,
 		mode++;
 	}
 
-	par->vbe_modes = kzalloc(sizeof(struct vbe_mode_ib) *
-				par->vbe_modes_cnt, GFP_KERNEL);
+	par->vbe_modes = kzalloc(array_size(sizeof(struct vbe_mode_ib), par->vbe_modes_cnt),
+				 GFP_KERNEL);
 	if (!par->vbe_modes)
 		return -ENOMEM;
 
@@ -1044,7 +1044,8 @@ static int uvesafb_setcmap(struct fb_cmap *cmap, struct fb_info *info)
 		    info->cmap.len || cmap->start < info->cmap.start)
 			return -EINVAL;
 
-		entries = kmalloc(sizeof(*entries) * cmap->len, GFP_KERNEL);
+		entries = kmalloc(array_size(sizeof(*entries), cmap->len),
+				  GFP_KERNEL);
 		if (!entries)
 			return -ENOMEM;
 
diff --git a/drivers/video/of_display_timing.c b/drivers/video/of_display_timing.c
index 83b8963c9657..8b1fdc19cde5 100644
--- a/drivers/video/of_display_timing.c
+++ b/drivers/video/of_display_timing.c
@@ -181,8 +181,8 @@ struct display_timings *of_get_display_timings(const struct device_node *np)
 		goto entryfail;
 	}
 
-	disp->timings = kzalloc(sizeof(struct display_timing *) *
-				disp->num_timings, GFP_KERNEL);
+	disp->timings = kzalloc(array_size(sizeof(struct display_timing *), disp->num_timings),
+				GFP_KERNEL);
 	if (!disp->timings) {
 		pr_err("%pOF: could not allocate timings array\n", np);
 		goto entryfail;
diff --git a/drivers/virt/vboxguest/vboxguest_core.c b/drivers/virt/vboxguest/vboxguest_core.c
index 7351f620fe4b..ef393e9bcbcd 100644
--- a/drivers/virt/vboxguest/vboxguest_core.c
+++ b/drivers/virt/vboxguest/vboxguest_core.c
@@ -69,7 +69,8 @@ static void vbg_guest_mappings_init(struct vbg_dev *gdev)
 	/* Add 4M so that we can align the vmap to 4MiB as the host requires. */
 	size = PAGE_ALIGN(req->hypervisor_size) + SZ_4M;
 
-	pages = kmalloc(sizeof(*pages) * (size >> PAGE_SHIFT), GFP_KERNEL);
+	pages = kmalloc(array_size(sizeof(*pages), (size >> PAGE_SHIFT)),
+			GFP_KERNEL);
 	if (!pages)
 		goto out;
 
diff --git a/drivers/xen/xen-pciback/pciback_ops.c b/drivers/xen/xen-pciback/pciback_ops.c
index ee2c891b55c6..43897e381505 100644
--- a/drivers/xen/xen-pciback/pciback_ops.c
+++ b/drivers/xen/xen-pciback/pciback_ops.c
@@ -234,7 +234,7 @@ int xen_pcibk_enable_msix(struct xen_pcibk_device *pdev,
 	if (dev->msi_enabled || !(cmd & PCI_COMMAND_MEMORY))
 		return -ENXIO;
 
-	entries = kmalloc(op->value * sizeof(*entries), GFP_KERNEL);
+	entries = kmalloc(array_size(op->value, sizeof(*entries)), GFP_KERNEL);
 	if (entries == NULL)
 		return -ENOMEM;
 
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index b2c9728f8164..39b9af14e913 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -203,7 +203,8 @@ static int afs_deliver_cb_callback(struct afs_call *call)
 		if (call->count > AFSCBMAX)
 			return afs_protocol_error(call, -EBADMSG);
 
-		call->buffer = kmalloc(call->count * 3 * 4, GFP_KERNEL);
+		call->buffer = kmalloc(array3_size(call->count, 3, 4),
+				       GFP_KERNEL);
 		if (!call->buffer)
 			return -ENOMEM;
 		call->offset = 0;
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index dc062b195c46..5ef9a7b4bcbc 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -1603,9 +1603,8 @@ static int btrfsic_read_block(struct btrfsic_state *state,
 
 	num_pages = (block_ctx->len + (u64)PAGE_SIZE - 1) >>
 		    PAGE_SHIFT;
-	block_ctx->mem_to_free = kzalloc((sizeof(*block_ctx->datav) +
-					  sizeof(*block_ctx->pagev)) *
-					 num_pages, GFP_NOFS);
+	block_ctx->mem_to_free = kzalloc(array_size((sizeof(*block_ctx->datav) + sizeof(*block_ctx->pagev)), num_pages),
+					 GFP_NOFS);
 	if (!block_ctx->mem_to_free)
 		return -ENOMEM;
 	block_ctx->datav = block_ctx->mem_to_free;
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 5ece2e6ad154..9eb0df9b44d0 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -2992,8 +2992,8 @@ static int encode_caps_cb(struct inode *inode, struct ceph_cap *cap,
 			num_flock_locks = 0;
 		}
 		if (num_fcntl_locks + num_flock_locks > 0) {
-			flocks = kmalloc((num_fcntl_locks + num_flock_locks) *
-					 sizeof(struct ceph_filelock), GFP_NOFS);
+			flocks = kmalloc(array_size((num_fcntl_locks + num_flock_locks), sizeof(struct ceph_filelock)),
+					 GFP_NOFS);
 			if (!flocks) {
 				err = -ENOMEM;
 				goto out_free;
diff --git a/fs/cifs/smb2pdu.c b/fs/cifs/smb2pdu.c
index 29e48ae8e269..b85ff8a1b69c 100644
--- a/fs/cifs/smb2pdu.c
+++ b/fs/cifs/smb2pdu.c
@@ -1379,7 +1379,7 @@ SMB2_tcon(const unsigned int xid, struct cifs_ses *ses, const char *tree,
 	if (!(ses->server) || !tree)
 		return -EIO;
 
-	unc_path = kmalloc(MAX_SHARENAME_LENGTH * 2, GFP_KERNEL);
+	unc_path = kmalloc(array_size(MAX_SHARENAME_LENGTH, 2), GFP_KERNEL);
 	if (unc_path == NULL)
 		return -ENOMEM;
 
diff --git a/fs/cifs/transport.c b/fs/cifs/transport.c
index 927226a2122f..5e4dfe6f6fbd 100644
--- a/fs/cifs/transport.c
+++ b/fs/cifs/transport.c
@@ -832,7 +832,7 @@ SendReceive2(const unsigned int xid, struct cifs_ses *ses,
 	int rc;
 
 	if (n_vec + 1 > CIFS_MAX_IOV_SIZE) {
-		new_iov = kmalloc(sizeof(struct kvec) * (n_vec + 1),
+		new_iov = kmalloc(array_size(sizeof(struct kvec), (n_vec + 1)),
 				  GFP_KERNEL);
 		if (!new_iov) {
 			/* otherwise cifs_send_recv below sets resp_buf_type */
@@ -874,7 +874,7 @@ smb2_send_recv(const unsigned int xid, struct cifs_ses *ses,
 	__be32 rfc1002_marker;
 
 	if (n_vec + 1 > CIFS_MAX_IOV_SIZE) {
-		new_iov = kmalloc(sizeof(struct kvec) * (n_vec + 1),
+		new_iov = kmalloc(array_size(sizeof(struct kvec), (n_vec + 1)),
 				  GFP_KERNEL);
 		if (!new_iov)
 			return -ENOMEM;
diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 708b574a35a4..fa8aaa4cb60f 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -577,7 +577,7 @@ int ext4_ext_precache(struct inode *inode)
 	down_read(&ei->i_data_sem);
 	depth = ext_depth(inode);
 
-	path = kzalloc(sizeof(struct ext4_ext_path) * (depth + 1),
+	path = kzalloc(array_size(sizeof(struct ext4_ext_path), (depth + 1)),
 		       GFP_NOFS);
 	if (path == NULL) {
 		up_read(&ei->i_data_sem);
@@ -879,8 +879,8 @@ ext4_find_extent(struct inode *inode, ext4_lblk_t block,
 	}
 	if (!path) {
 		/* account possible depth increase */
-		path = kzalloc(sizeof(struct ext4_ext_path) * (depth + 2),
-				GFP_NOFS);
+		path = kzalloc(array_size(sizeof(struct ext4_ext_path), (depth + 2)),
+			       GFP_NOFS);
 		if (unlikely(!path))
 			return ERR_PTR(-ENOMEM);
 		path[0].p_maxdepth = depth + 1;
@@ -2921,7 +2921,7 @@ int ext4_ext_remove_space(struct inode *inode, ext4_lblk_t start,
 			path[k].p_block =
 				le16_to_cpu(path[k].p_hdr->eh_entries)+1;
 	} else {
-		path = kzalloc(sizeof(struct ext4_ext_path) * (depth + 1),
+		path = kzalloc(array_size(sizeof(struct ext4_ext_path), (depth + 1)),
 			       GFP_NOFS);
 		if (path == NULL) {
 			ext4_journal_stop(handle);
diff --git a/fs/ext4/resize.c b/fs/ext4/resize.c
index d5640ca8c499..c0b74b875b96 100644
--- a/fs/ext4/resize.c
+++ b/fs/ext4/resize.c
@@ -839,8 +839,7 @@ static int add_new_gdb(handle_t *handle, struct inode *inode,
 	if (unlikely(err))
 		goto exit_dind;
 
-	n_group_desc = ext4_kvmalloc((gdb_num + 1) *
-				     sizeof(struct buffer_head *),
+	n_group_desc = ext4_kvmalloc(array_size((gdb_num + 1), sizeof(struct buffer_head *)),
 				     GFP_NOFS);
 	if (!n_group_desc) {
 		err = -ENOMEM;
@@ -918,8 +917,7 @@ static int add_new_gdb_meta_bg(struct super_block *sb,
 	gdb_bh = sb_bread(sb, gdblock);
 	if (!gdb_bh)
 		return -EIO;
-	n_group_desc = ext4_kvmalloc((gdb_num + 1) *
-				     sizeof(struct buffer_head *),
+	n_group_desc = ext4_kvmalloc(array_size((gdb_num + 1), sizeof(struct buffer_head *)),
 				     GFP_NOFS);
 	if (!n_group_desc) {
 		err = -ENOMEM;
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 947e64abb95d..74975b3be6aa 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1362,7 +1362,8 @@ static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
 	if (!fud)
 		return -EPERM;
 
-	bufs = kmalloc(pipe->buffers * sizeof(struct pipe_buffer), GFP_KERNEL);
+	bufs = kmalloc(array_size(pipe->buffers, sizeof(struct pipe_buffer)),
+		       GFP_KERNEL);
 	if (!bufs)
 		return -ENOMEM;
 
@@ -1943,7 +1944,8 @@ static ssize_t fuse_dev_splice_write(struct pipe_inode_info *pipe,
 	if (!fud)
 		return -EPERM;
 
-	bufs = kmalloc(pipe->buffers * sizeof(struct pipe_buffer), GFP_KERNEL);
+	bufs = kmalloc(array_size(pipe->buffers, sizeof(struct pipe_buffer)),
+		       GFP_KERNEL);
 	if (!bufs)
 		return -ENOMEM;
 
diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
index d68bf63af8b8..3f6aba012006 100644
--- a/fs/gfs2/dir.c
+++ b/fs/gfs2/dir.c
@@ -1169,7 +1169,7 @@ static int dir_double_exhash(struct gfs2_inode *dip)
 	if (IS_ERR(hc))
 		return PTR_ERR(hc);
 
-	hc2 = kmalloc(hsize_bytes * 2, GFP_NOFS | __GFP_NOWARN);
+	hc2 = kmalloc(array_size(hsize_bytes, 2), GFP_NOFS | __GFP_NOWARN);
 	if (hc2 == NULL)
 		hc2 = __vmalloc(hsize_bytes * 2, GFP_NOFS, PAGE_KERNEL);
 
diff --git a/fs/gfs2/rgrp.c b/fs/gfs2/rgrp.c
index 8b683917a27e..948a167d34cf 100644
--- a/fs/gfs2/rgrp.c
+++ b/fs/gfs2/rgrp.c
@@ -2605,7 +2605,7 @@ void gfs2_rlist_alloc(struct gfs2_rgrp_list *rlist, unsigned int state)
 {
 	unsigned int x;
 
-	rlist->rl_ghs = kmalloc(rlist->rl_rgrps * sizeof(struct gfs2_holder),
+	rlist->rl_ghs = kmalloc(array_size(rlist->rl_rgrps, sizeof(struct gfs2_holder)),
 				GFP_NOFS | __GFP_NOFAIL);
 	for (x = 0; x < rlist->rl_rgrps; x++)
 		gfs2_holder_init(rlist->rl_rgd[x]->rd_gl,
diff --git a/fs/hpfs/dnode.c b/fs/hpfs/dnode.c
index a4ad18afbdec..052a2dd64ea6 100644
--- a/fs/hpfs/dnode.c
+++ b/fs/hpfs/dnode.c
@@ -33,7 +33,7 @@ int hpfs_add_pos(struct inode *inode, loff_t *pos)
 			if (hpfs_inode->i_rddir_off[i] == pos)
 				return 0;
 	if (!(i&0x0f)) {
-		if (!(ppos = kmalloc((i+0x11) * sizeof(loff_t*), GFP_NOFS))) {
+		if (!(ppos = kmalloc(array_size((i + 0x11), sizeof(loff_t *)), GFP_NOFS))) {
 			pr_err("out of memory for position list\n");
 			return -ENOMEM;
 		}
diff --git a/fs/hpfs/map.c b/fs/hpfs/map.c
index 7c49f1ef0c85..616ffe643e1e 100644
--- a/fs/hpfs/map.c
+++ b/fs/hpfs/map.c
@@ -115,7 +115,7 @@ __le32 *hpfs_load_bitmap_directory(struct super_block *s, secno bmp)
 	int n = (hpfs_sb(s)->sb_fs_size + 0x200000 - 1) >> 21;
 	int i;
 	__le32 *b;
-	if (!(b = kmalloc(n * 512, GFP_KERNEL))) {
+	if (!(b = kmalloc(array_size(n, 512), GFP_KERNEL))) {
 		pr_err("can't allocate memory for bitmap directory\n");
 		return NULL;
 	}	
diff --git a/fs/jffs2/wbuf.c b/fs/jffs2/wbuf.c
index 2cfe487708e0..ac8ec1680544 100644
--- a/fs/jffs2/wbuf.c
+++ b/fs/jffs2/wbuf.c
@@ -1208,7 +1208,8 @@ int jffs2_nand_flash_setup(struct jffs2_sb_info *c)
 	if (!c->wbuf)
 		return -ENOMEM;
 
-	c->oobbuf = kmalloc(NR_OOB_SCAN_PAGES * c->oobavail, GFP_KERNEL);
+	c->oobbuf = kmalloc(array_size(NR_OOB_SCAN_PAGES, c->oobavail),
+			    GFP_KERNEL);
 	if (!c->oobbuf) {
 		kfree(c->wbuf);
 		return -ENOMEM;
diff --git a/fs/jfs/jfs_dtree.c b/fs/jfs/jfs_dtree.c
index de2bcb36e079..70880fb1db18 100644
--- a/fs/jfs/jfs_dtree.c
+++ b/fs/jfs/jfs_dtree.c
@@ -594,7 +594,8 @@ int dtSearch(struct inode *ip, struct component_name * key, ino_t * data,
 	struct component_name ciKey;
 	struct super_block *sb = ip->i_sb;
 
-	ciKey.name = kmalloc((JFS_NAME_MAX + 1) * sizeof(wchar_t), GFP_NOFS);
+	ciKey.name = kmalloc(array_size((JFS_NAME_MAX + 1), sizeof(wchar_t)),
+			     GFP_NOFS);
 	if (!ciKey.name) {
 		rc = -ENOMEM;
 		goto dtSearch_Exit2;
@@ -957,7 +958,8 @@ static int dtSplitUp(tid_t tid,
 	smp = split->mp;
 	sp = DT_PAGE(ip, smp);
 
-	key.name = kmalloc((JFS_NAME_MAX + 2) * sizeof(wchar_t), GFP_NOFS);
+	key.name = kmalloc(array_size((JFS_NAME_MAX + 2), sizeof(wchar_t)),
+			   GFP_NOFS);
 	if (!key.name) {
 		DT_PUTPAGE(smp);
 		rc = -ENOMEM;
@@ -3779,13 +3781,13 @@ static int ciGetLeafPrefixKey(dtpage_t * lp, int li, dtpage_t * rp,
 	struct component_name lkey;
 	struct component_name rkey;
 
-	lkey.name = kmalloc((JFS_NAME_MAX + 1) * sizeof(wchar_t),
-					GFP_KERNEL);
+	lkey.name = kmalloc(array_size((JFS_NAME_MAX + 1), sizeof(wchar_t)),
+			    GFP_KERNEL);
 	if (lkey.name == NULL)
 		return -ENOMEM;
 
-	rkey.name = kmalloc((JFS_NAME_MAX + 1) * sizeof(wchar_t),
-					GFP_KERNEL);
+	rkey.name = kmalloc(array_size((JFS_NAME_MAX + 1), sizeof(wchar_t)),
+			    GFP_KERNEL);
 	if (rkey.name == NULL) {
 		kfree(lkey.name);
 		return -ENOMEM;
diff --git a/fs/jfs/jfs_unicode.c b/fs/jfs/jfs_unicode.c
index c7de6f5bbefc..3c324911b127 100644
--- a/fs/jfs/jfs_unicode.c
+++ b/fs/jfs/jfs_unicode.c
@@ -121,7 +121,7 @@ int get_UCSname(struct component_name * uniName, struct dentry *dentry)
 		return -ENAMETOOLONG;
 
 	uniName->name =
-	    kmalloc((length + 1) * sizeof(wchar_t), GFP_NOFS);
+	    kmalloc(array_size((length + 1), sizeof(wchar_t)), GFP_NOFS);
 
 	if (uniName->name == NULL)
 		return -ENOMEM;
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 8ceb25a10ea0..fd042ba61e10 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -404,8 +404,8 @@ fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc)
 	if (fsloc->locations_count == 0)
 		return 0;
 
-	fsloc->locations = kzalloc(fsloc->locations_count
-			* sizeof(struct nfsd4_fs_location), GFP_KERNEL);
+	fsloc->locations = kzalloc(array_size(fsloc->locations_count, sizeof(struct nfsd4_fs_location)),
+				   GFP_KERNEL);
 	if (!fsloc->locations)
 		return -ENOMEM;
 	for (i=0; i < fsloc->locations_count; i++) {
diff --git a/fs/ocfs2/journal.c b/fs/ocfs2/journal.c
index e5dcea6cee5f..748d7e81bfcf 100644
--- a/fs/ocfs2/journal.c
+++ b/fs/ocfs2/journal.c
@@ -1383,7 +1383,7 @@ static int __ocfs2_recovery_thread(void *arg)
 		goto bail;
 	}
 
-	rm_quota = kzalloc(osb->max_slots * sizeof(int), GFP_NOFS);
+	rm_quota = kzalloc(array_size(osb->max_slots, sizeof(int)), GFP_NOFS);
 	if (!rm_quota) {
 		status = -ENOMEM;
 		goto bail;
diff --git a/fs/ocfs2/sysfile.c b/fs/ocfs2/sysfile.c
index af155c183123..bef0932590ce 100644
--- a/fs/ocfs2/sysfile.c
+++ b/fs/ocfs2/sysfile.c
@@ -69,9 +69,7 @@ static struct inode **get_local_system_inode(struct ocfs2_super *osb,
 	spin_unlock(&osb->osb_lock);
 
 	if (unlikely(!local_system_inodes)) {
-		local_system_inodes = kzalloc(sizeof(struct inode *) *
-					      NUM_LOCAL_SYSTEM_INODES *
-					      osb->max_slots,
+		local_system_inodes = kzalloc(array3_size(sizeof(struct inode *), NUM_LOCAL_SYSTEM_INODES, osb->max_slots),
 					      GFP_NOFS);
 		if (!local_system_inodes) {
 			mlog_errno(-ENOMEM);
diff --git a/fs/overlayfs/namei.c b/fs/overlayfs/namei.c
index 2dba29eadde6..ca9b06516f0d 100644
--- a/fs/overlayfs/namei.c
+++ b/fs/overlayfs/namei.c
@@ -612,7 +612,7 @@ static int ovl_get_index_name_fh(struct ovl_fh *fh, struct qstr *name)
 {
 	char *n, *s;
 
-	n = kzalloc(fh->len * 2, GFP_KERNEL);
+	n = kzalloc(array_size(fh->len, 2), GFP_KERNEL);
 	if (!n)
 		return -ENOMEM;
 
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 8989936f2995..e4bb535b4df3 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -1417,7 +1417,7 @@ static int register_leaf_sysctl_tables(const char *path, char *pos,
 	/* If there are mixed files and directories we need a new table */
 	if (nr_dirs && nr_files) {
 		struct ctl_table *new;
-		files = kzalloc(sizeof(struct ctl_table) * (nr_files + 1),
+		files = kzalloc(array_size(sizeof(struct ctl_table), (nr_files + 1)),
 				GFP_KERNEL);
 		if (!files)
 			goto out;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c486ad4b43f0..70448d34bf2d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1466,7 +1466,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	pm.show_pfn = file_ns_capable(file, &init_user_ns, CAP_SYS_ADMIN);
 
 	pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
-	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_KERNEL);
+	pm.buffer = kmalloc(array_size(pm.len, PM_ENTRY_BYTES), GFP_KERNEL);
 	ret = -ENOMEM;
 	if (!pm.buffer)
 		goto out_mm;
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index b13fc024d2ee..e5e0781f6c35 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -1044,7 +1044,8 @@ int reiserfs_get_block(struct inode *inode, sector_t block,
 			if (blocks_needed == 1) {
 				un = &unf_single;
 			} else {
-				un = kzalloc(min(blocks_needed, max_to_insert) * UNFM_P_SIZE, GFP_NOFS);
+				un = kzalloc(array_size(min(blocks_needed, max_to_insert), UNFM_P_SIZE),
+					     GFP_NOFS);
 				if (!un) {
 					un = &unf_single;
 					blocks_needed = 1;
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index 23148c3ed675..d8c85c9a3227 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -2192,10 +2192,10 @@ static int journal_read_transaction(struct super_block *sb,
 	 * now we know we've got a good transaction, and it was
 	 * inside the valid time ranges
 	 */
-	log_blocks = kmalloc(get_desc_trans_len(desc) *
-			     sizeof(struct buffer_head *), GFP_NOFS);
-	real_blocks = kmalloc(get_desc_trans_len(desc) *
-			      sizeof(struct buffer_head *), GFP_NOFS);
+	log_blocks = kmalloc(array_size(get_desc_trans_len(desc), sizeof(struct buffer_head *)),
+			     GFP_NOFS);
+	real_blocks = kmalloc(array_size(get_desc_trans_len(desc), sizeof(struct buffer_head *)),
+			      GFP_NOFS);
 	if (!log_blocks || !real_blocks) {
 		brelse(c_bh);
 		brelse(d_bh);
diff --git a/fs/select.c b/fs/select.c
index ba879c51288f..41ad4307f7b5 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -1223,7 +1223,7 @@ static int compat_core_sys_select(int n, compat_ulong_t __user *inp,
 	size = FDS_BYTES(n);
 	bits = stack_fds;
 	if (size > sizeof(stack_fds) / 6) {
-		bits = kmalloc(6 * size, GFP_KERNEL);
+		bits = kmalloc(array_size(6, size), GFP_KERNEL);
 		ret = -ENOMEM;
 		if (!bits)
 			goto out_nofds;
diff --git a/fs/ubifs/lpt.c b/fs/ubifs/lpt.c
index 322f7aa7f44f..6f3a83cce258 100644
--- a/fs/ubifs/lpt.c
+++ b/fs/ubifs/lpt.c
@@ -628,7 +628,7 @@ int ubifs_create_dflt_lpt(struct ubifs_info *c, int *main_lebs, int lpt_first,
 	/* Needed by 'ubifs_pack_lsave()' */
 	c->main_first = c->leb_cnt - *main_lebs;
 
-	lsave = kmalloc(sizeof(int) * c->lsave_cnt, GFP_KERNEL);
+	lsave = kmalloc(array_size(sizeof(int), c->lsave_cnt), GFP_KERNEL);
 	pnode = kzalloc(sizeof(struct ubifs_pnode), GFP_KERNEL);
 	nnode = kzalloc(sizeof(struct ubifs_nnode), GFP_KERNEL);
 	buf = vmalloc(c->leb_size);
@@ -1698,7 +1698,8 @@ static int lpt_init_wr(struct ubifs_info *c)
 		return -ENOMEM;
 
 	if (c->big_lpt) {
-		c->lsave = kmalloc(sizeof(int) * c->lsave_cnt, GFP_NOFS);
+		c->lsave = kmalloc(array_size(sizeof(int), c->lsave_cnt),
+				   GFP_NOFS);
 		if (!c->lsave)
 			return -ENOMEM;
 		err = read_lsave(c);
@@ -1940,7 +1941,7 @@ int ubifs_lpt_scan_nolock(struct ubifs_info *c, int start_lnum, int end_lnum,
 			return err;
 	}
 
-	path = kmalloc(sizeof(struct lpt_scan_node) * (c->lpt_hght + 1),
+	path = kmalloc(array_size(sizeof(struct lpt_scan_node), (c->lpt_hght + 1)),
 		       GFP_NOFS);
 	if (!path)
 		return -ENOMEM;
diff --git a/fs/ubifs/tnc.c b/fs/ubifs/tnc.c
index ba3d0e0f8615..d3ccabce9be0 100644
--- a/fs/ubifs/tnc.c
+++ b/fs/ubifs/tnc.c
@@ -1104,7 +1104,7 @@ static struct ubifs_znode *dirty_cow_bottom_up(struct ubifs_info *c,
 	ubifs_assert(znode);
 	if (c->zroot.znode->level > BOTTOM_UP_HEIGHT) {
 		kfree(c->bottom_up_buf);
-		c->bottom_up_buf = kmalloc(c->zroot.znode->level * sizeof(int),
+		c->bottom_up_buf = kmalloc(array_size(c->zroot.znode->level, sizeof(int)),
 					   GFP_NOFS);
 		if (!c->bottom_up_buf)
 			return ERR_PTR(-ENOMEM);
diff --git a/fs/ubifs/tnc_commit.c b/fs/ubifs/tnc_commit.c
index 3fad907bbd25..74841922335d 100644
--- a/fs/ubifs/tnc_commit.c
+++ b/fs/ubifs/tnc_commit.c
@@ -366,7 +366,8 @@ static int layout_in_gaps(struct ubifs_info *c, int cnt)
 
 	dbg_gc("%d znodes to write", cnt);
 
-	c->gap_lebs = kmalloc(sizeof(int) * (c->lst.idx_lebs + 1), GFP_NOFS);
+	c->gap_lebs = kmalloc(array_size(sizeof(int), (c->lst.idx_lebs + 1)),
+			      GFP_NOFS);
 	if (!c->gap_lebs)
 		return -ENOMEM;
 
diff --git a/fs/udf/super.c b/fs/udf/super.c
index 55bcd93a1145..6a9a664848fc 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -1647,8 +1647,8 @@ static noinline int udf_process_sequence(
 
 	memset(data.vds, 0, sizeof(struct udf_vds_record) * VDS_POS_LENGTH);
 	data.size_part_descs = PART_DESC_ALLOC_STEP;
-	data.part_descs_loc = kzalloc(sizeof(*data.part_descs_loc) *
-					data.size_part_descs, GFP_KERNEL);
+	data.part_descs_loc = kzalloc(array_size(sizeof(*data.part_descs_loc), data.size_part_descs),
+				      GFP_KERNEL);
 	if (!data.part_descs_loc)
 		return -ENOMEM;
 
diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index 8254b8b3690f..543802fbf86d 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -541,7 +541,7 @@ static int ufs_read_cylinder_structures(struct super_block *sb)
 	 * Read cylinder group (we read only first fragment from block
 	 * at this time) and prepare internal data structures for cg caching.
 	 */
-	if (!(sbi->s_ucg = kmalloc (sizeof(struct buffer_head *) * uspi->s_ncg, GFP_NOFS)))
+	if (!(sbi->s_ucg = kmalloc(array_size(sizeof(struct buffer_head *), uspi->s_ncg), GFP_NOFS)))
 		goto failed;
 	for (i = 0; i < uspi->s_ncg; i++) 
 		sbi->s_ucg[i] = NULL;
diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index b4b5b81e7251..6860fb1108f0 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -623,7 +623,7 @@ static int trie_get_next_key(struct bpf_map *map, void *_key, void *_next_key)
 	if (!key || key->prefixlen > trie->max_prefixlen)
 		goto find_leftmost;
 
-	node_stack = kmalloc(trie->max_prefixlen * sizeof(struct lpm_trie_node *),
+	node_stack = kmalloc(array_size(trie->max_prefixlen, sizeof(struct lpm_trie_node *)),
 			     GFP_ATOMIC | __GFP_NOWARN);
 	if (!node_stack)
 		return -ENOMEM;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 5dd1dcb902bf..a3170ed0f8c9 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -5265,7 +5265,8 @@ static int jit_subprogs(struct bpf_verifier_env *env)
 		insn->imm = 1;
 	}
 
-	func = kzalloc(sizeof(prog) * (env->subprog_cnt + 1), GFP_KERNEL);
+	func = kzalloc(array_size(sizeof(prog), (env->subprog_cnt + 1)),
+		       GFP_KERNEL);
 	if (!func)
 		return -ENOMEM;
 
diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index d68ef0115ee9..4c3f39aff8e6 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -683,7 +683,7 @@ static int generate_sched_domains(cpumask_var_t **domains,
 		goto done;
 	}
 
-	csa = kmalloc(nr_cpusets() * sizeof(cp), GFP_KERNEL);
+	csa = kmalloc(array_size(nr_cpusets(), sizeof(cp)), GFP_KERNEL);
 	if (!csa)
 		goto done;
 	csn = 0;
diff --git a/kernel/debug/kdb/kdb_main.c b/kernel/debug/kdb/kdb_main.c
index e405677ee08d..ac7be4cc0809 100644
--- a/kernel/debug/kdb/kdb_main.c
+++ b/kernel/debug/kdb/kdb_main.c
@@ -691,7 +691,8 @@ static int kdb_defcmd2(const char *cmdstr, const char *argv0)
 	}
 	if (!s->usable)
 		return KDB_NOTIMP;
-	s->command = kzalloc((s->count + 1) * sizeof(*(s->command)), GFP_KDB);
+	s->command = kzalloc(array_size((s->count + 1), sizeof(*(s->command))),
+			     GFP_KDB);
 	if (!s->command) {
 		kdb_printf("Could not allocate new kdb_defcmd table for %s\n",
 			   cmdstr);
@@ -729,7 +730,7 @@ static int kdb_defcmd(int argc, const char **argv)
 		kdb_printf("Command only available during kdb_init()\n");
 		return KDB_NOTIMP;
 	}
-	defcmd_set = kmalloc((defcmd_set_count + 1) * sizeof(*defcmd_set),
+	defcmd_set = kmalloc(array_size((defcmd_set_count + 1), sizeof(*defcmd_set)),
 			     GFP_KDB);
 	if (!defcmd_set)
 		goto fail_defcmd;
@@ -2706,8 +2707,8 @@ int kdb_register_flags(char *cmd,
 	}
 
 	if (i >= kdb_max_commands) {
-		kdbtab_t *new = kmalloc((kdb_max_commands - KDB_BASE_CMD_MAX +
-			 kdb_command_extend) * sizeof(*new), GFP_KDB);
+		kdbtab_t *new = kmalloc(array_size((kdb_max_commands - KDB_BASE_CMD_MAX + kdb_command_extend), sizeof(*new)),
+					GFP_KDB);
 		if (!new) {
 			kdb_printf("Could not allocate new kdb_command "
 				   "table\n");
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1725b902983f..1ef39478b866 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1184,7 +1184,8 @@ static struct xol_area *__create_xol_area(unsigned long vaddr)
 	if (unlikely(!area))
 		goto out;
 
-	area->bitmap = kzalloc(BITS_TO_LONGS(UINSNS_PER_PAGE) * sizeof(long), GFP_KERNEL);
+	area->bitmap = kzalloc(array_size(BITS_TO_LONGS(UINSNS_PER_PAGE), sizeof(long)),
+			       GFP_KERNEL);
 	if (!area->bitmap)
 		goto free_area;
 
diff --git a/kernel/fail_function.c b/kernel/fail_function.c
index 1d5632d8bbcc..c0694c049c2c 100644
--- a/kernel/fail_function.c
+++ b/kernel/fail_function.c
@@ -258,7 +258,7 @@ static ssize_t fei_write(struct file *file, const char __user *buffer,
 	/* cut off if it is too long */
 	if (count > KSYM_NAME_LEN)
 		count = KSYM_NAME_LEN;
-	buf = kmalloc(sizeof(char) * (count + 1), GFP_KERNEL);
+	buf = kmalloc(array_size(sizeof(char), (count + 1)), GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
diff --git a/kernel/locking/locktorture.c b/kernel/locking/locktorture.c
index 6850ffd69125..194c341e327f 100644
--- a/kernel/locking/locktorture.c
+++ b/kernel/locking/locktorture.c
@@ -913,7 +913,8 @@ static int __init lock_torture_init(void)
 	/* Initialize the statistics so that each run gets its own numbers. */
 	if (nwriters_stress) {
 		lock_is_write_held = 0;
-		cxt.lwsa = kmalloc(sizeof(*cxt.lwsa) * cxt.nrealwriters_stress, GFP_KERNEL);
+		cxt.lwsa = kmalloc(array_size(sizeof(*cxt.lwsa), cxt.nrealwriters_stress),
+				   GFP_KERNEL);
 		if (cxt.lwsa == NULL) {
 			VERBOSE_TOROUT_STRING("cxt.lwsa: Out of memory");
 			firsterr = -ENOMEM;
@@ -942,7 +943,8 @@ static int __init lock_torture_init(void)
 
 		if (nreaders_stress) {
 			lock_is_read_held = 0;
-			cxt.lrsa = kmalloc(sizeof(*cxt.lrsa) * cxt.nrealreaders_stress, GFP_KERNEL);
+			cxt.lrsa = kmalloc(array_size(sizeof(*cxt.lrsa), cxt.nrealreaders_stress),
+					   GFP_KERNEL);
 			if (cxt.lrsa == NULL) {
 				VERBOSE_TOROUT_STRING("cxt.lrsa: Out of memory");
 				firsterr = -ENOMEM;
@@ -985,7 +987,7 @@ static int __init lock_torture_init(void)
 	}
 
 	if (nwriters_stress) {
-		writer_tasks = kzalloc(cxt.nrealwriters_stress * sizeof(writer_tasks[0]),
+		writer_tasks = kzalloc(array_size(cxt.nrealwriters_stress, sizeof(writer_tasks[0])),
 				       GFP_KERNEL);
 		if (writer_tasks == NULL) {
 			VERBOSE_TOROUT_ERRSTRING("writer_tasks: Out of memory");
@@ -995,7 +997,7 @@ static int __init lock_torture_init(void)
 	}
 
 	if (cxt.cur_ops->readlock) {
-		reader_tasks = kzalloc(cxt.nrealreaders_stress * sizeof(reader_tasks[0]),
+		reader_tasks = kzalloc(array_size(cxt.nrealreaders_stress, sizeof(reader_tasks[0])),
 				       GFP_KERNEL);
 		if (reader_tasks == NULL) {
 			VERBOSE_TOROUT_ERRSTRING("reader_tasks: Out of memory");
diff --git a/kernel/relay.c b/kernel/relay.c
index c955b10c973c..248ab20adc77 100644
--- a/kernel/relay.c
+++ b/kernel/relay.c
@@ -169,7 +169,8 @@ static struct rchan_buf *relay_create_buf(struct rchan *chan)
 	buf = kzalloc(sizeof(struct rchan_buf), GFP_KERNEL);
 	if (!buf)
 		return NULL;
-	buf->padding = kmalloc(chan->n_subbufs * sizeof(size_t *), GFP_KERNEL);
+	buf->padding = kmalloc(array_size(chan->n_subbufs, sizeof(size_t *)),
+			       GFP_KERNEL);
 	if (!buf->padding)
 		goto free_buf;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6a78cf70761d..2a43effaaea3 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -3047,7 +3047,7 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
 		if (IS_ERR(kbuf))
 			return PTR_ERR(kbuf);
 
-		tmp_bitmap = kzalloc(BITS_TO_LONGS(bitmap_len) * sizeof(unsigned long),
+		tmp_bitmap = kzalloc(array_size(BITS_TO_LONGS(bitmap_len), sizeof(unsigned long)),
 				     GFP_KERNEL);
 		if (!tmp_bitmap) {
 			kfree(kbuf);
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 2ca63426d8f0..6af952aab9f5 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -4361,7 +4361,7 @@ int set_tracer_flag(struct trace_array *tr, unsigned int mask, int enabled)
 
 	if (mask == TRACE_ITER_RECORD_TGID) {
 		if (!tgid_map)
-			tgid_map = kzalloc((PID_MAX_DEFAULT + 1) * sizeof(*tgid_map),
+			tgid_map = kzalloc(array_size((PID_MAX_DEFAULT + 1), sizeof(*tgid_map)),
 					   GFP_KERNEL);
 		if (!tgid_map) {
 			tr->trace_flags &= ~TRACE_ITER_RECORD_TGID;
@@ -5069,7 +5069,8 @@ trace_insert_eval_map_file(struct module *mod, struct trace_eval_map **start,
 	 * where the head holds the module and length of array, and the
 	 * tail holds a pointer to the next list.
 	 */
-	map_array = kmalloc(sizeof(*map_array) * (len + 2), GFP_KERNEL);
+	map_array = kmalloc(array_size(sizeof(*map_array), (len + 2)),
+			    GFP_KERNEL);
 	if (!map_array) {
 		pr_warn("Unable to allocate trace eval mapping\n");
 		return;
diff --git a/lib/argv_split.c b/lib/argv_split.c
index 5c35752a9414..67721cf97a63 100644
--- a/lib/argv_split.c
+++ b/lib/argv_split.c
@@ -69,7 +69,7 @@ char **argv_split(gfp_t gfp, const char *str, int *argcp)
 		return NULL;
 
 	argc = count_argc(argv_str);
-	argv = kmalloc(sizeof(*argv) * (argc + 2), gfp);
+	argv = kmalloc(array_size(sizeof(*argv), (argc + 2)), gfp);
 	if (!argv) {
 		kfree(argv_str);
 		return NULL;
diff --git a/lib/reed_solomon/reed_solomon.c b/lib/reed_solomon/reed_solomon.c
index 06d04cfa9339..bde83becda91 100644
--- a/lib/reed_solomon/reed_solomon.c
+++ b/lib/reed_solomon/reed_solomon.c
@@ -85,15 +85,18 @@ static struct rs_control *rs_init(int symsize, int gfpoly, int (*gffunc)(int),
 	rs->gffunc = gffunc;
 
 	/* Allocate the arrays */
-	rs->alpha_to = kmalloc(sizeof(uint16_t) * (rs->nn + 1), GFP_KERNEL);
+	rs->alpha_to = kmalloc(array_size(sizeof(uint16_t), (rs->nn + 1)),
+			       GFP_KERNEL);
 	if (rs->alpha_to == NULL)
 		goto errrs;
 
-	rs->index_of = kmalloc(sizeof(uint16_t) * (rs->nn + 1), GFP_KERNEL);
+	rs->index_of = kmalloc(array_size(sizeof(uint16_t), (rs->nn + 1)),
+			       GFP_KERNEL);
 	if (rs->index_of == NULL)
 		goto erralp;
 
-	rs->genpoly = kmalloc(sizeof(uint16_t) * (rs->nroots + 1), GFP_KERNEL);
+	rs->genpoly = kmalloc(array_size(sizeof(uint16_t), (rs->nroots + 1)),
+			      GFP_KERNEL);
 	if(rs->genpoly == NULL)
 		goto erridx;
 
diff --git a/lib/test_string.c b/lib/test_string.c
index 0fcdb82dca86..6c0c8f5f0b28 100644
--- a/lib/test_string.c
+++ b/lib/test_string.c
@@ -8,7 +8,7 @@ static __init int memset16_selftest(void)
 	unsigned i, j, k;
 	u16 v, *p;
 
-	p = kmalloc(256 * 2 * 2, GFP_KERNEL);
+	p = kmalloc(array3_size(256, 2, 2), GFP_KERNEL);
 	if (!p)
 		return -1;
 
@@ -44,7 +44,7 @@ static __init int memset32_selftest(void)
 	unsigned i, j, k;
 	u32 v, *p;
 
-	p = kmalloc(256 * 2 * 4, GFP_KERNEL);
+	p = kmalloc(array3_size(256, 2, 4), GFP_KERNEL);
 	if (!p)
 		return -1;
 
@@ -80,7 +80,7 @@ static __init int memset64_selftest(void)
 	unsigned i, j, k;
 	u64 v, *p;
 
-	p = kmalloc(256 * 2 * 8, GFP_KERNEL);
+	p = kmalloc(array3_size(256, 2, 8), GFP_KERNEL);
 	if (!p)
 		return -1;
 
diff --git a/lib/test_user_copy.c b/lib/test_user_copy.c
index e161f0498f42..9e7a3af57fbc 100644
--- a/lib/test_user_copy.c
+++ b/lib/test_user_copy.c
@@ -61,7 +61,7 @@ static int __init test_user_copy_init(void)
 	u64 val_u64;
 #endif
 
-	kmem = kmalloc(PAGE_SIZE * 2, GFP_KERNEL);
+	kmem = kmalloc(array_size(PAGE_SIZE, 2), GFP_KERNEL);
 	if (!kmem)
 		return -ENOMEM;
 
diff --git a/mm/slab.c b/mm/slab.c
index 2f308253c3d7..815828a26036 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4338,7 +4338,8 @@ static int leaks_show(struct seq_file *m, void *p)
 	if (x[0] == x[1]) {
 		/* Increase the buffer size */
 		mutex_unlock(&slab_mutex);
-		m->private = kzalloc(x[0] * 4 * sizeof(unsigned long), GFP_KERNEL);
+		m->private = kzalloc(array3_size(x[0], 4, sizeof(unsigned long)),
+				     GFP_KERNEL);
 		if (!m->private) {
 			/* Too bad, we are really out */
 			m->private = x;
diff --git a/mm/slub.c b/mm/slub.c
index 2726905b9dbf..9e7c7157f8cd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3660,8 +3660,8 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	unsigned long *map = kzalloc(BITS_TO_LONGS(page->objects) *
-				     sizeof(long), GFP_ATOMIC);
+	unsigned long *map = kzalloc(array_size(BITS_TO_LONGS(page->objects), sizeof(long)),
+				     GFP_ATOMIC);
 	if (!map)
 		return;
 	slab_err(s, page, text, s->name);
@@ -4455,8 +4455,8 @@ static long validate_slab_cache(struct kmem_cache *s)
 {
 	int node;
 	unsigned long count = 0;
-	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
-				sizeof(unsigned long), GFP_KERNEL);
+	unsigned long *map = kmalloc(array_size(BITS_TO_LONGS(oo_objects(s->max)), sizeof(unsigned long)),
+				     GFP_KERNEL);
 	struct kmem_cache_node *n;
 
 	if (!map)
@@ -4616,8 +4616,8 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	unsigned long i;
 	struct loc_track t = { 0, 0, NULL };
 	int node;
-	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
-				     sizeof(unsigned long), GFP_KERNEL);
+	unsigned long *map = kmalloc(array_size(BITS_TO_LONGS(oo_objects(s->max)), sizeof(unsigned long)),
+				     GFP_KERNEL);
 	struct kmem_cache_node *n;
 
 	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
diff --git a/mm/swapfile.c b/mm/swapfile.c
index fac13e7aab69..2f75036ea4b0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3230,7 +3230,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	/* frontswap enabled? set up bit-per-page map for frontswap */
 	if (IS_ENABLED(CONFIG_FRONTSWAP))
-		frontswap_map = kvzalloc(BITS_TO_LONGS(maxpages) * sizeof(long),
+		frontswap_map = kvzalloc(array_size(BITS_TO_LONGS(maxpages), sizeof(long)),
 					 GFP_KERNEL);
 
 	if (p->bdev &&(swap_flags & SWAP_FLAG_DISCARD) && swap_discardable(p)) {
diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index 16e10680518c..e53fb3fcc9a6 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -242,7 +242,7 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 								"w", nwname);
 				if (!errcode) {
 					*wnames =
-					    kmalloc(sizeof(char *) * *nwname,
+					    kmalloc(array_size(sizeof(char *), *nwname),
 						    GFP_NOFS);
 					if (!*wnames)
 						errcode = -ENOMEM;
@@ -285,8 +285,7 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				    p9pdu_readf(pdu, proto_version, "w", nwqid);
 				if (!errcode) {
 					*wqids =
-					    kmalloc(*nwqid *
-						    sizeof(struct p9_qid),
+					    kmalloc(array_size(*nwqid, sizeof(struct p9_qid)),
 						    GFP_NOFS);
 					if (*wqids == NULL)
 						errcode = -ENOMEM;
diff --git a/net/can/bcm.c b/net/can/bcm.c
index ac5e5e34fee3..44ede6298dbc 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -935,7 +935,7 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 
 		/* create array for CAN frames and copy the data */
 		if (msg_head->nframes > 1) {
-			op->frames = kmalloc(msg_head->nframes * op->cfsiz,
+			op->frames = kmalloc(array_size(msg_head->nframes, op->cfsiz),
 					     GFP_KERNEL);
 			if (!op->frames) {
 				kfree(op);
@@ -1107,7 +1107,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 
 		if (msg_head->nframes > 1) {
 			/* create array for CAN frames and copy the data */
-			op->frames = kmalloc(msg_head->nframes * op->cfsiz,
+			op->frames = kmalloc(array_size(msg_head->nframes, op->cfsiz),
 					     GFP_KERNEL);
 			if (!op->frames) {
 				kfree(op);
@@ -1115,7 +1115,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 			}
 
 			/* create and init array for received CAN frames */
-			op->last_frames = kzalloc(msg_head->nframes * op->cfsiz,
+			op->last_frames = kzalloc(array_size(msg_head->nframes, op->cfsiz),
 						  GFP_KERNEL);
 			if (!op->last_frames) {
 				kfree(op->frames);
diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
index 9645ffd6acfb..e69907f531da 100644
--- a/net/ceph/osdmap.c
+++ b/net/ceph/osdmap.c
@@ -1299,7 +1299,7 @@ static int set_primary_affinity(struct ceph_osdmap *map, int osd, u32 aff)
 	if (!map->osd_primary_affinity) {
 		int i;
 
-		map->osd_primary_affinity = kmalloc(map->max_osd*sizeof(u32),
+		map->osd_primary_affinity = kmalloc(array_size(map->max_osd, sizeof(u32)),
 						    GFP_NOFS);
 		if (!map->osd_primary_affinity)
 			return -ENOMEM;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f11086fa153f..0646c35e4b4e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1042,7 +1042,7 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 	if (info.cmd == ETHTOOL_GRXCLSRLALL) {
 		if (info.rule_cnt > 0) {
 			if (info.rule_cnt <= KMALLOC_MAX_SIZE / sizeof(u32))
-				rule_buf = kzalloc(info.rule_cnt * sizeof(u32),
+				rule_buf = kzalloc(array_size(info.rule_cnt, sizeof(u32)),
 						   GFP_USER);
 			if (!rule_buf)
 				return -ENOMEM;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index f05afaf3235c..6fdea81c6ae6 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -563,7 +563,7 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 		struct nlattr *mx;
 		int len = 0;
 
-		mx = kzalloc(3 * nla_total_size(4), GFP_KERNEL);
+		mx = kzalloc(array_size(3, nla_total_size(4)), GFP_KERNEL);
 		if (!mx)
 			return -ENOMEM;
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 11f9cfc016d9..b2158c392fd2 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1803,8 +1803,8 @@ static int ieee80211_reconfig_nan(struct ieee80211_sub_if_data *sdata)
 	if (WARN_ON(res))
 		return res;
 
-	funcs = kzalloc((sdata->local->hw.max_nan_de_entries + 1) *
-			sizeof(*funcs), GFP_KERNEL);
+	funcs = kzalloc(array_size((sdata->local->hw.max_nan_de_entries + 1), sizeof(*funcs)),
+			GFP_KERNEL);
 	if (!funcs)
 		return -ENOMEM;
 
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index b63d2a3d80ba..1de43cccf5a4 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -165,7 +165,7 @@ static int __init dccp_mt_init(void)
 	/* doff is 8 bits, so the maximum option size is (4*256).  Don't put
 	 * this in BSS since DaveM is worried about locked TLB's for kernel
 	 * BSS. */
-	dccp_optbuf = kmalloc(256 * 4, GFP_KERNEL);
+	dccp_optbuf = kmalloc(array_size(256, 4), GFP_KERNEL);
 	if (!dccp_optbuf)
 		return -ENOMEM;
 	ret = xt_register_matches(dccp_mt_reg, ARRAY_SIZE(dccp_mt_reg));
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index b9ce82c9440f..14d81a8a6da7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -352,8 +352,8 @@ int genl_register_family(struct genl_family *family)
 	}
 
 	if (family->maxattr && !family->parallel_ops) {
-		family->attrbuf = kmalloc((family->maxattr+1) *
-					sizeof(struct nlattr *), GFP_KERNEL);
+		family->attrbuf = kmalloc(array_size((family->maxattr + 1), sizeof(struct nlattr *)),
+					  GFP_KERNEL);
 		if (family->attrbuf == NULL) {
 			err = -ENOMEM;
 			goto errout_locked;
@@ -566,8 +566,8 @@ static int genl_family_rcv_msg(const struct genl_family *family,
 		return -EOPNOTSUPP;
 
 	if (family->maxattr && family->parallel_ops) {
-		attrbuf = kmalloc((family->maxattr+1) *
-					sizeof(struct nlattr *), GFP_KERNEL);
+		attrbuf = kmalloc(array_size((family->maxattr + 1), sizeof(struct nlattr *)),
+				  GFP_KERNEL);
 		if (attrbuf == NULL)
 			return -ENOMEM;
 	} else
diff --git a/net/rds/ib.c b/net/rds/ib.c
index 02deee29e7f1..2a6c2817df4b 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -163,7 +163,7 @@ static void rds_ib_add_one(struct ib_device *device)
 	rds_ibdev->max_initiator_depth = device->attrs.max_qp_init_rd_atom;
 	rds_ibdev->max_responder_resources = device->attrs.max_qp_rd_atom;
 
-	rds_ibdev->vector_load = kzalloc(sizeof(int) * device->num_comp_vectors,
+	rds_ibdev->vector_load = kzalloc(array_size(sizeof(int), device->num_comp_vectors),
 					 GFP_KERNEL);
 	if (!rds_ibdev->vector_load) {
 		pr_err("RDS/IB: %s failed to allocate vector memory\n",
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 22fa13cf5d8b..22e2745b853d 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -489,11 +489,12 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt,
 		return err;
 
 	if (!q->flows) {
-		q->flows = kvzalloc(q->flows_cnt *
-					   sizeof(struct fq_codel_flow), GFP_KERNEL);
+		q->flows = kvzalloc(array_size(q->flows_cnt, sizeof(struct fq_codel_flow)),
+				    GFP_KERNEL);
 		if (!q->flows)
 			return -ENOMEM;
-		q->backlogs = kvzalloc(q->flows_cnt * sizeof(u32), GFP_KERNEL);
+		q->backlogs = kvzalloc(array_size(q->flows_cnt, sizeof(u32)),
+				       GFP_KERNEL);
 		if (!q->backlogs)
 			return -ENOMEM;
 		for (i = 0; i < q->flows_cnt; i++) {
diff --git a/net/smc/smc_wr.c b/net/smc/smc_wr.c
index 1b8af23e6e2b..ce23302d3bce 100644
--- a/net/smc/smc_wr.c
+++ b/net/smc/smc_wr.c
@@ -583,9 +583,8 @@ int smc_wr_alloc_link_mem(struct smc_link *link)
 				   GFP_KERNEL);
 	if (!link->wr_rx_sges)
 		goto no_mem_wr_tx_sges;
-	link->wr_tx_mask = kzalloc(
-		BITS_TO_LONGS(SMC_WR_BUF_CNT) * sizeof(*link->wr_tx_mask),
-		GFP_KERNEL);
+	link->wr_tx_mask = kzalloc(array_size(BITS_TO_LONGS(SMC_WR_BUF_CNT), sizeof(*link->wr_tx_mask)),
+				   GFP_KERNEL);
 	if (!link->wr_tx_mask)
 		goto no_mem_wr_rx_sges;
 	link->wr_tx_pends = kcalloc(SMC_WR_BUF_CNT,
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 9463af4b32e8..bb4857075a31 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1753,8 +1753,8 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 	last = (snd_buf->page_base + snd_buf->page_len - 1) >> PAGE_SHIFT;
 	rqstp->rq_enc_pages_num = last - first + 1 + 1;
 	rqstp->rq_enc_pages
-		= kmalloc(rqstp->rq_enc_pages_num * sizeof(struct page *),
-				GFP_NOFS);
+		= kmalloc(array_size(rqstp->rq_enc_pages_num, sizeof(struct page *)),
+			  GFP_NOFS);
 	if (!rqstp->rq_enc_pages)
 		goto out;
 	for (i=0; i < rqstp->rq_enc_pages_num; i++) {
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 8654494b4d0a..5859a6e64acd 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -682,7 +682,7 @@ gss_krb5_cts_crypt(struct crypto_skcipher *cipher, struct xdr_buf *buf,
 		WARN_ON(0);
 		return -ENOMEM;
 	}
-	data = kmalloc(GSS_KRB5_MAX_BLOCKSIZE * 2, GFP_NOFS);
+	data = kmalloc(array_size(GSS_KRB5_MAX_BLOCKSIZE, 2), GFP_NOFS);
 	if (!data)
 		return -ENOMEM;
 
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 46b295e4f2b8..1b6375bac18a 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -224,7 +224,8 @@ static void gssp_free_receive_pages(struct gssx_arg_accept_sec_context *arg)
 static int gssp_alloc_receive_pages(struct gssx_arg_accept_sec_context *arg)
 {
 	arg->npages = DIV_ROUND_UP(NGROUPS_MAX * 4, PAGE_SIZE);
-	arg->pages = kzalloc(arg->npages * sizeof(struct page *), GFP_KERNEL);
+	arg->pages = kzalloc(array_size(arg->npages, sizeof(struct page *)),
+			     GFP_KERNEL);
 	/*
 	 * XXX: actual pages are allocated by xdr layer in
 	 * xdr_partial_copy_from_skb.
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index cdda4744c9b1..27a5bbb8e880 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1683,7 +1683,7 @@ struct cache_detail *cache_create_net(const struct cache_detail *tmpl, struct ne
 	if (cd == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	cd->hash_table = kzalloc(cd->hash_size * sizeof(struct hlist_head),
+	cd->hash_table = kzalloc(array_size(cd->hash_size, sizeof(struct hlist_head)),
 				 GFP_KERNEL);
 	if (cd->hash_table == NULL) {
 		kfree(cd);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 4492cda45566..7544e3efec02 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -285,8 +285,8 @@ static int __tipc_nl_compat_doit(struct tipc_nl_compat_cmd_doit *cmd,
 	if (!trans_buf)
 		return -ENOMEM;
 
-	attrbuf = kmalloc((tipc_genl_family.maxattr + 1) *
-			sizeof(struct nlattr *), GFP_KERNEL);
+	attrbuf = kmalloc(array_size((tipc_genl_family.maxattr + 1), sizeof(struct nlattr *)),
+			  GFP_KERNEL);
 	if (!attrbuf) {
 		err = -ENOMEM;
 		goto trans_out;
diff --git a/security/keys/trusted.c b/security/keys/trusted.c
index 423776682025..a4b1f4f94ea8 100644
--- a/security/keys/trusted.c
+++ b/security/keys/trusted.c
@@ -1148,7 +1148,7 @@ static long trusted_read(const struct key *key, char __user *buffer,
 		return -EINVAL;
 
 	if (buffer && buflen >= 2 * p->blob_len) {
-		ascii_buf = kmalloc(2 * p->blob_len, GFP_KERNEL);
+		ascii_buf = kmalloc(array_size(2, p->blob_len), GFP_KERNEL);
 		if (!ascii_buf)
 			return -ENOMEM;
 
diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
index 0e875d5a9e86..ce5ca784b7f2 100644
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -3093,7 +3093,7 @@ static ssize_t snd_pcm_readv(struct kiocb *iocb, struct iov_iter *to)
 	if (!frame_aligned(runtime, to->iov->iov_len))
 		return -EINVAL;
 	frames = bytes_to_samples(runtime, to->iov->iov_len);
-	bufs = kmalloc(sizeof(void *) * to->nr_segs, GFP_KERNEL);
+	bufs = kmalloc(array_size(sizeof(void *), to->nr_segs), GFP_KERNEL);
 	if (bufs == NULL)
 		return -ENOMEM;
 	for (i = 0; i < to->nr_segs; ++i)
@@ -3128,7 +3128,7 @@ static ssize_t snd_pcm_writev(struct kiocb *iocb, struct iov_iter *from)
 	    !frame_aligned(runtime, from->iov->iov_len))
 		return -EINVAL;
 	frames = bytes_to_samples(runtime, from->iov->iov_len);
-	bufs = kmalloc(sizeof(void *) * from->nr_segs, GFP_KERNEL);
+	bufs = kmalloc(array_size(sizeof(void *), from->nr_segs), GFP_KERNEL);
 	if (bufs == NULL)
 		return -ENOMEM;
 	for (i = 0; i < from->nr_segs; ++i)
diff --git a/sound/firewire/dice/dice-transaction.c b/sound/firewire/dice/dice-transaction.c
index 0f0350320ae8..ae7c1ac80207 100644
--- a/sound/firewire/dice/dice-transaction.c
+++ b/sound/firewire/dice/dice-transaction.c
@@ -170,7 +170,7 @@ static int register_notification_address(struct snd_dice *dice, bool retry)
 
 	retries = (retry) ? 3 : 0;
 
-	buffer = kmalloc(2 * 8, GFP_KERNEL);
+	buffer = kmalloc(array_size(2, 8), GFP_KERNEL);
 	if (!buffer)
 		return -ENOMEM;
 
@@ -220,7 +220,7 @@ static void unregister_notification_address(struct snd_dice *dice)
 	struct fw_device *device = fw_parent_device(dice->unit);
 	__be64 *buffer;
 
-	buffer = kmalloc(2 * 8, GFP_KERNEL);
+	buffer = kmalloc(array_size(2, 8), GFP_KERNEL);
 	if (buffer == NULL)
 		return;
 
diff --git a/sound/pci/cs46xx/cs46xx_lib.c b/sound/pci/cs46xx/cs46xx_lib.c
index 0020fd0efc46..314c7bf81429 100644
--- a/sound/pci/cs46xx/cs46xx_lib.c
+++ b/sound/pci/cs46xx/cs46xx_lib.c
@@ -460,7 +460,7 @@ static int load_firmware(struct snd_cs46xx *chip,
 		entry->size = le32_to_cpu(fwdat[fwlen++]);
 		if (fwlen + entry->size > fwsize)
 			goto error_inval;
-		entry->data = kmalloc(entry->size * 4, GFP_KERNEL);
+		entry->data = kmalloc(array_size(entry->size, 4), GFP_KERNEL);
 		if (!entry->data)
 			goto error;
 		memcpy_le32(entry->data, &fwdat[fwlen], entry->size * 4);
@@ -4036,8 +4036,8 @@ int snd_cs46xx_create(struct snd_card *card,
 	snd_cs46xx_proc_init(card, chip);
 
 #ifdef CONFIG_PM_SLEEP
-	chip->saved_regs = kmalloc(sizeof(*chip->saved_regs) *
-				   ARRAY_SIZE(saved_regs), GFP_KERNEL);
+	chip->saved_regs = kmalloc(array_size(sizeof(*chip->saved_regs), ARRAY_SIZE(saved_regs)),
+				   GFP_KERNEL);
 	if (!chip->saved_regs) {
 		snd_cs46xx_free(chip);
 		return -ENOMEM;
diff --git a/sound/pci/ctxfi/ctatc.c b/sound/pci/ctxfi/ctatc.c
index 6fd0e030615d..33b9038adbe9 100644
--- a/sound/pci/ctxfi/ctatc.c
+++ b/sound/pci/ctxfi/ctatc.c
@@ -1397,7 +1397,7 @@ static int atc_get_resources(struct ct_atc *atc)
 	if (!atc->srcimps)
 		return -ENOMEM;
 
-	atc->pcm = kzalloc(sizeof(void *)*(2*4), GFP_KERNEL);
+	atc->pcm = kzalloc(array_size(sizeof(void *), (2 * 4)), GFP_KERNEL);
 	if (!atc->pcm)
 		return -ENOMEM;
 
diff --git a/sound/pci/ctxfi/ctdaio.c b/sound/pci/ctxfi/ctdaio.c
index 7f089cb433e1..f35a7341e446 100644
--- a/sound/pci/ctxfi/ctdaio.c
+++ b/sound/pci/ctxfi/ctdaio.c
@@ -398,7 +398,8 @@ static int dao_rsc_init(struct dao *dao,
 	if (err)
 		return err;
 
-	dao->imappers = kzalloc(sizeof(void *)*desc->msr*2, GFP_KERNEL);
+	dao->imappers = kzalloc(array3_size(sizeof(void *), desc->msr, 2),
+				GFP_KERNEL);
 	if (!dao->imappers) {
 		err = -ENOMEM;
 		goto error1;
diff --git a/sound/pci/ctxfi/ctmixer.c b/sound/pci/ctxfi/ctmixer.c
index 4f4a2a5dedb8..e47067d05171 100644
--- a/sound/pci/ctxfi/ctmixer.c
+++ b/sound/pci/ctxfi/ctmixer.c
@@ -910,13 +910,14 @@ static int ct_mixer_get_mem(struct ct_mixer **rmixer)
 	if (!mixer)
 		return -ENOMEM;
 
-	mixer->amixers = kzalloc(sizeof(void *)*(NUM_CT_AMIXERS*CHN_NUM),
+	mixer->amixers = kzalloc(array_size(sizeof(void *), (NUM_CT_AMIXERS * CHN_NUM)),
 				 GFP_KERNEL);
 	if (!mixer->amixers) {
 		err = -ENOMEM;
 		goto error1;
 	}
-	mixer->sums = kzalloc(sizeof(void *)*(NUM_CT_SUMS*CHN_NUM), GFP_KERNEL);
+	mixer->sums = kzalloc(array_size(sizeof(void *), (NUM_CT_SUMS * CHN_NUM)),
+			      GFP_KERNEL);
 	if (!mixer->sums) {
 		err = -ENOMEM;
 		goto error2;
diff --git a/sound/pci/ctxfi/ctsrc.c b/sound/pci/ctxfi/ctsrc.c
index bb4c9c3c89ae..4931fb382045 100644
--- a/sound/pci/ctxfi/ctsrc.c
+++ b/sound/pci/ctxfi/ctsrc.c
@@ -679,7 +679,7 @@ static int srcimp_rsc_init(struct srcimp *srcimp,
 		return err;
 
 	/* Reserve memory for imapper nodes */
-	srcimp->imappers = kzalloc(sizeof(struct imapper)*desc->msr,
+	srcimp->imappers = kzalloc(array_size(sizeof(struct imapper), desc->msr),
 				   GFP_KERNEL);
 	if (!srcimp->imappers) {
 		err = -ENOMEM;
diff --git a/sound/pci/emu10k1/emufx.c b/sound/pci/emu10k1/emufx.c
index a2b56b188be4..f31971b6fce7 100644
--- a/sound/pci/emu10k1/emufx.c
+++ b/sound/pci/emu10k1/emufx.c
@@ -2690,12 +2690,12 @@ int snd_emu10k1_efx_alloc_pm_buffer(struct snd_emu10k1 *emu)
 	int len;
 
 	len = emu->audigy ? 0x200 : 0x100;
-	emu->saved_gpr = kmalloc(len * 4, GFP_KERNEL);
+	emu->saved_gpr = kmalloc(array_size(len, 4), GFP_KERNEL);
 	if (! emu->saved_gpr)
 		return -ENOMEM;
 	len = emu->audigy ? 0x100 : 0xa0;
-	emu->tram_val_saved = kmalloc(len * 4, GFP_KERNEL);
-	emu->tram_addr_saved = kmalloc(len * 4, GFP_KERNEL);
+	emu->tram_val_saved = kmalloc(array_size(len, 4), GFP_KERNEL);
+	emu->tram_addr_saved = kmalloc(array_size(len, 4), GFP_KERNEL);
 	if (! emu->tram_val_saved || ! emu->tram_addr_saved)
 		return -ENOMEM;
 	len = emu->audigy ? 2 * 1024 : 2 * 512;
diff --git a/sound/pci/hda/hda_codec.c b/sound/pci/hda/hda_codec.c
index acce4219e234..956071137057 100644
--- a/sound/pci/hda/hda_codec.c
+++ b/sound/pci/hda/hda_codec.c
@@ -439,7 +439,8 @@ static int read_widget_caps(struct hda_codec *codec, hda_nid_t fg_node)
 	int i;
 	hda_nid_t nid;
 
-	codec->wcaps = kmalloc(codec->core.num_nodes * 4, GFP_KERNEL);
+	codec->wcaps = kmalloc(array_size(codec->core.num_nodes, 4),
+			       GFP_KERNEL);
 	if (!codec->wcaps)
 		return -ENOMEM;
 	nid = codec->core.start_nid;
diff --git a/sound/soc/codecs/wm8904.c b/sound/soc/codecs/wm8904.c
index 20fdcae06c6b..ce5f8d4ac767 100644
--- a/sound/soc/codecs/wm8904.c
+++ b/sound/soc/codecs/wm8904.c
@@ -2023,8 +2023,8 @@ static void wm8904_handle_pdata(struct snd_soc_component *component)
 				     wm8904_get_drc_enum, wm8904_put_drc_enum);
 
 		/* We need an array of texts for the enum API */
-		wm8904->drc_texts = kmalloc(sizeof(char *)
-					    * pdata->num_drc_cfgs, GFP_KERNEL);
+		wm8904->drc_texts = kmalloc(array_size(sizeof(char *), pdata->num_drc_cfgs),
+				            GFP_KERNEL);
 		if (!wm8904->drc_texts)
 			return;
 
diff --git a/sound/soc/codecs/wm8958-dsp2.c b/sound/soc/codecs/wm8958-dsp2.c
index 8d495220fa25..df77636f3113 100644
--- a/sound/soc/codecs/wm8958-dsp2.c
+++ b/sound/soc/codecs/wm8958-dsp2.c
@@ -932,8 +932,8 @@ void wm8958_dsp2_init(struct snd_soc_component *component)
 		};
 
 		/* We need an array of texts for the enum API */
-		wm8994->mbc_texts = kmalloc(sizeof(char *)
-					    * pdata->num_mbc_cfgs, GFP_KERNEL);
+		wm8994->mbc_texts = kmalloc(array_size(sizeof(char *), pdata->num_mbc_cfgs),
+					    GFP_KERNEL);
 		if (!wm8994->mbc_texts)
 			return;
 
@@ -957,8 +957,8 @@ void wm8958_dsp2_init(struct snd_soc_component *component)
 		};
 
 		/* We need an array of texts for the enum API */
-		wm8994->vss_texts = kmalloc(sizeof(char *)
-					    * pdata->num_vss_cfgs, GFP_KERNEL);
+		wm8994->vss_texts = kmalloc(array_size(sizeof(char *), pdata->num_vss_cfgs),
+					    GFP_KERNEL);
 		if (!wm8994->vss_texts)
 			return;
 
@@ -983,8 +983,8 @@ void wm8958_dsp2_init(struct snd_soc_component *component)
 		};
 
 		/* We need an array of texts for the enum API */
-		wm8994->vss_hpf_texts = kmalloc(sizeof(char *)
-						* pdata->num_vss_hpf_cfgs, GFP_KERNEL);
+		wm8994->vss_hpf_texts = kmalloc(array_size(sizeof(char *), pdata->num_vss_hpf_cfgs),
+						GFP_KERNEL);
 		if (!wm8994->vss_hpf_texts)
 			return;
 
@@ -1010,8 +1010,8 @@ void wm8958_dsp2_init(struct snd_soc_component *component)
 		};
 
 		/* We need an array of texts for the enum API */
-		wm8994->enh_eq_texts = kmalloc(sizeof(char *)
-						* pdata->num_enh_eq_cfgs, GFP_KERNEL);
+		wm8994->enh_eq_texts = kmalloc(array_size(sizeof(char *), pdata->num_enh_eq_cfgs),
+					       GFP_KERNEL);
 		if (!wm8994->enh_eq_texts)
 			return;
 
diff --git a/sound/soc/codecs/wm_adsp.c b/sound/soc/codecs/wm_adsp.c
index 82b0927e6ed7..9675edabefb9 100644
--- a/sound/soc/codecs/wm_adsp.c
+++ b/sound/soc/codecs/wm_adsp.c
@@ -1900,7 +1900,7 @@ static void *wm_adsp_read_algs(struct wm_adsp *dsp, size_t n_algs,
 		adsp_warn(dsp, "Algorithm list end %x 0x%x != 0xbedead\n",
 			  pos + len, be32_to_cpu(val));
 
-	alg = kzalloc(len * 2, GFP_KERNEL | GFP_DMA);
+	alg = kzalloc(array_size(len, 2), GFP_KERNEL | GFP_DMA);
 	if (!alg)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/sound/soc/soc-core.c b/sound/soc/soc-core.c
index bf7ca32ab31f..ae5d7f515697 100644
--- a/sound/soc/soc-core.c
+++ b/sound/soc/soc-core.c
@@ -570,9 +570,8 @@ static struct snd_soc_pcm_runtime *soc_new_pcm_runtime(
 	if (!rtd->dai_link->ops)
 		rtd->dai_link->ops = &null_snd_soc_ops;
 
-	rtd->codec_dais = kzalloc(sizeof(struct snd_soc_dai *) *
-					dai_link->num_codecs,
-					GFP_KERNEL);
+	rtd->codec_dais = kzalloc(array_size(sizeof(struct snd_soc_dai *), dai_link->num_codecs),
+				  GFP_KERNEL);
 	if (!rtd->codec_dais) {
 		kfree(rtd);
 		return NULL;
diff --git a/sound/soc/soc-dapm.c b/sound/soc/soc-dapm.c
index fadf9896bf2c..1fdbe6aa4b51 100644
--- a/sound/soc/soc-dapm.c
+++ b/sound/soc/soc-dapm.c
@@ -3057,9 +3057,8 @@ int snd_soc_dapm_new_widgets(struct snd_soc_card *card)
 			continue;
 
 		if (w->num_kcontrols) {
-			w->kcontrols = kzalloc(w->num_kcontrols *
-						sizeof(struct snd_kcontrol *),
-						GFP_KERNEL);
+			w->kcontrols = kzalloc(array_size(w->num_kcontrols, sizeof(struct snd_kcontrol *)),
+					       GFP_KERNEL);
 			if (!w->kcontrols) {
 				mutex_unlock(&card->dapm_mutex);
 				return -ENOMEM;
diff --git a/sound/soc/soc-topology.c b/sound/soc/soc-topology.c
index 986b8b2f90fb..be5398010d2b 100644
--- a/sound/soc/soc-topology.c
+++ b/sound/soc/soc-topology.c
@@ -941,7 +941,7 @@ static int soc_tplg_denum_create_texts(struct soc_enum *se,
 	int i, ret;
 
 	se->dobj.control.dtexts =
-		kzalloc(sizeof(char *) * ec->items, GFP_KERNEL);
+		kzalloc(array_size(sizeof(char *), ec->items), GFP_KERNEL);
 	if (se->dobj.control.dtexts == NULL)
 		return -ENOMEM;
 
diff --git a/sound/usb/format.c b/sound/usb/format.c
index ba7c14e20b37..c38a3290d2d8 100644
--- a/sound/usb/format.c
+++ b/sound/usb/format.c
@@ -363,7 +363,8 @@ static int parse_audio_format_rates_v2v3(struct snd_usb_audio *chip,
 		goto err_free;
 	}
 
-	fp->rate_table = kmalloc(sizeof(int) * fp->nr_rates, GFP_KERNEL);
+	fp->rate_table = kmalloc(array_size(sizeof(int), fp->nr_rates),
+				 GFP_KERNEL);
 	if (!fp->rate_table) {
 		ret = -ENOMEM;
 		goto err_free;
diff --git a/sound/usb/line6/capture.c b/sound/usb/line6/capture.c
index 947d6168f24a..69f5cb7eb3cf 100644
--- a/sound/usb/line6/capture.c
+++ b/sound/usb/line6/capture.c
@@ -264,8 +264,8 @@ int line6_create_audio_in_urbs(struct snd_line6_pcm *line6pcm)
 	struct usb_line6 *line6 = line6pcm->line6;
 	int i;
 
-	line6pcm->in.urbs = kzalloc(
-		sizeof(struct urb *) * line6->iso_buffers, GFP_KERNEL);
+	line6pcm->in.urbs = kzalloc(array_size(sizeof(struct urb *), line6->iso_buffers),
+				    GFP_KERNEL);
 	if (line6pcm->in.urbs == NULL)
 		return -ENOMEM;
 
diff --git a/sound/usb/line6/pcm.c b/sound/usb/line6/pcm.c
index b3854f8c0c67..8fd838ba9997 100644
--- a/sound/usb/line6/pcm.c
+++ b/sound/usb/line6/pcm.c
@@ -158,8 +158,8 @@ static int line6_buffer_acquire(struct snd_line6_pcm *line6pcm,
 
 	/* Invoked multiple times in a row so allocate once only */
 	if (!test_and_set_bit(type, &pstr->opened) && !pstr->buffer) {
-		pstr->buffer = kmalloc(line6pcm->line6->iso_buffers *
-				       LINE6_ISO_PACKETS * pkt_size, GFP_KERNEL);
+		pstr->buffer = kmalloc(array3_size(line6pcm->line6->iso_buffers, LINE6_ISO_PACKETS, pkt_size),
+				       GFP_KERNEL);
 		if (!pstr->buffer)
 			return -ENOMEM;
 	}
diff --git a/sound/usb/line6/playback.c b/sound/usb/line6/playback.c
index 819e9b2d1d6e..b5141f3e70b0 100644
--- a/sound/usb/line6/playback.c
+++ b/sound/usb/line6/playback.c
@@ -409,8 +409,8 @@ int line6_create_audio_out_urbs(struct snd_line6_pcm *line6pcm)
 	struct usb_line6 *line6 = line6pcm->line6;
 	int i;
 
-	line6pcm->out.urbs = kzalloc(
-		sizeof(struct urb *) * line6->iso_buffers, GFP_KERNEL);
+	line6pcm->out.urbs = kzalloc(array_size(sizeof(struct urb *), line6->iso_buffers),
+				     GFP_KERNEL);
 	if (line6pcm->out.urbs == NULL)
 		return -ENOMEM;
 
diff --git a/sound/usb/mixer.c b/sound/usb/mixer.c
index 344d7b069d59..f4b2cb293606 100644
--- a/sound/usb/mixer.c
+++ b/sound/usb/mixer.c
@@ -2330,7 +2330,8 @@ static int parse_audio_selector_unit(struct mixer_build *state, int unitid,
 		cval->control = (desc->bDescriptorSubtype == UAC2_CLOCK_SELECTOR) ?
 			UAC2_CX_CLOCK_SELECTOR : UAC2_SU_SELECTOR;
 
-	namelist = kmalloc(sizeof(char *) * desc->bNrInPins, GFP_KERNEL);
+	namelist = kmalloc(array_size(sizeof(char *), desc->bNrInPins),
+			   GFP_KERNEL);
 	if (!namelist) {
 		kfree(cval);
 		return -ENOMEM;
diff --git a/sound/usb/usx2y/usbusx2yaudio.c b/sound/usb/usx2y/usbusx2yaudio.c
index 6b662e0905c6..4067a367165e 100644
--- a/sound/usb/usx2y/usbusx2yaudio.c
+++ b/sound/usb/usx2y/usbusx2yaudio.c
@@ -436,7 +436,8 @@ static int usX2Y_urbs_allocate(struct snd_usX2Y_substream *subs)
 		}
 		if (!is_playback && !(*purb)->transfer_buffer) {
 			/* allocate a capture buffer per urb */
-			(*purb)->transfer_buffer = kmalloc(subs->maxpacksize * nr_of_packs(), GFP_KERNEL);
+			(*purb)->transfer_buffer = kmalloc(array_size(subs->maxpacksize, nr_of_packs()),
+							   GFP_KERNEL);
 			if (NULL == (*purb)->transfer_buffer) {
 				usX2Y_urbs_release(subs);
 				return -ENOMEM;
-- 
2.17.0
