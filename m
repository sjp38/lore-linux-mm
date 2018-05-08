Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25FF86B0292
	for <linux-mm@kvack.org>; Tue,  8 May 2018 11:00:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z1so8773402pfh.3
        for <linux-mm@kvack.org>; Tue, 08 May 2018 08:00:01 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z14-v6si1296789pgv.514.2018.05.08.07.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 08:00:00 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 3/8] mm/pkeys: Remove include of asm/mmu_context.h from pkeys.h
Date: Wed,  9 May 2018 00:59:43 +1000
Message-Id: <20180508145948.9492-4-mpe@ellerman.id.au>
In-Reply-To: <20180508145948.9492-1-mpe@ellerman.id.au>
References: <20180508145948.9492-1-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

While trying to unify the pkey handling in show_smap() between x86 and
powerpc we stumbled across various build failures due to the order of
includes between the two arches.

Part of the problem is that linux/pkeys.h includes asm/mmu_context.h,
and the relationship between asm/mmu_context.h and asm/pkeys.h is not
consistent between the two arches.

It would be cleaner if linux/pkeys.h only included asm/pkeys.h,
creating a single integration point for the arch pkey definitions.

So this patch removes the include of asm/mmu_context.h from
linux/pkeys.h.

We can't prove that this is safe in the general case, but it passes
all the build tests I've thrown at it. Also asm/mmu_context.h is
included widely while linux/pkeys.h is not, so most likely any code
that is including linux/pkeys.h is already getting asm/mmu_context.h
from elsewhere.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 include/linux/pkeys.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index 0794ca78c379..ed06e1a67bfa 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -3,7 +3,6 @@
 #define _LINUX_PKEYS_H
 
 #include <linux/mm_types.h>
-#include <asm/mmu_context.h>
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
 #include <asm/pkeys.h>
-- 
2.14.1
