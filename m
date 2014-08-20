Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 973066B003A
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:26:03 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so7355974qgf.7
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:26:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si34387352qae.48.2014.08.20.08.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 08:25:53 -0700 (PDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH 0/2] x86: allow read/write /dev/mem to access non-system RAM above high_memory
Date: Wed, 20 Aug 2014 17:25:24 +0200
Message-Id: <1408548326-18665-1-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1408103043-31015-1-git-send-email-fhrbata@redhat.com>
References: <1408103043-31015-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com

Hi,

this patch set depends on the following patches posted earlier.

[PATCH V2 1/2] x86: add arch_pfn_possible helper
   lkml: Message-Id: <1408103043-31015-2-git-send-email-fhrbata@redhat.com>
[PATCH V2 2/2] x86: add phys addr validity check for /dev/mem mmap
   lkml: Message-Id: <1408103043-31015-3-git-send-email-fhrbata@redhat.com>

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
allowing read/write to access non-system RAM above high_memory. So far this was
possible only by using mmap.

I hope I haven't overlooked something.

Many thanks

Frantisek Hrbata (2):
  x86: add high_memory check to (xlate|unxlate)_dev_mem_ptr
  x86: remove high_memory check from valid_phys_addr_range

 arch/x86/mm/ioremap.c | 9 ++++++---
 arch/x86/mm/mmap.c    | 2 +-
 2 files changed, 7 insertions(+), 4 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
