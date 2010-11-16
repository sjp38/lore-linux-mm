Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D4F438D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 08:08:24 -0500 (EST)
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id DE990C4
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:02 +0000 (GMT)
Received: from relay1.stm.gmessaging.net (unknown [10.230.100.17])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 9A31E78E
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:02 +0000 (GMT)
Received: from exdcvycastm004.EQ1STM.local (alteon-source-exch [10.230.100.61])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(Client CN "exdcvycastm004", Issuer "exdcvycastm004" (not verified))
	by relay1.stm.gmessaging.net (Postfix) with ESMTPS id 59A9824C2AB
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 14:07:55 +0100 (CET)
From: Johan Mossberg <johan.xx.mossberg@stericsson.com>
Subject: [PATCH 0/3] hwmem: Hardware memory driver
Date: Tue, 16 Nov 2010 14:07:59 +0100
Message-ID: <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Johan Mossberg <johan.xx.mossberg@stericsson.com>
List-ID: <linux-mm.kvack.org>

Hello everyone, 

The following patchset implements a "hardware memory driver". The
main purpose of hwmem is:

* To allocate buffers suitable for use with hardware. Currently
this means contiguous buffers.
* To synchronize the caches for the allocated buffers. This is
achieved by keeping track of when the CPU uses a buffer and when
other hardware uses the buffer, when we switch from CPU to other
hardware or vice versa the caches are synchronized.
* To handle sharing of allocated buffers between processes i.e.
import, export.

Hwmem is available both through a user space API and through a
kernel API.

Here at ST-Ericsson we use hwmem for graphics buffers. Graphics
buffers need to be contiguous due to our hardware, are passed
between processes (usually application and window manager)and are
part of usecases where performance is top priority so we can't
afford to synchronize the caches unecessarily.

Hwmem and CMA (Contiguous Memory Allocator) overlap to some extent.
Hwmem could use CMA as its allocator and thereby remove the overlap
but then defragmentation can not be implemented as CMA currently
has no support for this. We would very much like to see a
discussion about adding defragmentation to CMA.

Best regards
Johan Mossberg
Consultant at ST-Ericsson

Johan Mossberg (3):
  hwmem: Add hwmem (part 1)
  hwmem: Add hwmem (part 2)
  hwmem: Add hwmem to ux500 and mop500

 arch/arm/mach-ux500/board-mop500.c         |    1 +
 arch/arm/mach-ux500/devices.c              |   31 ++
 arch/arm/mach-ux500/include/mach/devices.h |    1 +
 drivers/misc/Kconfig                       |    7 +
 drivers/misc/Makefile                      |    1 +
 drivers/misc/hwmem/Makefile                |    3 +
 drivers/misc/hwmem/cache_handler.c         |  494 ++++++++++++++++++++++
 drivers/misc/hwmem/cache_handler.h         |   60 +++
 drivers/misc/hwmem/cache_handler_u8500.c   |  208 ++++++++++
 drivers/misc/hwmem/hwmem-ioctl.c           |  470 +++++++++++++++++++++
 drivers/misc/hwmem/hwmem-main.c            |  609 ++++++++++++++++++++++++++++
 include/linux/hwmem.h                      |  499 +++++++++++++++++++++++
 12 files changed, 2384 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/hwmem/Makefile
 create mode 100644 drivers/misc/hwmem/cache_handler.c
 create mode 100644 drivers/misc/hwmem/cache_handler.h
 create mode 100644 drivers/misc/hwmem/cache_handler_u8500.c
 create mode 100644 drivers/misc/hwmem/hwmem-ioctl.c
 create mode 100644 drivers/misc/hwmem/hwmem-main.c
 create mode 100644 include/linux/hwmem.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
