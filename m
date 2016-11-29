Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C28336B0267
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:55:54 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id p16so116154995qta.5
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:54 -0800 (PST)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by mx.google.com with ESMTPS id n26si28250269qtf.120.2016.11.29.10.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:55:54 -0800 (PST)
Received: by mail-qt0-f180.google.com with SMTP id n6so165103056qtd.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:54 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv4 06/10] xen: Switch to using __pa_symbol
Date: Tue, 29 Nov 2016 10:55:25 -0800
Message-Id: <1480445729-27130-7-git-send-email-labbott@redhat.com>
In-Reply-To: <1480445729-27130-1-git-send-email-labbott@redhat.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org

__pa_symbol is the correct macro to use on kernel
symbols. Switch to this from __pa.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
Found during a sweep of the kernel. Untested.
---
 drivers/xen/xenbus/xenbus_dev_backend.c | 2 +-
 drivers/xen/xenfs/xenstored.c           | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/xenbus/xenbus_dev_backend.c b/drivers/xen/xenbus/xenbus_dev_backend.c
index 4a41ac9..31ca2bf 100644
--- a/drivers/xen/xenbus/xenbus_dev_backend.c
+++ b/drivers/xen/xenbus/xenbus_dev_backend.c
@@ -99,7 +99,7 @@ static int xenbus_backend_mmap(struct file *file, struct vm_area_struct *vma)
 		return -EINVAL;
 
 	if (remap_pfn_range(vma, vma->vm_start,
-			    virt_to_pfn(xen_store_interface),
+			    PHYS_PFN(__pa_symbol(xen_store_interface)),
 			    size, vma->vm_page_prot))
 		return -EAGAIN;
 
diff --git a/drivers/xen/xenfs/xenstored.c b/drivers/xen/xenfs/xenstored.c
index fef20db..21009ea 100644
--- a/drivers/xen/xenfs/xenstored.c
+++ b/drivers/xen/xenfs/xenstored.c
@@ -38,7 +38,7 @@ static int xsd_kva_mmap(struct file *file, struct vm_area_struct *vma)
 		return -EINVAL;
 
 	if (remap_pfn_range(vma, vma->vm_start,
-			    virt_to_pfn(xen_store_interface),
+			    PHYS_PFN(__pa_symbol(xen_store_interface)),
 			    size, vma->vm_page_prot))
 		return -EAGAIN;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
