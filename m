Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id ECE8E900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 05:46:22 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so2613964pdb.41
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 02:46:22 -0700 (PDT)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTP id a10si131836pat.135.2014.10.29.02.46.21
        for <linux-mm@kvack.org>;
        Wed, 29 Oct 2014 02:46:22 -0700 (PDT)
From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH] x86, pageattr: fix slow_virt_to_phys() for X86_PAE
Date: Wed, 29 Oct 2014 03:53:53 -0700
Message-Id: <1414580033-27484-1-git-send-email-decui@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, dave.hansen@intel.com, riel@redhat.com
Cc: kys@microsoft.com, haiyangz@microsoft.com

pte_pfn() returns a PFN of long (32 bits in 32-PAE), then
"long << PAGE_SHIFT" will overflow for PFNs above 4GB.

Due to this issue, some Linux 32-PAE distros, running as guests on Hyper-V,
with 5GB memory assigned, can't load the netvsc driver successfully and
hence the synthetic network device can't work (we can use the kernel parameter
mem=3000M to work around the issue).

Cc: K. Y. Srinivasan <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 arch/x86/mm/pageattr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index ae242a7..36de293 100644
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
