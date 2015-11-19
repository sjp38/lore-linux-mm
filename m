Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1731C6B025A
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:34:09 -0500 (EST)
Received: by wmww144 with SMTP id w144so136358640wmw.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:08 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 138si51015168wmi.22.2015.11.19.14.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 14:34:04 -0800 (PST)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJMWM5a029263
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt77yu-8
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:02 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 9d22326c8f0d11e58c3b0002c95209d8-2a7fd230 for <linux-mm@kvack.org>;	Thu, 19
 Nov 2015 14:33:54 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 0/8] userfaultfd: add write protect support
Date: Thu, 19 Nov 2015 14:33:45 -0800
Message-ID: <cover.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>

Hi,

There is plan to support write protect fault into userfaultfd before, but it's
not implemented yet. I'm working on a library to support different types of
buffer like compressed buffer and file buffer, something like a page cache
implementation in userspace. The buffer enables userfaultfd and does something
like decompression in userfault handler. When memory size exceeds a
threshold, madvise is used to reclaim memory. The problem is data can be
corrupted in reclaim without memory protection support.

For example, in the compressed buffer case, reclaim does:
1. compress memory range and store compressed data elsewhere
2. madvise the memory range

But if the memory is changed before 2, new change is lost. memory write
protection can solve the issue. With it, the reclaim does:
1. write protect memory range
2. compress memory range and store compressed data elsewhere
3. madvise the memory range
4. undo write protect memory range and wakeup tasks waiting in write protect
fault.
If a task changes memory before 3, write protect fault will be triggered. we
can put the task into sleep till step 4 runs for example. In this way memory
changes will not be lost.

This patch set add write protect support for userfaultfd. One issue is write
protect fault can happen even without enabling write protect in userfault. For
example, a write to address backed by zero page. There is no way to distinguish
if this is a write protect fault expected by userfault. This patch just blindly
triggers write protect fault to userfault if corresponding vma enables
VM_UFFD_WP. Application should be prepared to handle such write protect fault.

Thanks,
Shaohua


Shaohua Li (8):
  userfaultfd: add helper for writeprotect check
  userfaultfd: support write protection for userfault vma range
  userfaultfd: expose writeprotect API to ioctl
  userfaultfd: allow userfaultfd register success with writeprotection
  userfaultfd: undo write proctection in unregister
  userfaultfd: hook userfault handler to write protection fault
  userfaultfd: fault try one more time
  userfaultfd: enabled write protection in userfaultfd API

 arch/alpha/mm/fault.c            |  8 ++++-
 arch/arc/mm/fault.c              |  8 ++++-
 arch/arm/mm/fault.c              |  8 ++++-
 arch/arm64/mm/fault.c            |  8 ++++-
 arch/avr32/mm/fault.c            |  8 ++++-
 arch/cris/mm/fault.c             |  8 ++++-
 arch/hexagon/mm/vm_fault.c       |  8 ++++-
 arch/ia64/mm/fault.c             |  8 ++++-
 arch/m68k/mm/fault.c             |  8 ++++-
 arch/metag/mm/fault.c            |  8 ++++-
 arch/microblaze/mm/fault.c       |  8 ++++-
 arch/mips/mm/fault.c             |  8 ++++-
 arch/mn10300/mm/fault.c          |  8 ++++-
 arch/nios2/mm/fault.c            |  8 ++++-
 arch/openrisc/mm/fault.c         |  8 ++++-
 arch/parisc/mm/fault.c           |  8 ++++-
 arch/powerpc/mm/fault.c          |  8 ++++-
 arch/s390/mm/fault.c             |  9 +++++-
 arch/sh/mm/fault.c               |  8 ++++-
 arch/sparc/mm/fault_32.c         |  8 ++++-
 arch/sparc/mm/fault_64.c         |  8 ++++-
 arch/tile/mm/fault.c             |  8 ++++-
 arch/um/kernel/trap.c            |  8 ++++-
 arch/unicore32/mm/fault.c        |  8 ++++-
 arch/x86/mm/fault.c              |  9 +++++-
 arch/xtensa/mm/fault.c           |  8 ++++-
 fs/userfaultfd.c                 | 66 ++++++++++++++++++++++++++++++++++------
 include/linux/mm.h               |  3 +-
 include/linux/userfaultfd_k.h    | 12 ++++++++
 include/uapi/linux/userfaultfd.h | 17 +++++++++--
 mm/memory.c                      | 66 +++++++++++++++++++++++++++++-----------
 mm/userfaultfd.c                 | 52 +++++++++++++++++++++++++++++++
 32 files changed, 369 insertions(+), 57 deletions(-)

-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
