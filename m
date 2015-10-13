Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87E046B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 03:33:23 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so13253579pad.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 00:33:23 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id or2si3063287pbc.207.2015.10.13.00.33.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 00:33:22 -0700 (PDT)
Received: by palb17 with SMTP id b17so1236130pal.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 00:33:22 -0700 (PDT)
Content-Type: multipart/mixed; boundary="Apple-Mail=_E308760F-8872-46AD-80B7-E62963202B9F"
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [RFC] arm: add __initbss section attribute
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151012200422.GA29175@ravnborg.org>
Date: Tue, 13 Oct 2015 15:33:10 +0800
Message-Id: <FEDC4251-5A6A-4E3C-AE36-8E5B55D9D6CF@gmail.com>
References: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com> <20151012200422.GA29175@ravnborg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>, Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Victor Kamensky <victor.kamensky@linaro.org>, Mark Salter <msalter@redhat.com>, vladimir.murzin@arm.com, ggdavisiv@gmail.com, paul.gortmaker@windriver.com, mingo@kernel.org, rusty@rustcorp.com.au, mcgrof@suse.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, jack@suse.cz, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org


--Apple-Mail=_E308760F-8872-46AD-80B7-E62963202B9F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Oct 13, 2015, at 04:04, Sam Ravnborg <sam@ravnborg.org> wrote:
>=20
>> --- a/include/asm-generic/vmlinux.lds.h
>> +++ b/include/asm-generic/vmlinux.lds.h
>>=20
>> -#define BSS_SECTION(sbss_align, bss_align, stop_align)			=
\
>> +#define BSS_SECTION(sbss_align, bss_align, initbss_align, =
stop_align)			\
>=20
> A few comments:
>=20
> 1) - please align the backslash at the end of the
>     line with the backslash above it.
> 2) - you need to fix all the remaining users of BSS_SECTION.
> 3) - do we really need the flexibility to specify an alignment =
(stop_align)?
>        If not - drop the extra argument.
>=20
> 	Sam
i change lots of __initdata to __initbss to test it on ARM arch,


--Apple-Mail=_E308760F-8872-46AD-80B7-E62963202B9F
Content-Disposition: attachment;
	filename=initbss_change.diff
Content-Type: application/octet-stream;
	name="initbss_change.diff"
Content-Transfer-Encoding: 7bit

diff --git a/arch/alpha/kernel/smc37c669.c b/arch/alpha/kernel/smc37c669.c
index c803fc7..1f25738 100644
--- a/arch/alpha/kernel/smc37c669.c
+++ b/arch/alpha/kernel/smc37c669.c
@@ -983,7 +983,7 @@ static SMC37c669_CONFIG_REGS *SMC37c669 __initdata = NULL;
 ** and standard ISA IRQs.
 **
 */
-static SMC37c669_IRQ_TRANSLATION_ENTRY *SMC37c669_irq_table __initdata; 
+static SMC37c669_IRQ_TRANSLATION_ENTRY *SMC37c669_irq_table __initbss; 
 
 /*
 ** The following definition is for the default IRQ 
@@ -1032,7 +1032,7 @@ static SMC37c669_IRQ_TRANSLATION_ENTRY *SMC37c669_irq_tables[] __initdata =
 ** ISA DMA channels.
 **
 */
-static SMC37c669_DRQ_TRANSLATION_ENTRY *SMC37c669_drq_table __initdata;
+static SMC37c669_DRQ_TRANSLATION_ENTRY *SMC37c669_drq_table __initbss;
 
 /*
 ** The following definition is the default DRQ
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 036473b..df36e02 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -90,7 +90,7 @@ EXPORT_SYMBOL(__machine_arch_type);
 unsigned int cacheid __read_mostly;
 EXPORT_SYMBOL(cacheid);
 
-unsigned int __atags_pointer __initdata;
+unsigned int __atags_pointer __initbss;
 
 unsigned int system_rev;
 EXPORT_SYMBOL(system_rev);
@@ -152,7 +152,7 @@ EXPORT_SYMBOL(elf_platform);
 static const char *cpu_name;
 static const char *machine_name;
 static char __initdata cmd_line[COMMAND_LINE_SIZE];
-const struct machine_desc *machine_desc __initdata;
+const struct machine_desc *machine_desc __initbss;
 
 static union { char c[4]; unsigned long l; } endian_test __initdata = { { 'l', '?', '?', 'b' } };
 #define ENDIANNESS ((char)endian_test.l)
@@ -739,7 +739,7 @@ int __init arm_add_memory(u64 start, u64 size)
 
 static int __init early_mem(char *p)
 {
-	static int usermem __initdata = 0;
+	static int usermem __initbss;
 	u64 size;
 	u64 start;
 	char *endp;
diff --git a/arch/arm/mach-davinci/devices-da8xx.c b/arch/arm/mach-davinci/devices-da8xx.c
index 29e08aa..9765298 100644
--- a/arch/arm/mach-davinci/devices-da8xx.c
+++ b/arch/arm/mach-davinci/devices-da8xx.c
@@ -829,8 +829,8 @@ static struct platform_device da8xx_dsp = {
 
 #if IS_ENABLED(CONFIG_DA8XX_REMOTEPROC)
 
-static phys_addr_t rproc_base __initdata;
-static unsigned long rproc_size __initdata;
+static phys_addr_t rproc_base __initbss;
+static unsigned long rproc_size __initbss;
 
 static int __init early_rproc_mem(char *p)
 {
diff --git a/arch/arm/mach-exynos/s5p-dev-mfc.c b/arch/arm/mach-exynos/s5p-dev-mfc.c
index 0b04b6b..9d7ad51 100644
--- a/arch/arm/mach-exynos/s5p-dev-mfc.c
+++ b/arch/arm/mach-exynos/s5p-dev-mfc.c
@@ -34,7 +34,7 @@ struct s5p_mfc_reserved_mem {
 	struct device	*dev;
 };
 
-static struct s5p_mfc_reserved_mem s5p_mfc_mem[2] __initdata;
+static struct s5p_mfc_reserved_mem s5p_mfc_mem[2] __initbss;
 
 
 static void __init s5p_mfc_reserve_mem(phys_addr_t rbase, unsigned int rsize,
diff --git a/arch/arm/mach-imx/devices/platform-ipu-core.c b/arch/arm/mach-imx/devices/platform-ipu-core.c
index 6bd7c3f..713b09d 100644
--- a/arch/arm/mach-imx/devices/platform-ipu-core.c
+++ b/arch/arm/mach-imx/devices/platform-ipu-core.c
@@ -28,7 +28,7 @@ const struct imx_ipu_core_data imx35_ipu_core_data __initconst =
 	imx_ipu_core_entry_single(MX35);
 #endif
 
-static struct platform_device *imx_ipu_coredev __initdata;
+static struct platform_device *imx_ipu_coredev __initbss;
 
 struct platform_device *__init imx_add_ipu_core(
 		const struct imx_ipu_core_data *data)
diff --git a/arch/arm/mach-imx/mach-imx27_visstrim_m10.c b/arch/arm/mach-imx/mach-imx27_visstrim_m10.c
index ede2bdb..6b1d3ed 100644
--- a/arch/arm/mach-imx/mach-imx27_visstrim_m10.c
+++ b/arch/arm/mach-imx/mach-imx27_visstrim_m10.c
@@ -239,7 +239,7 @@ static struct mx2_camera_platform_data visstrim_camera = {
 	.clk = 100000,
 };
 
-static phys_addr_t mx2_camera_base __initdata;
+static phys_addr_t mx2_camera_base __initbss;
 #define MX2_CAMERA_BUF_SIZE SZ_8M
 
 static void __init visstrim_analog_camera_init(void)
diff --git a/arch/arm/mach-imx/mach-mx27_3ds.c b/arch/arm/mach-imx/mach-mx27_3ds.c
index 9ef4640..761126e 100644
--- a/arch/arm/mach-imx/mach-mx27_3ds.c
+++ b/arch/arm/mach-imx/mach-mx27_3ds.c
@@ -245,7 +245,7 @@ static const struct fsl_usb2_platform_data otg_device_pdata __initconst = {
 	.phy_mode       = FSL_USB2_PHY_ULPI,
 };
 
-static bool otg_mode_host __initdata;
+static bool otg_mode_host __initbss;
 
 static int __init mx27_3ds_otg_mode(char *options)
 {
diff --git a/arch/arm/mach-imx/mach-mx31_3ds.c b/arch/arm/mach-imx/mach-mx31_3ds.c
index 65a0dc0..a3c7f92 100644
--- a/arch/arm/mach-imx/mach-mx31_3ds.c
+++ b/arch/arm/mach-imx/mach-mx31_3ds.c
@@ -164,7 +164,7 @@ static int mx31_3ds_pins[] = {
 /*
  * Camera support
  */
-static phys_addr_t mx3_camera_base __initdata;
+static phys_addr_t mx3_camera_base __initbss;
 #define MX31_3DS_CAMERA_BUF_SIZE SZ_8M
 
 #define MX31_3DS_GPIO_CAMERA_PW IOMUX_TO_GPIO(MX31_PIN_CSI_D5)
@@ -665,7 +665,7 @@ static const struct fsl_usb2_platform_data usbotg_pdata __initconst = {
 	.phy_mode	= FSL_USB2_PHY_ULPI,
 };
 
-static bool otg_mode_host __initdata;
+static bool otg_mode_host __initbss;
 
 static int __init mx31_3ds_otg_mode(char *options)
 {
diff --git a/arch/arm/mach-imx/mach-mx31moboard.c b/arch/arm/mach-imx/mach-mx31moboard.c
index bb6f8a5..d00c212 100644
--- a/arch/arm/mach-imx/mach-mx31moboard.c
+++ b/arch/arm/mach-imx/mach-mx31moboard.c
@@ -470,7 +470,7 @@ static struct mx3_camera_pdata camera_pdata __initdata = {
 	.mclk_10khz	= 4800,
 };
 
-static phys_addr_t mx3_camera_base __initdata;
+static phys_addr_t mx3_camera_base __initbss;
 #define MX3_CAMERA_BUF_SIZE SZ_4M
 
 static int __init mx31moboard_init_cam(void)
diff --git a/arch/arm/mach-imx/mach-mx35_3ds.c b/arch/arm/mach-imx/mach-mx35_3ds.c
index 7e315f0..fe9c9d5 100644
--- a/arch/arm/mach-imx/mach-mx35_3ds.c
+++ b/arch/arm/mach-imx/mach-mx35_3ds.c
@@ -255,7 +255,7 @@ static const iomux_v3_cfg_t mx35pdk_pads[] __initconst = {
 /*
  * Camera support
 */
-static phys_addr_t mx3_camera_base __initdata;
+static phys_addr_t mx3_camera_base __initbss;
 #define MX35_3DS_CAMERA_BUF_SIZE SZ_8M
 
 static const struct mx3_camera_pdata mx35_3ds_camera_pdata __initconst = {
@@ -531,7 +531,7 @@ static const struct mxc_usbh_platform_data usb_host_pdata __initconst = {
 	.portsc		= MXC_EHCI_MODE_SERIAL,
 };
 
-static bool otg_mode_host __initdata;
+static bool otg_mode_host __initbss;
 
 static int __init mx35_3ds_otg_mode(char *options)
 {
diff --git a/arch/arm/mach-imx/mach-pca100.c b/arch/arm/mach-imx/mach-pca100.c
index 2d1c50b..2174705 100644
--- a/arch/arm/mach-imx/mach-pca100.c
+++ b/arch/arm/mach-imx/mach-pca100.c
@@ -297,7 +297,7 @@ static const struct fsl_usb2_platform_data otg_device_pdata __initconst = {
 	.phy_mode       = FSL_USB2_PHY_ULPI,
 };
 
-static bool otg_mode_host __initdata;
+static bool otg_mode_host __initbss;
 
 static int __init pca100_otg_mode(char *options)
 {
diff --git a/arch/arm/mach-imx/mach-pcm037.c b/arch/arm/mach-imx/mach-pcm037.c
index 6d87941..01b30fb 100644
--- a/arch/arm/mach-imx/mach-pcm037.c
+++ b/arch/arm/mach-imx/mach-pcm037.c
@@ -408,7 +408,7 @@ struct mx3_camera_pdata camera_pdata __initdata = {
 	.mclk_10khz	= 2000,
 };
 
-static phys_addr_t mx3_camera_base __initdata;
+static phys_addr_t mx3_camera_base __initbss;
 #define MX3_CAMERA_BUF_SIZE SZ_4M
 
 static int __init pcm037_init_camera(void)
@@ -551,7 +551,7 @@ static const struct fsl_usb2_platform_data otg_device_pdata __initconst = {
 	.phy_mode       = FSL_USB2_PHY_ULPI,
 };
 
-static bool otg_mode_host __initdata;
+static bool otg_mode_host __initbss;
 
 static int __init pcm037_otg_mode(char *options)
 {
diff --git a/arch/arm/mach-imx/mach-pcm043.c b/arch/arm/mach-imx/mach-pcm043.c
index e447e59..cf17683 100644
--- a/arch/arm/mach-imx/mach-pcm043.c
+++ b/arch/arm/mach-imx/mach-pcm043.c
@@ -326,7 +326,7 @@ static const struct fsl_usb2_platform_data otg_device_pdata __initconst = {
 	.phy_mode       = FSL_USB2_PHY_UTMI,
 };
 
-static bool otg_mode_host __initdata;
+static bool otg_mode_host __initbss;
 
 static int __init pcm043_otg_mode(char *options)
 {
diff --git a/arch/arm/mach-omap2/serial.c b/arch/arm/mach-omap2/serial.c
index 5fb50fe..639de16 100644
--- a/arch/arm/mach-omap2/serial.c
+++ b/arch/arm/mach-omap2/serial.c
@@ -103,7 +103,7 @@ static void omap_uart_enable_wakeup(struct device *dev, bool enable)
 
 #define OMAP_UART_DEFAULT_PAD_NAME_LEN	28
 static char rx_pad_name[OMAP_UART_DEFAULT_PAD_NAME_LEN],
-		tx_pad_name[OMAP_UART_DEFAULT_PAD_NAME_LEN] __initdata;
+		tx_pad_name[OMAP_UART_DEFAULT_PAD_NAME_LEN] __initbss;
 
 static void  __init
 omap_serial_fill_uart_tx_rx_pads(struct omap_board_data *bdata,
diff --git a/arch/arm/mach-omap2/timer.c b/arch/arm/mach-omap2/timer.c
index bef4183..287dcb9 100644
--- a/arch/arm/mach-omap2/timer.c
+++ b/arch/arm/mach-omap2/timer.c
@@ -356,7 +356,7 @@ static void __init omap2_gp_clockevent_init(int gptimer_id,
 
 /* Clocksource code */
 static struct omap_dm_timer clksrc;
-static bool use_gptimer_clksrc __initdata;
+static bool use_gptimer_clksrc __initbss;
 
 /*
  * clocksource
diff --git a/arch/arm/mach-orion5x/pci.c b/arch/arm/mach-orion5x/pci.c
index b02f394..ef06040 100644
--- a/arch/arm/mach-orion5x/pci.c
+++ b/arch/arm/mach-orion5x/pci.c
@@ -526,7 +526,7 @@ static void rc_pci_fixup(struct pci_dev *dev)
 }
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_MARVELL, PCI_ANY_ID, rc_pci_fixup);
 
-static int orion5x_pci_disabled __initdata;
+static int orion5x_pci_disabled __initbss;
 
 void __init orion5x_pci_disable(void)
 {
diff --git a/arch/arm/mach-sa1100/badge4.c b/arch/arm/mach-sa1100/badge4.c
index 63361b6..98b8f63 100644
--- a/arch/arm/mach-sa1100/badge4.c
+++ b/arch/arm/mach-sa1100/badge4.c
@@ -161,7 +161,7 @@ static struct flash_platform_data badge4_flash_data = {
 static struct resource badge4_flash_resource =
 	DEFINE_RES_MEM(SA1100_CS0_PHYS, SZ_64M);
 
-static int five_v_on __initdata = 0;
+static int five_v_on __initbss;
 
 static int __init five_v_on_setup(char *ignore)
 {
diff --git a/arch/arm/mach-shmobile/pm-rmobile.c b/arch/arm/mach-shmobile/pm-rmobile.c
index 89068c8..7d66150 100644
--- a/arch/arm/mach-shmobile/pm-rmobile.c
+++ b/arch/arm/mach-shmobile/pm-rmobile.c
@@ -170,9 +170,9 @@ enum pd_types {
 static struct special_pd {
 	struct device_node *pd;
 	enum pd_types type;
-} special_pds[MAX_NUM_SPECIAL_PDS] __initdata;
+} special_pds[MAX_NUM_SPECIAL_PDS] __initbss;
 
-static unsigned int num_special_pds __initdata;
+static unsigned int num_special_pds __initbss;
 
 static const struct of_device_id special_ids[] __initconst = {
 	{ .compatible = "arm,coresight-etm3x", .data = (void *)PD_DEBUG },
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index e62400e..9aa00dc 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -400,9 +400,9 @@ struct dma_contig_early_reserve {
 	unsigned long size;
 };
 
-static struct dma_contig_early_reserve dma_mmu_remap[MAX_CMA_AREAS] __initdata;
+static struct dma_contig_early_reserve dma_mmu_remap[MAX_CMA_AREAS] __initbss;
 
-static int dma_mmu_remap_num __initdata;
+static int dma_mmu_remap_num __initbss;
 
 void __init dma_contiguous_early_fixup(phys_addr_t base, unsigned long size)
 {
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 50b881e..71c199c 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -46,8 +46,8 @@ unsigned long __init __clear_cr(unsigned long mask)
 }
 #endif
 
-static phys_addr_t phys_initrd_start __initdata = 0;
-static unsigned long phys_initrd_size __initdata = 0;
+static phys_addr_t phys_initrd_start __initbss;
+static unsigned long phys_initrd_size __initbss;
 
 static int __init early_initrd(char *p)
 {
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index f65a6f3..6e6ebc0 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -62,7 +62,7 @@ pmdval_t user_pmd_table = _PAGE_USER_TABLE;
 #define CPOLICY_WRITEALLOC	4
 
 static unsigned int cachepolicy __initdata = CPOLICY_WRITEBACK;
-static unsigned int ecc_mask __initdata = 0;
+static unsigned int ecc_mask __initbss;
 pgprot_t pgprot_user;
 pgprot_t pgprot_kernel;
 pgprot_t pgprot_hyp_device;
@@ -121,7 +121,7 @@ static struct cachepolicy cache_policies[] __initdata = {
 };
 
 #ifdef CONFIG_CPU_CP15
-static unsigned long initial_pmd_value __initdata = 0;
+static unsigned long initial_pmd_value __initbss;
 
 /*
  * Initialise the cache_policy variable with the initial state specified
@@ -360,7 +360,7 @@ EXPORT_SYMBOL(get_mem_type);
 static pte_t *(*pte_offset_fixmap)(pmd_t *dir, unsigned long addr);
 
 static pte_t bm_pte[PTRS_PER_PTE + PTE_HWTABLE_PTRS]
-	__aligned(PTE_HWTABLE_OFF + PTE_HWTABLE_SIZE) __initdata;
+	__aligned(PTE_HWTABLE_OFF + PTE_HWTABLE_SIZE) __initbss;
 
 static pte_t * __init pte_offset_early_fixmap(pmd_t *dir, unsigned long addr)
 {
@@ -1105,7 +1105,7 @@ static int __init early_vmalloc(char *arg)
 }
 early_param("vmalloc", early_vmalloc);
 
-phys_addr_t arm_lowmem_limit __initdata = 0;
+phys_addr_t arm_lowmem_limit __initbss;
 
 void __init sanity_check_meminfo(void)
 {
diff --git a/arch/arm/plat-samsung/init.c b/arch/arm/plat-samsung/init.c
index 11fbbc2..0b27658 100644
--- a/arch/arm/plat-samsung/init.c
+++ b/arch/arm/plat-samsung/init.c
@@ -91,7 +91,7 @@ void __init s3c24xx_init_clocks(int xtal)
 
 /* uart management */
 #if IS_ENABLED(CONFIG_SAMSUNG_ATAGS)
-static int nr_uarts __initdata = 0;
+static int nr_uarts __initbss;
 
 #ifdef CONFIG_SERIAL_SAMSUNG_UARTS
 static struct s3c2410_uartcfg uart_cfgs[CONFIG_SERIAL_SAMSUNG_UARTS];
diff --git a/arch/arm/xen/enlighten.c b/arch/arm/xen/enlighten.c
index 50b4769..35192b3 100644
--- a/arch/arm/xen/enlighten.c
+++ b/arch/arm/xen/enlighten.c
@@ -43,7 +43,7 @@ static struct vcpu_info __percpu *xen_vcpu_info;
 
 /* These are unused until we support booting "pre-ballooned" */
 unsigned long xen_released_pages;
-struct xen_memory_region xen_extra_mem[XEN_EXTRA_MEM_MAX_REGIONS] __initdata;
+struct xen_memory_region xen_extra_mem[XEN_EXTRA_MEM_MAX_REGIONS] __initbss;
 
 static __read_mostly unsigned int xen_events_irq;
 
diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index d1ce8e2..346b3f5 100644
--- a/arch/arm64/kernel/acpi.c
+++ b/arch/arm64/kernel/acpi.c
@@ -41,8 +41,8 @@ EXPORT_SYMBOL(acpi_disabled);
 int acpi_pci_disabled = 1;	/* skip ACPI PCI scan and IRQ initialization */
 EXPORT_SYMBOL(acpi_pci_disabled);
 
-static bool param_acpi_off __initdata;
-static bool param_acpi_force __initdata;
+static bool param_acpi_off __initbss;
+static bool param_acpi_force __initbss;
 
 static int __init parse_acpi(char *arg)
 {
diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index a48d1f4..4833871 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -50,7 +50,7 @@ static struct mm_struct efi_mm = {
 	.mmlist			= LIST_HEAD_INIT(efi_mm.mmlist),
 };
 
-static int uefi_debug __initdata;
+static int uefi_debug __initbss;
 static int __init uefi_debug_setup(char *str)
 {
 	uefi_debug = 1;
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 2322479..55dbdbe 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -81,7 +81,7 @@ unsigned int compat_elf_hwcap2 __read_mostly;
 
 DECLARE_BITMAP(cpu_hwcaps, ARM64_NCAPS);
 
-phys_addr_t __fdt_pointer __initdata;
+phys_addr_t __fdt_pointer __initbss;
 
 /*
  * Standard memory resources
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 4910be2..3a2ca65 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -387,7 +387,7 @@ static int __init smp_cpu_setup(int cpu)
 	return 0;
 }
 
-static bool bootcpu_valid __initdata;
+static bool bootcpu_valid __initbss;
 static unsigned int cpu_count = 1;
 
 #ifdef CONFIG_ACPI
diff --git a/arch/arm64/kernel/topology.c b/arch/arm64/kernel/topology.c
index 694f6de..137f6aa 100644
--- a/arch/arm64/kernel/topology.c
+++ b/arch/arm64/kernel/topology.c
@@ -99,7 +99,7 @@ static int __init parse_cluster(struct device_node *cluster, int depth)
 	bool leaf = true;
 	bool has_cores = false;
 	struct device_node *c;
-	static int cluster_id __initdata;
+	static int cluster_id __initbss;
 	int core_id = 0;
 	int i, ret;
 
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f5c0680..54a40f5 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -358,7 +358,7 @@ void free_initmem(void)
 
 #ifdef CONFIG_BLK_DEV_INITRD
 
-static int keep_initrd __initdata;
+static int keep_initrd __initbss;
 
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
diff --git a/arch/avr32/boards/atngw100/setup.c b/arch/avr32/boards/atngw100/setup.c
index afeae89..e460859 100644
--- a/arch/avr32/boards/atngw100/setup.c
+++ b/arch/avr32/boards/atngw100/setup.c
@@ -104,7 +104,7 @@ static struct atmel_nand_data atngw100mkii_nand_data __initdata = {
 #endif
 
 /* Initialized by bootloader-specific startup code. */
-struct tag *bootloader_tags __initdata;
+struct tag *bootloader_tags __initbss;
 
 struct eth_addr {
 	u8 addr[6];
diff --git a/arch/avr32/boards/atstk1000/setup.c b/arch/avr32/boards/atstk1000/setup.c
index b6b88f5..a628438 100644
--- a/arch/avr32/boards/atstk1000/setup.c
+++ b/arch/avr32/boards/atstk1000/setup.c
@@ -25,7 +25,7 @@
 #include "atstk1000.h"
 
 /* Initialized by bootloader-specific startup code. */
-struct tag *bootloader_tags __initdata;
+struct tag *bootloader_tags __initbss;
 
 static struct fb_videomode __initdata ltv350qv_modes[] = {
 	{
diff --git a/arch/avr32/boards/favr-32/setup.c b/arch/avr32/boards/favr-32/setup.c
index 234cb07..fcc2392 100644
--- a/arch/avr32/boards/favr-32/setup.c
+++ b/arch/avr32/boards/favr-32/setup.c
@@ -46,7 +46,7 @@ unsigned long at32_board_osc_rates[3] = {
 };
 
 /* Initialized by bootloader-specific startup code. */
-struct tag *bootloader_tags __initdata;
+struct tag *bootloader_tags __initbss;
 
 static struct atmel_abdac_pdata __initdata abdac0_data = {
 };
diff --git a/arch/avr32/boards/hammerhead/setup.c b/arch/avr32/boards/hammerhead/setup.c
index dc0e317..69d6ca5 100644
--- a/arch/avr32/boards/hammerhead/setup.c
+++ b/arch/avr32/boards/hammerhead/setup.c
@@ -42,7 +42,7 @@ unsigned long at32_board_osc_rates[3] = {
 };
 
 /* Initialized by bootloader-specific startup code. */
-struct tag *bootloader_tags __initdata;
+struct tag *bootloader_tags __initbss;
 
 #ifdef CONFIG_BOARD_HAMMERHEAD_LCD
 static struct fb_videomode __initdata hda350tlv_modes[] = {
diff --git a/arch/avr32/boards/merisc/setup.c b/arch/avr32/boards/merisc/setup.c
index 83d896c..bd1d5cb 100644
--- a/arch/avr32/boards/merisc/setup.c
+++ b/arch/avr32/boards/merisc/setup.c
@@ -40,7 +40,7 @@
 static int merisc_board_id;
 
 /* Initialized by bootloader-specific startup code. */
-struct tag *bootloader_tags __initdata;
+struct tag *bootloader_tags __initbss;
 
 /* Oscillator frequencies. These are board specific */
 unsigned long at32_board_osc_rates[3] = {
diff --git a/arch/avr32/boards/mimc200/setup.c b/arch/avr32/boards/mimc200/setup.c
index 1cb8e9c..22d128b 100644
--- a/arch/avr32/boards/mimc200/setup.c
+++ b/arch/avr32/boards/mimc200/setup.c
@@ -41,7 +41,7 @@ unsigned long at32_board_osc_rates[3] = {
 };
 
 /* Initialized by bootloader-specific startup code. */
-struct tag *bootloader_tags __initdata;
+struct tag *bootloader_tags __initbss;
 
 static struct fb_videomode __initdata pt0434827_modes[] = {
 	{
diff --git a/arch/blackfin/kernel/setup.c b/arch/blackfin/kernel/setup.c
index ad82468..e2ff203 100644
--- a/arch/blackfin/kernel/setup.c
+++ b/arch/blackfin/kernel/setup.c
@@ -74,17 +74,17 @@ static struct bfin_memmap {
 		unsigned long long size;
 		unsigned long type;
 	} map[BFIN_MEMMAP_MAX];
-} bfin_memmap __initdata;
+} bfin_memmap __initbss;
 
 /* for memmap sanitization */
 struct change_member {
 	struct bfin_memmap_entry *pentry; /* pointer to original entry */
 	unsigned long long addr; /* address for this change point */
 };
-static struct change_member change_point_list[2*BFIN_MEMMAP_MAX] __initdata;
-static struct change_member *change_point[2*BFIN_MEMMAP_MAX] __initdata;
-static struct bfin_memmap_entry *overlap_list[BFIN_MEMMAP_MAX] __initdata;
-static struct bfin_memmap_entry new_map[BFIN_MEMMAP_MAX] __initdata;
+static struct change_member change_point_list[2*BFIN_MEMMAP_MAX] __initbss;
+static struct change_member *change_point[2*BFIN_MEMMAP_MAX] __initbss;
+static struct bfin_memmap_entry *overlap_list[BFIN_MEMMAP_MAX] __initbss;
+static struct bfin_memmap_entry new_map[BFIN_MEMMAP_MAX] __initbss;
 
 DEFINE_PER_CPU(struct blackfin_cpudata, cpu_data);
 
diff --git a/arch/c6x/kernel/setup.c b/arch/c6x/kernel/setup.c
index 72e17f7..c4cab3e 100644
--- a/arch/c6x/kernel/setup.c
+++ b/arch/c6x/kernel/setup.c
@@ -69,8 +69,8 @@ unsigned long ram_start;
 unsigned long ram_end;
 
 /* Uncached memory for DMA consistent use (memdma=) */
-static unsigned long dma_start __initdata;
-static unsigned long dma_size __initdata;
+static unsigned long dma_start __initbss;
+static unsigned long dma_size __initbss;
 
 struct cpuinfo_c6x {
 	const char *cpu_name;
@@ -214,7 +214,7 @@ static void __init get_cpuinfo(void)
 /*
  * Early parsing of the command line
  */
-static u32 mem_size __initdata;
+static u32 mem_size __initbss;
 
 /* "mem=" parsing. */
 static int __init early_mem(char *p)
@@ -247,7 +247,7 @@ early_param("memdma", early_memdma);
 
 int __init c6x_add_memory(phys_addr_t start, unsigned long size)
 {
-	static int ram_found __initdata;
+	static int ram_found __initbss;
 
 	/* We only handle one bank (the one with PAGE_OFFSET) for now */
 	if (ram_found)
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index efa3f0a..2c8d548 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -172,8 +172,8 @@ void __init __acpi_unmap_table(char *map, unsigned long size)
                             Boot-time Table Parsing
    -------------------------------------------------------------------------- */
 
-static int available_cpus __initdata;
-struct acpi_table_madt *acpi_madt __initdata;
+static int available_cpus __initbss;
+struct acpi_table_madt *acpi_madt __initbss;
 static u8 has_8259;
 
 static int __init
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 2889412..2a47003 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -167,7 +167,7 @@ static int cpe_poll_enabled = 1;
 
 extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
 
-static int mca_init __initdata;
+static int mca_init __initbss;
 
 /*
  * limited & delayed printing support for MCA/INIT handler
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 4f118b0..19de3a7 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -130,8 +130,8 @@ EXPORT_SYMBOL(ia64_max_iommu_merge_mask);
 /*
  * We use a special marker for the end of memory and it uses the extra (+1) slot
  */
-struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1] __initdata;
-int num_rsvd_regions __initdata;
+struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1] __initbss;
+int num_rsvd_regions __initbss;
 
 
 /*
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 0e76fad..a1baa1c 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -128,7 +128,7 @@ EXPORT_SYMBOL(ia64_cpu_to_sapicid);
 
 static cpumask_t cpu_callin_map;
 
-struct smp_boot_data smp_boot_data __initdata;
+struct smp_boot_data smp_boot_data __initbss;
 
 unsigned long ap_wakeup_vector = -1; /* External Int use to wakeup APs */
 
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 8786268..6aba1f7 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -44,8 +44,8 @@ struct early_node_data {
 	unsigned long max_pfn;
 };
 
-static struct early_node_data mem_data[MAX_NUMNODES] __initdata;
-static nodemask_t memory_less_mask __initdata;
+static struct early_node_data mem_data[MAX_NUMNODES] __initbss;
+static nodemask_t memory_less_mask __initbss;
 
 pg_data_t *pgdat_list[MAX_NUMNODES];
 
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 1841ef6..5ab0a85 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -591,7 +591,7 @@ find_max_min_low_pfn (u64 start, u64 end, void *arg)
  * purposes.
  */
 
-static int nolwsys __initdata;
+static int nolwsys __initbss;
 
 static int __init
 nolwsys_setup (char *s)
diff --git a/arch/m32r/kernel/setup.c b/arch/m32r/kernel/setup.c
index 0392112..410ff43 100644
--- a/arch/m32r/kernel/setup.c
+++ b/arch/m32r/kernel/setup.c
@@ -377,7 +377,7 @@ const struct seq_operations cpuinfo_op = {
 };
 #endif	/* CONFIG_PROC_FS */
 
-unsigned long cpu_initialized __initdata = 0;
+unsigned long cpu_initialized __initbss;
 
 /*
  * cpu_init() initializes state that is per-CPU. Some data is already
diff --git a/arch/m68k/kernel/bootinfo_proc.c b/arch/m68k/kernel/bootinfo_proc.c
index 2a33a96..2af8764 100644
--- a/arch/m68k/kernel/bootinfo_proc.c
+++ b/arch/m68k/kernel/bootinfo_proc.c
@@ -13,7 +13,7 @@
 #include <asm/byteorder.h>
 
 
-static char bootinfo_tmp[1536] __initdata;
+static char bootinfo_tmp[1536] __initbss;
 
 static void *bootinfo_copy;
 static size_t bootinfo_size;
diff --git a/arch/m68k/kernel/setup_mm.c b/arch/m68k/kernel/setup_mm.c
index 5b8ec4d..ca54c9e 100644
--- a/arch/m68k/kernel/setup_mm.c
+++ b/arch/m68k/kernel/setup_mm.c
@@ -75,9 +75,9 @@ unsigned long m68k_memoffset;
 struct m68k_mem_info m68k_memory[NUM_MEMINFO];
 EXPORT_SYMBOL(m68k_memory);
 
-static struct m68k_mem_info m68k_ramdisk __initdata;
+static struct m68k_mem_info m68k_ramdisk __initbss;
 
-static char m68k_command_line[CL_SIZE] __initdata;
+static char m68k_command_line[CL_SIZE] __initbss;
 
 void (*mach_sched_init) (irq_handler_t handler) __initdata = NULL;
 /* machine dependent irq functions */
diff --git a/arch/metag/kernel/setup.c b/arch/metag/kernel/setup.c
index 31cf53d..b7cf313 100644
--- a/arch/metag/kernel/setup.c
+++ b/arch/metag/kernel/setup.c
@@ -110,7 +110,7 @@ extern char _heap_start[];
 extern struct console dash_console;
 #endif
 
-const struct machine_desc *machine_desc __initdata;
+const struct machine_desc *machine_desc __initbss;
 
 /*
  * Map a Linux CPU number to a hardware thread ID
diff --git a/arch/mips/ar7/platform.c b/arch/mips/ar7/platform.c
index 58fca9a..7c8b9bc 100644
--- a/arch/mips/ar7/platform.c
+++ b/arch/mips/ar7/platform.c
@@ -563,7 +563,7 @@ static struct platform_device ar7_wdt = {
 static int __init ar7_register_uarts(void)
 {
 #ifdef CONFIG_SERIAL_8250
-	static struct uart_port uart_port __initdata;
+	static struct uart_port uart_port __initbss;
 	struct clk *bus_clk;
 	int res;
 
diff --git a/arch/mips/ath79/pci.c b/arch/mips/ath79/pci.c
index 730c0b0..5e5df1d 100644
--- a/arch/mips/ath79/pci.c
+++ b/arch/mips/ath79/pci.c
@@ -22,8 +22,8 @@
 #include "pci.h"
 
 static int (*ath79_pci_plat_dev_init)(struct pci_dev *dev);
-static const struct ath79_pci_irq *ath79_pci_irq_map __initdata;
-static unsigned ath79_pci_nr_irqs __initdata;
+static const struct ath79_pci_irq *ath79_pci_irq_map __initbss;
+static unsigned ath79_pci_nr_irqs __initbss;
 
 static const struct ath79_pci_irq ar71xx_pci_irq_map[] __initconst = {
 	{
diff --git a/arch/mips/bcm47xx/prom.c b/arch/mips/bcm47xx/prom.c
index 135a540..b5a8dcb 100644
--- a/arch/mips/bcm47xx/prom.c
+++ b/arch/mips/bcm47xx/prom.c
@@ -50,7 +50,7 @@ __init void bcm47xx_set_system_type(u16 chip_id)
 		 chip_id);
 }
 
-static unsigned long lowmem __initdata;
+static unsigned long lowmem __initbss;
 
 static __init void prom_init_mem(void)
 {
diff --git a/arch/mips/kernel/mips_machine.c b/arch/mips/kernel/mips_machine.c
index 8760975..cb81c3b 100644
--- a/arch/mips/kernel/mips_machine.c
+++ b/arch/mips/kernel/mips_machine.c
@@ -13,7 +13,7 @@
 #include <asm/mips_machine.h>
 #include <asm/prom.h>
 
-static struct mips_machine *mips_machine __initdata;
+static struct mips_machine *mips_machine __initbss;
 
 #define for_each_machine(mach) \
 	for ((mach) = (struct mips_machine *)&__mips_machines_start; \
diff --git a/arch/mips/kernel/pm-cps.c b/arch/mips/kernel/pm-cps.c
index f63a289..38b4cc3 100644
--- a/arch/mips/kernel/pm-cps.c
+++ b/arch/mips/kernel/pm-cps.c
@@ -70,8 +70,8 @@ static DEFINE_PER_CPU_ALIGNED(atomic_t, pm_barrier);
 DEFINE_PER_CPU_ALIGNED(struct mips_static_suspend_state, cps_cpu_state);
 
 /* A somewhat arbitrary number of labels & relocs for uasm */
-static struct uasm_label labels[32] __initdata;
-static struct uasm_reloc relocs[32] __initdata;
+static struct uasm_label labels[32] __initbss;
+static struct uasm_reloc relocs[32] __initbss;
 
 /* CPU dependant sync types */
 static unsigned stype_intervention;
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index 5b46b67..a688e3e 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -496,7 +496,7 @@ static void __init bootmem_init(void)
  * initialization hook for anything else was introduced.
  */
 
-static int usermem __initdata;
+static int usermem __initbss;
 
 static int __init early_parse_mem(char *p)
 {
diff --git a/arch/mips/lasat/serial.c b/arch/mips/lasat/serial.c
index 2e5fbed..39c675d 100644
--- a/arch/mips/lasat/serial.c
+++ b/arch/mips/lasat/serial.c
@@ -26,7 +26,7 @@
 #include <asm/lasat/lasat.h>
 #include <asm/lasat/serial.h>
 
-static struct resource lasat_serial_res[2] __initdata;
+static struct resource lasat_serial_res[2] __initbss;
 
 static struct plat_serial8250_port lasat_serial8250_port[] = {
 	{
diff --git a/arch/mips/mti-malta/malta-dtshim.c b/arch/mips/mti-malta/malta-dtshim.c
index f7133ef..72e6fea 100644
--- a/arch/mips/mti-malta/malta-dtshim.c
+++ b/arch/mips/mti-malta/malta-dtshim.c
@@ -17,7 +17,7 @@
 #include <asm/fw/fw.h>
 #include <asm/page.h>
 
-static unsigned char fdt_buf[16 << 10] __initdata;
+static unsigned char fdt_buf[16 << 10] __initbss;
 
 /* determined physical memory size, not overridden by command line args	 */
 extern unsigned long physical_memsize;
diff --git a/arch/mips/pci/pci.c b/arch/mips/pci/pci.c
index b8a0bf5..2ec3ed8 100644
--- a/arch/mips/pci/pci.c
+++ b/arch/mips/pci/pci.c
@@ -346,7 +346,7 @@ int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
 		vma->vm_end - vma->vm_start, vma->vm_page_prot);
 }
 
-char * (*pcibios_plat_setup)(char *str) __initdata;
+char * (*pcibios_plat_setup)(char *str) __initbss;
 
 char *__init pcibios_setup(char *str)
 {
diff --git a/arch/mips/rb532/prom.c b/arch/mips/rb532/prom.c
index 657210e..3ded361 100644
--- a/arch/mips/rb532/prom.c
+++ b/arch/mips/rb532/prom.c
@@ -69,7 +69,7 @@ static inline unsigned long tag2ul(char *arg, const char *tag)
 
 void __init prom_setup_cmdline(void)
 {
-	static char cmd_line[COMMAND_LINE_SIZE] __initdata;
+	static char cmd_line[COMMAND_LINE_SIZE] __initbss;
 	char *cp, *board;
 	int prom_argc;
 	char **prom_argv;
diff --git a/arch/mips/sgi-ip22/ip22-eisa.c b/arch/mips/sgi-ip22/ip22-eisa.c
index a0a7922..491e5ed 100644
--- a/arch/mips/sgi-ip22/ip22-eisa.c
+++ b/arch/mips/sgi-ip22/ip22-eisa.c
@@ -50,7 +50,7 @@
 
 static char __init *decode_eisa_sig(unsigned long addr)
 {
-	static char sig_str[EISA_SIG_LEN] __initdata;
+	static char sig_str[EISA_SIG_LEN] __initbss;
 	u8 sig[4];
 	u16 rev;
 	int i;
diff --git a/arch/mips/sgi-ip22/ip22-setup.c b/arch/mips/sgi-ip22/ip22-setup.c
index c7bdfe4..dcfdd03 100644
--- a/arch/mips/sgi-ip22/ip22-setup.c
+++ b/arch/mips/sgi-ip22/ip22-setup.c
@@ -64,7 +64,7 @@ void __init plat_mem_setup(void)
 	cserial = ArcGetEnvironmentVariable("ConsoleOut");
 
 	if ((ctype && *ctype == 'd') || (cserial && *cserial == 's')) {
-		static char options[8] __initdata;
+		static char options[8] __initbss;
 		char *baud = ArcGetEnvironmentVariable("dbaud");
 		if (baud)
 			strcpy(options, baud);
diff --git a/arch/mips/sgi-ip32/ip32-setup.c b/arch/mips/sgi-ip32/ip32-setup.c
index 3abd146..333e92a 100644
--- a/arch/mips/sgi-ip32/ip32-setup.c
+++ b/arch/mips/sgi-ip32/ip32-setup.c
@@ -90,7 +90,7 @@ void __init plat_mem_setup(void)
 	{
 		char* con = ArcGetEnvironmentVariable("console");
 		if (con && *con == 'd') {
-			static char options[8] __initdata;
+			static char options[8] __initbss;
 			char *baud = ArcGetEnvironmentVariable("dbaud");
 			if (baud)
 				strcpy(options, baud);
diff --git a/arch/mips/sni/setup.c b/arch/mips/sni/setup.c
index efad85c..42da945 100644
--- a/arch/mips/sni/setup.c
+++ b/arch/mips/sni/setup.c
@@ -62,7 +62,7 @@ static void __init sni_console_setup(void)
 	char *cdev;
 	char *baud;
 	int port;
-	static char options[8] __initdata;
+	static char options[8] __initbss;
 
 	cdev = prom_getenv("console_dev");
 	if (strncmp(cdev, "tty", 3) == 0) {
diff --git a/arch/mips/txx9/generic/pci.c b/arch/mips/txx9/generic/pci.c
index a77698f..05bd656 100644
--- a/arch/mips/txx9/generic/pci.c
+++ b/arch/mips/txx9/generic/pci.c
@@ -102,7 +102,7 @@ struct pci_controller txx9_primary_pcic = {
 #ifdef CONFIG_64BIT
 int txx9_pci_mem_high __initdata = 1;
 #else
-int txx9_pci_mem_high __initdata;
+int txx9_pci_mem_high __initbss;
 #endif
 
 /*
@@ -397,7 +397,7 @@ int __init pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin)
 	return txx9_board_vec->pci_map_irq(dev, slot, pin);
 }
 
-char * (*txx9_board_pcibios_setup)(char *str) __initdata;
+char * (*txx9_board_pcibios_setup)(char *str) __initbss;
 
 char *__init txx9_pcibios_setup(char *str)
 {
diff --git a/arch/mips/txx9/generic/setup.c b/arch/mips/txx9/generic/setup.c
index 9d9962a..4145140 100644
--- a/arch/mips/txx9/generic/setup.c
+++ b/arch/mips/txx9/generic/setup.c
@@ -78,7 +78,7 @@ unsigned int txx9_gbus_clock;
 
 #ifdef CONFIG_CPU_TX39XX
 /* don't enable by default - see errata */
-int txx9_ccfg_toeon __initdata;
+int txx9_ccfg_toeon __initbss;
 #else
 int txx9_ccfg_toeon __initdata = 1;
 #endif
@@ -121,7 +121,7 @@ EXPORT_SYMBOL(clk_put);
 #include <asm/txx9/boards.h>
 #undef BOARD_VEC
 
-struct txx9_board_vec *txx9_board_vec __initdata;
+struct txx9_board_vec *txx9_board_vec __initbss;
 static char txx9_system_type[32];
 
 static struct txx9_board_vec *board_vecs[] __initdata = {
@@ -175,8 +175,8 @@ static void __init prom_init_cmdline(void)
 	}
 }
 
-static int txx9_ic_disable __initdata;
-static int txx9_dc_disable __initdata;
+static int txx9_ic_disable __initbss;
+static int txx9_dc_disable __initbss;
 
 #if defined(CONFIG_CPU_TX49XX)
 /* flush all cache on very early stage (before 4k_cache_init) */
@@ -281,7 +281,7 @@ static inline void txx9_cache_fixup(void)
 
 static void __init preprocess_cmdline(void)
 {
-	static char cmdline[COMMAND_LINE_SIZE] __initdata;
+	static char cmdline[COMMAND_LINE_SIZE] __initbss;
 	char *s;
 
 	strcpy(cmdline, arcs_cmdline);
diff --git a/arch/openrisc/mm/ioremap.c b/arch/openrisc/mm/ioremap.c
index 62b08ef..ae7333d 100644
--- a/arch/openrisc/mm/ioremap.c
+++ b/arch/openrisc/mm/ioremap.c
@@ -27,7 +27,7 @@
 
 extern int mem_init_done;
 
-static unsigned int fixmaps_used __initdata;
+static unsigned int fixmaps_used __initbss;
 
 /*
  * Remap an arbitrary physical address space into the kernel virtual
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index c229427..b5f7b60 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -382,7 +382,7 @@ static void __init setup_bootmem(void)
 
 static int __init parisc_text_address(unsigned long vaddr)
 {
-	static unsigned long head_ptr __initdata;
+	static unsigned long head_ptr __initbss;
 
 	if (!head_ptr)
 		head_ptr = PAGE_MASK & (unsigned long)
diff --git a/arch/powerpc/kernel/prom_init.c b/arch/powerpc/kernel/prom_init.c
index 15099c4..08c2c04 100644
--- a/arch/powerpc/kernel/prom_init.c
+++ b/arch/powerpc/kernel/prom_init.c
@@ -147,7 +147,7 @@ extern void copy_and_flush(unsigned long dest, unsigned long src,
 /* prom structure */
 static struct prom_t __initdata prom;
 
-static unsigned long prom_entry __initdata;
+static unsigned long prom_entry __initbss;
 
 #define PROM_SCRATCH_SIZE 256
 
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 8d8a541..7afaa24 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -43,7 +43,7 @@
 
 static int numa_enabled = 1;
 
-static char *cmdline __initdata;
+static char *cmdline __initbss;
 
 static int numa_debug;
 #define dbg(args...) if (numa_debug) { printk(KERN_INFO args); }
diff --git a/arch/s390/kernel/smp.c b/arch/s390/kernel/smp.c
index dbd40d4..8e180b7 100644
--- a/arch/s390/kernel/smp.c
+++ b/arch/s390/kernel/smp.c
@@ -838,7 +838,7 @@ int __cpu_up(unsigned int cpu, struct task_struct *tidle)
 	return 0;
 }
 
-static unsigned int setup_possible_cpus __initdata;
+static unsigned int setup_possible_cpus __initbss;
 
 static int __init _setup_possible_cpus(char *s)
 {
diff --git a/arch/sh/drivers/pci/fixups-sdk7786.c b/arch/sh/drivers/pci/fixups-sdk7786.c
index 36eb6fc..98f4a02 100644
--- a/arch/sh/drivers/pci/fixups-sdk7786.c
+++ b/arch/sh/drivers/pci/fixups-sdk7786.c
@@ -23,7 +23,7 @@
  * Misconfigurations can be detected through the FPGA via the slot
  * resistors to determine card presence. Hotplug remains unsupported.
  */
-static unsigned int slot4en __initdata;
+static unsigned int slot4en __initbss;
 
 char *__init pcibios_setup(char *str)
 {
diff --git a/arch/sparc/kernel/irq_64.c b/arch/sparc/kernel/irq_64.c
index e22416c..768b80d 100644
--- a/arch/sparc/kernel/irq_64.c
+++ b/arch/sparc/kernel/irq_64.c
@@ -105,7 +105,7 @@ static void bucket_set_irq(unsigned long bucket_pa, unsigned int irq)
 
 #define irq_work_pa(__cpu)	&(trap_block[(__cpu)].irq_worklist_pa)
 
-static unsigned long hvirq_major __initdata;
+static unsigned long hvirq_major __initbss;
 static int __init early_hvirq_major(char *p)
 {
 	int rc = kstrtoul(p, 10, &hvirq_major);
diff --git a/arch/sparc/kernel/nmi.c b/arch/sparc/kernel/nmi.c
index a9973bb..9d8146b 100644
--- a/arch/sparc/kernel/nmi.c
+++ b/arch/sparc/kernel/nmi.c
@@ -45,7 +45,7 @@ EXPORT_SYMBOL(nmi_active);
 
 static unsigned int nmi_hz = HZ;
 static DEFINE_PER_CPU(short, wd_enabled);
-static int endflag __initdata;
+static int endflag __initbss;
 
 static DEFINE_PER_CPU(unsigned int, last_irq_sum);
 static DEFINE_PER_CPU(long, alert_counter);
diff --git a/arch/sparc/kernel/prom_common.c b/arch/sparc/kernel/prom_common.c
index 79cc0d1..5b5d6f5 100644
--- a/arch/sparc/kernel/prom_common.c
+++ b/arch/sparc/kernel/prom_common.c
@@ -142,7 +142,7 @@ static int __init prom_common_nextprop(phandle node, char *prev, char *buf)
 	return handle_nextprop_quirks(buf, name);
 }
 
-unsigned int prom_early_allocated __initdata;
+unsigned int prom_early_allocated __initbss;
 
 static struct of_pdt_ops prom_sparc_ops __initdata = {
 	.nextprop = prom_common_nextprop,
diff --git a/arch/sparc/kernel/setup_32.c b/arch/sparc/kernel/setup_32.c
index baef495..31e58bf 100644
--- a/arch/sparc/kernel/setup_32.c
+++ b/arch/sparc/kernel/setup_32.c
@@ -99,11 +99,11 @@ static void prom_sync_me(void)
 	local_irq_restore(flags);
 }
 
-static unsigned int boot_flags __initdata = 0;
+static unsigned int boot_flags __initbss;
 #define BOOTME_DEBUG  0x1
 
 /* Exported for mm/init.c:paging_init. */
-unsigned long cmdline_memory_size __initdata = 0;
+unsigned long cmdline_memory_size __initbss;
 
 /* which CPU booted us (0xff = not set) */
 unsigned char boot_cpu_id = 0xff; /* 0xff will make it into DATA section... */
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 4ac88b7..9bdec47 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -1363,8 +1363,8 @@ static unsigned long __init bootmem_init(unsigned long phys_base)
 	return end_pfn;
 }
 
-static struct linux_prom64_registers pall[MAX_BANKS] __initdata;
-static int pall_ents __initdata;
+static struct linux_prom64_registers pall[MAX_BANKS] __initbss;
+static int pall_ents __initbss;
 
 static unsigned long max_phys_bits = 40;
 
diff --git a/arch/sparc/prom/bootstr_32.c b/arch/sparc/prom/bootstr_32.c
index d2b49d2..f35618c 100644
--- a/arch/sparc/prom/bootstr_32.c
+++ b/arch/sparc/prom/bootstr_32.c
@@ -10,7 +10,7 @@
 
 #define BARG_LEN  256
 static char barg_buf[BARG_LEN] = { 0 };
-static char fetched __initdata = 0;
+static char fetched __initbss;
 
 char * __init
 prom_getbootargs(void)
diff --git a/arch/um/kernel/um_arch.c b/arch/um/kernel/um_arch.c
index 16630e7..9bad858 100644
--- a/arch/um/kernel/um_arch.c
+++ b/arch/um/kernel/um_arch.c
@@ -113,7 +113,7 @@ unsigned long end_vm;
 int ncpus = 1;
 
 /* Set in early boot */
-static int have_root __initdata = 0;
+static int have_root __initbss;
 
 /* Set in uml_mem_setup and modified in linux_main */
 long long physmem_size = 32 * 1024 * 1024;
diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
index 3fa317f..4464f08 100644
--- a/arch/unicore32/kernel/setup.c
+++ b/arch/unicore32/kernel/setup.c
@@ -224,7 +224,7 @@ request_standard_resources(struct meminfo *mi)
 	}
 }
 
-static void (*init_machine)(void) __initdata;
+static void (*init_machine)(void) __initbss;
 
 static int __init customize_machine(void)
 {
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 5488526..168984d 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -66,11 +66,11 @@ int acpi_ioapic;
 int acpi_strict;
 int acpi_disable_cmcff;
 
-u8 acpi_sci_flags __initdata;
-int acpi_sci_override_gsi __initdata;
-int acpi_skip_timer_override __initdata;
-int acpi_use_timer_override __initdata;
-int acpi_fix_pin2_polarity __initdata;
+u8 acpi_sci_flags __initbss;
+int acpi_sci_override_gsi __initbss;
+int acpi_skip_timer_override __initbss;
+int acpi_use_timer_override __initbss;
+int acpi_fix_pin2_polarity __initbss;
 
 #ifdef CONFIG_X86_LOCAL_APIC
 static u64 acpi_lapic_addr __initdata = APIC_DEFAULT_PHYS_BASE;
@@ -806,7 +806,7 @@ static int __init acpi_parse_sbf(struct acpi_table_header *table)
 #ifdef CONFIG_HPET_TIMER
 #include <asm/hpet.h>
 
-static struct resource *hpet_res __initdata;
+static struct resource *hpet_res __initbss;
 
 static int __init acpi_parse_hpet(struct acpi_table_header *table)
 {
diff --git a/arch/x86/kernel/aperture_64.c b/arch/x86/kernel/aperture_64.c
index 6e85f71..9f45d06 100644
--- a/arch/x86/kernel/aperture_64.c
+++ b/arch/x86/kernel/aperture_64.c
@@ -47,11 +47,11 @@
 #define GART_MAX_ADDR	(1ULL   << 32)
 
 int gart_iommu_aperture;
-int gart_iommu_aperture_disabled __initdata;
-int gart_iommu_aperture_allowed __initdata;
+int gart_iommu_aperture_disabled __initbss;
+int gart_iommu_aperture_allowed __initbss;
 
 int fallback_aper_order __initdata = 1; /* 64MB */
-int fallback_aper_force __initdata;
+int fallback_aper_force __initbss;
 
 int fix_aperture __initdata = 1;
 
diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index 2f69e3b..7214e62 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -132,7 +132,7 @@ static inline void imcr_apic_to_pic(void)
  *
  * +1=force-enable
  */
-static int force_enable_local_apic __initdata;
+static int force_enable_local_apic __initbss;
 
 /*
  * APIC command line parameters
@@ -148,7 +148,7 @@ static int __init parse_lapic(char *arg)
 early_param("lapic", parse_lapic);
 
 #ifdef CONFIG_X86_64
-static int apic_calibrate_pmtmr __initdata;
+static int apic_calibrate_pmtmr __initbss;
 static __init int setup_apicpmtimer(char *s)
 {
 	apic_calibrate_pmtmr = 1;
@@ -161,7 +161,7 @@ __setup("apicpmtimer", setup_apicpmtimer);
 unsigned long mp_lapic_addr;
 int disable_apic;
 /* Disable local APIC timer from the kernel commandline or via dmi quirk */
-static int disable_apic_timer __initdata;
+static int disable_apic_timer __initbss;
 /* Local APIC timer works in C2 */
 int local_apic_timer_c2_ok;
 EXPORT_SYMBOL_GPL(local_apic_timer_c2_ok);
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 5c60bb1..b8b5a69 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -1598,7 +1598,7 @@ void __init setup_ioapic_ids_from_mpc(void)
 }
 #endif
 
-int no_timer_check __initdata;
+int no_timer_check __initbss;
 
 static int __init notimercheck(char *s)
 {
@@ -2009,7 +2009,7 @@ static inline void __init unlock_ExtINT_logic(void)
 	ioapic_write_entry(apic, pin, entry0);
 }
 
-static int disable_timer_pin_1 __initdata;
+static int disable_timer_pin_1 __initbss;
 /* Actually the next is obsolete, but keep it for paranoid reasons -AK */
 static int __init disable_timer_pin_setup(char *arg)
 {
diff --git a/arch/x86/kernel/apic/probe_32.c b/arch/x86/kernel/apic/probe_32.c
index 7694ae6..4de57c5 100644
--- a/arch/x86/kernel/apic/probe_32.c
+++ b/arch/x86/kernel/apic/probe_32.c
@@ -129,7 +129,7 @@ apic_driver(apic_default);
 struct apic *apic = &apic_default;
 EXPORT_SYMBOL_GPL(apic);
 
-static int cmdline_apic __initdata;
+static int cmdline_apic __initbss;
 static int __init parse_apic(char *arg)
 {
 	struct apic **drv;
diff --git a/arch/x86/kernel/cpu/mtrr/cleanup.c b/arch/x86/kernel/cpu/mtrr/cleanup.c
index 70d7c93..bbd1f3f 100644
--- a/arch/x86/kernel/cpu/mtrr/cleanup.c
+++ b/arch/x86/kernel/cpu/mtrr/cleanup.c
@@ -449,7 +449,7 @@ static int __init parse_mtrr_chunk_size_opt(char *p)
 early_param("mtrr_chunk_size", parse_mtrr_chunk_size_opt);
 
 /* Granularity of mtrr of block: */
-static u64 mtrr_gran_size __initdata;
+static u64 mtrr_gran_size __initbss;
 
 static int __init parse_mtrr_gran_size_opt(char *p)
 {
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 569c1e4..f8ef6e3 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -259,10 +259,10 @@ static int __init cpcompare(const void *a, const void *b)
 int __init sanitize_e820_map(struct e820entry *biosmap, int max_nr_map,
 			     u32 *pnr_map)
 {
-	static struct change_member change_point_list[2*E820_X_MAX] __initdata;
-	static struct change_member *change_point[2*E820_X_MAX] __initdata;
-	static struct e820entry *overlap_list[E820_X_MAX] __initdata;
-	static struct e820entry new_bios[E820_X_MAX] __initdata;
+	static struct change_member change_point_list[2*E820_X_MAX] __initbss;
+	static struct change_member *change_point[2*E820_X_MAX] __initbss;
+	static struct e820entry *overlap_list[E820_X_MAX] __initbss;
+	static struct e820entry new_bios[E820_X_MAX] __initbss;
 	unsigned long current_type, last_type;
 	unsigned long long last_addr;
 	int chgidx;
@@ -807,7 +807,7 @@ static void early_panic(char *msg)
 	panic(msg);
 }
 
-static int userdef __initdata;
+static int userdef __initbss;
 
 /* "mem=nopentium" disables the 4MB page tables. */
 static int __init parse_memopt(char *p)
diff --git a/arch/x86/kernel/fpu/init.c b/arch/x86/kernel/fpu/init.c
index be39b5f..94f5e45 100644
--- a/arch/x86/kernel/fpu/init.c
+++ b/arch/x86/kernel/fpu/init.c
@@ -103,7 +103,7 @@ static void __init fpu__init_system_mxcsr(void)
 
 	if (cpu_has_fxsr) {
 		/* Static because GCC does not get 16-byte stack alignment right: */
-		static struct fxregs_state fxregs __initdata;
+		static struct fxregs_state fxregs __initbss;
 
 		asm volatile("fxsave %0" : "+m" (fxregs));
 
diff --git a/arch/x86/kernel/nmi_selftest.c b/arch/x86/kernel/nmi_selftest.c
index 6d9582e..d7ff617 100644
--- a/arch/x86/kernel/nmi_selftest.c
+++ b/arch/x86/kernel/nmi_selftest.c
@@ -25,7 +25,7 @@
 static int __initdata nmi_fail;
 
 /* check to see if NMI IPIs work on this machine */
-static DECLARE_BITMAP(nmi_ipi_mask, NR_CPUS) __initdata;
+static DECLARE_BITMAP(nmi_ipi_mask, NR_CPUS) __initbss;
 
 static int __initdata testcase_total;
 static int __initdata testcase_successes;
diff --git a/arch/x86/kernel/pci-calgary_64.c b/arch/x86/kernel/pci-calgary_64.c
index 0497f71..6ade439 100644
--- a/arch/x86/kernel/pci-calgary_64.c
+++ b/arch/x86/kernel/pci-calgary_64.c
@@ -160,9 +160,9 @@ unsigned int specified_table_size = TCE_TABLE_SIZE_UNSPECIFIED;
 static int translate_empty_slots __read_mostly = 0;
 static int calgary_detected __read_mostly = 0;
 
-static struct rio_table_hdr	*rio_table_hdr __initdata;
-static struct scal_detail	*scal_devs[MAX_NUMNODES] __initdata;
-static struct rio_detail	*rio_devs[MAX_NUMNODES * 4] __initdata;
+static struct rio_table_hdr	*rio_table_hdr __initbss;
+static struct scal_detail	*scal_devs[MAX_NUMNODES] __initbss;
+static struct rio_detail	*rio_devs[MAX_NUMNODES * 4] __initbss;
 
 struct calgary_bus_info {
 	void *tce_space;
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index e5a3b35..62fec24 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -21,8 +21,8 @@
 #include "numa_internal.h"
 
 int __initdata numa_off;
-nodemask_t numa_nodes_parsed __initdata;
-static nodemask_t numa_nodes_empty __initdata;
+nodemask_t numa_nodes_parsed __initbss;
+static nodemask_t numa_nodes_empty __initbss;
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index a8f90ce..2bb78bb 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -11,7 +11,7 @@
 #include "numa_internal.h"
 
 static int emu_nid_to_phys[MAX_NUMNODES];
-static char *emu_cmdline __initdata;
+static char *emu_cmdline __initbss;
 
 void __init numa_emu_cmdline(char *str)
 {
@@ -309,8 +309,8 @@ static int __init split_nodes_size_interleave(struct numa_meminfo *ei,
  */
 void __init numa_emulation(struct numa_meminfo *numa_meminfo, int numa_dist_cnt)
 {
-	static struct numa_meminfo ei __initdata;
-	static struct numa_meminfo pi __initdata;
+	static struct numa_meminfo ei __initbss;
+	static struct numa_meminfo pi __initbss;
 	const u64 max_addr = PFN_PHYS(max_pfn);
 	u8 *phys_dist = NULL;
 	size_t phys_size = numa_dist_cnt * numa_dist_cnt * sizeof(phys_dist[0]);
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index c2aea63..74f752c 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -24,7 +24,7 @@
 #include <asm/apic.h>
 #include <asm/uv/uv.h>
 
-int acpi_numa __initdata;
+int acpi_numa __initbss;
 
 static __init int setup_node(int pxm)
 {
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index f55f223..c67fcf4 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -58,8 +58,8 @@
 
 struct efi_memory_map memmap;
 
-static struct efi efi_phys __initdata;
-static efi_system_table_t efi_systab __initdata;
+static struct efi efi_phys __initbss;
+static efi_system_table_t efi_systab __initbss;
 
 static efi_config_table_type_t arch_tables[] __initdata = {
 #ifdef CONFIG_X86_UV
@@ -70,7 +70,7 @@ static efi_config_table_type_t arch_tables[] __initdata = {
 
 u64 efi_setup;		/* efi setup_data physical address */
 
-static int add_efi_memmap __initdata;
+static int add_efi_memmap __initbss;
 static int __init setup_add_efi_memmap(char *arg)
 {
 	add_efi_memmap = 1;
diff --git a/arch/x86/platform/olpc/olpc_dt.c b/arch/x86/platform/olpc/olpc_dt.c
index d6ee929..9205980 100644
--- a/arch/x86/platform/olpc/olpc_dt.c
+++ b/arch/x86/platform/olpc/olpc_dt.c
@@ -124,7 +124,7 @@ static int __init olpc_dt_pkg2path(phandle node, char *buf,
 	return 0;
 }
 
-static unsigned int prom_early_allocated __initdata;
+static unsigned int prom_early_allocated __initbss;
 
 void * __init prom_early_alloc(unsigned long size)
 {
diff --git a/arch/x86/platform/olpc/olpc_ofw.c b/arch/x86/platform/olpc/olpc_ofw.c
index e7604f6..2ac3d9f 100644
--- a/arch/x86/platform/olpc/olpc_ofw.c
+++ b/arch/x86/platform/olpc/olpc_ofw.c
@@ -11,7 +11,7 @@
 static int (*olpc_ofw_cif)(int *);
 
 /* page dir entry containing OFW's pgdir table; filled in by head_32.S */
-u32 olpc_ofw_pgd __initdata;
+u32 olpc_ofw_pgd __initbss;
 
 static DEFINE_SPINLOCK(ofw_lock);
 
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 9c479fe..34ed265 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -116,7 +116,7 @@ static pud_t level3_user_vsyscall[PTRS_PER_PUD] __page_aligned_bss;
 DEFINE_PER_CPU(unsigned long, xen_cr3);	 /* cr3 stored as physaddr */
 DEFINE_PER_CPU(unsigned long, xen_current_cr3);	 /* actual vcpu cr3 */
 
-static phys_addr_t xen_pt_base, xen_pt_size __initdata;
+static phys_addr_t xen_pt_base, xen_pt_size __initbss;
 
 /*
  * Just beyond the highest usermode address.  STACK_TOP_MAX has a
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 2f46c46..f88fb64 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -35,14 +35,14 @@
 #define GB(x) ((uint64_t)(x) * 1024 * 1024 * 1024)
 
 /* Amount of extra memory space we add to the e820 ranges */
-struct xen_memory_region xen_extra_mem[XEN_EXTRA_MEM_MAX_REGIONS] __initdata;
+struct xen_memory_region xen_extra_mem[XEN_EXTRA_MEM_MAX_REGIONS] __initbss;
 
 /* Number of pages released from the initial allocation. */
 unsigned long xen_released_pages;
 
 /* E820 map used during setting up memory. */
-static struct e820entry xen_e820_map[E820MAX] __initdata;
-static u32 xen_e820_map_entries __initdata;
+static struct e820entry xen_e820_map[E820MAX] __initbss;
+static u32 xen_e820_map_entries __initbss;
 
 /*
  * Buffer used to remap identity mapped pages. We only need the virtual space.
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index 9a9a593..881243d 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -31,7 +31,7 @@
 #include <asm/sections.h>
 #include <asm/sysmem.h>
 
-struct sysmem_info sysmem __initdata;
+struct sysmem_info sysmem __initbss;
 
 static void __init sysmem_dump(void)
 {
diff --git a/drivers/acpi/blacklist.c b/drivers/acpi/blacklist.c
index 96809cd..e8c088d 100644
--- a/drivers/acpi/blacklist.c
+++ b/drivers/acpi/blacklist.c
@@ -47,7 +47,7 @@ struct acpi_blacklist_item {
 	u32 is_critical_error;
 };
 
-static struct dmi_system_id acpi_osi_dmi_table[] __initdata;
+static struct dmi_system_id acpi_osi_dmi_table[] __initbss;
 
 /*
  * POLICY: If *anything* doesn't work, put it on the blacklist.
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 72b6e9e..39b8aac 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -42,7 +42,7 @@ static int pxm_to_node_map[MAX_PXM_DOMAINS]
 static int node_to_pxm_map[MAX_NUMNODES]
 			= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
 
-unsigned char acpi_srat_revision __initdata;
+unsigned char acpi_srat_revision __initbss;
 
 int pxm_to_node(int pxm)
 {
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index a2ed38a..0e8cb29 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -38,9 +38,9 @@
 static char *mps_inti_flags_polarity[] = { "dfl", "high", "res", "low" };
 static char *mps_inti_flags_trigger[] = { "dfl", "edge", "res", "level" };
 
-static struct acpi_table_desc initial_tables[ACPI_MAX_TABLES] __initdata;
+static struct acpi_table_desc initial_tables[ACPI_MAX_TABLES] __initbss;
 
-static int acpi_apic_instance __initdata;
+static int acpi_apic_instance __initbss;
 
 /*
  * Disable table checksum verification for the early stage due to the size
diff --git a/drivers/ata/libata-core.c b/drivers/ata/libata-core.c
index b79cb10..f08c5f0 100644
--- a/drivers/ata/libata-core.c
+++ b/drivers/ata/libata-core.c
@@ -123,7 +123,7 @@ struct ata_force_ent {
 static struct ata_force_ent *ata_force_tbl;
 static int ata_force_tbl_size;
 
-static char ata_force_param_buf[PAGE_SIZE] __initdata;
+static char ata_force_param_buf[PAGE_SIZE] __initbss;
 /* param_buf is thrown away after initialization, disallow read */
 module_param_string(force, ata_force_param_buf, sizeof(ata_force_param_buf), 0);
 MODULE_PARM_DESC(force, "Force ATA configurations including cable type, link speed and transfer mode (see Documentation/kernel-parameters.txt for details)");
diff --git a/drivers/clk/imx/clk-imx1.c b/drivers/clk/imx/clk-imx1.c
index 99cf802..70ac020 100644
--- a/drivers/clk/imx/clk-imx1.c
+++ b/drivers/clk/imx/clk-imx1.c
@@ -38,7 +38,7 @@ static const char *clko_sel_clks[] = { "per1", "hclk", "clk48m", "clk16m",
 static struct clk *clk[IMX1_CLK_MAX];
 static struct clk_onecell_data clk_data;
 
-static void __iomem *ccm __initdata;
+static void __iomem *ccm __initbss;
 #define CCM_CSCR	(ccm + 0x0000)
 #define CCM_MPCTL0	(ccm + 0x0004)
 #define CCM_SPCTL0	(ccm + 0x000c)
diff --git a/drivers/clk/imx/clk-imx21.c b/drivers/clk/imx/clk-imx21.c
index e63188e..701c67f 100644
--- a/drivers/clk/imx/clk-imx21.c
+++ b/drivers/clk/imx/clk-imx21.c
@@ -23,7 +23,7 @@
 #define MX21_GPT1_BASE_ADDR	0x10003000
 #define MX21_INT_GPT1		(NR_IRQS_LEGACY + 26)
 
-static void __iomem *ccm __initdata;
+static void __iomem *ccm __initbss;
 
 /* Register offsets */
 #define CCM_CSCR	(ccm + 0x00)
diff --git a/drivers/clk/imx/clk-imx27.c b/drivers/clk/imx/clk-imx27.c
index 0d7b8df..9e4c34c 100644
--- a/drivers/clk/imx/clk-imx27.c
+++ b/drivers/clk/imx/clk-imx27.c
@@ -15,7 +15,7 @@
 #define MX27_GPT1_BASE_ADDR	0x10003000
 #define MX27_INT_GPT1		(NR_IRQS_LEGACY + 26)
 
-static void __iomem *ccm __initdata;
+static void __iomem *ccm __initbss;
 
 /* Register offsets */
 #define CCM_CSCR		(ccm + 0x00)
diff --git a/drivers/clk/imx/clk.c b/drivers/clk/imx/clk.c
index a634b11..987e6212 100644
--- a/drivers/clk/imx/clk.c
+++ b/drivers/clk/imx/clk.c
@@ -74,8 +74,8 @@ void imx_cscmr1_fixup(u32 *val)
 	return;
 }
 
-static int imx_keep_uart_clocks __initdata;
-static struct clk ** const *imx_uart_clocks __initdata;
+static int imx_keep_uart_clocks __initbss;
+static struct clk ** const *imx_uart_clocks __initbss;
 
 static int __init imx_keep_uart_clocks_param(char *str)
 {
diff --git a/drivers/clk/mediatek/clk-mt8173.c b/drivers/clk/mediatek/clk-mt8173.c
index 227e356..305ea73 100644
--- a/drivers/clk/mediatek/clk-mt8173.c
+++ b/drivers/clk/mediatek/clk-mt8173.c
@@ -890,8 +890,8 @@ static const struct mtk_gate venclt_clks[] __initconst = {
 	GATE_VENCLT(CLK_VENCLT_CKE1, "venclt_cke1", "venclt_sel", 4),
 };
 
-static struct clk_onecell_data *mt8173_top_clk_data __initdata;
-static struct clk_onecell_data *mt8173_pll_clk_data __initdata;
+static struct clk_onecell_data *mt8173_top_clk_data __initbss;
+static struct clk_onecell_data *mt8173_pll_clk_data __initbss;
 
 static void __init mtk_clk_enable_critical(void)
 {
diff --git a/drivers/clk/shmobile/clk-r8a7740.c b/drivers/clk/shmobile/clk-r8a7740.c
index 1e6b1da..e11acb2 100644
--- a/drivers/clk/shmobile/clk-r8a7740.c
+++ b/drivers/clk/shmobile/clk-r8a7740.c
@@ -59,7 +59,7 @@ static const struct clk_div_table div4_div_table[] = {
 	{ 13, 72 }, { 14, 96 }, { 0, 0 }
 };
 
-static u32 cpg_mode __initdata;
+static u32 cpg_mode __initbss;
 
 static struct clk * __init
 r8a7740_cpg_register_clock(struct device_node *np, struct r8a7740_cpg *cpg,
diff --git a/drivers/clk/shmobile/clk-r8a7778.c b/drivers/clk/shmobile/clk-r8a7778.c
index 87c1d2f..cd7fa09 100644
--- a/drivers/clk/shmobile/clk-r8a7778.c
+++ b/drivers/clk/shmobile/clk-r8a7778.c
@@ -45,8 +45,8 @@ struct {
 	{ "s1",  { 8,  6,  8,  6  } },
 };
 
-static u32 cpg_mode_rates __initdata;
-static u32 cpg_mode_divs __initdata;
+static u32 cpg_mode_rates __initbss;
+static u32 cpg_mode_divs __initbss;
 
 static struct clk * __init
 r8a7778_cpg_register_clock(struct device_node *np, struct r8a7778_cpg *cpg,
diff --git a/drivers/clk/shmobile/clk-r8a7779.c b/drivers/clk/shmobile/clk-r8a7779.c
index 92275c5f..22e3b67 100644
--- a/drivers/clk/shmobile/clk-r8a7779.c
+++ b/drivers/clk/shmobile/clk-r8a7779.c
@@ -88,7 +88,7 @@ static const unsigned int cpg_plla_mult[4] __initconst = { 42, 48, 56, 64 };
  * Initialization
  */
 
-static u32 cpg_mode __initdata;
+static u32 cpg_mode __initbss;
 
 static struct clk * __init
 r8a7779_cpg_register_clock(struct device_node *np, struct r8a7779_cpg *cpg,
diff --git a/drivers/clk/shmobile/clk-rcar-gen2.c b/drivers/clk/shmobile/clk-rcar-gen2.c
index 745496f..6abd23c 100644
--- a/drivers/clk/shmobile/clk-rcar-gen2.c
+++ b/drivers/clk/shmobile/clk-rcar-gen2.c
@@ -295,7 +295,7 @@ static const struct clk_div_table cpg_sd01_div_table[] = {
  * Initialization
  */
 
-static u32 cpg_mode __initdata;
+static u32 cpg_mode __initbss;
 
 static struct clk * __init
 rcar_gen2_cpg_register_clock(struct device_node *np, struct rcar_gen2_cpg *cpg,
diff --git a/drivers/clocksource/arm_arch_timer.c b/drivers/clocksource/arm_arch_timer.c
index c64d543..58261c9 100644
--- a/drivers/clocksource/arm_arch_timer.c
+++ b/drivers/clocksource/arm_arch_timer.c
@@ -42,7 +42,7 @@
 
 #define ARCH_CP15_TIMER	BIT(0)
 #define ARCH_MEM_TIMER	BIT(1)
-static unsigned arch_timers_present __initdata;
+static unsigned arch_timers_present __initbss;
 
 static void __iomem *arch_counter_base;
 
diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index ac1ce4a..a9f8e3b 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -20,7 +20,7 @@ EXPORT_SYMBOL_GPL(dmi_kobj);
  */
 static const char dmi_empty_string[] = "        ";
 
-static u32 dmi_ver __initdata;
+static u32 dmi_ver __initbss;
 static u32 dmi_len;
 static u16 dmi_num;
 static u8 smbios_entry_point[32];
@@ -32,7 +32,7 @@ static int smbios_entry_point_size;
 static int dmi_initialized;
 
 /* DMI system identification string used during boot */
-static char dmi_ids_string[128] __initdata;
+static char dmi_ids_string[128] __initbss;
 
 static struct dmi_memdev_info {
 	const char *device;
diff --git a/drivers/gpu/drm/drm_modes.c b/drivers/gpu/drm/drm_modes.c
index cd74a09..1d0ec51 100644
--- a/drivers/gpu/drm/drm_modes.c
+++ b/drivers/gpu/drm/drm_modes.c
@@ -1491,4 +1491,4 @@ int drm_mode_convert_umode(struct drm_display_mode *out,
 
 out:
 	return ret;
-}
\ No newline at end of file
+}
diff --git a/drivers/input/serio/i8042.c b/drivers/input/serio/i8042.c
index db91de5..c3ca199 100644
--- a/drivers/input/serio/i8042.c
+++ b/drivers/input/serio/i8042.c
@@ -685,8 +685,8 @@ static int __init i8042_check_mux(void)
 /*
  * The following is used to test AUX IRQ delivery.
  */
-static struct completion i8042_aux_irq_delivered __initdata;
-static bool i8042_irq_being_tested __initdata;
+static struct completion i8042_aux_irq_delivered __initbss;
+static bool i8042_irq_being_tested __initbss;
 
 static irqreturn_t __init i8042_aux_test_irq(int irq, void *dev_id)
 {
diff --git a/drivers/irqchip/irq-gic.c b/drivers/irqchip/irq-gic.c
index 2518c55..bf1a380 100644
--- a/drivers/irqchip/irq-gic.c
+++ b/drivers/irqchip/irq-gic.c
@@ -1100,7 +1100,7 @@ void __init gic_init_bases(unsigned int gic_nr, int irq_start,
 }
 
 #ifdef CONFIG_OF
-static int gic_cnt __initdata;
+static int gic_cnt __initbss;
 
 static bool gic_check_eoimode(struct device_node *node, void __iomem **base)
 {
@@ -1195,7 +1195,7 @@ IRQCHIP_DECLARE(pl390, "arm,pl390", gic_of_init);
 #endif
 
 #ifdef CONFIG_ACPI
-static phys_addr_t cpu_phy_base __initdata;
+static phys_addr_t cpu_phy_base __initbss;
 
 static int __init
 gic_acpi_parse_madt_cpu(struct acpi_subtable_header *header,
diff --git a/drivers/mtd/ubi/block.c b/drivers/mtd/ubi/block.c
index ebf46ad..a65bfb7 100644
--- a/drivers/mtd/ubi/block.c
+++ b/drivers/mtd/ubi/block.c
@@ -75,10 +75,10 @@ struct ubiblock_pdu {
 };
 
 /* Numbers of elements set in the @ubiblock_param array */
-static int ubiblock_devs __initdata;
+static int ubiblock_devs __initbss;
 
 /* MTD devices specification parameters */
-static struct ubiblock_param ubiblock_param[UBIBLOCK_MAX_DEVICES] __initdata;
+static struct ubiblock_param ubiblock_param[UBIBLOCK_MAX_DEVICES] __initbss;
 
 struct ubiblock {
 	struct ubi_volume_desc *desc;
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 0d9b45f..9e0ab87 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -79,7 +79,7 @@ static int numcards;
 #define BUFFER_SIZE (512)
 #define MIRROR_SIZE (BUFFER_SIZE * 4)
 
-static int com90xx_skip_probe __initdata = 0;
+static int com90xx_skip_probe __initbss;
 
 /* Module parameters */
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 8fef8d8..2b0a8a0 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -153,8 +153,8 @@ static const char  version[] =
 	"Granch SBNI12 driver ver 5.0.1  Jun 22 2001  Denis I.Timofeev.\n";
 
 static bool skip_pci_probe	__initdata = false;
-static int  scandone	__initdata = 0;
-static int  num		__initdata = 0;
+static int  scandone	__initbss;
+static int  num		__initbss;
 
 static unsigned char  rxl_tab[];
 static u32  crc32tab[];
@@ -165,11 +165,11 @@ static struct net_device  *sbni_cards[ SBNI_MAX_NUM_CARDS ];
 /* Lists of device's parameters */
 static u32	io[   SBNI_MAX_NUM_CARDS ] __initdata =
 	{ [0 ... SBNI_MAX_NUM_CARDS-1] = -1 };
-static u32	irq[  SBNI_MAX_NUM_CARDS ] __initdata;
-static u32	baud[ SBNI_MAX_NUM_CARDS ] __initdata;
+static u32	irq[  SBNI_MAX_NUM_CARDS ] __initbss;
+static u32	baud[ SBNI_MAX_NUM_CARDS ] __initbss;
 static u32	rxl[  SBNI_MAX_NUM_CARDS ] __initdata =
 	{ [0 ... SBNI_MAX_NUM_CARDS-1] = -1 };
-static u32	mac[  SBNI_MAX_NUM_CARDS ] __initdata;
+static u32	mac[  SBNI_MAX_NUM_CARDS ] __initbss;
 
 #ifndef MODULE
 typedef u32  iarr[];
diff --git a/drivers/of/pdt.c b/drivers/of/pdt.c
index d2acae8..fd57c97 100644
--- a/drivers/of/pdt.c
+++ b/drivers/of/pdt.c
@@ -23,12 +23,12 @@
 #include <linux/of.h>
 #include <linux/of_pdt.h>
 
-static struct of_pdt_ops *of_pdt_prom_ops __initdata;
+static struct of_pdt_ops *of_pdt_prom_ops __initbss;
 
 void __initdata (*of_pdt_build_more)(struct device_node *dp);
 
 #if defined(CONFIG_SPARC)
-unsigned int of_pdt_unique_id __initdata;
+unsigned int of_pdt_unique_id __initbss;
 
 #define of_pdt_incr_unique_id(p) do { \
 	(p)->unique_id = of_pdt_unique_id++; \
diff --git a/drivers/parport/parport_pc.c b/drivers/parport/parport_pc.c
index 78530d1..95517df 100644
--- a/drivers/parport/parport_pc.c
+++ b/drivers/parport/parport_pc.c
@@ -3220,7 +3220,7 @@ static int __init parse_parport_params(void)
 
 #else
 
-static int parport_setup_ptr __initdata;
+static int parport_setup_ptr __initbss;
 
 /*
  * Acceptable parameters:
diff --git a/drivers/pci/pci-stub.c b/drivers/pci/pci-stub.c
index 886fb35..44e7d28 100644
--- a/drivers/pci/pci-stub.c
+++ b/drivers/pci/pci-stub.c
@@ -19,7 +19,7 @@
 #include <linux/module.h>
 #include <linux/pci.h>
 
-static char ids[1024] __initdata;
+static char ids[1024] __initbss;
 
 module_param_string(ids, ids, sizeof(ids), 0);
 MODULE_PARM_DESC(ids, "Initial PCI IDs to add to the stub driver, format is "
diff --git a/drivers/platform/x86/acer-wmi.c b/drivers/platform/x86/acer-wmi.c
index d773b9d..ece34cb 100644
--- a/drivers/platform/x86/acer-wmi.c
+++ b/drivers/platform/x86/acer-wmi.c
@@ -793,7 +793,7 @@ static acpi_status __init AMW0_find_mailled(void)
 	return AE_OK;
 }
 
-static int AMW0_set_cap_acpi_check_device_found __initdata;
+static int AMW0_set_cap_acpi_check_device_found __initbss;
 
 static acpi_status __init AMW0_set_cap_acpi_check_device_cb(acpi_handle handle,
 	u32 level, void *context, void **retval)
diff --git a/drivers/pnp/pnpacpi/core.c b/drivers/pnp/pnpacpi/core.c
index 9113876..4e951cd 100644
--- a/drivers/pnp/pnpacpi/core.c
+++ b/drivers/pnp/pnpacpi/core.c
@@ -309,7 +309,7 @@ static acpi_status __init pnpacpi_add_device_handler(acpi_handle handle,
 	return AE_OK;
 }
 
-int pnpacpi_disabled __initdata;
+int pnpacpi_disabled __initbss;
 static int __init pnpacpi_init(void)
 {
 	if (acpi_disabled || pnpacpi_disabled) {
diff --git a/drivers/s390/char/sclp_early.c b/drivers/s390/char/sclp_early.c
index 7bc6df3..d58607f 100644
--- a/drivers/s390/char/sclp_early.c
+++ b/drivers/s390/char/sclp_early.c
@@ -48,7 +48,7 @@ struct read_info_sccb {
 	u8	_pad_122[4096 - 122];	/* 122-4095 */
 } __packed __aligned(PAGE_SIZE);
 
-static char sccb_early[PAGE_SIZE] __aligned(PAGE_SIZE) __initdata;
+static char sccb_early[PAGE_SIZE] __aligned(PAGE_SIZE) __initbss;
 static struct sclp_ipl_info sclp_ipl_info;
 
 struct sclp_info sclp;
diff --git a/drivers/scsi/NCR5380.c b/drivers/scsi/NCR5380.c
index a777e5c..a62e9dc 100644
--- a/drivers/scsi/NCR5380.c
+++ b/drivers/scsi/NCR5380.c
@@ -534,7 +534,7 @@ static void NCR5380_set_timer(struct NCR5380_hostdata *hostdata, unsigned long t
 }
 
 
-static int probe_irq __initdata = 0;
+static int probe_irq __initbss;
 
 /**
  *	probe_intr	-	helper for IRQ autoprobe
diff --git a/drivers/scsi/gdth.c b/drivers/scsi/gdth.c
index 71e1380..22bcf0b 100644
--- a/drivers/scsi/gdth.c
+++ b/drivers/scsi/gdth.c
@@ -329,7 +329,7 @@ static int irq[MAXHA] __initdata =
 {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
  0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
 /* disable driver flag */
-static int disable __initdata = 0;
+static int disable __initbss;
 /* reserve flag */
 static int reserve_mode = 1;                  
 /* reserve list */
diff --git a/drivers/soc/tegra/fuse/speedo-tegra30.c b/drivers/soc/tegra/fuse/speedo-tegra30.c
index 9b010b3..5c57325 100644
--- a/drivers/soc/tegra/fuse/speedo-tegra30.c
+++ b/drivers/soc/tegra/fuse/speedo-tegra30.c
@@ -84,7 +84,7 @@ static const u32 __initconst cpu_process_speedos[][CPU_PROCESS_CORNERS] = {
 	{295, 336, 358, 375, 391, UINT_MAX},
 };
 
-static int threshold_index __initdata;
+static int threshold_index __initbss;
 
 static void __init fuse_speedo_calib(u32 *speedo_g, u32 *speedo_lp)
 {
diff --git a/drivers/staging/board/board.c b/drivers/staging/board/board.c
index 3eb5eb8..fcc8cd9 100644
--- a/drivers/staging/board/board.c
+++ b/drivers/staging/board/board.c
@@ -22,8 +22,8 @@
 
 #include "board.h"
 
-static struct device_node *irqc_node __initdata;
-static unsigned int irqc_base __initdata;
+static struct device_node *irqc_node __initbss;
+static unsigned int irqc_base __initbss;
 
 static bool find_by_address(u64 base_address)
 {
diff --git a/drivers/vfio/pci/vfio_pci.c b/drivers/vfio/pci/vfio_pci.c
index 964ad57..e47b540 100644
--- a/drivers/vfio/pci/vfio_pci.c
+++ b/drivers/vfio/pci/vfio_pci.c
@@ -35,7 +35,7 @@
 #define DRIVER_AUTHOR   "Alex Williamson <alex.williamson@redhat.com>"
 #define DRIVER_DESC     "VFIO PCI - User Level meta-driver"
 
-static char ids[1024] __initdata;
+static char ids[1024] __initbss;
 module_param_string(ids, ids, sizeof(ids), 0);
 MODULE_PARM_DESC(ids, "Initial PCI IDs to add to the vfio driver, format is \"vendor:device[:subvendor[:subdevice[:class[:class_mask]]]]\" and multiple comma separated entries can be specified");
 
diff --git a/drivers/video/fbdev/amifb.c b/drivers/video/fbdev/amifb.c
index 1d702e1..d1d5f32 100644
--- a/drivers/video/fbdev/amifb.c
+++ b/drivers/video/fbdev/amifb.c
@@ -950,10 +950,10 @@ static int round_down_bpp = 1;	/* for mode probing */
 
 static int amifb_ilbm = 0;	/* interleaved or normal bitplanes */
 
-static u32 amifb_hfmin __initdata;	/* monitor hfreq lower limit (Hz) */
-static u32 amifb_hfmax __initdata;	/* monitor hfreq upper limit (Hz) */
-static u16 amifb_vfmin __initdata;	/* monitor vfreq lower limit (Hz) */
-static u16 amifb_vfmax __initdata;	/* monitor vfreq upper limit (Hz) */
+static u32 amifb_hfmin __initbss;	/* monitor hfreq lower limit (Hz) */
+static u32 amifb_hfmax __initbss;	/* monitor hfreq upper limit (Hz) */
+static u16 amifb_vfmin __initbss;	/* monitor vfreq lower limit (Hz) */
+static u16 amifb_vfmax __initbss;	/* monitor vfreq upper limit (Hz) */
 
 
 	/*
diff --git a/drivers/video/fbdev/omap2/dss/omapdss-boot-init.c b/drivers/video/fbdev/omap2/dss/omapdss-boot-init.c
index 8b6f6d5..387208c 100644
--- a/drivers/video/fbdev/omap2/dss/omapdss-boot-init.c
+++ b/drivers/video/fbdev/omap2/dss/omapdss-boot-init.c
@@ -30,7 +30,7 @@
 #include <linux/slab.h>
 #include <linux/list.h>
 
-static struct list_head dss_conv_list __initdata;
+static struct list_head dss_conv_list __initbss;
 
 static const char prefix[] __initconst = "omapdss,";
 
diff --git a/drivers/video/fbdev/stifb.c b/drivers/video/fbdev/stifb.c
index 7df4228..1757027 100644
--- a/drivers/video/fbdev/stifb.c
+++ b/drivers/video/fbdev/stifb.c
@@ -1345,7 +1345,7 @@ out_err0:
 	return -ENXIO;
 }
 
-static int stifb_disabled __initdata;
+static int stifb_disabled __initbss;
 
 int __init
 stifb_setup(char *options);
diff --git a/drivers/video/fbdev/vfb.c b/drivers/video/fbdev/vfb.c
index b9c2f81..3bc813a 100644
--- a/drivers/video/fbdev/vfb.c
+++ b/drivers/video/fbdev/vfb.c
@@ -117,7 +117,7 @@ static struct fb_fix_screeninfo vfb_fix = {
 	.accel =	FB_ACCEL_NONE,
 };
 
-static bool vfb_enable __initdata = 0;	/* disabled by default */
+static bool vfb_enable __initbss;	/* disabled by default */
 module_param(vfb_enable, bool, 0);
 
 static int vfb_check_var(struct fb_var_screeninfo *var,
diff --git a/drivers/watchdog/octeon-wdt-main.c b/drivers/watchdog/octeon-wdt-main.c
index 14521c8..7d32fbe 100644
--- a/drivers/watchdog/octeon-wdt-main.c
+++ b/drivers/watchdog/octeon-wdt-main.c
@@ -105,10 +105,10 @@ MODULE_PARM_DESC(nowayout,
 	"Watchdog cannot be stopped once started (default="
 				__MODULE_STRING(WATCHDOG_NOWAYOUT) ")");
 
-static u32 nmi_stage1_insns[64] __initdata;
+static u32 nmi_stage1_insns[64] __initbss;
 /* We need one branch and therefore one relocation per target label. */
-static struct uasm_label labels[5] __initdata;
-static struct uasm_reloc relocs[5] __initdata;
+static struct uasm_label labels[5] __initbss;
+static struct uasm_reloc relocs[5] __initbss;
 
 enum lable_id {
 	label_enter_bootloader = 1
diff --git a/drivers/xen/efi.c b/drivers/xen/efi.c
index f745db2..b18510e 100644
--- a/drivers/xen/efi.c
+++ b/drivers/xen/efi.c
@@ -261,7 +261,7 @@ static efi_status_t xen_efi_query_capsule_caps(efi_capsule_header_t **capsules,
 	return efi_data(op).status;
 }
 
-static efi_char16_t vendor[100] __initdata;
+static efi_char16_t vendor[100] __initbss;
 
 static efi_system_table_t efi_systab_xen __initdata = {
 	.hdr = {
diff --git a/drivers/zorro/zorro.c b/drivers/zorro/zorro.c
index d295d98..dcbd00c 100644
--- a/drivers/zorro/zorro.c
+++ b/drivers/zorro/zorro.c
@@ -30,7 +30,7 @@
      */
 
 unsigned int zorro_num_autocon;
-struct zorro_dev_init zorro_autocon_init[ZORRO_NUM_AUTO] __initdata;
+struct zorro_dev_init zorro_autocon_init[ZORRO_NUM_AUTO] __initbss;
 struct zorro_dev *zorro_autocon;
 
 
diff --git a/init/do_mounts.c b/init/do_mounts.c
index dea5de9..2d06ae0 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -35,11 +35,11 @@
 
 #include "do_mounts.h"
 
-int __initdata rd_doload;	/* 1 = load RAM disk, 0 = don't load */
+int __initbss rd_doload;	/* 1 = load RAM disk, 0 = don't load */
 
 int root_mountflags = MS_RDONLY | MS_SILENT;
-static char * __initdata root_device_name;
-static char __initdata saved_root_name[64];
+static char * __initbss root_device_name;
+static char __initbss saved_root_name[64];
 static int root_wait;
 
 dev_t ROOT_DEV;
@@ -308,21 +308,21 @@ static int __init rootwait_setup(char *str)
 
 __setup("rootwait", rootwait_setup);
 
-static char * __initdata root_mount_data;
+static char * __initbss root_mount_data;
 static int __init root_data_setup(char *str)
 {
 	root_mount_data = str;
 	return 1;
 }
 
-static char * __initdata root_fs_names;
+static char * __initbss root_fs_names;
 static int __init fs_names_setup(char *str)
 {
 	root_fs_names = str;
 	return 1;
 }
 
-static unsigned int __initdata root_delay;
+static unsigned int __initbss root_delay;
 static int __init root_delay_setup(char *str)
 {
 	root_delay = simple_strtoul(str, NULL, 0);
diff --git a/init/do_mounts_initrd.c b/init/do_mounts_initrd.c
index 3f46d60..8d4286b 100644
--- a/init/do_mounts_initrd.c
+++ b/init/do_mounts_initrd.c
@@ -21,8 +21,8 @@
 #include "do_mounts.h"
 
 unsigned long initrd_start, initrd_end;
-phys_addr_t initrd_start_phys __initdata;
-phys_addr_t initrd_end_phys __initdata;
+phys_addr_t initrd_start_phys __initbss;
+phys_addr_t initrd_end_phys __initbss;
 int initrd_below_start_ok;
 unsigned int real_root_dev;	/* do_proc_dointvec cannot handle kdev_t */
 static int __initdata mount_initrd = 1;
diff --git a/init/do_mounts_md.c b/init/do_mounts_md.c
index 8cb6db5..e10c2f6 100644
--- a/init/do_mounts_md.c
+++ b/init/do_mounts_md.c
@@ -24,11 +24,11 @@
  */
 
 #ifdef CONFIG_MD_AUTODETECT
-static int __initdata raid_noautodetect;
+static int __initbss raid_noautodetect;
 #else
 static int __initdata raid_noautodetect=1;
 #endif
-static int __initdata raid_autopart;
+static int __initbss raid_autopart;
 
 static struct {
 	int minor;
@@ -36,9 +36,9 @@ static struct {
 	int level;
 	int chunk;
 	char *device_names;
-} md_setup_args[256] __initdata;
+} md_setup_args[256] __initbss;
 
-static int md_setup_ents __initdata;
+static int md_setup_ents __initbss;
 
 /*
  * Parse the command-line parameters given our kernel, but do not
diff --git a/init/do_mounts_rd.c b/init/do_mounts_rd.c
index e5d059e..5b49458 100644
--- a/init/do_mounts_rd.c
+++ b/init/do_mounts_rd.c
@@ -33,7 +33,7 @@ static int __init prompt_ramdisk(char *str)
 }
 __setup("prompt_ramdisk=", prompt_ramdisk);
 
-int __initdata rd_image_start;		/* starting block # of image */
+int __initbss rd_image_start;		/* starting block # of image */
 
 static int __init ramdisk_start_setup(char *str)
 {
diff --git a/init/initramfs.c b/init/initramfs.c
index b32ad7d..7566c4f 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -42,7 +42,7 @@ static ssize_t __init xwrite(int fd, const char *p, size_t count)
 	return out;
 }
 
-static __initdata char *message;
+static __initbss char *message;
 static void __init error(char *x)
 {
 	if (!message)
@@ -53,7 +53,7 @@ static void __init error(char *x)
 
 #define N_ALIGN(len) ((((len) + 1) & ~3) + 2)
 
-static __initdata struct hash {
+static __initbss struct hash {
 	int ino, minor, major;
 	umode_t mode;
 	struct hash *next;
@@ -148,16 +148,16 @@ static void __init dir_utime(void)
 	}
 }
 
-static __initdata time_t mtime;
+static __initbss time_t mtime;
 
 /* cpio header parsing */
 
-static __initdata unsigned long ino, major, minor, nlink;
-static __initdata umode_t mode;
-static __initdata unsigned long body_len, name_len;
-static __initdata uid_t uid;
-static __initdata gid_t gid;
-static __initdata unsigned rdev;
+static __initbss unsigned long ino, major, minor, nlink;
+static __initbss umode_t mode;
+static __initbss unsigned long body_len, name_len;
+static __initbss uid_t uid;
+static __initbss gid_t gid;
+static __initbss unsigned rdev;
 
 static void __init parse_header(char *s)
 {
@@ -185,7 +185,7 @@ static void __init parse_header(char *s)
 
 /* FSM */
 
-static __initdata enum state {
+static __initbss enum state {
 	Start,
 	Collect,
 	GotHeader,
@@ -196,9 +196,9 @@ static __initdata enum state {
 	Reset
 } state, next_state;
 
-static __initdata char *victim;
-static unsigned long byte_count __initdata;
-static __initdata loff_t this_header, next_header;
+static __initbss char *victim;
+static unsigned long byte_count __initbss;
+static __initbss loff_t this_header, next_header;
 
 static inline void __init eat(unsigned n)
 {
@@ -207,10 +207,10 @@ static inline void __init eat(unsigned n)
 	byte_count -= n;
 }
 
-static __initdata char *vcollected;
-static __initdata char *collected;
-static long remains __initdata;
-static __initdata char *collect;
+static __initbss char *vcollected;
+static __initbss char *collected;
+static long remains __initbss;
+static __initbss char *collect;
 
 static void __init read_into(char *buf, unsigned size, enum state next)
 {
@@ -226,7 +226,7 @@ static void __init read_into(char *buf, unsigned size, enum state next)
 	}
 }
 
-static __initdata char *header_buf, *symlink_buf, *name_buf;
+static __initbss char *header_buf, *symlink_buf, *name_buf;
 
 static int __init do_start(void)
 {
@@ -321,7 +321,7 @@ static void __init clean_path(char *path, umode_t fmode)
 	}
 }
 
-static __initdata int wfd;
+static __initbss int wfd;
 
 static int __init do_name(void)
 {
@@ -451,7 +451,7 @@ static char * __init unpack_to_rootfs(char *buf, unsigned long len)
 	long written;
 	decompress_fn decompress;
 	const char *compress_name;
-	static __initdata char msg_buf[64];
+	static __initbss char msg_buf[64];
 
 	header_buf = kmalloc(110, GFP_KERNEL);
 	symlink_buf = kmalloc(PATH_MAX + N_ALIGN(PATH_MAX) + 1, GFP_KERNEL);
@@ -508,7 +508,7 @@ static char * __init unpack_to_rootfs(char *buf, unsigned long len)
 	return message;
 }
 
-static int __initdata do_retain_initrd;
+static int __initbss do_retain_initrd;
 
 static int __init retain_initrd_param(char *str)
 {
diff --git a/init/main.c b/init/main.c
index 9e64d70..917936a 100644
--- a/init/main.c
+++ b/init/main.c
@@ -120,7 +120,7 @@ extern void time_init(void);
 void (*__initdata late_time_init)(void);
 
 /* Untouched command line saved by arch-specific code. */
-char __initdata boot_command_line[COMMAND_LINE_SIZE];
+char __initbss boot_command_line[COMMAND_LINE_SIZE];
 /* Untouched saved command line (eg. for /proc) */
 char *saved_command_line;
 /* Command line for parameter parsing */
@@ -440,8 +440,8 @@ void __init parse_early_options(char *cmdline)
 /* Arch code calls this early on, or if not, just before other parsing. */
 void __init parse_early_param(void)
 {
-	static int done __initdata;
-	static char tmp_cmdline[COMMAND_LINE_SIZE] __initdata;
+	static int done __initbss;
+	static char tmp_cmdline[COMMAND_LINE_SIZE] __initbss;
 
 	if (done)
 		return;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0acdbf0..aeea36d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5124,7 +5124,7 @@ int __init cgroup_init_early(void)
 	return 0;
 }
 
-static unsigned long cgroup_disable_mask __initdata;
+static unsigned long cgroup_disable_mask __initbss;
 
 /**
  * cgroup_init - cgroup initialization
diff --git a/kernel/power/suspend_test.c b/kernel/power/suspend_test.c
index 084452e..c61ddcb 100644
--- a/kernel/power/suspend_test.c
+++ b/kernel/power/suspend_test.c
@@ -143,7 +143,7 @@ static int __init has_wakealarm(struct device *dev, const void *data)
  * at startup time.  They're normally disabled, for faster boot and because
  * we can't know which states really work on this particular system.
  */
-static const char *test_state_label __initdata;
+static const char *test_state_label __initbss;
 
 static char warn_bad_state[] __initdata =
 	KERN_WARNING "PM: can't test '%s' suspend state\n";
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 3a7db65..2c29b49 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -4267,11 +4267,11 @@ EXPORT_SYMBOL_GPL(ftrace_set_global_notrace);
  * command line interface to allow users to set filters on boot up.
  */
 #define FTRACE_FILTER_SIZE		COMMAND_LINE_SIZE
-static char ftrace_notrace_buf[FTRACE_FILTER_SIZE] __initdata;
-static char ftrace_filter_buf[FTRACE_FILTER_SIZE] __initdata;
+static char ftrace_notrace_buf[FTRACE_FILTER_SIZE] __initbss;
+static char ftrace_filter_buf[FTRACE_FILTER_SIZE] __initbss;
 
 /* Used by function selftest to not test if filter is set */
-bool ftrace_filter_param __initdata;
+bool ftrace_filter_param __initbss;
 
 static int __init set_ftrace_notrace(char *str)
 {
@@ -4290,8 +4290,8 @@ static int __init set_ftrace_filter(char *str)
 __setup("ftrace_filter=", set_ftrace_filter);
 
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
-static char ftrace_graph_buf[FTRACE_FILTER_SIZE] __initdata;
-static char ftrace_graph_notrace_buf[FTRACE_FILTER_SIZE] __initdata;
+static char ftrace_graph_buf[FTRACE_FILTER_SIZE] __initbss;
+static char ftrace_graph_notrace_buf[FTRACE_FILTER_SIZE] __initbss;
 static int ftrace_set_func(unsigned long *array, int *idx, int size, char *buffer);
 
 static unsigned long save_global_trampoline;
diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index fc347f8..2f36944 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -4709,7 +4709,7 @@ static int rb_cpu_notify(struct notifier_block *self,
  * ring buffer should happen that's not expected, a big warning
  * is displayed and all ring buffers are disabled.
  */
-static struct task_struct *rb_threads[NR_CPUS] __initdata;
+static struct task_struct *rb_threads[NR_CPUS] __initbss;
 
 struct rb_test_data {
 	struct ring_buffer	*buffer;
@@ -4729,7 +4729,7 @@ struct rb_test_data {
 	int			cnt;
 };
 
-static struct rb_test_data rb_data[NR_CPUS] __initdata;
+static struct rb_test_data rb_data[NR_CPUS] __initbss;
 
 /* 1 meg per cpu */
 #define RB_TEST_BUFFER_SIZE	1048576
@@ -4739,7 +4739,7 @@ static char rb_string[] __initdata =
 	"?+|:';\",.<>/?abcdefghijklmnopqrstuvwxyz1234567890"
 	"!@#$%^&*()?+\\?+|:';\",.<>/?abcdefghijklmnopqrstuv";
 
-static bool rb_test_started __initdata;
+static bool rb_test_started __initbss;
 
 struct rb_item {
 	int size;
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 78022c1..997123a 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -164,7 +164,7 @@ static union trace_enum_map_item *trace_enum_maps;
 static int tracing_set_tracer(struct trace_array *tr, const char *buf);
 
 #define MAX_TRACER_SIZE		100
-static char bootup_tracer_buf[MAX_TRACER_SIZE] __initdata;
+static char bootup_tracer_buf[MAX_TRACER_SIZE] __initbss;
 static char *default_bootup_tracer;
 
 static bool allocate_snapshot;
@@ -213,8 +213,8 @@ static int __init boot_alloc_snapshot(char *str)
 __setup("alloc_snapshot", boot_alloc_snapshot);
 
 
-static char trace_boot_options_buf[MAX_TRACER_SIZE] __initdata;
-static char *trace_boot_options __initdata;
+static char trace_boot_options_buf[MAX_TRACER_SIZE] __initbss;
+static char *trace_boot_options __initbss;
 
 static int __init set_trace_boot_options(char *str)
 {
@@ -224,8 +224,8 @@ static int __init set_trace_boot_options(char *str)
 }
 __setup("trace_options=", set_trace_boot_options);
 
-static char trace_boot_clock_buf[MAX_TRACER_SIZE] __initdata;
-static char *trace_boot_clock __initdata;
+static char trace_boot_clock_buf[MAX_TRACER_SIZE] __initbss;
+static char *trace_boot_clock __initbss;
 
 static int __init set_trace_boot_clock(char *str)
 {
diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
index 57c9e70..d74b1e2 100644
--- a/kernel/trace/trace_events.c
+++ b/kernel/trace/trace_events.c
@@ -2447,7 +2447,7 @@ static void __add_event_to_tracers(struct trace_event_call *call)
 extern struct trace_event_call *__start_ftrace_events[];
 extern struct trace_event_call *__stop_ftrace_events[];
 
-static char bootup_event_buf[COMMAND_LINE_SIZE] __initdata;
+static char bootup_event_buf[COMMAND_LINE_SIZE] __initbss;
 
 static __init int setup_trace_event(char *str)
 {
diff --git a/kernel/trace/trace_stack.c b/kernel/trace/trace_stack.c
index b746399..3a8e5ff 100644
--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -420,7 +420,7 @@ stack_trace_sysctl(struct ctl_table *table, int write,
 	return ret;
 }
 
-static char stack_trace_filter_buf[COMMAND_LINE_SIZE+1] __initdata;
+static char stack_trace_filter_buf[COMMAND_LINE_SIZE+1] __initbss;
 
 static __init int enable_stacktrace(char *str)
 {
diff --git a/lib/debugobjects.c b/lib/debugobjects.c
index 547f7f9..f091580 100644
--- a/lib/debugobjects.c
+++ b/lib/debugobjects.c
@@ -35,7 +35,7 @@ struct debug_bucket {
 
 static struct debug_bucket	obj_hash[ODEBUG_HASH_SIZE];
 
-static struct debug_obj		obj_static_pool[ODEBUG_POOL_SIZE] __initdata;
+static struct debug_obj		obj_static_pool[ODEBUG_POOL_SIZE] __initbss;
 
 static DEFINE_RAW_SPINLOCK(pool_lock);
 
diff --git a/lib/list_sort.c b/lib/list_sort.c
index 3fe4010..b0d6291 100644
--- a/lib/list_sort.c
+++ b/lib/list_sort.c
@@ -169,7 +169,7 @@ struct debug_el {
 };
 
 /* Array, containing pointers to all elements in the test list */
-static struct debug_el **elts __initdata;
+static struct debug_el **elts __initbss;
 
 static int __init check(struct debug_el *ela, struct debug_el *elb)
 {
diff --git a/lib/test_printf.c b/lib/test_printf.c
index c5a666a..5f013f2 100644
--- a/lib/test_printf.c
+++ b/lib/test_printf.c
@@ -36,9 +36,9 @@
 #endif
 #define PTR_WIDTH_STR stringify(PTR_WIDTH)
 
-static unsigned total_tests __initdata;
-static unsigned failed_tests __initdata;
-static char *test_buffer __initdata;
+static unsigned total_tests __initbss;
+static unsigned failed_tests __initbss;
+static char *test_buffer __initbss;
 
 static int __printf(4, 0) __init
 do_test(int bufsize, const char *expect, int elen,
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 3b63807..4a28ed5 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -34,7 +34,7 @@ unsigned long max_low_pfn;
 unsigned long min_low_pfn;
 unsigned long max_pfn;
 
-bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
+bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initbss;
 
 static struct list_head bdata_list __initdata = LIST_HEAD_INIT(bdata_list);
 
@@ -243,7 +243,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	return count;
 }
 
-static int reset_managed_pages_done __initdata;
+static int reset_managed_pages_done __initbss;
 
 void reset_node_managed_pages(pg_data_t *pgdat)
 {
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index 6d5717b..a3d4c22 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -18,7 +18,7 @@
 #include <asm/early_ioremap.h>
 
 #ifdef CONFIG_MMU
-static int early_ioremap_debug __initdata;
+static int early_ioremap_debug __initbss;
 
 static int __init early_ioremap_debug_setup(char *str)
 {
@@ -28,7 +28,7 @@ static int __init early_ioremap_debug_setup(char *str)
 }
 early_param("early_ioremap_debug", early_ioremap_debug_setup);
 
-static int after_paging_init __initdata;
+static int after_paging_init __initbss;
 
 void __init __weak early_ioremap_shutdown(void)
 {
@@ -60,9 +60,9 @@ static inline void __init __late_clear_fixmap(enum fixed_addresses idx)
 }
 #endif
 
-static void __iomem *prev_map[FIX_BTMAPS_SLOTS] __initdata;
-static unsigned long prev_size[FIX_BTMAPS_SLOTS] __initdata;
-static unsigned long slot_virt[FIX_BTMAPS_SLOTS] __initdata;
+static void __iomem *prev_map[FIX_BTMAPS_SLOTS] __initbss;
+static unsigned long prev_size[FIX_BTMAPS_SLOTS] __initbss;
+static unsigned long slot_virt[FIX_BTMAPS_SLOTS] __initbss;
 
 void __init early_ioremap_setup(void)
 {
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 19423a4..54e8729 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -268,8 +268,8 @@ struct early_log {
 
 /* early logging buffer and current position */
 static struct early_log
-	early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE] __initdata;
-static int crt_early_log __initdata;
+	early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE] __initbss;
+static int crt_early_log __initbss;
 
 static void kmemleak_disable(void);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2dc337..3b1a5c0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5728,7 +5728,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 #ifdef CONFIG_MEMCG_SWAP_ENABLED
 static int really_do_swap_account __initdata = 1;
 #else
-static int really_do_swap_account __initdata;
+static int really_do_swap_account __initbss;
 #endif
 
 static int __init enable_swap_account(char *s)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 87a1779..c8ec038 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2508,7 +2508,7 @@ void mpol_free_shared_policy(struct shared_policy *p)
 }
 
 #ifdef CONFIG_NUMA_BALANCING
-static int __initdata numabalancing_override;
+static int __initbss numabalancing_override;
 
 static void __init check_numabalancing_enable(void)
 {
diff --git a/mm/memtest.c b/mm/memtest.c
index 8eaa4c3..4625ed0 100644
--- a/mm/memtest.c
+++ b/mm/memtest.c
@@ -80,7 +80,7 @@ static void __init do_one_pass(u64 pattern, phys_addr_t start, phys_addr_t end)
 }
 
 /* default is disabled */
-static unsigned int memtest_pattern __initdata;
+static unsigned int memtest_pattern __initbss;
 
 static int __init parse_memtest(char *arg)
 {
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index e57cf24..f61fbc4 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -156,7 +156,7 @@ static unsigned long __init free_low_memory_core_early(void)
 	return count;
 }
 
-static int reset_managed_pages_done __initdata;
+static int reset_managed_pages_done __initbss;
 
 void reset_node_managed_pages(pg_data_t *pgdat)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index de82e2c..16c55b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -248,8 +248,8 @@ static unsigned long __meminitdata dma_reserve;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
-static unsigned long __initdata required_kernelcore;
-static unsigned long __initdata required_movablecore;
+static unsigned long __initbss required_kernelcore;
+static unsigned long __initbss required_movablecore;
 static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
 
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
@@ -1112,7 +1112,7 @@ static void __init deferred_free_range(struct page *page,
 }
 
 /* Completion tracking for deferred_init_memmap() threads */
-static atomic_t pgdat_init_n_undone __initdata;
+static atomic_t pgdat_init_n_undone __initbss;
 static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
 
 static inline void __init pgdat_init_report_one_done(void)
diff --git a/mm/percpu.c b/mm/percpu.c
index 8a943b9..e611ccd 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1528,8 +1528,8 @@ static void pcpu_dump_alloc_info(const char *lvl,
 int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 				  void *base_addr)
 {
-	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
-	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
+	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initbss;
+	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initbss;
 	size_t dyn_size = ai->dyn_size;
 	size_t size_sum = ai->static_size + ai->reserved_size + dyn_size;
 	struct pcpu_chunk *schunk, *dchunk = NULL;
@@ -1776,8 +1776,8 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 				size_t atom_size,
 				pcpu_fc_cpu_distance_fn_t cpu_distance_fn)
 {
-	static int group_map[NR_CPUS] __initdata;
-	static int group_cnt[NR_CPUS] __initdata;
+	static int group_map[NR_CPUS] __initbss;
+	static int group_cnt[NR_CPUS] __initbss;
 	const size_t static_size = __per_cpu_end - __per_cpu_start;
 	int nr_groups = 1, nr_units = 0;
 	size_t size_sum, min_unit_size, alloc_size;
diff --git a/mm/slab.c b/mm/slab.c
index 767cd76..def0e6e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -238,7 +238,7 @@ struct arraycache_init {
  * Need this for bootstrapping a per node allocator.
  */
 #define NUM_INIT_LISTS (2 * MAX_NUMNODES)
-static struct kmem_cache_node __initdata init_kmem_cache_node[NUM_INIT_LISTS];
+static struct kmem_cache_node __initbss init_kmem_cache_node[NUM_INIT_LISTS];
 #define	CACHE_CACHE 0
 #define	SIZE_NODE (MAX_NUMNODES)
 
@@ -429,7 +429,7 @@ static inline void set_obj_status(struct page *page, int idx, int val) {}
 #define	SLAB_MAX_ORDER_HI	1
 #define	SLAB_MAX_ORDER_LO	0
 static int slab_max_order = SLAB_MAX_ORDER_LO;
-static bool slab_max_order_set __initdata;
+static bool slab_max_order_set __initbss;
 
 static inline struct kmem_cache *virt_to_cache(const void *obj)
 {
diff --git a/mm/slub.c b/mm/slub.c
index 0a795e9..0982ede 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3881,7 +3881,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 
 void __init kmem_cache_init(void)
 {
-	static __initdata struct kmem_cache boot_kmem_cache,
+	static __initbss struct kmem_cache boot_kmem_cache,
 		boot_kmem_cache_node;
 
 	if (debug_guardpage_minorder())
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 842c12c..4af41f3 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1143,7 +1143,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 }
 EXPORT_SYMBOL(vm_map_ram);
 
-static struct vm_struct *vmlist __initdata;
+static struct vm_struct *vmlist __initbss;
 /**
  * vm_area_add_early - add vmap area early during boot
  * @vm: vm_struct to add
@@ -1184,7 +1184,7 @@ void __init vm_area_add_early(struct vm_struct *vm)
  */
 void __init vm_area_register_early(struct vm_struct *vm, size_t align)
 {
-	static size_t vm_init_off __initdata;
+	static size_t vm_init_off __initbss;
 	unsigned long addr;
 
 	addr = ALIGN(VMALLOC_START + vm_init_off, align);
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ed4ef09..3381a6c 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -113,9 +113,9 @@
  * variables using firmware environment vars.  If this is set, it will
  * ignore such firmware variables.
  */
-int ic_set_manually __initdata = 0;		/* IPconfig parameters set manually */
+int ic_set_manually __initbss;		/* IPconfig parameters set manually */
 
-static int ic_enable __initdata;		/* IP config enabled? */
+static int ic_enable __initbss;		/* IP config enabled? */
 
 /* Protocol choice */
 int ic_proto_enabled __initdata = 0
@@ -130,7 +130,7 @@ int ic_proto_enabled __initdata = 0
 #endif
 			;
 
-static int ic_host_name_set __initdata;	/* Host name set by us? */
+static int ic_host_name_set __initbss;	/* Host name set by us? */
 
 __be32 ic_myaddr = NONE;		/* My IP address */
 static __be32 ic_netmask = NONE;	/* Netmask for local subnet */
@@ -144,7 +144,7 @@ __be32 root_server_addr = NONE;	/* Address of NFS server */
 u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
 /* vendor class identifier */
-static char vendor_class_identifier[253] __initdata;
+static char vendor_class_identifier[253] __initbss;
 
 /* Persistent data: */
 
@@ -160,17 +160,17 @@ static u8 ic_domain[64];		/* DNS (not NIS) domain name */
 static char user_dev_name[IFNAMSIZ] __initdata = { 0, };
 
 /* Protocols supported by available interfaces */
-static int ic_proto_have_if __initdata;
+static int ic_proto_have_if __initbss;
 
 /* MTU for boot device */
-static int ic_dev_mtu __initdata;
+static int ic_dev_mtu __initbss;
 
 #ifdef IPCONFIG_DYNAMIC
 static DEFINE_SPINLOCK(ic_recv_lock);
-static volatile int ic_got_reply __initdata;    /* Proto(s) that replied */
+static volatile int ic_got_reply __initbss;    /* Proto(s) that replied */
 #endif
 #ifdef IPCONFIG_DHCP
-static int ic_dhcp_msgtype __initdata;	/* DHCP msg type received */
+static int ic_dhcp_msgtype __initbss;	/* DHCP msg type received */
 #endif
 
 
@@ -186,8 +186,8 @@ struct ic_device {
 	__be32 xid;
 };
 
-static struct ic_device *ic_first_dev __initdata;	/* List of open device */
-static struct net_device *ic_dev __initdata;		/* Selected device */
+static struct ic_device *ic_first_dev __initbss;	/* List of open device */
+static struct net_device *ic_dev __initbss;		/* Selected device */
 
 static bool __init ic_is_init_dev(struct net_device *dev)
 {
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index dec607c..1dc6cf6 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -37,7 +37,7 @@
 #include "include/procattr.h"
 
 /* Flag indicating whether initialization completed */
-int apparmor_initialized __initdata;
+int apparmor_initialized __initbss;
 
 /*
  * LSM hook functions
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index 3997e20..18f82cb 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -139,7 +139,7 @@ static struct list_head *ima_rules;
 
 static DEFINE_MUTEX(ima_rules_mutex);
 
-static int ima_policy __initdata;
+static int ima_policy __initbss;
 static int __init default_measure_policy_setup(char *str)
 {
 	if (ima_policy)
@@ -162,7 +162,7 @@ static int __init policy_setup(char *str)
 }
 __setup("ima_policy=", policy_setup);
 
-static bool ima_use_appraise_tcb __initdata;
+static bool ima_use_appraise_tcb __initbss;
 static int __init default_appraise_policy_setup(char *str)
 {
 	ima_use_appraise_tcb = 1;
diff --git a/sound/oss/aedsp16.c b/sound/oss/aedsp16.c
index 35b5912..2573817 100644
--- a/sound/oss/aedsp16.c
+++ b/sound/oss/aedsp16.c
@@ -409,8 +409,8 @@
 #define INIT_MSS    (1<<1)
 #define INIT_MPU401 (1<<2)
 
-static int      soft_cfg __initdata = 0;	/* bitmapped config */
-static int      soft_cfg_mss __initdata = 0;	/* bitmapped mss config */
+static int      soft_cfg __initbss;	/* bitmapped config */
+static int      soft_cfg_mss __initbss;	/* bitmapped mss config */
 static int      ver[CARDVERDIGITS] __initdata = {0, 0};	/* DSP Ver:
 						   hi->ver[0] lo->ver[1] */
 
diff --git a/sound/oss/msnd_pinnacle.c b/sound/oss/msnd_pinnacle.c
index a8bb4a0..10d420d 100644
--- a/sound/oss/msnd_pinnacle.c
+++ b/sound/oss/msnd_pinnacle.c
@@ -1630,20 +1630,20 @@ static int write_ndelay __initdata =	-1;
 static int cfg __initdata =		-1;
 
 /* Extra Peripheral Configuration */
-static int reset __initdata = 0;
-static int mpu_io __initdata = 0;
-static int mpu_irq __initdata = 0;
-static int ide_io0 __initdata = 0;
-static int ide_io1 __initdata = 0;
-static int ide_irq __initdata = 0;
-static int joystick_io __initdata = 0;
+static int reset __initbss;
+static int mpu_io __initbss;
+static int mpu_irq __initbss;
+static int ide_io0 __initbss;
+static int ide_io1 __initbss;
+static int ide_irq __initbss;
+static int joystick_io __initbss;
 
 /* If we have the digital daugherboard... */
 static bool digital __initdata = false;
 #endif
 
 static int fifosize __initdata =	DEFFIFOSIZE;
-static int calibrate_signal __initdata = 0;
+static int calibrate_signal __initbss;
 
 #else /* not a module */
 

--Apple-Mail=_E308760F-8872-46AD-80B7-E62963202B9F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


build result :


yalin@ubuntu:~/linux-next$ ll ../kernel_out_arm/arch/arm/boot/*Image*
-rwxrwxr-x 1 yalin yalin 14487552 Oct 13 15:08 =
../kernel_out_arm/arch/arm/boot/Image*       # apply the patch
-rwxrwxr-x 1 yalin yalin 14512128 Oct 12 11:48 =
../kernel_out_arm/arch/arm/boot/Image_old*
-rwxrwxr-x 1 yalin yalin  6479568 Oct 13 15:08 =
../kernel_out_arm/arch/arm/boot/zImage*    # apply the patch
-rwxrwxr-x 1 yalin yalin  6479664 Oct 12 17:31 =
../kernel_out_arm/arch/arm/boot/zImage_old*


Image size shrink about 24576 bytes
zImage seems not change much .

it will be more useful for platform which don=E2=80=99t use compress =
Image like ARM64 / x86 platform i think.

Thanks











--Apple-Mail=_E308760F-8872-46AD-80B7-E62963202B9F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
