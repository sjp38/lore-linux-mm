Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id F09336B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:34:01 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 04:30:58 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 431752BB0054
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:33:56 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6OIICEA1835308
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:18:22 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6OIXjkZ027310
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:33:45 +1000
Message-ID: <51F01E06.6090800@linux.vnet.ibm.com>
Date: Wed, 24 Jul 2013 13:33:42 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/8] Correct memory hot add/remove for powerpc
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, isimatu.yasuaki@jp.fujitsu.com

The current implementation of memory hot add and remove for powerpc is broken.
This patch set both corrects this issue and updates the memory hot add and
remove code for powerpc so that it can be done properly in the kernel.

The first two patches update the powerpc hot add and remove code to work with
all of the updates that have gone in to enable memory remove with sparse
vmemmap enabled. With these two patches applied the powerpc code is back to
working, but not working properly.

The remaining patches update the powerpc memory add and remove code so the
work can be done in the kernel and all while holding the memory hotplug lock.
The current powerpc implementation does some of the work in the kernel and
some of the work in userspace. While this code did work at one time, it has
a problem in that it does part of the work to add and remove memory without
holding the memory hotplug lock. In this scheme memory could be added and
removed fast enough to cause the system to crash. This was a result of
doing part of the add or remove without holding the lock.

In order to do memory hot remove in the kernel, this patch set introduces
a sysfs release file (/sys/device/system/memory/release) which one
can write the physical address of the memory to be removed to. Additionally
there is a new set of flags defined for the memory notification chain to
indicate that memory is being hot added or hot removed. This allows any work
that may need to be done prior to or after memory is hot added or removed
to be performed.

The remaining patches in the patch set update the powerpc to properly do
memory hot add and remove in the kernel.

Nathan Fontenot
---
 Documentation/memory-hotplug.txt                      |   26 ++++
 arch/powerpc/mm/mem.c                                 |   35 +++++-
 arch/powerpc/platforms/pseries/hotplug-memory.c       |   95 +---------------
 drivers/base/memory.c                                 |   81 ++++++++++++--
 linux/Documentation/memory-hotplug.txt                |   34 ++++-
 linux/arch/powerpc/Kconfig                            |    2 
 linux/arch/powerpc/mm/init_64.c                       |    6 +
 linux/arch/powerpc/mm/mem.c                           |    9 +
 linux/arch/powerpc/platforms/pseries/dlpar.c          |  103 ++++++++++++++++++
 linux/arch/powerpc/platforms/pseries/hotplug-memory.c |   60 +---------
 linux/arch/x86/Kconfig                                |    2 
 linux/drivers/base/memory.c                           |   20 +--
 linux/include/linux/memory.h                          |    6 +
 linux/mm/Kconfig                                      |    2 
 linux/mm/memory_hotplug.c                             |   25 +++-
 15 files changed, 322 insertions(+), 184 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
