Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 038766B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:33:28 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id r5so7313082qcx.18
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 04:33:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 4si13238123qan.54.2014.09.29.04.33.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Sep 2014 04:33:28 -0700 (PDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [RESEND PATCH 0/4] x86: /dev/mem fixes
Date: Mon, 29 Sep 2014 13:32:58 +0200
Message-Id: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

Hi all,

this is a combination of two patch sets I sent a while ago
1) Prevent possible PTE corruption with /dev/mem mmap
2) x86: allow read/write /dev/mem to access non-system RAM above high_memory

The original thread with both patch sets can be found here
   https://lkml.org/lkml/2014/8/14/229
   lkml: <1408025927-16826-1-git-send-email-fhrbata@redhat.com>

1) Prevent possible PTE corruption with /dev/mem mmap
x86: add arch_pfn_possible helper
x86: add phys addr validity check for /dev/mem mmap

Many thanks goes to Dave Hansen, who helped with the "final" check. Other than
that it did not get much attention, except H. Peter Anvin's complain that having
two checks for mmap and read/write for /dev/mem access is ridiculous. I for sure
do not object to this, but AFAICT it's not that simple to unify them and it's not
"directly" related to the PTE corruption. Please note that there are other
archs(ia64, arm) using these check. But I for sure can be missing something.

What this patch set does is using the existing interface to implement x86 specific
check in the least invasive way.

Anyway I tried to remove the high_memory check with a follow-up patch set 2)

2) x86: allow read/write /dev/mem to access non-system RAM above high_memory
x86: add high_memory check to (xlate|unxlate)_dev_mem_ptr
x86: remove high_memory check from valid_phys_addr_range

This is an attempt to remove the high_memory limit for the read/write access to
/dev/mem. IMHO there is no reason for this limit on x86. It is presented in
the generic valid_phys_addr_range, which is used only by (read|write)_mem. IIUIC
it's main purpose is for the generic xlate_dev_mem_ptr, which is using only the
direct kernel mapping __va translation. Since the valid_phys_addr_range is
called as the first check in (read|write)_mem, it basically does not allow to
access anything above high_memory on x86.

The first patch adds high_memory check to x86's (xlate|unxlate)_dev_mem_ptr, so
the direct kernel mapping can be safely used for system RAM bellow high_memory.
This is IMHO the only valid reason to use high_memory check in (read|write)_mem.

The second patch removes the high_memory check from valid_phys_addr_range,
allowing read/write to access non-system RAM above high_memory. So far this
was possible only by using mmap.

I hope I haven't overlooked something.

Many thanks

Frantisek Hrbata (4):
  x86: add arch_pfn_possible helper
  x86: add phys addr validity check for /dev/mem mmap
  x86: add high_memory check to (xlate|unxlate)_dev_mem_ptr
  x86: remove high_memory check from valid_phys_addr_range

 arch/x86/include/asm/io.h |  4 ++++
 arch/x86/mm/ioremap.c     |  9 ++++++---
 arch/x86/mm/mmap.c        | 12 ++++++++++++
 arch/x86/mm/physaddr.h    |  9 +++++++--
 4 files changed, 29 insertions(+), 5 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
