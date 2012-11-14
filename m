Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E46F16B004D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 11:58:27 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so544185pbc.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 08:58:27 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 0/3] introduce static_vm for ARM-specific static mapped area
Date: Thu, 15 Nov 2012 01:55:51 +0900
Message-Id: <1352912154-16210-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

In current implementation, we used ARM-specific flag, that is,
VM_ARM_STATIC_MAPPING, for distinguishing ARM specific static mapped area.
The purpose of static mapped area is to re-use static mapped area when
entire physical address range of the ioremap request can be covered
by this area.

This implementation causes needless overhead for some cases.
We unnecessarily iterate vmlist for finding matched area even if there
is no static mapped area. And if there are some static mapped areas,
iterating whole vmlist is not preferable.
In fact, it is not a critical problem, because ioremap is not frequently
used. But reducing overhead is better idea.

Another reason for doing this work is for removing architecture dependency
on vmalloc layer. I think that vmlist and vmlist_lock is internal data
structure for vmalloc layer. Some codes for debugging and stat inevitably
use vmlist and vmlist_lock. But it is preferable that they are used outside
of vmalloc.c as least as possible.

In the near future, I will try to remove other architecture dependency on
vmalloc layer.

This is just RFC patch and I did compile-test only.
If you have any good suggestion, please let me know.

These are based on v3.7-rc5.

Thanks.

Joonsoo Kim (3):
  ARM: vmregion: remove vmregion code entirely
  ARM: static_vm: introduce an infrastructure for static mapped area
  ARM: mm: use static_vm for managing static mapped areas

 arch/arm/include/asm/mach/static_vm.h |   51 ++++++++
 arch/arm/mm/Makefile                  |    2 +-
 arch/arm/mm/ioremap.c                 |   69 ++++-------
 arch/arm/mm/mm.h                      |   10 --
 arch/arm/mm/mmu.c                     |   55 +++++----
 arch/arm/mm/static_vm.c               |   97 ++++++++++++++++
 arch/arm/mm/vmregion.c                |  205 ---------------------------------
 arch/arm/mm/vmregion.h                |   31 -----
 8 files changed, 208 insertions(+), 312 deletions(-)
 create mode 100644 arch/arm/include/asm/mach/static_vm.h
 create mode 100644 arch/arm/mm/static_vm.c
 delete mode 100644 arch/arm/mm/vmregion.c
 delete mode 100644 arch/arm/mm/vmregion.h

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
