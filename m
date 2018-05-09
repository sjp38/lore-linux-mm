Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 23EDA6B02FD
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b31-v6so2743043plb.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 184sor8303737pfg.112.2018.05.08.17.42.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:52 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 09/13] treewide: Use array_size() for kmalloc()-family
Date: Tue,  8 May 2018 17:42:25 -0700
Message-Id: <20180509004229.36341-10-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

For kmalloc()-family allocations, instead of A * B, use array_size().
Similarly,instead of A * B *C, use array3_size(). Automatically generated
using the following Coccinelle script:

// 2-factor product with sizeof(variable)
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP, THING;
identifier COUNT;
@@

- alloc(sizeof(THING) * COUNT, GFP)
+ alloc(array_size(COUNT, sizeof(THING)), GFP)

// 2-factor product with sizeof(type)
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
identifier COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * COUNT, GFP)
+ alloc(array_size(COUNT, sizeof(TYPE)), GFP)

// 2-factor product with sizeof(variable) and constant
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP, THING;
constant COUNT;
@@

- alloc(sizeof(THING) * COUNT, GFP)
+ alloc(array_size(COUNT, sizeof(THING)), GFP)

// 2-factor product with sizeof(type) and constant
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
constant COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * COUNT, GFP)
+ alloc(array_size(COUNT, sizeof(TYPE)), GFP)

// 3-factor product with 1 sizeof(variable)
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP, THING;
identifier STRIDE, COUNT;
@@

- alloc(sizeof(THING) * COUNT * STRIDE, GFP)
+ alloc(array3_size(COUNT, STRIDE, sizeof(THING)), GFP)

// 3-factor product with 2 sizeof(variable)
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP, THING1, THING2;
identifier COUNT;
@@

- alloc(sizeof(THING1) * sizeof(THING2) * COUNT, GFP)
+ alloc(array3_size(COUNT, sizeof(THING1), sizeof(THING2)), GFP)

// 3-factor product with 1 sizeof(type)
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
identifier STRIDE, COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * COUNT * STRIDE, GFP)
+ alloc(array3_size(COUNT, STRIDE, sizeof(TYPE)), GFP)

// 3-factor product with 2 sizeof(type)
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
identifier COUNT;
type TYPE1, TYPE2;
@@

- alloc(sizeof(TYPE1) * sizeof(TYPE2) * COUNT, GFP)
+ alloc(array3_size(COUNT, sizeof(TYPE1), sizeof(TYPE2)), GFP)

// 3-factor product with mixed sizeof() type/variable
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP, THING;
identifier COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * sizeof(THING) * COUNT, GFP)
+ alloc(array3_size(COUNT, sizeof(TYPE), sizeof(THING)), GFP)

// 2-factor product, only identifiers
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
identifier SIZE, COUNT;
@@

- alloc(SIZE * COUNT, GFP)
+ alloc(array_size(COUNT, SIZE), GFP)

// 3-factor product, only identifiers
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
identifier STRIDE, SIZE, COUNT;
@@

- alloc(COUNT * STRIDE * SIZE, GFP)
+ alloc(array3_size(COUNT, STRIDE, SIZE), GFP)
---
 arch/arm/kernel/sys_oabi-compat.c             |  4 +-
 arch/arm/mach-footbridge/dc21285.c            |  2 +-
 arch/arm/mach-ixp4xx/common-pci.c             |  2 +-
 arch/arm/mach-omap1/mcbsp.c                   |  2 +-
 arch/arm/mach-omap2/omap_device.c             |  5 +-
 arch/arm/mach-omap2/prm_common.c              | 10 ++--
 arch/arm/mach-vexpress/spc.c                  |  2 +-
 arch/arm/mm/dma-mapping.c                     |  4 +-
 arch/arm/mm/pgd.c                             |  2 +-
 arch/arm/probes/kprobes/test-core.c           |  4 +-
 arch/ia64/kernel/topology.c                   |  7 +--
 arch/ia64/sn/kernel/io_common.c               |  3 +-
 arch/ia64/sn/kernel/irq.c                     |  3 +-
 arch/mips/alchemy/common/dbdma.c              |  7 +--
 arch/mips/alchemy/common/platform.c           |  2 +-
 arch/mips/alchemy/devboards/platform.c        |  5 +-
 arch/mips/txx9/rbtx4939/setup.c               |  2 +-
 arch/powerpc/lib/rheap.c                      |  3 +-
 arch/powerpc/platforms/4xx/hsta_msi.c         |  3 +-
 arch/powerpc/platforms/4xx/pci.c              |  2 +-
 .../powerpc/platforms/powernv/opal-sysparam.c |  8 +--
 arch/powerpc/sysdev/mpic.c                    |  6 ++-
 arch/s390/appldata/appldata_base.c            |  3 +-
 arch/s390/kernel/debug.c                      |  6 ++-
 arch/s390/kernel/perf_cpum_cf_events.c        |  2 +-
 arch/s390/mm/extmem.c                         |  3 +-
 arch/sh/drivers/dma/dmabrg.c                  |  2 +-
 arch/sh/drivers/pci/pcie-sh7786.c             |  2 +-
 arch/sparc/kernel/nmi.c                       |  3 +-
 arch/sparc/net/bpf_jit_comp_32.c              |  2 +-
 arch/um/drivers/ubd_kern.c                    | 12 ++---
 arch/um/drivers/vector_user.c                 |  4 +-
 arch/um/os-Linux/sigio.c                      |  2 +-
 arch/x86/events/core.c                        |  2 +-
 arch/x86/kernel/cpu/mcheck/mce.c              |  3 +-
 arch/x86/kernel/cpu/mtrr/if.c                 |  2 +-
 arch/x86/kernel/hpet.c                        |  3 +-
 arch/x86/kernel/ksysfs.c                      |  2 +-
 arch/x86/kvm/page_track.c                     |  4 +-
 arch/x86/kvm/x86.c                            |  6 ++-
 arch/x86/platform/uv/tlb_uv.c                 |  3 +-
 arch/x86/platform/uv/uv_time.c                |  3 +-
 block/bio.c                                   |  3 +-
 block/blk-tag.c                               |  6 ++-
 block/partitions/ldm.c                        |  2 +-
 drivers/acpi/acpi_platform.c                  |  2 +-
 drivers/acpi/apei/erst.c                      |  3 +-
 drivers/acpi/apei/hest.c                      |  3 +-
 drivers/ata/libata-core.c                     |  3 +-
 drivers/ata/libata-pmp.c                      |  2 +-
 drivers/atm/fore200e.c                        |  3 +-
 drivers/auxdisplay/cfag12864b.c               |  4 +-
 drivers/block/drbd/drbd_main.c                |  3 +-
 drivers/block/loop.c                          |  3 +-
 drivers/block/null_blk.c                      |  3 +-
 drivers/block/ps3vram.c                       |  4 +-
 drivers/block/xen-blkfront.c                  |  8 +--
 drivers/cdrom/cdrom.c                         |  3 +-
 drivers/char/agp/isoch.c                      |  2 +-
 drivers/char/agp/sgi-agp.c                    |  3 +-
 drivers/char/virtio_console.c                 | 12 +++--
 drivers/clk/renesas/clk-r8a7740.c             |  2 +-
 drivers/clk/renesas/clk-r8a7779.c             |  2 +-
 drivers/clk/renesas/clk-rcar-gen2.c           |  2 +-
 drivers/clk/renesas/clk-rz.c                  |  2 +-
 drivers/clk/rockchip/clk-rockchip.c           |  3 +-
 drivers/clk/st/clkgen-fsyn.c                  |  2 +-
 drivers/clk/tegra/clk.c                       |  2 +-
 drivers/cpufreq/arm_big_little.c              |  2 +-
 drivers/cpufreq/s3c24xx-cpufreq.c             |  2 +-
 drivers/crypto/amcc/crypto4xx_core.c          |  4 +-
 drivers/crypto/chelsio/chtls/chtls_io.c       |  3 +-
 drivers/crypto/n2_core.c                      |  4 +-
 drivers/dma/bestcomm/bestcomm.c               |  3 +-
 drivers/dma/ioat/init.c                       |  4 +-
 drivers/dma/mv_xor.c                          |  4 +-
 drivers/dma/pl330.c                           |  3 +-
 drivers/dma/xilinx/zynqmp_dma.c               |  2 +-
 drivers/extcon/extcon.c                       |  4 +-
 drivers/firewire/core-iso.c                   |  2 +-
 drivers/firewire/net.c                        |  2 +-
 drivers/firmware/dell_rbu.c                   |  4 +-
 drivers/firmware/efi/capsule.c                |  3 +-
 drivers/fmc/fmc-sdb.c                         |  6 ++-
 drivers/gpio/gpio-ml-ioh.c                    |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_acp.c       | 10 ++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_test.c      |  2 +-
 drivers/gpu/drm/amd/amdgpu/ci_dpm.c           |  3 +-
 drivers/gpu/drm/amd/amdgpu/si_dpm.c           |  3 +-
 .../amd/display/amdgpu_dm/amdgpu_dm_helpers.c |  2 +-
 .../gpu/drm/amd/display/dc/basics/logger.c    |  2 +-
 .../gpu/drm/amd/display/dc/basics/vector.c    |  6 ++-
 .../drm/amd/display/dc/gpio/gpio_service.c    |  2 +-
 .../amd/display/modules/freesync/freesync.c   |  4 +-
 drivers/gpu/drm/amd/powerplay/hwmgr/pp_psm.c  |  2 +-
 drivers/gpu/drm/i915/gvt/vgpu.c               |  2 +-
 drivers/gpu/drm/i915/intel_hdcp.c             |  3 +-
 drivers/gpu/drm/nouveau/nvkm/core/event.c     |  2 +-
 .../drm/nouveau/nvkm/subdev/bios/iccsense.c   |  3 +-
 .../gpu/drm/nouveau/nvkm/subdev/fb/ramgt215.c |  2 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/mem.c |  4 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c |  3 +-
 drivers/gpu/drm/omapdrm/omap_dmm_tiler.c      |  2 +-
 drivers/gpu/drm/omapdrm/omap_gem.c            |  6 ++-
 drivers/gpu/drm/radeon/btc_dpm.c              |  3 +-
 drivers/gpu/drm/radeon/ci_dpm.c               |  3 +-
 drivers/gpu/drm/radeon/ni_dpm.c               |  3 +-
 drivers/gpu/drm/radeon/radeon_atombios.c      |  9 ++--
 drivers/gpu/drm/radeon/radeon_combios.c       |  9 ++--
 drivers/gpu/drm/radeon/radeon_test.c          |  2 +-
 drivers/gpu/drm/radeon/si_dpm.c               |  3 +-
 drivers/gpu/drm/tegra/fb.c                    |  3 +-
 drivers/gpu/drm/ttm/ttm_page_alloc.c          |  5 +-
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c      |  5 +-
 drivers/hid/hid-core.c                        |  2 +-
 drivers/hid/hid-debug.c                       |  7 +--
 drivers/hid/hidraw.c                          |  2 +-
 drivers/hv/hv.c                               |  2 +-
 drivers/hwmon/coretemp.c                      |  2 +-
 drivers/hwmon/i5k_amb.c                       |  4 +-
 drivers/i2c/busses/i2c-amd756-s4882.c         |  6 +--
 drivers/i2c/busses/i2c-nforce2-s4985.c        |  6 ++-
 drivers/i2c/busses/i2c-nforce2.c              |  3 +-
 drivers/i2c/i2c-dev.c                         |  3 +-
 drivers/ide/it821x.c                          |  2 +-
 drivers/infiniband/core/fmr_pool.c            |  2 +-
 drivers/infiniband/core/iwpm_util.c           |  8 +--
 drivers/infiniband/hw/cxgb3/cxio_hal.c        |  6 ++-
 drivers/infiniband/hw/cxgb4/device.c          |  3 +-
 drivers/infiniband/hw/hns/hns_roce_hw_v2.c    |  2 +-
 drivers/infiniband/hw/mlx4/mad.c              |  2 +-
 drivers/infiniband/hw/mlx4/main.c             |  6 ++-
 drivers/infiniband/hw/mlx5/srq.c              |  2 +-
 drivers/infiniband/hw/mthca/mthca_allocator.c | 11 ++--
 drivers/infiniband/hw/mthca/mthca_eq.c        |  4 +-
 drivers/infiniband/hw/mthca/mthca_mr.c        |  3 +-
 drivers/infiniband/hw/mthca/mthca_profile.c   |  3 +-
 drivers/infiniband/hw/nes/nes_mgt.c           |  3 +-
 drivers/infiniband/hw/nes/nes_nic.c           |  2 +-
 drivers/infiniband/hw/nes/nes_verbs.c         |  4 +-
 drivers/infiniband/hw/ocrdma/ocrdma_hw.c      |  3 +-
 drivers/infiniband/hw/ocrdma/ocrdma_main.c    | 11 ++--
 drivers/infiniband/hw/qedr/main.c             |  4 +-
 drivers/infiniband/hw/qib/qib_iba7322.c       | 16 +++---
 drivers/infiniband/hw/usnic/usnic_vnic.c      |  3 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c     |  6 +--
 drivers/infiniband/ulp/isert/ib_isert.c       |  4 +-
 drivers/infiniband/ulp/srpt/ib_srpt.c         |  2 +-
 drivers/input/joystick/joydump.c              |  3 +-
 drivers/input/keyboard/omap4-keypad.c         |  2 +-
 drivers/iommu/dmar.c                          |  3 +-
 drivers/iommu/intel-iommu.c                   |  7 +--
 drivers/ipack/carriers/tpci200.c              |  4 +-
 drivers/irqchip/irq-gic-v3-its.c              | 11 ++--
 drivers/irqchip/irq-gic-v3.c                  |  5 +-
 drivers/irqchip/irq-s3c24xx.c                 |  2 +-
 drivers/isdn/capi/capi.c                      |  2 +-
 drivers/isdn/gigaset/common.c                 |  5 +-
 drivers/isdn/hardware/avm/b1.c                |  3 +-
 drivers/isdn/hisax/hfc_2bds0.c                |  2 +-
 drivers/isdn/hisax/hfc_2bs0.c                 |  2 +-
 drivers/isdn/hisax/netjet.c                   |  6 +--
 drivers/isdn/i4l/isdn_common.c                |  6 +--
 drivers/mailbox/pcc.c                         |  4 +-
 drivers/md/dm-integrity.c                     |  3 +-
 drivers/md/dm-snap.c                          |  4 +-
 drivers/md/dm-table.c                         |  2 +-
 drivers/md/md-bitmap.c                        |  6 +--
 drivers/md/raid10.c                           |  3 +-
 drivers/md/raid5.c                            | 11 ++--
 drivers/media/dvb-frontends/dib7000p.c        |  4 +-
 drivers/media/dvb-frontends/dib8000.c         |  6 ++-
 drivers/media/dvb-frontends/dib9000.c         |  6 ++-
 drivers/media/pci/ivtv/ivtvfb.c               |  3 +-
 drivers/media/usb/au0828/au0828-video.c       |  7 +--
 drivers/media/usb/cpia2/cpia2_usb.c           |  3 +-
 drivers/media/usb/cx231xx/cx231xx-core.c      |  8 +--
 drivers/media/usb/cx231xx/cx231xx-vbi.c       |  4 +-
 drivers/media/usb/go7007/go7007-usb.c         |  3 +-
 drivers/media/usb/pvrusb2/pvrusb2-std.c       |  2 +-
 drivers/media/usb/stk1160/stk1160-video.c     |  7 +--
 drivers/media/usb/stkwebcam/stk-webcam.c      |  4 +-
 drivers/media/usb/tm6000/tm6000-video.c       | 13 +++--
 drivers/media/usb/usbtv/usbtv-video.c         |  4 +-
 drivers/memstick/core/ms_block.c              |  3 +-
 drivers/mfd/timberdale.c                      |  4 +-
 drivers/misc/altera-stapl/altera.c            |  9 ++--
 drivers/misc/cxl/guest.c                      |  3 +-
 drivers/misc/cxl/of.c                         |  2 +-
 drivers/misc/sgi-xp/xpc_main.c                |  6 +--
 drivers/misc/sgi-xp/xpc_partition.c           |  2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c       |  6 ++-
 drivers/mtd/ar7part.c                         |  3 +-
 drivers/mtd/bcm47xxpart.c                     |  2 +-
 drivers/mtd/chips/cfi_cmdset_0002.c           |  3 +-
 drivers/mtd/devices/docg3.c                   |  3 +-
 drivers/mtd/maps/physmap_of_core.c            |  2 +-
 drivers/mtd/mtdconcat.c                       |  4 +-
 drivers/mtd/nand/raw/nand_bch.c               |  2 +-
 drivers/mtd/ofpart.c                          |  4 +-
 drivers/mtd/parsers/parser_trx.c              |  2 +-
 drivers/mtd/parsers/sharpslpart.c             |  4 +-
 drivers/mtd/tests/stresstest.c                |  2 +-
 drivers/mtd/ubi/eba.c                         |  5 +-
 drivers/net/can/slcan.c                       |  3 +-
 drivers/net/ethernet/amd/lance.c              |  8 +--
 drivers/net/ethernet/broadcom/bnx2.c          |  2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  7 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c |  2 +-
 drivers/net/ethernet/broadcom/cnic.c          |  4 +-
 drivers/net/ethernet/broadcom/tg3.c           |  4 +-
 drivers/net/ethernet/brocade/bna/bnad.c       |  2 +-
 drivers/net/ethernet/calxeda/xgmac.c          |  4 +-
 .../ethernet/cavium/liquidio/lio_vf_main.c    |  4 +-
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c |  3 +-
 .../ethernet/chelsio/cxgb4/cxgb4_debugfs.c    |  2 +-
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c |  3 +-
 .../net/ethernet/chelsio/cxgb4/cxgb4_uld.c    |  6 +--
 drivers/net/ethernet/cortina/gemini.c         |  4 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c   |  4 +-
 .../net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  2 +-
 .../net/ethernet/mellanox/mlx4/en_netdev.c    | 16 +++---
 drivers/net/ethernet/mellanox/mlx4/main.c     |  6 ++-
 .../ethernet/mellanox/mlxsw/spectrum_qdisc.c  |  2 +-
 .../net/ethernet/neterion/vxge/vxge-config.c  | 12 +++--
 .../ethernet/oki-semi/pch_gbe/pch_gbe_main.c  |  2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c      |  8 +--
 .../net/ethernet/qlogic/qed/qed_init_ops.c    |  4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_main.c  |  8 +--
 .../qlogic/qlcnic/qlcnic_sriov_common.c       | 10 ++--
 drivers/net/ethernet/socionext/netsec.c       |  3 +-
 .../net/ethernet/toshiba/ps3_gelic_wireless.c |  4 +-
 drivers/net/gtp.c                             |  6 ++-
 drivers/net/hippi/rrunner.c                   |  3 +-
 drivers/net/phy/dp83640.c                     |  4 +-
 drivers/net/slip/slip.c                       |  4 +-
 drivers/net/team/team.c                       |  5 +-
 drivers/net/usb/smsc95xx.c                    |  3 +-
 drivers/net/virtio_net.c                      |  9 ++--
 drivers/net/wireless/ath/ath10k/wmi-tlv.c     |  2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c    |  3 +-
 drivers/net/wireless/ath/ath9k/hw.c           |  4 +-
 drivers/net/wireless/ath/carl9170/main.c      |  3 +-
 drivers/net/wireless/broadcom/b43/phy_n.c     |  2 +-
 .../net/wireless/broadcom/b43legacy/main.c    |  3 +-
 .../broadcom/brcm80211/brcmfmac/p2p.c         |  2 +-
 .../broadcom/brcm80211/brcmsmac/main.c        |  9 ++--
 .../broadcom/brcm80211/brcmsmac/phy/phy_lcn.c |  8 +--
 .../broadcom/brcm80211/brcmsmac/phy/phy_n.c   |  5 +-
 drivers/net/wireless/cisco/airo.c             |  2 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c  |  5 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c  |  8 +--
 drivers/net/wireless/intel/iwlegacy/common.c  |  6 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c |  3 +-
 .../wireless/intersil/hostap/hostap_info.c    |  2 +-
 .../wireless/intersil/hostap/hostap_ioctl.c   |  6 ++-
 drivers/net/wireless/intersil/p54/eeprom.c    |  6 +--
 .../wireless/marvell/mwifiex/11n_rxreorder.c  |  4 +-
 drivers/net/wireless/realtek/rtlwifi/usb.c    |  2 +-
 drivers/net/wireless/st/cw1200/queue.c        |  6 +--
 drivers/net/wireless/zydas/zd1211rw/zd_mac.c  |  3 +-
 drivers/nvmem/rockchip-efuse.c                |  6 ++-
 drivers/of/unittest.c                         |  2 +-
 drivers/pci/msi.c                             |  2 +-
 drivers/pci/pci-sysfs.c                       |  2 +-
 drivers/pcmcia/cistpl.c                       |  4 +-
 drivers/pcmcia/pd6729.c                       |  2 +-
 drivers/pinctrl/freescale/pinctrl-imx.c       |  3 +-
 drivers/pinctrl/freescale/pinctrl-imx1-core.c |  3 +-
 drivers/pinctrl/freescale/pinctrl-mxs.c       |  2 +-
 drivers/pinctrl/samsung/pinctrl-exynos5440.c  |  4 +-
 drivers/pinctrl/sirf/pinctrl-sirf.c           |  2 +-
 drivers/pinctrl/spear/pinctrl-spear.c         |  2 +-
 drivers/pinctrl/sunxi/pinctrl-sunxi.c         |  6 ++-
 drivers/platform/x86/intel_ips.c              | 18 ++++---
 drivers/platform/x86/thinkpad_acpi.c          |  2 +-
 drivers/power/supply/wm97xx_battery.c         |  2 +-
 drivers/power/supply/z2_battery.c             |  2 +-
 drivers/powercap/powercap_sys.c               |  8 +--
 drivers/regulator/s2mps11.c                   |  2 +-
 drivers/s390/char/keyboard.c                  |  3 +-
 drivers/s390/char/tty3270.c                   |  3 +-
 drivers/s390/cio/qdio_setup.c                 |  2 +-
 drivers/s390/cio/qdio_thinint.c               |  4 +-
 drivers/s390/crypto/pkey_api.c                |  3 +-
 drivers/s390/net/ctcm_main.c                  |  3 +-
 drivers/s390/net/qeth_core_main.c             |  4 +-
 drivers/scsi/BusLogic.c                       |  4 +-
 drivers/scsi/aacraid/aachba.c                 |  3 +-
 drivers/scsi/aha1542.c                        |  3 +-
 drivers/scsi/aic7xxx/aic7xxx_core.c           |  4 +-
 drivers/scsi/arm/queue.c                      |  3 +-
 drivers/scsi/be2iscsi/be_main.c               |  4 +-
 drivers/scsi/bfa/bfad_attr.c                  |  2 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c             |  2 +-
 drivers/scsi/bnx2fc/bnx2fc_io.c               |  8 +--
 drivers/scsi/esas2r/esas2r_init.c             |  6 +--
 drivers/scsi/fcoe/fcoe_ctlr.c                 |  2 +-
 drivers/scsi/hpsa.c                           | 18 ++++---
 drivers/scsi/ipr.c                            |  4 +-
 drivers/scsi/lpfc/lpfc_init.c                 |  6 +--
 drivers/scsi/lpfc/lpfc_mem.c                  |  4 +-
 drivers/scsi/lpfc/lpfc_sli.c                  | 54 +++++++------------
 drivers/scsi/megaraid.c                       |  3 +-
 drivers/scsi/megaraid/megaraid_sas_base.c     |  7 ++-
 drivers/scsi/megaraid/megaraid_sas_fusion.c   |  2 +-
 drivers/scsi/osst.c                           |  6 ++-
 drivers/scsi/pmcraid.c                        |  4 +-
 drivers/scsi/qla2xxx/qla_nx.c                 |  2 +-
 drivers/scsi/qla2xxx/qla_target.c             |  4 +-
 drivers/scsi/qla4xxx/ql4_nx.c                 |  2 +-
 drivers/scsi/scsi_debug.c                     |  2 +-
 drivers/scsi/ses.c                            |  3 +-
 drivers/scsi/sg.c                             |  2 +-
 drivers/scsi/smartpqi/smartpqi_init.c         |  4 +-
 drivers/scsi/st.c                             |  4 +-
 drivers/scsi/virtio_scsi.c                    |  8 +--
 drivers/sh/clk/cpg.c                          |  2 +-
 drivers/slimbus/qcom-ctrl.c                   |  2 +-
 drivers/soc/fsl/qbman/qman.c                  |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c |  4 +-
 .../staging/lustre/lnet/selftest/console.c    |  7 +--
 .../lustre/lustre/obdclass/lustre_handles.c   |  4 +-
 .../pci/atomisp2/atomisp_compat_css20.c       |  4 +-
 .../media/atomisp/pci/atomisp2/atomisp_fops.c |  2 +-
 .../pci/atomisp2/hmm/hmm_reserved_pool.c      |  4 +-
 .../staging/mt7621-pinctrl/pinctrl-rt2880.c   |  3 +-
 .../staging/rtl8192u/ieee80211/ieee80211_rx.c |  4 +-
 .../staging/unisys/visorhba/visorhba_main.c   |  2 +-
 drivers/target/target_core_transport.c        |  2 +-
 .../int340x_thermal/int340x_thermal_zone.c    |  5 +-
 drivers/thermal/x86_pkg_temp_thermal.c        |  3 +-
 drivers/tty/ehv_bytechan.c                    |  3 +-
 drivers/tty/goldfish.c                        |  4 +-
 drivers/tty/hvc/hvcs.c                        |  3 +-
 drivers/tty/serial/atmel_serial.c             |  4 +-
 drivers/tty/serial/pch_uart.c                 |  3 +-
 drivers/tty/serial/sunsab.c                   |  4 +-
 drivers/tty/vt/consolemap.c                   |  8 +--
 drivers/tty/vt/keyboard.c                     |  8 +--
 drivers/uio/uio_pruss.c                       |  3 +-
 drivers/usb/core/devio.c                      |  4 +-
 drivers/usb/core/hub.c                        |  3 +-
 drivers/usb/core/message.c                    |  4 +-
 drivers/usb/dwc2/hcd.c                        |  9 ++--
 drivers/usb/gadget/udc/bdc/bdc_ep.c           |  5 +-
 drivers/usb/host/fhci-tds.c                   |  2 +-
 drivers/usb/host/ohci-dbg.c                   |  2 +-
 drivers/usb/host/xhci-mem.c                   | 17 +++---
 drivers/usb/renesas_usbhs/mod_gadget.c        |  3 +-
 drivers/usb/renesas_usbhs/pipe.c              |  3 +-
 drivers/usb/serial/iuu_phoenix.c              |  4 +-
 drivers/usb/storage/sddr09.c                  |  6 ++-
 drivers/usb/storage/sddr55.c                  |  6 ++-
 drivers/vhost/net.c                           |  6 +--
 drivers/vhost/scsi.c                          | 14 ++---
 drivers/vhost/test.c                          |  2 +-
 drivers/vhost/vhost.c                         |  8 +--
 drivers/vhost/vringh.c                        |  2 +-
 drivers/video/fbdev/broadsheetfb.c            |  3 +-
 drivers/video/fbdev/core/fbcon_rotate.c       |  2 +-
 drivers/video/fbdev/core/fbmon.c              |  5 +-
 drivers/video/fbdev/imxfb.c                   |  3 +-
 drivers/video/fbdev/mmp/fb/mmpfb.c            |  4 +-
 .../video/fbdev/omap2/omapfb/dss/manager.c    |  4 +-
 .../video/fbdev/omap2/omapfb/dss/overlay.c    |  4 +-
 drivers/video/fbdev/pvr2fb.c                  |  3 +-
 drivers/video/fbdev/uvesafb.c                 |  2 +-
 drivers/video/fbdev/via/viafbdev.c            |  3 +-
 drivers/video/fbdev/w100fb.c                  |  3 +-
 drivers/virt/fsl_hypervisor.c                 |  3 +-
 drivers/virt/vboxguest/vboxguest_core.c       |  2 +-
 drivers/virtio/virtio_pci_common.c            |  4 +-
 drivers/virtio/virtio_ring.c                  |  2 +-
 drivers/xen/arm-device.c                      |  7 +--
 drivers/xen/evtchn.c                          |  3 +-
 drivers/xen/grant-table.c                     |  5 +-
 fs/9p/fid.c                                   |  2 +-
 fs/adfs/super.c                               |  2 +-
 fs/afs/cmservice.c                            |  6 ++-
 fs/binfmt_elf.c                               |  3 +-
 fs/binfmt_elf_fdpic.c                         |  3 +-
 fs/block_dev.c                                |  3 +-
 fs/ceph/addr.c                                |  6 +--
 fs/ceph/file.c                                |  2 +-
 fs/cifs/asn1.c                                |  2 +-
 fs/cifs/cifsacl.c                             |  2 +-
 fs/cifs/inode.c                               |  4 +-
 fs/cifs/smb2pdu.c                             |  6 +--
 fs/exofs/inode.c                              |  2 +-
 fs/ext2/super.c                               |  3 +-
 fs/ext4/extents.c                             |  2 +-
 fs/ext4/resize.c                              | 10 ++--
 fs/ext4/super.c                               |  5 +-
 fs/fat/namei_vfat.c                           |  2 +-
 fs/fuse/dev.c                                 |  7 +--
 fs/gfs2/dir.c                                 |  4 +-
 fs/gfs2/glock.c                               |  3 +-
 fs/gfs2/quota.c                               |  3 +-
 fs/gfs2/super.c                               |  3 +-
 fs/jbd2/revoke.c                              |  3 +-
 fs/jfs/jfs_dmap.c                             |  3 +-
 fs/mbcache.c                                  |  2 +-
 fs/namei.c                                    |  8 +--
 fs/nfs/flexfilelayout/flexfilelayout.c        |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c     |  2 +-
 fs/nfsd/nfs4recover.c                         |  4 +-
 fs/nfsd/nfs4state.c                           | 16 +++---
 fs/ntfs/compress.c                            |  2 +-
 fs/ocfs2/cluster/tcp.c                        |  2 +-
 fs/ocfs2/dlm/dlmdomain.c                      |  2 +-
 fs/proc/base.c                                |  3 +-
 fs/read_write.c                               |  6 ++-
 fs/splice.c                                   |  9 ++--
 fs/ubifs/journal.c                            |  2 +-
 fs/ubifs/lpt.c                                |  5 +-
 fs/ubifs/super.c                              |  3 +-
 fs/ubifs/tnc_commit.c                         |  2 +-
 fs/udf/super.c                                |  3 +-
 ipc/sem.c                                     |  2 +-
 kernel/cgroup/cgroup-v1.c                     |  2 +-
 kernel/cgroup/cpuset.c                        |  3 +-
 kernel/sched/fair.c                           |  5 +-
 kernel/sched/rt.c                             |  4 +-
 kernel/sched/topology.c                       |  2 +-
 kernel/trace/ftrace.c                         | 21 ++++----
 kernel/trace/trace.c                          |  5 +-
 kernel/trace/trace_events_filter.c            |  8 +--
 kernel/user_namespace.c                       |  4 +-
 kernel/workqueue.c                            |  2 +-
 lib/bucket_locks.c                            |  3 +-
 lib/interval_tree_test.c                      |  5 +-
 lib/kfifo.c                                   |  2 +-
 lib/lru_cache.c                               |  3 +-
 lib/mpi/mpiutil.c                             |  6 ++-
 lib/rbtree_test.c                             |  2 +-
 lib/scatterlist.c                             |  3 +-
 mm/gup_benchmark.c                            |  2 +-
 mm/huge_memory.c                              |  2 +-
 mm/hugetlb.c                                  |  3 +-
 mm/slub.c                                     |  5 +-
 mm/swap_slots.c                               |  4 +-
 mm/swap_state.c                               |  3 +-
 mm/swapfile.c                                 |  2 +-
 net/9p/trans_virtio.c                         |  3 +-
 net/atm/mpc.c                                 |  3 +-
 net/bluetooth/hci_core.c                      |  3 +-
 net/bluetooth/l2cap_core.c                    |  3 +-
 net/bridge/br_multicast.c                     |  2 +-
 net/ceph/pagevec.c                            |  4 +-
 net/core/dev.c                                |  3 +-
 net/core/ethtool.c                            |  4 +-
 net/dcb/dcbnl.c                               |  3 +-
 net/dccp/ccids/ccid2.c                        |  3 +-
 net/ieee802154/nl-phy.c                       |  2 +-
 net/ipv4/route.c                              |  6 ++-
 net/ipv6/icmp.c                               |  3 +-
 net/ipv6/ila/ila_xlat.c                       |  3 +-
 net/ipv6/route.c                              |  2 +-
 net/mac80211/chan.c                           |  3 +-
 net/mac80211/main.c                           |  3 +-
 net/mac80211/rc80211_minstrel.c               |  5 +-
 net/mac80211/rc80211_minstrel_ht.c            |  6 ++-
 net/mac80211/scan.c                           |  2 +-
 net/netfilter/nf_conntrack_proto.c            |  3 +-
 net/netfilter/nf_nat_core.c                   |  2 +-
 net/netfilter/nf_tables_api.c                 |  4 +-
 net/netfilter/nfnetlink_cthelper.c            |  4 +-
 net/netfilter/x_tables.c                      |  3 +-
 net/netrom/af_netrom.c                        |  3 +-
 net/openvswitch/datapath.c                    |  2 +-
 net/openvswitch/vport.c                       |  2 +-
 net/rds/info.c                                |  3 +-
 net/rose/af_rose.c                            |  3 +-
 net/rxrpc/rxkad.c                             |  2 +-
 net/sched/sch_hhf.c                           |  8 +--
 net/sctp/auth.c                               |  4 +-
 net/sctp/protocol.c                           |  3 +-
 net/wireless/nl80211.c                        |  4 +-
 security/apparmor/policy_unpack.c             |  2 +-
 security/selinux/ss/services.c                |  2 +-
 sound/core/pcm_compat.c                       |  2 +-
 sound/core/seq/seq_midi_emul.c                |  3 +-
 sound/firewire/fireface/ff-protocol-ff400.c   |  2 +-
 sound/firewire/packets-buffer.c               |  3 +-
 sound/oss/dmasound/dmasound_core.c            |  2 +-
 sound/pci/cs46xx/dsp_spos.c                   |  3 +-
 sound/pci/ctxfi/ctatc.c                       | 23 +++++---
 sound/pci/hda/hda_codec.c                     |  3 +-
 sound/pci/hda/hda_proc.c                      |  2 +-
 sound/pci/hda/patch_ca0132.c                  |  3 +-
 sound/pci/via82xx.c                           |  3 +-
 sound/pci/via82xx_modem.c                     |  3 +-
 sound/pci/ymfpci/ymfpci_main.c                |  2 +-
 sound/soc/intel/common/sst-ipc.c              |  4 +-
 sound/usb/6fire/pcm.c                         |  8 +--
 sound/usb/caiaq/audio.c                       |  9 ++--
 sound/usb/format.c                            |  3 +-
 sound/usb/pcm.c                               |  2 +-
 sound/usb/usx2y/usbusx2y.c                    |  2 +-
 sound/usb/usx2y/usbusx2yaudio.c               |  3 +-
 tools/virtio/ringtest/ptr_ring.c              |  2 +-
 virt/kvm/arm/vgic/vgic-v4.c                   |  2 +-
 503 files changed, 1155 insertions(+), 912 deletions(-)

diff --git a/arch/arm/kernel/sys_oabi-compat.c b/arch/arm/kernel/sys_oabi-compat.c
index b9786f491873..fcf7b230a65e 100644
--- a/arch/arm/kernel/sys_oabi-compat.c
+++ b/arch/arm/kernel/sys_oabi-compat.c
@@ -286,7 +286,7 @@ asmlinkage long sys_oabi_epoll_wait(int epfd,
 		return -EINVAL;
 	if (!access_ok(VERIFY_WRITE, events, sizeof(*events) * maxevents))
 		return -EFAULT;
-	kbuf = kmalloc(sizeof(*kbuf) * maxevents, GFP_KERNEL);
+	kbuf = kmalloc(array_size(maxevents, sizeof(*kbuf)), GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
 	fs = get_fs();
@@ -324,7 +324,7 @@ asmlinkage long sys_oabi_semtimedop(int semid,
 		return -EINVAL;
 	if (!access_ok(VERIFY_READ, tsops, sizeof(*tsops) * nsops))
 		return -EFAULT;
-	sops = kmalloc(sizeof(*sops) * nsops, GFP_KERNEL);
+	sops = kmalloc(array_size(nsops, sizeof(*sops)), GFP_KERNEL);
 	if (!sops)
 		return -ENOMEM;
 	err = 0;
diff --git a/arch/arm/mach-footbridge/dc21285.c b/arch/arm/mach-footbridge/dc21285.c
index e7b350f18f5f..46188ceb0407 100644
--- a/arch/arm/mach-footbridge/dc21285.c
+++ b/arch/arm/mach-footbridge/dc21285.c
@@ -252,7 +252,7 @@ int __init dc21285_setup(int nr, struct pci_sys_data *sys)
 	if (nr || !footbridge_cfn_mode())
 		return 0;
 
-	res = kzalloc(sizeof(struct resource) * 2, GFP_KERNEL);
+	res = kzalloc(array_size(2, sizeof(struct resource)), GFP_KERNEL);
 	if (!res) {
 		printk("out of memory for root bus resources");
 		return 0;
diff --git a/arch/arm/mach-ixp4xx/common-pci.c b/arch/arm/mach-ixp4xx/common-pci.c
index bcf3df59f71b..6710ac32550b 100644
--- a/arch/arm/mach-ixp4xx/common-pci.c
+++ b/arch/arm/mach-ixp4xx/common-pci.c
@@ -421,7 +421,7 @@ int ixp4xx_setup(int nr, struct pci_sys_data *sys)
 	if (nr >= 1)
 		return 0;
 
-	res = kzalloc(sizeof(*res) * 2, GFP_KERNEL);
+	res = kzalloc(array_size(2, sizeof(*res)), GFP_KERNEL);
 	if (res == NULL) {
 		/* 
 		 * If we're out of memory this early, something is wrong,
diff --git a/arch/arm/mach-omap1/mcbsp.c b/arch/arm/mach-omap1/mcbsp.c
index 8ed67f8d1762..9955a3f132cd 100644
--- a/arch/arm/mach-omap1/mcbsp.c
+++ b/arch/arm/mach-omap1/mcbsp.c
@@ -389,7 +389,7 @@ static void omap_mcbsp_register_board_cfg(struct resource *res, int res_count,
 {
 	int i;
 
-	omap_mcbsp_devices = kzalloc(size * sizeof(struct platform_device *),
+	omap_mcbsp_devices = kzalloc(array_size(size, sizeof(struct platform_device *)),
 				     GFP_KERNEL);
 	if (!omap_mcbsp_devices) {
 		printk(KERN_ERR "Could not register McBSP devices\n");
diff --git a/arch/arm/mach-omap2/omap_device.c b/arch/arm/mach-omap2/omap_device.c
index 3b829a50d1db..1c1b200ada50 100644
--- a/arch/arm/mach-omap2/omap_device.c
+++ b/arch/arm/mach-omap2/omap_device.c
@@ -155,7 +155,8 @@ static int omap_device_build_from_dt(struct platform_device *pdev)
 	if (!omap_hwmod_parse_module_range(NULL, node, &res))
 		return -ENODEV;
 
-	hwmods = kzalloc(sizeof(struct omap_hwmod *) * oh_cnt, GFP_KERNEL);
+	hwmods = kzalloc(array_size(oh_cnt, sizeof(struct omap_hwmod *)),
+			 GFP_KERNEL);
 	if (!hwmods) {
 		ret = -ENOMEM;
 		goto odbfd_exit;
@@ -405,7 +406,7 @@ omap_device_copy_resources(struct omap_hwmod *oh,
 		goto error;
 	}
 
-	res = kzalloc(sizeof(*res) * 2, GFP_KERNEL);
+	res = kzalloc(array_size(2, sizeof(*res)), GFP_KERNEL);
 	if (!res)
 		return -ENOMEM;
 
diff --git a/arch/arm/mach-omap2/prm_common.c b/arch/arm/mach-omap2/prm_common.c
index 021b5a8b9c0a..805b50753253 100644
--- a/arch/arm/mach-omap2/prm_common.c
+++ b/arch/arm/mach-omap2/prm_common.c
@@ -285,10 +285,12 @@ int omap_prcm_register_chain_handler(struct omap_prcm_irq_setup *irq_setup)
 
 	prcm_irq_setup = irq_setup;
 
-	prcm_irq_chips = kzalloc(sizeof(void *) * nr_regs, GFP_KERNEL);
-	prcm_irq_setup->saved_mask = kzalloc(sizeof(u32) * nr_regs, GFP_KERNEL);
-	prcm_irq_setup->priority_mask = kzalloc(sizeof(u32) * nr_regs,
-		GFP_KERNEL);
+	prcm_irq_chips = kzalloc(array_size(nr_regs, sizeof(void *)),
+				 GFP_KERNEL);
+	prcm_irq_setup->saved_mask = kzalloc(array_size(nr_regs, sizeof(u32)),
+					     GFP_KERNEL);
+	prcm_irq_setup->priority_mask = kzalloc(array_size(nr_regs, sizeof(u32)),
+						GFP_KERNEL);
 
 	if (!prcm_irq_chips || !prcm_irq_setup->saved_mask ||
 	    !prcm_irq_setup->priority_mask)
diff --git a/arch/arm/mach-vexpress/spc.c b/arch/arm/mach-vexpress/spc.c
index 21c064267af5..893f29642248 100644
--- a/arch/arm/mach-vexpress/spc.c
+++ b/arch/arm/mach-vexpress/spc.c
@@ -403,7 +403,7 @@ static int ve_spc_populate_opps(uint32_t cluster)
 	uint32_t data = 0, off, ret, idx;
 	struct ve_spc_opp *opps;
 
-	opps = kzalloc(sizeof(*opps) * MAX_OPPS, GFP_KERNEL);
+	opps = kzalloc(array_size(MAX_OPPS, sizeof(*opps)), GFP_KERNEL);
 	if (!opps)
 		return -ENOMEM;
 
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 8c398fedbbb6..d61502849e7f 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -2185,8 +2185,8 @@ arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, u64 size)
 		goto err;
 
 	mapping->bitmap_size = bitmap_size;
-	mapping->bitmaps = kzalloc(extensions * sizeof(unsigned long *),
-				GFP_KERNEL);
+	mapping->bitmaps = kzalloc(array_size(extensions, sizeof(unsigned long *)),
+				   GFP_KERNEL);
 	if (!mapping->bitmaps)
 		goto err2;
 
diff --git a/arch/arm/mm/pgd.c b/arch/arm/mm/pgd.c
index 61e281cb29fb..f520a3a6ec00 100644
--- a/arch/arm/mm/pgd.c
+++ b/arch/arm/mm/pgd.c
@@ -20,7 +20,7 @@
 #include "mm.h"
 
 #ifdef CONFIG_ARM_LPAE
-#define __pgd_alloc()	kmalloc(PTRS_PER_PGD * sizeof(pgd_t), GFP_KERNEL)
+#define __pgd_alloc()	kmalloc(array_size(PTRS_PER_PGD, sizeof(pgd_t)), GFP_KERNEL)
 #define __pgd_free(pgd)	kfree(pgd)
 #else
 #define __pgd_alloc()	(pgd_t *)__get_free_pages(GFP_KERNEL, 2)
diff --git a/arch/arm/probes/kprobes/test-core.c b/arch/arm/probes/kprobes/test-core.c
index 9ed0129bed3c..7d8f7b30b78b 100644
--- a/arch/arm/probes/kprobes/test-core.c
+++ b/arch/arm/probes/kprobes/test-core.c
@@ -766,8 +766,8 @@ static int coverage_start_fn(const struct decode_header *h, void *args)
 
 static int coverage_start(const union decode_item *table)
 {
-	coverage.base = kmalloc(MAX_COVERAGE_ENTRIES *
-				sizeof(struct coverage_entry), GFP_KERNEL);
+	coverage.base = kmalloc(array_size(MAX_COVERAGE_ENTRIES, sizeof(struct coverage_entry)),
+				GFP_KERNEL);
 	coverage.num_entries = 0;
 	coverage.nesting = 0;
 	return table_iter(table, coverage_start_fn, &coverage);
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index d76529cbff20..e867f4267851 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -85,7 +85,8 @@ static int __init topology_init(void)
 	}
 #endif
 
-	sysfs_cpus = kzalloc(sizeof(struct ia64_cpu) * NR_CPUS, GFP_KERNEL);
+	sysfs_cpus = kzalloc(array_size(NR_CPUS, sizeof(struct ia64_cpu)),
+			     GFP_KERNEL);
 	if (!sysfs_cpus)
 		panic("kzalloc in topology_init failed - NR_CPUS too big?");
 
@@ -319,8 +320,8 @@ static int cpu_cache_sysfs_init(unsigned int cpu)
 		return -1;
 	}
 
-	this_cache=kzalloc(sizeof(struct cache_info)*unique_caches,
-			GFP_KERNEL);
+	this_cache=kzalloc(array_size(unique_caches, sizeof(struct cache_info)),
+			   GFP_KERNEL);
 	if (this_cache == NULL)
 		return -ENOMEM;
 
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 11f2275570fb..b46365a8b4c0 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -132,7 +132,8 @@ static s64 sn_device_fixup_war(u64 nasid, u64 widget, int device,
 	printk_once(KERN_WARNING
 		"PROM version < 4.50 -- implementing old PROM flush WAR\n");
 
-	war_list = kzalloc(DEV_PER_WIDGET * sizeof(*war_list), GFP_KERNEL);
+	war_list = kzalloc(array_size(DEV_PER_WIDGET, sizeof(*war_list)),
+			   GFP_KERNEL);
 	BUG_ON(!war_list);
 
 	SAL_CALL_NOLOCK(isrv, SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST,
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 85d095154902..e78b26d60195 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -474,7 +474,8 @@ void __init sn_irq_lh_init(void)
 {
 	int i;
 
-	sn_irq_lh = kmalloc(sizeof(struct list_head *) * NR_IRQS, GFP_KERNEL);
+	sn_irq_lh = kmalloc(array_size(NR_IRQS, sizeof(struct list_head *)),
+			    GFP_KERNEL);
 	if (!sn_irq_lh)
 		panic("SN PCI INIT: Failed to allocate memory for PCI init\n");
 
diff --git a/arch/mips/alchemy/common/dbdma.c b/arch/mips/alchemy/common/dbdma.c
index fc482d900ddd..8040f76bbbc2 100644
--- a/arch/mips/alchemy/common/dbdma.c
+++ b/arch/mips/alchemy/common/dbdma.c
@@ -411,8 +411,8 @@ u32 au1xxx_dbdma_ring_alloc(u32 chanid, int entries)
 	 * and if we try that first we are likely to not waste larger
 	 * slabs of memory.
 	 */
-	desc_base = (u32)kmalloc(entries * sizeof(au1x_ddma_desc_t),
-				 GFP_KERNEL|GFP_DMA);
+	desc_base = (u32)kmalloc(array_size(entries, sizeof(au1x_ddma_desc_t)),
+				 GFP_KERNEL | GFP_DMA);
 	if (desc_base == 0)
 		return 0;
 
@@ -1050,7 +1050,8 @@ static int __init dbdma_setup(unsigned int irq, dbdev_tab_t *idtable)
 {
 	int ret;
 
-	dbdev_tab = kzalloc(sizeof(dbdev_tab_t) * DBDEV_TAB_SIZE, GFP_KERNEL);
+	dbdev_tab = kzalloc(array_size(DBDEV_TAB_SIZE, sizeof(dbdev_tab_t)),
+			    GFP_KERNEL);
 	if (!dbdev_tab)
 		return -ENOMEM;
 
diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
index d77a64f4c78b..cb2c316a2165 100644
--- a/arch/mips/alchemy/common/platform.c
+++ b/arch/mips/alchemy/common/platform.c
@@ -198,7 +198,7 @@ static unsigned long alchemy_ehci_data[][2] __initdata = {
 
 static int __init _new_usbres(struct resource **r, struct platform_device **d)
 {
-	*r = kzalloc(sizeof(struct resource) * 2, GFP_KERNEL);
+	*r = kzalloc(array_size(2, sizeof(struct resource)), GFP_KERNEL);
 	if (!*r)
 		return -ENOMEM;
 	*d = kzalloc(sizeof(struct platform_device), GFP_KERNEL);
diff --git a/arch/mips/alchemy/devboards/platform.c b/arch/mips/alchemy/devboards/platform.c
index 4640edab207c..9584940417aa 100644
--- a/arch/mips/alchemy/devboards/platform.c
+++ b/arch/mips/alchemy/devboards/platform.c
@@ -103,7 +103,7 @@ int __init db1x_register_pcmcia_socket(phys_addr_t pcmcia_attr_start,
 	if (stschg_irq)
 		cnt++;
 
-	sr = kzalloc(sizeof(struct resource) * cnt, GFP_KERNEL);
+	sr = kzalloc(array_size(cnt, sizeof(struct resource)), GFP_KERNEL);
 	if (!sr)
 		return -ENOMEM;
 
@@ -178,7 +178,8 @@ int __init db1x_register_norflash(unsigned long size, int width,
 		return -EINVAL;
 
 	ret = -ENOMEM;
-	parts = kzalloc(sizeof(struct mtd_partition) * 5, GFP_KERNEL);
+	parts = kzalloc(array_size(5, sizeof(struct mtd_partition)),
+			GFP_KERNEL);
 	if (!parts)
 		goto out;
 
diff --git a/arch/mips/txx9/rbtx4939/setup.c b/arch/mips/txx9/rbtx4939/setup.c
index fd26fadc8617..ff5c6e4a52f8 100644
--- a/arch/mips/txx9/rbtx4939/setup.c
+++ b/arch/mips/txx9/rbtx4939/setup.c
@@ -219,7 +219,7 @@ static int __init rbtx4939_led_probe(struct platform_device *pdev)
 		"nand-disk",
 	};
 
-	leds_data = kzalloc(sizeof(*leds_data) * RBTX4939_MAX_7SEGLEDS,
+	leds_data = kzalloc(array_size(RBTX4939_MAX_7SEGLEDS, sizeof(*leds_data)),
 			    GFP_KERNEL);
 	if (!leds_data)
 		return -ENOMEM;
diff --git a/arch/powerpc/lib/rheap.c b/arch/powerpc/lib/rheap.c
index 94058c21a482..a0faeea397b8 100644
--- a/arch/powerpc/lib/rheap.c
+++ b/arch/powerpc/lib/rheap.c
@@ -54,7 +54,8 @@ static int grow(rh_info_t * info, int max_blocks)
 
 	new_blocks = max_blocks - info->max_blocks;
 
-	block = kmalloc(sizeof(rh_block_t) * max_blocks, GFP_ATOMIC);
+	block = kmalloc(array_size(max_blocks, sizeof(rh_block_t)),
+			GFP_ATOMIC);
 	if (block == NULL)
 		return -ENOMEM;
 
diff --git a/arch/powerpc/platforms/4xx/hsta_msi.c b/arch/powerpc/platforms/4xx/hsta_msi.c
index 9926ad67af76..11dbc6146b8d 100644
--- a/arch/powerpc/platforms/4xx/hsta_msi.c
+++ b/arch/powerpc/platforms/4xx/hsta_msi.c
@@ -156,7 +156,8 @@ static int hsta_msi_probe(struct platform_device *pdev)
 	if (ret)
 		goto out;
 
-	ppc4xx_hsta_msi.irq_map = kmalloc(sizeof(int) * irq_count, GFP_KERNEL);
+	ppc4xx_hsta_msi.irq_map = kmalloc(array_size(irq_count, sizeof(int)),
+					  GFP_KERNEL);
 	if (!ppc4xx_hsta_msi.irq_map) {
 		ret = -ENOMEM;
 		goto out1;
diff --git a/arch/powerpc/platforms/4xx/pci.c b/arch/powerpc/platforms/4xx/pci.c
index 73e6b36bcd51..188ed628e616 100644
--- a/arch/powerpc/platforms/4xx/pci.c
+++ b/arch/powerpc/platforms/4xx/pci.c
@@ -1449,7 +1449,7 @@ static int __init ppc4xx_pciex_check_core_init(struct device_node *np)
 	count = ppc4xx_pciex_hwops->core_init(np);
 	if (count > 0) {
 		ppc4xx_pciex_ports =
-		       kzalloc(count * sizeof(struct ppc4xx_pciex_port),
+		       kzalloc(array_size(count, sizeof(struct ppc4xx_pciex_port)),
 			       GFP_KERNEL);
 		if (ppc4xx_pciex_ports) {
 			ppc4xx_pciex_port_count = count;
diff --git a/arch/powerpc/platforms/powernv/opal-sysparam.c b/arch/powerpc/platforms/powernv/opal-sysparam.c
index 6fd4092798d5..9217d0162242 100644
--- a/arch/powerpc/platforms/powernv/opal-sysparam.c
+++ b/arch/powerpc/platforms/powernv/opal-sysparam.c
@@ -198,21 +198,21 @@ void __init opal_sys_param_init(void)
 		goto out_param_buf;
 	}
 
-	id = kzalloc(sizeof(*id) * count, GFP_KERNEL);
+	id = kzalloc(array_size(count, sizeof(*id)), GFP_KERNEL);
 	if (!id) {
 		pr_err("SYSPARAM: Failed to allocate memory to read parameter "
 				"id\n");
 		goto out_param_buf;
 	}
 
-	size = kzalloc(sizeof(*size) * count, GFP_KERNEL);
+	size = kzalloc(array_size(count, sizeof(*size)), GFP_KERNEL);
 	if (!size) {
 		pr_err("SYSPARAM: Failed to allocate memory to read parameter "
 				"size\n");
 		goto out_free_id;
 	}
 
-	perm = kzalloc(sizeof(*perm) * count, GFP_KERNEL);
+	perm = kzalloc(array_size(count, sizeof(*perm)), GFP_KERNEL);
 	if (!perm) {
 		pr_err("SYSPARAM: Failed to allocate memory to read supported "
 				"action on the parameter");
@@ -235,7 +235,7 @@ void __init opal_sys_param_init(void)
 		goto out_free_perm;
 	}
 
-	attr = kzalloc(sizeof(*attr) * count, GFP_KERNEL);
+	attr = kzalloc(array_size(count, sizeof(*attr)), GFP_KERNEL);
 	if (!attr) {
 		pr_err("SYSPARAM: Failed to allocate memory for parameter "
 				"attributes\n");
diff --git a/arch/powerpc/sysdev/mpic.c b/arch/powerpc/sysdev/mpic.c
index 1d4e0ef658d3..0e9920e6ab9b 100644
--- a/arch/powerpc/sysdev/mpic.c
+++ b/arch/powerpc/sysdev/mpic.c
@@ -544,7 +544,8 @@ static void __init mpic_scan_ht_pics(struct mpic *mpic)
 	printk(KERN_INFO "mpic: Setting up HT PICs workarounds for U3/U4\n");
 
 	/* Allocate fixups array */
-	mpic->fixups = kzalloc(128 * sizeof(*mpic->fixups), GFP_KERNEL);
+	mpic->fixups = kzalloc(array_size(128, sizeof(*mpic->fixups)),
+			       GFP_KERNEL);
 	BUG_ON(mpic->fixups == NULL);
 
 	/* Init spinlock */
@@ -1324,7 +1325,8 @@ struct mpic * __init mpic_alloc(struct device_node *node,
 	if (psrc) {
 		/* Allocate a bitmap with one bit per interrupt */
 		unsigned int mapsize = BITS_TO_LONGS(intvec_top + 1);
-		mpic->protected = kzalloc(mapsize*sizeof(long), GFP_KERNEL);
+		mpic->protected = kzalloc(array_size(mapsize, sizeof(long)),
+					  GFP_KERNEL);
 		BUG_ON(mpic->protected == NULL);
 		for (i = 0; i < psize/sizeof(u32); i++) {
 			if (psrc[i] > intvec_top)
diff --git a/arch/s390/appldata/appldata_base.c b/arch/s390/appldata/appldata_base.c
index cb6e8066b1ad..8cc9d9559f81 100644
--- a/arch/s390/appldata/appldata_base.c
+++ b/arch/s390/appldata/appldata_base.c
@@ -391,7 +391,8 @@ int appldata_register_ops(struct appldata_ops *ops)
 	if (ops->size > APPLDATA_MAX_REC_SIZE)
 		return -EINVAL;
 
-	ops->ctl_table = kzalloc(4 * sizeof(struct ctl_table), GFP_KERNEL);
+	ops->ctl_table = kzalloc(array_size(4, sizeof(struct ctl_table)),
+				 GFP_KERNEL);
 	if (!ops->ctl_table)
 		return -ENOMEM;
 
diff --git a/arch/s390/kernel/debug.c b/arch/s390/kernel/debug.c
index 80e974adb9e8..de5a9120f22c 100644
--- a/arch/s390/kernel/debug.c
+++ b/arch/s390/kernel/debug.c
@@ -194,11 +194,13 @@ static debug_entry_t ***debug_areas_alloc(int pages_per_area, int nr_areas)
 	debug_entry_t ***areas;
 	int i, j;
 
-	areas = kmalloc(nr_areas * sizeof(debug_entry_t **), GFP_KERNEL);
+	areas = kmalloc(array_size(nr_areas, sizeof(debug_entry_t **)),
+			GFP_KERNEL);
 	if (!areas)
 		goto fail_malloc_areas;
 	for (i = 0; i < nr_areas; i++) {
-		areas[i] = kmalloc(pages_per_area * sizeof(debug_entry_t *), GFP_KERNEL);
+		areas[i] = kmalloc(array_size(pages_per_area, sizeof(debug_entry_t *)),
+				   GFP_KERNEL);
 		if (!areas[i])
 			goto fail_malloc_areas2;
 		for (j = 0; j < pages_per_area; j++) {
diff --git a/arch/s390/kernel/perf_cpum_cf_events.c b/arch/s390/kernel/perf_cpum_cf_events.c
index 5ee27dc9a10c..9514a2f0e407 100644
--- a/arch/s390/kernel/perf_cpum_cf_events.c
+++ b/arch/s390/kernel/perf_cpum_cf_events.c
@@ -527,7 +527,7 @@ static __init struct attribute **merge_attr(struct attribute **a,
 		j++;
 	j++;
 
-	new = kmalloc(sizeof(struct attribute *) * j, GFP_KERNEL);
+	new = kmalloc(array_size(j, sizeof(struct attribute *)), GFP_KERNEL);
 	if (!new)
 		return NULL;
 	j = 0;
diff --git a/arch/s390/mm/extmem.c b/arch/s390/mm/extmem.c
index 920d40894535..c8c4f31f33cf 100644
--- a/arch/s390/mm/extmem.c
+++ b/arch/s390/mm/extmem.c
@@ -103,7 +103,8 @@ static int scode_set;
 static int
 dcss_set_subcodes(void)
 {
-	char *name = kmalloc(8 * sizeof(char), GFP_KERNEL | GFP_DMA);
+	char *name = kmalloc(array_size(8, sizeof(char)),
+			     GFP_KERNEL | GFP_DMA);
 	unsigned long rx, ry;
 	int rc;
 
diff --git a/arch/sh/drivers/dma/dmabrg.c b/arch/sh/drivers/dma/dmabrg.c
index c0dd904483c7..e3a647958d96 100644
--- a/arch/sh/drivers/dma/dmabrg.c
+++ b/arch/sh/drivers/dma/dmabrg.c
@@ -154,7 +154,7 @@ static int __init dmabrg_init(void)
 	unsigned long or;
 	int ret;
 
-	dmabrg_handlers = kzalloc(10 * sizeof(struct dmabrg_handler),
+	dmabrg_handlers = kzalloc(array_size(10, sizeof(struct dmabrg_handler)),
 				  GFP_KERNEL);
 	if (!dmabrg_handlers)
 		return -ENOMEM;
diff --git a/arch/sh/drivers/pci/pcie-sh7786.c b/arch/sh/drivers/pci/pcie-sh7786.c
index 382e7ecf4c82..0c14a46c3c02 100644
--- a/arch/sh/drivers/pci/pcie-sh7786.c
+++ b/arch/sh/drivers/pci/pcie-sh7786.c
@@ -561,7 +561,7 @@ static int __init sh7786_pcie_init(void)
 	if (unlikely(nr_ports == 0))
 		return -ENODEV;
 
-	sh7786_pcie_ports = kzalloc(nr_ports * sizeof(struct sh7786_pcie_port),
+	sh7786_pcie_ports = kzalloc(array_size(nr_ports, sizeof(struct sh7786_pcie_port)),
 				    GFP_KERNEL);
 	if (unlikely(!sh7786_pcie_ports))
 		return -ENOMEM;
diff --git a/arch/sparc/kernel/nmi.c b/arch/sparc/kernel/nmi.c
index 048ad783ea3f..5c6a7414deb7 100644
--- a/arch/sparc/kernel/nmi.c
+++ b/arch/sparc/kernel/nmi.c
@@ -166,7 +166,8 @@ static int __init check_nmi_watchdog(void)
 	if (!atomic_read(&nmi_active))
 		return 0;
 
-	prev_nmi_count = kmalloc(nr_cpu_ids * sizeof(unsigned int), GFP_KERNEL);
+	prev_nmi_count = kmalloc(array_size(nr_cpu_ids, sizeof(unsigned int)),
+				 GFP_KERNEL);
 	if (!prev_nmi_count) {
 		err = -ENOMEM;
 		goto error;
diff --git a/arch/sparc/net/bpf_jit_comp_32.c b/arch/sparc/net/bpf_jit_comp_32.c
index 3bd8ca95e521..a6c7ce7bbd1f 100644
--- a/arch/sparc/net/bpf_jit_comp_32.c
+++ b/arch/sparc/net/bpf_jit_comp_32.c
@@ -335,7 +335,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 	if (!bpf_jit_enable)
 		return;
 
-	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
+	addrs = kmalloc(array_size(flen, sizeof(*addrs)), GFP_KERNEL);
 	if (addrs == NULL)
 		return;
 
diff --git a/arch/um/drivers/ubd_kern.c b/arch/um/drivers/ubd_kern.c
index d4e8c497ae86..070696d0ee56 100644
--- a/arch/um/drivers/ubd_kern.c
+++ b/arch/um/drivers/ubd_kern.c
@@ -1139,20 +1139,16 @@ static int __init ubd_init(void)
 			return -1;
 	}
 
-	irq_req_buffer = kmalloc(
-			sizeof(struct io_thread_req *) * UBD_REQ_BUFFER_SIZE,
-			GFP_KERNEL
-		);
+	irq_req_buffer = kmalloc(array_size(UBD_REQ_BUFFER_SIZE, sizeof(struct io_thread_req *)),
+				 GFP_KERNEL);
 	irq_remainder = 0;
 
 	if (irq_req_buffer == NULL) {
 		printk(KERN_ERR "Failed to initialize ubd buffering\n");
 		return -1;
 	}
-	io_req_buffer = kmalloc(
-			sizeof(struct io_thread_req *) * UBD_REQ_BUFFER_SIZE,
-			GFP_KERNEL
-		);
+	io_req_buffer = kmalloc(array_size(UBD_REQ_BUFFER_SIZE, sizeof(struct io_thread_req *)),
+				GFP_KERNEL);
 
 	io_remainder = 0;
 
diff --git a/arch/um/drivers/vector_user.c b/arch/um/drivers/vector_user.c
index 4d6a78e31089..3e968398a13e 100644
--- a/arch/um/drivers/vector_user.c
+++ b/arch/um/drivers/vector_user.c
@@ -563,8 +563,8 @@ void *uml_vector_default_bpf(int fd, void *mac)
 		.filter = NULL,
 	};
 
-	bpf = uml_kmalloc(
-		sizeof(struct sock_filter) * DEFAULT_BPF_LEN, UM_GFP_KERNEL);
+	bpf = uml_kmalloc(array_size(DEFAULT_BPF_LEN, sizeof(struct sock_filter)),
+			  UM_GFP_KERNEL);
 	if (bpf != NULL) {
 		bpf_prog.filter = bpf;
 		/* ld	[8] */
diff --git a/arch/um/os-Linux/sigio.c b/arch/um/os-Linux/sigio.c
index 46e762f926eb..b1d8213e72ef 100644
--- a/arch/um/os-Linux/sigio.c
+++ b/arch/um/os-Linux/sigio.c
@@ -107,7 +107,7 @@ static int need_poll(struct pollfds *polls, int n)
 	if (n <= polls->size)
 		return 0;
 
-	new = uml_kmalloc(n * sizeof(struct pollfd), UM_GFP_ATOMIC);
+	new = uml_kmalloc(array_size(n, sizeof(struct pollfd)), UM_GFP_ATOMIC);
 	if (new == NULL) {
 		printk(UM_KERN_ERR "need_poll : failed to allocate new "
 		       "pollfds\n");
diff --git a/arch/x86/events/core.c b/arch/x86/events/core.c
index a6006e7bb729..08753fca0e88 100644
--- a/arch/x86/events/core.c
+++ b/arch/x86/events/core.c
@@ -1631,7 +1631,7 @@ __init struct attribute **merge_attr(struct attribute **a, struct attribute **b)
 		j++;
 	j++;
 
-	new = kmalloc(sizeof(struct attribute *) * j, GFP_KERNEL);
+	new = kmalloc(array_size(j, sizeof(struct attribute *)), GFP_KERNEL);
 	if (!new)
 		return NULL;
 
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 42cf2880d0ed..f364bfd7696a 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -1457,7 +1457,8 @@ static int __mcheck_cpu_mce_banks_init(void)
 	int i;
 	u8 num_banks = mca_cfg.banks;
 
-	mce_banks = kzalloc(num_banks * sizeof(struct mce_bank), GFP_KERNEL);
+	mce_banks = kzalloc(array_size(num_banks, sizeof(struct mce_bank)),
+			    GFP_KERNEL);
 	if (!mce_banks)
 		return -ENOMEM;
 
diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 558444b23923..c5122de92138 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -43,7 +43,7 @@ mtrr_file_add(unsigned long base, unsigned long size,
 
 	max = num_var_ranges;
 	if (fcount == NULL) {
-		fcount = kzalloc(max * sizeof *fcount, GFP_KERNEL);
+		fcount = kzalloc(array_size(max, sizeof(*fcount)), GFP_KERNEL);
 		if (!fcount)
 			return -ENOMEM;
 		FILE_FCOUNT(file) = fcount;
diff --git a/arch/x86/kernel/hpet.c b/arch/x86/kernel/hpet.c
index 8ce4212e2b8d..29345edb485a 100644
--- a/arch/x86/kernel/hpet.c
+++ b/arch/x86/kernel/hpet.c
@@ -610,7 +610,8 @@ static void hpet_msi_capability_lookup(unsigned int start_timer)
 	if (!hpet_domain)
 		return;
 
-	hpet_devs = kzalloc(sizeof(struct hpet_dev) * num_timers, GFP_KERNEL);
+	hpet_devs = kzalloc(array_size(num_timers, sizeof(struct hpet_dev)),
+			    GFP_KERNEL);
 	if (!hpet_devs)
 		return;
 
diff --git a/arch/x86/kernel/ksysfs.c b/arch/x86/kernel/ksysfs.c
index 8c1cc08f514f..715bc75407d7 100644
--- a/arch/x86/kernel/ksysfs.c
+++ b/arch/x86/kernel/ksysfs.c
@@ -283,7 +283,7 @@ static int __init create_setup_data_nodes(struct kobject *parent)
 	if (ret)
 		goto out_setup_data_kobj;
 
-	kobjp = kmalloc(sizeof(*kobjp) * nr, GFP_KERNEL);
+	kobjp = kmalloc(array_size(nr, sizeof(*kobjp)), GFP_KERNEL);
 	if (!kobjp) {
 		ret = -ENOMEM;
 		goto out_setup_data_kobj;
diff --git a/arch/x86/kvm/page_track.c b/arch/x86/kvm/page_track.c
index 01c1371f39f8..abde9b08dd98 100644
--- a/arch/x86/kvm/page_track.c
+++ b/arch/x86/kvm/page_track.c
@@ -40,8 +40,8 @@ int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
 	int  i;
 
 	for (i = 0; i < KVM_PAGE_TRACK_MAX; i++) {
-		slot->arch.gfn_track[i] = kvzalloc(npages *
-					    sizeof(*slot->arch.gfn_track[i]), GFP_KERNEL);
+		slot->arch.gfn_track[i] = kvzalloc(array_size(npages, sizeof(*slot->arch.gfn_track[i])),
+						   GFP_KERNEL);
 		if (!slot->arch.gfn_track[i])
 			goto track_free;
 	}
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 51ecd381793b..3b706eb0bde9 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8871,13 +8871,15 @@ int kvm_arch_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 				      slot->base_gfn, level) + 1;
 
 		slot->arch.rmap[i] =
-			kvzalloc(lpages * sizeof(*slot->arch.rmap[i]), GFP_KERNEL);
+			kvzalloc(array_size(lpages, sizeof(*slot->arch.rmap[i])),
+				 GFP_KERNEL);
 		if (!slot->arch.rmap[i])
 			goto out_free;
 		if (i == 0)
 			continue;
 
-		linfo = kvzalloc(lpages * sizeof(*linfo), GFP_KERNEL);
+		linfo = kvzalloc(array_size(lpages, sizeof(*linfo)),
+				 GFP_KERNEL);
 		if (!linfo)
 			goto out_free;
 
diff --git a/arch/x86/platform/uv/tlb_uv.c b/arch/x86/platform/uv/tlb_uv.c
index b36caae0fb2f..d7fae2d761e0 100644
--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -2142,7 +2142,8 @@ static int __init init_per_cpu(int nuvhubs, int base_part_pnode)
 	if (is_uv3_hub() || is_uv2_hub() || is_uv1_hub())
 		timeout_us = calculate_destination_timeout();
 
-	vp = kmalloc(nuvhubs * sizeof(struct uvhub_desc), GFP_KERNEL);
+	vp = kmalloc(array_size(nuvhubs, sizeof(struct uvhub_desc)),
+		     GFP_KERNEL);
 	uvhub_descs = (struct uvhub_desc *)vp;
 	memset(uvhub_descs, 0, nuvhubs * sizeof(struct uvhub_desc));
 	uvhub_mask = kzalloc((nuvhubs+7)/8, GFP_KERNEL);
diff --git a/arch/x86/platform/uv/uv_time.c b/arch/x86/platform/uv/uv_time.c
index b082d71b08ee..462d84cf691f 100644
--- a/arch/x86/platform/uv/uv_time.c
+++ b/arch/x86/platform/uv/uv_time.c
@@ -158,7 +158,8 @@ static __init int uv_rtc_allocate_timers(void)
 {
 	int cpu;
 
-	blade_info = kzalloc(uv_possible_blades * sizeof(void *), GFP_KERNEL);
+	blade_info = kzalloc(array_size(uv_possible_blades, sizeof(void *)),
+			     GFP_KERNEL);
 	if (!blade_info)
 		return -ENOMEM;
 
diff --git a/block/bio.c b/block/bio.c
index 53e0f0a1ed94..84e3349df3e4 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -2013,7 +2013,8 @@ static int __init init_bio(void)
 {
 	bio_slab_max = 2;
 	bio_slab_nr = 0;
-	bio_slabs = kzalloc(bio_slab_max * sizeof(struct bio_slab), GFP_KERNEL);
+	bio_slabs = kzalloc(array_size(bio_slab_max, sizeof(struct bio_slab)),
+			    GFP_KERNEL);
 	if (!bio_slabs)
 		panic("bio: can't allocate bios\n");
 
diff --git a/block/blk-tag.c b/block/blk-tag.c
index 09f19c6c52ce..e71a4327ebb9 100644
--- a/block/blk-tag.c
+++ b/block/blk-tag.c
@@ -99,12 +99,14 @@ init_tag_map(struct request_queue *q, struct blk_queue_tag *tags, int depth)
 		       __func__, depth);
 	}
 
-	tag_index = kzalloc(depth * sizeof(struct request *), GFP_ATOMIC);
+	tag_index = kzalloc(array_size(depth, sizeof(struct request *)),
+			    GFP_ATOMIC);
 	if (!tag_index)
 		goto fail;
 
 	nr_ulongs = ALIGN(depth, BITS_PER_LONG) / BITS_PER_LONG;
-	tag_map = kzalloc(nr_ulongs * sizeof(unsigned long), GFP_ATOMIC);
+	tag_map = kzalloc(array_size(nr_ulongs, sizeof(unsigned long)),
+			  GFP_ATOMIC);
 	if (!tag_map)
 		goto fail;
 
diff --git a/block/partitions/ldm.c b/block/partitions/ldm.c
index 2a365c756648..6964714e71b7 100644
--- a/block/partitions/ldm.c
+++ b/block/partitions/ldm.c
@@ -378,7 +378,7 @@ static bool ldm_validate_tocblocks(struct parsed_partitions *state,
 	BUG_ON(!state || !ldb);
 	ph = &ldb->ph;
 	tb[0] = &ldb->toc;
-	tb[1] = kmalloc(sizeof(*tb[1]) * 3, GFP_KERNEL);
+	tb[1] = kmalloc(array_size(3, sizeof(*tb[1])), GFP_KERNEL);
 	if (!tb[1]) {
 		ldm_crit("Out of memory.");
 		goto err;
diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
index 88cd949003f3..635a06a11144 100644
--- a/drivers/acpi/acpi_platform.c
+++ b/drivers/acpi/acpi_platform.c
@@ -82,7 +82,7 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *adev,
 	if (count < 0) {
 		return NULL;
 	} else if (count > 0) {
-		resources = kzalloc(count * sizeof(struct resource),
+		resources = kzalloc(array_size(count, sizeof(struct resource)),
 				    GFP_KERNEL);
 		if (!resources) {
 			dev_err(&adev->dev, "No memory for resources\n");
diff --git a/drivers/acpi/apei/erst.c b/drivers/acpi/apei/erst.c
index 9bff853e85f3..0214377af50a 100644
--- a/drivers/acpi/apei/erst.c
+++ b/drivers/acpi/apei/erst.c
@@ -524,7 +524,8 @@ static int __erst_record_id_cache_add_one(void)
 				pr_warn(FW_WARN "too many record IDs!\n");
 			return 0;
 		}
-		new_entries = kvmalloc(new_size * sizeof(entries[0]), GFP_KERNEL);
+		new_entries = kvmalloc(array_size(new_size, sizeof(entries[0])),
+				       GFP_KERNEL);
 		if (!new_entries)
 			return -ENOMEM;
 		memcpy(new_entries, entries,
diff --git a/drivers/acpi/apei/hest.c b/drivers/acpi/apei/hest.c
index 9cb74115a43d..1434aa591931 100644
--- a/drivers/acpi/apei/hest.c
+++ b/drivers/acpi/apei/hest.c
@@ -195,7 +195,8 @@ static int __init hest_ghes_dev_register(unsigned int ghes_count)
 	struct ghes_arr ghes_arr;
 
 	ghes_arr.count = 0;
-	ghes_arr.ghes_devs = kmalloc(sizeof(void *) * ghes_count, GFP_KERNEL);
+	ghes_arr.ghes_devs = kmalloc(array_size(ghes_count, sizeof(void *)),
+				     GFP_KERNEL);
 	if (!ghes_arr.ghes_devs)
 		return -ENOMEM;
 
diff --git a/drivers/ata/libata-core.c b/drivers/ata/libata-core.c
index 8bc71ca61e7f..9ea0c8e25fc8 100644
--- a/drivers/ata/libata-core.c
+++ b/drivers/ata/libata-core.c
@@ -6984,7 +6984,8 @@ static void __init ata_parse_force_param(void)
 		if (*p == ',')
 			size++;
 
-	ata_force_tbl = kzalloc(sizeof(ata_force_tbl[0]) * size, GFP_KERNEL);
+	ata_force_tbl = kzalloc(array_size(size, sizeof(ata_force_tbl[0])),
+				GFP_KERNEL);
 	if (!ata_force_tbl) {
 		printk(KERN_WARNING "ata: failed to extend force table, "
 		       "libata.force ignored\n");
diff --git a/drivers/ata/libata-pmp.c b/drivers/ata/libata-pmp.c
index 85aa76116a30..6c0e4181e6f9 100644
--- a/drivers/ata/libata-pmp.c
+++ b/drivers/ata/libata-pmp.c
@@ -340,7 +340,7 @@ static int sata_pmp_init_links (struct ata_port *ap, int nr_ports)
 	int i, err;
 
 	if (!pmp_link) {
-		pmp_link = kzalloc(sizeof(pmp_link[0]) * SATA_PMP_MAX_PORTS,
+		pmp_link = kzalloc(array_size(SATA_PMP_MAX_PORTS, sizeof(pmp_link[0])),
 				   GFP_NOIO);
 		if (!pmp_link)
 			return -ENOMEM;
diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 6ebc4e4820fc..337297a565e6 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2094,7 +2094,8 @@ static int fore200e_alloc_rx_buf(struct fore200e *fore200e)
 	    DPRINTK(2, "rx buffers %d / %d are being allocated\n", scheme, magn);
 
 	    /* allocate the array of receive buffers */
-	    buffer = bsq->buffer = kzalloc(nbr * sizeof(struct buffer), GFP_KERNEL);
+	    buffer = bsq->buffer = kzalloc(array_size(nbr, sizeof(struct buffer)),
+                                           GFP_KERNEL);
 
 	    if (buffer == NULL)
 		return -ENOMEM;
diff --git a/drivers/auxdisplay/cfag12864b.c b/drivers/auxdisplay/cfag12864b.c
index 41ce4bd96813..2b14e5647355 100644
--- a/drivers/auxdisplay/cfag12864b.c
+++ b/drivers/auxdisplay/cfag12864b.c
@@ -347,8 +347,8 @@ static int __init cfag12864b_init(void)
 		goto none;
 	}
 
-	cfag12864b_cache = kmalloc(sizeof(unsigned char) *
-		CFAG12864B_SIZE, GFP_KERNEL);
+	cfag12864b_cache = kmalloc(array_size(CFAG12864B_SIZE, sizeof(unsigned char)),
+				   GFP_KERNEL);
 	if (cfag12864b_cache == NULL) {
 		printk(KERN_ERR CFAG12864B_NAME ": ERROR: "
 			"can't alloc cache buffer (%i bytes)\n",
diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index 185f1ef00a7c..7533c27d152d 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -511,7 +511,8 @@ static void drbd_calc_cpu_mask(cpumask_var_t *cpu_mask)
 {
 	unsigned int *resources_per_cpu, min_index = ~0;
 
-	resources_per_cpu = kzalloc(nr_cpu_ids * sizeof(*resources_per_cpu), GFP_KERNEL);
+	resources_per_cpu = kzalloc(array_size(nr_cpu_ids, sizeof(*resources_per_cpu)),
+				    GFP_KERNEL);
 	if (resources_per_cpu) {
 		struct drbd_resource *resource;
 		unsigned int cpu, min = ~0;
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index c9d04497a415..13d89cbceacb 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -500,7 +500,8 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 
 		__rq_for_each_bio(bio, rq)
 			segments += bio_segments(bio);
-		bvec = kmalloc(sizeof(struct bio_vec) * segments, GFP_NOIO);
+		bvec = kmalloc(array_size(segments, sizeof(struct bio_vec)),
+			       GFP_NOIO);
 		if (!bvec)
 			return -EIO;
 		cmd->bvec = bvec;
diff --git a/drivers/block/null_blk.c b/drivers/block/null_blk.c
index a76553293a31..df02a9211ae3 100644
--- a/drivers/block/null_blk.c
+++ b/drivers/block/null_blk.c
@@ -1578,7 +1578,8 @@ static int setup_commands(struct nullb_queue *nq)
 		return -ENOMEM;
 
 	tag_size = ALIGN(nq->queue_depth, BITS_PER_LONG) / BITS_PER_LONG;
-	nq->tag_map = kzalloc(tag_size * sizeof(unsigned long), GFP_KERNEL);
+	nq->tag_map = kzalloc(array_size(tag_size, sizeof(unsigned long)),
+			      GFP_KERNEL);
 	if (!nq->tag_map) {
 		kfree(nq->cmds);
 		return -ENOMEM;
diff --git a/drivers/block/ps3vram.c b/drivers/block/ps3vram.c
index 6a55959cbf78..c52903761b13 100644
--- a/drivers/block/ps3vram.c
+++ b/drivers/block/ps3vram.c
@@ -407,8 +407,8 @@ static int ps3vram_cache_init(struct ps3_system_bus_device *dev)
 
 	priv->cache.page_count = CACHE_PAGE_COUNT;
 	priv->cache.page_size = CACHE_PAGE_SIZE;
-	priv->cache.tags = kzalloc(sizeof(struct ps3vram_tag) *
-				   CACHE_PAGE_COUNT, GFP_KERNEL);
+	priv->cache.tags = kzalloc(array_size(CACHE_PAGE_COUNT, sizeof(struct ps3vram_tag)),
+				   GFP_KERNEL);
 	if (!priv->cache.tags)
 		return -ENOMEM;
 
diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index 2a8e7813bd1a..c6469b956520 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -2217,10 +2217,10 @@ static int blkfront_setup_indirect(struct blkfront_ring_info *rinfo)
 	}
 
 	for (i = 0; i < BLK_RING_SIZE(info); i++) {
-		rinfo->shadow[i].grants_used = kzalloc(
-			sizeof(rinfo->shadow[i].grants_used[0]) * grants,
-			GFP_NOIO);
-		rinfo->shadow[i].sg = kzalloc(sizeof(rinfo->shadow[i].sg[0]) * psegs, GFP_NOIO);
+		rinfo->shadow[i].grants_used = kzalloc(array_size(grants, sizeof(rinfo->shadow[i].grants_used[0])),
+						       GFP_NOIO);
+		rinfo->shadow[i].sg = kzalloc(array_size(psegs, sizeof(rinfo->shadow[i].sg[0])),
+					      GFP_NOIO);
 		if (info->max_indirect_segments)
 			rinfo->shadow[i].indirect_grants = kzalloc(
 				sizeof(rinfo->shadow[i].indirect_grants[0]) *
diff --git a/drivers/cdrom/cdrom.c b/drivers/cdrom/cdrom.c
index 8327478effd0..3a56395710a1 100644
--- a/drivers/cdrom/cdrom.c
+++ b/drivers/cdrom/cdrom.c
@@ -2132,7 +2132,8 @@ static int cdrom_read_cdda_old(struct cdrom_device_info *cdi, __u8 __user *ubuf,
 	 */
 	nr = nframes;
 	do {
-		cgc.buffer = kmalloc(CD_FRAMESIZE_RAW * nr, GFP_KERNEL);
+		cgc.buffer = kmalloc(array_size(nr, CD_FRAMESIZE_RAW),
+				     GFP_KERNEL);
 		if (cgc.buffer)
 			break;
 
diff --git a/drivers/char/agp/isoch.c b/drivers/char/agp/isoch.c
index fc8e1bc3347d..affd779f6bbe 100644
--- a/drivers/char/agp/isoch.c
+++ b/drivers/char/agp/isoch.c
@@ -93,7 +93,7 @@ static int agp_3_5_isochronous_node_enable(struct agp_bridge_data *bridge,
 	 * We'll work with an array of isoch_data's (one for each
 	 * device in dev_list) throughout this function.
 	 */
-	if ((master = kmalloc(ndevs * sizeof(*master), GFP_KERNEL)) == NULL) {
+	if ((master = kmalloc(array_size(ndevs, sizeof(*master)), GFP_KERNEL)) == NULL) {
 		ret = -ENOMEM;
 		goto get_out;
 	}
diff --git a/drivers/char/agp/sgi-agp.c b/drivers/char/agp/sgi-agp.c
index 3051c73bc383..b5ab61a02f7e 100644
--- a/drivers/char/agp/sgi-agp.c
+++ b/drivers/char/agp/sgi-agp.c
@@ -280,8 +280,7 @@ static int agp_sgi_init(void)
 	else
 		return 0;
 
-	sgi_tioca_agp_bridges = kmalloc(tioca_gart_found *
-					sizeof(struct agp_bridge_data *),
+	sgi_tioca_agp_bridges = kmalloc(array_size(tioca_gart_found, sizeof(struct agp_bridge_data *)),
 					GFP_KERNEL);
 	if (!sgi_tioca_agp_bridges)
 		return -ENOMEM;
diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index 468f06134012..5ef7fc2f49d3 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -1902,12 +1902,14 @@ static int init_vqs(struct ports_device *portdev)
 	nr_ports = portdev->max_nr_ports;
 	nr_queues = use_multiport(portdev) ? (nr_ports + 1) * 2 : 2;
 
-	vqs = kmalloc(nr_queues * sizeof(struct virtqueue *), GFP_KERNEL);
-	io_callbacks = kmalloc(nr_queues * sizeof(vq_callback_t *), GFP_KERNEL);
-	io_names = kmalloc(nr_queues * sizeof(char *), GFP_KERNEL);
-	portdev->in_vqs = kmalloc(nr_ports * sizeof(struct virtqueue *),
+	vqs = kmalloc(array_size(nr_queues, sizeof(struct virtqueue *)),
+		      GFP_KERNEL);
+	io_callbacks = kmalloc(array_size(nr_queues, sizeof(vq_callback_t *)),
+			       GFP_KERNEL);
+	io_names = kmalloc(array_size(nr_queues, sizeof(char *)), GFP_KERNEL);
+	portdev->in_vqs = kmalloc(array_size(nr_ports, sizeof(struct virtqueue *)),
 				  GFP_KERNEL);
-	portdev->out_vqs = kmalloc(nr_ports * sizeof(struct virtqueue *),
+	portdev->out_vqs = kmalloc(array_size(nr_ports, sizeof(struct virtqueue *)),
 				   GFP_KERNEL);
 	if (!vqs || !io_callbacks || !io_names || !portdev->in_vqs ||
 	    !portdev->out_vqs) {
diff --git a/drivers/clk/renesas/clk-r8a7740.c b/drivers/clk/renesas/clk-r8a7740.c
index d074f8e982d0..d17fb702258b 100644
--- a/drivers/clk/renesas/clk-r8a7740.c
+++ b/drivers/clk/renesas/clk-r8a7740.c
@@ -161,7 +161,7 @@ static void __init r8a7740_cpg_clocks_init(struct device_node *np)
 	}
 
 	cpg = kzalloc(sizeof(*cpg), GFP_KERNEL);
-	clks = kzalloc(num_clks * sizeof(*clks), GFP_KERNEL);
+	clks = kzalloc(array_size(num_clks, sizeof(*clks)), GFP_KERNEL);
 	if (cpg == NULL || clks == NULL) {
 		/* We're leaking memory on purpose, there's no point in cleaning
 		 * up as the system won't boot anyway.
diff --git a/drivers/clk/renesas/clk-r8a7779.c b/drivers/clk/renesas/clk-r8a7779.c
index 27fbfafaf2cd..62671236b5d7 100644
--- a/drivers/clk/renesas/clk-r8a7779.c
+++ b/drivers/clk/renesas/clk-r8a7779.c
@@ -138,7 +138,7 @@ static void __init r8a7779_cpg_clocks_init(struct device_node *np)
 	}
 
 	cpg = kzalloc(sizeof(*cpg), GFP_KERNEL);
-	clks = kzalloc(CPG_NUM_CLOCKS * sizeof(*clks), GFP_KERNEL);
+	clks = kzalloc(array_size(CPG_NUM_CLOCKS, sizeof(*clks)), GFP_KERNEL);
 	if (cpg == NULL || clks == NULL) {
 		/* We're leaking memory on purpose, there's no point in cleaning
 		 * up as the system won't boot anyway.
diff --git a/drivers/clk/renesas/clk-rcar-gen2.c b/drivers/clk/renesas/clk-rcar-gen2.c
index ee32a022e6da..2c664643b05a 100644
--- a/drivers/clk/renesas/clk-rcar-gen2.c
+++ b/drivers/clk/renesas/clk-rcar-gen2.c
@@ -417,7 +417,7 @@ static void __init rcar_gen2_cpg_clocks_init(struct device_node *np)
 	}
 
 	cpg = kzalloc(sizeof(*cpg), GFP_KERNEL);
-	clks = kzalloc(num_clks * sizeof(*clks), GFP_KERNEL);
+	clks = kzalloc(array_size(num_clks, sizeof(*clks)), GFP_KERNEL);
 	if (cpg == NULL || clks == NULL) {
 		/* We're leaking memory on purpose, there's no point in cleaning
 		 * up as the system won't boot anyway.
diff --git a/drivers/clk/renesas/clk-rz.c b/drivers/clk/renesas/clk-rz.c
index 67dd712aa723..c366aae95154 100644
--- a/drivers/clk/renesas/clk-rz.c
+++ b/drivers/clk/renesas/clk-rz.c
@@ -97,7 +97,7 @@ static void __init rz_cpg_clocks_init(struct device_node *np)
 		return;
 
 	cpg = kzalloc(sizeof(*cpg), GFP_KERNEL);
-	clks = kzalloc(num_clks * sizeof(*clks), GFP_KERNEL);
+	clks = kzalloc(array_size(num_clks, sizeof(*clks)), GFP_KERNEL);
 	BUG_ON(!cpg || !clks);
 
 	cpg->data.clks = clks;
diff --git a/drivers/clk/rockchip/clk-rockchip.c b/drivers/clk/rockchip/clk-rockchip.c
index 2c9bb81144c9..fe1e06c1526f 100644
--- a/drivers/clk/rockchip/clk-rockchip.c
+++ b/drivers/clk/rockchip/clk-rockchip.c
@@ -58,7 +58,8 @@ static void __init rk2928_gate_clk_init(struct device_node *node)
 		return;
 	}
 
-	clk_data->clks = kzalloc(qty * sizeof(struct clk *), GFP_KERNEL);
+	clk_data->clks = kzalloc(array_size(qty, sizeof(struct clk *)),
+				 GFP_KERNEL);
 	if (!clk_data->clks) {
 		kfree(clk_data);
 		iounmap(reg);
diff --git a/drivers/clk/st/clkgen-fsyn.c b/drivers/clk/st/clkgen-fsyn.c
index 14819d919df1..ddd6caa6ab19 100644
--- a/drivers/clk/st/clkgen-fsyn.c
+++ b/drivers/clk/st/clkgen-fsyn.c
@@ -874,7 +874,7 @@ static void __init st_of_create_quadfs_fsynths(
 		return;
 
 	clk_data->clk_num = QUADFS_MAX_CHAN;
-	clk_data->clks = kzalloc(QUADFS_MAX_CHAN * sizeof(struct clk *),
+	clk_data->clks = kzalloc(array_size(QUADFS_MAX_CHAN, sizeof(struct clk *)),
 				 GFP_KERNEL);
 
 	if (!clk_data->clks) {
diff --git a/drivers/clk/tegra/clk.c b/drivers/clk/tegra/clk.c
index ba923f0d5953..2115110745c5 100644
--- a/drivers/clk/tegra/clk.c
+++ b/drivers/clk/tegra/clk.c
@@ -223,7 +223,7 @@ struct clk ** __init tegra_clk_init(void __iomem *regs, int num, int banks)
 
 	periph_banks = banks;
 
-	clks = kzalloc(num * sizeof(struct clk *), GFP_KERNEL);
+	clks = kzalloc(array_size(num, sizeof(struct clk *)), GFP_KERNEL);
 	if (!clks)
 		kfree(periph_clk_enb_refcnt);
 
diff --git a/drivers/cpufreq/arm_big_little.c b/drivers/cpufreq/arm_big_little.c
index 1d7ef5fc1977..d9f5a4946a1b 100644
--- a/drivers/cpufreq/arm_big_little.c
+++ b/drivers/cpufreq/arm_big_little.c
@@ -280,7 +280,7 @@ static int merge_cluster_tables(void)
 	for (i = 0; i < MAX_CLUSTERS; i++)
 		count += get_table_count(freq_table[i]);
 
-	table = kzalloc(sizeof(*table) * count, GFP_KERNEL);
+	table = kzalloc(array_size(count, sizeof(*table)), GFP_KERNEL);
 	if (!table)
 		return -ENOMEM;
 
diff --git a/drivers/cpufreq/s3c24xx-cpufreq.c b/drivers/cpufreq/s3c24xx-cpufreq.c
index 909bd6e27639..97a30ebe86d4 100644
--- a/drivers/cpufreq/s3c24xx-cpufreq.c
+++ b/drivers/cpufreq/s3c24xx-cpufreq.c
@@ -562,7 +562,7 @@ static int s3c_cpufreq_build_freq(void)
 	size = cpu_cur.info->calc_freqtable(&cpu_cur, NULL, 0);
 	size++;
 
-	ftab = kzalloc(sizeof(*ftab) * size, GFP_KERNEL);
+	ftab = kzalloc(array_size(size, sizeof(*ftab)), GFP_KERNEL);
 	if (!ftab)
 		return -ENOMEM;
 
diff --git a/drivers/crypto/amcc/crypto4xx_core.c b/drivers/crypto/amcc/crypto4xx_core.c
index 76f459ad2821..db1ce09759a5 100644
--- a/drivers/crypto/amcc/crypto4xx_core.c
+++ b/drivers/crypto/amcc/crypto4xx_core.c
@@ -179,8 +179,8 @@ static u32 crypto4xx_build_pdr(struct crypto4xx_device *dev)
 	if (!dev->pdr)
 		return -ENOMEM;
 
-	dev->pdr_uinfo = kzalloc(sizeof(struct pd_uinfo) * PPC4XX_NUM_PD,
-				GFP_KERNEL);
+	dev->pdr_uinfo = kzalloc(array_size(PPC4XX_NUM_PD, sizeof(struct pd_uinfo)),
+				 GFP_KERNEL);
 	if (!dev->pdr_uinfo) {
 		dma_free_coherent(dev->core_dev->device,
 				  sizeof(struct ce_pd) * PPC4XX_NUM_PD,
diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
index 5a75be43950f..b057bc7496ab 100644
--- a/drivers/crypto/chelsio/chtls/chtls_io.c
+++ b/drivers/crypto/chelsio/chtls/chtls_io.c
@@ -240,7 +240,8 @@ static int tls_copy_ivs(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* generate the  IVs */
-	ivs = kmalloc(number_of_ivs * CIPHER_BLOCK_SIZE, GFP_ATOMIC);
+	ivs = kmalloc(array_size(CIPHER_BLOCK_SIZE, number_of_ivs),
+		      GFP_ATOMIC);
 	if (!ivs)
 		return -ENOMEM;
 	get_random_bytes(ivs, number_of_ivs * CIPHER_BLOCK_SIZE);
diff --git a/drivers/crypto/n2_core.c b/drivers/crypto/n2_core.c
index 80e9c842aad4..3dc59d88bd80 100644
--- a/drivers/crypto/n2_core.c
+++ b/drivers/crypto/n2_core.c
@@ -1919,12 +1919,12 @@ static int grab_global_resources(void)
 		goto out_hvapi_release;
 
 	err = -ENOMEM;
-	cpu_to_cwq = kzalloc(sizeof(struct spu_queue *) * NR_CPUS,
+	cpu_to_cwq = kzalloc(array_size(NR_CPUS, sizeof(struct spu_queue *)),
 			     GFP_KERNEL);
 	if (!cpu_to_cwq)
 		goto out_queue_cache_destroy;
 
-	cpu_to_mau = kzalloc(sizeof(struct spu_queue *) * NR_CPUS,
+	cpu_to_mau = kzalloc(array_size(NR_CPUS, sizeof(struct spu_queue *)),
 			     GFP_KERNEL);
 	if (!cpu_to_mau)
 		goto out_free_cwq_table;
diff --git a/drivers/dma/bestcomm/bestcomm.c b/drivers/dma/bestcomm/bestcomm.c
index 7a67b8345092..cfb395e3f3c9 100644
--- a/drivers/dma/bestcomm/bestcomm.c
+++ b/drivers/dma/bestcomm/bestcomm.c
@@ -87,7 +87,8 @@ bcom_task_alloc(int bd_count, int bd_size, int priv_size)
 
 	/* Init the BDs, if needed */
 	if (bd_count) {
-		tsk->cookie = kmalloc(sizeof(void*) * bd_count, GFP_KERNEL);
+		tsk->cookie = kmalloc(array_size(bd_count, sizeof(void *)),
+				      GFP_KERNEL);
 		if (!tsk->cookie)
 			goto error;
 
diff --git a/drivers/dma/ioat/init.c b/drivers/dma/ioat/init.c
index 7792a9186f9c..f24df47308ad 100644
--- a/drivers/dma/ioat/init.c
+++ b/drivers/dma/ioat/init.c
@@ -322,10 +322,10 @@ static int ioat_dma_self_test(struct ioatdma_device *ioat_dma)
 	unsigned long tmo;
 	unsigned long flags;
 
-	src = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, GFP_KERNEL);
+	src = kzalloc(array_size(IOAT_TEST_SIZE, sizeof(u8)), GFP_KERNEL);
 	if (!src)
 		return -ENOMEM;
-	dest = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, GFP_KERNEL);
+	dest = kzalloc(array_size(IOAT_TEST_SIZE, sizeof(u8)), GFP_KERNEL);
 	if (!dest) {
 		kfree(src);
 		return -ENOMEM;
diff --git a/drivers/dma/mv_xor.c b/drivers/dma/mv_xor.c
index 1993889003fd..dd7583a1d4ad 100644
--- a/drivers/dma/mv_xor.c
+++ b/drivers/dma/mv_xor.c
@@ -777,11 +777,11 @@ static int mv_chan_memcpy_self_test(struct mv_xor_chan *mv_chan)
 	struct dmaengine_unmap_data *unmap;
 	int err = 0;
 
-	src = kmalloc(sizeof(u8) * PAGE_SIZE, GFP_KERNEL);
+	src = kmalloc(array_size(PAGE_SIZE, sizeof(u8)), GFP_KERNEL);
 	if (!src)
 		return -ENOMEM;
 
-	dest = kzalloc(sizeof(u8) * PAGE_SIZE, GFP_KERNEL);
+	dest = kzalloc(array_size(PAGE_SIZE, sizeof(u8)), GFP_KERNEL);
 	if (!dest) {
 		kfree(src);
 		return -ENOMEM;
diff --git a/drivers/dma/pl330.c b/drivers/dma/pl330.c
index de1fd59fe136..96238a30e804 100644
--- a/drivers/dma/pl330.c
+++ b/drivers/dma/pl330.c
@@ -2881,7 +2881,8 @@ pl330_probe(struct amba_device *adev, const struct amba_id *id)
 
 	pl330->num_peripherals = num_chan;
 
-	pl330->peripherals = kzalloc(num_chan * sizeof(*pch), GFP_KERNEL);
+	pl330->peripherals = kzalloc(array_size(num_chan, sizeof(*pch)),
+				     GFP_KERNEL);
 	if (!pl330->peripherals) {
 		ret = -ENOMEM;
 		goto probe_err2;
diff --git a/drivers/dma/xilinx/zynqmp_dma.c b/drivers/dma/xilinx/zynqmp_dma.c
index f14645817ed8..b741d6b1192c 100644
--- a/drivers/dma/xilinx/zynqmp_dma.c
+++ b/drivers/dma/xilinx/zynqmp_dma.c
@@ -471,7 +471,7 @@ static int zynqmp_dma_alloc_chan_resources(struct dma_chan *dchan)
 	if (ret < 0)
 		return ret;
 
-	chan->sw_desc_pool = kzalloc(sizeof(*desc) * ZYNQMP_DMA_NUM_DESCS,
+	chan->sw_desc_pool = kzalloc(array_size(ZYNQMP_DMA_NUM_DESCS, sizeof(*desc)),
 				     GFP_KERNEL);
 	if (!chan->sw_desc_pool)
 		return -ENOMEM;
diff --git a/drivers/extcon/extcon.c b/drivers/extcon/extcon.c
index 8bff5fd18185..498b2d29d52f 100644
--- a/drivers/extcon/extcon.c
+++ b/drivers/extcon/extcon.c
@@ -1184,8 +1184,8 @@ int extcon_dev_register(struct extcon_dev *edev)
 			goto err_muex;
 		}
 
-		edev->d_attrs_muex = kzalloc(sizeof(struct device_attribute) *
-					     index, GFP_KERNEL);
+		edev->d_attrs_muex = kzalloc(array_size(index, sizeof(struct device_attribute)),
+					     GFP_KERNEL);
 		if (!edev->d_attrs_muex) {
 			ret = -ENOMEM;
 			kfree(edev->attrs_muex);
diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
index 38c0aa60b2cb..c0205cb3d77d 100644
--- a/drivers/firewire/core-iso.c
+++ b/drivers/firewire/core-iso.c
@@ -45,7 +45,7 @@ int fw_iso_buffer_alloc(struct fw_iso_buffer *buffer, int page_count)
 
 	buffer->page_count = 0;
 	buffer->page_count_mapped = 0;
-	buffer->pages = kmalloc(page_count * sizeof(buffer->pages[0]),
+	buffer->pages = kmalloc(array_size(page_count, sizeof(buffer->pages[0])),
 				GFP_KERNEL);
 	if (buffer->pages == NULL)
 		return -ENOMEM;
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 60e75e6d9104..24ac0ef25695 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1121,7 +1121,7 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
 
-	ptrptr = kmalloc(sizeof(void *) * num_packets, GFP_KERNEL);
+	ptrptr = kmalloc(array_size(num_packets, sizeof(void *)), GFP_KERNEL);
 	if (!ptrptr) {
 		retval = -ENOMEM;
 		goto failed;
diff --git a/drivers/firmware/dell_rbu.c b/drivers/firmware/dell_rbu.c
index 2f452f1f7c8a..44b7755dc8f1 100644
--- a/drivers/firmware/dell_rbu.c
+++ b/drivers/firmware/dell_rbu.c
@@ -146,8 +146,8 @@ static int create_packet(void *data, size_t length)
 	packet_array_size = max(
 	       		(unsigned int)(allocation_floor / rbu_data.packetsize),
 			(unsigned int)1);
-	invalid_addr_packet_array = kzalloc(packet_array_size * sizeof(void*),
-						GFP_KERNEL);
+	invalid_addr_packet_array = kzalloc(array_size(packet_array_size, sizeof(void *)),
+					    GFP_KERNEL);
 
 	if (!invalid_addr_packet_array) {
 		printk(KERN_WARNING
diff --git a/drivers/firmware/efi/capsule.c b/drivers/firmware/efi/capsule.c
index 901b9306bf94..9e8dd2805b04 100644
--- a/drivers/firmware/efi/capsule.c
+++ b/drivers/firmware/efi/capsule.c
@@ -231,7 +231,8 @@ int efi_capsule_update(efi_capsule_header_t *capsule, phys_addr_t *pages)
 	count = DIV_ROUND_UP(imagesize, PAGE_SIZE);
 	sg_count = sg_pages_num(count);
 
-	sg_pages = kzalloc(sg_count * sizeof(*sg_pages), GFP_KERNEL);
+	sg_pages = kzalloc(array_size(sg_count, sizeof(*sg_pages)),
+			   GFP_KERNEL);
 	if (!sg_pages)
 		return -ENOMEM;
 
diff --git a/drivers/fmc/fmc-sdb.c b/drivers/fmc/fmc-sdb.c
index ffdc1762b580..6a67ceeb410d 100644
--- a/drivers/fmc/fmc-sdb.c
+++ b/drivers/fmc/fmc-sdb.c
@@ -48,8 +48,10 @@ static struct sdb_array *__fmc_scan_sdb_tree(struct fmc_device *fmc,
 	arr = kzalloc(sizeof(*arr), GFP_KERNEL);
 	if (!arr)
 		return ERR_PTR(-ENOMEM);
-	arr->record = kzalloc(sizeof(arr->record[0]) * n, GFP_KERNEL);
-	arr->subtree = kzalloc(sizeof(arr->subtree[0]) * n, GFP_KERNEL);
+	arr->record = kzalloc(array_size(n, sizeof(arr->record[0])),
+			      GFP_KERNEL);
+	arr->subtree = kzalloc(array_size(n, sizeof(arr->subtree[0])),
+			       GFP_KERNEL);
 	if (!arr->record || !arr->subtree) {
 		kfree(arr->record);
 		kfree(arr->subtree);
diff --git a/drivers/gpio/gpio-ml-ioh.c b/drivers/gpio/gpio-ml-ioh.c
index b3678bd1c120..6c2b313d932f 100644
--- a/drivers/gpio/gpio-ml-ioh.c
+++ b/drivers/gpio/gpio-ml-ioh.c
@@ -443,7 +443,7 @@ static int ioh_gpio_probe(struct pci_dev *pdev,
 		goto err_iomap;
 	}
 
-	chip_save = kzalloc(sizeof(*chip) * 8, GFP_KERNEL);
+	chip_save = kzalloc(array_size(8, sizeof(*chip)), GFP_KERNEL);
 	if (chip_save == NULL) {
 		ret = -ENOMEM;
 		goto err_kzalloc;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_acp.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_acp.c
index a29362f9ef41..bdddde996444 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_acp.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_acp.c
@@ -311,20 +311,22 @@ static int acp_hw_init(void *handle)
 		pm_genpd_init(&adev->acp.acp_genpd->gpd, NULL, false);
 	}
 
-	adev->acp.acp_cell = kzalloc(sizeof(struct mfd_cell) * ACP_DEVS,
-							GFP_KERNEL);
+	adev->acp.acp_cell = kzalloc(array_size(ACP_DEVS, sizeof(struct mfd_cell)),
+				     GFP_KERNEL);
 
 	if (adev->acp.acp_cell == NULL)
 		return -ENOMEM;
 
-	adev->acp.acp_res = kzalloc(sizeof(struct resource) * 4, GFP_KERNEL);
+	adev->acp.acp_res = kzalloc(array_size(4, sizeof(struct resource)),
+				    GFP_KERNEL);
 
 	if (adev->acp.acp_res == NULL) {
 		kfree(adev->acp.acp_cell);
 		return -ENOMEM;
 	}
 
-	i2s_pdata = kzalloc(sizeof(struct i2s_platform_data) * 2, GFP_KERNEL);
+	i2s_pdata = kzalloc(array_size(2, sizeof(struct i2s_platform_data)),
+			    GFP_KERNEL);
 	if (i2s_pdata == NULL) {
 		kfree(adev->acp.acp_res);
 		kfree(adev->acp.acp_cell);
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_test.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_test.c
index 2dbe87591f81..e008106321be 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_test.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_test.c
@@ -52,7 +52,7 @@ static void amdgpu_do_test_moves(struct amdgpu_device *adev)
 		n -= adev->irq.ih.ring_size;
 	n /= size;
 
-	gtt_obj = kzalloc(n * sizeof(*gtt_obj), GFP_KERNEL);
+	gtt_obj = kzalloc(array_size(n, sizeof(*gtt_obj)), GFP_KERNEL);
 	if (!gtt_obj) {
 		DRM_ERROR("Failed to allocate %d pointers\n", n);
 		r = 1;
diff --git a/drivers/gpu/drm/amd/amdgpu/ci_dpm.c b/drivers/gpu/drm/amd/amdgpu/ci_dpm.c
index 47ef3e6e7178..0c1e6ae61ff2 100644
--- a/drivers/gpu/drm/amd/amdgpu/ci_dpm.c
+++ b/drivers/gpu/drm/amd/amdgpu/ci_dpm.c
@@ -5927,7 +5927,8 @@ static int ci_dpm_init(struct amdgpu_device *adev)
 	ci_set_private_data_variables_based_on_pptable(adev);
 
 	adev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries =
-		kzalloc(4 * sizeof(struct amdgpu_clock_voltage_dependency_entry), GFP_KERNEL);
+		kzalloc(array_size(4, sizeof(struct amdgpu_clock_voltage_dependency_entry)),
+			GFP_KERNEL);
 	if (!adev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries) {
 		ci_dpm_fini(adev);
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/amd/amdgpu/si_dpm.c b/drivers/gpu/drm/amd/amdgpu/si_dpm.c
index 797d505bf9ee..6e12d8f28859 100644
--- a/drivers/gpu/drm/amd/amdgpu/si_dpm.c
+++ b/drivers/gpu/drm/amd/amdgpu/si_dpm.c
@@ -7346,7 +7346,8 @@ static int si_dpm_init(struct amdgpu_device *adev)
 		return ret;
 
 	adev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries =
-		kzalloc(4 * sizeof(struct amdgpu_clock_voltage_dependency_entry), GFP_KERNEL);
+		kzalloc(array_size(4, sizeof(struct amdgpu_clock_voltage_dependency_entry)),
+			GFP_KERNEL);
 	if (!adev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries) {
 		amdgpu_free_extended_power_table(adev);
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_helpers.c b/drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_helpers.c
index ca0b08bfa2cf..5c4d44153514 100644
--- a/drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_helpers.c
+++ b/drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_helpers.c
@@ -440,7 +440,7 @@ bool dm_helpers_submit_i2c(
 		return false;
 	}
 
-	msgs = kzalloc(num * sizeof(struct i2c_msg), GFP_KERNEL);
+	msgs = kzalloc(array_size(num, sizeof(struct i2c_msg)), GFP_KERNEL);
 
 	if (!msgs)
 		return false;
diff --git a/drivers/gpu/drm/amd/display/dc/basics/logger.c b/drivers/gpu/drm/amd/display/dc/basics/logger.c
index 31bee054f43a..4ce5e98f3688 100644
--- a/drivers/gpu/drm/amd/display/dc/basics/logger.c
+++ b/drivers/gpu/drm/amd/display/dc/basics/logger.c
@@ -364,7 +364,7 @@ void dm_logger_open(
 	entry->type = log_type;
 	entry->logger = logger;
 
-	entry->buf = kzalloc(DAL_LOGGER_BUFFER_MAX_SIZE * sizeof(char),
+	entry->buf = kzalloc(array_size(DAL_LOGGER_BUFFER_MAX_SIZE, sizeof(char)),
 			     GFP_KERNEL);
 
 	entry->buf_offset = 0;
diff --git a/drivers/gpu/drm/amd/display/dc/basics/vector.c b/drivers/gpu/drm/amd/display/dc/basics/vector.c
index 217b8f1f7bf6..79f23ae28bf7 100644
--- a/drivers/gpu/drm/amd/display/dc/basics/vector.c
+++ b/drivers/gpu/drm/amd/display/dc/basics/vector.c
@@ -40,7 +40,8 @@ bool dal_vector_construct(
 		return false;
 	}
 
-	vector->container = kzalloc(struct_size * capacity, GFP_KERNEL);
+	vector->container = kzalloc(array_size(capacity, struct_size),
+				    GFP_KERNEL);
 	if (vector->container == NULL)
 		return false;
 	vector->capacity = capacity;
@@ -67,7 +68,8 @@ bool dal_vector_presized_costruct(
 		return false;
 	}
 
-	vector->container = kzalloc(struct_size * count, GFP_KERNEL);
+	vector->container = kzalloc(array_size(count, struct_size),
+				    GFP_KERNEL);
 
 	if (vector->container == NULL)
 		return false;
diff --git a/drivers/gpu/drm/amd/display/dc/gpio/gpio_service.c b/drivers/gpu/drm/amd/display/dc/gpio/gpio_service.c
index 80038e0e610f..989c2224660e 100644
--- a/drivers/gpu/drm/amd/display/dc/gpio/gpio_service.c
+++ b/drivers/gpu/drm/amd/display/dc/gpio/gpio_service.c
@@ -98,7 +98,7 @@ struct gpio_service *dal_gpio_service_create(
 			if (number_of_bits) {
 				uint32_t index_of_uint = 0;
 
-				slot = kzalloc(number_of_uints * sizeof(uint32_t),
+				slot = kzalloc(array_size(number_of_uints, sizeof(uint32_t)),
 					       GFP_KERNEL);
 
 				if (!slot) {
diff --git a/drivers/gpu/drm/amd/display/modules/freesync/freesync.c b/drivers/gpu/drm/amd/display/modules/freesync/freesync.c
index 27d4003aa2c7..f7fd1732f4a2 100644
--- a/drivers/gpu/drm/amd/display/modules/freesync/freesync.c
+++ b/drivers/gpu/drm/amd/display/modules/freesync/freesync.c
@@ -155,8 +155,8 @@ struct mod_freesync *mod_freesync_create(struct dc *dc)
 	if (core_freesync == NULL)
 		goto fail_alloc_context;
 
-	core_freesync->map = kzalloc(sizeof(struct freesync_entity) * MOD_FREESYNC_MAX_CONCURRENT_STREAMS,
-					GFP_KERNEL);
+	core_freesync->map = kzalloc(array_size(MOD_FREESYNC_MAX_CONCURRENT_STREAMS, sizeof(struct freesync_entity)),
+				     GFP_KERNEL);
 
 	if (core_freesync->map == NULL)
 		goto fail_alloc_map;
diff --git a/drivers/gpu/drm/amd/powerplay/hwmgr/pp_psm.c b/drivers/gpu/drm/amd/powerplay/hwmgr/pp_psm.c
index 0f2851b5b368..fc45b805dc10 100644
--- a/drivers/gpu/drm/amd/powerplay/hwmgr/pp_psm.c
+++ b/drivers/gpu/drm/amd/powerplay/hwmgr/pp_psm.c
@@ -50,7 +50,7 @@ int psm_init_power_state_table(struct pp_hwmgr *hwmgr)
 		return 0;
 	}
 
-	hwmgr->ps = kzalloc(size * table_entries, GFP_KERNEL);
+	hwmgr->ps = kzalloc(array_size(table_entries, size), GFP_KERNEL);
 	if (hwmgr->ps == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/i915/gvt/vgpu.c b/drivers/gpu/drm/i915/gvt/vgpu.c
index 2e0a02a80fe4..9efeb37d2242 100644
--- a/drivers/gpu/drm/i915/gvt/vgpu.c
+++ b/drivers/gpu/drm/i915/gvt/vgpu.c
@@ -121,7 +121,7 @@ int intel_gvt_init_vgpu_types(struct intel_gvt *gvt)
 	high_avail = gvt_hidden_sz(gvt) - HOST_HIGH_GM_SIZE;
 	num_types = sizeof(vgpu_types) / sizeof(vgpu_types[0]);
 
-	gvt->types = kzalloc(num_types * sizeof(struct intel_vgpu_type),
+	gvt->types = kzalloc(array_size(num_types, sizeof(struct intel_vgpu_type)),
 			     GFP_KERNEL);
 	if (!gvt->types)
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/i915/intel_hdcp.c b/drivers/gpu/drm/i915/intel_hdcp.c
index 14ca5d3057a7..4a9463205eae 100644
--- a/drivers/gpu/drm/i915/intel_hdcp.c
+++ b/drivers/gpu/drm/i915/intel_hdcp.c
@@ -181,7 +181,8 @@ int intel_hdcp_auth_downstream(struct intel_digital_port *intel_dig_port,
 	if (num_downstream == 0)
 		return -EINVAL;
 
-	ksv_fifo = kzalloc(num_downstream * DRM_HDCP_KSV_LEN, GFP_KERNEL);
+	ksv_fifo = kzalloc(array_size(DRM_HDCP_KSV_LEN, num_downstream),
+			   GFP_KERNEL);
 	if (!ksv_fifo)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/nouveau/nvkm/core/event.c b/drivers/gpu/drm/nouveau/nvkm/core/event.c
index 4e8d3fa042df..5e44bbb74177 100644
--- a/drivers/gpu/drm/nouveau/nvkm/core/event.c
+++ b/drivers/gpu/drm/nouveau/nvkm/core/event.c
@@ -84,7 +84,7 @@ int
 nvkm_event_init(const struct nvkm_event_func *func, int types_nr, int index_nr,
 		struct nvkm_event *event)
 {
-	event->refs = kzalloc(sizeof(*event->refs) * index_nr * types_nr,
+	event->refs = kzalloc(array3_size(index_nr, types_nr, sizeof(*event->refs)),
 			      GFP_KERNEL);
 	if (!event->refs)
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/bios/iccsense.c b/drivers/gpu/drm/nouveau/nvkm/subdev/bios/iccsense.c
index 73e463ed55c3..3d63dd153a93 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/bios/iccsense.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/bios/iccsense.c
@@ -73,7 +73,8 @@ nvbios_iccsense_parse(struct nvkm_bios *bios, struct nvbios_iccsense *iccsense)
 	}
 
 	iccsense->nr_entry = cnt;
-	iccsense->rail = kmalloc(sizeof(struct pwr_rail_t) * cnt, GFP_KERNEL);
+	iccsense->rail = kmalloc(array_size(cnt, sizeof(struct pwr_rail_t)),
+				 GFP_KERNEL);
 	if (!iccsense->rail)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/fb/ramgt215.c b/drivers/gpu/drm/nouveau/nvkm/subdev/fb/ramgt215.c
index 920b3d347803..df0c370c850d 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/fb/ramgt215.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/fb/ramgt215.c
@@ -171,7 +171,7 @@ gt215_link_train(struct gt215_ram *ram)
 		return -ENOSYS;
 
 	/* XXX: Multiple partitions? */
-	result = kmalloc(64 * sizeof(u32), GFP_KERNEL);
+	result = kmalloc(array_size(64, sizeof(u32)), GFP_KERNEL);
 	if (!result)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/mem.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/mem.c
index 39808489f21d..51aeb655d84b 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/mem.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/mem.c
@@ -191,9 +191,9 @@ nvkm_mem_new_host(struct nvkm_mmu *mmu, int type, u8 page, u64 size,
 	nvkm_memory_ctor(&nvkm_mem_dma, &mem->memory);
 	size = ALIGN(size, PAGE_SIZE) >> PAGE_SHIFT;
 
-	if (!(mem->mem = kvmalloc(sizeof(*mem->mem) * size, GFP_KERNEL)))
+	if (!(mem->mem = kvmalloc(array_size(size, sizeof(*mem->mem)), GFP_KERNEL)))
 		return -ENOMEM;
-	if (!(mem->dma = kvmalloc(sizeof(*mem->dma) * size, GFP_KERNEL)))
+	if (!(mem->dma = kvmalloc(array_size(size, sizeof(*mem->dma)), GFP_KERNEL)))
 		return -ENOMEM;
 
 	if (mmu->dma_bits > 32)
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
index 1c12e58f44c2..c873505bfb7a 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
@@ -59,7 +59,8 @@ nvkm_vmm_pt_new(const struct nvkm_vmm_desc *desc, bool sparse,
 	pgt->sparse = sparse;
 
 	if (desc->type == PGD) {
-		pgt->pde = kvzalloc(sizeof(*pgt->pde) * pten, GFP_KERNEL);
+		pgt->pde = kvzalloc(array_size(pten, sizeof(*pgt->pde)),
+				    GFP_KERNEL);
 		if (!pgt->pde) {
 			kfree(pgt);
 			return NULL;
diff --git a/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c b/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
index f9fa1c90b35c..c6ad066c9ccf 100644
--- a/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
+++ b/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
@@ -936,7 +936,7 @@ int tiler_map_show(struct seq_file *s, void *arg)
 	h_adj = omap_dmm->container_height / ydiv;
 	w_adj = omap_dmm->container_width / xdiv;
 
-	map = kmalloc(h_adj * sizeof(*map), GFP_KERNEL);
+	map = kmalloc(array_size(h_adj, sizeof(*map)), GFP_KERNEL);
 	global_map = kmalloc((w_adj + 1) * h_adj, GFP_KERNEL);
 
 	if (!map || !global_map)
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 0faf042b82e1..f0fef82ac6f2 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -244,7 +244,8 @@ static int omap_gem_attach_pages(struct drm_gem_object *obj)
 	 * DSS, GPU, etc. are not cache coherent:
 	 */
 	if (omap_obj->flags & (OMAP_BO_WC|OMAP_BO_UNCACHED)) {
-		addrs = kmalloc(npages * sizeof(*addrs), GFP_KERNEL);
+		addrs = kmalloc(array_size(npages, sizeof(*addrs)),
+				GFP_KERNEL);
 		if (!addrs) {
 			ret = -ENOMEM;
 			goto free_pages;
@@ -268,7 +269,8 @@ static int omap_gem_attach_pages(struct drm_gem_object *obj)
 			}
 		}
 	} else {
-		addrs = kzalloc(npages * sizeof(*addrs), GFP_KERNEL);
+		addrs = kzalloc(array_size(npages, sizeof(*addrs)),
+				GFP_KERNEL);
 		if (!addrs) {
 			ret = -ENOMEM;
 			goto free_pages;
diff --git a/drivers/gpu/drm/radeon/btc_dpm.c b/drivers/gpu/drm/radeon/btc_dpm.c
index 95652e643da1..22f816799437 100644
--- a/drivers/gpu/drm/radeon/btc_dpm.c
+++ b/drivers/gpu/drm/radeon/btc_dpm.c
@@ -2581,7 +2581,8 @@ int btc_dpm_init(struct radeon_device *rdev)
 		return ret;
 
 	rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries =
-		kzalloc(4 * sizeof(struct radeon_clock_voltage_dependency_entry), GFP_KERNEL);
+		kzalloc(array_size(4, sizeof(struct radeon_clock_voltage_dependency_entry)),
+			GFP_KERNEL);
 	if (!rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries) {
 		r600_free_extended_power_table(rdev);
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/radeon/ci_dpm.c b/drivers/gpu/drm/radeon/ci_dpm.c
index 7e1b04dc5593..bdefba5d7287 100644
--- a/drivers/gpu/drm/radeon/ci_dpm.c
+++ b/drivers/gpu/drm/radeon/ci_dpm.c
@@ -5770,7 +5770,8 @@ int ci_dpm_init(struct radeon_device *rdev)
 	ci_set_private_data_variables_based_on_pptable(rdev);
 
 	rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries =
-		kzalloc(4 * sizeof(struct radeon_clock_voltage_dependency_entry), GFP_KERNEL);
+		kzalloc(array_size(4, sizeof(struct radeon_clock_voltage_dependency_entry)),
+			GFP_KERNEL);
 	if (!rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries) {
 		ci_dpm_fini(rdev);
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/radeon/ni_dpm.c b/drivers/gpu/drm/radeon/ni_dpm.c
index 9416e72f86aa..021ca86432b0 100644
--- a/drivers/gpu/drm/radeon/ni_dpm.c
+++ b/drivers/gpu/drm/radeon/ni_dpm.c
@@ -4075,7 +4075,8 @@ int ni_dpm_init(struct radeon_device *rdev)
 		return ret;
 
 	rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries =
-		kzalloc(4 * sizeof(struct radeon_clock_voltage_dependency_entry), GFP_KERNEL);
+		kzalloc(array_size(4, sizeof(struct radeon_clock_voltage_dependency_entry)),
+			GFP_KERNEL);
 	if (!rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries) {
 		r600_free_extended_power_table(rdev);
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/radeon/radeon_atombios.c b/drivers/gpu/drm/radeon/radeon_atombios.c
index 4134759a6823..49693891ac9f 100644
--- a/drivers/gpu/drm/radeon/radeon_atombios.c
+++ b/drivers/gpu/drm/radeon/radeon_atombios.c
@@ -2126,13 +2126,15 @@ static int radeon_atombios_parse_power_table_1_3(struct radeon_device *rdev)
 		num_modes = ATOM_MAX_NUMBEROF_POWER_BLOCK;
 	if (num_modes == 0)
 		return state_index;
-	rdev->pm.power_state = kzalloc(sizeof(struct radeon_power_state) * num_modes, GFP_KERNEL);
+	rdev->pm.power_state = kzalloc(array_size(num_modes, sizeof(struct radeon_power_state)),
+				       GFP_KERNEL);
 	if (!rdev->pm.power_state)
 		return state_index;
 	/* last mode is usually default, array is low to high */
 	for (i = 0; i < num_modes; i++) {
 		rdev->pm.power_state[state_index].clock_info =
-			kzalloc(sizeof(struct radeon_pm_clock_info) * 1, GFP_KERNEL);
+			kzalloc(array_size(1, sizeof(struct radeon_pm_clock_info)),
+				GFP_KERNEL);
 		if (!rdev->pm.power_state[state_index].clock_info)
 			return state_index;
 		rdev->pm.power_state[state_index].num_clock_modes = 1;
@@ -2782,7 +2784,8 @@ void radeon_atombios_get_power_modes(struct radeon_device *rdev)
 		rdev->pm.power_state = kzalloc(sizeof(struct radeon_power_state), GFP_KERNEL);
 		if (rdev->pm.power_state) {
 			rdev->pm.power_state[0].clock_info =
-				kzalloc(sizeof(struct radeon_pm_clock_info) * 1, GFP_KERNEL);
+				kzalloc(array_size(1, sizeof(struct radeon_pm_clock_info)),
+				        GFP_KERNEL);
 			if (rdev->pm.power_state[0].clock_info) {
 				/* add the default mode */
 				rdev->pm.power_state[state_index].type =
diff --git a/drivers/gpu/drm/radeon/radeon_combios.c b/drivers/gpu/drm/radeon/radeon_combios.c
index 3178ba0c537c..bfef144602f5 100644
--- a/drivers/gpu/drm/radeon/radeon_combios.c
+++ b/drivers/gpu/drm/radeon/radeon_combios.c
@@ -2642,13 +2642,16 @@ void radeon_combios_get_power_modes(struct radeon_device *rdev)
 	rdev->pm.default_power_state_index = -1;
 
 	/* allocate 2 power states */
-	rdev->pm.power_state = kzalloc(sizeof(struct radeon_power_state) * 2, GFP_KERNEL);
+	rdev->pm.power_state = kzalloc(array_size(2, sizeof(struct radeon_power_state)),
+				       GFP_KERNEL);
 	if (rdev->pm.power_state) {
 		/* allocate 1 clock mode per state */
 		rdev->pm.power_state[0].clock_info =
-			kzalloc(sizeof(struct radeon_pm_clock_info) * 1, GFP_KERNEL);
+			kzalloc(array_size(1, sizeof(struct radeon_pm_clock_info)),
+				GFP_KERNEL);
 		rdev->pm.power_state[1].clock_info =
-			kzalloc(sizeof(struct radeon_pm_clock_info) * 1, GFP_KERNEL);
+			kzalloc(array_size(1, sizeof(struct radeon_pm_clock_info)),
+				GFP_KERNEL);
 		if (!rdev->pm.power_state[0].clock_info ||
 		    !rdev->pm.power_state[1].clock_info)
 			goto pm_failed;
diff --git a/drivers/gpu/drm/radeon/radeon_test.c b/drivers/gpu/drm/radeon/radeon_test.c
index f5e9abfadb56..c6b8d6a94b8e 100644
--- a/drivers/gpu/drm/radeon/radeon_test.c
+++ b/drivers/gpu/drm/radeon/radeon_test.c
@@ -59,7 +59,7 @@ static void radeon_do_test_moves(struct radeon_device *rdev, int flag)
 	n = rdev->mc.gtt_size - rdev->gart_pin_size;
 	n /= size;
 
-	gtt_obj = kzalloc(n * sizeof(*gtt_obj), GFP_KERNEL);
+	gtt_obj = kzalloc(array_size(n, sizeof(*gtt_obj)), GFP_KERNEL);
 	if (!gtt_obj) {
 		DRM_ERROR("Failed to allocate %d pointers\n", n);
 		r = 1;
diff --git a/drivers/gpu/drm/radeon/si_dpm.c b/drivers/gpu/drm/radeon/si_dpm.c
index 90d5b41007bf..0e2a43220a23 100644
--- a/drivers/gpu/drm/radeon/si_dpm.c
+++ b/drivers/gpu/drm/radeon/si_dpm.c
@@ -6941,7 +6941,8 @@ int si_dpm_init(struct radeon_device *rdev)
 		return ret;
 
 	rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries =
-		kzalloc(4 * sizeof(struct radeon_clock_voltage_dependency_entry), GFP_KERNEL);
+		kzalloc(array_size(4, sizeof(struct radeon_clock_voltage_dependency_entry)),
+			GFP_KERNEL);
 	if (!rdev->pm.dpm.dyn_state.vddc_dependency_on_dispclk.entries) {
 		r600_free_extended_power_table(rdev);
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/tegra/fb.c b/drivers/gpu/drm/tegra/fb.c
index e69434909a42..9d7b7a48d660 100644
--- a/drivers/gpu/drm/tegra/fb.c
+++ b/drivers/gpu/drm/tegra/fb.c
@@ -149,7 +149,8 @@ static struct tegra_fb *tegra_fb_alloc(struct drm_device *drm,
 	if (!fb)
 		return ERR_PTR(-ENOMEM);
 
-	fb->planes = kzalloc(num_planes * sizeof(*planes), GFP_KERNEL);
+	fb->planes = kzalloc(array_size(num_planes, sizeof(*planes)),
+			     GFP_KERNEL);
 	if (!fb->planes) {
 		kfree(fb);
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
index f0481b7b60c5..a77fcd164f13 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -348,7 +348,7 @@ static int ttm_page_pool_free(struct ttm_page_pool *pool, unsigned nr_free,
 	if (use_static)
 		pages_to_free = static_buf;
 	else
-		pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
+		pages_to_free = kmalloc(array_size(npages_to_free, sizeof(struct page *)),
 					GFP_KERNEL);
 	if (!pages_to_free) {
 		pr_debug("Failed to allocate memory for pool free operation\n");
@@ -547,7 +547,8 @@ static int ttm_alloc_new_pages(struct list_head *pages, gfp_t gfp_flags,
 	unsigned max_cpages = min(count << order, (unsigned)NUM_PAGES_TO_ALLOC);
 
 	/* allocate array for page caching change */
-	caching_array = kmalloc(max_cpages*sizeof(struct page *), GFP_KERNEL);
+	caching_array = kmalloc(array_size(max_cpages, sizeof(struct page *)),
+				GFP_KERNEL);
 
 	if (!caching_array) {
 		pr_debug("Unable to allocate table for new pages\n");
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
index 8a25d1974385..3500babe2572 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
@@ -463,7 +463,7 @@ static unsigned ttm_dma_page_pool_free(struct dma_pool *pool, unsigned nr_free,
 	if (use_static)
 		pages_to_free = static_buf;
 	else
-		pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
+		pages_to_free = kmalloc(array_size(npages_to_free, sizeof(struct page *)),
 					GFP_KERNEL);
 
 	if (!pages_to_free) {
@@ -753,7 +753,8 @@ static int ttm_dma_pool_alloc_new_pages(struct dma_pool *pool,
 			(unsigned)(PAGE_SIZE/sizeof(struct page *)));
 
 	/* allocate array for page caching change */
-	caching_array = kmalloc(max_cpages*sizeof(struct page *), GFP_KERNEL);
+	caching_array = kmalloc(array_size(max_cpages, sizeof(struct page *)),
+				GFP_KERNEL);
 
 	if (!caching_array) {
 		pr_debug("%s: Unable to allocate table for new pages\n",
diff --git a/drivers/hid/hid-core.c b/drivers/hid/hid-core.c
index 5d7cc6bbbac6..f82dc60d432e 100644
--- a/drivers/hid/hid-core.c
+++ b/drivers/hid/hid-core.c
@@ -1271,7 +1271,7 @@ static void hid_input_field(struct hid_device *hid, struct hid_field *field,
 	__s32 max = field->logical_maximum;
 	__s32 *value;
 
-	value = kmalloc(sizeof(__s32) * count, GFP_ATOMIC);
+	value = kmalloc(array_size(count, sizeof(__s32)), GFP_ATOMIC);
 	if (!value)
 		return;
 
diff --git a/drivers/hid/hid-debug.c b/drivers/hid/hid-debug.c
index 4f4e7a08a07b..a20a5ac3cc70 100644
--- a/drivers/hid/hid-debug.c
+++ b/drivers/hid/hid-debug.c
@@ -457,7 +457,8 @@ static char *resolv_usage_page(unsigned page, struct seq_file *f) {
 	char *buf = NULL;
 
 	if (!f) {
-		buf = kzalloc(sizeof(char) * HID_DEBUG_BUFSIZE, GFP_ATOMIC);
+		buf = kzalloc(array_size(HID_DEBUG_BUFSIZE, sizeof(char)),
+			      GFP_ATOMIC);
 		if (!buf)
 			return ERR_PTR(-ENOMEM);
 	}
@@ -685,7 +686,7 @@ void hid_dump_report(struct hid_device *hid, int type, u8 *data,
 	char *buf;
 	unsigned int i;
 
-	buf = kmalloc(sizeof(char) * HID_DEBUG_BUFSIZE, GFP_ATOMIC);
+	buf = kmalloc(array_size(HID_DEBUG_BUFSIZE, sizeof(char)), GFP_ATOMIC);
 
 	if (!buf)
 		return;
@@ -1088,7 +1089,7 @@ static int hid_debug_events_open(struct inode *inode, struct file *file)
 		goto out;
 	}
 
-	if (!(list->hid_debug_buf = kzalloc(sizeof(char) * HID_DEBUG_BUFSIZE, GFP_KERNEL))) {
+	if (!(list->hid_debug_buf = kzalloc(array_size(HID_DEBUG_BUFSIZE, sizeof(char)), GFP_KERNEL))) {
 		err = -ENOMEM;
 		kfree(list);
 		goto out;
diff --git a/drivers/hid/hidraw.c b/drivers/hid/hidraw.c
index b39844adea47..6dc9e5b65e16 100644
--- a/drivers/hid/hidraw.c
+++ b/drivers/hid/hidraw.c
@@ -218,7 +218,7 @@ static ssize_t hidraw_get_report(struct file *file, char __user *buffer, size_t
 		goto out;
 	}
 
-	buf = kmalloc(count * sizeof(__u8), GFP_KERNEL);
+	buf = kmalloc(array_size(count, sizeof(__u8)), GFP_KERNEL);
 	if (!buf) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/drivers/hv/hv.c b/drivers/hv/hv.c
index 9b82549cbbc8..e8343d005898 100644
--- a/drivers/hv/hv.c
+++ b/drivers/hv/hv.c
@@ -190,7 +190,7 @@ int hv_synic_alloc(void)
 {
 	int cpu;
 
-	hv_context.hv_numa_map = kzalloc(sizeof(struct cpumask) * nr_node_ids,
+	hv_context.hv_numa_map = kzalloc(array_size(nr_node_ids, sizeof(struct cpumask)),
 					 GFP_KERNEL);
 	if (hv_context.hv_numa_map == NULL) {
 		pr_err("Unable to allocate NUMA map\n");
diff --git a/drivers/hwmon/coretemp.c b/drivers/hwmon/coretemp.c
index 72c338eb5fae..bb647588c0cf 100644
--- a/drivers/hwmon/coretemp.c
+++ b/drivers/hwmon/coretemp.c
@@ -742,7 +742,7 @@ static int __init coretemp_init(void)
 		return -ENODEV;
 
 	max_packages = topology_max_packages();
-	pkg_devices = kzalloc(max_packages * sizeof(struct platform_device *),
+	pkg_devices = kzalloc(array_size(max_packages, sizeof(struct platform_device *)),
 			      GFP_KERNEL);
 	if (!pkg_devices)
 		return -ENOMEM;
diff --git a/drivers/hwmon/i5k_amb.c b/drivers/hwmon/i5k_amb.c
index 9397d2f0e79a..ba92064dd43e 100644
--- a/drivers/hwmon/i5k_amb.c
+++ b/drivers/hwmon/i5k_amb.c
@@ -274,8 +274,8 @@ static int i5k_amb_hwmon_init(struct platform_device *pdev)
 		num_ambs += hweight16(data->amb_present[i] & 0x7fff);
 
 	/* Set up sysfs stuff */
-	data->attrs = kzalloc(sizeof(*data->attrs) * num_ambs * KNOBS_PER_AMB,
-				GFP_KERNEL);
+	data->attrs = kzalloc(array3_size(num_ambs, KNOBS_PER_AMB, sizeof(*data->attrs)),
+			      GFP_KERNEL);
 	if (!data->attrs)
 		return -ENOMEM;
 	data->num_attrs = 0;
diff --git a/drivers/i2c/busses/i2c-amd756-s4882.c b/drivers/i2c/busses/i2c-amd756-s4882.c
index 65e324054970..4305d3f686b9 100644
--- a/drivers/i2c/busses/i2c-amd756-s4882.c
+++ b/drivers/i2c/busses/i2c-amd756-s4882.c
@@ -169,13 +169,11 @@ static int __init amd756_s4882_init(void)
 
 	printk(KERN_INFO "Enabling SMBus multiplexing for Tyan S4882\n");
 	/* Define the 5 virtual adapters and algorithms structures */
-	if (!(s4882_adapter = kzalloc(5 * sizeof(struct i2c_adapter),
-				      GFP_KERNEL))) {
+	if (!(s4882_adapter = kzalloc(array_size(5, sizeof(struct i2c_adapter)), GFP_KERNEL))) {
 		error = -ENOMEM;
 		goto ERROR1;
 	}
-	if (!(s4882_algo = kzalloc(5 * sizeof(struct i2c_algorithm),
-				   GFP_KERNEL))) {
+	if (!(s4882_algo = kzalloc(array_size(5, sizeof(struct i2c_algorithm)), GFP_KERNEL))) {
 		error = -ENOMEM;
 		goto ERROR2;
 	}
diff --git a/drivers/i2c/busses/i2c-nforce2-s4985.c b/drivers/i2c/busses/i2c-nforce2-s4985.c
index 88eda09e73c0..b89f362ac38b 100644
--- a/drivers/i2c/busses/i2c-nforce2-s4985.c
+++ b/drivers/i2c/busses/i2c-nforce2-s4985.c
@@ -164,12 +164,14 @@ static int __init nforce2_s4985_init(void)
 
 	printk(KERN_INFO "Enabling SMBus multiplexing for Tyan S4985\n");
 	/* Define the 5 virtual adapters and algorithms structures */
-	s4985_adapter = kzalloc(5 * sizeof(struct i2c_adapter), GFP_KERNEL);
+	s4985_adapter = kzalloc(array_size(5, sizeof(struct i2c_adapter)),
+				GFP_KERNEL);
 	if (!s4985_adapter) {
 		error = -ENOMEM;
 		goto ERROR1;
 	}
-	s4985_algo = kzalloc(5 * sizeof(struct i2c_algorithm), GFP_KERNEL);
+	s4985_algo = kzalloc(array_size(5, sizeof(struct i2c_algorithm)),
+			     GFP_KERNEL);
 	if (!s4985_algo) {
 		error = -ENOMEM;
 		goto ERROR2;
diff --git a/drivers/i2c/busses/i2c-nforce2.c b/drivers/i2c/busses/i2c-nforce2.c
index 3241bb9d6c18..115f0c86731a 100644
--- a/drivers/i2c/busses/i2c-nforce2.c
+++ b/drivers/i2c/busses/i2c-nforce2.c
@@ -381,7 +381,8 @@ static int nforce2_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	int res1, res2;
 
 	/* we support 2 SMBus adapters */
-	smbuses = kzalloc(2 * sizeof(struct nforce2_smbus), GFP_KERNEL);
+	smbuses = kzalloc(array_size(2, sizeof(struct nforce2_smbus)),
+			  GFP_KERNEL);
 	if (!smbuses)
 		return -ENOMEM;
 	pci_set_drvdata(dev, smbuses);
diff --git a/drivers/i2c/i2c-dev.c b/drivers/i2c/i2c-dev.c
index 036a03f0d0a6..0bcdfacb483e 100644
--- a/drivers/i2c/i2c-dev.c
+++ b/drivers/i2c/i2c-dev.c
@@ -244,7 +244,8 @@ static noinline int i2cdev_ioctl_rdwr(struct i2c_client *client,
 	u8 __user **data_ptrs;
 	int i, res;
 
-	data_ptrs = kmalloc(nmsgs * sizeof(u8 __user *), GFP_KERNEL);
+	data_ptrs = kmalloc(array_size(nmsgs, sizeof(u8 __user *)),
+			    GFP_KERNEL);
 	if (data_ptrs == NULL) {
 		kfree(msgs);
 		return -ENOMEM;
diff --git a/drivers/ide/it821x.c b/drivers/ide/it821x.c
index 04029d18a696..fa11eb26c2ed 100644
--- a/drivers/ide/it821x.c
+++ b/drivers/ide/it821x.c
@@ -652,7 +652,7 @@ static int it821x_init_one(struct pci_dev *dev, const struct pci_device_id *id)
 	struct it821x_dev *itdevs;
 	int rc;
 
-	itdevs = kzalloc(2 * sizeof(*itdevs), GFP_KERNEL);
+	itdevs = kzalloc(array_size(2, sizeof(*itdevs)), GFP_KERNEL);
 	if (itdevs == NULL) {
 		printk(KERN_ERR DRV_NAME " %s: out of memory\n", pci_name(dev));
 		return -ENOMEM;
diff --git a/drivers/infiniband/core/fmr_pool.c b/drivers/infiniband/core/fmr_pool.c
index a0a9ed719031..d4c864700b38 100644
--- a/drivers/infiniband/core/fmr_pool.c
+++ b/drivers/infiniband/core/fmr_pool.c
@@ -235,7 +235,7 @@ struct ib_fmr_pool *ib_create_fmr_pool(struct ib_pd             *pd,
 
 	if (params->cache) {
 		pool->cache_bucket =
-			kmalloc(IB_FMR_HASH_SIZE * sizeof *pool->cache_bucket,
+			kmalloc(array_size(IB_FMR_HASH_SIZE, sizeof(*pool->cache_bucket)),
 				GFP_KERNEL);
 		if (!pool->cache_bucket) {
 			ret = -ENOMEM;
diff --git a/drivers/infiniband/core/iwpm_util.c b/drivers/infiniband/core/iwpm_util.c
index 9821ae900f6d..bb724690c5a2 100644
--- a/drivers/infiniband/core/iwpm_util.c
+++ b/drivers/infiniband/core/iwpm_util.c
@@ -56,14 +56,14 @@ int iwpm_init(u8 nl_client)
 	int ret = 0;
 	mutex_lock(&iwpm_admin_lock);
 	if (atomic_read(&iwpm_admin.refcount) == 0) {
-		iwpm_hash_bucket = kzalloc(IWPM_MAPINFO_HASH_SIZE *
-					sizeof(struct hlist_head), GFP_KERNEL);
+		iwpm_hash_bucket = kzalloc(array_size(IWPM_MAPINFO_HASH_SIZE, sizeof(struct hlist_head)),
+					   GFP_KERNEL);
 		if (!iwpm_hash_bucket) {
 			ret = -ENOMEM;
 			goto init_exit;
 		}
-		iwpm_reminfo_bucket = kzalloc(IWPM_REMINFO_HASH_SIZE *
-					sizeof(struct hlist_head), GFP_KERNEL);
+		iwpm_reminfo_bucket = kzalloc(array_size(IWPM_REMINFO_HASH_SIZE, sizeof(struct hlist_head)),
+					      GFP_KERNEL);
 		if (!iwpm_reminfo_bucket) {
 			kfree(iwpm_hash_bucket);
 			ret = -ENOMEM;
diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 3328acc53c2a..5596f7853fea 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -279,7 +279,8 @@ int cxio_create_qp(struct cxio_rdev *rdev_p, u32 kernel_domain,
 	if (!wq->qpid)
 		return -ENOMEM;
 
-	wq->rq = kzalloc(depth * sizeof(struct t3_swrq), GFP_KERNEL);
+	wq->rq = kzalloc(array_size(depth, sizeof(struct t3_swrq)),
+			 GFP_KERNEL);
 	if (!wq->rq)
 		goto err1;
 
@@ -287,7 +288,8 @@ int cxio_create_qp(struct cxio_rdev *rdev_p, u32 kernel_domain,
 	if (!wq->rq_addr)
 		goto err2;
 
-	wq->sq = kzalloc(depth * sizeof(struct t3_swsq), GFP_KERNEL);
+	wq->sq = kzalloc(array_size(depth, sizeof(struct t3_swsq)),
+			 GFP_KERNEL);
 	if (!wq->sq)
 		goto err3;
 
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index feeb8ee6f4a2..cc024ffc5f4f 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -1438,7 +1438,8 @@ static void recover_queues(struct uld_ctx *ctx)
 	ctx->dev->db_state = RECOVERY;
 	idr_for_each(&ctx->dev->qpidr, count_qps, &count);
 
-	qp_list.qps = kzalloc(count * sizeof *qp_list.qps, GFP_ATOMIC);
+	qp_list.qps = kzalloc(array_size(count, sizeof(*qp_list.qps)),
+			      GFP_ATOMIC);
 	if (!qp_list.qps) {
 		spin_unlock_irq(&ctx->dev->lock);
 		return;
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v2.c b/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
index 8b84ab7800d8..aeebf3fc894f 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v2.c
@@ -3120,7 +3120,7 @@ static int hns_roce_v2_modify_qp(struct ib_qp *ibqp,
 	struct device *dev = hr_dev->dev;
 	int ret = -EINVAL;
 
-	context = kzalloc(2 * sizeof(*context), GFP_KERNEL);
+	context = kzalloc(array_size(2, sizeof(*context)), GFP_KERNEL);
 	if (!context)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 0793a21d76f4..1f46498ddafa 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -1613,7 +1613,7 @@ static int mlx4_ib_alloc_pv_bufs(struct mlx4_ib_demux_pv_ctx *ctx,
 
 	tun_qp = &ctx->qp[qp_type];
 
-	tun_qp->ring = kzalloc(sizeof (struct mlx4_ib_buf) * MLX4_NUM_TUNNEL_BUFS,
+	tun_qp->ring = kzalloc(array_size(MLX4_NUM_TUNNEL_BUFS, sizeof(struct mlx4_ib_buf)),
 			       GFP_KERNEL);
 	if (!tun_qp->ring)
 		return -ENOMEM;
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 5b70744f414a..d449e1472d53 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -302,7 +302,8 @@ static int mlx4_ib_add_gid(const union ib_gid *gid,
 		ctx->refcount++;
 	}
 	if (!ret && hw_update) {
-		gids = kmalloc(sizeof(*gids) * MLX4_MAX_PORT_GIDS, GFP_ATOMIC);
+		gids = kmalloc(array_size(MLX4_MAX_PORT_GIDS, sizeof(*gids)),
+			       GFP_ATOMIC);
 		if (!gids) {
 			ret = -ENOMEM;
 		} else {
@@ -354,7 +355,8 @@ static int mlx4_ib_del_gid(const struct ib_gid_attr *attr, void **context)
 	if (!ret && hw_update) {
 		int i;
 
-		gids = kmalloc(sizeof(*gids) * MLX4_MAX_PORT_GIDS, GFP_ATOMIC);
+		gids = kmalloc(array_size(MLX4_MAX_PORT_GIDS, sizeof(*gids)),
+			       GFP_ATOMIC);
 		if (!gids) {
 			ret = -ENOMEM;
 		} else {
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 3c7522d025f2..0148b8f559a4 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -127,7 +127,7 @@ static int create_srq_user(struct ib_pd *pd, struct mlx5_ib_srq *srq,
 		goto err_umem;
 	}
 
-	in->pas = kvzalloc(sizeof(*in->pas) * ncont, GFP_KERNEL);
+	in->pas = kvzalloc(array_size(ncont, sizeof(*in->pas)), GFP_KERNEL);
 	if (!in->pas) {
 		err = -ENOMEM;
 		goto err_umem;
diff --git a/drivers/infiniband/hw/mthca/mthca_allocator.c b/drivers/infiniband/hw/mthca/mthca_allocator.c
index b4e0cf4e95cd..dfa35adf5b91 100644
--- a/drivers/infiniband/hw/mthca/mthca_allocator.c
+++ b/drivers/infiniband/hw/mthca/mthca_allocator.c
@@ -162,7 +162,8 @@ int mthca_array_init(struct mthca_array *array, int nent)
 	int npage = (nent * sizeof (void *) + PAGE_SIZE - 1) / PAGE_SIZE;
 	int i;
 
-	array->page_list = kmalloc(npage * sizeof *array->page_list, GFP_KERNEL);
+	array->page_list = kmalloc(array_size(npage, sizeof(*array->page_list)),
+				   GFP_KERNEL);
 	if (!array->page_list)
 		return -ENOMEM;
 
@@ -220,7 +221,8 @@ int mthca_buf_alloc(struct mthca_dev *dev, int size, int max_direct,
 			npages *= 2;
 		}
 
-		dma_list = kmalloc(npages * sizeof *dma_list, GFP_KERNEL);
+		dma_list = kmalloc(array_size(npages, sizeof(*dma_list)),
+				   GFP_KERNEL);
 		if (!dma_list)
 			goto err_free;
 
@@ -231,11 +233,12 @@ int mthca_buf_alloc(struct mthca_dev *dev, int size, int max_direct,
 		npages     = (size + PAGE_SIZE - 1) / PAGE_SIZE;
 		shift      = PAGE_SHIFT;
 
-		dma_list = kmalloc(npages * sizeof *dma_list, GFP_KERNEL);
+		dma_list = kmalloc(array_size(npages, sizeof(*dma_list)),
+				   GFP_KERNEL);
 		if (!dma_list)
 			return -ENOMEM;
 
-		buf->page_list = kmalloc(npages * sizeof *buf->page_list,
+		buf->page_list = kmalloc(array_size(npages, sizeof(*buf->page_list)),
 					 GFP_KERNEL);
 		if (!buf->page_list)
 			goto err_out;
diff --git a/drivers/infiniband/hw/mthca/mthca_eq.c b/drivers/infiniband/hw/mthca/mthca_eq.c
index 690201738993..a58d80e9dd41 100644
--- a/drivers/infiniband/hw/mthca/mthca_eq.c
+++ b/drivers/infiniband/hw/mthca/mthca_eq.c
@@ -479,7 +479,7 @@ static int mthca_create_eq(struct mthca_dev *dev,
 	eq->nent = roundup_pow_of_two(max(nent, 2));
 	npages = ALIGN(eq->nent * MTHCA_EQ_ENTRY_SIZE, PAGE_SIZE) / PAGE_SIZE;
 
-	eq->page_list = kmalloc(npages * sizeof *eq->page_list,
+	eq->page_list = kmalloc(array_size(npages, sizeof(*eq->page_list)),
 				GFP_KERNEL);
 	if (!eq->page_list)
 		goto err_out;
@@ -487,7 +487,7 @@ static int mthca_create_eq(struct mthca_dev *dev,
 	for (i = 0; i < npages; ++i)
 		eq->page_list[i].buf = NULL;
 
-	dma_list = kmalloc(npages * sizeof *dma_list, GFP_KERNEL);
+	dma_list = kmalloc(array_size(npages, sizeof(*dma_list)), GFP_KERNEL);
 	if (!dma_list)
 		goto err_out_free;
 
diff --git a/drivers/infiniband/hw/mthca/mthca_mr.c b/drivers/infiniband/hw/mthca/mthca_mr.c
index ed9a989e501b..88d3a53966e1 100644
--- a/drivers/infiniband/hw/mthca/mthca_mr.c
+++ b/drivers/infiniband/hw/mthca/mthca_mr.c
@@ -153,7 +153,8 @@ static int mthca_buddy_init(struct mthca_buddy *buddy, int max_order)
 
 	for (i = 0; i <= buddy->max_order; ++i) {
 		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
-		buddy->bits[i] = kmalloc(s * sizeof (long), GFP_KERNEL);
+		buddy->bits[i] = kmalloc(array_size(s, sizeof(long)),
+					 GFP_KERNEL);
 		if (!buddy->bits[i])
 			goto err_out_free;
 		bitmap_zero(buddy->bits[i],
diff --git a/drivers/infiniband/hw/mthca/mthca_profile.c b/drivers/infiniband/hw/mthca/mthca_profile.c
index 15d064479ef6..a28a4dab088c 100644
--- a/drivers/infiniband/hw/mthca/mthca_profile.c
+++ b/drivers/infiniband/hw/mthca/mthca_profile.c
@@ -79,7 +79,8 @@ s64 mthca_make_profile(struct mthca_dev *dev,
 	struct mthca_resource *profile;
 	int i, j;
 
-	profile = kzalloc(MTHCA_RES_NUM * sizeof *profile, GFP_KERNEL);
+	profile = kzalloc(array_size(MTHCA_RES_NUM, sizeof(*profile)),
+			  GFP_KERNEL);
 	if (!profile)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/nes/nes_mgt.c b/drivers/infiniband/hw/nes/nes_mgt.c
index 21e0ebd39a05..668f22a8cac2 100644
--- a/drivers/infiniband/hw/nes/nes_mgt.c
+++ b/drivers/infiniband/hw/nes/nes_mgt.c
@@ -878,7 +878,8 @@ int nes_init_mgt_qp(struct nes_device *nesdev, struct net_device *netdev, struct
 	int ret;
 
 	/* Allocate space the all mgt QPs once */
-	mgtvnic = kzalloc(NES_MGT_QP_COUNT * sizeof(struct nes_vnic_mgt), GFP_KERNEL);
+	mgtvnic = kzalloc(array_size(NES_MGT_QP_COUNT, sizeof(struct nes_vnic_mgt)),
+			  GFP_KERNEL);
 	if (!mgtvnic)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 0a75164cedea..205e76befe63 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -904,7 +904,7 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 		int i;
 		struct netdev_hw_addr *ha;
 
-		addrs = kmalloc(ETH_ALEN * mc_count, GFP_ATOMIC);
+		addrs = kmalloc(array_size(mc_count, ETH_ALEN), GFP_ATOMIC);
 		if (!addrs) {
 			set_allmulti(nesdev, nic_active_bit);
 			goto unlock;
diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband/hw/nes/nes_verbs.c
index 1040a6e34230..515dc93a4a60 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -2254,8 +2254,8 @@ static struct ib_mr *nes_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 								ibmr = ERR_PTR(-ENOMEM);
 								goto reg_user_mr_err;
 							}
-							root_vpbl.leaf_vpbl = kzalloc(sizeof(*root_vpbl.leaf_vpbl)*1024,
-									GFP_KERNEL);
+							root_vpbl.leaf_vpbl = kzalloc(array_size(1024, sizeof(*root_vpbl.leaf_vpbl)),
+										      GFP_KERNEL);
 							if (!root_vpbl.leaf_vpbl) {
 								ib_umem_release(region);
 								pci_free_consistent(nesdev->pcidev, 8192, root_vpbl.pbl_vbase,
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_hw.c b/drivers/infiniband/hw/ocrdma/ocrdma_hw.c
index 2c260e1c29d1..a10617f11ad4 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_hw.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_hw.c
@@ -3096,7 +3096,8 @@ static int ocrdma_create_eqs(struct ocrdma_dev *dev)
 	if (!num_eq)
 		return -EINVAL;
 
-	dev->eq_tbl = kzalloc(sizeof(struct ocrdma_eq) * num_eq, GFP_KERNEL);
+	dev->eq_tbl = kzalloc(array_size(num_eq, sizeof(struct ocrdma_eq)),
+			      GFP_KERNEL);
 	if (!dev->eq_tbl)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_main.c b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
index eb8b6a935016..5dde3565a9a2 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_main.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
@@ -221,19 +221,20 @@ static int ocrdma_register_device(struct ocrdma_dev *dev)
 static int ocrdma_alloc_resources(struct ocrdma_dev *dev)
 {
 	mutex_init(&dev->dev_lock);
-	dev->cq_tbl = kzalloc(sizeof(struct ocrdma_cq *) *
-			      OCRDMA_MAX_CQ, GFP_KERNEL);
+	dev->cq_tbl = kzalloc(array_size(OCRDMA_MAX_CQ, sizeof(struct ocrdma_cq *)),
+			      GFP_KERNEL);
 	if (!dev->cq_tbl)
 		goto alloc_err;
 
 	if (dev->attr.max_qp) {
-		dev->qp_tbl = kzalloc(sizeof(struct ocrdma_qp *) *
-				      OCRDMA_MAX_QP, GFP_KERNEL);
+		dev->qp_tbl = kzalloc(array_size(OCRDMA_MAX_QP, sizeof(struct ocrdma_qp *)),
+				      GFP_KERNEL);
 		if (!dev->qp_tbl)
 			goto alloc_err;
 	}
 
-	dev->stag_arr = kzalloc(sizeof(u64) * OCRDMA_MAX_STAG, GFP_KERNEL);
+	dev->stag_arr = kzalloc(array_size(OCRDMA_MAX_STAG, sizeof(u64)),
+				GFP_KERNEL);
 	if (dev->stag_arr == NULL)
 		goto alloc_err;
 
diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index f4cb60b658ea..c291177a7cdc 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -317,8 +317,8 @@ static int qedr_alloc_resources(struct qedr_dev *dev)
 	u16 n_entries;
 	int i, rc;
 
-	dev->sgid_tbl = kzalloc(sizeof(union ib_gid) *
-				QEDR_MAX_SGID, GFP_KERNEL);
+	dev->sgid_tbl = kzalloc(array_size(QEDR_MAX_SGID, sizeof(union ib_gid)),
+				GFP_KERNEL);
 	if (!dev->sgid_tbl)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/qib/qib_iba7322.c b/drivers/infiniband/hw/qib/qib_iba7322.c
index 8414ae44a518..57583362bf3e 100644
--- a/drivers/infiniband/hw/qib/qib_iba7322.c
+++ b/drivers/infiniband/hw/qib/qib_iba7322.c
@@ -6412,12 +6412,12 @@ static int qib_init_7322_variables(struct qib_devdata *dd)
 	sbufcnt = dd->piobcnt2k + dd->piobcnt4k +
 		NUM_VL15_BUFS + BITS_PER_LONG - 1;
 	sbufcnt /= BITS_PER_LONG;
-	dd->cspec->sendchkenable = kmalloc(sbufcnt *
-		sizeof(*dd->cspec->sendchkenable), GFP_KERNEL);
-	dd->cspec->sendgrhchk = kmalloc(sbufcnt *
-		sizeof(*dd->cspec->sendgrhchk), GFP_KERNEL);
-	dd->cspec->sendibchk = kmalloc(sbufcnt *
-		sizeof(*dd->cspec->sendibchk), GFP_KERNEL);
+	dd->cspec->sendchkenable = kmalloc(array_size(sbufcnt, sizeof(*dd->cspec->sendchkenable)),
+					   GFP_KERNEL);
+	dd->cspec->sendgrhchk = kmalloc(array_size(sbufcnt, sizeof(*dd->cspec->sendgrhchk)),
+					GFP_KERNEL);
+	dd->cspec->sendibchk = kmalloc(array_size(sbufcnt, sizeof(*dd->cspec->sendibchk)),
+				       GFP_KERNEL);
 	if (!dd->cspec->sendchkenable || !dd->cspec->sendgrhchk ||
 		!dd->cspec->sendibchk) {
 		ret = -ENOMEM;
@@ -7290,8 +7290,8 @@ struct qib_devdata *qib_init_iba7322_funcs(struct pci_dev *pdev,
 		actual_cnt -= dd->num_pports;
 
 	tabsize = actual_cnt;
-	dd->cspec->msix_entries = kzalloc(tabsize *
-			sizeof(struct qib_msix_entry), GFP_KERNEL);
+	dd->cspec->msix_entries = kzalloc(array_size(tabsize, sizeof(struct qib_msix_entry)),
+					  GFP_KERNEL);
 	if (!dd->cspec->msix_entries)
 		tabsize = 0;
 
diff --git a/drivers/infiniband/hw/usnic/usnic_vnic.c b/drivers/infiniband/hw/usnic/usnic_vnic.c
index e7b0030254da..b13bdb1a1a81 100644
--- a/drivers/infiniband/hw/usnic/usnic_vnic.c
+++ b/drivers/infiniband/hw/usnic/usnic_vnic.c
@@ -312,7 +312,8 @@ static int usnic_vnic_alloc_res_chunk(struct usnic_vnic *vnic,
 	}
 
 	chunk->cnt = chunk->free_cnt = cnt;
-	chunk->res = kzalloc(sizeof(*(chunk->res))*cnt, GFP_KERNEL);
+	chunk->res = kzalloc(array_size(cnt, sizeof(*(chunk->res))),
+			     GFP_KERNEL);
 	if (!chunk->res)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 161ba8c76285..8097b1d8422f 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1525,7 +1525,7 @@ static int ipoib_neigh_hash_init(struct ipoib_dev_priv *priv)
 		return -ENOMEM;
 	set_bit(IPOIB_STOP_NEIGH_GC, &priv->flags);
 	size = roundup_pow_of_two(arp_tbl.gc_thresh3);
-	buckets = kzalloc(size * sizeof(*buckets), GFP_KERNEL);
+	buckets = kzalloc(array_size(size, sizeof(*buckets)), GFP_KERNEL);
 	if (!buckets) {
 		kfree(htbl);
 		return -ENOMEM;
@@ -1703,8 +1703,8 @@ static int ipoib_dev_init_default(struct net_device *dev)
 	ipoib_napi_add(dev);
 
 	/* Allocate RX/TX "rings" to hold queued skbs */
-	priv->rx_ring =	kzalloc(ipoib_recvq_size * sizeof *priv->rx_ring,
-				GFP_KERNEL);
+	priv->rx_ring =	kzalloc(array_size(ipoib_recvq_size, sizeof(*priv->rx_ring)),
+				       GFP_KERNEL);
 	if (!priv->rx_ring)
 		goto out;
 
diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index fff40b097947..f68ef506f11c 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -181,8 +181,8 @@ isert_alloc_rx_descriptors(struct isert_conn *isert_conn)
 	u64 dma_addr;
 	int i, j;
 
-	isert_conn->rx_descs = kzalloc(ISERT_QP_MAX_RECV_DTOS *
-				sizeof(struct iser_rx_desc), GFP_KERNEL);
+	isert_conn->rx_descs = kzalloc(array_size(ISERT_QP_MAX_RECV_DTOS, sizeof(struct iser_rx_desc)),
+				       GFP_KERNEL);
 	if (!isert_conn->rx_descs)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/ulp/srpt/ib_srpt.c b/drivers/infiniband/ulp/srpt/ib_srpt.c
index dfec0e1fac29..620cfdeddefc 100644
--- a/drivers/infiniband/ulp/srpt/ib_srpt.c
+++ b/drivers/infiniband/ulp/srpt/ib_srpt.c
@@ -720,7 +720,7 @@ static struct srpt_ioctx **srpt_alloc_ioctx_ring(struct srpt_device *sdev,
 	WARN_ON(ioctx_size != sizeof(struct srpt_recv_ioctx)
 		&& ioctx_size != sizeof(struct srpt_send_ioctx));
 
-	ring = kmalloc(ring_size * sizeof(ring[0]), GFP_KERNEL);
+	ring = kmalloc(array_size(ring_size, sizeof(ring[0])), GFP_KERNEL);
 	if (!ring)
 		goto out;
 	for (i = 0; i < ring_size; ++i) {
diff --git a/drivers/input/joystick/joydump.c b/drivers/input/joystick/joydump.c
index d1c6e4846a4a..01f5b97c2937 100644
--- a/drivers/input/joystick/joydump.c
+++ b/drivers/input/joystick/joydump.c
@@ -80,7 +80,8 @@ static int joydump_connect(struct gameport *gameport, struct gameport_driver *dr
 
 	timeout = gameport_time(gameport, 10000); /* 10 ms */
 
-	buf = kmalloc(BUF_SIZE * sizeof(struct joydump), GFP_KERNEL);
+	buf = kmalloc(array_size(BUF_SIZE, sizeof(struct joydump)),
+		      GFP_KERNEL);
 	if (!buf) {
 		printk(KERN_INFO "joydump: no memory for testing\n");
 		goto jd_end;
diff --git a/drivers/input/keyboard/omap4-keypad.c b/drivers/input/keyboard/omap4-keypad.c
index 940d38b08e6b..f09f870f1fb0 100644
--- a/drivers/input/keyboard/omap4-keypad.c
+++ b/drivers/input/keyboard/omap4-keypad.c
@@ -337,7 +337,7 @@ static int omap4_keypad_probe(struct platform_device *pdev)
 
 	keypad_data->row_shift = get_count_order(keypad_data->cols);
 	max_keys = keypad_data->rows << keypad_data->row_shift;
-	keypad_data->keymap = kzalloc(max_keys * sizeof(keypad_data->keymap[0]),
+	keypad_data->keymap = kzalloc(array_size(max_keys, sizeof(keypad_data->keymap[0])),
 				      GFP_KERNEL);
 	if (!keypad_data->keymap) {
 		dev_err(&pdev->dev, "Not enough memory for keymap\n");
diff --git a/drivers/iommu/dmar.c b/drivers/iommu/dmar.c
index accf58388bdb..e7774b6551c6 100644
--- a/drivers/iommu/dmar.c
+++ b/drivers/iommu/dmar.c
@@ -1458,7 +1458,8 @@ int dmar_enable_qi(struct intel_iommu *iommu)
 
 	qi->desc = page_address(desc_page);
 
-	qi->desc_status = kzalloc(QI_LENGTH * sizeof(int), GFP_ATOMIC);
+	qi->desc_status = kzalloc(array_size(QI_LENGTH, sizeof(int)),
+				  GFP_ATOMIC);
 	if (!qi->desc_status) {
 		free_page((unsigned long) qi->desc);
 		kfree(qi);
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 749d8f235346..7bf4810ce41d 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3177,7 +3177,8 @@ static int copy_translation_tables(struct intel_iommu *iommu)
 	/* This is too big for the stack - allocate it from slab */
 	ctxt_table_entries = ext ? 512 : 256;
 	ret = -ENOMEM;
-	ctxt_tbls = kzalloc(ctxt_table_entries * sizeof(void *), GFP_KERNEL);
+	ctxt_tbls = kzalloc(array_size(ctxt_table_entries, sizeof(void *)),
+			    GFP_KERNEL);
 	if (!ctxt_tbls)
 		goto out_unmap;
 
@@ -4034,8 +4035,8 @@ static int iommu_suspend(void)
 	unsigned long flag;
 
 	for_each_active_iommu(iommu, drhd) {
-		iommu->iommu_state = kzalloc(sizeof(u32) * MAX_SR_DMAR_REGS,
-						 GFP_ATOMIC);
+		iommu->iommu_state = kzalloc(array_size(MAX_SR_DMAR_REGS, sizeof(u32)),
+					     GFP_ATOMIC);
 		if (!iommu->iommu_state)
 			goto nomem;
 	}
diff --git a/drivers/ipack/carriers/tpci200.c b/drivers/ipack/carriers/tpci200.c
index 9b23843dcad4..b7797e913e4b 100644
--- a/drivers/ipack/carriers/tpci200.c
+++ b/drivers/ipack/carriers/tpci200.c
@@ -457,8 +457,8 @@ static int tpci200_install(struct tpci200_board *tpci200)
 {
 	int res;
 
-	tpci200->slots = kzalloc(
-		TPCI200_NB_SLOT * sizeof(struct tpci200_slot), GFP_KERNEL);
+	tpci200->slots = kzalloc(array_size(TPCI200_NB_SLOT, sizeof(struct tpci200_slot)),
+				 GFP_KERNEL);
 	if (tpci200->slots == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/irqchip/irq-gic-v3-its.c b/drivers/irqchip/irq-gic-v3-its.c
index 5416f2b2ac21..d1a9972c4f58 100644
--- a/drivers/irqchip/irq-gic-v3-its.c
+++ b/drivers/irqchip/irq-gic-v3-its.c
@@ -1823,7 +1823,7 @@ static int its_alloc_tables(struct its_node *its)
 
 static int its_alloc_collections(struct its_node *its)
 {
-	its->collections = kzalloc(nr_cpu_ids * sizeof(*its->collections),
+	its->collections = kzalloc(array_size(nr_cpu_ids, sizeof(*its->collections)),
 				   GFP_KERNEL);
 	if (!its->collections)
 		return -ENOMEM;
@@ -2124,10 +2124,11 @@ static struct its_device *its_create_device(struct its_node *its, u32 dev_id,
 	if (alloc_lpis) {
 		lpi_map = its_lpi_alloc_chunks(nvecs, &lpi_base, &nr_lpis);
 		if (lpi_map)
-			col_map = kzalloc(sizeof(*col_map) * nr_lpis,
+			col_map = kzalloc(array_size(nr_lpis, sizeof(*col_map)),
 					  GFP_KERNEL);
 	} else {
-		col_map = kzalloc(sizeof(*col_map) * nr_ites, GFP_KERNEL);
+		col_map = kzalloc(array_size(nr_ites, sizeof(*col_map)),
+				  GFP_KERNEL);
 		nr_lpis = 0;
 		lpi_base = 0;
 	}
@@ -3183,7 +3184,7 @@ static int its_init_vpe_domain(void)
 	its = list_first_entry(&its_nodes, struct its_node, entry);
 
 	entries = roundup_pow_of_two(nr_cpu_ids);
-	vpe_proxy.vpes = kzalloc(sizeof(*vpe_proxy.vpes) * entries,
+	vpe_proxy.vpes = kzalloc(array_size(entries, sizeof(*vpe_proxy.vpes)),
 				 GFP_KERNEL);
 	if (!vpe_proxy.vpes) {
 		pr_err("ITS: Can't allocate GICv4 proxy device array\n");
@@ -3567,7 +3568,7 @@ static void __init acpi_table_parse_srat_its(void)
 	if (count <= 0)
 		return;
 
-	its_srat_maps = kmalloc(count * sizeof(struct its_srat_map),
+	its_srat_maps = kmalloc(array_size(count, sizeof(struct its_srat_map)),
 				GFP_KERNEL);
 	if (!its_srat_maps) {
 		pr_warn("SRAT: Failed to allocate memory for its_srat_maps!\n");
diff --git a/drivers/irqchip/irq-gic-v3.c b/drivers/irqchip/irq-gic-v3.c
index e5d101418390..537bf15fc46d 100644
--- a/drivers/irqchip/irq-gic-v3.c
+++ b/drivers/irqchip/irq-gic-v3.c
@@ -1160,7 +1160,7 @@ static void __init gic_populate_ppi_partitions(struct device_node *gic_node)
 	if (!nr_parts)
 		goto out_put_node;
 
-	parts = kzalloc(sizeof(*parts) * nr_parts, GFP_KERNEL);
+	parts = kzalloc(array_size(nr_parts, sizeof(*parts)), GFP_KERNEL);
 	if (WARN_ON(!parts))
 		goto out_put_node;
 
@@ -1282,7 +1282,8 @@ static int __init gic_of_init(struct device_node *node, struct device_node *pare
 	if (of_property_read_u32(node, "#redistributor-regions", &nr_redist_regions))
 		nr_redist_regions = 1;
 
-	rdist_regs = kzalloc(sizeof(*rdist_regs) * nr_redist_regions, GFP_KERNEL);
+	rdist_regs = kzalloc(array_size(nr_redist_regions, sizeof(*rdist_regs)),
+			     GFP_KERNEL);
 	if (!rdist_regs) {
 		err = -ENOMEM;
 		goto out_unmap_dist;
diff --git a/drivers/irqchip/irq-s3c24xx.c b/drivers/irqchip/irq-s3c24xx.c
index ec0e6a8cdb75..e37bebc36d28 100644
--- a/drivers/irqchip/irq-s3c24xx.c
+++ b/drivers/irqchip/irq-s3c24xx.c
@@ -1261,7 +1261,7 @@ static int __init s3c_init_intc_of(struct device_node *np,
 			return -ENOMEM;
 
 		intc->domain = domain;
-		intc->irqs = kzalloc(sizeof(struct s3c_irq_data) * 32,
+		intc->irqs = kzalloc(array_size(32, sizeof(struct s3c_irq_data)),
 				     GFP_KERNEL);
 		if (!intc->irqs) {
 			kfree(intc);
diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 19cd93783c87..0ac75cb7d7b0 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1260,7 +1260,7 @@ static int __init capinc_tty_init(void)
 	if (capi_ttyminors <= 0)
 		capi_ttyminors = CAPINC_NR_PORTS;
 
-	capiminors = kzalloc(sizeof(struct capiminor *) * capi_ttyminors,
+	capiminors = kzalloc(array_size(capi_ttyminors, sizeof(struct capiminor *)),
 			     GFP_KERNEL);
 	if (!capiminors)
 		return -ENOMEM;
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 15482c5de33c..57ecbbc5c4f5 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -710,7 +710,8 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->mode = M_UNKNOWN;
 	cs->mstate = MS_UNINITIALIZED;
 
-	cs->bcs = kmalloc(channels * sizeof(struct bc_state), GFP_KERNEL);
+	cs->bcs = kmalloc(array_size(channels, sizeof(struct bc_state)),
+			  GFP_KERNEL);
 	cs->inbuf = kmalloc(sizeof(struct inbuf_t), GFP_KERNEL);
 	if (!cs->bcs || !cs->inbuf) {
 		pr_err("out of memory\n");
@@ -1089,7 +1090,7 @@ struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
 	drv->owner = owner;
 	INIT_LIST_HEAD(&drv->list);
 
-	drv->cs = kmalloc(minors * sizeof *drv->cs, GFP_KERNEL);
+	drv->cs = kmalloc(array_size(minors, sizeof(*drv->cs)), GFP_KERNEL);
 	if (!drv->cs)
 		goto error;
 
diff --git a/drivers/isdn/hardware/avm/b1.c b/drivers/isdn/hardware/avm/b1.c
index b1833d08a5fe..8103b1eb409a 100644
--- a/drivers/isdn/hardware/avm/b1.c
+++ b/drivers/isdn/hardware/avm/b1.c
@@ -72,7 +72,8 @@ avmcard *b1_alloc_card(int nr_controllers)
 	if (!card)
 		return NULL;
 
-	cinfo = kzalloc(sizeof(*cinfo) * nr_controllers, GFP_KERNEL);
+	cinfo = kzalloc(array_size(nr_controllers, sizeof(*cinfo)),
+			GFP_KERNEL);
 	if (!cinfo) {
 		kfree(card);
 		return NULL;
diff --git a/drivers/isdn/hisax/hfc_2bds0.c b/drivers/isdn/hisax/hfc_2bds0.c
index 86b82172e992..50e77782b98a 100644
--- a/drivers/isdn/hisax/hfc_2bds0.c
+++ b/drivers/isdn/hisax/hfc_2bds0.c
@@ -1024,7 +1024,7 @@ static unsigned int
 	int i;
 	unsigned *send;
 
-	if (!(send = kmalloc(cnt * sizeof(unsigned int), GFP_ATOMIC))) {
+	if (!(send = kmalloc(array_size(cnt, sizeof(unsigned int)), GFP_ATOMIC))) {
 		printk(KERN_WARNING
 		       "HiSax: No memory for hfcd.send\n");
 		return (NULL);
diff --git a/drivers/isdn/hisax/hfc_2bs0.c b/drivers/isdn/hisax/hfc_2bs0.c
index 14dada42874e..dcfb516d46bc 100644
--- a/drivers/isdn/hisax/hfc_2bs0.c
+++ b/drivers/isdn/hisax/hfc_2bs0.c
@@ -557,7 +557,7 @@ init_send(struct BCState *bcs)
 {
 	int i;
 
-	if (!(bcs->hw.hfc.send = kmalloc(32 * sizeof(unsigned int), GFP_ATOMIC))) {
+	if (!(bcs->hw.hfc.send = kmalloc(array_size(32, sizeof(unsigned int)), GFP_ATOMIC))) {
 		printk(KERN_WARNING
 		       "HiSax: No memory for hfc.send\n");
 		return;
diff --git a/drivers/isdn/hisax/netjet.c b/drivers/isdn/hisax/netjet.c
index b7f54fa29228..cdaf9119fdc5 100644
--- a/drivers/isdn/hisax/netjet.c
+++ b/drivers/isdn/hisax/netjet.c
@@ -912,8 +912,7 @@ setstack_tiger(struct PStack *st, struct BCState *bcs)
 void
 inittiger(struct IsdnCardState *cs)
 {
-	if (!(cs->bcs[0].hw.tiger.send = kmalloc(NETJET_DMA_TXSIZE * sizeof(unsigned int),
-						 GFP_KERNEL | GFP_DMA))) {
+	if (!(cs->bcs[0].hw.tiger.send = kmalloc(array_size(NETJET_DMA_TXSIZE, sizeof(unsigned int)), GFP_KERNEL | GFP_DMA))) {
 		printk(KERN_WARNING
 		       "HiSax: No memory for tiger.send\n");
 		return;
@@ -933,8 +932,7 @@ inittiger(struct IsdnCardState *cs)
 	     cs->hw.njet.base + NETJET_DMA_READ_IRQ);
 	outl(virt_to_bus(cs->bcs[0].hw.tiger.s_end),
 	     cs->hw.njet.base + NETJET_DMA_READ_END);
-	if (!(cs->bcs[0].hw.tiger.rec = kmalloc(NETJET_DMA_RXSIZE * sizeof(unsigned int),
-						GFP_KERNEL | GFP_DMA))) {
+	if (!(cs->bcs[0].hw.tiger.rec = kmalloc(array_size(NETJET_DMA_RXSIZE, sizeof(unsigned int)), GFP_KERNEL | GFP_DMA))) {
 		printk(KERN_WARNING
 		       "HiSax: No memory for tiger.rec\n");
 		return;
diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index 7c6f3f5d9d9a..b628da5e2d2e 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -2070,14 +2070,14 @@ isdn_add_channels(isdn_driver_t *d, int drvidx, int n, int adding)
 
 	if ((adding) && (d->rcverr))
 		kfree(d->rcverr);
-	if (!(d->rcverr = kzalloc(sizeof(int) * m, GFP_ATOMIC))) {
+	if (!(d->rcverr = kzalloc(array_size(m, sizeof(int)), GFP_ATOMIC))) {
 		printk(KERN_WARNING "register_isdn: Could not alloc rcverr\n");
 		return -1;
 	}
 
 	if ((adding) && (d->rcvcount))
 		kfree(d->rcvcount);
-	if (!(d->rcvcount = kzalloc(sizeof(int) * m, GFP_ATOMIC))) {
+	if (!(d->rcvcount = kzalloc(array_size(m, sizeof(int)), GFP_ATOMIC))) {
 		printk(KERN_WARNING "register_isdn: Could not alloc rcvcount\n");
 		if (!adding)
 			kfree(d->rcverr);
@@ -2089,7 +2089,7 @@ isdn_add_channels(isdn_driver_t *d, int drvidx, int n, int adding)
 			skb_queue_purge(&d->rpqueue[j]);
 		kfree(d->rpqueue);
 	}
-	if (!(d->rpqueue = kmalloc(sizeof(struct sk_buff_head) * m, GFP_ATOMIC))) {
+	if (!(d->rpqueue = kmalloc(array_size(m, sizeof(struct sk_buff_head)), GFP_ATOMIC))) {
 		printk(KERN_WARNING "register_isdn: Could not alloc rpqueue\n");
 		if (!adding) {
 			kfree(d->rcvcount);
diff --git a/drivers/mailbox/pcc.c b/drivers/mailbox/pcc.c
index 3ef7f036ceea..d375cd2cdb28 100644
--- a/drivers/mailbox/pcc.c
+++ b/drivers/mailbox/pcc.c
@@ -476,8 +476,8 @@ static int __init acpi_pcc_probe(void)
 		return -EINVAL;
 	}
 
-	pcc_mbox_channels = kzalloc(sizeof(struct mbox_chan) *
-			sum, GFP_KERNEL);
+	pcc_mbox_channels = kzalloc(array_size(sum, sizeof(struct mbox_chan)),
+				    GFP_KERNEL);
 	if (!pcc_mbox_channels) {
 		pr_err("Could not allocate space for PCC mbox channels\n");
 		return -ENOMEM;
diff --git a/drivers/md/dm-integrity.c b/drivers/md/dm-integrity.c
index 77d9fe58dae2..9c354be188d4 100644
--- a/drivers/md/dm-integrity.c
+++ b/drivers/md/dm-integrity.c
@@ -2464,7 +2464,8 @@ static struct scatterlist **dm_integrity_alloc_journal_scatterlist(struct dm_int
 
 		n_pages = (end_index - start_index + 1);
 
-		s = kvmalloc(n_pages * sizeof(struct scatterlist), GFP_KERNEL);
+		s = kvmalloc(array_size(n_pages, sizeof(struct scatterlist)),
+			     GFP_KERNEL);
 		if (!s) {
 			dm_integrity_free_journal_scatterlist(ic, sl);
 			return NULL;
diff --git a/drivers/md/dm-snap.c b/drivers/md/dm-snap.c
index 216035be5661..dcc957e488e2 100644
--- a/drivers/md/dm-snap.c
+++ b/drivers/md/dm-snap.c
@@ -326,7 +326,7 @@ static int init_origin_hash(void)
 {
 	int i;
 
-	_origins = kmalloc(ORIGIN_HASH_SIZE * sizeof(struct list_head),
+	_origins = kmalloc(array_size(ORIGIN_HASH_SIZE, sizeof(struct list_head)),
 			   GFP_KERNEL);
 	if (!_origins) {
 		DMERR("unable to allocate memory for _origins");
@@ -335,7 +335,7 @@ static int init_origin_hash(void)
 	for (i = 0; i < ORIGIN_HASH_SIZE; i++)
 		INIT_LIST_HEAD(_origins + i);
 
-	_dm_origins = kmalloc(ORIGIN_HASH_SIZE * sizeof(struct list_head),
+	_dm_origins = kmalloc(array_size(ORIGIN_HASH_SIZE, sizeof(struct list_head)),
 			      GFP_KERNEL);
 	if (!_dm_origins) {
 		DMERR("unable to allocate memory for _dm_origins");
diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
index caa51dd351b6..227818e985bb 100644
--- a/drivers/md/dm-table.c
+++ b/drivers/md/dm-table.c
@@ -561,7 +561,7 @@ static char **realloc_argv(unsigned *size, char **old_argv)
 		new_size = 8;
 		gfp = GFP_NOIO;
 	}
-	argv = kmalloc(new_size * sizeof(*argv), gfp);
+	argv = kmalloc(array_size(new_size, sizeof(*argv)), gfp);
 	if (argv) {
 		memcpy(argv, old_argv, *size * sizeof(*argv));
 		*size = new_size;
diff --git a/drivers/md/md-bitmap.c b/drivers/md/md-bitmap.c
index 239c7bb3929b..c46dbc4dc367 100644
--- a/drivers/md/md-bitmap.c
+++ b/drivers/md/md-bitmap.c
@@ -789,8 +789,8 @@ static int bitmap_storage_alloc(struct bitmap_storage *store,
 	num_pages = DIV_ROUND_UP(bytes, PAGE_SIZE);
 	offset = slot_number * num_pages;
 
-	store->filemap = kmalloc(sizeof(struct page *)
-				 * num_pages, GFP_KERNEL);
+	store->filemap = kmalloc(array_size(num_pages, sizeof(struct page *)),
+				 GFP_KERNEL);
 	if (!store->filemap)
 		return -ENOMEM;
 
@@ -2117,7 +2117,7 @@ int bitmap_resize(struct bitmap *bitmap, sector_t blocks,
 
 	pages = DIV_ROUND_UP(chunks, PAGE_COUNTER_RATIO);
 
-	new_bp = kzalloc(pages * sizeof(*new_bp), GFP_KERNEL);
+	new_bp = kzalloc(array_size(pages, sizeof(*new_bp)), GFP_KERNEL);
 	ret = -ENOMEM;
 	if (!new_bp) {
 		bitmap_file_unmap(&store);
diff --git a/drivers/md/raid10.c b/drivers/md/raid10.c
index 3c60774c8430..2a7bd1000cb5 100644
--- a/drivers/md/raid10.c
+++ b/drivers/md/raid10.c
@@ -175,7 +175,8 @@ static void * r10buf_pool_alloc(gfp_t gfp_flags, void *data)
 		nalloc_rp = nalloc;
 	else
 		nalloc_rp = nalloc * 2;
-	rps = kmalloc(sizeof(struct resync_pages) * nalloc_rp, gfp_flags);
+	rps = kmalloc(array_size(nalloc_rp, sizeof(struct resync_pages)),
+		      gfp_flags);
 	if (!rps)
 		goto out_free_r10bio;
 
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index be117d0a65a8..c08d83dcf1e2 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -2391,7 +2391,8 @@ static int resize_stripes(struct r5conf *conf, int newsize)
 	 * is completely stalled, so now is a good time to resize
 	 * conf->disks and the scribble region
 	 */
-	ndisks = kzalloc(newsize * sizeof(struct disk_info), GFP_NOIO);
+	ndisks = kzalloc(array_size(newsize, sizeof(struct disk_info)),
+			 GFP_NOIO);
 	if (ndisks) {
 		for (i = 0; i < conf->pool_size; i++)
 			ndisks[i] = conf->disks[i];
@@ -6888,8 +6889,8 @@ static struct r5conf *setup_conf(struct mddev *mddev)
 		goto abort;
 	INIT_LIST_HEAD(&conf->free_list);
 	INIT_LIST_HEAD(&conf->pending_list);
-	conf->pending_data = kzalloc(sizeof(struct r5pending_data) *
-		PENDING_IO_MAX, GFP_KERNEL);
+	conf->pending_data = kzalloc(array_size(PENDING_IO_MAX, sizeof(struct r5pending_data)),
+				     GFP_KERNEL);
 	if (!conf->pending_data)
 		goto abort;
 	for (i = 0; i < PENDING_IO_MAX; i++)
@@ -6938,8 +6939,8 @@ static struct r5conf *setup_conf(struct mddev *mddev)
 		conf->previous_raid_disks = mddev->raid_disks - mddev->delta_disks;
 	max_disks = max(conf->raid_disks, conf->previous_raid_disks);
 
-	conf->disks = kzalloc(max_disks * sizeof(struct disk_info),
-			      GFP_KERNEL);
+	conf->disks = kzalloc(array_size(max_disks, sizeof(struct disk_info)),
+		              GFP_KERNEL);
 
 	if (!conf->disks)
 		goto abort;
diff --git a/drivers/media/dvb-frontends/dib7000p.c b/drivers/media/dvb-frontends/dib7000p.c
index 902af482448e..c5e4000c0c05 100644
--- a/drivers/media/dvb-frontends/dib7000p.c
+++ b/drivers/media/dvb-frontends/dib7000p.c
@@ -2018,10 +2018,10 @@ static int dib7000pc_detection(struct i2c_adapter *i2c_adap)
 	};
 	int ret = 0;
 
-	tx = kzalloc(2*sizeof(u8), GFP_KERNEL);
+	tx = kzalloc(array_size(2, sizeof(u8)), GFP_KERNEL);
 	if (!tx)
 		return -ENOMEM;
-	rx = kzalloc(2*sizeof(u8), GFP_KERNEL);
+	rx = kzalloc(array_size(2, sizeof(u8)), GFP_KERNEL);
 	if (!rx) {
 		ret = -ENOMEM;
 		goto rx_memory_error;
diff --git a/drivers/media/dvb-frontends/dib8000.c b/drivers/media/dvb-frontends/dib8000.c
index 6f35173d2968..09b69bebf3ba 100644
--- a/drivers/media/dvb-frontends/dib8000.c
+++ b/drivers/media/dvb-frontends/dib8000.c
@@ -4271,12 +4271,14 @@ static int dib8000_i2c_enumeration(struct i2c_adapter *host, int no_of_demods,
 	u8 new_addr = 0;
 	struct i2c_device client = {.adap = host };
 
-	client.i2c_write_buffer = kzalloc(4 * sizeof(u8), GFP_KERNEL);
+	client.i2c_write_buffer = kzalloc(array_size(4, sizeof(u8)),
+					  GFP_KERNEL);
 	if (!client.i2c_write_buffer) {
 		dprintk("%s: not enough memory\n", __func__);
 		return -ENOMEM;
 	}
-	client.i2c_read_buffer = kzalloc(4 * sizeof(u8), GFP_KERNEL);
+	client.i2c_read_buffer = kzalloc(array_size(4, sizeof(u8)),
+					 GFP_KERNEL);
 	if (!client.i2c_read_buffer) {
 		dprintk("%s: not enough memory\n", __func__);
 		ret = -ENOMEM;
diff --git a/drivers/media/dvb-frontends/dib9000.c b/drivers/media/dvb-frontends/dib9000.c
index f9289f488de7..d4ffed23a541 100644
--- a/drivers/media/dvb-frontends/dib9000.c
+++ b/drivers/media/dvb-frontends/dib9000.c
@@ -2381,12 +2381,14 @@ int dib9000_i2c_enumeration(struct i2c_adapter *i2c, int no_of_demods, u8 defaul
 	u8 new_addr = 0;
 	struct i2c_device client = {.i2c_adap = i2c };
 
-	client.i2c_write_buffer = kzalloc(4 * sizeof(u8), GFP_KERNEL);
+	client.i2c_write_buffer = kzalloc(array_size(4, sizeof(u8)),
+					  GFP_KERNEL);
 	if (!client.i2c_write_buffer) {
 		dprintk("%s: not enough memory\n", __func__);
 		return -ENOMEM;
 	}
-	client.i2c_read_buffer = kzalloc(4 * sizeof(u8), GFP_KERNEL);
+	client.i2c_read_buffer = kzalloc(array_size(4, sizeof(u8)),
+					 GFP_KERNEL);
 	if (!client.i2c_read_buffer) {
 		dprintk("%s: not enough memory\n", __func__);
 		ret = -ENOMEM;
diff --git a/drivers/media/pci/ivtv/ivtvfb.c b/drivers/media/pci/ivtv/ivtvfb.c
index 8e62b8be6529..aa5eb1b8d63e 100644
--- a/drivers/media/pci/ivtv/ivtvfb.c
+++ b/drivers/media/pci/ivtv/ivtvfb.c
@@ -1077,7 +1077,8 @@ static int ivtvfb_init_vidmode(struct ivtv *itv)
 
 	/* Allocate the pseudo palette */
 	oi->ivtvfb_info.pseudo_palette =
-		kmalloc(sizeof(u32) * 16, GFP_KERNEL|__GFP_NOWARN);
+		kmalloc(array_size(16, sizeof(u32)),
+			GFP_KERNEL | __GFP_NOWARN);
 
 	if (!oi->ivtvfb_info.pseudo_palette) {
 		IVTVFB_ERR("abort, unable to alloc pseudo palette\n");
diff --git a/drivers/media/usb/au0828/au0828-video.c b/drivers/media/usb/au0828/au0828-video.c
index 964cd7bcdd2c..80330668d09e 100644
--- a/drivers/media/usb/au0828/au0828-video.c
+++ b/drivers/media/usb/au0828/au0828-video.c
@@ -217,14 +217,15 @@ static int au0828_init_isoc(struct au0828_dev *dev, int max_packets,
 	dev->isoc_ctl.isoc_copy = isoc_copy;
 	dev->isoc_ctl.num_bufs = num_bufs;
 
-	dev->isoc_ctl.urb = kzalloc(sizeof(void *)*num_bufs,  GFP_KERNEL);
+	dev->isoc_ctl.urb = kzalloc(array_size(num_bufs, sizeof(void *)),
+				    GFP_KERNEL);
 	if (!dev->isoc_ctl.urb) {
 		au0828_isocdbg("cannot alloc memory for usb buffers\n");
 		return -ENOMEM;
 	}
 
-	dev->isoc_ctl.transfer_buffer = kzalloc(sizeof(void *)*num_bufs,
-					      GFP_KERNEL);
+	dev->isoc_ctl.transfer_buffer = kzalloc(array_size(num_bufs, sizeof(void *)),
+						GFP_KERNEL);
 	if (!dev->isoc_ctl.transfer_buffer) {
 		au0828_isocdbg("cannot allocate memory for usb transfer\n");
 		kfree(dev->isoc_ctl.urb);
diff --git a/drivers/media/usb/cpia2/cpia2_usb.c b/drivers/media/usb/cpia2/cpia2_usb.c
index b51fc372ca25..55dc1f09d4c6 100644
--- a/drivers/media/usb/cpia2/cpia2_usb.c
+++ b/drivers/media/usb/cpia2/cpia2_usb.c
@@ -663,7 +663,8 @@ static int submit_urbs(struct camera_data *cam)
 		if (cam->sbuf[i].data)
 			continue;
 		cam->sbuf[i].data =
-		    kmalloc(FRAMES_PER_DESC * FRAME_SIZE_PER_DESC, GFP_KERNEL);
+		    kmalloc(array_size(FRAME_SIZE_PER_DESC, FRAMES_PER_DESC),
+			    GFP_KERNEL);
 		if (!cam->sbuf[i].data) {
 			while (--i >= 0) {
 				kfree(cam->sbuf[i].data);
diff --git a/drivers/media/usb/cx231xx/cx231xx-core.c b/drivers/media/usb/cx231xx/cx231xx-core.c
index 4f43668df15d..aa73fb2a1bf6 100644
--- a/drivers/media/usb/cx231xx/cx231xx-core.c
+++ b/drivers/media/usb/cx231xx/cx231xx-core.c
@@ -1034,7 +1034,7 @@ int cx231xx_init_isoc(struct cx231xx *dev, int max_packets,
 		dma_q->partial_buf[i] = 0;
 
 	dev->video_mode.isoc_ctl.urb =
-	    kzalloc(sizeof(void *) * num_bufs, GFP_KERNEL);
+	    kzalloc(array_size(num_bufs, sizeof(void *)), GFP_KERNEL);
 	if (!dev->video_mode.isoc_ctl.urb) {
 		dev_err(dev->dev,
 			"cannot alloc memory for usb buffers\n");
@@ -1042,7 +1042,7 @@ int cx231xx_init_isoc(struct cx231xx *dev, int max_packets,
 	}
 
 	dev->video_mode.isoc_ctl.transfer_buffer =
-	    kzalloc(sizeof(void *) * num_bufs, GFP_KERNEL);
+	    kzalloc(array_size(num_bufs, sizeof(void *)), GFP_KERNEL);
 	if (!dev->video_mode.isoc_ctl.transfer_buffer) {
 		dev_err(dev->dev,
 			"cannot allocate memory for usbtransfer\n");
@@ -1169,7 +1169,7 @@ int cx231xx_init_bulk(struct cx231xx *dev, int max_packets,
 		dma_q->partial_buf[i] = 0;
 
 	dev->video_mode.bulk_ctl.urb =
-	    kzalloc(sizeof(void *) * num_bufs, GFP_KERNEL);
+	    kzalloc(array_size(num_bufs, sizeof(void *)), GFP_KERNEL);
 	if (!dev->video_mode.bulk_ctl.urb) {
 		dev_err(dev->dev,
 			"cannot alloc memory for usb buffers\n");
@@ -1177,7 +1177,7 @@ int cx231xx_init_bulk(struct cx231xx *dev, int max_packets,
 	}
 
 	dev->video_mode.bulk_ctl.transfer_buffer =
-	    kzalloc(sizeof(void *) * num_bufs, GFP_KERNEL);
+	    kzalloc(array_size(num_bufs, sizeof(void *)), GFP_KERNEL);
 	if (!dev->video_mode.bulk_ctl.transfer_buffer) {
 		dev_err(dev->dev,
 			"cannot allocate memory for usbtransfer\n");
diff --git a/drivers/media/usb/cx231xx/cx231xx-vbi.c b/drivers/media/usb/cx231xx/cx231xx-vbi.c
index d3bfe8e23b1f..6e2a2d6e651b 100644
--- a/drivers/media/usb/cx231xx/cx231xx-vbi.c
+++ b/drivers/media/usb/cx231xx/cx231xx-vbi.c
@@ -415,7 +415,7 @@ int cx231xx_init_vbi_isoc(struct cx231xx *dev, int max_packets,
 	for (i = 0; i < 8; i++)
 		dma_q->partial_buf[i] = 0;
 
-	dev->vbi_mode.bulk_ctl.urb = kzalloc(sizeof(void *) * num_bufs,
+	dev->vbi_mode.bulk_ctl.urb = kzalloc(array_size(num_bufs, sizeof(void *)),
 					     GFP_KERNEL);
 	if (!dev->vbi_mode.bulk_ctl.urb) {
 		dev_err(dev->dev,
@@ -424,7 +424,7 @@ int cx231xx_init_vbi_isoc(struct cx231xx *dev, int max_packets,
 	}
 
 	dev->vbi_mode.bulk_ctl.transfer_buffer =
-	    kzalloc(sizeof(void *) * num_bufs, GFP_KERNEL);
+	    kzalloc(array_size(num_bufs, sizeof(void *)), GFP_KERNEL);
 	if (!dev->vbi_mode.bulk_ctl.transfer_buffer) {
 		dev_err(dev->dev,
 			"cannot allocate memory for usbtransfer\n");
diff --git a/drivers/media/usb/go7007/go7007-usb.c b/drivers/media/usb/go7007/go7007-usb.c
index ed9bcaf08d5e..0c0c6de6345e 100644
--- a/drivers/media/usb/go7007/go7007-usb.c
+++ b/drivers/media/usb/go7007/go7007-usb.c
@@ -1143,7 +1143,8 @@ static int go7007_usb_probe(struct usb_interface *intf,
 	usb->intr_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (usb->intr_urb == NULL)
 		goto allocfail;
-	usb->intr_urb->transfer_buffer = kmalloc(2*sizeof(u16), GFP_KERNEL);
+	usb->intr_urb->transfer_buffer = kmalloc(array_size(2, sizeof(u16)),
+						 GFP_KERNEL);
 	if (usb->intr_urb->transfer_buffer == NULL)
 		goto allocfail;
 
diff --git a/drivers/media/usb/pvrusb2/pvrusb2-std.c b/drivers/media/usb/pvrusb2/pvrusb2-std.c
index 21bb20dba82c..a37920accac5 100644
--- a/drivers/media/usb/pvrusb2/pvrusb2-std.c
+++ b/drivers/media/usb/pvrusb2/pvrusb2-std.c
@@ -361,7 +361,7 @@ struct v4l2_standard *pvr2_std_create_enum(unsigned int *countptr,
 		   std_cnt);
 	if (!std_cnt) return NULL; // paranoia
 
-	stddefs = kzalloc(sizeof(struct v4l2_standard) * std_cnt,
+	stddefs = kzalloc(array_size(std_cnt, sizeof(struct v4l2_standard)),
 			  GFP_KERNEL);
 	if (!stddefs)
 		return NULL;
diff --git a/drivers/media/usb/stk1160/stk1160-video.c b/drivers/media/usb/stk1160/stk1160-video.c
index 423c03a0638d..ac3869a3630c 100644
--- a/drivers/media/usb/stk1160/stk1160-video.c
+++ b/drivers/media/usb/stk1160/stk1160-video.c
@@ -439,14 +439,15 @@ int stk1160_alloc_isoc(struct stk1160 *dev)
 
 	dev->isoc_ctl.buf = NULL;
 	dev->isoc_ctl.max_pkt_size = dev->max_pkt_size;
-	dev->isoc_ctl.urb = kzalloc(sizeof(void *)*num_bufs, GFP_KERNEL);
+	dev->isoc_ctl.urb = kzalloc(array_size(num_bufs, sizeof(void *)),
+				    GFP_KERNEL);
 	if (!dev->isoc_ctl.urb) {
 		stk1160_err("out of memory for urb array\n");
 		return -ENOMEM;
 	}
 
-	dev->isoc_ctl.transfer_buffer = kzalloc(sizeof(void *)*num_bufs,
-					      GFP_KERNEL);
+	dev->isoc_ctl.transfer_buffer = kzalloc(array_size(num_bufs, sizeof(void *)),
+						GFP_KERNEL);
 	if (!dev->isoc_ctl.transfer_buffer) {
 		stk1160_err("out of memory for usb transfers\n");
 		kfree(dev->isoc_ctl.urb);
diff --git a/drivers/media/usb/stkwebcam/stk-webcam.c b/drivers/media/usb/stkwebcam/stk-webcam.c
index 22389b56ec24..541e3c2349b1 100644
--- a/drivers/media/usb/stkwebcam/stk-webcam.c
+++ b/drivers/media/usb/stkwebcam/stk-webcam.c
@@ -567,8 +567,8 @@ static int stk_prepare_sio_buffers(struct stk_camera *dev, unsigned n_sbufs)
 	if (dev->sio_bufs != NULL)
 		pr_err("sio_bufs already allocated\n");
 	else {
-		dev->sio_bufs = kzalloc(n_sbufs * sizeof(struct stk_sio_buffer),
-				GFP_KERNEL);
+		dev->sio_bufs = kzalloc(array_size(n_sbufs, sizeof(struct stk_sio_buffer)),
+					GFP_KERNEL);
 		if (dev->sio_bufs == NULL)
 			return -ENOMEM;
 		for (i = 0; i < n_sbufs; i++) {
diff --git a/drivers/media/usb/tm6000/tm6000-video.c b/drivers/media/usb/tm6000/tm6000-video.c
index b2399d4266da..9ef9f71094f5 100644
--- a/drivers/media/usb/tm6000/tm6000-video.c
+++ b/drivers/media/usb/tm6000/tm6000-video.c
@@ -463,11 +463,13 @@ static int tm6000_alloc_urb_buffers(struct tm6000_core *dev)
 	if (dev->urb_buffer)
 		return 0;
 
-	dev->urb_buffer = kmalloc(sizeof(void *)*num_bufs, GFP_KERNEL);
+	dev->urb_buffer = kmalloc(array_size(num_bufs, sizeof(void *)),
+				  GFP_KERNEL);
 	if (!dev->urb_buffer)
 		return -ENOMEM;
 
-	dev->urb_dma = kmalloc(sizeof(dma_addr_t *)*num_bufs, GFP_KERNEL);
+	dev->urb_dma = kmalloc(array_size(num_bufs, sizeof(dma_addr_t *)),
+			       GFP_KERNEL);
 	if (!dev->urb_dma)
 		return -ENOMEM;
 
@@ -583,12 +585,13 @@ static int tm6000_prepare_isoc(struct tm6000_core *dev)
 
 	dev->isoc_ctl.num_bufs = num_bufs;
 
-	dev->isoc_ctl.urb = kmalloc(sizeof(void *)*num_bufs, GFP_KERNEL);
+	dev->isoc_ctl.urb = kmalloc(array_size(num_bufs, sizeof(void *)),
+				    GFP_KERNEL);
 	if (!dev->isoc_ctl.urb)
 		return -ENOMEM;
 
-	dev->isoc_ctl.transfer_buffer = kmalloc(sizeof(void *)*num_bufs,
-				   GFP_KERNEL);
+	dev->isoc_ctl.transfer_buffer = kmalloc(array_size(num_bufs, sizeof(void *)),
+						GFP_KERNEL);
 	if (!dev->isoc_ctl.transfer_buffer) {
 		kfree(dev->isoc_ctl.urb);
 		return -ENOMEM;
diff --git a/drivers/media/usb/usbtv/usbtv-video.c b/drivers/media/usb/usbtv/usbtv-video.c
index 3668a04359e8..a4433d5518e6 100644
--- a/drivers/media/usb/usbtv/usbtv-video.c
+++ b/drivers/media/usb/usbtv/usbtv-video.c
@@ -424,8 +424,8 @@ static struct urb *usbtv_setup_iso_transfer(struct usbtv *usbtv)
 	ip->pipe = usb_rcvisocpipe(usbtv->udev, USBTV_VIDEO_ENDP);
 	ip->interval = 1;
 	ip->transfer_flags = URB_ISO_ASAP;
-	ip->transfer_buffer = kzalloc(size * USBTV_ISOC_PACKETS,
-						GFP_KERNEL);
+	ip->transfer_buffer = kzalloc(array_size(USBTV_ISOC_PACKETS, size),
+				      GFP_KERNEL);
 	if (!ip->transfer_buffer) {
 		usb_free_urb(ip);
 		return NULL;
diff --git a/drivers/memstick/core/ms_block.c b/drivers/memstick/core/ms_block.c
index 57b13dfbd21e..a3db881094e1 100644
--- a/drivers/memstick/core/ms_block.c
+++ b/drivers/memstick/core/ms_block.c
@@ -1201,7 +1201,8 @@ static int msb_read_boot_blocks(struct msb_data *msb)
 	dbg_verbose("Start of a scan for the boot blocks");
 
 	if (!msb->boot_page) {
-		page = kmalloc(sizeof(struct ms_boot_page)*2, GFP_KERNEL);
+		page = kmalloc(array_size(2, sizeof(struct ms_boot_page)),
+			       GFP_KERNEL);
 		if (!page)
 			return -ENOMEM;
 
diff --git a/drivers/mfd/timberdale.c b/drivers/mfd/timberdale.c
index cd4a6d7d6750..74ef35d3041d 100644
--- a/drivers/mfd/timberdale.c
+++ b/drivers/mfd/timberdale.c
@@ -707,8 +707,8 @@ static int timb_probe(struct pci_dev *dev,
 		goto err_config;
 	}
 
-	msix_entries = kzalloc(TIMBERDALE_NR_IRQS * sizeof(*msix_entries),
-		GFP_KERNEL);
+	msix_entries = kzalloc(array_size(TIMBERDALE_NR_IRQS, sizeof(*msix_entries)),
+			       GFP_KERNEL);
 	if (!msix_entries)
 		goto err_config;
 
diff --git a/drivers/misc/altera-stapl/altera.c b/drivers/misc/altera-stapl/altera.c
index f53e217e963f..50e86182217f 100644
--- a/drivers/misc/altera-stapl/altera.c
+++ b/drivers/misc/altera-stapl/altera.c
@@ -304,13 +304,14 @@ static int altera_execute(struct altera_state *astate,
 	if (sym_count <= 0)
 		goto exit_done;
 
-	vars = kzalloc(sym_count * sizeof(long), GFP_KERNEL);
+	vars = kzalloc(array_size(sym_count, sizeof(long)), GFP_KERNEL);
 
 	if (vars == NULL)
 		status = -ENOMEM;
 
 	if (status == 0) {
-		var_size = kzalloc(sym_count * sizeof(s32), GFP_KERNEL);
+		var_size = kzalloc(array_size(sym_count, sizeof(s32)),
+				   GFP_KERNEL);
 
 		if (var_size == NULL)
 			status = -ENOMEM;
@@ -1136,8 +1137,8 @@ static int altera_execute(struct altera_state *astate,
 				/* Allocate a writable buffer for this array */
 				count = var_size[variable_id];
 				long_tmp = vars[variable_id];
-				longptr_tmp = kzalloc(count * sizeof(long),
-								GFP_KERNEL);
+				longptr_tmp = kzalloc(array_size(count, sizeof(long)),
+						      GFP_KERNEL);
 				vars[variable_id] = (long)longptr_tmp;
 
 				if (vars[variable_id] == 0) {
diff --git a/drivers/misc/cxl/guest.c b/drivers/misc/cxl/guest.c
index f58b4b6c79f2..911ea2e8b863 100644
--- a/drivers/misc/cxl/guest.c
+++ b/drivers/misc/cxl/guest.c
@@ -89,7 +89,8 @@ static ssize_t guest_collect_vpd(struct cxl *adapter, struct cxl_afu *afu,
 		mod = 0;
 	}
 
-	vpd_buf = kzalloc(entries * sizeof(unsigned long *), GFP_KERNEL);
+	vpd_buf = kzalloc(array_size(entries, sizeof(unsigned long *)),
+			  GFP_KERNEL);
 	if (!vpd_buf)
 		return -ENOMEM;
 
diff --git a/drivers/misc/cxl/of.c b/drivers/misc/cxl/of.c
index ec175ea5dfba..48433e888468 100644
--- a/drivers/misc/cxl/of.c
+++ b/drivers/misc/cxl/of.c
@@ -302,7 +302,7 @@ static int read_adapter_irq_config(struct cxl *adapter, struct device_node *np)
 	if (nranges == 0 || (nranges * 2 * sizeof(int)) != len)
 		return -EINVAL;
 
-	adapter->guest->irq_avail = kzalloc(nranges * sizeof(struct irq_avail),
+	adapter->guest->irq_avail = kzalloc(array_size(nranges, sizeof(struct irq_avail)),
 					    GFP_KERNEL);
 	if (adapter->guest->irq_avail == NULL)
 		return -ENOMEM;
diff --git a/drivers/misc/sgi-xp/xpc_main.c b/drivers/misc/sgi-xp/xpc_main.c
index 0c775d6fcf59..5c833f11636c 100644
--- a/drivers/misc/sgi-xp/xpc_main.c
+++ b/drivers/misc/sgi-xp/xpc_main.c
@@ -416,7 +416,7 @@ xpc_setup_ch_structures(struct xpc_partition *part)
 	 * memory.
 	 */
 	DBUG_ON(part->channels != NULL);
-	part->channels = kzalloc(sizeof(struct xpc_channel) * XPC_MAX_NCHANNELS,
+	part->channels = kzalloc(array_size(XPC_MAX_NCHANNELS, sizeof(struct xpc_channel)),
 				 GFP_KERNEL);
 	if (part->channels == NULL) {
 		dev_err(xpc_chan, "can't get memory for channels\n");
@@ -905,8 +905,8 @@ xpc_setup_partitions(void)
 	short partid;
 	struct xpc_partition *part;
 
-	xpc_partitions = kzalloc(sizeof(struct xpc_partition) *
-				 xp_max_npartitions, GFP_KERNEL);
+	xpc_partitions = kzalloc(array_size(xp_max_npartitions, sizeof(struct xpc_partition)),
+				 GFP_KERNEL);
 	if (xpc_partitions == NULL) {
 		dev_err(xpc_part, "can't get memory for partition structure\n");
 		return -ENOMEM;
diff --git a/drivers/misc/sgi-xp/xpc_partition.c b/drivers/misc/sgi-xp/xpc_partition.c
index 6956f7e7d439..cc45797f8a2c 100644
--- a/drivers/misc/sgi-xp/xpc_partition.c
+++ b/drivers/misc/sgi-xp/xpc_partition.c
@@ -425,7 +425,7 @@ xpc_discovery(void)
 	if (remote_rp == NULL)
 		return;
 
-	discovered_nasids = kzalloc(sizeof(long) * xpc_nasid_mask_nlongs,
+	discovered_nasids = kzalloc(array_size(xpc_nasid_mask_nlongs, sizeof(long)),
 				    GFP_KERNEL);
 	if (discovered_nasids == NULL) {
 		kfree(remote_rp_base);
diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index 0339538c182d..175609841e7d 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -449,12 +449,14 @@ static int qp_alloc_ppn_set(void *prod_q,
 		return VMCI_ERROR_ALREADY_EXISTS;
 
 	produce_ppns =
-	    kmalloc(num_produce_pages * sizeof(*produce_ppns), GFP_KERNEL);
+	    kmalloc(array_size(num_produce_pages, sizeof(*produce_ppns)),
+		    GFP_KERNEL);
 	if (!produce_ppns)
 		return VMCI_ERROR_NO_MEM;
 
 	consume_ppns =
-	    kmalloc(num_consume_pages * sizeof(*consume_ppns), GFP_KERNEL);
+	    kmalloc(array_size(num_consume_pages, sizeof(*consume_ppns)),
+		    GFP_KERNEL);
 	if (!consume_ppns) {
 		kfree(produce_ppns);
 		return VMCI_ERROR_NO_MEM;
diff --git a/drivers/mtd/ar7part.c b/drivers/mtd/ar7part.c
index 90575deff0ae..8607508fbd6b 100644
--- a/drivers/mtd/ar7part.c
+++ b/drivers/mtd/ar7part.c
@@ -55,7 +55,8 @@ static int create_mtd_partitions(struct mtd_info *master,
 	int retries = 10;
 	struct mtd_partition *ar7_parts;
 
-	ar7_parts = kzalloc(sizeof(*ar7_parts) * AR7_PARTS, GFP_KERNEL);
+	ar7_parts = kzalloc(array_size(AR7_PARTS, sizeof(*ar7_parts)),
+			    GFP_KERNEL);
 	if (!ar7_parts)
 		return -ENOMEM;
 	ar7_parts[0].name = "loader";
diff --git a/drivers/mtd/bcm47xxpart.c b/drivers/mtd/bcm47xxpart.c
index fe2581d9d882..3b71155619a2 100644
--- a/drivers/mtd/bcm47xxpart.c
+++ b/drivers/mtd/bcm47xxpart.c
@@ -110,7 +110,7 @@ static int bcm47xxpart_parse(struct mtd_info *master,
 		blocksize = 0x1000;
 
 	/* Alloc */
-	parts = kzalloc(sizeof(struct mtd_partition) * BCM47XXPART_MAX_PARTS,
+	parts = kzalloc(array_size(BCM47XXPART_MAX_PARTS, sizeof(struct mtd_partition)),
 			GFP_KERNEL);
 	if (!parts)
 		return -ENOMEM;
diff --git a/drivers/mtd/chips/cfi_cmdset_0002.c b/drivers/mtd/chips/cfi_cmdset_0002.c
index 668e2cbc155b..5799f866629a 100644
--- a/drivers/mtd/chips/cfi_cmdset_0002.c
+++ b/drivers/mtd/chips/cfi_cmdset_0002.c
@@ -2622,7 +2622,8 @@ static int __maybe_unused cfi_ppb_unlock(struct mtd_info *mtd, loff_t ofs,
 	 * first check the locking status of all sectors and save
 	 * it for future use.
 	 */
-	sect = kzalloc(MAX_SECTORS * sizeof(struct ppb_lock), GFP_KERNEL);
+	sect = kzalloc(array_size(MAX_SECTORS, sizeof(struct ppb_lock)),
+		       GFP_KERNEL);
 	if (!sect)
 		return -ENOMEM;
 
diff --git a/drivers/mtd/devices/docg3.c b/drivers/mtd/devices/docg3.c
index c594fe5eac08..a1782ceae772 100644
--- a/drivers/mtd/devices/docg3.c
+++ b/drivers/mtd/devices/docg3.c
@@ -1828,7 +1828,8 @@ doc_probe_device(struct docg3_cascade *cascade, int floor, struct device *dev)
 	mtd->dev.parent = dev;
 	bbt_nbpages = DIV_ROUND_UP(docg3->max_block + 1,
 				   8 * DOC_LAYOUT_PAGE_SIZE);
-	docg3->bbt = kzalloc(bbt_nbpages * DOC_LAYOUT_PAGE_SIZE, GFP_KERNEL);
+	docg3->bbt = kzalloc(array_size(DOC_LAYOUT_PAGE_SIZE, bbt_nbpages),
+			     GFP_KERNEL);
 	if (!docg3->bbt)
 		goto nomem3;
 
diff --git a/drivers/mtd/maps/physmap_of_core.c b/drivers/mtd/maps/physmap_of_core.c
index 527b1682381f..8f859b488a98 100644
--- a/drivers/mtd/maps/physmap_of_core.c
+++ b/drivers/mtd/maps/physmap_of_core.c
@@ -197,7 +197,7 @@ static int of_flash_probe(struct platform_device *dev)
 
 	dev_set_drvdata(&dev->dev, info);
 
-	mtd_list = kzalloc(sizeof(*mtd_list) * count, GFP_KERNEL);
+	mtd_list = kzalloc(array_size(count, sizeof(*mtd_list)), GFP_KERNEL);
 	if (!mtd_list)
 		goto err_flash_remove;
 
diff --git a/drivers/mtd/mtdconcat.c b/drivers/mtd/mtdconcat.c
index 6b86d1a73cf2..b5eafaa16efa 100644
--- a/drivers/mtd/mtdconcat.c
+++ b/drivers/mtd/mtdconcat.c
@@ -778,8 +778,8 @@ struct mtd_info *mtd_concat_create(struct mtd_info *subdev[],	/* subdevices to c
 		concat->mtd.erasesize = max_erasesize;
 		concat->mtd.numeraseregions = num_erase_region;
 		concat->mtd.eraseregions = erase_region_p =
-		    kmalloc(num_erase_region *
-			    sizeof (struct mtd_erase_region_info), GFP_KERNEL);
+		    kmalloc(array_size(num_erase_region, sizeof(struct mtd_erase_region_info)),
+			    GFP_KERNEL);
 		if (!erase_region_p) {
 			kfree(concat);
 			printk
diff --git a/drivers/mtd/nand/raw/nand_bch.c b/drivers/mtd/nand/raw/nand_bch.c
index 7f11b68f6db1..8ad34b2621fe 100644
--- a/drivers/mtd/nand/raw/nand_bch.c
+++ b/drivers/mtd/nand/raw/nand_bch.c
@@ -186,7 +186,7 @@ struct nand_bch_control *nand_bch_init(struct mtd_info *mtd)
 	}
 
 	nbc->eccmask = kmalloc(eccbytes, GFP_KERNEL);
-	nbc->errloc = kmalloc(t*sizeof(*nbc->errloc), GFP_KERNEL);
+	nbc->errloc = kmalloc(array_size(t, sizeof(*nbc->errloc)), GFP_KERNEL);
 	if (!nbc->eccmask || !nbc->errloc)
 		goto fail;
 	/*
diff --git a/drivers/mtd/ofpart.c b/drivers/mtd/ofpart.c
index 615f8c173162..407e2867879d 100644
--- a/drivers/mtd/ofpart.c
+++ b/drivers/mtd/ofpart.c
@@ -71,7 +71,7 @@ static int parse_fixed_partitions(struct mtd_info *master,
 	if (nr_parts == 0)
 		return 0;
 
-	parts = kzalloc(nr_parts * sizeof(*parts), GFP_KERNEL);
+	parts = kzalloc(array_size(nr_parts, sizeof(*parts)), GFP_KERNEL);
 	if (!parts)
 		return -ENOMEM;
 
@@ -177,7 +177,7 @@ static int parse_ofoldpart_partitions(struct mtd_info *master,
 
 	nr_parts = plen / sizeof(part[0]);
 
-	parts = kzalloc(nr_parts * sizeof(*parts), GFP_KERNEL);
+	parts = kzalloc(array_size(nr_parts, sizeof(*parts)), GFP_KERNEL);
 	if (!parts)
 		return -ENOMEM;
 
diff --git a/drivers/mtd/parsers/parser_trx.c b/drivers/mtd/parsers/parser_trx.c
index df360a75e1eb..256ec568b0ab 100644
--- a/drivers/mtd/parsers/parser_trx.c
+++ b/drivers/mtd/parsers/parser_trx.c
@@ -62,7 +62,7 @@ static int parser_trx_parse(struct mtd_info *mtd,
 	uint8_t curr_part = 0, i = 0;
 	int err;
 
-	parts = kzalloc(sizeof(struct mtd_partition) * TRX_PARSER_MAX_PARTS,
+	parts = kzalloc(array_size(TRX_PARSER_MAX_PARTS, sizeof(struct mtd_partition)),
 			GFP_KERNEL);
 	if (!parts)
 		return -ENOMEM;
diff --git a/drivers/mtd/parsers/sharpslpart.c b/drivers/mtd/parsers/sharpslpart.c
index 8893dc82a5c8..bf9c7c76fffc 100644
--- a/drivers/mtd/parsers/sharpslpart.c
+++ b/drivers/mtd/parsers/sharpslpart.c
@@ -362,8 +362,8 @@ static int sharpsl_parse_mtd_partitions(struct mtd_info *master,
 		return err;
 	}
 
-	sharpsl_nand_parts = kzalloc(sizeof(*sharpsl_nand_parts) *
-				     SHARPSL_NAND_PARTS, GFP_KERNEL);
+	sharpsl_nand_parts = kzalloc(array_size(SHARPSL_NAND_PARTS, sizeof(*sharpsl_nand_parts)),
+				     GFP_KERNEL);
 	if (!sharpsl_nand_parts)
 		return -ENOMEM;
 
diff --git a/drivers/mtd/tests/stresstest.c b/drivers/mtd/tests/stresstest.c
index e509f8aa9a7e..4f60398f111c 100644
--- a/drivers/mtd/tests/stresstest.c
+++ b/drivers/mtd/tests/stresstest.c
@@ -199,7 +199,7 @@ static int __init mtd_stresstest_init(void)
 	err = -ENOMEM;
 	readbuf = vmalloc(bufsize);
 	writebuf = vmalloc(bufsize);
-	offsets = kmalloc(ebcnt * sizeof(int), GFP_KERNEL);
+	offsets = kmalloc(array_size(ebcnt, sizeof(int)), GFP_KERNEL);
 	if (!readbuf || !writebuf || !offsets)
 		goto out;
 	for (i = 0; i < ebcnt; i++)
diff --git a/drivers/mtd/ubi/eba.c b/drivers/mtd/ubi/eba.c
index 250e30fac61b..5d09fde485e5 100644
--- a/drivers/mtd/ubi/eba.c
+++ b/drivers/mtd/ubi/eba.c
@@ -1427,11 +1427,12 @@ int self_check_eba(struct ubi_device *ubi, struct ubi_attach_info *ai_fastmap,
 
 	num_volumes = ubi->vtbl_slots + UBI_INT_VOL_COUNT;
 
-	scan_eba = kmalloc(sizeof(*scan_eba) * num_volumes, GFP_KERNEL);
+	scan_eba = kmalloc(array_size(num_volumes, sizeof(*scan_eba)),
+			   GFP_KERNEL);
 	if (!scan_eba)
 		return -ENOMEM;
 
-	fm_eba = kmalloc(sizeof(*fm_eba) * num_volumes, GFP_KERNEL);
+	fm_eba = kmalloc(array_size(num_volumes, sizeof(*fm_eba)), GFP_KERNEL);
 	if (!fm_eba) {
 		kfree(scan_eba);
 		return -ENOMEM;
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 89d60d8e467c..9f00b4015dc9 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -703,7 +703,8 @@ static int __init slcan_init(void)
 	pr_info("slcan: serial line CAN interface driver\n");
 	pr_info("slcan: %d dynamic interface channels.\n", maxdev);
 
-	slcan_devs = kzalloc(sizeof(struct net_device *)*maxdev, GFP_KERNEL);
+	slcan_devs = kzalloc(array_size(maxdev, sizeof(struct net_device *)),
+			     GFP_KERNEL);
 	if (!slcan_devs)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index 12a6a93d221b..689a227d18f2 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -551,13 +551,13 @@ static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int
 	if (lance_debug > 6) printk(" (#0x%05lx)", (unsigned long)lp);
 	dev->ml_priv = lp;
 	lp->name = chipname;
-	lp->rx_buffs = (unsigned long)kmalloc(PKT_BUF_SZ*RX_RING_SIZE,
-						  GFP_DMA | GFP_KERNEL);
+	lp->rx_buffs = (unsigned long)kmalloc(array_size(RX_RING_SIZE, PKT_BUF_SZ),
+					      GFP_DMA | GFP_KERNEL);
 	if (!lp->rx_buffs)
 		goto out_lp;
 	if (lance_need_isa_bounce_buffers) {
-		lp->tx_bounce_buffs = kmalloc(PKT_BUF_SZ*TX_RING_SIZE,
-						  GFP_DMA | GFP_KERNEL);
+		lp->tx_bounce_buffs = kmalloc(array_size(TX_RING_SIZE, PKT_BUF_SZ),
+					      GFP_DMA | GFP_KERNEL);
 		if (!lp->tx_bounce_buffs)
 			goto out_rx;
 	} else
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9ffc4a8c5fc7..067c5f349808 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2666,7 +2666,7 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 	u32 good_mbuf_cnt;
 	u32 val;
 
-	good_mbuf = kmalloc(512 * sizeof(u16), GFP_KERNEL);
+	good_mbuf = kmalloc(array_size(512, sizeof(u16)), GFP_KERNEL);
 	if (good_mbuf == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index ffa7959f6b31..5d1d54478ef2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -571,7 +571,7 @@ int bnx2x_vf_mcast(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	else
 		set_bit(RAMROD_COMP_WAIT, &mcast.ramrod_flags);
 	if (mc_num) {
-		mc = kzalloc(mc_num * sizeof(struct bnx2x_mcast_list_elem),
+		mc = kzalloc(array_size(mc_num, sizeof(struct bnx2x_mcast_list_elem)),
 			     GFP_KERNEL);
 		if (!mc) {
 			BNX2X_ERR("Cannot Configure multicasts due to lack of memory\n");
@@ -1278,9 +1278,8 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 	}
 
 	/* allocate the queue arrays for all VFs */
-	bp->vfdb->vfqs = kzalloc(
-		BNX2X_MAX_NUM_VF_QUEUES * sizeof(struct bnx2x_vf_queue),
-		GFP_KERNEL);
+	bp->vfdb->vfqs = kzalloc(array_size(BNX2X_MAX_NUM_VF_QUEUES, sizeof(struct bnx2x_vf_queue)),
+				 GFP_KERNEL);
 
 	if (!bp->vfdb->vfqs) {
 		BNX2X_ERR("failed to allocate vf queue array\n");
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 38f635cf8408..dddaa97e2b1b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -444,7 +444,7 @@ static int bnxt_vf_reps_create(struct bnxt *bp)
 		return -ENOMEM;
 
 	/* storage for cfa_code to vf-idx mapping */
-	cfa_code_map = kmalloc(sizeof(*bp->cfa_code_map) * MAX_CFA_CODE,
+	cfa_code_map = kmalloc(array_size(MAX_CFA_CODE, sizeof(*bp->cfa_code_map)),
 			       GFP_KERNEL);
 	if (!cfa_code_map) {
 		rc = -ENOMEM;
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 8bc126a156e8..f23611362756 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1255,7 +1255,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 			cp->fcoe_init_cid = 0x10;
 	}
 
-	cp->iscsi_tbl = kzalloc(sizeof(struct cnic_iscsi) * MAX_ISCSI_TBL_SZ,
+	cp->iscsi_tbl = kzalloc(array_size(MAX_ISCSI_TBL_SZ, sizeof(struct cnic_iscsi)),
 				GFP_KERNEL);
 	if (!cp->iscsi_tbl)
 		goto error;
@@ -4100,7 +4100,7 @@ static int cnic_cm_alloc_mem(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	u32 port_id;
 
-	cp->csk_tbl = kzalloc(sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ,
+	cp->csk_tbl = kzalloc(array_size(MAX_CM_SK_TBL_SZ, sizeof(struct cnic_sock)),
 			      GFP_KERNEL);
 	if (!cp->csk_tbl)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 08bbb639be1a..667dbb3038f4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8631,8 +8631,8 @@ static int tg3_mem_tx_acquire(struct tg3 *tp)
 		tnapi++;
 
 	for (i = 0; i < tp->txq_cnt; i++, tnapi++) {
-		tnapi->tx_buffers = kzalloc(sizeof(struct tg3_tx_ring_info) *
-					    TG3_TX_RING_SIZE, GFP_KERNEL);
+		tnapi->tx_buffers = kzalloc(array_size(TG3_TX_RING_SIZE, sizeof(struct tg3_tx_ring_info)),
+					    GFP_KERNEL);
 		if (!tnapi->tx_buffers)
 			goto err_out;
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 69cc3e0119d6..30685a7e27ff 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3141,7 +3141,7 @@ bnad_set_rx_ucast_fltr(struct bnad *bnad)
 	if (uc_count > bna_attr(&bnad->bna)->num_ucmac)
 		goto mode_default;
 
-	mac_list = kzalloc(uc_count * ETH_ALEN, GFP_ATOMIC);
+	mac_list = kzalloc(array_size(ETH_ALEN, uc_count), GFP_ATOMIC);
 	if (mac_list == NULL)
 		goto mode_default;
 
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 2bd7c638b178..a95919b0fac4 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -739,7 +739,7 @@ static int xgmac_dma_desc_rings_init(struct net_device *dev)
 
 	netdev_dbg(priv->dev, "mtu [%d] bfsize [%d]\n", dev->mtu, bfsize);
 
-	priv->rx_skbuff = kzalloc(sizeof(struct sk_buff *) * DMA_RX_RING_SZ,
+	priv->rx_skbuff = kzalloc(array_size(DMA_RX_RING_SZ, sizeof(struct sk_buff *)),
 				  GFP_KERNEL);
 	if (!priv->rx_skbuff)
 		return -ENOMEM;
@@ -752,7 +752,7 @@ static int xgmac_dma_desc_rings_init(struct net_device *dev)
 	if (!priv->dma_rx)
 		goto err_dma_rx;
 
-	priv->tx_skbuff = kzalloc(sizeof(struct sk_buff *) * DMA_TX_RING_SZ,
+	priv->tx_skbuff = kzalloc(array_size(DMA_TX_RING_SZ, sizeof(struct sk_buff *)),
 				  GFP_KERNEL);
 	if (!priv->tx_skbuff)
 		goto err_tx_skb;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index f92dfa411de6..e8f5fa5dedd3 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -354,12 +354,12 @@ static int setup_glists(struct lio *lio, int num_iqs)
 	int i, j;
 
 	lio->glist_lock =
-	    kzalloc(sizeof(*lio->glist_lock) * num_iqs, GFP_KERNEL);
+	    kzalloc(array_size(num_iqs, sizeof(*lio->glist_lock)), GFP_KERNEL);
 	if (!lio->glist_lock)
 		return -ENOMEM;
 
 	lio->glist =
-	    kzalloc(sizeof(*lio->glist) * num_iqs, GFP_KERNEL);
+	    kzalloc(array_size(num_iqs, sizeof(*lio->glist)), GFP_KERNEL);
 	if (!lio->glist) {
 		kfree(lio->glist_lock);
 		lio->glist_lock = NULL;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
index 290039026ece..6e7dc11680ab 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -304,7 +304,8 @@ struct clip_tbl *t4_init_clip_tbl(unsigned int clipt_start,
 	for (i = 0; i < ctbl->clipt_size; ++i)
 		INIT_LIST_HEAD(&ctbl->hash_list[i]);
 
-	cl_list = kvzalloc(clipt_size*sizeof(struct clip_entry), GFP_KERNEL);
+	cl_list = kvzalloc(array_size(clipt_size, sizeof(struct clip_entry)),
+			   GFP_KERNEL);
 	if (!cl_list) {
 		kvfree(ctbl);
 		return NULL;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 251d5bdc972f..f714b0ef2001 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -873,7 +873,7 @@ static int cctrl_tbl_show(struct seq_file *seq, void *v)
 	u16 (*incr)[NCCTRL_WIN];
 	struct adapter *adap = seq->private;
 
-	incr = kmalloc(sizeof(*incr) * NMTUS, GFP_KERNEL);
+	incr = kmalloc(array_size(NMTUS, sizeof(*incr)), GFP_KERNEL);
 	if (!incr)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
index ab174bcfbfb0..c35f0a54b177 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -457,7 +457,8 @@ struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap)
 		unsigned int bmap_size;
 
 		bmap_size = BITS_TO_LONGS(max_tids);
-		link->tid_map = kvzalloc(sizeof(unsigned long) * bmap_size, GFP_KERNEL);
+		link->tid_map = kvzalloc(array_size(bmap_size, sizeof(unsigned long)),
+					 GFP_KERNEL);
 		if (!link->tid_map)
 			goto out_no_mem;
 		bitmap_zero(link->tid_map, max_tids);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index a95cde0fadf7..3ed6c73ffbe6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -561,14 +561,12 @@ int t4_uld_mem_alloc(struct adapter *adap)
 	if (!adap->uld)
 		return -ENOMEM;
 
-	s->uld_rxq_info = kzalloc(CXGB4_ULD_MAX *
-				  sizeof(struct sge_uld_rxq_info *),
+	s->uld_rxq_info = kzalloc(array_size(CXGB4_ULD_MAX, sizeof(struct sge_uld_rxq_info *)),
 				  GFP_KERNEL);
 	if (!s->uld_rxq_info)
 		goto err_uld;
 
-	s->uld_txq_info = kzalloc(CXGB4_TX_MAX *
-				  sizeof(struct sge_uld_txq_info *),
+	s->uld_txq_info = kzalloc(array_size(CXGB4_TX_MAX, sizeof(struct sge_uld_txq_info *)),
 				  GFP_KERNEL);
 	if (!s->uld_txq_info)
 		goto err_uld_rx;
diff --git a/drivers/net/ethernet/cortina/gemini.c b/drivers/net/ethernet/cortina/gemini.c
index bd3f6e4d1341..ee469dc269f8 100644
--- a/drivers/net/ethernet/cortina/gemini.c
+++ b/drivers/net/ethernet/cortina/gemini.c
@@ -910,8 +910,8 @@ static int geth_setup_freeq(struct gemini_ethernet *geth)
 	}
 
 	/* Allocate a mapping to page look-up index */
-	geth->freeq_pages = kzalloc(pages * sizeof(*geth->freeq_pages),
-				   GFP_KERNEL);
+	geth->freeq_pages = kzalloc(array_size(pages, sizeof(*geth->freeq_pages)),
+				    GFP_KERNEL);
 	if (!geth->freeq_pages)
 		goto err_freeq;
 	geth->num_freeq_pages = pages;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 2353c383f0a7..323b479dbf4c 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1118,8 +1118,8 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
-		u8 *mta = kmalloc(IXGB_MAX_NUM_MULTICAST_ADDRESSES *
-			      ETH_ALEN, GFP_ATOMIC);
+		u8 *mta = kmalloc(array_size(ETH_ALEN, IXGB_MAX_NUM_MULTICAST_ADDRESSES),
+				  GFP_ATOMIC);
 		u8 *addr;
 		if (!mta)
 			goto alloc_failed;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index c0e6ab42e0e1..d234c52debbf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -926,7 +926,7 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 	eeprom_len = last_word - first_word + 1;
 
-	eeprom_buff = kmalloc(sizeof(u16) * eeprom_len, GFP_KERNEL);
+	eeprom_buff = kmalloc(array_size(eeprom_len, sizeof(u16)), GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e0adac4a9a19..d66e832a6e8b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2229,13 +2229,13 @@ static int mlx4_en_copy_priv(struct mlx4_en_priv *dst,
 		if (!dst->tx_ring_num[t])
 			continue;
 
-		dst->tx_ring[t] = kzalloc(sizeof(struct mlx4_en_tx_ring *) *
-					  MAX_TX_RINGS, GFP_KERNEL);
+		dst->tx_ring[t] = kzalloc(array_size(MAX_TX_RINGS, sizeof(struct mlx4_en_tx_ring *)),
+					  GFP_KERNEL);
 		if (!dst->tx_ring[t])
 			goto err_free_tx;
 
-		dst->tx_cq[t] = kzalloc(sizeof(struct mlx4_en_cq *) *
-					MAX_TX_RINGS, GFP_KERNEL);
+		dst->tx_cq[t] = kzalloc(array_size(MAX_TX_RINGS, sizeof(struct mlx4_en_cq *)),
+					GFP_KERNEL);
 		if (!dst->tx_cq[t]) {
 			kfree(dst->tx_ring[t]);
 			goto err_free_tx;
@@ -3320,14 +3320,14 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		if (!priv->tx_ring_num[t])
 			continue;
 
-		priv->tx_ring[t] = kzalloc(sizeof(struct mlx4_en_tx_ring *) *
-					   MAX_TX_RINGS, GFP_KERNEL);
+		priv->tx_ring[t] = kzalloc(array_size(MAX_TX_RINGS, sizeof(struct mlx4_en_tx_ring *)),
+					   GFP_KERNEL);
 		if (!priv->tx_ring[t]) {
 			err = -ENOMEM;
 			goto err_free_tx;
 		}
-		priv->tx_cq[t] = kzalloc(sizeof(struct mlx4_en_cq *) *
-					 MAX_TX_RINGS, GFP_KERNEL);
+		priv->tx_cq[t] = kzalloc(array_size(MAX_TX_RINGS, sizeof(struct mlx4_en_cq *)),
+					 GFP_KERNEL);
 		if (!priv->tx_cq[t]) {
 			kfree(priv->tx_ring[t]);
 			err = -ENOMEM;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index bfef69235d71..c80f27a2a423 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2977,7 +2977,8 @@ static int mlx4_init_steering(struct mlx4_dev *dev)
 	int num_entries = dev->caps.num_ports;
 	int i, j;
 
-	priv->steer = kzalloc(sizeof(struct mlx4_steer) * num_entries, GFP_KERNEL);
+	priv->steer = kzalloc(array_size(num_entries, sizeof(struct mlx4_steer)),
+			      GFP_KERNEL);
 	if (!priv->steer)
 		return -ENOMEM;
 
@@ -3098,7 +3099,8 @@ static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
 		}
 	}
 
-	dev->dev_vfs = kzalloc(total_vfs * sizeof(*dev->dev_vfs), GFP_KERNEL);
+	dev->dev_vfs = kzalloc(array_size(total_vfs, sizeof(*dev->dev_vfs)),
+			       GFP_KERNEL);
 	if (NULL == dev->dev_vfs) {
 		mlx4_err(dev, "Failed to allocate memory for VFs\n");
 		goto disable_sriov;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
index 91262b0573e3..30a1f5c762d3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
@@ -740,7 +740,7 @@ int mlxsw_sp_tc_qdisc_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	mlxsw_sp_port->root_qdisc->prio_bitmap = 0xff;
 	mlxsw_sp_port->root_qdisc->tclass_num = MLXSW_SP_PORT_DEFAULT_TCLASS;
 
-	mlxsw_sp_qdisc = kzalloc(sizeof(*mlxsw_sp_qdisc) * IEEE_8021QAZ_MAX_TCS,
+	mlxsw_sp_qdisc = kzalloc(array_size(IEEE_8021QAZ_MAX_TCS, sizeof(*mlxsw_sp_qdisc)),
 				 GFP_KERNEL);
 	if (!mlxsw_sp_qdisc)
 		goto err_tclass_qdiscs_init;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
index 6223930a8155..64f56f71066b 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
@@ -2220,22 +2220,26 @@ __vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
 	channel->length = length;
 	channel->vp_id = vp_id;
 
-	channel->work_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	channel->work_arr = kzalloc(array_size(length, sizeof(void *)),
+				    GFP_KERNEL);
 	if (channel->work_arr == NULL)
 		goto exit1;
 
-	channel->free_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	channel->free_arr = kzalloc(array_size(length, sizeof(void *)),
+				    GFP_KERNEL);
 	if (channel->free_arr == NULL)
 		goto exit1;
 	channel->free_ptr = length;
 
-	channel->reserve_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	channel->reserve_arr = kzalloc(array_size(length, sizeof(void *)),
+				       GFP_KERNEL);
 	if (channel->reserve_arr == NULL)
 		goto exit1;
 	channel->reserve_ptr = length;
 	channel->reserve_top = 0;
 
-	channel->orig_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	channel->orig_arr = kzalloc(array_size(length, sizeof(void *)),
+				    GFP_KERNEL);
 	if (channel->orig_arr == NULL)
 		goto exit1;
 
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 7cd494611a74..3a949994ff25 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2178,7 +2178,7 @@ static void pch_gbe_set_multi(struct net_device *netdev)
 
 	if (mc_count >= PCH_GBE_MAR_ENTRIES)
 		return;
-	mta_list = kmalloc(mc_count * ETH_ALEN, GFP_ATOMIC);
+	mta_list = kmalloc(array_size(ETH_ALEN, mc_count), GFP_ATOMIC);
 	if (!mta_list)
 		return;
 
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 07a2eb3781b1..a80772bf125c 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -390,8 +390,8 @@ static int pasemi_mac_setup_rx_resources(const struct net_device *dev)
 	spin_lock_init(&ring->lock);
 
 	ring->size = RX_RING_SIZE;
-	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
-				  RX_RING_SIZE, GFP_KERNEL);
+	ring->ring_info = kzalloc(array_size(RX_RING_SIZE, sizeof(struct pasemi_mac_buffer)),
+				  GFP_KERNEL);
 
 	if (!ring->ring_info)
 		goto out_ring_info;
@@ -473,8 +473,8 @@ pasemi_mac_setup_tx_resources(const struct net_device *dev)
 	spin_lock_init(&ring->lock);
 
 	ring->size = TX_RING_SIZE;
-	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
-				  TX_RING_SIZE, GFP_KERNEL);
+	ring->ring_info = kzalloc(array_size(TX_RING_SIZE, sizeof(struct pasemi_mac_buffer)),
+				  GFP_KERNEL);
 	if (!ring->ring_info)
 		goto out_ring_info;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
index 3bb76da6baa2..06b1fad88360 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
@@ -149,12 +149,12 @@ int qed_init_alloc(struct qed_hwfn *p_hwfn)
 	if (IS_VF(p_hwfn->cdev))
 		return 0;
 
-	rt_data->b_valid = kzalloc(sizeof(bool) * RUNTIME_ARRAY_SIZE,
+	rt_data->b_valid = kzalloc(array_size(RUNTIME_ARRAY_SIZE, sizeof(bool)),
 				   GFP_KERNEL);
 	if (!rt_data->b_valid)
 		return -ENOMEM;
 
-	rt_data->init_val = kzalloc(sizeof(u32) * RUNTIME_ARRAY_SIZE,
+	rt_data->init_val = kzalloc(array_size(RUNTIME_ARRAY_SIZE, sizeof(u32)),
 				    GFP_KERNEL);
 	if (!rt_data->init_val) {
 		kfree(rt_data->b_valid);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1b5f7d57b6f8..f425cc12d472 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1025,15 +1025,15 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 
 	act_pci_func = ahw->total_nic_func;
 
-	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
-				 act_pci_func, GFP_KERNEL);
+	adapter->npars = kzalloc(array_size(act_pci_func, sizeof(struct qlcnic_npar_info)),
+				 GFP_KERNEL);
 	if (!adapter->npars) {
 		ret = -ENOMEM;
 		goto err_pci_info;
 	}
 
-	adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
-				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
+	adapter->eswitch = kzalloc(array_size(QLCNIC_NIU_MAX_XG_PORTS, sizeof(struct qlcnic_eswitch)),
+				   GFP_KERNEL);
 	if (!adapter->eswitch) {
 		ret = -ENOMEM;
 		goto err_npars;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index c58180f40844..debfa149e27d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -157,8 +157,8 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 	adapter->ahw->sriov = sriov;
 	sriov->num_vfs = num_vfs;
 	bc = &sriov->bc;
-	sriov->vf_info = kzalloc(sizeof(struct qlcnic_vf_info) *
-				 num_vfs, GFP_KERNEL);
+	sriov->vf_info = kzalloc(array_size(num_vfs, sizeof(struct qlcnic_vf_info)),
+				 GFP_KERNEL);
 	if (!sriov->vf_info) {
 		err = -ENOMEM;
 		goto qlcnic_free_sriov;
@@ -450,7 +450,8 @@ static int qlcnic_sriov_set_guest_vlan_mode(struct qlcnic_adapter *adapter,
 		return 0;
 
 	num_vlans = sriov->num_allowed_vlans;
-	sriov->allowed_vlans = kzalloc(sizeof(u16) * num_vlans, GFP_KERNEL);
+	sriov->allowed_vlans = kzalloc(array_size(num_vlans, sizeof(u16)),
+				       GFP_KERNEL);
 	if (!sriov->allowed_vlans)
 		return -ENOMEM;
 
@@ -706,7 +707,8 @@ static inline int qlcnic_sriov_alloc_bc_trans(struct qlcnic_bc_trans **trans)
 static inline int qlcnic_sriov_alloc_bc_msg(struct qlcnic_bc_hdr **hdr,
 					    u32 size)
 {
-	*hdr = kzalloc(sizeof(struct qlcnic_bc_hdr) * size, GFP_ATOMIC);
+	*hdr = kzalloc(array_size(size, sizeof(struct qlcnic_bc_hdr)),
+		       GFP_ATOMIC);
 	if (!*hdr)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/socionext/netsec.c b/drivers/net/ethernet/socionext/netsec.c
index f4c0b02ddad8..98dfeb50d07b 100644
--- a/drivers/net/ethernet/socionext/netsec.c
+++ b/drivers/net/ethernet/socionext/netsec.c
@@ -973,7 +973,8 @@ static int netsec_alloc_dring(struct netsec_priv *priv, enum ring_id id)
 		goto err;
 	}
 
-	dring->desc = kzalloc(DESC_NUM * sizeof(*dring->desc), GFP_KERNEL);
+	dring->desc = kzalloc(array_size(DESC_NUM, sizeof(*dring->desc)),
+			      GFP_KERNEL);
 	if (!dring->desc) {
 		ret = -ENOMEM;
 		goto err;
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index eed18f88bdff..e947c33fd9d5 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -2320,8 +2320,8 @@ static struct net_device *gelic_wl_alloc(struct gelic_card *card)
 	pr_debug("%s: wl=%p port=%p\n", __func__, wl, port);
 
 	/* allocate scan list */
-	wl->networks = kzalloc(sizeof(struct gelic_wl_scan_info) *
-			       GELIC_WL_BSS_MAX_ENT, GFP_KERNEL);
+	wl->networks = kzalloc(array_size(GELIC_WL_BSS_MAX_ENT, sizeof(struct gelic_wl_scan_info)),
+			       GFP_KERNEL);
 
 	if (!wl->networks)
 		goto fail_bss;
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f38e32a7ec9c..683f1de30b0b 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -742,11 +742,13 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 {
 	int i;
 
-	gtp->addr_hash = kmalloc(sizeof(struct hlist_head) * hsize, GFP_KERNEL);
+	gtp->addr_hash = kmalloc(array_size(hsize, sizeof(struct hlist_head)),
+				 GFP_KERNEL);
 	if (gtp->addr_hash == NULL)
 		return -ENOMEM;
 
-	gtp->tid_hash = kmalloc(sizeof(struct hlist_head) * hsize, GFP_KERNEL);
+	gtp->tid_hash = kmalloc(array_size(hsize, sizeof(struct hlist_head)),
+				GFP_KERNEL);
 	if (gtp->tid_hash == NULL)
 		goto err1;
 
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 1ab97d99b9ba..83e77a320573 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1583,7 +1583,8 @@ static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 			return -EPERM;
 		}
 
-		image = kmalloc(EEPROM_WORDS * sizeof(u32), GFP_KERNEL);
+		image = kmalloc(array_size(EEPROM_WORDS, sizeof(u32)),
+				GFP_KERNEL);
 		if (!image)
 			return -ENOMEM;
 
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index a6c87793d899..eb79d72506da 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1097,8 +1097,8 @@ static struct dp83640_clock *dp83640_clock_get_bus(struct mii_bus *bus)
 	if (!clock)
 		goto out;
 
-	clock->caps.pin_config = kzalloc(sizeof(struct ptp_pin_desc) *
-					 DP83640_N_PINS, GFP_KERNEL);
+	clock->caps.pin_config = kzalloc(array_size(DP83640_N_PINS, sizeof(struct ptp_pin_desc)),
+					 GFP_KERNEL);
 	if (!clock->caps.pin_config) {
 		kfree(clock);
 		clock = NULL;
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 8940417c30e5..e033cacbf743 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -1307,8 +1307,8 @@ static int __init slip_init(void)
 	printk(KERN_INFO "SLIP linefill/keepalive option.\n");
 #endif
 
-	slip_devs = kzalloc(sizeof(struct net_device *)*slip_maxdev,
-								GFP_KERNEL);
+	slip_devs = kzalloc(array_size(slip_maxdev, sizeof(struct net_device *)),
+			    GFP_KERNEL);
 	if (!slip_devs)
 		return -ENOMEM;
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index acbe84967834..4319acb3a7d8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -280,7 +280,7 @@ static int __team_options_register(struct team *team,
 	struct team_option **dst_opts;
 	int err;
 
-	dst_opts = kzalloc(sizeof(struct team_option *) * option_count,
+	dst_opts = kzalloc(array_size(option_count, sizeof(struct team_option *)),
 			   GFP_KERNEL);
 	if (!dst_opts)
 		return -ENOMEM;
@@ -791,7 +791,8 @@ static int team_queue_override_init(struct team *team)
 
 	if (!queue_cnt)
 		return 0;
-	listarr = kmalloc(sizeof(struct list_head) * queue_cnt, GFP_KERNEL);
+	listarr = kmalloc(array_size(queue_cnt, sizeof(struct list_head)),
+			  GFP_KERNEL);
 	if (!listarr)
 		return -ENOMEM;
 	team->qom_lists = listarr;
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 309b88acd3d0..8817e8ff2cd7 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1661,7 +1661,8 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	}
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
-		u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);
+		u32 *filter_mask = kzalloc(array_size(32, sizeof(u32)),
+					   GFP_KERNEL);
 		u32 command[2];
 		u32 offset[2];
 		u32 crc[4];
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 770422e953f7..fb627b35ae1b 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2480,17 +2480,18 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
 
 	/* Allocate space for find_vqs parameters */
-	vqs = kzalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
+	vqs = kzalloc(array_size(total_vqs, sizeof(*vqs)), GFP_KERNEL);
 	if (!vqs)
 		goto err_vq;
-	callbacks = kmalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
+	callbacks = kmalloc(array_size(total_vqs, sizeof(*callbacks)),
+			    GFP_KERNEL);
 	if (!callbacks)
 		goto err_callback;
-	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
+	names = kmalloc(array_size(total_vqs, sizeof(*names)), GFP_KERNEL);
 	if (!names)
 		goto err_names;
 	if (!vi->big_packets || vi->mergeable_rx_bufs) {
-		ctx = kzalloc(total_vqs * sizeof(*ctx), GFP_KERNEL);
+		ctx = kzalloc(array_size(total_vqs, sizeof(*ctx)), GFP_KERNEL);
 		if (!ctx)
 			goto err_ctx;
 	} else {
diff --git a/drivers/net/wireless/ath/ath10k/wmi-tlv.c b/drivers/net/wireless/ath/ath10k/wmi-tlv.c
index 9d1b0a459069..a6ccb99a7913 100644
--- a/drivers/net/wireless/ath/ath10k/wmi-tlv.c
+++ b/drivers/net/wireless/ath/ath10k/wmi-tlv.c
@@ -155,7 +155,7 @@ ath10k_wmi_tlv_parse_alloc(struct ath10k *ar, const void *ptr,
 	const void **tb;
 	int ret;
 
-	tb = kzalloc(sizeof(*tb) * WMI_TLV_TAG_MAX, gfp);
+	tb = kzalloc(array_size(WMI_TLV_TAG_MAX, sizeof(*tb)), gfp);
 	if (!tb)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 2ba8cf3f38af..81bb05d979f4 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -1041,7 +1041,8 @@ static int ath6kl_cfg80211_scan(struct wiphy *wiphy,
 
 		n_channels = request->n_channels;
 
-		channels = kzalloc(n_channels * sizeof(u16), GFP_KERNEL);
+		channels = kzalloc(array_size(n_channels, sizeof(u16)),
+				   GFP_KERNEL);
 		if (channels == NULL) {
 			ath6kl_warn("failed to set scan channels, scan all channels");
 			n_channels = 0;
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 6b37036b2d36..ab77ed1702be 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -127,13 +127,13 @@ void ath9k_hw_read_array(struct ath_hw *ah, u32 array[][2], int size)
 	u32 *tmp_reg_list, *tmp_data;
 	int i;
 
-	tmp_reg_list = kmalloc(size * sizeof(u32), GFP_KERNEL);
+	tmp_reg_list = kmalloc(array_size(size, sizeof(u32)), GFP_KERNEL);
 	if (!tmp_reg_list) {
 		dev_err(ah->dev, "%s: tmp_reg_list: alloc filed\n", __func__);
 		return;
 	}
 
-	tmp_data = kmalloc(size * sizeof(u32), GFP_KERNEL);
+	tmp_data = kmalloc(array_size(size, sizeof(u32)), GFP_KERNEL);
 	if (!tmp_data) {
 		dev_err(ah->dev, "%s tmp_data: alloc filed\n", __func__);
 		goto error_tmp_data;
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 29e93c953d93..04cfdd6bef55 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1958,7 +1958,8 @@ static int carl9170_parse_eeprom(struct ar9170 *ar)
 	if (!bands)
 		return -EINVAL;
 
-	ar->survey = kzalloc(sizeof(struct survey_info) * chans, GFP_KERNEL);
+	ar->survey = kzalloc(array_size(chans, sizeof(struct survey_info)),
+			     GFP_KERNEL);
 	if (!ar->survey)
 		return -ENOMEM;
 	ar->num_channels = chans;
diff --git a/drivers/net/wireless/broadcom/b43/phy_n.c b/drivers/net/wireless/broadcom/b43/phy_n.c
index f2a2f41e3c96..2f6fb4b00718 100644
--- a/drivers/net/wireless/broadcom/b43/phy_n.c
+++ b/drivers/net/wireless/broadcom/b43/phy_n.c
@@ -1518,7 +1518,7 @@ static int b43_nphy_load_samples(struct b43_wldev *dev,
 	u16 i;
 	u32 *data;
 
-	data = kzalloc(len * sizeof(u32), GFP_KERNEL);
+	data = kzalloc(array_size(len, sizeof(u32)), GFP_KERNEL);
 	if (!data) {
 		b43err(dev->wl, "allocation for samples loading failed\n");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/broadcom/b43legacy/main.c b/drivers/net/wireless/broadcom/b43legacy/main.c
index f1e3dad57629..111b9266ce46 100644
--- a/drivers/net/wireless/broadcom/b43legacy/main.c
+++ b/drivers/net/wireless/broadcom/b43legacy/main.c
@@ -3300,8 +3300,7 @@ static int b43legacy_wireless_core_init(struct b43legacy_wldev *dev)
 
 	if ((phy->type == B43legacy_PHYTYPE_B) ||
 	    (phy->type == B43legacy_PHYTYPE_G)) {
-		phy->_lo_pairs = kzalloc(sizeof(struct b43legacy_lopair)
-					 * B43legacy_LO_COUNT,
+		phy->_lo_pairs = kzalloc(array_size(B43legacy_LO_COUNT, sizeof(struct b43legacy_lopair)),
 					 GFP_KERNEL);
 		if (!phy->_lo_pairs)
 			return -ENOMEM;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
index bcef208a81a5..37431ba2a904 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
@@ -1058,7 +1058,7 @@ static s32 brcmf_p2p_act_frm_search(struct brcmf_p2p_info *p2p, u16 channel)
 		channel_cnt = AF_PEER_SEARCH_CNT;
 	else
 		channel_cnt = SOCIAL_CHAN_CNT;
-	default_chan_list = kzalloc(channel_cnt * sizeof(*default_chan_list),
+	default_chan_list = kzalloc(array_size(channel_cnt, sizeof(*default_chan_list)),
 				    GFP_KERNEL);
 	if (default_chan_list == NULL) {
 		brcmf_err("channel list allocation failed\n");
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
index 0a14942b8216..e79ce5a11d5b 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c
@@ -507,7 +507,8 @@ brcms_c_attach_malloc(uint unit, uint *err, uint devid)
 	wlc->hw->wlc = wlc;
 
 	wlc->hw->bandstate[0] =
-		kzalloc(sizeof(struct brcms_hw_band) * MAXBANDS, GFP_ATOMIC);
+		kzalloc(array_size(MAXBANDS, sizeof(struct brcms_hw_band)),
+			GFP_ATOMIC);
 	if (wlc->hw->bandstate[0] == NULL) {
 		*err = 1006;
 		goto fail;
@@ -521,7 +522,8 @@ brcms_c_attach_malloc(uint unit, uint *err, uint devid)
 	}
 
 	wlc->modulecb =
-		kzalloc(sizeof(struct modulecb) * BRCMS_MAXMODULES, GFP_ATOMIC);
+		kzalloc(array_size(BRCMS_MAXMODULES, sizeof(struct modulecb)),
+			GFP_ATOMIC);
 	if (wlc->modulecb == NULL) {
 		*err = 1009;
 		goto fail;
@@ -553,7 +555,8 @@ brcms_c_attach_malloc(uint unit, uint *err, uint devid)
 	}
 
 	wlc->bandstate[0] =
-		kzalloc(sizeof(struct brcms_band)*MAXBANDS, GFP_ATOMIC);
+		kzalloc(array_size(MAXBANDS, sizeof(struct brcms_band)),
+			GFP_ATOMIC);
 	if (wlc->bandstate[0] == NULL) {
 		*err = 1025;
 		goto fail;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.c
index 93d4cde0eb31..44e5c305e2b8 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_lcn.c
@@ -1387,7 +1387,7 @@ wlc_lcnphy_rx_iq_cal(struct brcms_phy *pi,
 	s16 *ptr;
 	struct brcms_phy_lcnphy *pi_lcn = pi->u.pi_lcnphy;
 
-	ptr = kmalloc(sizeof(s16) * 131, GFP_ATOMIC);
+	ptr = kmalloc(array_size(131, sizeof(s16)), GFP_ATOMIC);
 	if (NULL == ptr)
 		return false;
 	if (module == 2) {
@@ -2670,7 +2670,7 @@ wlc_lcnphy_tx_iqlo_cal(struct brcms_phy *pi,
 	u16 *values_to_save;
 	struct brcms_phy_lcnphy *pi_lcn = pi->u.pi_lcnphy;
 
-	values_to_save = kmalloc(sizeof(u16) * 20, GFP_ATOMIC);
+	values_to_save = kmalloc(array_size(20, sizeof(u16)), GFP_ATOMIC);
 	if (NULL == values_to_save)
 		return;
 
@@ -3683,11 +3683,11 @@ wlc_lcnphy_a1(struct brcms_phy *pi, int cal_type, int num_levels,
 	u16 *phy_c32;
 	phy_c21 = 0;
 	phy_c10 = phy_c13 = phy_c14 = phy_c8 = 0;
-	ptr = kmalloc(sizeof(s16) * 131, GFP_ATOMIC);
+	ptr = kmalloc(array_size(131, sizeof(s16)), GFP_ATOMIC);
 	if (NULL == ptr)
 		return;
 
-	phy_c32 = kmalloc(sizeof(u16) * 20, GFP_ATOMIC);
+	phy_c32 = kmalloc(array_size(20, sizeof(u16)), GFP_ATOMIC);
 	if (NULL == phy_c32) {
 		kfree(ptr);
 		return;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
index 7e01981bc5c8..88eb34244caa 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
@@ -23032,7 +23032,7 @@ wlc_phy_loadsampletable_nphy(struct brcms_phy *pi, struct cordic_iq *tone_buf,
 	u16 t;
 	u32 *data_buf = NULL;
 
-	data_buf = kmalloc(sizeof(u32) * num_samps, GFP_ATOMIC);
+	data_buf = kmalloc(array_size(num_samps, sizeof(u32)), GFP_ATOMIC);
 	if (data_buf == NULL)
 		return;
 
@@ -23074,7 +23074,8 @@ wlc_phy_gen_load_samples_nphy(struct brcms_phy *pi, u32 f_kHz, u16 max_val,
 		tbl_len = (phy_bw << 1);
 	}
 
-	tone_buf = kmalloc(sizeof(struct cordic_iq) * tbl_len, GFP_ATOMIC);
+	tone_buf = kmalloc(array_size(tbl_len, sizeof(struct cordic_iq)),
+			   GFP_ATOMIC);
 	if (tone_buf == NULL)
 		return 0;
 
diff --git a/drivers/net/wireless/cisco/airo.c b/drivers/net/wireless/cisco/airo.c
index ce0fbf83285f..ce0c4c987e53 100644
--- a/drivers/net/wireless/cisco/airo.c
+++ b/drivers/net/wireless/cisco/airo.c
@@ -7127,7 +7127,7 @@ static int airo_get_aplist(struct net_device *dev,
 	int i;
 	int loseSync = capable(CAP_NET_ADMIN) ? 1: -1;
 
-	qual = kmalloc(IW_MAX_AP * sizeof(*qual), GFP_KERNEL);
+	qual = kmalloc(array_size(IW_MAX_AP, sizeof(*qual)), GFP_KERNEL);
 	if (!qual)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index 236b52423506..920ecaf4152c 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -3445,7 +3445,7 @@ static int ipw2100_msg_allocate(struct ipw2100_priv *priv)
 	dma_addr_t p;
 
 	priv->msg_buffers =
-	    kmalloc(IPW_COMMAND_POOL_SIZE * sizeof(struct ipw2100_tx_packet),
+	    kmalloc(array_size(IPW_COMMAND_POOL_SIZE, sizeof(struct ipw2100_tx_packet)),
 		    GFP_KERNEL);
 	if (!priv->msg_buffers)
 		return -ENOMEM;
@@ -4587,8 +4587,7 @@ static int ipw2100_rx_allocate(struct ipw2100_priv *priv)
 	/*
 	 * allocate packets
 	 */
-	priv->rx_buffers = kmalloc(RX_QUEUE_LENGTH *
-				   sizeof(struct ipw2100_rx_packet),
+	priv->rx_buffers = kmalloc(array_size(RX_QUEUE_LENGTH, sizeof(struct ipw2100_rx_packet)),
 				   GFP_KERNEL);
 	if (!priv->rx_buffers) {
 		IPW_DEBUG_INFO("can't allocate rx packet buffer table\n");
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index 87a5e414c2f7..27ff4b3ab683 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -3208,13 +3208,13 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 
 	IPW_DEBUG_TRACE("<< :\n");
 
-	virts = kmalloc(sizeof(void *) * CB_NUMBER_OF_ELEMENTS_SMALL,
+	virts = kmalloc(array_size(CB_NUMBER_OF_ELEMENTS_SMALL, sizeof(void *)),
 			GFP_KERNEL);
 	if (!virts)
 		return -ENOMEM;
 
-	phys = kmalloc(sizeof(dma_addr_t) * CB_NUMBER_OF_ELEMENTS_SMALL,
-			GFP_KERNEL);
+	phys = kmalloc(array_size(CB_NUMBER_OF_ELEMENTS_SMALL, sizeof(dma_addr_t)),
+		       GFP_KERNEL);
 	if (!phys) {
 		kfree(virts);
 		return -ENOMEM;
@@ -3782,7 +3782,7 @@ static int ipw_queue_tx_init(struct ipw_priv *priv,
 {
 	struct pci_dev *dev = priv->pci_dev;
 
-	q->txb = kmalloc(sizeof(q->txb[0]) * count, GFP_KERNEL);
+	q->txb = kmalloc(array_size(count, sizeof(q->txb[0])), GFP_KERNEL);
 	if (!q->txb) {
 		IPW_ERROR("vmalloc for auxiliary BD structures failed\n");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/intel/iwlegacy/common.c b/drivers/net/wireless/intel/iwlegacy/common.c
index 063e19ced7c8..a5d5748f5d30 100644
--- a/drivers/net/wireless/intel/iwlegacy/common.c
+++ b/drivers/net/wireless/intel/iwlegacy/common.c
@@ -3041,9 +3041,11 @@ il_tx_queue_init(struct il_priv *il, u32 txq_id)
 	}
 
 	txq->meta =
-	    kzalloc(sizeof(struct il_cmd_meta) * actual_slots, GFP_KERNEL);
+	    kzalloc(array_size(actual_slots, sizeof(struct il_cmd_meta)),
+		    GFP_KERNEL);
 	txq->cmd =
-	    kzalloc(sizeof(struct il_device_cmd *) * actual_slots, GFP_KERNEL);
+	    kzalloc(array_size(actual_slots, sizeof(struct il_device_cmd *)),
+		    GFP_KERNEL);
 
 	if (!txq->meta || !txq->cmd)
 		goto out_free_arrays;
diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/scan.c b/drivers/net/wireless/intel/iwlwifi/mvm/scan.c
index b31f0ffbbbf0..8c43feeef85d 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/scan.c
@@ -533,7 +533,8 @@ iwl_mvm_config_sched_scan_profiles(struct iwl_mvm *mvm,
 	else
 		blacklist_len = IWL_SCAN_MAX_BLACKLIST_LEN;
 
-	blacklist = kzalloc(sizeof(*blacklist) * blacklist_len, GFP_KERNEL);
+	blacklist = kzalloc(array_size(blacklist_len, sizeof(*blacklist)),
+			    GFP_KERNEL);
 	if (!blacklist)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/intersil/hostap/hostap_info.c b/drivers/net/wireless/intersil/hostap/hostap_info.c
index de8a099a9386..01301da80674 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_info.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_info.c
@@ -271,7 +271,7 @@ static void prism2_info_scanresults(local_info_t *local, unsigned char *buf,
 	left -= 4;
 
 	new_count = left / sizeof(struct hfa384x_scan_result);
-	results = kmalloc(new_count * sizeof(struct hfa384x_hostscan_result),
+	results = kmalloc(array_size(new_count, sizeof(struct hfa384x_hostscan_result)),
 			  GFP_ATOMIC);
 	if (results == NULL)
 		return;
diff --git a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
index c1bc0a6ef300..c9ce414ee84f 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
@@ -513,8 +513,10 @@ static int prism2_ioctl_giwaplist(struct net_device *dev,
 		return -EOPNOTSUPP;
 	}
 
-	addr = kmalloc(sizeof(struct sockaddr) * IW_MAX_AP, GFP_KERNEL);
-	qual = kmalloc(sizeof(struct iw_quality) * IW_MAX_AP, GFP_KERNEL);
+	addr = kmalloc(array_size(IW_MAX_AP, sizeof(struct sockaddr)),
+		       GFP_KERNEL);
+	qual = kmalloc(array_size(IW_MAX_AP, sizeof(struct iw_quality)),
+		       GFP_KERNEL);
 	if (addr == NULL || qual == NULL) {
 		kfree(addr);
 		kfree(qual);
diff --git a/drivers/net/wireless/intersil/p54/eeprom.c b/drivers/net/wireless/intersil/p54/eeprom.c
index d4c73d39336f..b792fe1eda66 100644
--- a/drivers/net/wireless/intersil/p54/eeprom.c
+++ b/drivers/net/wireless/intersil/p54/eeprom.c
@@ -344,7 +344,7 @@ static int p54_generate_channel_lists(struct ieee80211_hw *dev)
 		goto free;
 	}
 	priv->chan_num = max_channel_num;
-	priv->survey = kzalloc(sizeof(struct survey_info) * max_channel_num,
+	priv->survey = kzalloc(array_size(max_channel_num, sizeof(struct survey_info)),
 			       GFP_KERNEL);
 	if (!priv->survey) {
 		ret = -ENOMEM;
@@ -352,8 +352,8 @@ static int p54_generate_channel_lists(struct ieee80211_hw *dev)
 	}
 
 	list->max_entries = max_channel_num;
-	list->channels = kzalloc(sizeof(struct p54_channel_entry) *
-				 max_channel_num, GFP_KERNEL);
+	list->channels = kzalloc(array_size(max_channel_num, sizeof(struct p54_channel_entry)),
+				 GFP_KERNEL);
 	if (!list->channels) {
 		ret = -ENOMEM;
 		goto free;
diff --git a/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c b/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
index 1edcddaf7b4b..3c5974ce5809 100644
--- a/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
@@ -399,8 +399,8 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_private *priv, u8 *ta,
 
 	new_node->win_size = win_size;
 
-	new_node->rx_reorder_ptr = kzalloc(sizeof(void *) * win_size,
-					GFP_KERNEL);
+	new_node->rx_reorder_ptr = kzalloc(array_size(win_size, sizeof(void *)),
+					   GFP_KERNEL);
 	if (!new_node->rx_reorder_ptr) {
 		kfree((u8 *) new_node);
 		mwifiex_dbg(priv->adapter, ERROR,
diff --git a/drivers/net/wireless/realtek/rtlwifi/usb.c b/drivers/net/wireless/realtek/rtlwifi/usb.c
index ce3103bb8ebb..db46f24edb21 100644
--- a/drivers/net/wireless/realtek/rtlwifi/usb.c
+++ b/drivers/net/wireless/realtek/rtlwifi/usb.c
@@ -1048,7 +1048,7 @@ int rtl_usb_probe(struct usb_interface *intf,
 	}
 	rtlpriv = hw->priv;
 	rtlpriv->hw = hw;
-	rtlpriv->usb_data = kzalloc(RTL_USB_MAX_RX_COUNT * sizeof(u32),
+	rtlpriv->usb_data = kzalloc(array_size(RTL_USB_MAX_RX_COUNT, sizeof(u32)),
 				    GFP_KERNEL);
 	if (!rtlpriv->usb_data)
 		return -ENOMEM;
diff --git a/drivers/net/wireless/st/cw1200/queue.c b/drivers/net/wireless/st/cw1200/queue.c
index 5153d2cfd991..8b8453fac571 100644
--- a/drivers/net/wireless/st/cw1200/queue.c
+++ b/drivers/net/wireless/st/cw1200/queue.c
@@ -154,7 +154,7 @@ int cw1200_queue_stats_init(struct cw1200_queue_stats *stats,
 	spin_lock_init(&stats->lock);
 	init_waitqueue_head(&stats->wait_link_id_empty);
 
-	stats->link_map_cache = kzalloc(sizeof(int) * map_capacity,
+	stats->link_map_cache = kzalloc(array_size(map_capacity, sizeof(int)),
 					GFP_KERNEL);
 	if (!stats->link_map_cache)
 		return -ENOMEM;
@@ -181,8 +181,8 @@ int cw1200_queue_init(struct cw1200_queue *queue,
 	spin_lock_init(&queue->lock);
 	timer_setup(&queue->gc, cw1200_queue_gc, 0);
 
-	queue->pool = kzalloc(sizeof(struct cw1200_queue_item) * capacity,
-			GFP_KERNEL);
+	queue->pool = kzalloc(array_size(capacity, sizeof(struct cw1200_queue_item)),
+			      GFP_KERNEL);
 	if (!queue->pool)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/zydas/zd1211rw/zd_mac.c b/drivers/net/wireless/zydas/zd1211rw/zd_mac.c
index b01b44a5d16e..aefa19089bc9 100644
--- a/drivers/net/wireless/zydas/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zydas/zd1211rw/zd_mac.c
@@ -732,7 +732,8 @@ static int zd_mac_config_beacon(struct ieee80211_hw *hw, struct sk_buff *beacon,
 
 	/* Alloc memory for full beacon write at once. */
 	num_cmds = 1 + zd_chip_is_zd1211b(&mac->chip) + full_len;
-	ioreqs = kmalloc(num_cmds * sizeof(struct zd_ioreq32), GFP_KERNEL);
+	ioreqs = kmalloc(array_size(num_cmds, sizeof(struct zd_ioreq32)),
+			 GFP_KERNEL);
 	if (!ioreqs) {
 		r = -ENOMEM;
 		goto out_nofree;
diff --git a/drivers/nvmem/rockchip-efuse.c b/drivers/nvmem/rockchip-efuse.c
index b3b0b648be62..146de9489339 100644
--- a/drivers/nvmem/rockchip-efuse.c
+++ b/drivers/nvmem/rockchip-efuse.c
@@ -122,7 +122,8 @@ static int rockchip_rk3328_efuse_read(void *context, unsigned int offset,
 	addr_offset = offset % RK3399_NBYTES;
 	addr_len = addr_end - addr_start;
 
-	buf = kzalloc(sizeof(*buf) * addr_len * RK3399_NBYTES, GFP_KERNEL);
+	buf = kzalloc(array3_size(addr_len, RK3399_NBYTES, sizeof(*buf)),
+		      GFP_KERNEL);
 	if (!buf) {
 		ret = -ENOMEM;
 		goto nomem;
@@ -174,7 +175,8 @@ static int rockchip_rk3399_efuse_read(void *context, unsigned int offset,
 	addr_offset = offset % RK3399_NBYTES;
 	addr_len = addr_end - addr_start;
 
-	buf = kzalloc(sizeof(*buf) * addr_len * RK3399_NBYTES, GFP_KERNEL);
+	buf = kzalloc(array3_size(addr_len, RK3399_NBYTES, sizeof(*buf)),
+		      GFP_KERNEL);
 	if (!buf) {
 		clk_disable_unprepare(efuse->clk);
 		return -ENOMEM;
diff --git a/drivers/of/unittest.c b/drivers/of/unittest.c
index 6bb37c18292a..bda3e153cb30 100644
--- a/drivers/of/unittest.c
+++ b/drivers/of/unittest.c
@@ -156,7 +156,7 @@ static void __init of_unittest_dynamic(void)
 	}
 
 	/* Array of 4 properties for the purpose of testing */
-	prop = kzalloc(sizeof(*prop) * 4, GFP_KERNEL);
+	prop = kzalloc(array_size(4, sizeof(*prop)), GFP_KERNEL);
 	if (!prop) {
 		unittest(0, "kzalloc() failed\n");
 		return;
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 30250631efe7..82d241f5bf3b 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -501,7 +501,7 @@ static int populate_msi_sysfs(struct pci_dev *pdev)
 	msi_irq_group->name = "msi_irqs";
 	msi_irq_group->attrs = msi_attrs;
 
-	msi_irq_groups = kzalloc(sizeof(void *) * 2, GFP_KERNEL);
+	msi_irq_groups = kzalloc(array_size(2, sizeof(void *)), GFP_KERNEL);
 	if (!msi_irq_groups)
 		goto error_irq_group;
 	msi_irq_groups[0] = msi_irq_group;
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index 366d93af051d..d2e06e9786e0 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -1073,7 +1073,7 @@ void pci_create_legacy_files(struct pci_bus *b)
 {
 	int error;
 
-	b->legacy_io = kzalloc(sizeof(struct bin_attribute) * 2,
+	b->legacy_io = kzalloc(array_size(2, sizeof(struct bin_attribute)),
 			       GFP_ATOMIC);
 	if (!b->legacy_io)
 		goto kzalloc_err;
diff --git a/drivers/pcmcia/cistpl.c b/drivers/pcmcia/cistpl.c
index 102646fedb56..86fb0aff8aa9 100644
--- a/drivers/pcmcia/cistpl.c
+++ b/drivers/pcmcia/cistpl.c
@@ -1481,11 +1481,11 @@ static ssize_t pccard_extract_cis(struct pcmcia_socket *s, char *buf,
 	u_char *tuplebuffer;
 	u_char *tempbuffer;
 
-	tuplebuffer = kmalloc(sizeof(u_char) * 256, GFP_KERNEL);
+	tuplebuffer = kmalloc(array_size(256, sizeof(u_char)), GFP_KERNEL);
 	if (!tuplebuffer)
 		return -ENOMEM;
 
-	tempbuffer = kmalloc(sizeof(u_char) * 258, GFP_KERNEL);
+	tempbuffer = kmalloc(array_size(258, sizeof(u_char)), GFP_KERNEL);
 	if (!tempbuffer) {
 		ret = -ENOMEM;
 		goto free_tuple;
diff --git a/drivers/pcmcia/pd6729.c b/drivers/pcmcia/pd6729.c
index 959ae3e65ef8..df5707d2e02b 100644
--- a/drivers/pcmcia/pd6729.c
+++ b/drivers/pcmcia/pd6729.c
@@ -628,7 +628,7 @@ static int pd6729_pci_probe(struct pci_dev *dev,
 	char configbyte;
 	struct pd6729_socket *socket;
 
-	socket = kzalloc(sizeof(struct pd6729_socket) * MAX_SOCKETS,
+	socket = kzalloc(array_size(MAX_SOCKETS, sizeof(struct pd6729_socket)),
 			 GFP_KERNEL);
 	if (!socket) {
 		dev_warn(&dev->dev, "failed to kzalloc socket.\n");
diff --git a/drivers/pinctrl/freescale/pinctrl-imx.c b/drivers/pinctrl/freescale/pinctrl-imx.c
index 24aaddd760a0..8734e5f05b46 100644
--- a/drivers/pinctrl/freescale/pinctrl-imx.c
+++ b/drivers/pinctrl/freescale/pinctrl-imx.c
@@ -86,7 +86,8 @@ static int imx_dt_node_to_map(struct pinctrl_dev *pctldev,
 			map_num++;
 	}
 
-	new_map = kmalloc(sizeof(struct pinctrl_map) * map_num, GFP_KERNEL);
+	new_map = kmalloc(array_size(map_num, sizeof(struct pinctrl_map)),
+			  GFP_KERNEL);
 	if (!new_map)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/freescale/pinctrl-imx1-core.c b/drivers/pinctrl/freescale/pinctrl-imx1-core.c
index a4e9f430d452..4eedd874bd02 100644
--- a/drivers/pinctrl/freescale/pinctrl-imx1-core.c
+++ b/drivers/pinctrl/freescale/pinctrl-imx1-core.c
@@ -246,7 +246,8 @@ static int imx1_dt_node_to_map(struct pinctrl_dev *pctldev,
 	for (i = 0; i < grp->npins; i++)
 		map_num++;
 
-	new_map = kmalloc(sizeof(struct pinctrl_map) * map_num, GFP_KERNEL);
+	new_map = kmalloc(array_size(map_num, sizeof(struct pinctrl_map)),
+			  GFP_KERNEL);
 	if (!new_map)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/freescale/pinctrl-mxs.c b/drivers/pinctrl/freescale/pinctrl-mxs.c
index 6852010a6d70..ea3bb26b0c3e 100644
--- a/drivers/pinctrl/freescale/pinctrl-mxs.c
+++ b/drivers/pinctrl/freescale/pinctrl-mxs.c
@@ -96,7 +96,7 @@ static int mxs_dt_node_to_map(struct pinctrl_dev *pctldev,
 	if (!purecfg && config)
 		new_num = 2;
 
-	new_map = kzalloc(sizeof(*new_map) * new_num, GFP_KERNEL);
+	new_map = kzalloc(array_size(new_num, sizeof(*new_map)), GFP_KERNEL);
 	if (!new_map)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/samsung/pinctrl-exynos5440.c b/drivers/pinctrl/samsung/pinctrl-exynos5440.c
index 3d8d5e812839..832ba81e192e 100644
--- a/drivers/pinctrl/samsung/pinctrl-exynos5440.c
+++ b/drivers/pinctrl/samsung/pinctrl-exynos5440.c
@@ -201,7 +201,7 @@ static int exynos5440_dt_node_to_map(struct pinctrl_dev *pctldev,
 	}
 
 	/* Allocate memory for pin-map entries */
-	map = kzalloc(sizeof(*map) * map_cnt, GFP_KERNEL);
+	map = kzalloc(array_size(map_cnt, sizeof(*map)), GFP_KERNEL);
 	if (!map)
 		return -ENOMEM;
 	*nmaps = 0;
@@ -222,7 +222,7 @@ static int exynos5440_dt_node_to_map(struct pinctrl_dev *pctldev,
 		goto skip_cfgs;
 
 	/* Allocate memory for config entries */
-	cfg = kzalloc(sizeof(*cfg) * cfg_cnt, GFP_KERNEL);
+	cfg = kzalloc(array_size(cfg_cnt, sizeof(*cfg)), GFP_KERNEL);
 	if (!cfg)
 		goto free_gname;
 
diff --git a/drivers/pinctrl/sirf/pinctrl-sirf.c b/drivers/pinctrl/sirf/pinctrl-sirf.c
index ca2347d0d579..b45d16276c05 100644
--- a/drivers/pinctrl/sirf/pinctrl-sirf.c
+++ b/drivers/pinctrl/sirf/pinctrl-sirf.c
@@ -108,7 +108,7 @@ static int sirfsoc_dt_node_to_map(struct pinctrl_dev *pctldev,
 		return -ENODEV;
 	}
 
-	*map = kzalloc(sizeof(**map) * count, GFP_KERNEL);
+	*map = kzalloc(array_size(count, sizeof(**map)), GFP_KERNEL);
 	if (!*map)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/spear/pinctrl-spear.c b/drivers/pinctrl/spear/pinctrl-spear.c
index efe79d3f7659..c108914c0888 100644
--- a/drivers/pinctrl/spear/pinctrl-spear.c
+++ b/drivers/pinctrl/spear/pinctrl-spear.c
@@ -172,7 +172,7 @@ static int spear_pinctrl_dt_node_to_map(struct pinctrl_dev *pctldev,
 		return -ENODEV;
 	}
 
-	*map = kzalloc(sizeof(**map) * count, GFP_KERNEL);
+	*map = kzalloc(array_size(count, sizeof(**map)), GFP_KERNEL);
 	if (!*map)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/sunxi/pinctrl-sunxi.c b/drivers/pinctrl/sunxi/pinctrl-sunxi.c
index 020d6d84639c..14ccf7722d65 100644
--- a/drivers/pinctrl/sunxi/pinctrl-sunxi.c
+++ b/drivers/pinctrl/sunxi/pinctrl-sunxi.c
@@ -277,7 +277,8 @@ static unsigned long *sunxi_pctrl_build_pin_config(struct device_node *node,
 	if (!configlen)
 		return NULL;
 
-	pinconfig = kzalloc(configlen * sizeof(*pinconfig), GFP_KERNEL);
+	pinconfig = kzalloc(array_size(configlen, sizeof(*pinconfig)),
+			    GFP_KERNEL);
 	if (!pinconfig)
 		return ERR_PTR(-ENOMEM);
 
@@ -352,7 +353,8 @@ static int sunxi_pctrl_dt_node_to_map(struct pinctrl_dev *pctldev,
 	 * any configuration.
 	 */
 	nmaps = npins * 2;
-	*map = kmalloc(nmaps * sizeof(struct pinctrl_map), GFP_KERNEL);
+	*map = kmalloc(array_size(nmaps, sizeof(struct pinctrl_map)),
+		       GFP_KERNEL);
 	if (!*map)
 		return -ENOMEM;
 
diff --git a/drivers/platform/x86/intel_ips.c b/drivers/platform/x86/intel_ips.c
index a0c95853fd3f..98f7264c9092 100644
--- a/drivers/platform/x86/intel_ips.c
+++ b/drivers/platform/x86/intel_ips.c
@@ -964,12 +964,18 @@ static int ips_monitor(void *data)
 	u16 *mcp_samples, *ctv1_samples, *ctv2_samples, *mch_samples;
 	u8 cur_seqno, last_seqno;
 
-	mcp_samples = kzalloc(sizeof(u16) * IPS_SAMPLE_COUNT, GFP_KERNEL);
-	ctv1_samples = kzalloc(sizeof(u16) * IPS_SAMPLE_COUNT, GFP_KERNEL);
-	ctv2_samples = kzalloc(sizeof(u16) * IPS_SAMPLE_COUNT, GFP_KERNEL);
-	mch_samples = kzalloc(sizeof(u16) * IPS_SAMPLE_COUNT, GFP_KERNEL);
-	cpu_samples = kzalloc(sizeof(u32) * IPS_SAMPLE_COUNT, GFP_KERNEL);
-	mchp_samples = kzalloc(sizeof(u32) * IPS_SAMPLE_COUNT, GFP_KERNEL);
+	mcp_samples = kzalloc(array_size(IPS_SAMPLE_COUNT, sizeof(u16)),
+			      GFP_KERNEL);
+	ctv1_samples = kzalloc(array_size(IPS_SAMPLE_COUNT, sizeof(u16)),
+			       GFP_KERNEL);
+	ctv2_samples = kzalloc(array_size(IPS_SAMPLE_COUNT, sizeof(u16)),
+			       GFP_KERNEL);
+	mch_samples = kzalloc(array_size(IPS_SAMPLE_COUNT, sizeof(u16)),
+			      GFP_KERNEL);
+	cpu_samples = kzalloc(array_size(IPS_SAMPLE_COUNT, sizeof(u32)),
+			      GFP_KERNEL);
+	mchp_samples = kzalloc(array_size(IPS_SAMPLE_COUNT, sizeof(u32)),
+			       GFP_KERNEL);
 	if (!mcp_samples || !ctv1_samples || !ctv2_samples || !mch_samples ||
 			!cpu_samples || !mchp_samples) {
 		dev_err(ips->dev,
diff --git a/drivers/platform/x86/thinkpad_acpi.c b/drivers/platform/x86/thinkpad_acpi.c
index da1ca4856ea1..0e109e5e2f73 100644
--- a/drivers/platform/x86/thinkpad_acpi.c
+++ b/drivers/platform/x86/thinkpad_acpi.c
@@ -6006,7 +6006,7 @@ static int __init led_init(struct ibm_init_struct *iibm)
 	if (led_supported == TPACPI_LED_NONE)
 		return 1;
 
-	tpacpi_leds = kzalloc(sizeof(*tpacpi_leds) * TPACPI_LED_NUMLEDS,
+	tpacpi_leds = kzalloc(array_size(TPACPI_LED_NUMLEDS, sizeof(*tpacpi_leds)),
 			      GFP_KERNEL);
 	if (!tpacpi_leds) {
 		pr_err("Out of memory for LED data\n");
diff --git a/drivers/power/supply/wm97xx_battery.c b/drivers/power/supply/wm97xx_battery.c
index bd4f66651513..231d8b059bc4 100644
--- a/drivers/power/supply/wm97xx_battery.c
+++ b/drivers/power/supply/wm97xx_battery.c
@@ -201,7 +201,7 @@ static int wm97xx_bat_probe(struct platform_device *dev)
 	if (pdata->min_voltage >= 0)
 		props++;	/* POWER_SUPPLY_PROP_VOLTAGE_MIN */
 
-	prop = kzalloc(props * sizeof(*prop), GFP_KERNEL);
+	prop = kzalloc(array_size(props, sizeof(*prop)), GFP_KERNEL);
 	if (!prop) {
 		ret = -ENOMEM;
 		goto err3;
diff --git a/drivers/power/supply/z2_battery.c b/drivers/power/supply/z2_battery.c
index 8a43b49cfd35..4e8f9ff7b6d1 100644
--- a/drivers/power/supply/z2_battery.c
+++ b/drivers/power/supply/z2_battery.c
@@ -146,7 +146,7 @@ static int z2_batt_ps_init(struct z2_charger *charger, int props)
 	if (info->min_voltage >= 0)
 		props++;	/* POWER_SUPPLY_PROP_VOLTAGE_MIN */
 
-	prop = kzalloc(props * sizeof(*prop), GFP_KERNEL);
+	prop = kzalloc(array_size(props, sizeof(*prop)), GFP_KERNEL);
 	if (!prop)
 		return -ENOMEM;
 
diff --git a/drivers/powercap/powercap_sys.c b/drivers/powercap/powercap_sys.c
index 64b2b2501a79..0a988158a563 100644
--- a/drivers/powercap/powercap_sys.c
+++ b/drivers/powercap/powercap_sys.c
@@ -545,15 +545,15 @@ struct powercap_zone *powercap_register_zone(
 	dev_set_name(&power_zone->dev, "%s:%x",
 					dev_name(power_zone->dev.parent),
 					power_zone->id);
-	power_zone->constraints = kzalloc(sizeof(*power_zone->constraints) *
-					 nr_constraints, GFP_KERNEL);
+	power_zone->constraints = kzalloc(array_size(nr_constraints, sizeof(*power_zone->constraints)),
+					  GFP_KERNEL);
 	if (!power_zone->constraints)
 		goto err_const_alloc;
 
 	nr_attrs = nr_constraints * POWERCAP_CONSTRAINTS_ATTRS +
 						POWERCAP_ZONE_MAX_ATTRS + 1;
-	power_zone->zone_dev_attrs = kzalloc(sizeof(void *) *
-						nr_attrs, GFP_KERNEL);
+	power_zone->zone_dev_attrs = kzalloc(array_size(nr_attrs, sizeof(void *)),
+					     GFP_KERNEL);
 	if (!power_zone->zone_dev_attrs)
 		goto err_attr_alloc;
 	create_power_zone_common_attributes(power_zone);
diff --git a/drivers/regulator/s2mps11.c b/drivers/regulator/s2mps11.c
index 7726b874e539..afc6518b3680 100644
--- a/drivers/regulator/s2mps11.c
+++ b/drivers/regulator/s2mps11.c
@@ -1162,7 +1162,7 @@ static int s2mps11_pmic_probe(struct platform_device *pdev)
 		}
 	}
 
-	rdata = kzalloc(sizeof(*rdata) * rdev_num, GFP_KERNEL);
+	rdata = kzalloc(array_size(rdev_num, sizeof(*rdata)), GFP_KERNEL);
 	if (!rdata)
 		return -ENOMEM;
 
diff --git a/drivers/s390/char/keyboard.c b/drivers/s390/char/keyboard.c
index db1fbf9b00b5..b2a2a56101e6 100644
--- a/drivers/s390/char/keyboard.c
+++ b/drivers/s390/char/keyboard.c
@@ -78,7 +78,8 @@ kbd_alloc(void) {
 		}
 	}
 	kbd->fn_handler =
-		kzalloc(sizeof(fn_handler_fn *) * NR_FN_HANDLER, GFP_KERNEL);
+		kzalloc(array_size(NR_FN_HANDLER, sizeof(fn_handler_fn *)),
+			GFP_KERNEL);
 	if (!kbd->fn_handler)
 		goto out_func;
 	kbd->accent_table = kmemdup(ebc_accent_table,
diff --git a/drivers/s390/char/tty3270.c b/drivers/s390/char/tty3270.c
index 1c98023cffd4..7879adcc16cf 100644
--- a/drivers/s390/char/tty3270.c
+++ b/drivers/s390/char/tty3270.c
@@ -719,7 +719,8 @@ tty3270_alloc_view(void)
 	if (!tp)
 		goto out_err;
 	tp->freemem_pages =
-		kmalloc(sizeof(void *) * TTY3270_STRING_PAGES, GFP_KERNEL);
+		kmalloc(array_size(TTY3270_STRING_PAGES, sizeof(void *)),
+			GFP_KERNEL);
 	if (!tp->freemem_pages)
 		goto out_tp;
 	INIT_LIST_HEAD(&tp->freemem);
diff --git a/drivers/s390/cio/qdio_setup.c b/drivers/s390/cio/qdio_setup.c
index 439991d71b14..1116503f701a 100644
--- a/drivers/s390/cio/qdio_setup.c
+++ b/drivers/s390/cio/qdio_setup.c
@@ -542,7 +542,7 @@ void qdio_print_subchannel_info(struct qdio_irq *irq_ptr,
 
 int qdio_enable_async_operation(struct qdio_output_q *outq)
 {
-	outq->aobs = kzalloc(sizeof(struct qaob *) * QDIO_MAX_BUFFERS_PER_Q,
+	outq->aobs = kzalloc(array_size(QDIO_MAX_BUFFERS_PER_Q, sizeof(struct qaob *)),
 			     GFP_ATOMIC);
 	if (!outq->aobs) {
 		outq->use_cq = 0;
diff --git a/drivers/s390/cio/qdio_thinint.c b/drivers/s390/cio/qdio_thinint.c
index 0787b587e4b8..2029229e2209 100644
--- a/drivers/s390/cio/qdio_thinint.c
+++ b/drivers/s390/cio/qdio_thinint.c
@@ -241,8 +241,8 @@ static int set_subchannel_ind(struct qdio_irq *irq_ptr, int reset)
 /* allocate non-shared indicators and shared indicator */
 int __init tiqdio_allocate_memory(void)
 {
-	q_indicators = kzalloc(sizeof(struct indicator_t) * TIQDIO_NR_INDICATORS,
-			     GFP_KERNEL);
+	q_indicators = kzalloc(array_size(TIQDIO_NR_INDICATORS, sizeof(struct indicator_t)),
+			       GFP_KERNEL);
 	if (!q_indicators)
 		return -ENOMEM;
 	return 0;
diff --git a/drivers/s390/crypto/pkey_api.c b/drivers/s390/crypto/pkey_api.c
index ed80d00cdb6f..2dfe566c208a 100644
--- a/drivers/s390/crypto/pkey_api.c
+++ b/drivers/s390/crypto/pkey_api.c
@@ -899,8 +899,7 @@ int pkey_findcard(const struct pkey_seckey *seckey,
 		return -EINVAL;
 
 	/* fetch status of all crypto cards */
-	device_status = kmalloc(MAX_ZDEV_ENTRIES_EXT
-				* sizeof(struct zcrypt_device_status_ext),
+	device_status = kmalloc(array_size(MAX_ZDEV_ENTRIES_EXT, sizeof(struct zcrypt_device_status_ext)),
 				GFP_KERNEL);
 	if (!device_status)
 		return -ENOMEM;
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index 7ce98b70cad3..d54c6de82c63 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -1379,7 +1379,8 @@ static int add_channel(struct ccw_device *cdev, enum ctcm_channel_types type,
 	} else
 		ccw_num = 8;
 
-	ch->ccw = kzalloc(ccw_num * sizeof(struct ccw1), GFP_KERNEL | GFP_DMA);
+	ch->ccw = kzalloc(array_size(ccw_num, sizeof(struct ccw1)),
+			  GFP_KERNEL | GFP_DMA);
 	if (ch->ccw == NULL)
 					goto nomem_return;
 
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 04fefa5bb08d..cc8d1591a4ff 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4988,8 +4988,8 @@ static int qeth_qdio_establish(struct qeth_card *card)
 
 	QETH_DBF_TEXT(SETUP, 2, "qdioest");
 
-	qib_param_field = kzalloc(QDIO_MAX_BUFFERS_PER_Q * sizeof(char),
-			      GFP_KERNEL);
+	qib_param_field = kzalloc(array_size(QDIO_MAX_BUFFERS_PER_Q, sizeof(char)),
+				  GFP_KERNEL);
 	if (!qib_param_field) {
 		rc =  -ENOMEM;
 		goto out_free_nothing;
diff --git a/drivers/scsi/BusLogic.c b/drivers/scsi/BusLogic.c
index 35380a58d3f0..bcbef23fabb4 100644
--- a/drivers/scsi/BusLogic.c
+++ b/drivers/scsi/BusLogic.c
@@ -2366,8 +2366,8 @@ static int __init blogic_init(void)
 	if (blogic_probe_options.noprobe)
 		return -ENODEV;
 	blogic_probeinfo_list =
-	    kzalloc(BLOGIC_MAX_ADAPTERS * sizeof(struct blogic_probeinfo),
-			    GFP_KERNEL);
+	    kzalloc(array_size(BLOGIC_MAX_ADAPTERS, sizeof(struct blogic_probeinfo)),
+		    GFP_KERNEL);
 	if (blogic_probeinfo_list == NULL) {
 		blogic_err("BusLogic: Unable to allocate Probe Info List\n",
 				NULL);
diff --git a/drivers/scsi/aacraid/aachba.c b/drivers/scsi/aacraid/aachba.c
index e7961cbd2c55..69f0574b39b3 100644
--- a/drivers/scsi/aacraid/aachba.c
+++ b/drivers/scsi/aacraid/aachba.c
@@ -4132,7 +4132,8 @@ static int aac_convert_sgraw2(struct aac_raw_io2 *rio2, int pages, int nseg, int
 	if (aac_convert_sgl == 0)
 		return 0;
 
-	sge = kmalloc(nseg_new * sizeof(struct sge_ieee1212), GFP_ATOMIC);
+	sge = kmalloc(array_size(nseg_new, sizeof(struct sge_ieee1212)),
+		      GFP_ATOMIC);
 	if (sge == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/aha1542.c b/drivers/scsi/aha1542.c
index 124217927c4a..cef0f19feb95 100644
--- a/drivers/scsi/aha1542.c
+++ b/drivers/scsi/aha1542.c
@@ -400,7 +400,8 @@ static int aha1542_queuecommand(struct Scsi_Host *sh, struct scsi_cmnd *cmd)
 #endif
 	if (bufflen) {	/* allocate memory before taking host_lock */
 		sg_count = scsi_sg_count(cmd);
-		cptr = kmalloc(sizeof(*cptr) * sg_count, GFP_KERNEL | GFP_DMA);
+		cptr = kmalloc(array_size(sg_count, sizeof(*cptr)),
+			       GFP_KERNEL | GFP_DMA);
 		if (!cptr)
 			return SCSI_MLQUEUE_HOST_BUSY;
 	} else {
diff --git a/drivers/scsi/aic7xxx/aic7xxx_core.c b/drivers/scsi/aic7xxx/aic7xxx_core.c
index e97eceacf522..235d622ecd37 100644
--- a/drivers/scsi/aic7xxx/aic7xxx_core.c
+++ b/drivers/scsi/aic7xxx/aic7xxx_core.c
@@ -4779,8 +4779,8 @@ ahc_init_scbdata(struct ahc_softc *ahc)
 	SLIST_INIT(&scb_data->sg_maps);
 
 	/* Allocate SCB resources */
-	scb_data->scbarray = kzalloc(sizeof(struct scb) * AHC_SCB_MAX_ALLOC,
-				GFP_ATOMIC);
+	scb_data->scbarray = kzalloc(array_size(AHC_SCB_MAX_ALLOC, sizeof(struct scb)),
+				     GFP_ATOMIC);
 	if (scb_data->scbarray == NULL)
 		return (ENOMEM);
 
diff --git a/drivers/scsi/arm/queue.c b/drivers/scsi/arm/queue.c
index 3441ce3ebabf..aa2bed2e09ef 100644
--- a/drivers/scsi/arm/queue.c
+++ b/drivers/scsi/arm/queue.c
@@ -70,7 +70,8 @@ int queue_initialise (Queue_t *queue)
 	 * need to keep free lists or allocate this
 	 * memory.
 	 */
-	queue->alloc = q = kmalloc(sizeof(QE_t) * nqueues, GFP_KERNEL);
+	queue->alloc = q = kmalloc(array_size(nqueues, sizeof(QE_t)),
+				   GFP_KERNEL);
 	if (q) {
 		for (; nqueues; q++, nqueues--) {
 			SET_MAGIC(q, QUEUE_MAGIC_FREE);
diff --git a/drivers/scsi/be2iscsi/be_main.c b/drivers/scsi/be2iscsi/be_main.c
index b3cfdd5f4d1c..ac7fbc7a9465 100644
--- a/drivers/scsi/be2iscsi/be_main.c
+++ b/drivers/scsi/be2iscsi/be_main.c
@@ -2483,7 +2483,7 @@ static int beiscsi_alloc_mem(struct beiscsi_hba *phba)
 		return -ENOMEM;
 	}
 
-	mem_arr_orig = kmalloc(sizeof(*mem_arr_orig) * BEISCSI_MAX_FRAGS_INIT,
+	mem_arr_orig = kmalloc(array_size(BEISCSI_MAX_FRAGS_INIT, sizeof(*mem_arr_orig)),
 			       GFP_KERNEL);
 	if (!mem_arr_orig) {
 		kfree(phba->init_mem);
@@ -2533,7 +2533,7 @@ static int beiscsi_alloc_mem(struct beiscsi_hba *phba)
 		} while (alloc_size);
 		mem_descr->num_elements = j;
 		mem_descr->size_in_bytes = phba->mem_req[i];
-		mem_descr->mem_array = kmalloc(sizeof(*mem_arr) * j,
+		mem_descr->mem_array = kmalloc(array_size(j, sizeof(*mem_arr)),
 					       GFP_KERNEL);
 		if (!mem_descr->mem_array)
 			goto free_mem;
diff --git a/drivers/scsi/bfa/bfad_attr.c b/drivers/scsi/bfa/bfad_attr.c
index d4d276c757ea..1aa501d700eb 100644
--- a/drivers/scsi/bfa/bfad_attr.c
+++ b/drivers/scsi/bfa/bfad_attr.c
@@ -927,7 +927,7 @@ bfad_im_num_of_discovered_ports_show(struct device *dev,
 	struct bfa_rport_qualifier_s *rports = NULL;
 	unsigned long   flags;
 
-	rports = kzalloc(sizeof(struct bfa_rport_qualifier_s) * nrports,
+	rports = kzalloc(array_size(nrports, sizeof(struct bfa_rport_qualifier_s)),
 			 GFP_ATOMIC);
 	if (rports == NULL)
 		return snprintf(buf, PAGE_SIZE, "Failed\n");
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 65de1d0578a1..843e1207e044 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -1397,7 +1397,7 @@ static struct bnx2fc_hba *bnx2fc_hba_create(struct cnic_dev *cnic)
 	hba->next_conn_id = 0;
 
 	hba->tgt_ofld_list =
-		kzalloc(sizeof(struct bnx2fc_rport *) * BNX2FC_NUM_MAX_SESS,
+		kzalloc(array_size(BNX2FC_NUM_MAX_SESS, sizeof(struct bnx2fc_rport *)),
 			GFP_KERNEL);
 	if (!hba->tgt_ofld_list) {
 		printk(KERN_ERR PFX "Unable to allocate tgt offload list\n");
diff --git a/drivers/scsi/bnx2fc/bnx2fc_io.c b/drivers/scsi/bnx2fc/bnx2fc_io.c
index 5a645b8b9af1..583b17f9ea3d 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_io.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_io.c
@@ -240,15 +240,15 @@ struct bnx2fc_cmd_mgr *bnx2fc_cmd_mgr_alloc(struct bnx2fc_hba *hba)
 		return NULL;
 	}
 
-	cmgr->free_list = kzalloc(sizeof(*cmgr->free_list) *
-				  arr_sz, GFP_KERNEL);
+	cmgr->free_list = kzalloc(array_size(arr_sz, sizeof(*cmgr->free_list)),
+				  GFP_KERNEL);
 	if (!cmgr->free_list) {
 		printk(KERN_ERR PFX "failed to alloc free_list\n");
 		goto mem_err;
 	}
 
-	cmgr->free_list_lock = kzalloc(sizeof(*cmgr->free_list_lock) *
-				       arr_sz, GFP_KERNEL);
+	cmgr->free_list_lock = kzalloc(array_size(arr_sz, sizeof(*cmgr->free_list_lock)),
+				       GFP_KERNEL);
 	if (!cmgr->free_list_lock) {
 		printk(KERN_ERR PFX "failed to alloc free_list_lock\n");
 		kfree(cmgr->free_list);
diff --git a/drivers/scsi/esas2r/esas2r_init.c b/drivers/scsi/esas2r/esas2r_init.c
index 9dffcb28c9b7..ed2dd0d23a2a 100644
--- a/drivers/scsi/esas2r/esas2r_init.c
+++ b/drivers/scsi/esas2r/esas2r_init.c
@@ -833,7 +833,7 @@ bool esas2r_init_adapter_struct(struct esas2r_adapter *a,
 
 	/* allocate requests for asynchronous events */
 	a->first_ae_req =
-		kzalloc(num_ae_requests * sizeof(struct esas2r_request),
+		kzalloc(array_size(num_ae_requests, sizeof(struct esas2r_request)),
 			GFP_KERNEL);
 
 	if (a->first_ae_req == NULL) {
@@ -843,8 +843,8 @@ bool esas2r_init_adapter_struct(struct esas2r_adapter *a,
 	}
 
 	/* allocate the S/G list memory descriptors */
-	a->sg_list_mds = kzalloc(
-		num_sg_lists * sizeof(struct esas2r_mem_desc), GFP_KERNEL);
+	a->sg_list_mds = kzalloc(array_size(num_sg_lists, sizeof(struct esas2r_mem_desc)),
+				 GFP_KERNEL);
 
 	if (a->sg_list_mds == NULL) {
 		esas2r_log(ESAS2R_LOG_CRIT,
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index 097f37de6ce9..16db6c46968a 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -1390,7 +1390,7 @@ static void fcoe_ctlr_recv_clr_vlink(struct fcoe_ctlr *fip,
 	 */
 	num_vlink_desc = rlen / sizeof(*vp);
 	if (num_vlink_desc)
-		vlink_desc_arr = kmalloc(sizeof(vp) * num_vlink_desc,
+		vlink_desc_arr = kmalloc(array_size(num_vlink_desc, sizeof(vp)),
 					 GFP_ATOMIC);
 	if (!vlink_desc_arr)
 		return;
diff --git a/drivers/scsi/hpsa.c b/drivers/scsi/hpsa.c
index 3a9eca163db8..307344abc722 100644
--- a/drivers/scsi/hpsa.c
+++ b/drivers/scsi/hpsa.c
@@ -1923,8 +1923,10 @@ static void adjust_hpsa_scsi_table(struct ctlr_info *h,
 	}
 	spin_unlock_irqrestore(&h->reset_lock, flags);
 
-	added = kzalloc(sizeof(*added) * HPSA_MAX_DEVICES, GFP_KERNEL);
-	removed = kzalloc(sizeof(*removed) * HPSA_MAX_DEVICES, GFP_KERNEL);
+	added = kzalloc(array_size(HPSA_MAX_DEVICES, sizeof(*added)),
+			GFP_KERNEL);
+	removed = kzalloc(array_size(HPSA_MAX_DEVICES, sizeof(*removed)),
+			  GFP_KERNEL);
 
 	if (!added || !removed) {
 		dev_warn(&h->pdev->dev, "out of memory in "
@@ -4319,7 +4321,8 @@ static void hpsa_update_scsi_devices(struct ctlr_info *h)
 	bool physical_device;
 	DECLARE_BITMAP(lunzerobits, MAX_EXT_TARGETS);
 
-	currentsd = kzalloc(sizeof(*currentsd) * HPSA_MAX_DEVICES, GFP_KERNEL);
+	currentsd = kzalloc(array_size(HPSA_MAX_DEVICES, sizeof(*currentsd)),
+			    GFP_KERNEL);
 	physdev_list = kzalloc(sizeof(*physdev_list), GFP_KERNEL);
 	logdev_list = kzalloc(sizeof(*logdev_list), GFP_KERNEL);
 	tmpdevice = kzalloc(sizeof(*tmpdevice), GFP_KERNEL);
@@ -6402,12 +6405,14 @@ static int hpsa_big_passthru_ioctl(struct ctlr_info *h, void __user *argp)
 		status = -EINVAL;
 		goto cleanup1;
 	}
-	buff = kzalloc(SG_ENTRIES_IN_CMD * sizeof(char *), GFP_KERNEL);
+	buff = kzalloc(array_size(SG_ENTRIES_IN_CMD, sizeof(char *)),
+		       GFP_KERNEL);
 	if (!buff) {
 		status = -ENOMEM;
 		goto cleanup1;
 	}
-	buff_size = kmalloc(SG_ENTRIES_IN_CMD * sizeof(int), GFP_KERNEL);
+	buff_size = kmalloc(array_size(SG_ENTRIES_IN_CMD, sizeof(int)),
+			    GFP_KERNEL);
 	if (!buff_size) {
 		status = -ENOMEM;
 		goto cleanup1;
@@ -8507,7 +8512,8 @@ static struct ctlr_info *hpda_alloc_ctlr_info(void)
 	if (!h)
 		return NULL;
 
-	h->reply_map = kzalloc(sizeof(*h->reply_map) * nr_cpu_ids, GFP_KERNEL);
+	h->reply_map = kzalloc(array_size(nr_cpu_ids, sizeof(*h->reply_map)),
+			       GFP_KERNEL);
 	if (!h->reply_map) {
 		kfree(h);
 		return NULL;
diff --git a/drivers/scsi/ipr.c b/drivers/scsi/ipr.c
index dda1a64ab89c..d28b68c0d25d 100644
--- a/drivers/scsi/ipr.c
+++ b/drivers/scsi/ipr.c
@@ -9773,8 +9773,8 @@ static int ipr_alloc_mem(struct ipr_ioa_cfg *ioa_cfg)
 		list_add_tail(&ioa_cfg->hostrcb[i]->queue, &ioa_cfg->hostrcb_free_q);
 	}
 
-	ioa_cfg->trace = kzalloc(sizeof(struct ipr_trace_entry) *
-				 IPR_NUM_TRACE_ENTRIES, GFP_KERNEL);
+	ioa_cfg->trace = kzalloc(array_size(IPR_NUM_TRACE_ENTRIES, sizeof(struct ipr_trace_entry)),
+				 GFP_KERNEL);
 
 	if (!ioa_cfg->trace)
 		goto out_free_hostrcb_dma;
diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
index 7887468c71b4..8401e3b45be0 100644
--- a/drivers/scsi/lpfc/lpfc_init.c
+++ b/drivers/scsi/lpfc/lpfc_init.c
@@ -5712,8 +5712,8 @@ lpfc_sli_driver_resource_setup(struct lpfc_hba *phba)
 	}
 
 	if (!phba->sli.sli3_ring)
-		phba->sli.sli3_ring = kzalloc(LPFC_SLI3_MAX_RING *
-			sizeof(struct lpfc_sli_ring), GFP_KERNEL);
+		phba->sli.sli3_ring = kzalloc(array_size(LPFC_SLI3_MAX_RING, sizeof(struct lpfc_sli_ring)),
+					      GFP_KERNEL);
 	if (!phba->sli.sli3_ring)
 		return -ENOMEM;
 
@@ -6207,7 +6207,7 @@ lpfc_sli4_driver_resource_setup(struct lpfc_hba *phba)
 
 	/* Allocate eligible FCF bmask memory for FCF roundrobin failover */
 	longs = (LPFC_SLI4_FCF_TBL_INDX_MAX + BITS_PER_LONG - 1)/BITS_PER_LONG;
-	phba->fcf.fcf_rr_bmask = kzalloc(longs * sizeof(unsigned long),
+	phba->fcf.fcf_rr_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 					 GFP_KERNEL);
 	if (!phba->fcf.fcf_rr_bmask) {
 		lpfc_printf_log(phba, KERN_ERR, LOG_INIT,
diff --git a/drivers/scsi/lpfc/lpfc_mem.c b/drivers/scsi/lpfc/lpfc_mem.c
index 41361662ff08..1f8f5b98cb7a 100644
--- a/drivers/scsi/lpfc/lpfc_mem.c
+++ b/drivers/scsi/lpfc/lpfc_mem.c
@@ -120,8 +120,8 @@ lpfc_mem_alloc(struct lpfc_hba *phba, int align)
 	if (!phba->lpfc_mbuf_pool)
 		goto fail_free_dma_buf_pool;
 
-	pool->elements = kmalloc(sizeof(struct lpfc_dmabuf) *
-					 LPFC_MBUF_POOL_SIZE, GFP_KERNEL);
+	pool->elements = kmalloc(array_size(LPFC_MBUF_POOL_SIZE, sizeof(struct lpfc_dmabuf)),
+				 GFP_KERNEL);
 	if (!pool->elements)
 		goto fail_free_lpfc_mbuf_pool;
 
diff --git a/drivers/scsi/lpfc/lpfc_sli.c b/drivers/scsi/lpfc/lpfc_sli.c
index cb17e2b2be81..ac999abb4466 100644
--- a/drivers/scsi/lpfc/lpfc_sli.c
+++ b/drivers/scsi/lpfc/lpfc_sli.c
@@ -1692,7 +1692,7 @@ lpfc_sli_next_iotag(struct lpfc_hba *phba, struct lpfc_iocbq *iocbq)
 					   - LPFC_IOCBQ_LOOKUP_INCREMENT)) {
 		new_len = psli->iocbq_lookup_len + LPFC_IOCBQ_LOOKUP_INCREMENT;
 		spin_unlock_irq(&phba->hbalock);
-		new_arr = kzalloc(new_len * sizeof (struct lpfc_iocbq *),
+		new_arr = kzalloc(array_size(new_len, sizeof(struct lpfc_iocbq *)),
 				  GFP_KERNEL);
 		if (new_arr) {
 			spin_lock_irq(&phba->hbalock);
@@ -5114,7 +5114,7 @@ lpfc_sli_hba_setup(struct lpfc_hba *phba)
 		 */
 		if ((phba->vpi_bmask == NULL) && (phba->vpi_ids == NULL)) {
 			longs = (phba->max_vpi + BITS_PER_LONG) / BITS_PER_LONG;
-			phba->vpi_bmask = kzalloc(longs * sizeof(unsigned long),
+			phba->vpi_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 						  GFP_KERNEL);
 			if (!phba->vpi_bmask) {
 				rc = -ENOMEM;
@@ -5808,15 +5808,13 @@ lpfc_sli4_alloc_extent(struct lpfc_hba *phba, uint16_t type)
 	length = sizeof(struct lpfc_rsrc_blks);
 	switch (type) {
 	case LPFC_RSC_TYPE_FCOE_RPI:
-		phba->sli4_hba.rpi_bmask = kzalloc(longs *
-						   sizeof(unsigned long),
+		phba->sli4_hba.rpi_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 						   GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.rpi_bmask)) {
 			rc = -ENOMEM;
 			goto err_exit;
 		}
-		phba->sli4_hba.rpi_ids = kzalloc(rsrc_id_cnt *
-						 sizeof(uint16_t),
+		phba->sli4_hba.rpi_ids = kzalloc(array_size(rsrc_id_cnt, sizeof(uint16_t)),
 						 GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.rpi_ids)) {
 			kfree(phba->sli4_hba.rpi_bmask);
@@ -5837,16 +5835,14 @@ lpfc_sli4_alloc_extent(struct lpfc_hba *phba, uint16_t type)
 		ext_blk_list = &phba->sli4_hba.lpfc_rpi_blk_list;
 		break;
 	case LPFC_RSC_TYPE_FCOE_VPI:
-		phba->vpi_bmask = kzalloc(longs *
-					  sizeof(unsigned long),
+		phba->vpi_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 					  GFP_KERNEL);
 		if (unlikely(!phba->vpi_bmask)) {
 			rc = -ENOMEM;
 			goto err_exit;
 		}
-		phba->vpi_ids = kzalloc(rsrc_id_cnt *
-					 sizeof(uint16_t),
-					 GFP_KERNEL);
+		phba->vpi_ids = kzalloc(array_size(rsrc_id_cnt, sizeof(uint16_t)),
+					GFP_KERNEL);
 		if (unlikely(!phba->vpi_ids)) {
 			kfree(phba->vpi_bmask);
 			rc = -ENOMEM;
@@ -5859,16 +5855,14 @@ lpfc_sli4_alloc_extent(struct lpfc_hba *phba, uint16_t type)
 		ext_blk_list = &phba->lpfc_vpi_blk_list;
 		break;
 	case LPFC_RSC_TYPE_FCOE_XRI:
-		phba->sli4_hba.xri_bmask = kzalloc(longs *
-						   sizeof(unsigned long),
+		phba->sli4_hba.xri_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 						   GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.xri_bmask)) {
 			rc = -ENOMEM;
 			goto err_exit;
 		}
 		phba->sli4_hba.max_cfg_param.xri_used = 0;
-		phba->sli4_hba.xri_ids = kzalloc(rsrc_id_cnt *
-						 sizeof(uint16_t),
+		phba->sli4_hba.xri_ids = kzalloc(array_size(rsrc_id_cnt, sizeof(uint16_t)),
 						 GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.xri_ids)) {
 			kfree(phba->sli4_hba.xri_bmask);
@@ -5882,15 +5876,13 @@ lpfc_sli4_alloc_extent(struct lpfc_hba *phba, uint16_t type)
 		ext_blk_list = &phba->sli4_hba.lpfc_xri_blk_list;
 		break;
 	case LPFC_RSC_TYPE_FCOE_VFI:
-		phba->sli4_hba.vfi_bmask = kzalloc(longs *
-						   sizeof(unsigned long),
+		phba->sli4_hba.vfi_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 						   GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.vfi_bmask)) {
 			rc = -ENOMEM;
 			goto err_exit;
 		}
-		phba->sli4_hba.vfi_ids = kzalloc(rsrc_id_cnt *
-						 sizeof(uint16_t),
+		phba->sli4_hba.vfi_ids = kzalloc(array_size(rsrc_id_cnt, sizeof(uint16_t)),
 						 GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.vfi_ids)) {
 			kfree(phba->sli4_hba.vfi_bmask);
@@ -6222,15 +6214,13 @@ lpfc_sli4_alloc_resource_identifiers(struct lpfc_hba *phba)
 		}
 		base = phba->sli4_hba.max_cfg_param.rpi_base;
 		longs = (count + BITS_PER_LONG - 1) / BITS_PER_LONG;
-		phba->sli4_hba.rpi_bmask = kzalloc(longs *
-						   sizeof(unsigned long),
+		phba->sli4_hba.rpi_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 						   GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.rpi_bmask)) {
 			rc = -ENOMEM;
 			goto err_exit;
 		}
-		phba->sli4_hba.rpi_ids = kzalloc(count *
-						 sizeof(uint16_t),
+		phba->sli4_hba.rpi_ids = kzalloc(array_size(count, sizeof(uint16_t)),
 						 GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.rpi_ids)) {
 			rc = -ENOMEM;
@@ -6251,15 +6241,13 @@ lpfc_sli4_alloc_resource_identifiers(struct lpfc_hba *phba)
 		}
 		base = phba->sli4_hba.max_cfg_param.vpi_base;
 		longs = (count + BITS_PER_LONG - 1) / BITS_PER_LONG;
-		phba->vpi_bmask = kzalloc(longs *
-					  sizeof(unsigned long),
+		phba->vpi_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 					  GFP_KERNEL);
 		if (unlikely(!phba->vpi_bmask)) {
 			rc = -ENOMEM;
 			goto free_rpi_ids;
 		}
-		phba->vpi_ids = kzalloc(count *
-					sizeof(uint16_t),
+		phba->vpi_ids = kzalloc(array_size(count, sizeof(uint16_t)),
 					GFP_KERNEL);
 		if (unlikely(!phba->vpi_ids)) {
 			rc = -ENOMEM;
@@ -6280,16 +6268,14 @@ lpfc_sli4_alloc_resource_identifiers(struct lpfc_hba *phba)
 		}
 		base = phba->sli4_hba.max_cfg_param.xri_base;
 		longs = (count + BITS_PER_LONG - 1) / BITS_PER_LONG;
-		phba->sli4_hba.xri_bmask = kzalloc(longs *
-						   sizeof(unsigned long),
+		phba->sli4_hba.xri_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 						   GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.xri_bmask)) {
 			rc = -ENOMEM;
 			goto free_vpi_ids;
 		}
 		phba->sli4_hba.max_cfg_param.xri_used = 0;
-		phba->sli4_hba.xri_ids = kzalloc(count *
-						 sizeof(uint16_t),
+		phba->sli4_hba.xri_ids = kzalloc(array_size(count, sizeof(uint16_t)),
 						 GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.xri_ids)) {
 			rc = -ENOMEM;
@@ -6310,15 +6296,13 @@ lpfc_sli4_alloc_resource_identifiers(struct lpfc_hba *phba)
 		}
 		base = phba->sli4_hba.max_cfg_param.vfi_base;
 		longs = (count + BITS_PER_LONG - 1) / BITS_PER_LONG;
-		phba->sli4_hba.vfi_bmask = kzalloc(longs *
-						   sizeof(unsigned long),
+		phba->sli4_hba.vfi_bmask = kzalloc(array_size(longs, sizeof(unsigned long)),
 						   GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.vfi_bmask)) {
 			rc = -ENOMEM;
 			goto free_xri_ids;
 		}
-		phba->sli4_hba.vfi_ids = kzalloc(count *
-						 sizeof(uint16_t),
+		phba->sli4_hba.vfi_ids = kzalloc(array_size(count, sizeof(uint16_t)),
 						 GFP_KERNEL);
 		if (unlikely(!phba->sli4_hba.vfi_ids)) {
 			rc = -ENOMEM;
diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 7195cff51d4c..92f51a3518b9 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -4322,7 +4322,8 @@ megaraid_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto out_host_put;
 	}
 
-	adapter->scb_list = kmalloc(sizeof(scb_t) * MAX_COMMANDS, GFP_KERNEL);
+	adapter->scb_list = kmalloc(array_size(MAX_COMMANDS, sizeof(scb_t)),
+				    GFP_KERNEL);
 	if (!adapter->scb_list) {
 		dev_warn(&pdev->dev, "out of RAM\n");
 		goto out_free_cmd_buffer;
diff --git a/drivers/scsi/megaraid/megaraid_sas_base.c b/drivers/scsi/megaraid/megaraid_sas_base.c
index b89c6e6c0589..ee4968ced921 100644
--- a/drivers/scsi/megaraid/megaraid_sas_base.c
+++ b/drivers/scsi/megaraid/megaraid_sas_base.c
@@ -5423,9 +5423,8 @@ static int megasas_init_fw(struct megasas_instance *instance)
 	/* stream detection initialization */
 	if (instance->adapter_type == VENTURA_SERIES) {
 		fusion->stream_detect_by_ld =
-			kzalloc(sizeof(struct LD_STREAM_DETECT *)
-			* MAX_LOGICAL_DRIVES_EXT,
-			GFP_KERNEL);
+			kzalloc(array_size(MAX_LOGICAL_DRIVES_EXT, sizeof(struct LD_STREAM_DETECT *)),
+				GFP_KERNEL);
 		if (!fusion->stream_detect_by_ld) {
 			dev_err(&instance->pdev->dev,
 				"unable to allocate stream detection for pool of LDs\n");
@@ -6144,7 +6143,7 @@ static inline int megasas_alloc_mfi_ctrl_mem(struct megasas_instance *instance)
  */
 static int megasas_alloc_ctrl_mem(struct megasas_instance *instance)
 {
-	instance->reply_map = kzalloc(sizeof(unsigned int) * nr_cpu_ids,
+	instance->reply_map = kzalloc(array_size(nr_cpu_ids, sizeof(unsigned int)),
 				      GFP_KERNEL);
 	if (!instance->reply_map)
 		return -ENOMEM;
diff --git a/drivers/scsi/megaraid/megaraid_sas_fusion.c b/drivers/scsi/megaraid/megaraid_sas_fusion.c
index ce97cde3b41c..093abc602f7d 100644
--- a/drivers/scsi/megaraid/megaraid_sas_fusion.c
+++ b/drivers/scsi/megaraid/megaraid_sas_fusion.c
@@ -487,7 +487,7 @@ megasas_alloc_cmdlist_fusion(struct megasas_instance *instance)
 	 * commands.
 	 */
 	fusion->cmd_list =
-		kzalloc(sizeof(struct megasas_cmd_fusion *) * max_mpt_cmd,
+		kzalloc(array_size(max_mpt_cmd, sizeof(struct megasas_cmd_fusion *)),
 			GFP_KERNEL);
 	if (!fusion->cmd_list) {
 		dev_err(&instance->pdev->dev,
diff --git a/drivers/scsi/osst.c b/drivers/scsi/osst.c
index 20ec1c01dbd5..615faa0860a1 100644
--- a/drivers/scsi/osst.c
+++ b/drivers/scsi/osst.c
@@ -381,7 +381,8 @@ static int osst_execute(struct osst_request *SRpnt, const unsigned char *cmd,
 		struct scatterlist *sg, *sgl = (struct scatterlist *)buffer;
 		int i;
 
-		pages = kzalloc(use_sg * sizeof(struct page *), GFP_KERNEL);
+		pages = kzalloc(array_size(use_sg, sizeof(struct page *)),
+				GFP_KERNEL);
 		if (!pages)
 			goto free_req;
 
@@ -5856,7 +5857,8 @@ static int osst_probe(struct device *dev)
 	/* if this is the first attach, build the infrastructure */
 	write_lock(&os_scsi_tapes_lock);
 	if (os_scsi_tapes == NULL) {
-		os_scsi_tapes = kmalloc(osst_max_dev * sizeof(struct osst_tape *), GFP_ATOMIC);
+		os_scsi_tapes = kmalloc(array_size(osst_max_dev, sizeof(struct osst_tape *)),
+                                        GFP_ATOMIC);
 		if (os_scsi_tapes == NULL) {
 			write_unlock(&os_scsi_tapes_lock);
 			printk(KERN_ERR "osst :E: Unable to allocate array for OnStream SCSI tapes.\n");
diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index 95530393872d..5973557759f6 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -4873,8 +4873,8 @@ static int pmcraid_allocate_config_buffers(struct pmcraid_instance *pinstance)
 	int i;
 
 	pinstance->res_entries =
-			kzalloc(sizeof(struct pmcraid_resource_entry) *
-				PMCRAID_MAX_RESOURCES, GFP_KERNEL);
+			kzalloc(array_size(PMCRAID_MAX_RESOURCES, sizeof(struct pmcraid_resource_entry)),
+				GFP_KERNEL);
 
 	if (NULL == pinstance->res_entries) {
 		pmcraid_err("failed to allocate memory for resource table\n");
diff --git a/drivers/scsi/qla2xxx/qla_nx.c b/drivers/scsi/qla2xxx/qla_nx.c
index 872d66dd79cd..be2dd4612301 100644
--- a/drivers/scsi/qla2xxx/qla_nx.c
+++ b/drivers/scsi/qla2xxx/qla_nx.c
@@ -1230,7 +1230,7 @@ qla82xx_pinit_from_rom(scsi_qla_host_t *vha)
 	ql_log(ql_log_info, vha, 0x0072,
 	    "%d CRB init values found in ROM.\n", n);
 
-	buf = kmalloc(n * sizeof(struct crb_addr_pair), GFP_KERNEL);
+	buf = kmalloc(array_size(n, sizeof(struct crb_addr_pair)), GFP_KERNEL);
 	if (buf == NULL) {
 		ql_log(ql_log_fatal, vha, 0x010c,
 		    "Unable to allocate memory.\n");
diff --git a/drivers/scsi/qla2xxx/qla_target.c b/drivers/scsi/qla2xxx/qla_target.c
index 025dc2d3f3de..09997a1b1ec3 100644
--- a/drivers/scsi/qla2xxx/qla_target.c
+++ b/drivers/scsi/qla2xxx/qla_target.c
@@ -7007,8 +7007,8 @@ qlt_mem_alloc(struct qla_hw_data *ha)
 	if (!QLA_TGT_MODE_ENABLED())
 		return 0;
 
-	ha->tgt.tgt_vp_map = kzalloc(sizeof(struct qla_tgt_vp_map) *
-	    MAX_MULTI_ID_FABRIC, GFP_KERNEL);
+	ha->tgt.tgt_vp_map = kzalloc(array_size(MAX_MULTI_ID_FABRIC, sizeof(struct qla_tgt_vp_map)),
+				     GFP_KERNEL);
 	if (!ha->tgt.tgt_vp_map)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/qla4xxx/ql4_nx.c b/drivers/scsi/qla4xxx/ql4_nx.c
index 43f73583ef5c..5895d6fd239d 100644
--- a/drivers/scsi/qla4xxx/ql4_nx.c
+++ b/drivers/scsi/qla4xxx/ql4_nx.c
@@ -1077,7 +1077,7 @@ qla4_82xx_pinit_from_rom(struct scsi_qla_host *ha, int verbose)
 	ql4_printk(KERN_INFO, ha,
 		"%s: %d CRB init values found in ROM.\n", DRIVER_NAME, n);
 
-	buf = kmalloc(n * sizeof(struct crb_addr_pair), GFP_KERNEL);
+	buf = kmalloc(array_size(n, sizeof(struct crb_addr_pair)), GFP_KERNEL);
 	if (buf == NULL) {
 		ql4_printk(KERN_WARNING, ha,
 		    "%s: [ERROR] Unable to malloc memory.\n", DRIVER_NAME);
diff --git a/drivers/scsi/scsi_debug.c b/drivers/scsi/scsi_debug.c
index 9ef5e3b810f6..05cbbc913e6b 100644
--- a/drivers/scsi/scsi_debug.c
+++ b/drivers/scsi/scsi_debug.c
@@ -3441,7 +3441,7 @@ static int resp_comp_write(struct scsi_cmnd *scp,
 		return check_condition_result;
 	}
 	dnum = 2 * num;
-	arr = kzalloc(dnum * lb_size, GFP_ATOMIC);
+	arr = kzalloc(array_size(lb_size, dnum), GFP_ATOMIC);
 	if (NULL == arr) {
 		mk_sense_buffer(scp, ILLEGAL_REQUEST, INSUFF_RES_ASC,
 				INSUFF_RES_ASCQ);
diff --git a/drivers/scsi/ses.c b/drivers/scsi/ses.c
index 62f04c0511cf..e5c2c518fce4 100644
--- a/drivers/scsi/ses.c
+++ b/drivers/scsi/ses.c
@@ -747,7 +747,8 @@ static int ses_intf_add(struct device *cdev,
 		buf = NULL;
 	}
 page2_not_supported:
-	scomp = kzalloc(sizeof(struct ses_component) * components, GFP_KERNEL);
+	scomp = kzalloc(array_size(components, sizeof(struct ses_component)),
+			GFP_KERNEL);
 	if (!scomp)
 		goto err_free;
 
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index c198b96368dd..88920b221e2a 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -1046,7 +1046,7 @@ sg_ioctl(struct file *filp, unsigned int cmd_in, unsigned long arg)
 		else {
 			sg_req_info_t *rinfo;
 
-			rinfo = kzalloc(SZ_SG_REQ_INFO * SG_MAX_QUEUE,
+			rinfo = kzalloc(array_size(SG_MAX_QUEUE, SZ_SG_REQ_INFO),
 					GFP_KERNEL);
 			if (!rinfo)
 				return -ENOMEM;
diff --git a/drivers/scsi/smartpqi/smartpqi_init.c b/drivers/scsi/smartpqi/smartpqi_init.c
index 592b6dbf8b35..060bf5a27df8 100644
--- a/drivers/scsi/smartpqi/smartpqi_init.c
+++ b/drivers/scsi/smartpqi/smartpqi_init.c
@@ -1820,8 +1820,8 @@ static int pqi_update_scsi_devices(struct pqi_ctrl_info *ctrl_info)
 
 	num_new_devices = num_physicals + num_logicals;
 
-	new_device_list = kmalloc(sizeof(*new_device_list) *
-		num_new_devices, GFP_KERNEL);
+	new_device_list = kmalloc(array_size(num_new_devices, sizeof(*new_device_list)),
+				  GFP_KERNEL);
 	if (!new_device_list) {
 		dev_warn(&ctrl_info->pci_dev->dev, "%s\n", out_of_memory_msg);
 		rc = -ENOMEM;
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 6c399480783d..c3c9cd5a0dc8 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -3888,7 +3888,7 @@ static struct st_buffer *new_tape_buffer(int need_dma, int max_sg)
 	tb->dma = need_dma;
 	tb->buffer_size = 0;
 
-	tb->reserved_pages = kzalloc(max_sg * sizeof(struct page *),
+	tb->reserved_pages = kzalloc(array_size(max_sg, sizeof(struct page *)),
 				     GFP_ATOMIC);
 	if (!tb->reserved_pages) {
 		kfree(tb);
@@ -4915,7 +4915,7 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
 	if (count == 0)
 		return 0;
 
-	if ((pages = kmalloc(max_pages * sizeof(*pages), GFP_KERNEL)) == NULL)
+	if ((pages = kmalloc(array_size(max_pages, sizeof(*pages)), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index 45d04631888a..c41c65865ff2 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -794,9 +794,11 @@ static int virtscsi_init(struct virtio_device *vdev,
 	struct irq_affinity desc = { .pre_vectors = 2 };
 
 	num_vqs = vscsi->num_queues + VIRTIO_SCSI_VQ_BASE;
-	vqs = kmalloc(num_vqs * sizeof(struct virtqueue *), GFP_KERNEL);
-	callbacks = kmalloc(num_vqs * sizeof(vq_callback_t *), GFP_KERNEL);
-	names = kmalloc(num_vqs * sizeof(char *), GFP_KERNEL);
+	vqs = kmalloc(array_size(num_vqs, sizeof(struct virtqueue *)),
+		      GFP_KERNEL);
+	callbacks = kmalloc(array_size(num_vqs, sizeof(vq_callback_t *)),
+			    GFP_KERNEL);
+	names = kmalloc(array_size(num_vqs, sizeof(char *)), GFP_KERNEL);
 
 	if (!callbacks || !vqs || !names) {
 		err = -ENOMEM;
diff --git a/drivers/sh/clk/cpg.c b/drivers/sh/clk/cpg.c
index 7442bc130055..ac87bf189d50 100644
--- a/drivers/sh/clk/cpg.c
+++ b/drivers/sh/clk/cpg.c
@@ -249,7 +249,7 @@ static int __init sh_clk_div_register_ops(struct clk *clks, int nr,
 	int k;
 
 	freq_table_size *= (nr_divs + 1);
-	freq_table = kzalloc(freq_table_size * nr, GFP_KERNEL);
+	freq_table = kzalloc(array_size(nr, freq_table_size), GFP_KERNEL);
 	if (!freq_table) {
 		pr_err("%s: unable to alloc memory\n", __func__);
 		return -ENOMEM;
diff --git a/drivers/slimbus/qcom-ctrl.c b/drivers/slimbus/qcom-ctrl.c
index ffb46f915334..b21c1927eb40 100644
--- a/drivers/slimbus/qcom-ctrl.c
+++ b/drivers/slimbus/qcom-ctrl.c
@@ -541,7 +541,7 @@ static int qcom_slim_probe(struct platform_device *pdev)
 	ctrl->tx.sl_sz = SLIM_MSGQ_BUF_LEN;
 	ctrl->rx.n = QCOM_RX_MSGS;
 	ctrl->rx.sl_sz = SLIM_MSGQ_BUF_LEN;
-	ctrl->wr_comp = kzalloc(sizeof(struct completion *) * QCOM_TX_MSGS,
+	ctrl->wr_comp = kzalloc(array_size(QCOM_TX_MSGS, sizeof(struct completion *)),
 				GFP_KERNEL);
 	if (!ctrl->wr_comp)
 		return -ENOMEM;
diff --git a/drivers/soc/fsl/qbman/qman.c b/drivers/soc/fsl/qbman/qman.c
index ba3cfa8e279b..edbdf520e07c 100644
--- a/drivers/soc/fsl/qbman/qman.c
+++ b/drivers/soc/fsl/qbman/qman.c
@@ -1181,7 +1181,7 @@ static int qman_create_portal(struct qman_portal *portal,
 	qm_dqrr_set_ithresh(p, QMAN_PIRQ_DQRR_ITHRESH);
 	qm_mr_set_ithresh(p, QMAN_PIRQ_MR_ITHRESH);
 	qm_out(p, QM_REG_ITPR, QMAN_PIRQ_IPERIOD);
-	portal->cgrs = kmalloc(2 * sizeof(*cgrs), GFP_KERNEL);
+	portal->cgrs = kmalloc(array_size(2, sizeof(*cgrs)), GFP_KERNEL);
 	if (!portal->cgrs)
 		goto fail_cgrs;
 	/* initial snapshot is no-depletion */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 1bee667802b0..244a7a13947d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -170,7 +170,7 @@ lnet_ipif_enumerate(char ***namesp)
 			      nalloc);
 		}
 
-		ifr = kzalloc(nalloc * sizeof(*ifr), GFP_KERNEL);
+		ifr = kzalloc(array_size(nalloc, sizeof(*ifr)), GFP_KERNEL);
 		if (!ifr) {
 			CERROR("ENOMEM enumerating up to %d interfaces\n",
 			       nalloc);
@@ -202,7 +202,7 @@ lnet_ipif_enumerate(char ***namesp)
 	if (!nfound)
 		goto out1;
 
-	names = kzalloc(nfound * sizeof(*names), GFP_KERNEL);
+	names = kzalloc(array_size(nfound, sizeof(*names)), GFP_KERNEL);
 	if (!names) {
 		rc = -ENOMEM;
 		goto out1;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 1acd5cb324b1..76b2a6c895ed 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -861,7 +861,7 @@ lstcon_batch_add(char *name)
 		return -ENOMEM;
 	}
 
-	bat->bat_cli_hash = kmalloc(sizeof(struct list_head) * LST_NODE_HASHSIZE,
+	bat->bat_cli_hash = kmalloc(array_size(LST_NODE_HASHSIZE, sizeof(struct list_head)),
 				    GFP_KERNEL);
 	if (!bat->bat_cli_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
@@ -870,7 +870,7 @@ lstcon_batch_add(char *name)
 		return -ENOMEM;
 	}
 
-	bat->bat_srv_hash = kmalloc(sizeof(struct list_head) * LST_NODE_HASHSIZE,
+	bat->bat_srv_hash = kmalloc(array_size(LST_NODE_HASHSIZE, sizeof(struct list_head)),
 				    GFP_KERNEL);
 	if (!bat->bat_srv_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
@@ -2024,7 +2024,8 @@ lstcon_console_init(void)
 	INIT_LIST_HEAD(&console_session.ses_trans_list);
 
 	console_session.ses_ndl_hash =
-		kmalloc(sizeof(struct list_head) * LST_GLOBAL_HASHSIZE, GFP_KERNEL);
+		kmalloc(array_size(LST_GLOBAL_HASHSIZE, sizeof(struct list_head)),
+			GFP_KERNEL);
 	if (!console_session.ses_ndl_hash)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index f53b1a3c342e..8074d40a8f4c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -184,8 +184,8 @@ int class_handle_init(void)
 
 	LASSERT(!handle_hash);
 
-	handle_hash = kvzalloc(sizeof(*bucket) * HANDLE_HASH_SIZE,
-				      GFP_KERNEL);
+	handle_hash = kvzalloc(array_size(HANDLE_HASH_SIZE, sizeof(*bucket)),
+			       GFP_KERNEL);
 	if (!handle_hash)
 		return -ENOMEM;
 
diff --git a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_compat_css20.c b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_compat_css20.c
index f668c68dc33a..06e6e24c2840 100644
--- a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_compat_css20.c
+++ b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_compat_css20.c
@@ -4313,8 +4313,8 @@ int atomisp_css_create_acc_pipe(struct atomisp_sub_device *asd)
 
 	pipe_config = &stream_env->pipe_configs[CSS_PIPE_ID_ACC];
 	ia_css_pipe_config_defaults(pipe_config);
-	asd->acc.acc_stages = kzalloc(MAX_ACC_STAGES *
-				sizeof(void *), GFP_KERNEL);
+	asd->acc.acc_stages = kzalloc(array_size(MAX_ACC_STAGES, sizeof(void *)),
+				      GFP_KERNEL);
 	if (!asd->acc.acc_stages)
 		return -ENOMEM;
 	pipe_config->acc_stages = asd->acc.acc_stages;
diff --git a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c
index 709137f25700..f37fe9d49d37 100644
--- a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c
+++ b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c
@@ -1132,7 +1132,7 @@ static int remove_pad_from_frame(struct atomisp_device *isp,
 	ia_css_ptr load = in_frame->data;
 	ia_css_ptr store = load;
 
-	buffer = kmalloc(width*sizeof(load), GFP_KERNEL);
+	buffer = kmalloc(array_size(width, sizeof(load)), GFP_KERNEL);
 	if (!buffer)
 		return -ENOMEM;
 
diff --git a/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_reserved_pool.c b/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_reserved_pool.c
index f300e7547997..9365bce201e8 100644
--- a/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_reserved_pool.c
+++ b/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_reserved_pool.c
@@ -91,8 +91,8 @@ static int hmm_reserved_pool_setup(struct hmm_reserved_pool_info **repool_info,
 	if (unlikely(!pool_info))
 		return -ENOMEM;
 
-	pool_info->pages = kmalloc(sizeof(struct page *) * pool_size,
-			GFP_KERNEL);
+	pool_info->pages = kmalloc(array_size(pool_size, sizeof(struct page *)),
+				   GFP_KERNEL);
 	if (unlikely(!pool_info->pages)) {
 		kfree(pool_info);
 		return -ENOMEM;
diff --git a/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c b/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c
index 3d2d1c2a006f..cc8c4e2a9614 100644
--- a/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c
+++ b/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c
@@ -143,7 +143,8 @@ static int rt2880_pinctrl_dt_node_to_map(struct pinctrl_dev *pctrldev,
 	if (!max_maps)
 		return max_maps;
 
-	*map = kzalloc(max_maps * sizeof(struct pinctrl_map), GFP_KERNEL);
+	*map = kzalloc(array_size(max_maps, sizeof(struct pinctrl_map)),
+		       GFP_KERNEL);
 	if (!*map)
 		return -ENOMEM;
 
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
index 37a610d05ad2..3d052f932226 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
@@ -597,8 +597,8 @@ static void RxReorderIndicatePacket(struct ieee80211_device *ieee,
 	bool			bMatchWinStart = false, bPktInBuf = false;
 	IEEE80211_DEBUG(IEEE80211_DL_REORDER,"%s(): Seq is %d,pTS->RxIndicateSeq is %d, WinSize is %d\n",__func__,SeqNum,pTS->RxIndicateSeq,WinSize);
 
-	prxbIndicateArray = kmalloc(sizeof(struct ieee80211_rxb *) *
-			REORDER_WIN_SIZE, GFP_KERNEL);
+	prxbIndicateArray = kmalloc(array_size(REORDER_WIN_SIZE, sizeof(struct ieee80211_rxb *)),
+				    GFP_KERNEL);
 	if (!prxbIndicateArray)
 		return;
 
diff --git a/drivers/staging/unisys/visorhba/visorhba_main.c b/drivers/staging/unisys/visorhba/visorhba_main.c
index 167e98f8688e..c50c80c4c028 100644
--- a/drivers/staging/unisys/visorhba/visorhba_main.c
+++ b/drivers/staging/unisys/visorhba/visorhba_main.c
@@ -865,7 +865,7 @@ static void do_scsi_nolinuxstat(struct uiscmdrsp *cmdrsp,
 		if (cmdrsp->scsi.no_disk_result == 0)
 			return;
 
-		buf = kzalloc(sizeof(char) * 36, GFP_KERNEL);
+		buf = kzalloc(array_size(36, sizeof(char)), GFP_KERNEL);
 		if (!buf)
 			return;
 
diff --git a/drivers/target/target_core_transport.c b/drivers/target/target_core_transport.c
index 4558f2e1fe1b..57ebd8f96c4c 100644
--- a/drivers/target/target_core_transport.c
+++ b/drivers/target/target_core_transport.c
@@ -250,7 +250,7 @@ int transport_alloc_session_tags(struct se_session *se_sess,
 {
 	int rc;
 
-	se_sess->sess_cmd_map = kzalloc(tag_num * tag_size,
+	se_sess->sess_cmd_map = kzalloc(array_size(tag_size, tag_num),
 					GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYFAIL);
 	if (!se_sess->sess_cmd_map) {
 		se_sess->sess_cmd_map = vzalloc(tag_num * tag_size);
diff --git a/drivers/thermal/int340x_thermal/int340x_thermal_zone.c b/drivers/thermal/int340x_thermal/int340x_thermal_zone.c
index 145a5c53ff5c..a5e57829815a 100644
--- a/drivers/thermal/int340x_thermal/int340x_thermal_zone.c
+++ b/drivers/thermal/int340x_thermal/int340x_thermal_zone.c
@@ -239,9 +239,8 @@ struct int34x_thermal_zone *int340x_thermal_zone_add(struct acpi_device *adev,
 	if (ACPI_FAILURE(status))
 		trip_cnt = 0;
 	else {
-		int34x_thermal_zone->aux_trips = kzalloc(
-				sizeof(*int34x_thermal_zone->aux_trips) *
-				trip_cnt, GFP_KERNEL);
+		int34x_thermal_zone->aux_trips = kzalloc(array_size(trip_cnt, sizeof(*int34x_thermal_zone->aux_trips)),
+							 GFP_KERNEL);
 		if (!int34x_thermal_zone->aux_trips) {
 			ret = -ENOMEM;
 			goto err_trip_alloc;
diff --git a/drivers/thermal/x86_pkg_temp_thermal.c b/drivers/thermal/x86_pkg_temp_thermal.c
index 1a6c88b10a39..0467e0e777cc 100644
--- a/drivers/thermal/x86_pkg_temp_thermal.c
+++ b/drivers/thermal/x86_pkg_temp_thermal.c
@@ -516,7 +516,8 @@ static int __init pkg_temp_thermal_init(void)
 		return -ENODEV;
 
 	max_packages = topology_max_packages();
-	packages = kzalloc(max_packages * sizeof(struct pkg_device *), GFP_KERNEL);
+	packages = kzalloc(array_size(max_packages, sizeof(struct pkg_device *)),
+			   GFP_KERNEL);
 	if (!packages)
 		return -ENOMEM;
 
diff --git a/drivers/tty/ehv_bytechan.c b/drivers/tty/ehv_bytechan.c
index 47ac56817c43..6c331d0c723f 100644
--- a/drivers/tty/ehv_bytechan.c
+++ b/drivers/tty/ehv_bytechan.c
@@ -754,7 +754,8 @@ static int __init ehv_bc_init(void)
 	 * array, then you can use pointer math (e.g. "bc - bcs") to get its
 	 * tty index.
 	 */
-	bcs = kzalloc(count * sizeof(struct ehv_bc_data), GFP_KERNEL);
+	bcs = kzalloc(array_size(count, sizeof(struct ehv_bc_data)),
+		      GFP_KERNEL);
 	if (!bcs)
 		return -ENOMEM;
 
diff --git a/drivers/tty/goldfish.c b/drivers/tty/goldfish.c
index 1c1bd0afcd48..b200df58d0bf 100644
--- a/drivers/tty/goldfish.c
+++ b/drivers/tty/goldfish.c
@@ -245,8 +245,8 @@ static int goldfish_tty_create_driver(void)
 	int ret;
 	struct tty_driver *tty;
 
-	goldfish_ttys = kzalloc(sizeof(*goldfish_ttys) *
-				goldfish_tty_line_count, GFP_KERNEL);
+	goldfish_ttys = kzalloc(array_size(goldfish_tty_line_count, sizeof(*goldfish_ttys)),
+				GFP_KERNEL);
 	if (goldfish_ttys == NULL) {
 		ret = -ENOMEM;
 		goto err_alloc_goldfish_ttys_failed;
diff --git a/drivers/tty/hvc/hvcs.c b/drivers/tty/hvc/hvcs.c
index 1db1d97e72e7..91541f5c617f 100644
--- a/drivers/tty/hvc/hvcs.c
+++ b/drivers/tty/hvc/hvcs.c
@@ -1441,7 +1441,8 @@ static int hvcs_alloc_index_list(int n)
 {
 	int i;
 
-	hvcs_index_list = kmalloc(n * sizeof(hvcs_index_count),GFP_KERNEL);
+	hvcs_index_list = kmalloc(array_size(n, sizeof(hvcs_index_count)),
+				  GFP_KERNEL);
 	if (!hvcs_index_list)
 		return -ENOMEM;
 	hvcs_index_count = n;
diff --git a/drivers/tty/serial/atmel_serial.c b/drivers/tty/serial/atmel_serial.c
index e287fe8f10fc..14ab25b9f81e 100644
--- a/drivers/tty/serial/atmel_serial.c
+++ b/drivers/tty/serial/atmel_serial.c
@@ -2739,8 +2739,8 @@ static int atmel_serial_probe(struct platform_device *pdev)
 
 	if (!atmel_use_pdc_rx(&atmel_port->uart)) {
 		ret = -ENOMEM;
-		data = kmalloc(sizeof(struct atmel_uart_char)
-				* ATMEL_SERIAL_RINGSIZE, GFP_KERNEL);
+		data = kmalloc(array_size(ATMEL_SERIAL_RINGSIZE, sizeof(struct atmel_uart_char)),
+			       GFP_KERNEL);
 		if (!data)
 			goto err_alloc_ring;
 		atmel_port->rx_ring.buf = data;
diff --git a/drivers/tty/serial/pch_uart.c b/drivers/tty/serial/pch_uart.c
index 760d5dd0aada..c8db0dfb705a 100644
--- a/drivers/tty/serial/pch_uart.c
+++ b/drivers/tty/serial/pch_uart.c
@@ -991,7 +991,8 @@ static unsigned int dma_handle_tx(struct eg20t_port *priv)
 
 	priv->tx_dma_use = 1;
 
-	priv->sg_tx_p = kzalloc(sizeof(struct scatterlist)*num, GFP_ATOMIC);
+	priv->sg_tx_p = kzalloc(array_size(num, sizeof(struct scatterlist)),
+				GFP_ATOMIC);
 	if (!priv->sg_tx_p) {
 		dev_err(priv->port.dev, "%s:kzalloc Failed\n", __func__);
 		return 0;
diff --git a/drivers/tty/serial/sunsab.c b/drivers/tty/serial/sunsab.c
index b93d0225f8c9..dac59df12b94 100644
--- a/drivers/tty/serial/sunsab.c
+++ b/drivers/tty/serial/sunsab.c
@@ -1125,8 +1125,8 @@ static int __init sunsab_init(void)
 	}
 
 	if (num_channels) {
-		sunsab_ports = kzalloc(sizeof(struct uart_sunsab_port) *
-				       num_channels, GFP_KERNEL);
+		sunsab_ports = kzalloc(array_size(num_channels, sizeof(struct uart_sunsab_port)),
+				       GFP_KERNEL);
 		if (!sunsab_ports)
 			return -ENOMEM;
 
diff --git a/drivers/tty/vt/consolemap.c b/drivers/tty/vt/consolemap.c
index 722a6690c70d..fe01c6a9da90 100644
--- a/drivers/tty/vt/consolemap.c
+++ b/drivers/tty/vt/consolemap.c
@@ -231,7 +231,8 @@ static void set_inverse_trans_unicode(struct vc_data *conp,
 	q = p->inverse_trans_unicode;
 	if (!q) {
 		q = p->inverse_trans_unicode =
-			kmalloc(MAX_GLYPH * sizeof(u16), GFP_KERNEL);
+			kmalloc(array_size(MAX_GLYPH, sizeof(u16)),
+				GFP_KERNEL);
 		if (!q)
 			return;
 	}
@@ -479,7 +480,8 @@ con_insert_unipair(struct uni_pagedir *p, u_short unicode, u_short fontpos)
 
 	p1 = p->uni_pgdir[n = unicode >> 11];
 	if (!p1) {
-		p1 = p->uni_pgdir[n] = kmalloc(32*sizeof(u16 *), GFP_KERNEL);
+		p1 = p->uni_pgdir[n] = kmalloc(array_size(32, sizeof(u16 *)),
+					       GFP_KERNEL);
 		if (!p1) return -ENOMEM;
 		for (i = 0; i < 32; i++)
 			p1[i] = NULL;
@@ -487,7 +489,7 @@ con_insert_unipair(struct uni_pagedir *p, u_short unicode, u_short fontpos)
 
 	p2 = p1[n = (unicode >> 6) & 0x1f];
 	if (!p2) {
-		p2 = p1[n] = kmalloc(64*sizeof(u16), GFP_KERNEL);
+		p2 = p1[n] = kmalloc(array_size(64, sizeof(u16)), GFP_KERNEL);
 		if (!p2) return -ENOMEM;
 		memset(p2, 0xff, 64*sizeof(u16)); /* No glyphs for the characters (yet) */
 	}
diff --git a/drivers/tty/vt/keyboard.c b/drivers/tty/vt/keyboard.c
index 5d412df8e943..66fac60c9fee 100644
--- a/drivers/tty/vt/keyboard.c
+++ b/drivers/tty/vt/keyboard.c
@@ -1624,8 +1624,8 @@ int vt_do_diacrit(unsigned int cmd, void __user *udp, int perm)
 		struct kbdiacr *dia;
 		int i;
 
-		dia = kmalloc(MAX_DIACR * sizeof(struct kbdiacr),
-								GFP_KERNEL);
+		dia = kmalloc(array_size(MAX_DIACR, sizeof(struct kbdiacr)),
+			      GFP_KERNEL);
 		if (!dia)
 			return -ENOMEM;
 
@@ -1657,8 +1657,8 @@ int vt_do_diacrit(unsigned int cmd, void __user *udp, int perm)
 		struct kbdiacrsuc __user *a = udp;
 		void *buf;
 
-		buf = kmalloc(MAX_DIACR * sizeof(struct kbdiacruc),
-								GFP_KERNEL);
+		buf = kmalloc(array_size(MAX_DIACR, sizeof(struct kbdiacruc)),
+			      GFP_KERNEL);
 		if (buf == NULL)
 			return -ENOMEM;
 
diff --git a/drivers/uio/uio_pruss.c b/drivers/uio/uio_pruss.c
index 31d5b1d3b5af..12070589a1b7 100644
--- a/drivers/uio/uio_pruss.c
+++ b/drivers/uio/uio_pruss.c
@@ -129,7 +129,8 @@ static int pruss_probe(struct platform_device *pdev)
 	if (!gdev)
 		return -ENOMEM;
 
-	gdev->info = kzalloc(sizeof(*p) * MAX_PRUSS_EVT, GFP_KERNEL);
+	gdev->info = kzalloc(array_size(MAX_PRUSS_EVT, sizeof(*p)),
+			     GFP_KERNEL);
 	if (!gdev->info) {
 		kfree(gdev);
 		return -ENOMEM;
diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
index 76e16c5251b9..8ec3da0cac27 100644
--- a/drivers/usb/core/devio.c
+++ b/drivers/usb/core/devio.c
@@ -897,7 +897,7 @@ static int parse_usbdevfs_streams(struct usb_dev_state *ps,
 	if (num_streams_ret && (num_streams < 2 || num_streams > 65536))
 		return -EINVAL;
 
-	eps = kmalloc(num_eps * sizeof(*eps), GFP_KERNEL);
+	eps = kmalloc(array_size(num_eps, sizeof(*eps)), GFP_KERNEL);
 	if (!eps)
 		return -ENOMEM;
 
@@ -1602,7 +1602,7 @@ static int proc_do_submiturb(struct usb_dev_state *ps, struct usbdevfs_urb *uurb
 	as->mem_usage = u;
 
 	if (num_sgs) {
-		as->urb->sg = kmalloc(num_sgs * sizeof(struct scatterlist),
+		as->urb->sg = kmalloc(array_size(num_sgs, sizeof(struct scatterlist)),
 				      GFP_KERNEL);
 		if (!as->urb->sg) {
 			ret = -ENOMEM;
diff --git a/drivers/usb/core/hub.c b/drivers/usb/core/hub.c
index f6ea16e9f6bb..67ab881186b2 100644
--- a/drivers/usb/core/hub.c
+++ b/drivers/usb/core/hub.c
@@ -1371,7 +1371,8 @@ static int hub_configure(struct usb_hub *hub,
 	dev_info(hub_dev, "%d port%s detected\n", maxchild,
 			(maxchild == 1) ? "" : "s");
 
-	hub->ports = kzalloc(maxchild * sizeof(struct usb_port *), GFP_KERNEL);
+	hub->ports = kzalloc(array_size(maxchild, sizeof(struct usb_port *)),
+			     GFP_KERNEL);
 	if (!hub->ports) {
 		ret = -ENOMEM;
 		goto fail;
diff --git a/drivers/usb/core/message.c b/drivers/usb/core/message.c
index 0c11d40a12bc..f6fdc9f54ec7 100644
--- a/drivers/usb/core/message.c
+++ b/drivers/usb/core/message.c
@@ -1824,8 +1824,8 @@ int usb_set_configuration(struct usb_device *dev, int configuration)
 	n = nintf = 0;
 	if (cp) {
 		nintf = cp->desc.bNumInterfaces;
-		new_interfaces = kmalloc(nintf * sizeof(*new_interfaces),
-				GFP_NOIO);
+		new_interfaces = kmalloc(array_size(nintf, sizeof(*new_interfaces)),
+					 GFP_NOIO);
 		if (!new_interfaces)
 			return -ENOMEM;
 
diff --git a/drivers/usb/dwc2/hcd.c b/drivers/usb/dwc2/hcd.c
index 190f95964000..3a7f6f7cef64 100644
--- a/drivers/usb/dwc2/hcd.c
+++ b/drivers/usb/dwc2/hcd.c
@@ -5077,13 +5077,12 @@ int dwc2_hcd_init(struct dwc2_hsotg *hsotg)
 	dev_dbg(hsotg->dev, "hcfg=%08x\n", hcfg);
 
 #ifdef CONFIG_USB_DWC2_TRACK_MISSED_SOFS
-	hsotg->frame_num_array = kzalloc(sizeof(*hsotg->frame_num_array) *
-					 FRAME_NUM_ARRAY_SIZE, GFP_KERNEL);
+	hsotg->frame_num_array = kzalloc(array_size(FRAME_NUM_ARRAY_SIZE, sizeof(*hsotg->frame_num_array)),
+					 GFP_KERNEL);
 	if (!hsotg->frame_num_array)
 		goto error1;
-	hsotg->last_frame_num_array = kzalloc(
-			sizeof(*hsotg->last_frame_num_array) *
-			FRAME_NUM_ARRAY_SIZE, GFP_KERNEL);
+	hsotg->last_frame_num_array = kzalloc(array_size(FRAME_NUM_ARRAY_SIZE, sizeof(*hsotg->last_frame_num_array)),
+					      GFP_KERNEL);
 	if (!hsotg->last_frame_num_array)
 		goto error1;
 #endif
diff --git a/drivers/usb/gadget/udc/bdc/bdc_ep.c b/drivers/usb/gadget/udc/bdc/bdc_ep.c
index 03149b9d7ea7..5ec898a79dfd 100644
--- a/drivers/usb/gadget/udc/bdc/bdc_ep.c
+++ b/drivers/usb/gadget/udc/bdc/bdc_ep.c
@@ -138,9 +138,8 @@ static int ep_bd_list_alloc(struct bdc_ep *ep)
 		__func__, ep, num_tabs);
 
 	/* Allocate memory for table array */
-	ep->bd_list.bd_table_array = kzalloc(
-					num_tabs * sizeof(struct bd_table *),
-					GFP_ATOMIC);
+	ep->bd_list.bd_table_array = kzalloc(array_size(num_tabs, sizeof(struct bd_table *)),
+					     GFP_ATOMIC);
 	if (!ep->bd_list.bd_table_array)
 		return -ENOMEM;
 
diff --git a/drivers/usb/host/fhci-tds.c b/drivers/usb/host/fhci-tds.c
index 3a4e8f616751..275293f7212b 100644
--- a/drivers/usb/host/fhci-tds.c
+++ b/drivers/usb/host/fhci-tds.c
@@ -189,7 +189,7 @@ u32 fhci_create_ep(struct fhci_usb *usb, enum fhci_mem_alloc data_mem,
 			goto err;
 		}
 
-		buff = kmalloc(1028 * sizeof(*buff), GFP_KERNEL);
+		buff = kmalloc(array_size(1028, sizeof(*buff)), GFP_KERNEL);
 		if (!buff) {
 			kfree(pkt);
 			err_for = "buffer";
diff --git a/drivers/usb/host/ohci-dbg.c b/drivers/usb/host/ohci-dbg.c
index ac7d4ac34b02..de7e249c1eef 100644
--- a/drivers/usb/host/ohci-dbg.c
+++ b/drivers/usb/host/ohci-dbg.c
@@ -492,7 +492,7 @@ static ssize_t fill_periodic_buffer(struct debug_buffer *buf)
 	char			*next;
 	unsigned		i;
 
-	seen = kmalloc(DBG_SCHED_LIMIT * sizeof *seen, GFP_ATOMIC);
+	seen = kmalloc(array_size(DBG_SCHED_LIMIT, sizeof(*seen)), GFP_ATOMIC);
 	if (!seen)
 		return 0;
 	seen_count = 0;
diff --git a/drivers/usb/host/xhci-mem.c b/drivers/usb/host/xhci-mem.c
index e5ace8995b3b..0b0d4893715e 100644
--- a/drivers/usb/host/xhci-mem.c
+++ b/drivers/usb/host/xhci-mem.c
@@ -633,9 +633,8 @@ struct xhci_stream_info *xhci_alloc_stream_info(struct xhci_hcd *xhci,
 	stream_info->num_stream_ctxs = num_stream_ctxs;
 
 	/* Initialize the array of virtual pointers to stream rings. */
-	stream_info->stream_rings = kzalloc(
-			sizeof(struct xhci_ring *)*num_streams,
-			mem_flags);
+	stream_info->stream_rings = kzalloc(array_size(num_streams, sizeof(struct xhci_ring *)),
+					    mem_flags);
 	if (!stream_info->stream_rings)
 		goto cleanup_info;
 
@@ -1652,7 +1651,8 @@ static int scratchpad_alloc(struct xhci_hcd *xhci, gfp_t flags)
 	if (!xhci->scratchpad->sp_array)
 		goto fail_sp2;
 
-	xhci->scratchpad->sp_buffers = kzalloc(sizeof(void *) * num_sp, flags);
+	xhci->scratchpad->sp_buffers = kzalloc(array_size(num_sp, sizeof(void *)),
+					       flags);
 	if (!xhci->scratchpad->sp_buffers)
 		goto fail_sp3;
 
@@ -2233,11 +2233,13 @@ static int xhci_setup_port_arrays(struct xhci_hcd *xhci, gfp_t flags)
 	u32 cap_start;
 
 	num_ports = HCS_MAX_PORTS(xhci->hcs_params1);
-	xhci->port_array = kzalloc(sizeof(*xhci->port_array)*num_ports, flags);
+	xhci->port_array = kzalloc(array_size(num_ports, sizeof(*xhci->port_array)),
+				   flags);
 	if (!xhci->port_array)
 		return -ENOMEM;
 
-	xhci->rh_bw = kzalloc(sizeof(*xhci->rh_bw)*num_ports, flags);
+	xhci->rh_bw = kzalloc(array_size(num_ports, sizeof(*xhci->rh_bw)),
+			      flags);
 	if (!xhci->rh_bw)
 		return -ENOMEM;
 	for (i = 0; i < num_ports; i++) {
@@ -2264,7 +2266,8 @@ static int xhci_setup_port_arrays(struct xhci_hcd *xhci, gfp_t flags)
 						      XHCI_EXT_CAPS_PROTOCOL);
 	}
 
-	xhci->ext_caps = kzalloc(sizeof(*xhci->ext_caps) * cap_count, flags);
+	xhci->ext_caps = kzalloc(array_size(cap_count, sizeof(*xhci->ext_caps)),
+				 flags);
 	if (!xhci->ext_caps)
 		return -ENOMEM;
 
diff --git a/drivers/usb/renesas_usbhs/mod_gadget.c b/drivers/usb/renesas_usbhs/mod_gadget.c
index 34ee9ebe12a3..46380dec3fd9 100644
--- a/drivers/usb/renesas_usbhs/mod_gadget.c
+++ b/drivers/usb/renesas_usbhs/mod_gadget.c
@@ -1068,7 +1068,8 @@ int usbhs_mod_gadget_probe(struct usbhs_priv *priv)
 	if (!gpriv)
 		return -ENOMEM;
 
-	uep = kzalloc(sizeof(struct usbhsg_uep) * pipe_size, GFP_KERNEL);
+	uep = kzalloc(array_size(pipe_size, sizeof(struct usbhsg_uep)),
+		      GFP_KERNEL);
 	if (!uep) {
 		ret = -ENOMEM;
 		goto usbhs_mod_gadget_probe_err_gpriv;
diff --git a/drivers/usb/renesas_usbhs/pipe.c b/drivers/usb/renesas_usbhs/pipe.c
index 9677e0e31475..8c5ceeb47dd3 100644
--- a/drivers/usb/renesas_usbhs/pipe.c
+++ b/drivers/usb/renesas_usbhs/pipe.c
@@ -803,7 +803,8 @@ int usbhs_pipe_probe(struct usbhs_priv *priv)
 		return -EINVAL;
 	}
 
-	info->pipe = kzalloc(sizeof(struct usbhs_pipe) * pipe_size, GFP_KERNEL);
+	info->pipe = kzalloc(array_size(pipe_size, sizeof(struct usbhs_pipe)),
+			     GFP_KERNEL);
 	if (!info->pipe)
 		return -ENOMEM;
 
diff --git a/drivers/usb/serial/iuu_phoenix.c b/drivers/usb/serial/iuu_phoenix.c
index 62c91e360baf..19d4f6576cdb 100644
--- a/drivers/usb/serial/iuu_phoenix.c
+++ b/drivers/usb/serial/iuu_phoenix.c
@@ -736,7 +736,7 @@ static int iuu_uart_on(struct usb_serial_port *port)
 	int status;
 	u8 *buf;
 
-	buf = kmalloc(sizeof(u8) * 4, GFP_KERNEL);
+	buf = kmalloc(array_size(4, sizeof(u8)), GFP_KERNEL);
 
 	if (!buf)
 		return -ENOMEM;
@@ -790,7 +790,7 @@ static int iuu_uart_baud(struct usb_serial_port *port, u32 baud_base,
 	unsigned int T1FrekvensHZ = 0;
 
 	dev_dbg(&port->dev, "%s - enter baud_base=%d\n", __func__, baud_base);
-	dataout = kmalloc(sizeof(u8) * 5, GFP_KERNEL);
+	dataout = kmalloc(array_size(5, sizeof(u8)), GFP_KERNEL);
 
 	if (!dataout)
 		return -ENOMEM;
diff --git a/drivers/usb/storage/sddr09.c b/drivers/usb/storage/sddr09.c
index 1cf7dbfe277c..8181a49f0e21 100644
--- a/drivers/usb/storage/sddr09.c
+++ b/drivers/usb/storage/sddr09.c
@@ -1231,8 +1231,10 @@ sddr09_read_map(struct us_data *us) {
 
 	kfree(info->lba_to_pba);
 	kfree(info->pba_to_lba);
-	info->lba_to_pba = kmalloc(numblocks*sizeof(int), GFP_NOIO);
-	info->pba_to_lba = kmalloc(numblocks*sizeof(int), GFP_NOIO);
+	info->lba_to_pba = kmalloc(array_size(numblocks, sizeof(int)),
+				   GFP_NOIO);
+	info->pba_to_lba = kmalloc(array_size(numblocks, sizeof(int)),
+				   GFP_NOIO);
 
 	if (info->lba_to_pba == NULL || info->pba_to_lba == NULL) {
 		printk(KERN_WARNING "sddr09_read_map: out of memory\n");
diff --git a/drivers/usb/storage/sddr55.c b/drivers/usb/storage/sddr55.c
index 8c814b2ec9b2..306fa78a026d 100644
--- a/drivers/usb/storage/sddr55.c
+++ b/drivers/usb/storage/sddr55.c
@@ -684,8 +684,10 @@ static int sddr55_read_map(struct us_data *us) {
 
 	kfree(info->lba_to_pba);
 	kfree(info->pba_to_lba);
-	info->lba_to_pba = kmalloc(numblocks*sizeof(int), GFP_NOIO);
-	info->pba_to_lba = kmalloc(numblocks*sizeof(int), GFP_NOIO);
+	info->lba_to_pba = kmalloc(array_size(numblocks, sizeof(int)),
+				   GFP_NOIO);
+	info->pba_to_lba = kmalloc(array_size(numblocks, sizeof(int)),
+				   GFP_NOIO);
 
 	if (info->lba_to_pba == NULL || info->pba_to_lba == NULL) {
 		kfree(info->lba_to_pba);
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 986058a57917..82c93acecaf0 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -269,8 +269,8 @@ static int vhost_net_set_ubuf_info(struct vhost_net *n)
 		zcopy = vhost_net_zcopy_mask & (0x1 << i);
 		if (!zcopy)
 			continue;
-		n->vqs[i].ubuf_info = kmalloc(sizeof(*n->vqs[i].ubuf_info) *
-					      UIO_MAXIOV, GFP_KERNEL);
+		n->vqs[i].ubuf_info = kmalloc(array_size(UIO_MAXIOV, sizeof(*n->vqs[i].ubuf_info)),
+					      GFP_KERNEL);
 		if  (!n->vqs[i].ubuf_info)
 			goto err;
 	}
@@ -927,7 +927,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	n = kvmalloc(sizeof *n, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
 	if (!n)
 		return -ENOMEM;
-	vqs = kmalloc(VHOST_NET_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
+	vqs = kmalloc(array_size(VHOST_NET_VQ_MAX, sizeof(*vqs)), GFP_KERNEL);
 	if (!vqs) {
 		kvfree(n);
 		return -ENOMEM;
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 7ad57094d736..20a3c8e87dc9 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1378,7 +1378,7 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 			goto err_vs;
 	}
 
-	vqs = kmalloc(VHOST_SCSI_MAX_VQ * sizeof(*vqs), GFP_KERNEL);
+	vqs = kmalloc(array_size(VHOST_SCSI_MAX_VQ, sizeof(*vqs)), GFP_KERNEL);
 	if (!vqs)
 		goto err_vqs;
 
@@ -1685,22 +1685,22 @@ static int vhost_scsi_nexus_cb(struct se_portal_group *se_tpg,
 	for (i = 0; i < VHOST_SCSI_DEFAULT_TAGS; i++) {
 		tv_cmd = &((struct vhost_scsi_cmd *)se_sess->sess_cmd_map)[i];
 
-		tv_cmd->tvc_sgl = kzalloc(sizeof(struct scatterlist) *
-					VHOST_SCSI_PREALLOC_SGLS, GFP_KERNEL);
+		tv_cmd->tvc_sgl = kzalloc(array_size(VHOST_SCSI_PREALLOC_SGLS, sizeof(struct scatterlist)),
+					  GFP_KERNEL);
 		if (!tv_cmd->tvc_sgl) {
 			pr_err("Unable to allocate tv_cmd->tvc_sgl\n");
 			goto out;
 		}
 
-		tv_cmd->tvc_upages = kzalloc(sizeof(struct page *) *
-				VHOST_SCSI_PREALLOC_UPAGES, GFP_KERNEL);
+		tv_cmd->tvc_upages = kzalloc(array_size(VHOST_SCSI_PREALLOC_UPAGES, sizeof(struct page *)),
+					     GFP_KERNEL);
 		if (!tv_cmd->tvc_upages) {
 			pr_err("Unable to allocate tv_cmd->tvc_upages\n");
 			goto out;
 		}
 
-		tv_cmd->tvc_prot_sgl = kzalloc(sizeof(struct scatterlist) *
-				VHOST_SCSI_PREALLOC_PROT_SGLS, GFP_KERNEL);
+		tv_cmd->tvc_prot_sgl = kzalloc(array_size(VHOST_SCSI_PREALLOC_PROT_SGLS, sizeof(struct scatterlist)),
+					       GFP_KERNEL);
 		if (!tv_cmd->tvc_prot_sgl) {
 			pr_err("Unable to allocate tv_cmd->tvc_prot_sgl\n");
 			goto out;
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index 906b8f0f19f7..c4db12a7a182 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -107,7 +107,7 @@ static int vhost_test_open(struct inode *inode, struct file *f)
 
 	if (!n)
 		return -ENOMEM;
-	vqs = kmalloc(VHOST_TEST_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
+	vqs = kmalloc(array_size(VHOST_TEST_VQ_MAX, sizeof(*vqs)), GFP_KERNEL);
 	if (!vqs) {
 		kfree(n);
 		return -ENOMEM;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index f3bd8e941224..4fea3adc6721 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -385,10 +385,12 @@ static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
 
 	for (i = 0; i < dev->nvqs; ++i) {
 		vq = dev->vqs[i];
-		vq->indirect = kmalloc(sizeof *vq->indirect * UIO_MAXIOV,
+		vq->indirect = kmalloc(array_size(UIO_MAXIOV, sizeof(*vq->indirect)),
 				       GFP_KERNEL);
-		vq->log = kmalloc(sizeof *vq->log * UIO_MAXIOV, GFP_KERNEL);
-		vq->heads = kmalloc(sizeof *vq->heads * UIO_MAXIOV, GFP_KERNEL);
+		vq->log = kmalloc(array_size(UIO_MAXIOV, sizeof(*vq->log)),
+				  GFP_KERNEL);
+		vq->heads = kmalloc(array_size(UIO_MAXIOV, sizeof(*vq->heads)),
+				    GFP_KERNEL);
 		if (!vq->indirect || !vq->log || !vq->heads)
 			goto err_nomem;
 	}
diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index bb8971f2a634..d87425e7fe31 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -191,7 +191,7 @@ static int resize_iovec(struct vringh_kiov *iov, gfp_t gfp)
 	if (flag)
 		new = krealloc(iov->iov, new_num * sizeof(struct iovec), gfp);
 	else {
-		new = kmalloc(new_num * sizeof(struct iovec), gfp);
+		new = kmalloc(array_size(new_num, sizeof(struct iovec)), gfp);
 		if (new) {
 			memcpy(new, iov->iov,
 			       iov->max_num * sizeof(struct iovec));
diff --git a/drivers/video/fbdev/broadsheetfb.c b/drivers/video/fbdev/broadsheetfb.c
index 9f9a7bef1ff6..59b89f8901e7 100644
--- a/drivers/video/fbdev/broadsheetfb.c
+++ b/drivers/video/fbdev/broadsheetfb.c
@@ -617,7 +617,8 @@ static int broadsheet_spiflash_rewrite_sector(struct broadsheetfb_par *par,
 	int tail_start_addr;
 	int start_sector_addr;
 
-	sector_buffer = kzalloc(sizeof(char)*sector_size, GFP_KERNEL);
+	sector_buffer = kzalloc(array_size(sector_size, sizeof(char)),
+				GFP_KERNEL);
 	if (!sector_buffer)
 		return -ENOMEM;
 
diff --git a/drivers/video/fbdev/core/fbcon_rotate.c b/drivers/video/fbdev/core/fbcon_rotate.c
index 8a51e4d95cc5..a6468416f547 100644
--- a/drivers/video/fbdev/core/fbcon_rotate.c
+++ b/drivers/video/fbdev/core/fbcon_rotate.c
@@ -46,7 +46,7 @@ static int fbcon_rotate_font(struct fb_info *info, struct vc_data *vc)
 		info->fbops->fb_sync(info);
 
 	if (ops->fd_size < d_cellsize * len) {
-		dst = kmalloc(d_cellsize * len, GFP_KERNEL);
+		dst = kmalloc(array_size(len, d_cellsize), GFP_KERNEL);
 
 		if (dst == NULL) {
 			err = -ENOMEM;
diff --git a/drivers/video/fbdev/core/fbmon.c b/drivers/video/fbdev/core/fbmon.c
index 2b2d67328514..24642cd9d25b 100644
--- a/drivers/video/fbdev/core/fbmon.c
+++ b/drivers/video/fbdev/core/fbmon.c
@@ -620,7 +620,8 @@ static struct fb_videomode *fb_create_modedb(unsigned char *edid, int *dbsize,
 	int num = 0, i, first = 1;
 	int ver, rev;
 
-	mode = kzalloc(50 * sizeof(struct fb_videomode), GFP_KERNEL);
+	mode = kzalloc(array_size(50, sizeof(struct fb_videomode)),
+		       GFP_KERNEL);
 	if (mode == NULL)
 		return NULL;
 
@@ -671,7 +672,7 @@ static struct fb_videomode *fb_create_modedb(unsigned char *edid, int *dbsize,
 	}
 
 	*dbsize = num;
-	m = kmalloc(num * sizeof(struct fb_videomode), GFP_KERNEL);
+	m = kmalloc(array_size(num, sizeof(struct fb_videomode)), GFP_KERNEL);
 	if (!m)
 		return mode;
 	memmove(m, mode, num * sizeof(struct fb_videomode));
diff --git a/drivers/video/fbdev/imxfb.c b/drivers/video/fbdev/imxfb.c
index ba82f97fb42b..45e0e8b084be 100644
--- a/drivers/video/fbdev/imxfb.c
+++ b/drivers/video/fbdev/imxfb.c
@@ -662,7 +662,8 @@ static int imxfb_init_fbinfo(struct platform_device *pdev)
 
 	pr_debug("%s\n",__func__);
 
-	info->pseudo_palette = kmalloc(sizeof(u32) * 16, GFP_KERNEL);
+	info->pseudo_palette = kmalloc(array_size(16, sizeof(u32)),
+				       GFP_KERNEL);
 	if (!info->pseudo_palette)
 		return -ENOMEM;
 
diff --git a/drivers/video/fbdev/mmp/fb/mmpfb.c b/drivers/video/fbdev/mmp/fb/mmpfb.c
index 92279e02dd94..3ef95828da35 100644
--- a/drivers/video/fbdev/mmp/fb/mmpfb.c
+++ b/drivers/video/fbdev/mmp/fb/mmpfb.c
@@ -493,8 +493,8 @@ static int modes_setup(struct mmpfb_info *fbi)
 		return 0;
 	}
 	/* put videomode list to info structure */
-	videomodes = kzalloc(sizeof(struct fb_videomode) * videomode_num,
-			GFP_KERNEL);
+	videomodes = kzalloc(array_size(videomode_num, sizeof(struct fb_videomode)),
+			     GFP_KERNEL);
 	if (!videomodes) {
 		dev_err(fbi->dev, "can't malloc video modes\n");
 		return -ENOMEM;
diff --git a/drivers/video/fbdev/omap2/omapfb/dss/manager.c b/drivers/video/fbdev/omap2/omapfb/dss/manager.c
index 69f86d2cc274..ec2e52fcdda6 100644
--- a/drivers/video/fbdev/omap2/omapfb/dss/manager.c
+++ b/drivers/video/fbdev/omap2/omapfb/dss/manager.c
@@ -42,8 +42,8 @@ int dss_init_overlay_managers(void)
 
 	num_managers = dss_feat_get_num_mgrs();
 
-	managers = kzalloc(sizeof(struct omap_overlay_manager) * num_managers,
-			GFP_KERNEL);
+	managers = kzalloc(array_size(num_managers, sizeof(struct omap_overlay_manager)),
+			   GFP_KERNEL);
 
 	BUG_ON(managers == NULL);
 
diff --git a/drivers/video/fbdev/omap2/omapfb/dss/overlay.c b/drivers/video/fbdev/omap2/omapfb/dss/overlay.c
index d6c5d75d2ef8..4905eded0160 100644
--- a/drivers/video/fbdev/omap2/omapfb/dss/overlay.c
+++ b/drivers/video/fbdev/omap2/omapfb/dss/overlay.c
@@ -59,8 +59,8 @@ void dss_init_overlays(struct platform_device *pdev)
 
 	num_overlays = dss_feat_get_num_ovls();
 
-	overlays = kzalloc(sizeof(struct omap_overlay) * num_overlays,
-			GFP_KERNEL);
+	overlays = kzalloc(array_size(num_overlays, sizeof(struct omap_overlay)),
+			   GFP_KERNEL);
 
 	BUG_ON(overlays == NULL);
 
diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
index a582d3ae7ac1..178c9d348467 100644
--- a/drivers/video/fbdev/pvr2fb.c
+++ b/drivers/video/fbdev/pvr2fb.c
@@ -682,7 +682,8 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
 
 	nr_pages = (count + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
-	pages = kmalloc(nr_pages * sizeof(struct page *), GFP_KERNEL);
+	pages = kmalloc(array_size(nr_pages, sizeof(struct page *)),
+			GFP_KERNEL);
 	if (!pages)
 		return -ENOMEM;
 
diff --git a/drivers/video/fbdev/uvesafb.c b/drivers/video/fbdev/uvesafb.c
index 73676eb0244a..889a3dee98e9 100644
--- a/drivers/video/fbdev/uvesafb.c
+++ b/drivers/video/fbdev/uvesafb.c
@@ -858,7 +858,7 @@ static int uvesafb_vbe_init_mode(struct fb_info *info)
 	 * Convert the modelist into a modedb so that we can use it with
 	 * fb_find_mode().
 	 */
-	mode = kzalloc(i * sizeof(*mode), GFP_KERNEL);
+	mode = kzalloc(array_size(i, sizeof(*mode)), GFP_KERNEL);
 	if (mode) {
 		i = 0;
 		list_for_each(pos, &info->modelist) {
diff --git a/drivers/video/fbdev/via/viafbdev.c b/drivers/video/fbdev/via/viafbdev.c
index badee04ef496..e708e24cc5d0 100644
--- a/drivers/video/fbdev/via/viafbdev.c
+++ b/drivers/video/fbdev/via/viafbdev.c
@@ -596,7 +596,8 @@ static int viafb_ioctl(struct fb_info *info, u_int cmd, u_long arg)
 		break;
 
 	case VIAFB_GET_GAMMA_LUT:
-		viafb_gamma_table = kmalloc(256 * sizeof(u32), GFP_KERNEL);
+		viafb_gamma_table = kmalloc(array_size(256, sizeof(u32)),
+					    GFP_KERNEL);
 		if (!viafb_gamma_table)
 			return -ENOMEM;
 		viafb_get_gamma_table(viafb_gamma_table);
diff --git a/drivers/video/fbdev/w100fb.c b/drivers/video/fbdev/w100fb.c
index 035ff6e02894..a71cfa861d57 100644
--- a/drivers/video/fbdev/w100fb.c
+++ b/drivers/video/fbdev/w100fb.c
@@ -693,7 +693,8 @@ int w100fb_probe(struct platform_device *pdev)
 		goto out;
 	}
 
-	info->pseudo_palette = kmalloc(sizeof (u32) * MAX_PALETTES, GFP_KERNEL);
+	info->pseudo_palette = kmalloc(array_size(MAX_PALETTES, sizeof(u32)),
+				       GFP_KERNEL);
 	if (!info->pseudo_palette) {
 		err = -ENOMEM;
 		goto out;
diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 4e05d7f711fe..5c7338f288fb 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -223,7 +223,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 	 * 'pages' is an array of struct page pointers that's initialized by
 	 * get_user_pages().
 	 */
-	pages = kzalloc(num_pages * sizeof(struct page *), GFP_KERNEL);
+	pages = kzalloc(array_size(num_pages, sizeof(struct page *)),
+			GFP_KERNEL);
 	if (!pages) {
 		pr_debug("fsl-hv: could not allocate page list\n");
 		return -ENOMEM;
diff --git a/drivers/virt/vboxguest/vboxguest_core.c b/drivers/virt/vboxguest/vboxguest_core.c
index 190dbf8cfcb5..9f0f2f26d6eb 100644
--- a/drivers/virt/vboxguest/vboxguest_core.c
+++ b/drivers/virt/vboxguest/vboxguest_core.c
@@ -262,7 +262,7 @@ static int vbg_balloon_inflate(struct vbg_dev *gdev, u32 chunk_idx)
 	struct page **pages;
 	int i, rc, ret;
 
-	pages = kmalloc(sizeof(*pages) * VMMDEV_MEMORY_BALLOON_CHUNK_PAGES,
+	pages = kmalloc(array_size(VMMDEV_MEMORY_BALLOON_CHUNK_PAGES, sizeof(*pages)),
 			GFP_KERNEL | __GFP_NOWARN);
 	if (!pages)
 		return -ENOMEM;
diff --git a/drivers/virtio/virtio_pci_common.c b/drivers/virtio/virtio_pci_common.c
index 48d4d1cf1cb6..0aa48dbf13fa 100644
--- a/drivers/virtio/virtio_pci_common.c
+++ b/drivers/virtio/virtio_pci_common.c
@@ -113,12 +113,12 @@ static int vp_request_msix_vectors(struct virtio_device *vdev, int nvectors,
 
 	vp_dev->msix_vectors = nvectors;
 
-	vp_dev->msix_names = kmalloc(nvectors * sizeof *vp_dev->msix_names,
+	vp_dev->msix_names = kmalloc(array_size(nvectors, sizeof(*vp_dev->msix_names)),
 				     GFP_KERNEL);
 	if (!vp_dev->msix_names)
 		goto error;
 	vp_dev->msix_affinity_masks
-		= kzalloc(nvectors * sizeof *vp_dev->msix_affinity_masks,
+		= kzalloc(array_size(nvectors, sizeof(*vp_dev->msix_affinity_masks)),
 			  GFP_KERNEL);
 	if (!vp_dev->msix_affinity_masks)
 		goto error;
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 21d464a29cf8..87053be9e6b6 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -247,7 +247,7 @@ static struct vring_desc *alloc_indirect(struct virtqueue *_vq,
 	 */
 	gfp &= ~__GFP_HIGHMEM;
 
-	desc = kmalloc(total_sg * sizeof(struct vring_desc), gfp);
+	desc = kmalloc(array_size(total_sg, sizeof(struct vring_desc)), gfp);
 	if (!desc)
 		return NULL;
 
diff --git a/drivers/xen/arm-device.c b/drivers/xen/arm-device.c
index 85dd20e05726..6c38f7ede8c2 100644
--- a/drivers/xen/arm-device.c
+++ b/drivers/xen/arm-device.c
@@ -70,9 +70,10 @@ static int xen_map_device_mmio(const struct resource *resources,
 		if ((resource_type(r) != IORESOURCE_MEM) || (nr == 0))
 			continue;
 
-		gpfns = kzalloc(sizeof(xen_pfn_t) * nr, GFP_KERNEL);
-		idxs = kzalloc(sizeof(xen_ulong_t) * nr, GFP_KERNEL);
-		errs = kzalloc(sizeof(int) * nr, GFP_KERNEL);
+		gpfns = kzalloc(array_size(nr, sizeof(xen_pfn_t)), GFP_KERNEL);
+		idxs = kzalloc(array_size(nr, sizeof(xen_ulong_t)),
+			       GFP_KERNEL);
+		errs = kzalloc(array_size(nr, sizeof(int)), GFP_KERNEL);
 		if (!gpfns || !idxs || !errs) {
 			kfree(gpfns);
 			kfree(idxs);
diff --git a/drivers/xen/evtchn.c b/drivers/xen/evtchn.c
index 8cac07ab60ab..7df056308338 100644
--- a/drivers/xen/evtchn.c
+++ b/drivers/xen/evtchn.c
@@ -322,7 +322,8 @@ static int evtchn_resize_ring(struct per_user_data *u)
 	else
 		new_size = 2 * u->ring_size;
 
-	new_ring = kvmalloc(new_size * sizeof(*new_ring), GFP_KERNEL);
+	new_ring = kvmalloc(array_size(new_size, sizeof(*new_ring)),
+			    GFP_KERNEL);
 	if (!new_ring)
 		return -ENOMEM;
 
diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index 27be107d6480..c3376059ef54 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -1137,7 +1137,8 @@ static int gnttab_map(unsigned int start_idx, unsigned int end_idx)
 	/* No need for kzalloc as it is initialized in following hypercall
 	 * GNTTABOP_setup_table.
 	 */
-	frames = kmalloc(nr_gframes * sizeof(unsigned long), GFP_ATOMIC);
+	frames = kmalloc(array_size(nr_gframes, sizeof(unsigned long)),
+			 GFP_ATOMIC);
 	if (!frames)
 		return -ENOMEM;
 
@@ -1300,7 +1301,7 @@ int gnttab_init(void)
 	max_nr_glist_frames = (max_nr_grant_frames *
 			       gnttab_interface->grefs_per_grant_frame / RPP);
 
-	gnttab_list = kmalloc(max_nr_glist_frames * sizeof(grant_ref_t *),
+	gnttab_list = kmalloc(array_size(max_nr_glist_frames, sizeof(grant_ref_t *)),
 			      GFP_KERNEL);
 	if (gnttab_list == NULL)
 		return -ENOMEM;
diff --git a/fs/9p/fid.c b/fs/9p/fid.c
index ed4f8519b627..9966ada52d75 100644
--- a/fs/9p/fid.c
+++ b/fs/9p/fid.c
@@ -100,7 +100,7 @@ static int build_path_from_dentry(struct v9fs_session_info *v9ses,
 	for (ds = dentry; !IS_ROOT(ds); ds = ds->d_parent)
 		n++;
 
-	wnames = kmalloc(sizeof(char *) * n, GFP_KERNEL);
+	wnames = kmalloc(array_size(n, sizeof(char *)), GFP_KERNEL);
 	if (!wnames)
 		goto err_out;
 
diff --git a/fs/adfs/super.c b/fs/adfs/super.c
index cfda2c7caedc..0004715f0e94 100644
--- a/fs/adfs/super.c
+++ b/fs/adfs/super.c
@@ -313,7 +313,7 @@ static struct adfs_discmap *adfs_read_map(struct super_block *sb, struct adfs_di
 
 	asb->s_ids_per_zone = zone_size / (asb->s_idlen + 1);
 
-	dm = kmalloc(nzones * sizeof(*dm), GFP_KERNEL);
+	dm = kmalloc(array_size(nzones, sizeof(*dm)), GFP_KERNEL);
 	if (dm == NULL) {
 		adfs_error(sb, "not enough memory");
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 357de908df3a..b2c9728f8164 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -355,7 +355,8 @@ static int afs_deliver_cb_init_call_back_state3(struct afs_call *call)
 	switch (call->unmarshall) {
 	case 0:
 		call->offset = 0;
-		call->buffer = kmalloc(11 * sizeof(__be32), GFP_KERNEL);
+		call->buffer = kmalloc(array_size(11, sizeof(__be32)),
+				       GFP_KERNEL);
 		if (!call->buffer)
 			return -ENOMEM;
 		call->unmarshall++;
@@ -478,7 +479,8 @@ static int afs_deliver_cb_probe_uuid(struct afs_call *call)
 	switch (call->unmarshall) {
 	case 0:
 		call->offset = 0;
-		call->buffer = kmalloc(11 * sizeof(__be32), GFP_KERNEL);
+		call->buffer = kmalloc(array_size(11, sizeof(__be32)),
+				       GFP_KERNEL);
 		if (!call->buffer)
 			return -ENOMEM;
 		call->unmarshall++;
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 4ad6f669fe34..b65133a6264e 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -2010,7 +2010,8 @@ static int elf_note_info_init(struct elf_note_info *info)
 	INIT_LIST_HEAD(&info->thread_list);
 
 	/* Allocate space for ELF notes */
-	info->notes = kmalloc(8 * sizeof(struct memelfnote), GFP_KERNEL);
+	info->notes = kmalloc(array_size(8, sizeof(struct memelfnote)),
+			      GFP_KERNEL);
 	if (!info->notes)
 		return 0;
 	info->psinfo = kmalloc(sizeof(*info->psinfo), GFP_KERNEL);
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index d90993adeffa..59e2f5442c50 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1600,7 +1600,8 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	psinfo = kmalloc(sizeof(*psinfo), GFP_KERNEL);
 	if (!psinfo)
 		goto cleanup;
-	notes = kmalloc(NUM_NOTES * sizeof(struct memelfnote), GFP_KERNEL);
+	notes = kmalloc(array_size(NUM_NOTES, sizeof(struct memelfnote)),
+			GFP_KERNEL);
 	if (!notes)
 		goto cleanup;
 	fpu = kmalloc(sizeof(*fpu), GFP_KERNEL);
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 7ec920e27065..4d34db5ac9c3 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -205,7 +205,8 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	if (nr_pages <= DIO_INLINE_BIO_VECS)
 		vecs = inline_vecs;
 	else {
-		vecs = kmalloc(nr_pages * sizeof(struct bio_vec), GFP_KERNEL);
+		vecs = kmalloc(array_size(nr_pages, sizeof(struct bio_vec)),
+			       GFP_KERNEL);
 		if (!vecs)
 			return -ENOMEM;
 	}
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 5f7ad3d0df2e..d5c6825fb2b7 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -370,7 +370,7 @@ static int start_read(struct inode *inode, struct ceph_rw_context *rw_ctx,
 
 	/* build page vector */
 	nr_pages = calc_pages_for(0, len);
-	pages = kmalloc(sizeof(*pages) * nr_pages, GFP_KERNEL);
+	pages = kmalloc(array_size(nr_pages, sizeof(*pages)), GFP_KERNEL);
 	if (!pages) {
 		ret = -ENOMEM;
 		goto out_put;
@@ -966,7 +966,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 
 				BUG_ON(pages);
 				max_pages = calc_pages_for(0, (u64)len);
-				pages = kmalloc(max_pages * sizeof (*pages),
+				pages = kmalloc(array_size(max_pages, sizeof(*pages)),
 						GFP_NOFS);
 				if (!pages) {
 					pool = fsc->wb_pagevec_pool;
@@ -1113,7 +1113,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 
 			/* allocate new pages array for next request */
 			data_pages = pages;
-			pages = kmalloc(locked_pages * sizeof (*pages),
+			pages = kmalloc(array_size(locked_pages, sizeof(*pages)),
 					GFP_NOFS);
 			if (!pages) {
 				pool = fsc->wb_pagevec_pool;
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index f85040d73e3d..467bdb1762f0 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -109,7 +109,7 @@ dio_get_pages_alloc(const struct iov_iter *it, size_t nbytes,
 	align = (unsigned long)(it->iov->iov_base + it->iov_offset) &
 		(PAGE_SIZE - 1);
 	npages = calc_pages_for(align, nbytes);
-	pages = kvmalloc(sizeof(*pages) * npages, GFP_KERNEL);
+	pages = kvmalloc(array_size(npages, sizeof(*pages)), GFP_KERNEL);
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/fs/cifs/asn1.c b/fs/cifs/asn1.c
index a3b56544c21b..385d21212c5a 100644
--- a/fs/cifs/asn1.c
+++ b/fs/cifs/asn1.c
@@ -428,7 +428,7 @@ asn1_oid_decode(struct asn1_ctx *ctx,
 	if (size < 2 || size > UINT_MAX/sizeof(unsigned long))
 		return 0;
 
-	*oid = kmalloc(size * sizeof(unsigned long), GFP_ATOMIC);
+	*oid = kmalloc(array_size(size, sizeof(unsigned long)), GFP_ATOMIC);
 	if (*oid == NULL)
 		return 0;
 
diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index 13a8a77322c9..c15aea7d712f 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -747,7 +747,7 @@ static void parse_dacl(struct cifs_acl *pdacl, char *end_of_acl,
 
 		if (num_aces > ULONG_MAX / sizeof(struct cifs_ace *))
 			return;
-		ppace = kmalloc(num_aces * sizeof(struct cifs_ace *),
+		ppace = kmalloc(array_size(num_aces, sizeof(struct cifs_ace *)),
 				GFP_KERNEL);
 		if (!ppace)
 			return;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 3c371f7f5963..128342aa4ee9 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1791,8 +1791,8 @@ cifs_rename2(struct inode *source_dir, struct dentry *source_dentry,
 		 * with unix extensions enabled.
 		 */
 		info_buf_source =
-			kmalloc(2 * sizeof(FILE_UNIX_BASIC_INFO),
-					GFP_KERNEL);
+			kmalloc(array_size(2, sizeof(FILE_UNIX_BASIC_INFO)),
+				GFP_KERNEL);
 		if (info_buf_source == NULL) {
 			rc = -ENOMEM;
 			goto cifs_rename_exit;
diff --git a/fs/cifs/smb2pdu.c b/fs/cifs/smb2pdu.c
index 0f044c4a2dc9..987efc0d5f54 100644
--- a/fs/cifs/smb2pdu.c
+++ b/fs/cifs/smb2pdu.c
@@ -3319,7 +3319,7 @@ send_set_info(const unsigned int xid, struct cifs_tcon *tcon,
 	if (!num)
 		return -EINVAL;
 
-	iov = kmalloc(sizeof(struct kvec) * num, GFP_KERNEL);
+	iov = kmalloc(array_size(num, sizeof(struct kvec)), GFP_KERNEL);
 	if (!iov)
 		return -ENOMEM;
 
@@ -3380,7 +3380,7 @@ SMB2_rename(const unsigned int xid, struct cifs_tcon *tcon,
 	int rc;
 	int len = (2 * UniStrnlen((wchar_t *)target_file, PATH_MAX));
 
-	data = kmalloc(sizeof(void *) * 2, GFP_KERNEL);
+	data = kmalloc(array_size(2, sizeof(void *)), GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
@@ -3428,7 +3428,7 @@ SMB2_set_hardlink(const unsigned int xid, struct cifs_tcon *tcon,
 	int rc;
 	int len = (2 * UniStrnlen((wchar_t *)target_file, PATH_MAX));
 
-	data = kmalloc(sizeof(void *) * 2, GFP_KERNEL);
+	data = kmalloc(array_size(2, sizeof(void *)), GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 0ac62811b341..30eae1ccafab 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -110,7 +110,7 @@ static int pcol_try_alloc(struct page_collect *pcol)
 	pages =  exofs_max_io_pages(&pcol->sbi->layout, pcol->expected_pages);
 
 	for (; pages; pages >>= 1) {
-		pcol->pages = kmalloc(pages * sizeof(struct page *),
+		pcol->pages = kmalloc(array_size(pages, sizeof(struct page *)),
 				      GFP_KERNEL);
 		if (likely(pcol->pages)) {
 			pcol->alloc_pages = pages;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index de1694512f1f..6c784acceb6a 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -1083,7 +1083,8 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
  					/ EXT2_BLOCKS_PER_GROUP(sb)) + 1;
 	db_count = (sbi->s_groups_count + EXT2_DESC_PER_BLOCK(sb) - 1) /
 		   EXT2_DESC_PER_BLOCK(sb);
-	sbi->s_group_desc = kmalloc (db_count * sizeof (struct buffer_head *), GFP_KERNEL);
+	sbi->s_group_desc = kmalloc(array_size(db_count, sizeof(struct buffer_head *)),
+				    GFP_KERNEL);
 	if (sbi->s_group_desc == NULL) {
 		ext2_msg(sb, KERN_ERR, "error: not enough memory");
 		goto failed_mount;
diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 0a7315961bac..37deae1bbad3 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -1063,7 +1063,7 @@ static int ext4_ext_split(handle_t *handle, struct inode *inode,
 	 * We need this to handle errors and free blocks
 	 * upon them.
 	 */
-	ablocks = kzalloc(sizeof(ext4_fsblk_t) * depth, GFP_NOFS);
+	ablocks = kzalloc(array_size(depth, sizeof(ext4_fsblk_t)), GFP_NOFS);
 	if (!ablocks)
 		return -ENOMEM;
 
diff --git a/fs/ext4/resize.c b/fs/ext4/resize.c
index b6bec270a8e4..d5640ca8c499 100644
--- a/fs/ext4/resize.c
+++ b/fs/ext4/resize.c
@@ -204,12 +204,13 @@ static struct ext4_new_flex_group_data *alloc_flex_gd(unsigned long flexbg_size)
 		goto out2;
 	flex_gd->count = flexbg_size;
 
-	flex_gd->groups = kmalloc(sizeof(struct ext4_new_group_data) *
-				  flexbg_size, GFP_NOFS);
+	flex_gd->groups = kmalloc(array_size(flexbg_size, sizeof(struct ext4_new_group_data)),
+				  GFP_NOFS);
 	if (flex_gd->groups == NULL)
 		goto out2;
 
-	flex_gd->bg_flags = kmalloc(flexbg_size * sizeof(__u16), GFP_NOFS);
+	flex_gd->bg_flags = kmalloc(array_size(flexbg_size, sizeof(__u16)),
+				    GFP_NOFS);
 	if (flex_gd->bg_flags == NULL)
 		goto out1;
 
@@ -969,7 +970,8 @@ static int reserve_backup_gdb(handle_t *handle, struct inode *inode,
 	int res, i;
 	int err;
 
-	primary = kmalloc(reserved_gdb * sizeof(*primary), GFP_NOFS);
+	primary = kmalloc(array_size(reserved_gdb, sizeof(*primary)),
+			  GFP_NOFS);
 	if (!primary)
 		return -ENOMEM;
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 185f7e61f4cf..2395bda3cc46 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -3970,9 +3970,8 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			goto failed_mount;
 		}
 	}
-	sbi->s_group_desc = kvmalloc(db_count *
-					  sizeof(struct buffer_head *),
-					  GFP_KERNEL);
+	sbi->s_group_desc = kvmalloc(array_size(db_count, sizeof(struct buffer_head *)),
+				     GFP_KERNEL);
 	if (sbi->s_group_desc == NULL) {
 		ext4_msg(sb, KERN_ERR, "not enough memory");
 		ret = -ENOMEM;
diff --git a/fs/fat/namei_vfat.c b/fs/fat/namei_vfat.c
index 2649759c478a..352b35bd5d55 100644
--- a/fs/fat/namei_vfat.c
+++ b/fs/fat/namei_vfat.c
@@ -664,7 +664,7 @@ static int vfat_add_entry(struct inode *dir, const struct qstr *qname,
 	if (len == 0)
 		return -ENOENT;
 
-	slots = kmalloc(sizeof(*slots) * MSDOS_SLOTS, GFP_NOFS);
+	slots = kmalloc(array_size(MSDOS_SLOTS, sizeof(*slots)), GFP_NOFS);
 	if (slots == NULL)
 		return -ENOMEM;
 
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 5d06384c2cae..947e64abb95d 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -64,9 +64,10 @@ static struct fuse_req *__fuse_request_alloc(unsigned npages, gfp_t flags)
 			pages = req->inline_pages;
 			page_descs = req->inline_page_descs;
 		} else {
-			pages = kmalloc(sizeof(struct page *) * npages, flags);
-			page_descs = kmalloc(sizeof(struct fuse_page_desc) *
-					     npages, flags);
+			pages = kmalloc(array_size(npages, sizeof(struct page *)),
+					flags);
+			page_descs = kmalloc(array_size(npages, sizeof(struct fuse_page_desc)),
+					     flags);
 		}
 
 		if (!pages || !page_descs) {
diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
index d9fb0ad6cc30..d68bf63af8b8 100644
--- a/fs/gfs2/dir.c
+++ b/fs/gfs2/dir.c
@@ -1055,7 +1055,7 @@ static int dir_split_leaf(struct inode *inode, const struct qstr *name)
 	/* Change the pointers.
 	   Don't bother distinguishing stuffed from non-stuffed.
 	   This code is complicated enough already. */
-	lp = kmalloc(half_len * sizeof(__be64), GFP_NOFS);
+	lp = kmalloc(array_size(half_len, sizeof(__be64)), GFP_NOFS);
 	if (!lp) {
 		error = -ENOMEM;
 		goto fail_brelse;
@@ -1596,7 +1596,7 @@ int gfs2_dir_read(struct inode *inode, struct dir_context *ctx,
 
 	error = -ENOMEM;
 	/* 96 is max number of dirents which can be stuffed into an inode */
-	darr = kmalloc(96 * sizeof(struct gfs2_dirent *), GFP_NOFS);
+	darr = kmalloc(array_size(96, sizeof(struct gfs2_dirent *)), GFP_NOFS);
 	if (darr) {
 		g.pdent = (const struct gfs2_dirent **)darr;
 		g.offset = 0;
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 097bd3c0f270..399b16928a41 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1303,7 +1303,8 @@ int gfs2_glock_nq_m(unsigned int num_gh, struct gfs2_holder *ghs)
 	default:
 		if (num_gh <= 4)
 			break;
-		pph = kmalloc(num_gh * sizeof(struct gfs2_holder *), GFP_NOFS);
+		pph = kmalloc(array_size(num_gh, sizeof(struct gfs2_holder *)),
+			      GFP_NOFS);
 		if (!pph)
 			return -ENOMEM;
 	}
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 7a98abd340ee..824cc96cea09 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -883,7 +883,8 @@ static int do_sync(unsigned int num_qd, struct gfs2_quota_data **qda)
 	gfs2_write_calc_reserv(ip, sizeof(struct gfs2_quota),
 			      &data_blocks, &ind_blocks);
 
-	ghs = kmalloc(num_qd * sizeof(struct gfs2_holder), GFP_NOFS);
+	ghs = kmalloc(array_size(num_qd, sizeof(struct gfs2_holder)),
+		      GFP_NOFS);
 	if (!ghs)
 		return -ENOMEM;
 
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index cf5c7f3080d2..467fc8472690 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -1097,7 +1097,8 @@ static int gfs2_statfs_slow(struct gfs2_sbd *sdp, struct gfs2_statfs_change_host
 	int error = 0, err;
 
 	memset(sc, 0, sizeof(struct gfs2_statfs_change_host));
-	gha = kmalloc(slots * sizeof(struct gfs2_holder), GFP_KERNEL);
+	gha = kmalloc(array_size(slots, sizeof(struct gfs2_holder)),
+		      GFP_KERNEL);
 	if (!gha)
 		return -ENOMEM;
 	for (x = 0; x < slots; x++)
diff --git a/fs/jbd2/revoke.c b/fs/jbd2/revoke.c
index 696ef15ec942..a8343b46d546 100644
--- a/fs/jbd2/revoke.c
+++ b/fs/jbd2/revoke.c
@@ -227,7 +227,8 @@ static struct jbd2_revoke_table_s *jbd2_journal_init_revoke_table(int hash_size)
 	table->hash_size = hash_size;
 	table->hash_shift = shift;
 	table->hash_table =
-		kmalloc(hash_size * sizeof(struct list_head), GFP_KERNEL);
+		kmalloc(array_size(hash_size, sizeof(struct list_head)),
+			GFP_KERNEL);
 	if (!table->hash_table) {
 		kmem_cache_free(jbd2_revoke_table_cache, table);
 		table = NULL;
diff --git a/fs/jfs/jfs_dmap.c b/fs/jfs/jfs_dmap.c
index 2d514c7affc2..1b536e6e0c36 100644
--- a/fs/jfs/jfs_dmap.c
+++ b/fs/jfs/jfs_dmap.c
@@ -1641,7 +1641,8 @@ s64 dbDiscardAG(struct inode *ip, int agno, s64 minlen)
 	max_ranges = nblocks;
 	do_div(max_ranges, minlen);
 	range_cnt = min_t(u64, max_ranges + 1, 32 * 1024);
-	totrim = kmalloc(sizeof(struct range2trim) * range_cnt, GFP_NOFS);
+	totrim = kmalloc(array_size(range_cnt, sizeof(struct range2trim)),
+			 GFP_NOFS);
 	if (totrim == NULL) {
 		jfs_error(bmp->db_ipbmap->i_sb, "no memory for trim array\n");
 		IWRITE_UNLOCK(ipbmap);
diff --git a/fs/mbcache.c b/fs/mbcache.c
index bf41e2e72c18..9cf5cd890cb6 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -353,7 +353,7 @@ struct mb_cache *mb_cache_create(int bucket_bits)
 	cache->c_max_entries = bucket_count << 4;
 	INIT_LIST_HEAD(&cache->c_list);
 	spin_lock_init(&cache->c_list_lock);
-	cache->c_hash = kmalloc(bucket_count * sizeof(struct hlist_bl_head),
+	cache->c_hash = kmalloc(array_size(bucket_count, sizeof(struct hlist_bl_head)),
 				GFP_KERNEL);
 	if (!cache->c_hash) {
 		kfree(cache);
diff --git a/fs/namei.c b/fs/namei.c
index 186bd2464fd5..5fd5c1b162d1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -537,13 +537,13 @@ static int __nd_alloc_stack(struct nameidata *nd)
 	struct saved *p;
 
 	if (nd->flags & LOOKUP_RCU) {
-		p= kmalloc(MAXSYMLINKS * sizeof(struct saved),
-				  GFP_ATOMIC);
+		p= kmalloc(array_size(MAXSYMLINKS, sizeof(struct saved)),
+			   GFP_ATOMIC);
 		if (unlikely(!p))
 			return -ECHILD;
 	} else {
-		p= kmalloc(MAXSYMLINKS * sizeof(struct saved),
-				  GFP_KERNEL);
+		p= kmalloc(array_size(MAXSYMLINKS, sizeof(struct saved)),
+			   GFP_KERNEL);
 		if (unlikely(!p))
 			return -ENOMEM;
 	}
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c75ad982bcfc..4cbf6dd84786 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -461,7 +461,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		fh_count = be32_to_cpup(p);
 
 		fls->mirror_array[i]->fh_versions =
-			kzalloc(fh_count * sizeof(struct nfs_fh),
+			kzalloc(array_size(fh_count, sizeof(struct nfs_fh)),
 				gfp_flags);
 		if (fls->mirror_array[i]->fh_versions == NULL) {
 			rc = -ENOMEM;
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index d62279d3fc5d..bf4854e9c346 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -99,7 +99,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	version_count = be32_to_cpup(p);
 	dprintk("%s: version count %d\n", __func__, version_count);
 
-	ds_versions = kzalloc(version_count * sizeof(struct nfs4_ff_ds_version),
+	ds_versions = kzalloc(array_size(version_count, sizeof(struct nfs4_ff_ds_version)),
 			      gfp_flags);
 	if (!ds_versions)
 		goto out_scratch;
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 66eaeb1e8c2c..74ffa4eb93c5 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -510,8 +510,8 @@ nfs4_legacy_state_init(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int i;
 
-	nn->reclaim_str_hashtbl = kmalloc(sizeof(struct list_head) *
-					  CLIENT_HASH_SIZE, GFP_KERNEL);
+	nn->reclaim_str_hashtbl = kmalloc(array_size(CLIENT_HASH_SIZE, sizeof(struct list_head)),
+					  GFP_KERNEL);
 	if (!nn->reclaim_str_hashtbl)
 		return -ENOMEM;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc74d6f46bd5..70af7b8c2789 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1807,8 +1807,8 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 	clp->cl_name.data = kmemdup(name.data, name.len, GFP_KERNEL);
 	if (clp->cl_name.data == NULL)
 		goto err_no_name;
-	clp->cl_ownerstr_hashtbl = kmalloc(sizeof(struct list_head) *
-			OWNER_HASH_SIZE, GFP_KERNEL);
+	clp->cl_ownerstr_hashtbl = kmalloc(array_size(OWNER_HASH_SIZE, sizeof(struct list_head)),
+					   GFP_KERNEL);
 	if (!clp->cl_ownerstr_hashtbl)
 		goto err_no_hashtbl;
 	for (i = 0; i < OWNER_HASH_SIZE; i++)
@@ -7093,16 +7093,16 @@ static int nfs4_state_create_net(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int i;
 
-	nn->conf_id_hashtbl = kmalloc(sizeof(struct list_head) *
-			CLIENT_HASH_SIZE, GFP_KERNEL);
+	nn->conf_id_hashtbl = kmalloc(array_size(CLIENT_HASH_SIZE, sizeof(struct list_head)),
+				      GFP_KERNEL);
 	if (!nn->conf_id_hashtbl)
 		goto err;
-	nn->unconf_id_hashtbl = kmalloc(sizeof(struct list_head) *
-			CLIENT_HASH_SIZE, GFP_KERNEL);
+	nn->unconf_id_hashtbl = kmalloc(array_size(CLIENT_HASH_SIZE, sizeof(struct list_head)),
+					GFP_KERNEL);
 	if (!nn->unconf_id_hashtbl)
 		goto err_unconf_id;
-	nn->sessionid_hashtbl = kmalloc(sizeof(struct list_head) *
-			SESSION_HASH_SIZE, GFP_KERNEL);
+	nn->sessionid_hashtbl = kmalloc(array_size(SESSION_HASH_SIZE, sizeof(struct list_head)),
+					GFP_KERNEL);
 	if (!nn->sessionid_hashtbl)
 		goto err_sessionid;
 
diff --git a/fs/ntfs/compress.c b/fs/ntfs/compress.c
index f8eb04387ca4..4de21fc801ee 100644
--- a/fs/ntfs/compress.c
+++ b/fs/ntfs/compress.c
@@ -527,7 +527,7 @@ int ntfs_read_compressed_block(struct page *page)
 	BUG_ON(ni->type != AT_DATA);
 	BUG_ON(ni->name_len);
 
-	pages = kmalloc(nr_pages * sizeof(struct page *), GFP_NOFS);
+	pages = kmalloc(array_size(nr_pages, sizeof(struct page *)), GFP_NOFS);
 
 	/* Allocate memory to store the buffer heads we need. */
 	bhs_size = cb_size / block_size * sizeof(struct buffer_head *);
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index e5076185cc1e..5981a9245f29 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -1078,7 +1078,7 @@ int o2net_send_message_vec(u32 msg_type, u32 key, struct kvec *caller_vec,
 	o2net_set_nst_sock_container(&nst, sc);
 
 	veclen = caller_veclen + 1;
-	vec = kmalloc(sizeof(struct kvec) * veclen, GFP_ATOMIC);
+	vec = kmalloc(array_size(veclen, sizeof(struct kvec)), GFP_ATOMIC);
 	if (vec == NULL) {
 		mlog(0, "failed to %zu element kvec!\n", veclen);
 		ret = -ENOMEM;
diff --git a/fs/ocfs2/dlm/dlmdomain.c b/fs/ocfs2/dlm/dlmdomain.c
index 425081be6161..a37e76e40b43 100644
--- a/fs/ocfs2/dlm/dlmdomain.c
+++ b/fs/ocfs2/dlm/dlmdomain.c
@@ -86,7 +86,7 @@ static void dlm_free_pagevec(void **vec, int pages)
 
 static void **dlm_alloc_pagevec(int pages)
 {
-	void **vec = kmalloc(pages * sizeof(void *), GFP_KERNEL);
+	void **vec = kmalloc(array_size(pages, sizeof(void *)), GFP_KERNEL);
 	int i;
 
 	if (!vec)
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1b2ede6abcdf..44bbe9db0e68 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -432,7 +432,8 @@ static int proc_pid_stack(struct seq_file *m, struct pid_namespace *ns,
 	int err;
 	int i;
 
-	entries = kmalloc(MAX_STACK_TRACE_DEPTH * sizeof(*entries), GFP_KERNEL);
+	entries = kmalloc(array_size(MAX_STACK_TRACE_DEPTH, sizeof(*entries)),
+			  GFP_KERNEL);
 	if (!entries)
 		return -ENOMEM;
 
diff --git a/fs/read_write.c b/fs/read_write.c
index c4eabbfc90df..d75e8bcd7f78 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -778,7 +778,8 @@ ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 		goto out;
 	}
 	if (nr_segs > fast_segs) {
-		iov = kmalloc(nr_segs*sizeof(struct iovec), GFP_KERNEL);
+		iov = kmalloc(array_size(nr_segs, sizeof(struct iovec)),
+			      GFP_KERNEL);
 		if (iov == NULL) {
 			ret = -ENOMEM;
 			goto out;
@@ -849,7 +850,8 @@ ssize_t compat_rw_copy_check_uvector(int type,
 		goto out;
 	if (nr_segs > fast_segs) {
 		ret = -ENOMEM;
-		iov = kmalloc(nr_segs*sizeof(struct iovec), GFP_KERNEL);
+		iov = kmalloc(array_size(nr_segs, sizeof(struct iovec)),
+			      GFP_KERNEL);
 		if (iov == NULL)
 			goto out;
 	}
diff --git a/fs/splice.c b/fs/splice.c
index 005d09cf3fa8..ec9b2e4a0743 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -259,8 +259,10 @@ int splice_grow_spd(const struct pipe_inode_info *pipe, struct splice_pipe_desc
 	if (buffers <= PIPE_DEF_BUFFERS)
 		return 0;
 
-	spd->pages = kmalloc(buffers * sizeof(struct page *), GFP_KERNEL);
-	spd->partial = kmalloc(buffers * sizeof(struct partial_page), GFP_KERNEL);
+	spd->pages = kmalloc(array_size(buffers, sizeof(struct page *)),
+			     GFP_KERNEL);
+	spd->partial = kmalloc(array_size(buffers, sizeof(struct partial_page)),
+			       GFP_KERNEL);
 
 	if (spd->pages && spd->partial)
 		return 0;
@@ -395,7 +397,8 @@ static ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 
 	vec = __vec;
 	if (nr_pages > PIPE_DEF_BUFFERS) {
-		vec = kmalloc(nr_pages * sizeof(struct kvec), GFP_KERNEL);
+		vec = kmalloc(array_size(nr_pages, sizeof(struct kvec)),
+			      GFP_KERNEL);
 		if (unlikely(!vec)) {
 			res = -ENOMEM;
 			goto out;
diff --git a/fs/ubifs/journal.c b/fs/ubifs/journal.c
index 04c4ec6483e5..52563f6877ba 100644
--- a/fs/ubifs/journal.c
+++ b/fs/ubifs/journal.c
@@ -1286,7 +1286,7 @@ static int truncate_data_node(const struct ubifs_info *c, const struct inode *in
 	int err, dlen, compr_type, out_len, old_dlen;
 
 	out_len = le32_to_cpu(dn->size);
-	buf = kmalloc(out_len * WORST_COMPR_FACTOR, GFP_NOFS);
+	buf = kmalloc(array_size(WORST_COMPR_FACTOR, out_len), GFP_NOFS);
 	if (!buf)
 		return -ENOMEM;
 
diff --git a/fs/ubifs/lpt.c b/fs/ubifs/lpt.c
index 9a517109da0f..322f7aa7f44f 100644
--- a/fs/ubifs/lpt.c
+++ b/fs/ubifs/lpt.c
@@ -1636,7 +1636,7 @@ static int lpt_init_rd(struct ubifs_info *c)
 		return -ENOMEM;
 
 	for (i = 0; i < LPROPS_HEAP_CNT; i++) {
-		c->lpt_heap[i].arr = kmalloc(sizeof(void *) * LPT_HEAP_SZ,
+		c->lpt_heap[i].arr = kmalloc(array_size(LPT_HEAP_SZ, sizeof(void *)),
 					     GFP_KERNEL);
 		if (!c->lpt_heap[i].arr)
 			return -ENOMEM;
@@ -1644,7 +1644,8 @@ static int lpt_init_rd(struct ubifs_info *c)
 		c->lpt_heap[i].max_cnt = LPT_HEAP_SZ;
 	}
 
-	c->dirty_idx.arr = kmalloc(sizeof(void *) * LPT_HEAP_SZ, GFP_KERNEL);
+	c->dirty_idx.arr = kmalloc(array_size(LPT_HEAP_SZ, sizeof(void *)),
+				   GFP_KERNEL);
 	if (!c->dirty_idx.arr)
 		return -ENOMEM;
 	c->dirty_idx.cnt = 0;
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 6c397a389105..ca095a5919f6 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -1196,7 +1196,8 @@ static int mount_ubifs(struct ubifs_info *c)
 	 * never exceed 64.
 	 */
 	err = -ENOMEM;
-	c->bottom_up_buf = kmalloc(BOTTOM_UP_HEIGHT * sizeof(int), GFP_KERNEL);
+	c->bottom_up_buf = kmalloc(array_size(BOTTOM_UP_HEIGHT, sizeof(int)),
+				   GFP_KERNEL);
 	if (!c->bottom_up_buf)
 		goto out_free;
 
diff --git a/fs/ubifs/tnc_commit.c b/fs/ubifs/tnc_commit.c
index aa31f60220ef..3fad907bbd25 100644
--- a/fs/ubifs/tnc_commit.c
+++ b/fs/ubifs/tnc_commit.c
@@ -674,7 +674,7 @@ static int alloc_idx_lebs(struct ubifs_info *c, int cnt)
 	dbg_cmt("need about %d empty LEBS for TNC commit", leb_cnt);
 	if (!leb_cnt)
 		return 0;
-	c->ilebs = kmalloc(leb_cnt * sizeof(int), GFP_NOFS);
+	c->ilebs = kmalloc(array_size(leb_cnt, sizeof(int)), GFP_NOFS);
 	if (!c->ilebs)
 		return -ENOMEM;
 	for (i = 0; i < leb_cnt; i++) {
diff --git a/fs/udf/super.c b/fs/udf/super.c
index 7949c338efa5..55bcd93a1145 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -1587,7 +1587,8 @@ static struct udf_vds_record *handle_partition_descriptor(
 		struct udf_vds_record *new_loc;
 		unsigned int new_size = ALIGN(partnum, PART_DESC_ALLOC_STEP);
 
-		new_loc = kzalloc(sizeof(*new_loc) * new_size, GFP_KERNEL);
+		new_loc = kzalloc(array_size(new_size, sizeof(*new_loc)),
+				  GFP_KERNEL);
 		if (!new_loc)
 			return ERR_PTR(-ENOMEM);
 		memcpy(new_loc, data->part_descs_loc,
diff --git a/ipc/sem.c b/ipc/sem.c
index 06be75d9217a..2e89e889abef 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -1936,7 +1936,7 @@ static long do_semtimedop(int semid, struct sembuf __user *tsops,
 	if (nsops > ns->sc_semopm)
 		return -E2BIG;
 	if (nsops > SEMOPM_FAST) {
-		sops = kvmalloc(sizeof(*sops)*nsops, GFP_KERNEL);
+		sops = kvmalloc(array_size(nsops, sizeof(*sops)), GFP_KERNEL);
 		if (sops == NULL)
 			return -ENOMEM;
 	}
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index a2c05d2476ac..017db02d747c 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -197,7 +197,7 @@ static void *pidlist_allocate(int count)
 	if (PIDLIST_TOO_LARGE(count))
 		return vmalloc(count * sizeof(pid_t));
 	else
-		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
+		return kmalloc(array_size(count, sizeof(pid_t)), GFP_KERNEL);
 }
 
 static void pidlist_free(void *p)
diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index b42037e6e81d..d68ef0115ee9 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -753,7 +753,8 @@ static int generate_sched_domains(cpumask_var_t **domains,
 	 * The rest of the code, including the scheduler, can deal with
 	 * dattr==NULL case. No need to abort if alloc fails.
 	 */
-	dattr = kmalloc(ndoms * sizeof(struct sched_domain_attr), GFP_KERNEL);
+	dattr = kmalloc(array_size(ndoms, sizeof(struct sched_domain_attr)),
+			GFP_KERNEL);
 
 	for (nslot = 0, i = 0; i < csn; i++) {
 		struct cpuset *a = csa[i];
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 54dc31e7ab9b..21085cd9dae0 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -10229,10 +10229,11 @@ int alloc_fair_sched_group(struct task_group *tg, struct task_group *parent)
 	struct cfs_rq *cfs_rq;
 	int i;
 
-	tg->cfs_rq = kzalloc(sizeof(cfs_rq) * nr_cpu_ids, GFP_KERNEL);
+	tg->cfs_rq = kzalloc(array_size(nr_cpu_ids, sizeof(cfs_rq)),
+			     GFP_KERNEL);
 	if (!tg->cfs_rq)
 		goto err;
-	tg->se = kzalloc(sizeof(se) * nr_cpu_ids, GFP_KERNEL);
+	tg->se = kzalloc(array_size(nr_cpu_ids, sizeof(se)), GFP_KERNEL);
 	if (!tg->se)
 		goto err;
 
diff --git a/kernel/sched/rt.c b/kernel/sched/rt.c
index 7aef6b4e885a..fbebe4e1ed24 100644
--- a/kernel/sched/rt.c
+++ b/kernel/sched/rt.c
@@ -183,10 +183,10 @@ int alloc_rt_sched_group(struct task_group *tg, struct task_group *parent)
 	struct sched_rt_entity *rt_se;
 	int i;
 
-	tg->rt_rq = kzalloc(sizeof(rt_rq) * nr_cpu_ids, GFP_KERNEL);
+	tg->rt_rq = kzalloc(array_size(nr_cpu_ids, sizeof(rt_rq)), GFP_KERNEL);
 	if (!tg->rt_rq)
 		goto err;
-	tg->rt_se = kzalloc(sizeof(rt_se) * nr_cpu_ids, GFP_KERNEL);
+	tg->rt_se = kzalloc(array_size(nr_cpu_ids, sizeof(rt_se)), GFP_KERNEL);
 	if (!tg->rt_se)
 		goto err;
 
diff --git a/kernel/sched/topology.c b/kernel/sched/topology.c
index 64cc564f5255..d5812cb7b399 100644
--- a/kernel/sched/topology.c
+++ b/kernel/sched/topology.c
@@ -1750,7 +1750,7 @@ cpumask_var_t *alloc_sched_domains(unsigned int ndoms)
 	int i;
 	cpumask_var_t *doms;
 
-	doms = kmalloc(sizeof(*doms) * ndoms, GFP_KERNEL);
+	doms = kmalloc(array_size(ndoms, sizeof(*doms)), GFP_KERNEL);
 	if (!doms)
 		return NULL;
 	for (i = 0; i < ndoms; i++) {
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 16bbf062018f..dd408b1acddc 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -728,7 +728,8 @@ static int ftrace_profile_init_cpu(int cpu)
 	 */
 	size = FTRACE_PROFILE_HASH_SIZE;
 
-	stat->hash = kzalloc(sizeof(struct hlist_head) * size, GFP_KERNEL);
+	stat->hash = kzalloc(array_size(size, sizeof(struct hlist_head)),
+			     GFP_KERNEL);
 
 	if (!stat->hash)
 		return -ENOMEM;
@@ -6830,9 +6831,8 @@ static int alloc_retstack_tasklist(struct ftrace_ret_stack **ret_stack_list)
 	struct task_struct *g, *t;
 
 	for (i = 0; i < FTRACE_RETSTACK_ALLOC_SIZE; i++) {
-		ret_stack_list[i] = kmalloc(FTRACE_RETFUNC_DEPTH
-					* sizeof(struct ftrace_ret_stack),
-					GFP_KERNEL);
+		ret_stack_list[i] = kmalloc(array_size(FTRACE_RETFUNC_DEPTH, sizeof(struct ftrace_ret_stack)),
+					    GFP_KERNEL);
 		if (!ret_stack_list[i]) {
 			start = 0;
 			end = i;
@@ -6904,9 +6904,8 @@ static int start_graph_tracing(void)
 	struct ftrace_ret_stack **ret_stack_list;
 	int ret, cpu;
 
-	ret_stack_list = kmalloc(FTRACE_RETSTACK_ALLOC_SIZE *
-				sizeof(struct ftrace_ret_stack *),
-				GFP_KERNEL);
+	ret_stack_list = kmalloc(array_size(FTRACE_RETSTACK_ALLOC_SIZE, sizeof(struct ftrace_ret_stack *)),
+				 GFP_KERNEL);
 
 	if (!ret_stack_list)
 		return -ENOMEM;
@@ -7088,8 +7087,7 @@ void ftrace_graph_init_idle_task(struct task_struct *t, int cpu)
 
 		ret_stack = per_cpu(idle_ret_stack, cpu);
 		if (!ret_stack) {
-			ret_stack = kmalloc(FTRACE_RETFUNC_DEPTH
-					    * sizeof(struct ftrace_ret_stack),
+			ret_stack = kmalloc(array_size(FTRACE_RETFUNC_DEPTH, sizeof(struct ftrace_ret_stack)),
 					    GFP_KERNEL);
 			if (!ret_stack)
 				return;
@@ -7109,9 +7107,8 @@ void ftrace_graph_init_task(struct task_struct *t)
 	if (ftrace_graph_active) {
 		struct ftrace_ret_stack *ret_stack;
 
-		ret_stack = kmalloc(FTRACE_RETFUNC_DEPTH
-				* sizeof(struct ftrace_ret_stack),
-				GFP_KERNEL);
+		ret_stack = kmalloc(array_size(FTRACE_RETFUNC_DEPTH, sizeof(struct ftrace_ret_stack)),
+				    GFP_KERNEL);
 		if (!ret_stack)
 			return;
 		graph_init_task(t, ret_stack);
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index dfbcf9ee1447..d6694d7fb0e6 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -1751,12 +1751,13 @@ static inline void set_cmdline(int idx, const char *cmdline)
 static int allocate_cmdlines_buffer(unsigned int val,
 				    struct saved_cmdlines_buffer *s)
 {
-	s->map_cmdline_to_pid = kmalloc(val * sizeof(*s->map_cmdline_to_pid),
+	s->map_cmdline_to_pid = kmalloc(array_size(val, sizeof(*s->map_cmdline_to_pid)),
 					GFP_KERNEL);
 	if (!s->map_cmdline_to_pid)
 		return -ENOMEM;
 
-	s->saved_cmdlines = kmalloc(val * TASK_COMM_LEN, GFP_KERNEL);
+	s->saved_cmdlines = kmalloc(array_size(TASK_COMM_LEN, val),
+				    GFP_KERNEL);
 	if (!s->saved_cmdlines) {
 		kfree(s->map_cmdline_to_pid);
 		return -ENOMEM;
diff --git a/kernel/trace/trace_events_filter.c b/kernel/trace/trace_events_filter.c
index 9b4716bb8bb0..beb9e3cb22c8 100644
--- a/kernel/trace/trace_events_filter.c
+++ b/kernel/trace/trace_events_filter.c
@@ -436,15 +436,17 @@ predicate_parse(const char *str, int nr_parens, int nr_preds,
 
 	nr_preds += 2; /* For TRUE and FALSE */
 
-	op_stack = kmalloc(sizeof(*op_stack) * nr_parens, GFP_KERNEL);
+	op_stack = kmalloc(array_size(nr_parens, sizeof(*op_stack)),
+			   GFP_KERNEL);
 	if (!op_stack)
 		return ERR_PTR(-ENOMEM);
-	prog_stack = kmalloc(sizeof(*prog_stack) * nr_preds, GFP_KERNEL);
+	prog_stack = kmalloc(array_size(nr_preds, sizeof(*prog_stack)),
+			     GFP_KERNEL);
 	if (!prog_stack) {
 		parse_error(pe, -ENOMEM, 0);
 		goto out_free;
 	}
-	inverts = kmalloc(sizeof(*inverts) * nr_preds, GFP_KERNEL);
+	inverts = kmalloc(array_size(nr_preds, sizeof(*inverts)), GFP_KERNEL);
 	if (!inverts) {
 		parse_error(pe, -ENOMEM, 0);
 		goto out_free;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 246d4d4ce5c7..7102739ad367 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -764,8 +764,8 @@ static int insert_extent(struct uid_gid_map *map, struct uid_gid_extent *extent)
 		struct uid_gid_extent *forward;
 
 		/* Allocate memory for 340 mappings. */
-		forward = kmalloc(sizeof(struct uid_gid_extent) *
-				 UID_GID_MAP_MAX_EXTENTS, GFP_KERNEL);
+		forward = kmalloc(array_size(UID_GID_MAP_MAX_EXTENTS, sizeof(struct uid_gid_extent)),
+				  GFP_KERNEL);
 		if (!forward)
 			return -ENOMEM;
 
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index c976e2bfbac5..894f8869b959 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -5590,7 +5590,7 @@ static void __init wq_numa_init(void)
 	 * available.  Build one from cpu_to_node() which should have been
 	 * fully initialized by now.
 	 */
-	tbl = kzalloc(nr_node_ids * sizeof(tbl[0]), GFP_KERNEL);
+	tbl = kzalloc(array_size(nr_node_ids, sizeof(tbl[0])), GFP_KERNEL);
 	BUG_ON(!tbl);
 
 	for_each_node(node)
diff --git a/lib/bucket_locks.c b/lib/bucket_locks.c
index 266a97c5708b..9cdd8e2e7ba1 100644
--- a/lib/bucket_locks.c
+++ b/lib/bucket_locks.c
@@ -31,7 +31,8 @@ int alloc_bucket_spinlocks(spinlock_t **locks, unsigned int *locks_mask,
 
 	if (sizeof(spinlock_t) != 0) {
 		if (gfpflags_allow_blocking(gfp))
-			tlocks = kvmalloc(size * sizeof(spinlock_t), gfp);
+			tlocks = kvmalloc(array_size(size, sizeof(spinlock_t)),
+					  gfp);
 		else
 			tlocks = kmalloc_array(size, sizeof(spinlock_t), gfp);
 		if (!tlocks)
diff --git a/lib/interval_tree_test.c b/lib/interval_tree_test.c
index 835242e74aaa..01c4802cab12 100644
--- a/lib/interval_tree_test.c
+++ b/lib/interval_tree_test.c
@@ -64,11 +64,12 @@ static int interval_tree_test_init(void)
 	unsigned long results;
 	cycles_t time1, time2, time;
 
-	nodes = kmalloc(nnodes * sizeof(struct interval_tree_node), GFP_KERNEL);
+	nodes = kmalloc(array_size(nnodes, sizeof(struct interval_tree_node)),
+			GFP_KERNEL);
 	if (!nodes)
 		return -ENOMEM;
 
-	queries = kmalloc(nsearches * sizeof(int), GFP_KERNEL);
+	queries = kmalloc(array_size(nsearches, sizeof(int)), GFP_KERNEL);
 	if (!queries) {
 		kfree(nodes);
 		return -ENOMEM;
diff --git a/lib/kfifo.c b/lib/kfifo.c
index b0f757bf7213..7ff1e25ff0d7 100644
--- a/lib/kfifo.c
+++ b/lib/kfifo.c
@@ -54,7 +54,7 @@ int __kfifo_alloc(struct __kfifo *fifo, unsigned int size,
 		return -EINVAL;
 	}
 
-	fifo->data = kmalloc(size * esize, gfp_mask);
+	fifo->data = kmalloc(array_size(esize, size), gfp_mask);
 
 	if (!fifo->data) {
 		fifo->mask = 0;
diff --git a/lib/lru_cache.c b/lib/lru_cache.c
index 28ba40b99337..df171bc14f9e 100644
--- a/lib/lru_cache.c
+++ b/lib/lru_cache.c
@@ -119,7 +119,8 @@ struct lru_cache *lc_create(const char *name, struct kmem_cache *cache,
 	slot = kcalloc(e_count, sizeof(struct hlist_head), GFP_KERNEL);
 	if (!slot)
 		goto out_fail;
-	element = kzalloc(e_count * sizeof(struct lc_element *), GFP_KERNEL);
+	element = kzalloc(array_size(e_count, sizeof(struct lc_element *)),
+			  GFP_KERNEL);
 	if (!element)
 		goto out_fail;
 
diff --git a/lib/mpi/mpiutil.c b/lib/mpi/mpiutil.c
index 314f4dfa603e..aa66eef3de8f 100644
--- a/lib/mpi/mpiutil.c
+++ b/lib/mpi/mpiutil.c
@@ -91,14 +91,16 @@ int mpi_resize(MPI a, unsigned nlimbs)
 		return 0;	/* no need to do it */
 
 	if (a->d) {
-		p = kmalloc(nlimbs * sizeof(mpi_limb_t), GFP_KERNEL);
+		p = kmalloc(array_size(nlimbs, sizeof(mpi_limb_t)),
+			    GFP_KERNEL);
 		if (!p)
 			return -ENOMEM;
 		memcpy(p, a->d, a->alloced * sizeof(mpi_limb_t));
 		kzfree(a->d);
 		a->d = p;
 	} else {
-		a->d = kzalloc(nlimbs * sizeof(mpi_limb_t), GFP_KERNEL);
+		a->d = kzalloc(array_size(nlimbs, sizeof(mpi_limb_t)),
+			       GFP_KERNEL);
 		if (!a->d)
 			return -ENOMEM;
 	}
diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index 7d36c1e27ff6..ad90df17b5ca 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -247,7 +247,7 @@ static int __init rbtree_test_init(void)
 	cycles_t time1, time2, time;
 	struct rb_node *node;
 
-	nodes = kmalloc(nnodes * sizeof(*nodes), GFP_KERNEL);
+	nodes = kmalloc(array_size(nnodes, sizeof(*nodes)), GFP_KERNEL);
 	if (!nodes)
 		return -ENOMEM;
 
diff --git a/lib/scatterlist.c b/lib/scatterlist.c
index 06dad7a072fd..48932d567bd4 100644
--- a/lib/scatterlist.c
+++ b/lib/scatterlist.c
@@ -170,7 +170,8 @@ static struct scatterlist *sg_kmalloc(unsigned int nents, gfp_t gfp_mask)
 		kmemleak_alloc(ptr, PAGE_SIZE, 1, gfp_mask);
 		return ptr;
 	} else
-		return kmalloc(nents * sizeof(struct scatterlist), gfp_mask);
+		return kmalloc(array_size(nents, sizeof(struct scatterlist)),
+		               gfp_mask);
 }
 
 static void sg_kfree(struct scatterlist *sg, unsigned int nents)
diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 0f44759486e2..8706b1f4c60e 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -23,7 +23,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 	struct page **pages;
 
 	nr_pages = gup->size / PAGE_SIZE;
-	pages = kvzalloc(sizeof(void *) * nr_pages, GFP_KERNEL);
+	pages = kvzalloc(array_size(nr_pages, sizeof(void *)), GFP_KERNEL);
 	if (!pages)
 		return -ENOMEM;
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a3a1815f8e11..c1ea75e8bea6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1134,7 +1134,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
-	pages = kmalloc(sizeof(struct page *) * HPAGE_PMD_NR,
+	pages = kmalloc(array_size(HPAGE_PMD_NR, sizeof(struct page *)),
 			GFP_KERNEL);
 	if (unlikely(!pages)) {
 		ret |= VM_FAULT_OOM;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 218679138255..c7e4062ac77c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2798,7 +2798,8 @@ static int __init hugetlb_init(void)
 	num_fault_mutexes = 1;
 #endif
 	hugetlb_fault_mutex_table =
-		kmalloc(sizeof(struct mutex) * num_fault_mutexes, GFP_KERNEL);
+		kmalloc(array_size(num_fault_mutexes, sizeof(struct mutex)),
+			GFP_KERNEL);
 	BUG_ON(!hugetlb_fault_mutex_table);
 
 	for (i = 0; i < num_fault_mutexes; i++)
diff --git a/mm/slub.c b/mm/slub.c
index 44aa7847324a..2726905b9dbf 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4793,7 +4793,8 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 	int x;
 	unsigned long *nodes;
 
-	nodes = kzalloc(sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
+	nodes = kzalloc(array_size(nr_node_ids, sizeof(unsigned long)),
+			GFP_KERNEL);
 	if (!nodes)
 		return -ENOMEM;
 
@@ -5342,7 +5343,7 @@ static int show_stat(struct kmem_cache *s, char *buf, enum stat_item si)
 	unsigned long sum  = 0;
 	int cpu;
 	int len;
-	int *data = kmalloc(nr_cpu_ids * sizeof(int), GFP_KERNEL);
+	int *data = kmalloc(array_size(nr_cpu_ids, sizeof(int)), GFP_KERNEL);
 
 	if (!data)
 		return -ENOMEM;
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index f2641894f440..e2d3aeaae55a 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -122,12 +122,12 @@ static int alloc_swap_slot_cache(unsigned int cpu)
 	 * as kvzalloc could trigger reclaim and get_swap_page,
 	 * which can lock swap_slots_cache_mutex.
 	 */
-	slots = kvzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE,
+	slots = kvzalloc(array_size(SWAP_SLOTS_CACHE_SIZE, sizeof(swp_entry_t)),
 			 GFP_KERNEL);
 	if (!slots)
 		return -ENOMEM;
 
-	slots_ret = kvzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE,
+	slots_ret = kvzalloc(array_size(SWAP_SLOTS_CACHE_SIZE, sizeof(swp_entry_t)),
 			     GFP_KERNEL);
 	if (!slots_ret) {
 		kvfree(slots);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 07f9aa2340c3..d785eae287e4 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -623,7 +623,8 @@ int init_swap_address_space(unsigned int type, unsigned long nr_pages)
 	unsigned int i, nr;
 
 	nr = DIV_ROUND_UP(nr_pages, SWAP_ADDRESS_SPACE_PAGES);
-	spaces = kvzalloc(sizeof(struct address_space) * nr, GFP_KERNEL);
+	spaces = kvzalloc(array_size(nr, sizeof(struct address_space)),
+			  GFP_KERNEL);
 	if (!spaces)
 		return -ENOMEM;
 	for (i = 0; i < nr; i++) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index cc2cf04d9018..fac13e7aab69 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3195,7 +3195,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
 		nr_cluster = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);
 
-		cluster_info = kvzalloc(nr_cluster * sizeof(*cluster_info),
+		cluster_info = kvzalloc(array_size(nr_cluster, sizeof(*cluster_info)),
 					GFP_KERNEL);
 		if (!cluster_info) {
 			error = -ENOMEM;
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 3aa5a93ad107..34446afa2e57 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -361,7 +361,8 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
 		nr_pages = DIV_ROUND_UP((unsigned long)p + len, PAGE_SIZE) -
 			   (unsigned long)p / PAGE_SIZE;
 
-		*pages = kmalloc(sizeof(struct page *) * nr_pages, GFP_NOFS);
+		*pages = kmalloc(array_size(nr_pages, sizeof(struct page *)),
+				 GFP_NOFS);
 		if (!*pages)
 			return -ENOMEM;
 
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 31e0dcb970f8..fed8d9ac8c5d 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -472,7 +472,8 @@ static const uint8_t *copy_macs(struct mpoa_client *mpc,
 		if (mpc->number_of_mps_macs != 0)
 			kfree(mpc->mps_macs);
 		mpc->number_of_mps_macs = 0;
-		mpc->mps_macs = kmalloc(num_macs * ETH_ALEN, GFP_KERNEL);
+		mpc->mps_macs = kmalloc(array_size(ETH_ALEN, num_macs),
+					GFP_KERNEL);
 		if (mpc->mps_macs == NULL) {
 			pr_info("(%s) out of mem\n", mpc->dev->name);
 			return NULL;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 40d260f2bea5..d83e1248379e 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1290,7 +1290,8 @@ int hci_inquiry(void __user *arg)
 	/* cache_dump can't sleep. Therefore we allocate temp buffer and then
 	 * copy it to the user space.
 	 */
-	buf = kmalloc(sizeof(struct inquiry_info) * max_rsp, GFP_KERNEL);
+	buf = kmalloc(array_size(max_rsp, sizeof(struct inquiry_info)),
+		      GFP_KERNEL);
 	if (!buf) {
 		err = -ENOMEM;
 		goto done;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 9b7907ebfa01..04d0ba6a0f80 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -331,7 +331,8 @@ static int l2cap_seq_list_init(struct l2cap_seq_list *seq_list, u16 size)
 	 */
 	alloc_size = roundup_pow_of_two(size);
 
-	seq_list->list = kmalloc(sizeof(u16) * alloc_size, GFP_KERNEL);
+	seq_list->list = kmalloc(array_size(alloc_size, sizeof(u16)),
+				 GFP_KERNEL);
 	if (!seq_list->list)
 		return -ENOMEM;
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index cb4729539b82..5ba8e0b31444 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -333,7 +333,7 @@ static int br_mdb_rehash(struct net_bridge_mdb_htable __rcu **mdbp, int max,
 	mdb->max = max;
 	mdb->old = old;
 
-	mdb->mhash = kzalloc(max * sizeof(*mdb->mhash), GFP_ATOMIC);
+	mdb->mhash = kzalloc(array_size(max, sizeof(*mdb->mhash)), GFP_ATOMIC);
 	if (!mdb->mhash) {
 		kfree(mdb);
 		return -ENOMEM;
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index a3d0adc828e6..94a4e810a382 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -20,7 +20,7 @@ struct page **ceph_get_direct_page_vector(const void __user *data,
 	int got = 0;
 	int rc = 0;
 
-	pages = kmalloc(sizeof(*pages) * num_pages, GFP_NOFS);
+	pages = kmalloc(array_size(num_pages, sizeof(*pages)), GFP_NOFS);
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 
@@ -74,7 +74,7 @@ struct page **ceph_alloc_page_vector(int num_pages, gfp_t flags)
 	struct page **pages;
 	int i;
 
-	pages = kmalloc(sizeof(*pages) * num_pages, flags);
+	pages = kmalloc(array_size(num_pages, sizeof(*pages)), flags);
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < num_pages; i++) {
diff --git a/net/core/dev.c b/net/core/dev.c
index af0558b00c6c..e59402dd1de3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -8785,7 +8785,8 @@ static struct hlist_head * __net_init netdev_create_hash(void)
 	int i;
 	struct hlist_head *hash;
 
-	hash = kmalloc(sizeof(*hash) * NETDEV_HASHENTRIES, GFP_KERNEL);
+	hash = kmalloc(array_size(NETDEV_HASHENTRIES, sizeof(*hash)),
+		       GFP_KERNEL);
 	if (hash != NULL)
 		for (i = 0; i < NETDEV_HASHENTRIES; i++)
 			INIT_HLIST_HEAD(&hash[i]);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 03416e6dd5d7..85db91f67e5d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -936,7 +936,7 @@ static noinline_for_stack int ethtool_get_sset_info(struct net_device *dev,
 	memset(&info, 0, sizeof(info));
 	info.cmd = ETHTOOL_GSSET_INFO;
 
-	info_buf = kzalloc(n_bits * sizeof(u32), GFP_USER);
+	info_buf = kzalloc(array_size(n_bits, sizeof(u32)), GFP_USER);
 	if (!info_buf)
 		return -ENOMEM;
 
@@ -1836,7 +1836,7 @@ static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 		return -EFAULT;
 
 	test.len = test_len;
-	data = kmalloc(test_len * sizeof(u64), GFP_USER);
+	data = kmalloc(array_size(test_len, sizeof(u64)), GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index bae7d78aa068..778fb3a41dbc 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -983,7 +983,8 @@ static int dcbnl_build_peer_app(struct net_device *netdev, struct sk_buff* skb,
 	 */
 	err = ops->peer_getappinfo(netdev, &info, &app_count);
 	if (!err && app_count) {
-		table = kmalloc(sizeof(struct dcb_app) * app_count, GFP_KERNEL);
+		table = kmalloc(array_size(app_count, sizeof(struct dcb_app)),
+				GFP_KERNEL);
 		if (!table)
 			return -ENOMEM;
 
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 92d016e87816..1f5289ea2db1 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -46,7 +46,8 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hc)
 		return -ENOMEM;
 
 	/* allocate buffer and initialize linked list */
-	seqp = kmalloc(CCID2_SEQBUF_LEN * sizeof(struct ccid2_seq), gfp_any());
+	seqp = kmalloc(array_size(CCID2_SEQBUF_LEN, sizeof(struct ccid2_seq)),
+		       gfp_any());
 	if (seqp == NULL)
 		return -ENOMEM;
 
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index dc2960be51e0..3174f82a3298 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -38,7 +38,7 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 {
 	void *hdr;
 	int i, pages = 0;
-	uint32_t *buf = kzalloc(32 * sizeof(uint32_t), GFP_KERNEL);
+	uint32_t *buf = kzalloc(array_size(32, sizeof(uint32_t)), GFP_KERNEL);
 
 	pr_debug("%s\n", __func__);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ccb25d80f679..db8434155788 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -660,7 +660,8 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 
 	hash = rcu_dereference(nh->nh_exceptions);
 	if (!hash) {
-		hash = kzalloc(FNHE_HASH_SIZE * sizeof(*hash), GFP_ATOMIC);
+		hash = kzalloc(array_size(FNHE_HASH_SIZE, sizeof(*hash)),
+			       GFP_ATOMIC);
 		if (!hash)
 			goto out_unlock;
 		rcu_assign_pointer(nh->nh_exceptions, hash);
@@ -3064,7 +3065,8 @@ int __init ip_rt_init(void)
 {
 	int cpu;
 
-	ip_idents = kmalloc(IP_IDENTS_SZ * sizeof(*ip_idents), GFP_KERNEL);
+	ip_idents = kmalloc(array_size(IP_IDENTS_SZ, sizeof(*ip_idents)),
+			    GFP_KERNEL);
 	if (!ip_idents)
 		panic("IP: failed to allocate ip_idents\n");
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index d8c4b6374377..e26063d7391c 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -956,7 +956,8 @@ static int __net_init icmpv6_sk_init(struct net *net)
 	int err, i, j;
 
 	net->ipv6.icmp_sk =
-		kzalloc(nr_cpu_ids * sizeof(struct sock *), GFP_KERNEL);
+		kzalloc(array_size(nr_cpu_ids, sizeof(struct sock *)),
+			GFP_KERNEL);
 	if (!net->ipv6.icmp_sk)
 		return -ENOMEM;
 
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 44c39c5f0638..f410255efffd 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -42,7 +42,8 @@ static int alloc_ila_locks(struct ila_net *ilan)
 	size = roundup_pow_of_two(nr_pcpus * LOCKS_PER_CPU);
 
 	if (sizeof(spinlock_t) != 0) {
-		ilan->locks = kvmalloc(size * sizeof(spinlock_t), GFP_KERNEL);
+		ilan->locks = kvmalloc(array_size(size, sizeof(spinlock_t)),
+				       GFP_KERNEL);
 		if (!ilan->locks)
 			return -ENOMEM;
 		for (i = 0; i < size; i++)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 49b954d6d0fa..9043b1cd2e1e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2518,7 +2518,7 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 	if (!cfg->fc_mx)
 		return 0;
 
-	mp = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
+	mp = kzalloc(array_size(RTAX_MAX, sizeof(u32)), GFP_KERNEL);
 	if (unlikely(!mp))
 		return -ENOMEM;
 
diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index 89178b46b32f..0782df3ae888 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -1186,7 +1186,8 @@ static int ieee80211_chsw_switch_vifs(struct ieee80211_local *local,
 	lockdep_assert_held(&local->mtx);
 	lockdep_assert_held(&local->chanctx_mtx);
 
-	vif_chsw = kzalloc(sizeof(vif_chsw[0]) * n_vifs, GFP_KERNEL);
+	vif_chsw = kzalloc(array_size(n_vifs, sizeof(vif_chsw[0])),
+			   GFP_KERNEL);
 	if (!vif_chsw)
 		return -ENOMEM;
 
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 9ea17afaa237..1a402f72b6d4 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -769,7 +769,8 @@ static int ieee80211_init_cipher_suites(struct ieee80211_local *local)
 		if (have_mfp)
 			n_suites += 4;
 
-		suites = kmalloc(sizeof(u32) * n_suites, GFP_KERNEL);
+		suites = kmalloc(array_size(n_suites, sizeof(u32)),
+				 GFP_KERNEL);
 		if (!suites)
 			return -ENOMEM;
 
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 8221bc5582ab..2640e64aeea6 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -592,11 +592,12 @@ minstrel_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp)
 			max_rates = sband->n_bitrates;
 	}
 
-	mi->r = kzalloc(sizeof(struct minstrel_rate) * max_rates, gfp);
+	mi->r = kzalloc(array_size(max_rates, sizeof(struct minstrel_rate)),
+			gfp);
 	if (!mi->r)
 		goto error;
 
-	mi->sample_table = kmalloc(SAMPLE_COLUMNS * max_rates, gfp);
+	mi->sample_table = kmalloc(array_size(max_rates, SAMPLE_COLUMNS), gfp);
 	if (!mi->sample_table)
 		goto error1;
 
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_minstrel_ht.c
index fb586b6e5d49..11956d56f192 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -1313,11 +1313,13 @@ minstrel_ht_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp)
 	if (!msp)
 		return NULL;
 
-	msp->ratelist = kzalloc(sizeof(struct minstrel_rate) * max_rates, gfp);
+	msp->ratelist = kzalloc(array_size(max_rates, sizeof(struct minstrel_rate)),
+				gfp);
 	if (!msp->ratelist)
 		goto error;
 
-	msp->sample_table = kmalloc(SAMPLE_COLUMNS * max_rates, gfp);
+	msp->sample_table = kmalloc(array_size(max_rates, SAMPLE_COLUMNS),
+				    gfp);
 	if (!msp->sample_table)
 		goto error1;
 
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index a3b1bcc2b461..9d60f3b98689 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -1157,7 +1157,7 @@ int __ieee80211_request_sched_scan_start(struct ieee80211_sub_if_data *sdata,
 		}
 	}
 
-	ie = kzalloc(num_bands * iebufsz, GFP_KERNEL);
+	ie = kzalloc(array_size(iebufsz, num_bands), GFP_KERNEL);
 	if (!ie) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index afdeca53e88b..d2b551261ee3 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -402,8 +402,7 @@ int nf_ct_l4proto_register_one(const struct nf_conntrack_l4proto *l4proto)
 		struct nf_conntrack_l4proto __rcu **proto_array;
 		int i;
 
-		proto_array = kmalloc(MAX_NF_CT_PROTO *
-				      sizeof(struct nf_conntrack_l4proto *),
+		proto_array = kmalloc(array_size(MAX_NF_CT_PROTO, sizeof(struct nf_conntrack_l4proto *)),
 				      GFP_KERNEL);
 		if (proto_array == NULL) {
 			ret = -ENOMEM;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 617693ff9f4c..8d6ff8f2da79 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -587,7 +587,7 @@ int nf_nat_l4proto_register(u8 l3proto, const struct nf_nat_l4proto *l4proto)
 
 	mutex_lock(&nf_nat_proto_mutex);
 	if (nf_nat_l4protos[l3proto] == NULL) {
-		l4protos = kmalloc(IPPROTO_MAX * sizeof(struct nf_nat_l4proto *),
+		l4protos = kmalloc(array_size(IPPROTO_MAX, sizeof(struct nf_nat_l4proto *)),
 				   GFP_KERNEL);
 		if (l4protos == NULL) {
 			ret = -ENOMEM;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 9134cc429ad4..7ac4f0d85eff 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -5006,7 +5006,7 @@ static int nf_tables_flowtable_parse_hook(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	ops = kzalloc(sizeof(struct nf_hook_ops) * n, GFP_KERNEL);
+	ops = kzalloc(array_size(n, sizeof(struct nf_hook_ops)), GFP_KERNEL);
 	if (!ops)
 		return -ENOMEM;
 
@@ -6671,7 +6671,7 @@ static int __init nf_tables_module_init(void)
 
 	nft_chain_filter_init();
 
-	info = kmalloc(sizeof(struct nft_expr_info) * NFT_RULE_MAXEXPRS,
+	info = kmalloc(array_size(NFT_RULE_MAXEXPRS, sizeof(struct nft_expr_info)),
 		       GFP_KERNEL);
 	if (info == NULL) {
 		err = -ENOMEM;
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index 4a4b293fb2e5..42f5c7e52b4b 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -190,8 +190,8 @@ nfnl_cthelper_parse_expect_policy(struct nf_conntrack_helper *helper,
 	if (class_max > NF_CT_MAX_EXPECT_CLASSES)
 		return -EOVERFLOW;
 
-	expect_policy = kzalloc(sizeof(struct nf_conntrack_expect_policy) *
-				class_max, GFP_KERNEL);
+	expect_policy = kzalloc(array_size(class_max, sizeof(struct nf_conntrack_expect_policy)),
+				GFP_KERNEL);
 	if (expect_policy == NULL)
 		return -ENOMEM;
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 71325fef647d..94f401d22291 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1957,7 +1957,8 @@ static int __init xt_init(void)
 		seqcount_init(&per_cpu(xt_recseq, i));
 	}
 
-	xt = kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL);
+	xt = kmalloc(array_size(NFPROTO_NUMPROTO, sizeof(struct xt_af)),
+		     GFP_KERNEL);
 	if (!xt)
 		return -ENOMEM;
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 4221d98a314b..18257d48e642 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1407,7 +1407,8 @@ static int __init nr_proto_init(void)
 		return -1;
 	}
 
-	dev_nr = kzalloc(nr_ndevs * sizeof(struct net_device *), GFP_KERNEL);
+	dev_nr = kzalloc(array_size(nr_ndevs, sizeof(struct net_device *)),
+			 GFP_KERNEL);
 	if (dev_nr == NULL) {
 		printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device array\n");
 		return -1;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 015e24e08909..573cca3291dd 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1578,7 +1578,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_table;
 	}
 
-	dp->ports = kmalloc(DP_VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
+	dp->ports = kmalloc(array_size(DP_VPORT_HASH_BUCKETS, sizeof(struct hlist_head)),
 			    GFP_KERNEL);
 	if (!dp->ports) {
 		err = -ENOMEM;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index f81c1d0ddff4..ebc3f0ec1477 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -47,7 +47,7 @@ static struct hlist_head *dev_table;
  */
 int ovs_vport_init(void)
 {
-	dev_table = kzalloc(VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
+	dev_table = kzalloc(array_size(VPORT_HASH_BUCKETS, sizeof(struct hlist_head)),
 			    GFP_KERNEL);
 	if (!dev_table)
 		return -ENOMEM;
diff --git a/net/rds/info.c b/net/rds/info.c
index 140a44a5f7b7..9d3870b77fd6 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -188,7 +188,8 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 	nr_pages = (PAGE_ALIGN(start + len) - (start & PAGE_MASK))
 			>> PAGE_SHIFT;
 
-	pages = kmalloc(nr_pages * sizeof(struct page *), GFP_KERNEL);
+	pages = kmalloc(array_size(nr_pages, sizeof(struct page *)),
+			GFP_KERNEL);
 	if (!pages) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 9ff5e0a76593..052af3f8390b 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1526,7 +1526,8 @@ static int __init rose_proto_init(void)
 
 	rose_callsign = null_ax25_address;
 
-	dev_rose = kzalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
+	dev_rose = kzalloc(array_size(rose_ndevs, sizeof(struct net_device *)),
+			   GFP_KERNEL);
 	if (dev_rose == NULL) {
 		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
 		rc = -ENOMEM;
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 588fea0dd362..6e22d1bcfbc8 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -432,7 +432,7 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 
 	sg = _sg;
 	if (unlikely(nsg > 4)) {
-		sg = kmalloc(sizeof(*sg) * nsg, GFP_NOIO);
+		sg = kmalloc(array_size(nsg, sizeof(*sg)), GFP_NOIO);
 		if (!sg)
 			goto nomem;
 	}
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index bce2632212d3..fd63d70aac0b 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -599,8 +599,8 @@ static int hhf_init(struct Qdisc *sch, struct nlattr *opt,
 
 	if (!q->hh_flows) {
 		/* Initialize heavy-hitter flow table. */
-		q->hh_flows = kvzalloc(HH_FLOWS_CNT *
-					 sizeof(struct list_head), GFP_KERNEL);
+		q->hh_flows = kvzalloc(array_size(HH_FLOWS_CNT, sizeof(struct list_head)),
+				       GFP_KERNEL);
 		if (!q->hh_flows)
 			return -ENOMEM;
 		for (i = 0; i < HH_FLOWS_CNT; i++)
@@ -614,8 +614,8 @@ static int hhf_init(struct Qdisc *sch, struct nlattr *opt,
 
 		/* Initialize heavy-hitter filter arrays. */
 		for (i = 0; i < HHF_ARRAYS_CNT; i++) {
-			q->hhf_arrays[i] = kvzalloc(HHF_ARRAYS_LEN *
-						      sizeof(u32), GFP_KERNEL);
+			q->hhf_arrays[i] = kvzalloc(array_size(HHF_ARRAYS_LEN, sizeof(u32)),
+						    GFP_KERNEL);
 			if (!q->hhf_arrays[i]) {
 				/* Note: hhf_destroy() will be called
 				 * by our caller.
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index e64630cd3331..dac7d403e8a8 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -482,8 +482,8 @@ int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp)
 		return 0;
 
 	/* Allocated the array of pointers to transorms */
-	ep->auth_hmacs = kzalloc(sizeof(struct crypto_shash *) *
-				 SCTP_AUTH_NUM_HMACS, gfp);
+	ep->auth_hmacs = kzalloc(array_size(SCTP_AUTH_NUM_HMACS, sizeof(struct crypto_shash *)),
+				 gfp);
 	if (!ep->auth_hmacs)
 		return -ENOMEM;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d685f8456762..b53aabaaf1a6 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1438,7 +1438,8 @@ static __init int sctp_init(void)
 	/* Allocate and initialize the endpoint hash table.  */
 	sctp_ep_hashsize = 64;
 	sctp_ep_hashtable =
-		kmalloc(64 * sizeof(struct sctp_hashbucket), GFP_KERNEL);
+		kmalloc(array_size(64, sizeof(struct sctp_hashbucket)),
+			GFP_KERNEL);
 	if (!sctp_ep_hashtable) {
 		pr_err("Failed endpoint_hash alloc\n");
 		status = -ENOMEM;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index ff28f8feeb09..fb722f6a8450 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -10586,7 +10586,7 @@ static int nl80211_parse_wowlan_nd(struct cfg80211_registered_device *rdev,
 	struct nlattr **tb;
 	int err;
 
-	tb = kzalloc(NUM_NL80211_ATTR * sizeof(*tb), GFP_KERNEL);
+	tb = kzalloc(array_size(NUM_NL80211_ATTR, sizeof(*tb)), GFP_KERNEL);
 	if (!tb)
 		return -ENOMEM;
 
@@ -11546,7 +11546,7 @@ static int nl80211_nan_add_func(struct sk_buff *skb,
 
 			func->srf_num_macs = n_entries;
 			func->srf_macs =
-				kzalloc(sizeof(*func->srf_macs) * n_entries,
+				kzalloc(array_size(n_entries, sizeof(*func->srf_macs)),
 					GFP_KERNEL);
 			if (!func->srf_macs) {
 				err = -ENOMEM;
diff --git a/security/apparmor/policy_unpack.c b/security/apparmor/policy_unpack.c
index b9e6b2cafa69..577a8ac47149 100644
--- a/security/apparmor/policy_unpack.c
+++ b/security/apparmor/policy_unpack.c
@@ -475,7 +475,7 @@ static bool unpack_trans_table(struct aa_ext *e, struct aa_profile *profile)
 		/* currently 4 exec bits and entries 0-3 are reserved iupcx */
 		if (size > 16 - 4)
 			goto fail;
-		profile->file.trans.table = kzalloc(sizeof(char *) * size,
+		profile->file.trans.table = kzalloc(array_size(size, sizeof(char *)),
 						    GFP_KERNEL);
 		if (!profile->file.trans.table)
 			goto fail;
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 8057e19dc15f..7126d4b4ed4c 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2118,7 +2118,7 @@ int security_load_policy(struct selinux_state *state, void *data, size_t len)
 	int rc = 0;
 	struct policy_file file = { data, len }, *fp = &file;
 
-	oldpolicydb = kzalloc(2 * sizeof(*oldpolicydb), GFP_KERNEL);
+	oldpolicydb = kzalloc(array_size(2, sizeof(*oldpolicydb)), GFP_KERNEL);
 	if (!oldpolicydb) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/sound/core/pcm_compat.c b/sound/core/pcm_compat.c
index b719d0bd833e..0a904b384e40 100644
--- a/sound/core/pcm_compat.c
+++ b/sound/core/pcm_compat.c
@@ -429,7 +429,7 @@ static int snd_pcm_ioctl_xfern_compat(struct snd_pcm_substream *substream,
 	    get_user(frames, &data32->frames))
 		return -EFAULT;
 	bufptr = compat_ptr(buf);
-	bufs = kmalloc(sizeof(void __user *) * ch, GFP_KERNEL);
+	bufs = kmalloc(array_size(ch, sizeof(void __user *)), GFP_KERNEL);
 	if (bufs == NULL)
 		return -ENOMEM;
 	for (i = 0; i < ch; i++) {
diff --git a/sound/core/seq/seq_midi_emul.c b/sound/core/seq/seq_midi_emul.c
index 9e2912e3e80f..0d9527032967 100644
--- a/sound/core/seq/seq_midi_emul.c
+++ b/sound/core/seq/seq_midi_emul.c
@@ -657,7 +657,8 @@ static struct snd_midi_channel *snd_midi_channel_init_set(int n)
 	struct snd_midi_channel *chan;
 	int  i;
 
-	chan = kmalloc(n * sizeof(struct snd_midi_channel), GFP_KERNEL);
+	chan = kmalloc(array_size(n, sizeof(struct snd_midi_channel)),
+		       GFP_KERNEL);
 	if (chan) {
 		for (i = 0; i < n; i++)
 			snd_midi_channel_init(chan+i, i);
diff --git a/sound/firewire/fireface/ff-protocol-ff400.c b/sound/firewire/fireface/ff-protocol-ff400.c
index 12aa15df435d..654a4f849605 100644
--- a/sound/firewire/fireface/ff-protocol-ff400.c
+++ b/sound/firewire/fireface/ff-protocol-ff400.c
@@ -147,7 +147,7 @@ static int ff400_switch_fetching_mode(struct snd_ff *ff, bool enable)
 	__le32 *reg;
 	int i;
 
-	reg = kzalloc(sizeof(__le32) * 18, GFP_KERNEL);
+	reg = kzalloc(array_size(18, sizeof(__le32)), GFP_KERNEL);
 	if (reg == NULL)
 		return -ENOMEM;
 
diff --git a/sound/firewire/packets-buffer.c b/sound/firewire/packets-buffer.c
index ea1506679c66..bb5c1858db99 100644
--- a/sound/firewire/packets-buffer.c
+++ b/sound/firewire/packets-buffer.c
@@ -27,7 +27,8 @@ int iso_packets_buffer_init(struct iso_packets_buffer *b, struct fw_unit *unit,
 	void *p;
 	int err;
 
-	b->packets = kmalloc(count * sizeof(*b->packets), GFP_KERNEL);
+	b->packets = kmalloc(array_size(count, sizeof(*b->packets)),
+			     GFP_KERNEL);
 	if (!b->packets) {
 		err = -ENOMEM;
 		goto error;
diff --git a/sound/oss/dmasound/dmasound_core.c b/sound/oss/dmasound/dmasound_core.c
index 8c0f8a9ee0ba..1b848a24e507 100644
--- a/sound/oss/dmasound/dmasound_core.c
+++ b/sound/oss/dmasound/dmasound_core.c
@@ -420,7 +420,7 @@ static int sq_allocate_buffers(struct sound_queue *sq, int num, int size)
 		return 0;
 	sq->numBufs = num;
 	sq->bufSize = size;
-	sq->buffers = kmalloc (num * sizeof(char *), GFP_KERNEL);
+	sq->buffers = kmalloc(array_size(num, sizeof(char *)), GFP_KERNEL);
 	if (!sq->buffers)
 		return -ENOMEM;
 	for (i = 0; i < num; i++) {
diff --git a/sound/pci/cs46xx/dsp_spos.c b/sound/pci/cs46xx/dsp_spos.c
index aa61615288ff..361a48c21b4a 100644
--- a/sound/pci/cs46xx/dsp_spos.c
+++ b/sound/pci/cs46xx/dsp_spos.c
@@ -243,7 +243,8 @@ struct dsp_spos_instance *cs46xx_dsp_spos_create (struct snd_cs46xx * chip)
 	ins->symbol_table.symbols = vmalloc(sizeof(struct dsp_symbol_entry) *
 					    DSP_MAX_SYMBOLS);
 	ins->code.data = kmalloc(DSP_CODE_BYTE_SIZE, GFP_KERNEL);
-	ins->modules = kmalloc(sizeof(struct dsp_module_desc) * DSP_MAX_MODULES, GFP_KERNEL);
+	ins->modules = kmalloc(array_size(DSP_MAX_MODULES, sizeof(struct dsp_module_desc)),
+			       GFP_KERNEL);
 	if (!ins->symbol_table.symbols || !ins->code.data || !ins->modules) {
 		cs46xx_dsp_spos_destroy(chip);
 		goto error;
diff --git a/sound/pci/ctxfi/ctatc.c b/sound/pci/ctxfi/ctatc.c
index 908658a00377..6fd0e030615d 100644
--- a/sound/pci/ctxfi/ctatc.c
+++ b/sound/pci/ctxfi/ctatc.c
@@ -275,7 +275,8 @@ static int atc_pcm_playback_prepare(struct ct_atc *atc, struct ct_atc_pcm *apcm)
 
 	/* Get AMIXER resource */
 	n_amixer = (n_amixer < 2) ? 2 : n_amixer;
-	apcm->amixers = kzalloc(sizeof(void *)*n_amixer, GFP_KERNEL);
+	apcm->amixers = kzalloc(array_size(n_amixer, sizeof(void *)),
+				GFP_KERNEL);
 	if (!apcm->amixers) {
 		err = -ENOMEM;
 		goto error1;
@@ -543,18 +544,21 @@ atc_pcm_capture_get_resources(struct ct_atc *atc, struct ct_atc_pcm *apcm)
 	}
 
 	if (n_srcc) {
-		apcm->srccs = kzalloc(sizeof(void *)*n_srcc, GFP_KERNEL);
+		apcm->srccs = kzalloc(array_size(n_srcc, sizeof(void *)),
+				      GFP_KERNEL);
 		if (!apcm->srccs)
 			return -ENOMEM;
 	}
 	if (n_amixer) {
-		apcm->amixers = kzalloc(sizeof(void *)*n_amixer, GFP_KERNEL);
+		apcm->amixers = kzalloc(array_size(n_amixer, sizeof(void *)),
+					GFP_KERNEL);
 		if (!apcm->amixers) {
 			err = -ENOMEM;
 			goto error1;
 		}
 	}
-	apcm->srcimps = kzalloc(sizeof(void *)*n_srcimp, GFP_KERNEL);
+	apcm->srcimps = kzalloc(array_size(n_srcimp, sizeof(void *)),
+				GFP_KERNEL);
 	if (!apcm->srcimps) {
 		err = -ENOMEM;
 		goto error1;
@@ -819,7 +823,8 @@ static int spdif_passthru_playback_get_resources(struct ct_atc *atc,
 
 	/* Get AMIXER resource */
 	n_amixer = (n_amixer < 2) ? 2 : n_amixer;
-	apcm->amixers = kzalloc(sizeof(void *)*n_amixer, GFP_KERNEL);
+	apcm->amixers = kzalloc(array_size(n_amixer, sizeof(void *)),
+				GFP_KERNEL);
 	if (!apcm->amixers) {
 		err = -ENOMEM;
 		goto error1;
@@ -1378,15 +1383,17 @@ static int atc_get_resources(struct ct_atc *atc)
 	num_daios = ((atc->model == CTSB1270) ? 8 : 7);
 	num_srcs = ((atc->model == CTSB1270) ? 6 : 4);
 
-	atc->daios = kzalloc(sizeof(void *)*num_daios, GFP_KERNEL);
+	atc->daios = kzalloc(array_size(num_daios, sizeof(void *)),
+			     GFP_KERNEL);
 	if (!atc->daios)
 		return -ENOMEM;
 
-	atc->srcs = kzalloc(sizeof(void *)*num_srcs, GFP_KERNEL);
+	atc->srcs = kzalloc(array_size(num_srcs, sizeof(void *)), GFP_KERNEL);
 	if (!atc->srcs)
 		return -ENOMEM;
 
-	atc->srcimps = kzalloc(sizeof(void *)*num_srcs, GFP_KERNEL);
+	atc->srcimps = kzalloc(array_size(num_srcs, sizeof(void *)),
+			       GFP_KERNEL);
 	if (!atc->srcimps)
 		return -ENOMEM;
 
diff --git a/sound/pci/hda/hda_codec.c b/sound/pci/hda/hda_codec.c
index 5bc3a7468e17..acce4219e234 100644
--- a/sound/pci/hda/hda_codec.c
+++ b/sound/pci/hda/hda_codec.c
@@ -158,7 +158,8 @@ static int read_and_add_raw_conns(struct hda_codec *codec, hda_nid_t nid)
 	len = snd_hda_get_raw_connections(codec, nid, list, ARRAY_SIZE(list));
 	if (len == -ENOSPC) {
 		len = snd_hda_get_num_raw_conns(codec, nid);
-		result = kmalloc(sizeof(hda_nid_t) * len, GFP_KERNEL);
+		result = kmalloc(array_size(len, sizeof(hda_nid_t)),
+				 GFP_KERNEL);
 		if (!result)
 			return -ENOMEM;
 		len = snd_hda_get_raw_connections(codec, nid, result, len);
diff --git a/sound/pci/hda/hda_proc.c b/sound/pci/hda/hda_proc.c
index 033aa84365b9..db2deb4c07db 100644
--- a/sound/pci/hda/hda_proc.c
+++ b/sound/pci/hda/hda_proc.c
@@ -825,7 +825,7 @@ static void print_codec_info(struct snd_info_entry *entry,
 		if (wid_caps & AC_WCAP_CONN_LIST) {
 			conn_len = snd_hda_get_num_raw_conns(codec, nid);
 			if (conn_len > 0) {
-				conn = kmalloc(sizeof(hda_nid_t) * conn_len,
+				conn = kmalloc(array_size(conn_len, sizeof(hda_nid_t)),
 					       GFP_KERNEL);
 				if (!conn)
 					return;
diff --git a/sound/pci/hda/patch_ca0132.c b/sound/pci/hda/patch_ca0132.c
index 768ea8651993..436984eb4ef7 100644
--- a/sound/pci/hda/patch_ca0132.c
+++ b/sound/pci/hda/patch_ca0132.c
@@ -4694,7 +4694,8 @@ static int ca0132_prepare_verbs(struct hda_codec *codec)
 	struct ca0132_spec *spec = codec->spec;
 
 	spec->chip_init_verbs = ca0132_init_verbs0;
-	spec->spec_init_verbs = kzalloc(sizeof(struct hda_verb) * NUM_SPEC_VERBS, GFP_KERNEL);
+	spec->spec_init_verbs = kzalloc(array_size(NUM_SPEC_VERBS, sizeof(struct hda_verb)),
+					GFP_KERNEL);
 	if (!spec->spec_init_verbs)
 		return -ENOMEM;
 
diff --git a/sound/pci/via82xx.c b/sound/pci/via82xx.c
index 3a1c0b8b4ea2..368e66ad09ed 100644
--- a/sound/pci/via82xx.c
+++ b/sound/pci/via82xx.c
@@ -439,7 +439,8 @@ static int build_via_table(struct viadev *dev, struct snd_pcm_substream *substre
 			return -ENOMEM;
 	}
 	if (! dev->idx_table) {
-		dev->idx_table = kmalloc(sizeof(*dev->idx_table) * VIA_TABLE_SIZE, GFP_KERNEL);
+		dev->idx_table = kmalloc(array_size(VIA_TABLE_SIZE, sizeof(*dev->idx_table)),
+					 GFP_KERNEL);
 		if (! dev->idx_table)
 			return -ENOMEM;
 	}
diff --git a/sound/pci/via82xx_modem.c b/sound/pci/via82xx_modem.c
index 8a69221c1b86..fa573cc7612b 100644
--- a/sound/pci/via82xx_modem.c
+++ b/sound/pci/via82xx_modem.c
@@ -292,7 +292,8 @@ static int build_via_table(struct viadev *dev, struct snd_pcm_substream *substre
 			return -ENOMEM;
 	}
 	if (! dev->idx_table) {
-		dev->idx_table = kmalloc(sizeof(*dev->idx_table) * VIA_TABLE_SIZE, GFP_KERNEL);
+		dev->idx_table = kmalloc(array_size(VIA_TABLE_SIZE, sizeof(*dev->idx_table)),
+					 GFP_KERNEL);
 		if (! dev->idx_table)
 			return -ENOMEM;
 	}
diff --git a/sound/pci/ymfpci/ymfpci_main.c b/sound/pci/ymfpci/ymfpci_main.c
index 8ca2e41e5827..0baf4975174e 100644
--- a/sound/pci/ymfpci/ymfpci_main.c
+++ b/sound/pci/ymfpci/ymfpci_main.c
@@ -2435,7 +2435,7 @@ int snd_ymfpci_create(struct snd_card *card,
 		goto free_chip;
 
 #ifdef CONFIG_PM_SLEEP
-	chip->saved_regs = kmalloc(YDSXGR_NUM_SAVED_REGS * sizeof(u32),
+	chip->saved_regs = kmalloc(array_size(YDSXGR_NUM_SAVED_REGS, sizeof(u32)),
 				   GFP_KERNEL);
 	if (chip->saved_regs == NULL) {
 		err = -ENOMEM;
diff --git a/sound/soc/intel/common/sst-ipc.c b/sound/soc/intel/common/sst-ipc.c
index 62f3a8e0ec87..156ce5a7cd54 100644
--- a/sound/soc/intel/common/sst-ipc.c
+++ b/sound/soc/intel/common/sst-ipc.c
@@ -121,8 +121,8 @@ static int msg_empty_list_init(struct sst_generic_ipc *ipc)
 {
 	int i;
 
-	ipc->msg = kzalloc(sizeof(struct ipc_message) *
-		IPC_EMPTY_LIST_SIZE, GFP_KERNEL);
+	ipc->msg = kzalloc(array_size(IPC_EMPTY_LIST_SIZE, sizeof(struct ipc_message)),
+			   GFP_KERNEL);
 	if (ipc->msg == NULL)
 		return -ENOMEM;
 
diff --git a/sound/usb/6fire/pcm.c b/sound/usb/6fire/pcm.c
index 224a6a5d1c0e..3b45404ca60c 100644
--- a/sound/usb/6fire/pcm.c
+++ b/sound/usb/6fire/pcm.c
@@ -591,12 +591,12 @@ static int usb6fire_pcm_buffers_init(struct pcm_runtime *rt)
 	int i;
 
 	for (i = 0; i < PCM_N_URBS; i++) {
-		rt->out_urbs[i].buffer = kzalloc(PCM_N_PACKETS_PER_URB
-				* PCM_MAX_PACKET_SIZE, GFP_KERNEL);
+		rt->out_urbs[i].buffer = kzalloc(array_size(PCM_MAX_PACKET_SIZE, PCM_N_PACKETS_PER_URB),
+						 GFP_KERNEL);
 		if (!rt->out_urbs[i].buffer)
 			return -ENOMEM;
-		rt->in_urbs[i].buffer = kzalloc(PCM_N_PACKETS_PER_URB
-				* PCM_MAX_PACKET_SIZE, GFP_KERNEL);
+		rt->in_urbs[i].buffer = kzalloc(array_size(PCM_MAX_PACKET_SIZE, PCM_N_PACKETS_PER_URB),
+						GFP_KERNEL);
 		if (!rt->in_urbs[i].buffer)
 			return -ENOMEM;
 	}
diff --git a/sound/usb/caiaq/audio.c b/sound/usb/caiaq/audio.c
index fb1c1eac0b5e..765a9f04f3fa 100644
--- a/sound/usb/caiaq/audio.c
+++ b/sound/usb/caiaq/audio.c
@@ -728,7 +728,7 @@ static struct urb **alloc_urbs(struct snd_usb_caiaqdev *cdev, int dir, int *ret)
 		usb_sndisocpipe(usb_dev, ENDPOINT_PLAYBACK) :
 		usb_rcvisocpipe(usb_dev, ENDPOINT_CAPTURE);
 
-	urbs = kmalloc(N_URBS * sizeof(*urbs), GFP_KERNEL);
+	urbs = kmalloc(array_size(N_URBS, sizeof(*urbs)), GFP_KERNEL);
 	if (!urbs) {
 		*ret = -ENOMEM;
 		return NULL;
@@ -742,7 +742,8 @@ static struct urb **alloc_urbs(struct snd_usb_caiaqdev *cdev, int dir, int *ret)
 		}
 
 		urbs[i]->transfer_buffer =
-			kmalloc(FRAMES_PER_URB * BYTES_PER_FRAME, GFP_KERNEL);
+			kmalloc(array_size(BYTES_PER_FRAME, FRAMES_PER_URB),
+				GFP_KERNEL);
 		if (!urbs[i]->transfer_buffer) {
 			*ret = -ENOMEM;
 			return urbs;
@@ -857,8 +858,8 @@ int snd_usb_caiaq_audio_init(struct snd_usb_caiaqdev *cdev)
 				&snd_usb_caiaq_ops);
 
 	cdev->data_cb_info =
-		kmalloc(sizeof(struct snd_usb_caiaq_cb_info) * N_URBS,
-					GFP_KERNEL);
+		kmalloc(array_size(N_URBS, sizeof(struct snd_usb_caiaq_cb_info)),
+			GFP_KERNEL);
 
 	if (!cdev->data_cb_info)
 		return -ENOMEM;
diff --git a/sound/usb/format.c b/sound/usb/format.c
index 49e7ec6d2399..ba7c14e20b37 100644
--- a/sound/usb/format.c
+++ b/sound/usb/format.c
@@ -188,7 +188,8 @@ static int parse_audio_format_rates_v1(struct snd_usb_audio *chip, struct audiof
 		 */
 		int r, idx;
 
-		fp->rate_table = kmalloc(sizeof(int) * nr_rates, GFP_KERNEL);
+		fp->rate_table = kmalloc(array_size(nr_rates, sizeof(int)),
+					 GFP_KERNEL);
 		if (fp->rate_table == NULL)
 			return -ENOMEM;
 
diff --git a/sound/usb/pcm.c b/sound/usb/pcm.c
index 3cbfae6604f9..8e75456bb472 100644
--- a/sound/usb/pcm.c
+++ b/sound/usb/pcm.c
@@ -1123,7 +1123,7 @@ static int snd_usb_pcm_check_knot(struct snd_pcm_runtime *runtime,
 		return 0;
 
 	subs->rate_list.list = rate_list =
-		kmalloc(sizeof(int) * count, GFP_KERNEL);
+		kmalloc(array_size(count, sizeof(int)), GFP_KERNEL);
 	if (!subs->rate_list.list)
 		return -ENOMEM;
 	subs->rate_list.count = count;
diff --git a/sound/usb/usx2y/usbusx2y.c b/sound/usb/usx2y/usbusx2y.c
index 0ddf29267d70..0162f78d854b 100644
--- a/sound/usb/usx2y/usbusx2y.c
+++ b/sound/usb/usx2y/usbusx2y.c
@@ -266,7 +266,7 @@ int usX2Y_AsyncSeq04_init(struct usX2Ydev *usX2Y)
 	int	err = 0,
 		i;
 
-	if (NULL == (usX2Y->AS04.buffer = kmalloc(URB_DataLen_AsyncSeq*URBS_AsyncSeq, GFP_KERNEL))) {
+	if (NULL == (usX2Y->AS04.buffer = kmalloc(array_size(URBS_AsyncSeq, URB_DataLen_AsyncSeq), GFP_KERNEL))) {
 		err = -ENOMEM;
 	} else
 		for (i = 0; i < URBS_AsyncSeq; ++i) {
diff --git a/sound/usb/usx2y/usbusx2yaudio.c b/sound/usb/usx2y/usbusx2yaudio.c
index 345e439aa95b..6b662e0905c6 100644
--- a/sound/usb/usx2y/usbusx2yaudio.c
+++ b/sound/usb/usx2y/usbusx2yaudio.c
@@ -662,7 +662,8 @@ static int usX2Y_rate_set(struct usX2Ydev *usX2Y, int rate)
 			err = -ENOMEM;
 			goto cleanup;
 		}
-		usbdata = kmalloc(sizeof(int) * NOOF_SETRATE_URBS, GFP_KERNEL);
+		usbdata = kmalloc(array_size(NOOF_SETRATE_URBS, sizeof(int)),
+				  GFP_KERNEL);
 		if (NULL == usbdata) {
 			err = -ENOMEM;
 			goto cleanup;
diff --git a/tools/virtio/ringtest/ptr_ring.c b/tools/virtio/ringtest/ptr_ring.c
index 2d566fbd236b..53b699ddbbbd 100644
--- a/tools/virtio/ringtest/ptr_ring.c
+++ b/tools/virtio/ringtest/ptr_ring.c
@@ -45,7 +45,7 @@ static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
 {
 	if (size != 0 && n > SIZE_MAX / size)
 		return NULL;
-	return kmalloc(n * size, flags);
+	return kmalloc(array_size(size, n), flags);
 }
 
 static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
diff --git a/virt/kvm/arm/vgic/vgic-v4.c b/virt/kvm/arm/vgic/vgic-v4.c
index bc4265154bac..a6387ea2e20d 100644
--- a/virt/kvm/arm/vgic/vgic-v4.c
+++ b/virt/kvm/arm/vgic/vgic-v4.c
@@ -126,7 +126,7 @@ int vgic_v4_init(struct kvm *kvm)
 
 	nr_vcpus = atomic_read(&kvm->online_vcpus);
 
-	dist->its_vm.vpes = kzalloc(sizeof(*dist->its_vm.vpes) * nr_vcpus,
+	dist->its_vm.vpes = kzalloc(array_size(nr_vcpus, sizeof(*dist->its_vm.vpes)),
 				    GFP_KERNEL);
 	if (!dist->its_vm.vpes)
 		return -ENOMEM;
-- 
2.17.0
