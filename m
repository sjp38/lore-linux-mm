Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id D2C576B005C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:34:41 -0500 (EST)
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
Subject: [RFCv1 5/6] PASR: Add Documentation
Date: Mon, 30 Jan 2012 14:33:55 +0100
Message-ID: <1327930436-10263-6-git-send-email-maxime.coquelin@stericsson.com>
In-Reply-To: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Mel Gorman <mel@csn.ul.ie>, Ankita Garg <ankita@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, Maxime Coquelin <maxime.coquelin@stericsson.com>, linus.walleij@stericsson.com, andrea.gallo@stericsson.com, vincent.guittot@stericsson.com, philippe.langlais@stericsson.com, loic.pallardy@stericsson.com

Signed-off-by: Maxime Coquelin <maxime.coquelin@stericsson.com>
---
 Documentation/pasr.txt |  183 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 183 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/pasr.txt

diff --git a/Documentation/pasr.txt b/Documentation/pasr.txt
new file mode 100644
index 0000000..d40e3f6
--- /dev/null
+++ b/Documentation/pasr.txt
@@ -0,0 +1,183 @@
+Partial Array Self-Refresh Framework
+
+(C) 2012 Maxime Coquelin <maxime.coquelin@stericsson.com>, ST-Ericsson.
+
+CONTENT
+1. Introduction
+2. Command-line parameters
+3. Allocators patching
+4. PASR platform drivers
+
+
+1. Introduction
+
+PASR Frameworks brings support for the Partial Array Self-Refresh DDR power
+management feature. PASR has been introduced in LP-DDR2, and is also present
+in DDR3.
+
+PASR provides 4 modes:
+
+* Single-Ended: Only 1/1, 1/2, 1/4 or 1/8 are refreshed, masking starting at
+  the end of the DDR die.
+
+* Double-Ended: Same as Single-Ended, but refresh-masking does not start
+  necessairly at the end of the DDR die.
+
+* Bank-Selective: Refresh of each bank of a die can be masked or unmasked via
+  a dedicated DDR register (MR16). This mode is convenient for DDR configured
+  in BRC (Bank-Row-Column) mode.
+
+* Segment-Selective: Refresh of each segment of a die can be masked or unmasked
+  via a dedicated DDR register (MR17). This mode is convenient for DDR configured
+  in RBC (Row-Bank-Column) mode.
+
+The role of this framework is to stop the refresh of unused memory to enhance
+DDR power consumption.
+
+It supports Bank-Selective and Segment-Selective modes, as the more adapted to
+modern OSes.
+
+At early boot stage, a representation of the physical DDR layout is built:
+
+             Die 0
+_______________________________
+| I--------------------------I |
+| I    Bank or Segment 0     I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment 1     I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment ...   I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment n     I |
+| I--------------------------I |
+|______________________________|
+             ...
+
+             Die n
+_______________________________
+| I--------------------------I |
+| I    Bank or Segment 0     I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment 1     I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment ...   I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment n     I |
+| I--------------------------I |
+|______________________________|
+
+The first level is a table where elements represent a die:
+* Base address,
+* Number of segments,
+* Table representing banks/segments,
+* MR16/MR17 refresh mask,
+* DDR Controller callback to update MR16/MR17 refresh mask.
+
+The second level is the section tables representing the banks or segments,
+depending on hardware configuration:
+* Base address,
+* Unused memory size counter,
+* Possible pointer to another section it depends on (E.g. Interleaving)
+
+When some memory becomes unused, the allocator owning this memory calls the PASR
+Framework's pasr_put(phys_addr, size) function. The framework finds the
+sections impacted and updates their counters accordingly.
+If a section counter reach the section size, the refresh of the section is
+masked. If the corresponding section has a dependency with another section
+(E.g. because of DDR interleaving, see figure below), it checks the "paired" section is also
+unused before updating the refresh mask.
+
+When some unused memory is requested by the allocator, the allocator owning
+this memory calls the PASR Framework's pasr_get(phys_addr, size) function. The
+framework find the section impacted and updates their counters accordingly.
+If before the update, the section counter was to the section size, the refrewh
+of the section is unmasked. If the corresponding section has a dependency with
+another section, it also unmask the refresh of the other section.
+
+Interleaving example:
+
+             Die 0
+_______________________________
+| I--------------------------I |
+| I    Bank or Segment 0     I |<----|
+| I--------------------------I |     |
+| I--------------------------I |     |
+| I    Bank or Segment 1     I |     |
+| I--------------------------I |     |
+| I--------------------------I |     |
+| I    Bank or Segment ...   I |     |
+| I--------------------------I |     |
+| I--------------------------I |     |
+| I    Bank or Segment n     I |     |
+| I--------------------------I |     |
+|______________________________|     |
+                                     |
+             Die 1                   |
+_______________________________      |
+| I--------------------------I |     |
+| I    Bank or Segment 0     I |<----|
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment 1     I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment ...   I |
+| I--------------------------I |
+| I--------------------------I |
+| I    Bank or Segment n     I |
+| I--------------------------I |
+|______________________________|
+
+In the above example, bank 0 of die 0 is interleaved with bank0 of die 0.
+The interleaving is done in HW by inverting some addresses lines. The goal is
+to improve DDR bandwidth.
+Practically, one buffer seen as contiguous by the kernel might be spread
+into two DDR dies physically.
+
+
+2. Command-line parameters
+
+To buid the DDR physical layout representation, two parameters are requested:
+
+* ddr_die (mandatory): Should be added for every DDR dies present in the system.
+   - Usage: ddr_die=xxx[M|G]@yyy[M|G] where xxx represents the size and yyy
+     the base address of the die. E.g.: ddr_die=512M@0 ddr_die=512M@512M
+
+* interleaved (optionnal): Should be added for every interleaved dependencies.
+   - Usage: interleaved=xxx[M|G]@yyy[M|G]:zzz[M|G] where xxx is the size of
+     the interleaved area between the adresses yyy and zzz. E.g
+     interleaved=256M@0:512M
+
+
+3. Allocator patching
+
+Any allocators might call the PASR Framework for DDR power savings. Currently,
+only Linux Buddy allocator is patched, but HWMEM and PMEM physically
+contiguous memory allocators will follow.
+
+Linux Buddy allocator porting uses Buddy specificities to reduce the overhead
+induced by the PASR Framework counter updates. Indeed, the PASR Framework is
+called only when MAX_ORDER (4MB page blocs by default) buddies are
+inserted/removed from the free lists.
+
+To port PASR FW into a new allocator:
+
+* Call pasr_put(phys_addr, size) each time a memory chunk becomes unused.
+* Call pasr_get(phys_addr, size) each time a memory chunk becomes used.
+
+4. PASR platform drivers
+
+The MR16/MR17 PASR mask registers are generally accessible through the DDR
+controller. At probe time, the DDR controller driver should register the
+callback used by PASR Framework to apply the refresh mask for every DDR die
+using pasr_register_mask_function(die_addr, callback, cookie).
+
+The callback passed to apply mask must not sleep since it can me called in
+interrupt contexts.
+
-- 
1.7.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
