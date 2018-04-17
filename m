Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B881A6B000E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 06:44:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so9258964pff.23
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 03:44:24 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 90si12742081pfp.65.2018.04.17.03.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 03:44:23 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH v2 2/2] mm: vmalloc: Pass proper vm_start into debugobjects
Date: Tue, 17 Apr 2018 16:13:48 +0530
Message-Id: <1523961828-9485-3-git-send-email-cpandya@codeaurora.org>
In-Reply-To: <1523961828-9485-1-git-send-email-cpandya@codeaurora.org>
References: <1523961828-9485-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, khandual@linux.vnet.ibm.com, mhocko@kernel.org, Chintan Pandya <cpandya@codeaurora.org>

Client can call vunmap with some intermediate 'addr'
which may not be the start of the VM area. Entire
unmap code works with vm->vm_start which is proper
but debug object API is called with 'addr'. This
could be a problem within debug objects.

Pass proper start address into debug object API.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
 mm/vmalloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 12d675c..033c918 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1124,15 +1124,15 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	BUG_ON(addr > VMALLOC_END);
 	BUG_ON(!PAGE_ALIGNED(addr));
 
-	debug_check_no_locks_freed(mem, size);
-
 	if (likely(count <= VMAP_MAX_ALLOC)) {
+		debug_check_no_locks_freed(mem, size);
 		vb_free(mem, size);
 		return;
 	}
 
 	va = find_vmap_area(addr);
 	BUG_ON(!va);
+	debug_check_no_locks_freed(va->va_start, (va->va_end - va->va_start));
 	free_unmap_vmap_area(va);
 }
 EXPORT_SYMBOL(vm_unmap_ram);
@@ -1507,8 +1507,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 		return;
 	}
 
-	debug_check_no_locks_freed(addr, get_vm_area_size(area));
-	debug_check_no_obj_freed(addr, get_vm_area_size(area));
+	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
+	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
 	remove_vm_area(addr);
 	if (deallocate_pages) {
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation
Center, Inc., is a member of Code Aurora Forum, a Linux Foundation
Collaborative Project
