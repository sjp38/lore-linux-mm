Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33EB66B000A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:06:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r78so19213wmd.0
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 16:06:28 -0700 (PDT)
Received: from mail.bootlin.com (mail.bootlin.com. [62.4.15.54])
        by mx.google.com with ESMTP id l19si188102wmh.69.2018.03.19.16.06.25
        for <linux-mm@kvack.org>;
        Mon, 19 Mar 2018 16:06:26 -0700 (PDT)
Date: Tue, 20 Mar 2018 00:06:14 +0100
From: Alexandre Belloni <alexandre.belloni@bootlin.com>
Subject: Re: [PATCH 11/16] treewide: simplify Kconfig dependencies for
 removed archs
Message-ID: <20180319230614.GD4373@piout.net>
References: <20180314143529.1456168-1-arnd@arndb.de>
 <20180314144614.1632190-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314144614.1632190-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi@vger.kernel.org, linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 14/03/2018 at 15:43:46 +0100, Arnd Bergmann wrote:
> A lot of Kconfig symbols have architecture specific dependencies.
> In those cases that depend on architectures we have already removed,
> they can be omitted.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  block/bounce.c                       |  2 +-
>  drivers/ide/Kconfig                  |  2 +-
>  drivers/ide/ide-generic.c            | 12 +-----------
>  drivers/input/joystick/analog.c      |  2 +-
>  drivers/isdn/hisax/Kconfig           | 10 +++++-----
>  drivers/net/ethernet/davicom/Kconfig |  2 +-
>  drivers/net/ethernet/smsc/Kconfig    |  6 +++---
>  drivers/net/wireless/cisco/Kconfig   |  2 +-
>  drivers/pwm/Kconfig                  |  2 +-
>  drivers/rtc/Kconfig                  |  2 +-

Acked-by: Alexandre Belloni <alexandre.belloni@bootlin.com>

>  drivers/spi/Kconfig                  |  4 ++--
>  drivers/usb/musb/Kconfig             |  2 +-
>  drivers/video/console/Kconfig        |  3 +--
>  drivers/watchdog/Kconfig             |  6 ------
>  drivers/watchdog/Makefile            |  6 ------
>  fs/Kconfig.binfmt                    |  5 ++---
>  fs/minix/Kconfig                     |  2 +-
>  include/linux/ide.h                  |  7 +------
>  init/Kconfig                         |  5 ++---
>  lib/Kconfig.debug                    | 13 +++++--------
>  lib/test_user_copy.c                 |  2 --
>  mm/Kconfig                           |  7 -------
>  mm/percpu.c                          |  4 ----
>  23 files changed, 31 insertions(+), 77 deletions(-)
> 
> diff --git a/block/bounce.c b/block/bounce.c
> index 6a3e68292273..dd0b93f2a871 100644
> --- a/block/bounce.c
> +++ b/block/bounce.c
> @@ -31,7 +31,7 @@
>  static struct bio_set *bounce_bio_set, *bounce_bio_split;
>  static mempool_t *page_pool, *isa_page_pool;
>  
> -#if defined(CONFIG_HIGHMEM) || defined(CONFIG_NEED_BOUNCE_POOL)
> +#if defined(CONFIG_HIGHMEM)
>  static __init int init_emergency_pool(void)
>  {
>  #if defined(CONFIG_HIGHMEM) && !defined(CONFIG_MEMORY_HOTPLUG)
> diff --git a/drivers/ide/Kconfig b/drivers/ide/Kconfig
> index cf1fb3fb5d26..901b8833847f 100644
> --- a/drivers/ide/Kconfig
> +++ b/drivers/ide/Kconfig
> @@ -200,7 +200,7 @@ comment "IDE chipset support/bugfixes"
>  
>  config IDE_GENERIC
>  	tristate "generic/default IDE chipset support"
> -	depends on ALPHA || X86 || IA64 || M32R || MIPS || ARCH_RPC
> +	depends on ALPHA || X86 || IA64 || MIPS || ARCH_RPC
>  	default ARM && ARCH_RPC
>  	help
>  	  This is the generic IDE driver.  This driver attaches to the
> diff --git a/drivers/ide/ide-generic.c b/drivers/ide/ide-generic.c
> index 54d7c4685d23..80c0d69b83ac 100644
> --- a/drivers/ide/ide-generic.c
> +++ b/drivers/ide/ide-generic.c
> @@ -13,13 +13,10 @@
>  #include <linux/ide.h>
>  #include <linux/pci_ids.h>
>  
> -/* FIXME: convert arm and m32r to use ide_platform host driver */
> +/* FIXME: convert arm to use ide_platform host driver */
>  #ifdef CONFIG_ARM
>  #include <asm/irq.h>
>  #endif
> -#ifdef CONFIG_M32R
> -#include <asm/m32r.h>
> -#endif
>  
>  #define DRV_NAME	"ide_generic"
>  
> @@ -35,13 +32,6 @@ static const struct ide_port_info ide_generic_port_info = {
>  #ifdef CONFIG_ARM
>  static const u16 legacy_bases[] = { 0x1f0 };
>  static const int legacy_irqs[]  = { IRQ_HARDDISK };
> -#elif defined(CONFIG_PLAT_M32700UT) || defined(CONFIG_PLAT_MAPPI2) || \
> -      defined(CONFIG_PLAT_OPSPUT)
> -static const u16 legacy_bases[] = { 0x1f0 };
> -static const int legacy_irqs[]  = { PLD_IRQ_CFIREQ };
> -#elif defined(CONFIG_PLAT_MAPPI3)
> -static const u16 legacy_bases[] = { 0x1f0, 0x170 };
> -static const int legacy_irqs[]  = { PLD_IRQ_CFIREQ, PLD_IRQ_IDEIREQ };
>  #elif defined(CONFIG_ALPHA)
>  static const u16 legacy_bases[] = { 0x1f0, 0x170, 0x1e8, 0x168 };
>  static const int legacy_irqs[]  = { 14, 15, 11, 10 };
> diff --git a/drivers/input/joystick/analog.c b/drivers/input/joystick/analog.c
> index be1b4921f22a..eefac7978f93 100644
> --- a/drivers/input/joystick/analog.c
> +++ b/drivers/input/joystick/analog.c
> @@ -163,7 +163,7 @@ static unsigned int get_time_pit(void)
>  #define GET_TIME(x)	do { x = (unsigned int)rdtsc(); } while (0)
>  #define DELTA(x,y)	((y)-(x))
>  #define TIME_NAME	"TSC"
> -#elif defined(__alpha__) || defined(CONFIG_ARM) || defined(CONFIG_ARM64) || defined(CONFIG_RISCV) || defined(CONFIG_TILE)
> +#elif defined(__alpha__) || defined(CONFIG_ARM) || defined(CONFIG_ARM64) || defined(CONFIG_RISCV)
>  #define GET_TIME(x)	do { x = get_cycles(); } while (0)
>  #define DELTA(x,y)	((y)-(x))
>  #define TIME_NAME	"get_cycles"
> diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
> index eb83d94ab4fe..38cfc8baae19 100644
> --- a/drivers/isdn/hisax/Kconfig
> +++ b/drivers/isdn/hisax/Kconfig
> @@ -109,7 +109,7 @@ config HISAX_16_3
>  
>  config HISAX_TELESPCI
>  	bool "Teles PCI"
> -	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || (XTENSA && !CPU_LITTLE_ENDIAN)))
>  	help
>  	  This enables HiSax support for the Teles PCI.
>  	  See <file:Documentation/isdn/README.HiSax> on how to configure it.
> @@ -237,7 +237,7 @@ config HISAX_MIC
>  
>  config HISAX_NETJET
>  	bool "NETjet card"
> -	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
> +	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>  	depends on VIRT_TO_BUS
>  	help
>  	  This enables HiSax support for the NetJet from Traverse
> @@ -249,7 +249,7 @@ config HISAX_NETJET
>  
>  config HISAX_NETJET_U
>  	bool "NETspider U card"
> -	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
> +	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>  	depends on VIRT_TO_BUS
>  	help
>  	  This enables HiSax support for the Netspider U interface ISDN card
> @@ -318,7 +318,7 @@ config HISAX_GAZEL
>  
>  config HISAX_HFC_PCI
>  	bool "HFC PCI-Bus cards"
> -	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || (XTENSA && !CPU_LITTLE_ENDIAN)))
>  	help
>  	  This enables HiSax support for the HFC-S PCI 2BDS0 based cards.
>  
> @@ -343,7 +343,7 @@ config HISAX_HFC_SX
>  
>  config HISAX_ENTERNOW_PCI
>  	bool "Formula-n enter:now PCI card"
> -	depends on HISAX_NETJET && PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +	depends on HISAX_NETJET && PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || (XTENSA && !CPU_LITTLE_ENDIAN)))
>  	help
>  	  This enables HiSax support for the Formula-n enter:now PCI
>  	  ISDN card.
> diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
> index 7ec2d74f94d3..680a6d983f37 100644
> --- a/drivers/net/ethernet/davicom/Kconfig
> +++ b/drivers/net/ethernet/davicom/Kconfig
> @@ -4,7 +4,7 @@
>  
>  config DM9000
>  	tristate "DM9000 support"
> -	depends on ARM || BLACKFIN || MIPS || COLDFIRE || NIOS2
> +	depends on ARM || MIPS || COLDFIRE || NIOS2
>  	select CRC32
>  	select MII
>  	---help---
> diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
> index 948603e9b905..3da0c573d2ab 100644
> --- a/drivers/net/ethernet/smsc/Kconfig
> +++ b/drivers/net/ethernet/smsc/Kconfig
> @@ -5,8 +5,8 @@
>  config NET_VENDOR_SMSC
>  	bool "SMC (SMSC)/Western Digital devices"
>  	default y
> -	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
> -		   ISA || M32R || MAC || MIPS || NIOS2 || PCI || \
> +	depends on ARM || ARM64 || ATARI_ETHERNAT || COLDFIRE || \
> +		   ISA || MAC || MIPS || NIOS2 || PCI || \
>  		   PCMCIA || SUPERH || XTENSA || H8300
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y.
> @@ -37,7 +37,7 @@ config SMC91X
>  	select CRC32
>  	select MII
>  	depends on !OF || GPIOLIB
> -	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
> +	depends on ARM || ARM64 || ATARI_ETHERNAT || COLDFIRE || \
>  		   M32R || MIPS || NIOS2 || SUPERH || XTENSA || H8300
>  	---help---
>  	  This is a driver for SMC's 91x series of Ethernet chipsets,
> diff --git a/drivers/net/wireless/cisco/Kconfig b/drivers/net/wireless/cisco/Kconfig
> index b22567dff893..8ed0b154bb33 100644
> --- a/drivers/net/wireless/cisco/Kconfig
> +++ b/drivers/net/wireless/cisco/Kconfig
> @@ -33,7 +33,7 @@ config AIRO
>  
>  config AIRO_CS
>  	tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
> -	depends on CFG80211 && PCMCIA && (BROKEN || !M32R)
> +	depends on CFG80211 && PCMCIA
>  	select WIRELESS_EXT
>  	select WEXT_SPY
>  	select WEXT_PRIV
> diff --git a/drivers/pwm/Kconfig b/drivers/pwm/Kconfig
> index 763ee50ea57d..f16aad3bf5d6 100644
> --- a/drivers/pwm/Kconfig
> +++ b/drivers/pwm/Kconfig
> @@ -43,7 +43,7 @@ config PWM_AB8500
>  
>  config PWM_ATMEL
>  	tristate "Atmel PWM support"
> -	depends on ARCH_AT91 || AVR32
> +	depends on ARCH_AT91
>  	help
>  	  Generic PWM framework driver for Atmel SoC.
>  
> diff --git a/drivers/rtc/Kconfig b/drivers/rtc/Kconfig
> index be5a3dc99c11..46af10ac45fc 100644
> --- a/drivers/rtc/Kconfig
> +++ b/drivers/rtc/Kconfig
> @@ -868,7 +868,7 @@ comment "Platform RTC drivers"
>  
>  config RTC_DRV_CMOS
>  	tristate "PC-style 'CMOS'"
> -	depends on X86 || ARM || M32R || PPC || MIPS || SPARC64
> +	depends on X86 || ARM || PPC || MIPS || SPARC64
>  	default y if X86
>  	select RTC_MC146818_LIB
>  	help
> diff --git a/drivers/spi/Kconfig b/drivers/spi/Kconfig
> index 603783976b81..103c13fcefa0 100644
> --- a/drivers/spi/Kconfig
> +++ b/drivers/spi/Kconfig
> @@ -72,10 +72,10 @@ config SPI_ARMADA_3700
>  config SPI_ATMEL
>  	tristate "Atmel SPI Controller"
>  	depends on HAS_DMA
> -	depends on (ARCH_AT91 || AVR32 || COMPILE_TEST)
> +	depends on ARCH_AT91 || COMPILE_TEST
>  	help
>  	  This selects a driver for the Atmel SPI Controller, present on
> -	  many AT32 (AVR32) and AT91 (ARM) chips.
> +	  many AT91 ARM chips.
>  
>  config SPI_AU1550
>  	tristate "Au1550/Au1200/Au1300 SPI Controller"
> diff --git a/drivers/usb/musb/Kconfig b/drivers/usb/musb/Kconfig
> index 5506a9c03c1f..e757afc1cfd0 100644
> --- a/drivers/usb/musb/Kconfig
> +++ b/drivers/usb/musb/Kconfig
> @@ -87,7 +87,7 @@ config USB_MUSB_DA8XX
>  config USB_MUSB_TUSB6010
>  	tristate "TUSB6010"
>  	depends on HAS_IOMEM
> -	depends on (ARCH_OMAP2PLUS || COMPILE_TEST) && !BLACKFIN
> +	depends on ARCH_OMAP2PLUS || COMPILE_TEST
>  	depends on NOP_USB_XCEIV = USB_MUSB_HDRC # both built-in or both modules
>  
>  config USB_MUSB_OMAP2PLUS
> diff --git a/drivers/video/console/Kconfig b/drivers/video/console/Kconfig
> index 005ed87c8216..a9e398c144f8 100644
> --- a/drivers/video/console/Kconfig
> +++ b/drivers/video/console/Kconfig
> @@ -6,8 +6,7 @@ menu "Console display driver support"
>  
>  config VGA_CONSOLE
>  	bool "VGA text console" if EXPERT || !X86
> -	depends on !4xx && !PPC_8xx && !SPARC && !M68K && !PARISC && !FRV && \
> -		!SUPERH && !BLACKFIN && !AVR32 && !CRIS && \
> +	depends on !4xx && !PPC_8xx && !SPARC && !M68K && !PARISC &&  !SUPERH && \
>  		(!ARM || ARCH_FOOTBRIDGE || ARCH_INTEGRATOR || ARCH_NETWINDER) && \
>  		!ARM64 && !ARC && !MICROBLAZE && !OPENRISC
>  	default y
> diff --git a/drivers/watchdog/Kconfig b/drivers/watchdog/Kconfig
> index 0e19679348d1..79020ce95de2 100644
> --- a/drivers/watchdog/Kconfig
> +++ b/drivers/watchdog/Kconfig
> @@ -828,10 +828,6 @@ config BFIN_WDT
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called bfin_wdt.
>  
> -# CRIS Architecture
> -
> -# FRV Architecture
> -
>  # X86 (i386 + ia64 + x86_64) Architecture
>  
>  config ACQUIRE_WDT
> @@ -1431,8 +1427,6 @@ config NIC7018_WDT
>  	  To compile this driver as a module, choose M here: the module will be
>  	  called nic7018_wdt.
>  
> -# M32R Architecture
> -
>  # M68K Architecture
>  
>  config M54xx_WATCHDOG
> diff --git a/drivers/watchdog/Makefile b/drivers/watchdog/Makefile
> index 0474d38aa854..1f9a0235f22c 100644
> --- a/drivers/watchdog/Makefile
> +++ b/drivers/watchdog/Makefile
> @@ -94,10 +94,6 @@ obj-$(CONFIG_SPRD_WATCHDOG) += sprd_wdt.o
>  # BLACKFIN Architecture
>  obj-$(CONFIG_BFIN_WDT) += bfin_wdt.o
>  
> -# CRIS Architecture
> -
> -# FRV Architecture
> -
>  # X86 (i386 + ia64 + x86_64) Architecture
>  obj-$(CONFIG_ACQUIRE_WDT) += acquirewdt.o
>  obj-$(CONFIG_ADVANTECH_WDT) += advantechwdt.o
> @@ -146,8 +142,6 @@ obj-$(CONFIG_INTEL_MEI_WDT) += mei_wdt.o
>  obj-$(CONFIG_NI903X_WDT) += ni903x_wdt.o
>  obj-$(CONFIG_NIC7018_WDT) += nic7018_wdt.o
>  
> -# M32R Architecture
> -
>  # M68K Architecture
>  obj-$(CONFIG_M54xx_WATCHDOG) += m54xx_wdt.o
>  
> diff --git a/fs/Kconfig.binfmt b/fs/Kconfig.binfmt
> index 58c2bbd385ad..57a27c42b5ac 100644
> --- a/fs/Kconfig.binfmt
> +++ b/fs/Kconfig.binfmt
> @@ -1,6 +1,6 @@
>  config BINFMT_ELF
>  	bool "Kernel support for ELF binaries"
> -	depends on MMU && (BROKEN || !FRV)
> +	depends on MMU
>  	select ELFCORE
>  	default y
>  	---help---
> @@ -35,7 +35,7 @@ config ARCH_BINFMT_ELF_STATE
>  config BINFMT_ELF_FDPIC
>  	bool "Kernel support for FDPIC ELF binaries"
>  	default y if !BINFMT_ELF
> -	depends on (ARM || FRV || BLACKFIN || (SUPERH32 && !MMU) || C6X)
> +	depends on (ARM || (SUPERH32 && !MMU) || C6X)
>  	select ELFCORE
>  	help
>  	  ELF FDPIC binaries are based on ELF, but allow the individual load
> @@ -90,7 +90,6 @@ config BINFMT_SCRIPT
>  config BINFMT_FLAT
>  	bool "Kernel support for flat binaries"
>  	depends on !MMU || ARM || M68K
> -	depends on !FRV || BROKEN
>  	help
>  	  Support uClinux FLAT format binaries.
>  
> diff --git a/fs/minix/Kconfig b/fs/minix/Kconfig
> index f2a0cfcef11d..bcd53a79156f 100644
> --- a/fs/minix/Kconfig
> +++ b/fs/minix/Kconfig
> @@ -18,7 +18,7 @@ config MINIX_FS
>  
>  config MINIX_FS_NATIVE_ENDIAN
>  	def_bool MINIX_FS
> -	depends on M32R || MICROBLAZE || MIPS || S390 || SUPERH || SPARC || XTENSA || (M68K && !MMU)
> +	depends on MICROBLAZE || MIPS || S390 || SUPERH || SPARC || XTENSA || (M68K && !MMU)
>  
>  config MINIX_FS_BIG_ENDIAN_16BIT_INDEXED
>  	def_bool MINIX_FS
> diff --git a/include/linux/ide.h b/include/linux/ide.h
> index 20d42c0d9fb6..1d6f16110eae 100644
> --- a/include/linux/ide.h
> +++ b/include/linux/ide.h
> @@ -25,15 +25,10 @@
>  #include <asm/byteorder.h>
>  #include <asm/io.h>
>  
> -#if defined(CONFIG_CRIS) || defined(CONFIG_FRV)
> -# define SUPPORT_VLB_SYNC 0
> -#else
> -# define SUPPORT_VLB_SYNC 1
> -#endif
> -
>  /*
>   * Probably not wise to fiddle with these
>   */
> +#define SUPPORT_VLB_SYNC 1
>  #define IDE_DEFAULT_MAX_FAILURES	1
>  #define ERROR_MAX	8	/* Max read/write errors per sector */
>  #define ERROR_RESET	3	/* Reset controller every 4th retry */
> diff --git a/init/Kconfig b/init/Kconfig
> index a14bcc9724a2..2852692d7c9c 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -998,7 +998,6 @@ config RELAY
>  
>  config BLK_DEV_INITRD
>  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
> -	depends on BROKEN || !FRV
>  	help
>  	  The initial RAM filesystem is a ramfs which is loaded by the
>  	  boot loader (loadlin or lilo) and that is mounted as root
> @@ -1108,7 +1107,7 @@ config MULTIUSER
>  
>  config SGETMASK_SYSCALL
>  	bool "sgetmask/ssetmask syscalls support" if EXPERT
> -	def_bool PARISC || BLACKFIN || M68K || PPC || MIPS || X86 || SPARC || CRIS || MICROBLAZE || SUPERH
> +	def_bool PARISC || M68K || PPC || MIPS || X86 || SPARC || MICROBLAZE || SUPERH
>  	---help---
>  	  sys_sgetmask and sys_ssetmask are obsolete system calls
>  	  no longer supported in libc but still enabled by default in some
> @@ -1370,7 +1369,7 @@ config KALLSYMS_ABSOLUTE_PERCPU
>  config KALLSYMS_BASE_RELATIVE
>  	bool
>  	depends on KALLSYMS
> -	default !IA64 && !(TILE && 64BIT)
> +	default !IA64
>  	help
>  	  Instead of emitting them as absolute values in the native word size,
>  	  emit the symbol references in the kallsyms table as 32-bit entries,
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 41ac9d294245..6927c6d8d185 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -165,7 +165,7 @@ config DEBUG_INFO_REDUCED
>  
>  config DEBUG_INFO_SPLIT
>  	bool "Produce split debuginfo in .dwo files"
> -	depends on DEBUG_INFO && !FRV
> +	depends on DEBUG_INFO
>  	help
>  	  Generate debug info into separate .dwo files. This significantly
>  	  reduces the build directory size for builds with DEBUG_INFO,
> @@ -354,10 +354,7 @@ config ARCH_WANT_FRAME_POINTERS
>  
>  config FRAME_POINTER
>  	bool "Compile the kernel with frame pointers"
> -	depends on DEBUG_KERNEL && \
> -		(CRIS || M68K || FRV || UML || \
> -		 SUPERH || BLACKFIN) || \
> -		ARCH_WANT_FRAME_POINTERS
> +	depends on DEBUG_KERNEL && (M68K || UML || SUPERH) || ARCH_WANT_FRAME_POINTERS
>  	default y if (DEBUG_INFO && UML) || ARCH_WANT_FRAME_POINTERS
>  	help
>  	  If you say Y here the resulting kernel image will be slightly
> @@ -1138,7 +1135,7 @@ config LOCKDEP
>  	bool
>  	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
>  	select STACKTRACE
> -	select FRAME_POINTER if !MIPS && !PPC && !ARM_UNWIND && !S390 && !MICROBLAZE && !ARC && !SCORE && !X86
> +	select FRAME_POINTER if !MIPS && !PPC && !ARM_UNWIND && !S390 && !MICROBLAZE && !ARC && !X86
>  	select KALLSYMS
>  	select KALLSYMS_ALL
>  
> @@ -1571,7 +1568,7 @@ config FAULT_INJECTION_STACKTRACE_FILTER
>  	depends on FAULT_INJECTION_DEBUG_FS && STACKTRACE_SUPPORT
>  	depends on !X86_64
>  	select STACKTRACE
> -	select FRAME_POINTER if !MIPS && !PPC && !S390 && !MICROBLAZE && !ARM_UNWIND && !ARC && !SCORE && !X86
> +	select FRAME_POINTER if !MIPS && !PPC && !S390 && !MICROBLAZE && !ARM_UNWIND && !ARC && !X86
>  	help
>  	  Provide stacktrace filter for fault-injection capabilities
>  
> @@ -1969,7 +1966,7 @@ config STRICT_DEVMEM
>  	bool "Filter access to /dev/mem"
>  	depends on MMU && DEVMEM
>  	depends on ARCH_HAS_DEVMEM_IS_ALLOWED
> -	default y if TILE || PPC || X86 || ARM64
> +	default y if PPC || X86 || ARM64
>  	---help---
>  	  If this option is disabled, you allow userspace (root) access to all
>  	  of memory, including kernel and userspace memory. Accidental
> diff --git a/lib/test_user_copy.c b/lib/test_user_copy.c
> index a6556f3364d1..e161f0498f42 100644
> --- a/lib/test_user_copy.c
> +++ b/lib/test_user_copy.c
> @@ -31,8 +31,6 @@
>   * their capability at compile-time, we just have to opt-out certain archs.
>   */
>  #if BITS_PER_LONG == 64 || (!(defined(CONFIG_ARM) && !defined(MMU)) && \
> -			    !defined(CONFIG_BLACKFIN) &&	\
> -			    !defined(CONFIG_M32R) &&		\
>  			    !defined(CONFIG_M68K) &&		\
>  			    !defined(CONFIG_MICROBLAZE) &&	\
>  			    !defined(CONFIG_NIOS2) &&		\
> diff --git a/mm/Kconfig b/mm/Kconfig
> index abefa573bcd8..d5004d82a1d6 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -278,13 +278,6 @@ config BOUNCE
>  	  by default when ZONE_DMA or HIGHMEM is selected, but you
>  	  may say n to override this.
>  
> -# On the 'tile' arch, USB OHCI needs the bounce pool since tilegx will often
> -# have more than 4GB of memory, but we don't currently use the IOTLB to present
> -# a 32-bit address to OHCI.  So we need to use a bounce pool instead.
> -config NEED_BOUNCE_POOL
> -	bool
> -	default y if TILE && USB_OHCI_HCD
> -
>  config NR_QUICK
>  	int
>  	depends on QUICKLIST
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 50e7fdf84055..79e3549cab0f 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2719,11 +2719,7 @@ void __init setup_per_cpu_areas(void)
>  
>  	if (pcpu_setup_first_chunk(ai, fc) < 0)
>  		panic("Failed to initialize percpu areas.");
> -#ifdef CONFIG_CRIS
> -#warning "the CRIS architecture has physical and virtual addresses confused"
> -#else
>  	pcpu_free_alloc_info(ai);
> -#endif
>  }
>  
>  #endif	/* CONFIG_SMP */
> -- 
> 2.9.0
> 

-- 
Alexandre Belloni, Bootlin (formerly Free Electrons)
Embedded Linux and Kernel engineering
https://bootlin.com
