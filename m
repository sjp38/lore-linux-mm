Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080704143058.GB23215@mit.edu>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <486E2818.1060003@garzik.org>  <20080704143058.GB23215@mit.edu>
Content-Type: text/plain
Date: Fri, 04 Jul 2008 19:01:56 +0100
Message-Id: <1215194516.3189.5.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, sam@ravnborg.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-04 at 10:30 -0400, Theodore Tso wrote:
> So on this point I'd side with David, and say that folding "make
> firmware_install" into "make modules_install" goes a long way towards
> healing this particular breakage.

make modules_install | tail ...
  INSTALL fs/nfs/nfs.ko
  INSTALL fs/nls/nls_iso8859-1.ko
  INSTALL fs/vfat/vfat.ko
  MKDIR   /lib/firmware/acenic
  INSTALL /lib/firmware/acenic/tg2.bin
  MKDIR   /lib/firmware/tigon
  INSTALL /lib/firmware/tigon/tg3.bin
  INSTALL /lib/firmware/tigon/tg3_tso.bin
  INSTALL /lib/firmware/tigon/tg3_tso5.bin
  DEPMOD  2.6.26-rc8

>From 9fcda0ce34142cb8d7450dd262173a1c7c629515 Mon Sep 17 00:00:00 2001
From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 4 Jul 2008 18:53:27 +0100
Subject: [PATCH] firmware: 'make modules_install' installs firmware to match modules

(and also the static kernel, when CONFIG_FIRMWARE_IN_KERNEL=n).

This means that people no longer have to know to run 'make
firmware_install' for themselves, and firmware should get installed
automatically.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>
---
 Makefile                |    6 ++++--
 firmware/Makefile       |   39 +++++++++++++++++++++++++++++----------
 scripts/Makefile.fwinst |   21 ++++++++++++++++++---
 3 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/Makefile b/Makefile
index 947a90f..676fa96 100644
--- a/Makefile
+++ b/Makefile
@@ -996,11 +996,12 @@ depend dep:
 
 # ---------------------------------------------------------------------------
 # Firmware install
-INSTALL_FW_PATH=/lib/firmware
+INSTALL_FW_PATH=$(INSTALL_MOD_PATH)/lib/firmware
 export INSTALL_FW_PATH
 
 PHONY += firmware_install
 firmware_install: FORCE
+	@mkdir -p $(objtree)/firmware
 	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.fwinst obj=firmware __fw_install
 
 # ---------------------------------------------------------------------------
@@ -1089,6 +1090,7 @@ _modinst_:
 # boot script depmod is the master version.
 PHONY += _modinst_post
 _modinst_post: _modinst_
+	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.fwinst obj=firmware __fw_modinst
 	$(call cmd,depmod)
 
 else # CONFIG_MODULES
@@ -1207,7 +1209,7 @@ help:
 	@echo  '* modules	  - Build all modules'
 	@echo  '  modules_install - Install all modules to INSTALL_MOD_PATH (default: /)'
 	@echo  '  firmware_install- Install all firmware to INSTALL_FW_PATH'
-	@echo  '                    (default: /lib/firmware)'
+	@echo  '                    (default: $$(INSTALL_MOD_PATH)/lib/firmware)'
 	@echo  '  dir/            - Build all files in dir and below'
 	@echo  '  dir/file.[ois]  - Build specified target only'
 	@echo  '  dir/file.ko     - Build module including final link'
diff --git a/firmware/Makefile b/firmware/Makefile
index f88d746..da9c92b 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -9,10 +9,24 @@ fwabs := $(addprefix $(srctree)/,$(filter-out /%,$(fwdir)))$(filter /%,$(fwdir))
 
 fw-external-y := $(subst ",,$(CONFIG_EXTRA_FIRMWARE))
 
-ifneq ($(CONFIG_ACENIC_OMIT_TIGON_I),y)
-fw-shipped-$(CONFIG_ACENIC) += acenic/tg1.bin
+# There are three cases to care about:
+# 1. Building kernel with CONFIG_FIRMWARE_IN_KERNEL=y -- $(fw-shipped-y) should
+#    include the firmware files to include, according to .config
+# 2. 'make modules_install', which will install firmware for modules, and 
+#    _also_ for the in-kernel drivers when CONFIG_FIRMWARE_IN_KERNEL=n
+# 3. 'make firmware_install', which installs all firmware, unconditionally.
+
+# For the former two cases we want $(fw-shipped-y) and $(fw-shipped-m) to be
+# accurate. In the latter case it doesn't matter -- it'll use $(fw-shipped-all).
+# But be aware that the config file might not be included at all.
+
+ifdef CONFIG_ACENIC_OMIT_TIGON_I
+acenic-objs := acenic/tg2.bin
+fw-shipped- += acenic/tg1.bin
+else
+acenic-objs := acenic/tg1.bin acenic/tg2.bin
 endif
-fw-shipped-$(CONFIG_ACENIC) += acenic/tg2.bin
+fw-shipped-$(CONFIG_ACENIC) += $(acenic-objs)
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
 fw-shipped-$(CONFIG_COMPUTONE) += intelliport2.bin
 fw-shipped-$(CONFIG_DVB_AV7110) += av7110/bootcode.bin
@@ -35,6 +49,7 @@ fw-shipped-$(CONFIG_USB_EMI62) += emi62/loader.fw emi62/bitstream.fw \
 fw-shipped-$(CONFIG_USB_KAWETH) += kaweth/new_code.bin kaweth/trigger_code.bin \
 				   kaweth/new_code_fix.bin \
 				   kaweth/trigger_code_fix.bin
+ifdef CONFIG_FIRMWARE_IN_KERNEL
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_MPR) += keyspan/mpr.fw
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA18X) += keyspan/usa18x.fw
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA19) += keyspan/usa19.fw
@@ -47,6 +62,12 @@ fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA28XB) += keyspan/usa28xb.fw
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA28X) += keyspan/usa28x.fw
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA49W) += keyspan/usa49w.fw
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA49WLC) += keyspan/usa49wlc.fw
+else
+fw-shipped- := keyspan/mpr.fw keyspan/usa18x.fw keyspan/usa19.fw	\
+	keyspan/usa19qi.fw keyspan/usa19qw.fw keyspan/usa19w.fw		\
+	keyspan/usa28.fw keyspan/usa28xa.fw keyspan/usa28xb.fw		\
+	keyspan/usa28x.fw keyspan/usa49w.fw keyspan/usa49wlc.fw
+endif
 fw-shipped-$(CONFIG_USB_SERIAL_TI) += ti_3410.fw ti_5052.fw
 fw-shipped-$(CONFIG_USB_SERIAL_WHITEHEAT) += whiteheat_loader.fw whiteheat.fw \
 					   # whiteheat_loader_debug.fw
@@ -55,13 +76,10 @@ fw-shipped-$(CONFIG_USB_SERIAL_XIRCOM) += keyspan_pda/xircom_pgs.fw
 fw-shipped-$(CONFIG_USB_VICAM) += vicam/firmware.fw
 fw-shipped-$(CONFIG_VIDEO_CPIA2) += cpia2/stv0672_vp4.bin
 
-# If CONFIG_FIRMWARE_IN_KERNEL is not set, then don't include any firmware
-ifneq ($(CONFIG_FIRMWARE_IN_KERNEL),y)
-fw-shipped-y :=
-endif
+fw-shipped-all := $(fw-shipped-y) $(fw-shipped-m) $(fw-shipped-)
 
-firmware-y    := $(fw-external-y) $(fw-shipped-y)
-firmware-dirs := $(sort $(patsubst %,$(objtree)/$(obj)/%/,$(dir $(firmware-y) $(fw-shipped-))))
+# Directories which we _might_ need to create, so we have a rule for them.
+firmware-dirs := $(sort $(patsubst %,$(objtree)/$(obj)/%/,$(dir $(fw-external-y) $(fw-shipped-all))))
 
 quiet_cmd_mkdir = MKDIR   $(patsubst $(objtree)/%,%,$@)
       cmd_mkdir = mkdir -p $@
@@ -146,7 +164,8 @@ $(obj)/%.fw: $(obj)/%.H16 $(obj)/ihex2fw | $(objtree)/$(obj)/$$(dir %)
 $(firmware-dirs):
 	$(call cmd,mkdir)
 
-obj-y := $(patsubst %,%.gen.o, $(firmware-y))
+obj-y				 += $(patsubst %,%.gen.o, $(fw-external-y))
+obj-$(CONFIG_FIRMWARE_IN_KERNEL) += $(patsubst %,%.gen.o, $(fw-shipped-y))
 
 # Remove .S files and binaries created from ihex
 # (during 'make clean' .config isn't included so they're all in $(fw-shipped-))
diff --git a/scripts/Makefile.fwinst b/scripts/Makefile.fwinst
index 8301802..df91610 100644
--- a/scripts/Makefile.fwinst
+++ b/scripts/Makefile.fwinst
@@ -8,13 +8,25 @@
 INSTALL := install
 src := $(obj)
 
+# For modules_install installing firmware, we want to see .config
+# But for firmware_install, we don't care, but don't want to require it.
+-include $(objtree)/.config
+
 include scripts/Kbuild.include
 include $(srctree)/$(obj)/Makefile
 
 include scripts/Makefile.host
 
-installed-fw := $(addprefix $(INSTALL_FW_PATH)/,$(fw-shipped-))
-installed-fw-dirs := $(sort $(dir $(installed-fw)))
+mod-fw := $(addprefix $(INSTALL_FW_PATH)/,$(fw-shipped-m))
+
+# If CONFIG_FIRMWARE_IN_KERNEL isn't set, then install the 
+# firmware for in-kernel drivers too.
+ifndef CONFIG_FIRMWARE_IN_KERNEL
+mod-fw += $(addprefix $(INSTALL_FW_PATH)/,$(fw-shipped-y))
+endif
+
+installed-fw := $(addprefix $(INSTALL_FW_PATH)/,$(fw-shipped-all))
+installed-fw-dirs := $(sort $(dir $(installed-fw))) $(INSTALL_FW_PATH)/.
 
 quiet_cmd_install = INSTALL $(subst $(srctree)/,,$@)
       cmd_install = $(INSTALL) -m0644 $< $@
@@ -25,7 +37,10 @@ $(installed-fw-dirs):
 $(installed-fw): $(INSTALL_FW_PATH)/%: $(obj)/% | $(INSTALL_FW_PATH)/$$(dir %)/
 	$(call cmd,install)
 
-.PHONY: __fw_install FORCE
+.PHONY: __fw_install __fw_modinst FORCE
+
 __fw_install: $(installed-fw)
+__fw_modinst: $(mod-fw)
+
 
 FORCE:
-- 
1.5.5.1


-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
