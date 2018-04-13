Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 725CF6B000D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:34:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v19so4642217pfn.7
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:34:21 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id y92-v6si5372630plb.198.2018.04.13.04.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 04:34:20 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH 2/2] mm: vmalloc: Pass proper vm_start into debugobjects
Date: Fri, 13 Apr 2018 17:03:54 +0530
Message-Id: <1523619234-17635-3-git-send-email-cpandya@codeaurora.org>
In-Reply-To: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
References: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>

Client can call vunmap with some intermediate 'addr'
which may not be the start of the VM area. Entire
unmap code works with vm->vm_start which is proper
but debug object API is called with 'addr'. This
could be a problem within debug objects.

Pass proper start address into debug object API.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9ff21a1..28034c55 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1526,8 +1526,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
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
