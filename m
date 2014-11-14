Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2560B6B00CD
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 07:26:29 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so19106072wgh.25
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 04:26:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex3si49021965wjd.56.2014.11.14.04.26.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 04:26:28 -0800 (PST)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [patch added to the 3.12 stable tree] x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE
Date: Fri, 14 Nov 2014 13:25:49 +0100
Message-Id: <1415967978-8989-51-git-send-email-jslaby@suse.cz>
In-Reply-To: <1415967978-8989-1-git-send-email-jslaby@suse.cz>
References: <1415967978-8989-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org
Cc: Dexuan Cui <decui@microsoft.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, gregkh@linuxfoundation.org, linux-mm@kvack.org, olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, dave.hansen@intel.com, riel@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Jiri Slaby <jslaby@suse.cz>

From: Dexuan Cui <decui@microsoft.com>

This patch has been added to the 3.12 stable tree. If you have any
objections, please let us know.

===============

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
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 arch/x86/mm/pageattr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index bb32480c2d71..aabdf762f592 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -389,7 +389,7 @@ phys_addr_t slow_virt_to_phys(void *__virt_addr)
 	psize = page_level_size(level);
 	pmask = page_level_mask(level);
 	offset = virt_addr & ~pmask;
-	phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
+	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
 	return (phys_addr | offset);
 }
 EXPORT_SYMBOL_GPL(slow_virt_to_phys);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
