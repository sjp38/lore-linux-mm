Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 3CF8D6B005A
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:34:39 -0500 (EST)
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
Subject: [RFCv1 0/6] PASR: Partial Array Self-Refresh Framework
Date: Mon, 30 Jan 2012 14:33:50 +0100
Message-ID: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Mel Gorman <mel@csn.ul.ie>, Ankita Garg <ankita@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, Maxime Coquelin <maxime.coquelin@stericsson.com>, linus.walleij@stericsson.com, andrea.gallo@stericsson.com, vincent.guittot@stericsson.com, philippe.langlais@stericsson.com, loic.pallardy@stericsson.com

PASR Frameworks brings support for the Partial Array Self-Refresh DDR power
management feature. PASR has been introduced in LP-DDR2, and is also present
in DDR3.

PASR provides 4 modes:

* Single-Ended: Only 1/1, 1/2, 1/4 or 1/8 are refreshed, masking starting at
  the end of the DDR die.

* Double-Ended: Same as Single-Ended, but refresh-masking does not start
  necessairly at the end of the DDR die.

* Bank-Selective: Refresh of each bank of a die can be masked or unmasked via
  a dedicated DDR register (MR16). This mode is convenient for DDR configured
  in BRC (Bank-Row-Column) mode.

* Segment-Selective: Refresh of each segment of a die can be masked or unmasked
  via a dedicated DDR register (MR17). This mode is convenient for DDR configured
  in RBC (Row-Bank-Column) mode.

The role of this framework is to stop the refresh of unused memory to enhance
DDR power consumption.

It supports Bank-Selective and Segment-Selective modes, as the more adapted to
modern OSes.

At early boot stage, a representation of the physical DDR layout is built:

             Die 0
_______________________________
| I--------------------------I |
| I    Bank or Segment 0     I |
| I--------------------------I |
| I--------------------------I |
| I    Bank or Segment 1     I |
| I--------------------------I |
| I--------------------------I |
| I    Bank or Segment ...   I |
| I--------------------------I |
| I--------------------------I |
| I    Bank or Segment n     I |
| I--------------------------I |
|______________________________|
             ...

             Die n
_______________________________
| I--------------------------I |
| I    Bank or Segment 0     I |
| I--------------------------I |
| I--------------------------I |
| I    Bank or Segment 1     I |
| I--------------------------I |
| I--------------------------I |
| I    Bank or Segment ...   I |
| I--------------------------I |
| I--------------------------I |
| I    Bank or Segment n     I |
| I--------------------------I |
|______________________________|

The first level is a table where elements represent a die:
* Base address,
* Number of segments,
* Table representing banks/segments,
* MR16/MR17 refresh mask,
* DDR Controller callback to update MR16/MR17 refresh mask.

The second level is the section tables representing the banks or segments,
depending on hardware configuration:
* Base address,
* Unused memory size counter,
* Possible pointer to another section it depends on (E.g. Interleaving)

When some memory becomes unused, the allocator owning this memory calls the PASR
Framework's pasr_put(phys_addr, size) function. The framework finds the
sections impacted and updates their counters accordingly.
If a section counter reach the section size, the refresh of the section is
masked. If the corresponding section has a dependency with another section
(E.g. because of DDR interleaving, see figure below), it checks the "paired" section
is also unused before updating the refresh mask.

When some unused memory is requested by the allocator, the allocator owning
this memory calls the PASR Framework's pasr_get(phys_addr, size) function. The
framework find the section impacted and updates their counters accordingly.
If before the update, the section counter was to the section size, the refrewh
of the section is unmasked. If the corresponding section has a dependency with
another section, it also unmask the refresh of the other section.

Patch 3/6 contains modifications for the Buddy allocator. Overhead induced is
very low because the PASR framework is notified only on "MAX_ORDER" pageblocs.
Any allocator support(PMEM, HWMEM...) and Memory Hotplug would be added in next
patch set revisions.

Maxime Coquelin (6):
  PASR: Initialize DDR layout
  PASR: Add core Framework
  PASR: mm: Integrate PASR in Buddy allocator
  PASR: Call PASR initialization
  PASR: Add Documentation
  PASR: Ux500: Add PASR support

 Documentation/pasr.txt                      |  183 ++++++++++++
 arch/arm/Kconfig                            |    1 +
 arch/arm/kernel/setup.c                     |    1 +
 arch/arm/mach-ux500/include/mach/hardware.h |   11 +
 arch/arm/mach-ux500/include/mach/memory.h   |    8 +
 drivers/mfd/db8500-prcmu.c                  |   67 +++++
 drivers/staging/Kconfig                     |    2 +
 drivers/staging/Makefile                    |    1 +
 drivers/staging/pasr/Kconfig                |   19 ++
 drivers/staging/pasr/Makefile               |    6 +
 drivers/staging/pasr/core.c                 |  168 +++++++++++
 drivers/staging/pasr/helper.c               |   84 ++++++
 drivers/staging/pasr/helper.h               |   16 +
 drivers/staging/pasr/init.c                 |  403 +++++++++++++++++++++++++++
 drivers/staging/pasr/ux500.c                |   58 ++++
 include/linux/pasr.h                        |  143 ++++++++++
 include/linux/ux500-pasr.h                  |   11 +
 init/main.c                                 |    8 +
 mm/page_alloc.c                             |    9 +
 19 files changed, 1199 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/pasr.txt
 create mode 100644 drivers/staging/pasr/Kconfig
 create mode 100644 drivers/staging/pasr/Makefile
 create mode 100644 drivers/staging/pasr/core.c
 create mode 100644 drivers/staging/pasr/helper.c
 create mode 100644 drivers/staging/pasr/helper.h
 create mode 100644 drivers/staging/pasr/init.c
 create mode 100644 drivers/staging/pasr/ux500.c
 create mode 100644 include/linux/pasr.h
 create mode 100644 include/linux/ux500-pasr.h

-- 
1.7.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
