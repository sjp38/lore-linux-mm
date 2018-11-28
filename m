Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE886B4CB7
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:33:06 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so9768157pfi.21
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 03:33:06 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id x10si6789973pgl.209.2018.11.28.03.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 03:33:05 -0800 (PST)
From: Alex Shi <alex.shi@linux.alibaba.com>
Subject: [PATCH 008/216] x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE
Date: Wed, 28 Nov 2018 19:29:20 +0800
Message-Id: <1543404768-89470-8-git-send-email-alex.shi@linux.alibaba.com>
In-Reply-To: <1543404768-89470-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1543404768-89470-1-git-send-email-alex.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, Michael Wang <yun.wang@linux.alibaba.com>, Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Dexuan Cui <decui@microsoft.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, gregkh@linuxfoundation.org, linux-mm@kvack.org, olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, dave.hansen@intel.com, riel@redhat.com, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Alex Shi <alex.shi@linux.alibaba.com>

From: Dexuan Cui <decui@microsoft.com>

commit d1cd1210834649ce1ca6bafe5ac25d2f40331343 upstream.

pte_pfn() returns a PFN of long (32 bits in 32-PAE), so "long <<
PAGE_SHIFT" will overflow for PFNs above 4GB.

Due to this issue, some Linux 32-PAE distros, running as guests on Hyper-V,
with 5GB memory assigned, can't load the netvsc driver successfully and
hence the synthetic network device can't work (we can use the kernel parameter
mem=3000M to work around the issue).

Cast pte_pfn() to phys_addr_t before shifting.

Fixes: "commit d76565344512: x86, mm: Create slow_virt_to_phys()"
Signed-off-by: Dexuan Cui <decui@microsoft.com>
Cc: K. Y. Srinivasan <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org
Cc: olaf@aepfle.de
Cc: apw@canonical.com
Cc: jasowang@redhat.com
Cc: dave.hansen@intel.com
Cc: riel@redhat.com
Cc: stable@vger.kernel.org
Link: http://lkml.kernel.org/r/1414580017-27444-1-git-send-email-decui@microsoft.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
---
 7u/arch/x86/mm/pageattr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/7u/arch/x86/mm/pageattr.c b/7u/arch/x86/mm/pageattr.c
index 4ed2b2d..81b82f4 100644
--- a/7u/arch/x86/mm/pageattr.c
+++ b/7u/arch/x86/mm/pageattr.c
@@ -405,7 +405,7 @@ phys_addr_t slow_virt_to_phys(void *__virt_addr)
 	psize = page_level_size(level);
 	pmask = page_level_mask(level);
 	offset = virt_addr & ~pmask;
-	phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
+	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
 	return (phys_addr | offset);
 }
 EXPORT_SYMBOL_GPL(slow_virt_to_phys);
-- 
1.8.3.1
