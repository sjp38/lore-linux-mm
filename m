Date: Thu, 28 Dec 2006 23:11:51 -0200
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: [PATCH 2/2] optional ZONE_DMA
Message-ID: <20061229011151.GA2074@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>, Andi Kleen <ak@suse.de>, Arjan van de Ven <arjan@infradead.org>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following patch turns ZONE_DMA into a configurable option on x86.

It also adds "select ZONE_DMA" entries in corresponding Kconfig files 
for in-tree PCI drivers which have <32bit addressing limitation.

Comments?

diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/arch/i386/Kconfig linux-2.6.20-rc2/arch/i386/Kconfig
--- linux-2.6.20-rc2.orig/arch/i386/Kconfig	2006-12-28 20:04:40.000000000 -0200
+++ linux-2.6.20-rc2/arch/i386/Kconfig	2006-12-28 20:31:00.000000000 -0200
@@ -46,10 +46,6 @@
 	bool
 	default y
 
-config ZONE_DMA
-	bool
-	default y
-
 config SBUS
 	bool
 
@@ -584,6 +580,18 @@
 	default y
 	select RESOURCES_64BIT
 
+config ZONE_DMA
+	bool "DMA zone support"
+	default y
+	help
+	  This enables support for the 16MiB DMA zone. Only disable this
+	  option if you are _absolutely_ sure that your devices contain
+	  no DMA addressing limitations.
+
+	  Note: disabling this option erroneously will cause random memory
+	  corruption.
+
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
@@ -1146,6 +1154,7 @@
 config GENERIC_ISA_DMA
 	bool "ISA DMA API"
 	select ISA_DMA_API
+	select ZONE_DMA
 	default y
 	help
 	  This enables support for the ISA DMA API. 
@@ -1174,6 +1183,7 @@
 config MCA
 	bool "MCA support" if !(X86_VISWS || X86_VOYAGER)
 	default y if X86_VOYAGER
+	select ZONE_DMA
 	help
 	  MicroChannel Architecture is found in some IBM PS/2 machines and
 	  laptops.  It is a bus system similar to PCI or ISA. See
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/arch/i386/kernel/setup.c linux-2.6.20-rc2/arch/i386/kernel/setup.c
--- linux-2.6.20-rc2.orig/arch/i386/kernel/setup.c	2006-12-28 17:35:58.000000000 -0200
+++ linux-2.6.20-rc2/arch/i386/kernel/setup.c	2006-12-28 20:14:03.000000000 -0200
@@ -372,8 +372,10 @@
 {
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
+#ifdef CONFIG_ZONE_DMA
 	max_zone_pfns[ZONE_DMA] =
 		virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+#endif
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 #ifdef CONFIG_HIGHMEM
 	max_zone_pfns[ZONE_HIGHMEM] = highend_pfn;
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/drivers/block/Kconfig linux-2.6.20-rc2/drivers/block/Kconfig
--- linux-2.6.20-rc2.orig/drivers/block/Kconfig	2006-12-28 17:35:58.000000000 -0200
+++ linux-2.6.20-rc2/drivers/block/Kconfig	2006-12-28 20:14:03.000000000 -0200
@@ -8,7 +8,7 @@
 
 config BLK_DEV_FD
 	tristate "Normal floppy disk support"
-	depends on ARCH_MAY_HAVE_PC_FDC
+	depends on ARCH_MAY_HAVE_PC_FDC && GENERIC_ISA_DMA
 	---help---
 	  If you want to use the floppy disk drive(s) of your PC under Linux,
 	  say Y. Information about this driver, especially important for IBM
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/drivers/net/Kconfig linux-2.6.20-rc2/drivers/net/Kconfig
--- linux-2.6.20-rc2.orig/drivers/net/Kconfig	2006-12-28 17:35:59.000000000 -0200
+++ linux-2.6.20-rc2/drivers/net/Kconfig	2006-12-28 20:14:03.000000000 -0200
@@ -1400,6 +1400,7 @@
 	tristate "Broadcom 4400 ethernet support"
 	depends on NET_PCI && PCI
 	select MII
+	select ZONE_DMA
 	help
 	  If you have a network (Ethernet) controller of this type, say Y and
 	  read the Ethernet-HOWTO, available from
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/drivers/net/wan/Kconfig linux-2.6.20-rc2/drivers/net/wan/Kconfig
--- linux-2.6.20-rc2.orig/drivers/net/wan/Kconfig	2006-12-24 02:00:32.000000000 -0200
+++ linux-2.6.20-rc2/drivers/net/wan/Kconfig	2006-12-28 20:14:03.000000000 -0200
@@ -186,6 +186,7 @@
 config WANXL
 	tristate "SBE Inc. wanXL support"
 	depends on HDLC && PCI
+	select ZONE_DMA
 	help
 	  Driver for wanXL PCI cards by SBE Inc.
 
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/drivers/net/wireless/bcm43xx/Kconfig linux-2.6.20-rc2/drivers/net/wireless/bcm43xx/Kconfig
--- linux-2.6.20-rc2.orig/drivers/net/wireless/bcm43xx/Kconfig	2006-12-24 02:00:32.000000000 -0200
+++ linux-2.6.20-rc2/drivers/net/wireless/bcm43xx/Kconfig	2006-12-28 20:21:06.000000000 -0200
@@ -3,6 +3,7 @@
 	depends on PCI && IEEE80211 && IEEE80211_SOFTMAC && NET_RADIO && EXPERIMENTAL
 	select FW_LOADER
 	select HW_RANDOM
+	select ZONE_DMA
 	---help---
 	  This is an experimental driver for the Broadcom 43xx wireless chip,
 	  found in the Apple Airport Extreme and various other devices.
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/drivers/scsi/Kconfig linux-2.6.20-rc2/drivers/scsi/Kconfig
--- linux-2.6.20-rc2.orig/drivers/scsi/Kconfig	2006-12-24 02:00:32.000000000 -0200
+++ linux-2.6.20-rc2/drivers/scsi/Kconfig	2006-12-28 20:14:03.000000000 -0200
@@ -413,6 +413,7 @@
 config SCSI_AACRAID
 	tristate "Adaptec AACRAID support"
 	depends on SCSI && PCI
+	select ZONE_DMA
 	help
 	  This driver supports a variety of Dell, HP, Adaptec, IBM and
 	  ICP storage products. For a list of supported products, refer
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/drivers/usb/host/Kconfig linux-2.6.20-rc2/drivers/usb/host/Kconfig
--- linux-2.6.20-rc2.orig/drivers/usb/host/Kconfig	2006-12-24 02:00:32.000000000 -0200
+++ linux-2.6.20-rc2/drivers/usb/host/Kconfig	2006-12-28 20:35:12.000000000 -0200
@@ -7,6 +7,7 @@
 config USB_EHCI_HCD
 	tristate "EHCI HCD (USB 2.0) support"
 	depends on USB && USB_ARCH_HAS_EHCI
+	select ZONE_DMA if (X86 && VMSPLIT_1G)
 	---help---
 	  The Enhanced Host Controller Interface (EHCI) is standard for USB 2.0
 	  "high speed" (480 Mbit/sec, 60 Mbyte/sec) host controller hardware.
diff -Nur --exclude-from=excl linux-2.6.20-rc2.orig/sound/pci/Kconfig linux-2.6.20-rc2/sound/pci/Kconfig
--- linux-2.6.20-rc2.orig/sound/pci/Kconfig	2006-12-28 17:36:02.000000000 -0200
+++ linux-2.6.20-rc2/sound/pci/Kconfig	2006-12-28 20:14:03.000000000 -0200
@@ -21,6 +21,7 @@
 	select SND_PCM
 	select SND_AC97_CODEC
 	select SND_OPL3_LIB
+	select ZONE_DMA
 	help
 	  Say 'Y' or 'M' to include support for Avance Logic ALS300/ALS300+
 
@@ -33,6 +34,7 @@
 	select SND_OPL3_LIB
 	select SND_MPU401_UART
 	select SND_PCM
+	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on Avance Logic
 	  ALS4000 chips.
@@ -45,6 +47,7 @@
 	depends on SND
 	select SND_MPU401_UART
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y here to include support for the integrated AC97 sound
 	  device on motherboards using the ALi M5451 Audio Controller
@@ -127,6 +130,7 @@
 	select SND_OPL3_LIB
 	select SND_MPU401_UART
 	select SND_PCM
+	select ZONE_DMA
 	help
 	  Say Y here to include support for Aztech AZF3328 (PCI168)
 	  soundcards.
@@ -377,6 +381,7 @@
 	select SND_HWDEP
 	select SND_RAWMIDI
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y to include support for Sound Blaster PCI 512, Live!,
 	  Audigy and E-mu APS (partially supported) soundcards.
@@ -393,6 +398,7 @@
 	depends on SND
 	select SND_AC97_CODEC
 	select SND_RAWMIDI
+	select ZONE_DMA
 	help
 	  Say Y here to include support for the Dell OEM version of the
 	  Sound Blaster Live!.
@@ -429,6 +435,7 @@
 	select SND_OPL3_LIB
 	select SND_MPU401_UART
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on ESS Solo-1
 	  (ES1938, ES1946, ES1969) chips.
@@ -441,6 +448,7 @@
 	depends on SND
 	select SND_MPU401_UART
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on ESS Maestro
 	  1/2/2E chips.
@@ -520,6 +528,7 @@
 	depends on SND
 	select SND_MPU401_UART
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on the
 	  ICE1712 (Envy24) chip.
@@ -589,6 +598,7 @@
 	depends on SND
 	select FW_LOADER
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on ESS Maestro 3
 	  (Allegro) chips.
@@ -682,6 +692,7 @@
 	select SND_OPL3_LIB
 	select SND_MPU401_UART
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on the S3
 	  SonicVibes chip.
@@ -694,6 +705,7 @@
 	depends on SND
 	select SND_MPU401_UART
 	select SND_AC97_CODEC
+	select ZONE_DMA
 	help
 	  Say Y here to include support for soundcards based on Trident
 	  4D-Wave DX/NX or SiS 7018 chips.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
