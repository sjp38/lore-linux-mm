Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 431B1280029
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:11:24 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id d1so1244101wiv.13
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 03:11:23 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id ex8si17155272wjb.33.2014.11.11.03.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 03:11:23 -0800 (PST)
From: Luis Henriques <luis.henriques@canonical.com>
Subject: [PATCH 3.16.y-ckt 149/170] x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE
Date: Tue, 11 Nov 2014 11:08:28 +0000
Message-Id: <1415704129-12709-150-git-send-email-luis.henriques@canonical.com>
In-Reply-To: <1415704129-12709-1-git-send-email-luis.henriques@canonical.com>
References: <1415704129-12709-1-git-send-email-luis.henriques@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org, kernel-team@lists.ubuntu.com
Cc: Dexuan Cui <decui@microsoft.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, gregkh@linuxfoundation.org, linux-mm@kvack.org, olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, dave.hansen@intel.com, riel@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Luis Henriques <luis.henriques@canonical.com>

3.16.7-ckt1 -stable review patch.  If anyone has any objections, please let me know.

------------------

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
Link: http://lkml.kernel.org/r/1414580017-27444-1-git-send-email-decui@microsoft.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 arch/x86/mm/pageattr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index ae242a7c11c7..36de293caf25 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -409,7 +409,7 @@ phys_addr_t slow_virt_to_phys(void *__virt_addr)
 	psize = page_level_size(level);
 	pmask = page_level_mask(level);
 	offset = virt_addr & ~pmask;
-	phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
+	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
 	return (phys_addr | offset);
 }
 EXPORT_SYMBOL_GPL(slow_virt_to_phys);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
