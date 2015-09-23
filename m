Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4A31C6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 15:56:32 -0400 (EDT)
Received: by qgez77 with SMTP id z77so28666848qge.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 12:56:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d51si5682055qge.43.2015.09.23.12.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 12:56:31 -0700 (PDT)
Date: Wed, 23 Sep 2015 12:56:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: undefined reference to `byte_rev_table'
Message-Id: <20150923125629.e15ef6ce76a6dad93cd2bebf@linux-foundation.org>
In-Reply-To: <201509240337.MLtXsNnm%fengguang.wu@intel.com>
References: <201509240337.MLtXsNnm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: yalin wang <yalin.wang2010@gmail.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 24 Sep 2015 03:23:38 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   bcee19f424a0d8c26ecf2607b73c690802658b29
> commit: 8b235f2f16a472b8cfc10e8ef1286fcd3331e033 zlib_deflate/deftree: remove bi_reverse()
> date:   13 days ago
> config: x86_64-randconfig-s2-09240230 (attached as .config)
> reproduce:
>   git checkout 8b235f2f16a472b8cfc10e8ef1286fcd3331e033
>   # save the attached .config to linux build tree
>   make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    lib/built-in.o: In function `gen_codes':
>    deftree.c:(.text+0xe6c9): undefined reference to `byte_rev_table'
>    deftree.c:(.text+0xe70f): undefined reference to `byte_rev_table'
>    deftree.c:(.text+0xe716): undefined reference to `byte_rev_table'
>    lib/built-in.o: In function `zlib_tr_init':
> >> (.text+0xecca): undefined reference to `byte_rev_table'
>    drivers/built-in.o: In function `zhenhua_interrupt':
>    zhenhua.c:(.text+0x103b71): undefined reference to `byte_rev_table'

I don't see how 8b235f2f16a472b8cfc10e8ef1286fcd3331e033 could have
caused this.

The problem is caused by

CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_BITREVERSE=m


It's silly to have a config option to make bitrevX() usable.  I'd say a
suitable fix is to remove CONFIG_BITREVERSE and, if
CONFIG_HAVE_ARCH_BITREVERSE=n, link bitrev.o into vmlinux.  Something
like the below.


But I think I'll take the path of least resistance and make
CONFIG_JOYSTICK_ZHENHUA select BITERVERSE.



 drivers/atm/Kconfig                |    1 -
 drivers/bluetooth/Kconfig          |    1 -
 drivers/char/pcmcia/Kconfig        |    1 -
 drivers/iio/amplifiers/Kconfig     |    1 -
 drivers/isdn/Kconfig               |    1 -
 drivers/isdn/gigaset/Kconfig       |    1 -
 drivers/isdn/hisax/Kconfig         |    1 -
 drivers/media/pci/solo6x10/Kconfig |    1 -
 drivers/media/rc/Kconfig           |    8 --------
 drivers/media/tuners/Kconfig       |    1 -
 drivers/mtd/devices/Kconfig        |    1 -
 drivers/mtd/nand/Kconfig           |    1 -
 drivers/net/ethernet/Kconfig       |    1 -
 drivers/net/ethernet/amd/Kconfig   |    1 -
 drivers/net/fddi/Kconfig           |    1 -
 drivers/net/usb/Kconfig            |    2 --
 drivers/rtc/Kconfig                |    1 -
 drivers/video/fbdev/Kconfig        |    3 ---
 lib/Kconfig                        |    7 +------
 lib/Makefile                       |    5 ++++-
 lib/bitrev.c                       |    3 ---
 sound/pci/Kconfig                  |    1 -
 sound/usb/Kconfig                  |    2 --
 23 files changed, 5 insertions(+), 41 deletions(-)

diff -puN drivers/atm/Kconfig~a drivers/atm/Kconfig
--- a/drivers/atm/Kconfig~a
+++ a/drivers/atm/Kconfig
@@ -246,7 +246,6 @@ config ATM_IDT77252_USE_SUNI
 config ATM_AMBASSADOR
 	tristate "Madge Ambassador (Collage PCI 155 Server)"
 	depends on PCI && VIRT_TO_BUS
-	select BITREVERSE
 	help
 	  This is a driver for ATMizer based ATM card produced by Madge
 	  Networks Ltd. Say Y (or M to compile as a module named ambassador)
diff -puN drivers/bluetooth/Kconfig~a drivers/bluetooth/Kconfig
--- a/drivers/bluetooth/Kconfig~a
+++ a/drivers/bluetooth/Kconfig
@@ -88,7 +88,6 @@ config BT_HCIUART_H4
 config BT_HCIUART_BCSP
 	bool "BCSP protocol support"
 	depends on BT_HCIUART
-	select BITREVERSE
 	help
 	  BCSP (BlueCore Serial Protocol) is serial protocol for communication
 	  between Bluetooth device and host. This protocol is required for non
diff -puN drivers/char/pcmcia/Kconfig~a drivers/char/pcmcia/Kconfig
--- a/drivers/char/pcmcia/Kconfig~a
+++ a/drivers/char/pcmcia/Kconfig
@@ -21,7 +21,6 @@ config SYNCLINK_CS
 config CARDMAN_4000
 	tristate "Omnikey Cardman 4000 support"
 	depends on PCMCIA
-	select BITREVERSE
 	help
 	  Enable support for the Omnikey Cardman 4000 PCMCIA Smartcard
 	  reader.
diff -puN drivers/iio/amplifiers/Kconfig~a drivers/iio/amplifiers/Kconfig
--- a/drivers/iio/amplifiers/Kconfig~a
+++ a/drivers/iio/amplifiers/Kconfig
@@ -8,7 +8,6 @@ menu "Amplifiers"
 config AD8366
 	tristate "Analog Devices AD8366 VGA"
 	depends on SPI
-	select BITREVERSE
 	help
 	  Say yes here to build support for Analog Devices AD8366
 	  SPI Dual-Digital Variable Gain Amplifier (VGA).
diff -puN drivers/isdn/Kconfig~a drivers/isdn/Kconfig
--- a/drivers/isdn/Kconfig~a
+++ a/drivers/isdn/Kconfig
@@ -73,6 +73,5 @@ source "drivers/isdn/mISDN/Kconfig"
 config ISDN_HDLC
 	tristate
 	select CRC_CCITT
-	select BITREVERSE
 
 endif # ISDN
diff -puN drivers/isdn/gigaset/Kconfig~a drivers/isdn/gigaset/Kconfig
--- a/drivers/isdn/gigaset/Kconfig~a
+++ a/drivers/isdn/gigaset/Kconfig
@@ -2,7 +2,6 @@ menuconfig ISDN_DRV_GIGASET
 	tristate "Siemens Gigaset support"
 	depends on TTY
 	select CRC_CCITT
-	select BITREVERSE
 	help
 	  This driver supports the Siemens Gigaset SX205/255 family of
 	  ISDN DECT bases, including the predecessors Gigaset 3070/3075
diff -puN drivers/isdn/hisax/Kconfig~a drivers/isdn/hisax/Kconfig
--- a/drivers/isdn/hisax/Kconfig~a
+++ a/drivers/isdn/hisax/Kconfig
@@ -391,7 +391,6 @@ config HISAX_ST5481
 	depends on USB
 	select ISDN_HDLC
 	select CRC_CCITT
-	select BITREVERSE
 	help
 	  This enables the driver for ST5481 based USB ISDN adapters,
 	  e.g. the BeWan Gazel 128 USB
diff -puN drivers/media/pci/solo6x10/Kconfig~a drivers/media/pci/solo6x10/Kconfig
--- a/drivers/media/pci/solo6x10/Kconfig~a
+++ a/drivers/media/pci/solo6x10/Kconfig
@@ -2,7 +2,6 @@ config VIDEO_SOLO6X10
 	tristate "Bluecherry / Softlogic 6x10 capture cards (MPEG-4/H.264)"
 	depends on PCI && VIDEO_DEV && SND && I2C
 	depends on HAS_DMA
-	select BITREVERSE
 	select FONT_SUPPORT
 	select FONT_8x16
 	select VIDEOBUF2_DMA_SG
diff -puN drivers/media/rc/Kconfig~a drivers/media/rc/Kconfig
--- a/drivers/media/rc/Kconfig~a
+++ a/drivers/media/rc/Kconfig
@@ -37,7 +37,6 @@ config IR_LIRC_CODEC
 config IR_NEC_DECODER
 	tristate "Enable IR raw decoder for the NEC protocol"
 	depends on RC_CORE
-	select BITREVERSE
 	default y
 
 	---help---
@@ -47,7 +46,6 @@ config IR_NEC_DECODER
 config IR_RC5_DECODER
 	tristate "Enable IR raw decoder for the RC-5 protocol"
 	depends on RC_CORE
-	select BITREVERSE
 	default y
 
 	---help---
@@ -57,7 +55,6 @@ config IR_RC5_DECODER
 config IR_RC6_DECODER
 	tristate "Enable IR raw decoder for the RC6 protocol"
 	depends on RC_CORE
-	select BITREVERSE
 	default y
 
 	---help---
@@ -67,7 +64,6 @@ config IR_RC6_DECODER
 config IR_JVC_DECODER
 	tristate "Enable IR raw decoder for the JVC protocol"
 	depends on RC_CORE
-	select BITREVERSE
 	default y
 
 	---help---
@@ -77,7 +73,6 @@ config IR_JVC_DECODER
 config IR_SONY_DECODER
 	tristate "Enable IR raw decoder for the Sony protocol"
 	depends on RC_CORE
-	select BITREVERSE
 	default y
 
 	---help---
@@ -106,7 +101,6 @@ config IR_SHARP_DECODER
 config IR_MCE_KBD_DECODER
 	tristate "Enable IR raw decoder for the MCE keyboard/mouse protocol"
 	depends on RC_CORE
-	select BITREVERSE
 	default y
 
 	---help---
@@ -117,7 +111,6 @@ config IR_MCE_KBD_DECODER
 config IR_XMP_DECODER
 	tristate "Enable IR raw decoder for the XMP protocol"
 	depends on RC_CORE
-	select BITREVERSE
 	default y
 
 	---help---
@@ -278,7 +271,6 @@ config IR_WINBOND_CIR
 	depends on RC_CORE
 	select NEW_LEDS
 	select LEDS_CLASS
-	select BITREVERSE
 	---help---
 	   Say Y here if you want to use the IR remote functionality found
 	   in some Winbond SuperI/O chips. Currently only the WPCD376I
diff -puN drivers/media/tuners/Kconfig~a drivers/media/tuners/Kconfig
--- a/drivers/media/tuners/Kconfig~a
+++ a/drivers/media/tuners/Kconfig
@@ -260,7 +260,6 @@ config MEDIA_TUNER_R820T
 	tristate "Rafael Micro R820T silicon tuner"
 	depends on MEDIA_SUPPORT && I2C
 	default m if !MEDIA_SUBDRV_AUTOSELECT
-	select BITREVERSE
 	help
 	  Rafael Micro R820T silicon tuner driver.
 
diff -puN drivers/mtd/devices/Kconfig~a drivers/mtd/devices/Kconfig
--- a/drivers/mtd/devices/Kconfig~a
+++ a/drivers/mtd/devices/Kconfig
@@ -209,7 +209,6 @@ config MTD_DOCG3
 	tristate "M-Systems Disk-On-Chip G3"
 	select BCH
 	select BCH_CONST_PARAMS
-	select BITREVERSE
 	---help---
 	  This provides an MTD device driver for the M-Systems DiskOnChip
 	  G3 devices.
diff -puN drivers/mtd/nand/Kconfig~a drivers/mtd/nand/Kconfig
--- a/drivers/mtd/nand/Kconfig~a
+++ a/drivers/mtd/nand/Kconfig
@@ -278,7 +278,6 @@ config MTD_NAND_DOCG4
 	tristate "Support for DiskOnChip G4"
 	depends on HAS_IOMEM
 	select BCH
-	select BITREVERSE
 	help
 	  Support for diskonchip G4 nand flash, found in various smartphones and
 	  PDAs, among them the Palm Treo680, HTC Prophet and Wizard, Toshiba
diff -puN drivers/net/ethernet/Kconfig~a drivers/net/ethernet/Kconfig
--- a/drivers/net/ethernet/Kconfig~a
+++ a/drivers/net/ethernet/Kconfig
@@ -146,7 +146,6 @@ config ETHOC
 	select MII
 	select PHYLIB
 	select CRC32
-	select BITREVERSE
 	---help---
 	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
 
diff -puN drivers/net/ethernet/amd/Kconfig~a drivers/net/ethernet/amd/Kconfig
--- a/drivers/net/ethernet/amd/Kconfig~a
+++ a/drivers/net/ethernet/amd/Kconfig
@@ -175,7 +175,6 @@ config AMD_XGBE
 	tristate "AMD 10GbE Ethernet driver"
 	depends on ((OF_NET && OF_ADDRESS) || ACPI) && HAS_IOMEM && HAS_DMA
 	depends on ARM64 || COMPILE_TEST
-	select BITREVERSE
 	select CRC32
 	select PTP_1588_CLOCK
 	---help---
diff -puN drivers/net/fddi/Kconfig~a drivers/net/fddi/Kconfig
--- a/drivers/net/fddi/Kconfig~a
+++ a/drivers/net/fddi/Kconfig
@@ -45,7 +45,6 @@ config DEFXX_MMIO
 config SKFP
 	tristate "SysKonnect FDDI PCI support"
 	depends on FDDI && PCI
-	select BITREVERSE
 	---help---
 	  Say Y here if you have a SysKonnect FDDI PCI adapter.
 	  The following adapters are supported by this driver:
diff -puN drivers/net/usb/Kconfig~a drivers/net/usb/Kconfig
--- a/drivers/net/usb/Kconfig~a
+++ a/drivers/net/usb/Kconfig
@@ -327,7 +327,6 @@ config USB_NET_SR9800
 config USB_NET_SMSC75XX
 	tristate "SMSC LAN75XX based USB 2.0 gigabit ethernet devices"
 	depends on USB_USBNET
-	select BITREVERSE
 	select CRC16
 	select CRC32
 	help
@@ -337,7 +336,6 @@ config USB_NET_SMSC75XX
 config USB_NET_SMSC95XX
 	tristate "SMSC LAN95XX based USB 2.0 10/100 ethernet devices"
 	depends on USB_USBNET
-	select BITREVERSE
 	select CRC16
 	select CRC32
 	help
diff -puN drivers/rtc/Kconfig~a drivers/rtc/Kconfig
--- a/drivers/rtc/Kconfig~a
+++ a/drivers/rtc/Kconfig
@@ -539,7 +539,6 @@ config RTC_DRV_RC5T583
 
 config RTC_DRV_S35390A
 	tristate "Seiko Instruments S-35390A"
-	select BITREVERSE
 	help
 	  If you say yes here you will get support for the Seiko
 	  Instruments S-35390A.
diff -puN drivers/video/fbdev/Kconfig~a drivers/video/fbdev/Kconfig
--- a/drivers/video/fbdev/Kconfig~a
+++ a/drivers/video/fbdev/Kconfig
@@ -709,7 +709,6 @@ config FB_TGA
 	select FB_CFB_FILLRECT
 	select FB_CFB_COPYAREA
 	select FB_CFB_IMAGEBLIT
-	select BITREVERSE
 	---help---
 	  This is the frame buffer device driver for generic TGA and SFB+
 	  graphic cards.  These include DEC ZLXp-E1, -E2 and -E3 PCI cards,
@@ -1007,7 +1006,6 @@ config FB_NVIDIA
 	select FB_CFB_FILLRECT
 	select FB_CFB_COPYAREA
 	select FB_CFB_IMAGEBLIT
-	select BITREVERSE
 	select VGASTATE
 	help
 	  This driver supports graphics boards with the nVidia chips, TNT
@@ -1055,7 +1053,6 @@ config FB_RIVA
 	select FB_CFB_FILLRECT
 	select FB_CFB_COPYAREA
 	select FB_CFB_IMAGEBLIT
-	select BITREVERSE
 	select VGASTATE
 	help
 	  This driver supports graphics boards with the nVidia Riva/Geforce
diff -puN lib/Kconfig~a lib/Kconfig
--- a/lib/Kconfig~a
+++ a/lib/Kconfig
@@ -10,13 +10,9 @@ menu "Library routines"
 config RAID6_PQ
 	tristate
 
-config BITREVERSE
-	tristate
-
 config HAVE_ARCH_BITREVERSE
 	bool
 	default n
-	depends on BITREVERSE
 	help
 	  This option enables the use of hardware bit-reversal instructions on
 	  architectures which support such operations.
@@ -95,8 +91,7 @@ config CRC_ITU_T
 config CRC32
 	tristate "CRC32/CRC32c functions"
 	default y
-	select BITREVERSE
-	help
+q	help
 	  This option is provided for the case where no in-kernel-tree
 	  modules require CRC32/CRC32c functions, but a module built outside
 	  the kernel tree does. Such modules that use library CRC32/CRC32c
diff -puN lib/Makefile~a lib/Makefile
--- a/lib/Makefile~a
+++ a/lib/Makefile
@@ -71,7 +71,10 @@ ifneq ($(CONFIG_HAVE_DEC_LOCK),y)
   lib-y += dec_and_lock.o
 endif
 
-obj-$(CONFIG_BITREVERSE) += bitrev.o
+ifneq ($(CONFIG_HAVE_ARCH_BITREVERSE),y)
+	lib-y += bitrev.o
+endif
+
 obj-$(CONFIG_RATIONAL)	+= rational.o
 obj-$(CONFIG_CRC_CCITT)	+= crc-ccitt.o
 obj-$(CONFIG_CRC16)	+= crc16.o
diff -puN lib/bitrev.c~a lib/bitrev.c
--- a/lib/bitrev.c~a
+++ a/lib/bitrev.c
@@ -1,4 +1,3 @@
-#ifndef CONFIG_HAVE_ARCH_BITREVERSE
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/bitrev.h>
@@ -42,5 +41,3 @@ const u8 byte_rev_table[256] = {
 	0x1f, 0x9f, 0x5f, 0xdf, 0x3f, 0xbf, 0x7f, 0xff,
 };
 EXPORT_SYMBOL_GPL(byte_rev_table);
-
-#endif /* CONFIG_HAVE_ARCH_BITREVERSE */
diff -puN sound/pci/Kconfig~a sound/pci/Kconfig
--- a/sound/pci/Kconfig~a
+++ a/sound/pci/Kconfig
@@ -611,7 +611,6 @@ config SND_ICE1712
 	tristate "ICEnsemble ICE1712 (Envy24)"
 	select SND_MPU401_UART
 	select SND_AC97_CODEC
-	select BITREVERSE
 	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on the
diff -puN sound/usb/Kconfig~a sound/usb/Kconfig
--- a/sound/usb/Kconfig~a
+++ a/sound/usb/Kconfig
@@ -14,7 +14,6 @@ config SND_USB_AUDIO
 	select SND_HWDEP
 	select SND_RAWMIDI
 	select SND_PCM
-	select BITREVERSE
 	help
 	  Say Y here to include support for USB audio and USB MIDI
 	  devices.
@@ -104,7 +103,6 @@ config SND_USB_US122L
 config SND_USB_6FIRE
         tristate "TerraTec DMX 6Fire USB"
         select FW_LOADER
-        select BITREVERSE
         select SND_RAWMIDI
         select SND_PCM
         select SND_VMASTER
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
