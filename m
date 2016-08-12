Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D78766B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 10:19:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so50743381pfg.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:19:49 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id sl8si9131888pab.264.2016.08.12.07.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 07:19:48 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id pp5so9100928pac.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:19:48 -0700 (PDT)
From: Ronit Halder <ronit.crj@gmail.com>
Subject: [RFC 0/4] Kexec: Enable run time memory resrvation of crash kernel
Date: Fri, 12 Aug 2016 19:48:38 +0530
Message-Id: <20160812141838.5973-1-ronit.crj@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, dyoung@redhat.com, jroedel@suse.de, krzysiek@podlesie.net, msalter@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, bhe@redhat.com, vgoyal@redhat.com, mnfhuang@gmail.com, kexec@lists.infradead.org, kirill.shutemov@linux.intel.com, mchehab@osg.samsung.com, aarcange@redhat.com, vdavydov@parallels.com, dan.j.williams@intel.com, jack@suse.cz, linux-mm@kvack.org, Ronit Halder <ronit.crj@gmail.com>

Currenty linux kernel reserves memory at the boot time for crash kernel.
It will be very useful if we can reserve memory in run time. The user can 
reserve the memory whenerver needed instead of reserving at the boot time.

It is possible to reserve memory for crash kernel at the run time using
CMA (Contiguous Memory Allocator). CMA is capable of allocating big chunk 
of memory. At the boot time we will create one (if only low memory is used)
or two (if we use both high memory in case of x86_64) CMA areas of size 
given in "crashkernel" boot time command line parameter. This memory in CMA
areas can be used as movable pages (used for disk caches, process pages
etc) if not allocated. Then the user can reserve or free memory from those
CMA areas using "/sys/kernel/kexec_crash_size" sysfs entry. If the user
uses high memory it will automatically at least 256MB low memory
(needed for swiotlb and DMA buffers) when the user allocates memory using
mentioned sysfs enrty. In case of high memory reservation the user controls
the size of reserved region in high memory with
"/sys/kernel/kexec_crash_size" entry. If the size set is zero then the 
memory allocated in low memory will automatically be freed.

As the pages under CMA area (when not allocated by CMA) can only be used by
movable pages. The pages won't be used for DMA. So, after allocating pages
from CMA area for loading the crash kernel, there won't be any chance of
DMA on the memory.

Thus is a prototype patch. Please share your opinions on my approach. This
patch is only for x86 and x86_64. Please note, this patch is only a
prototype just to explain my approach and get the review. This patch is on
kernel version v4.4.11.

CMA depends on page migration and only uses movable pages. But, the movable
pages become unmovable momentarily for pinning. The CMA fails for this
reason. I don't have any solution for that right now. This approach will
work when the this problems with CMA will be fixed. The patch is enabled
by a kernel configuration option CONFIG_KEXEC_CMA.

Ronit Halder (4):
  Creating one or two CMA area at Boot time
  Functions for memory reservation and release
  Adding a new kernel configuration to enable the feature
  Enable memory allocation through sysfs interface

 arch/x86/kernel/setup.c | 44 ++++++++++++++++++++++++--
 include/linux/kexec.h   | 11 ++++++-
 kernel/kexec_core.c     | 83 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/ksysfs.c         | 23 +++++++++++++-
 mm/Kconfig              |  6 ++++
 5 files changed, 162 insertions(+), 5 deletions(-)

-- 
2.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
