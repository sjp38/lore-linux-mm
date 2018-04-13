Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 067AA6B000C
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:34:16 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y7-v6so5761474plh.7
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:34:15 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d13si3851790pgn.334.2018.04.13.04.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 04:34:14 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH 1/2] mm: vmalloc: Avoid racy handling of debugobjects in vunmap
Date: Fri, 13 Apr 2018 17:03:53 +0530
Message-Id: <1523619234-17635-2-git-send-email-cpandya@codeaurora.org>
In-Reply-To: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
References: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>

Currently, __vunmap flow is,
 1) Release the VM area
 2) Free the debug objects corresponding to that vm area.

This leave some race window open.
 1) Release the VM area
 1.5) Some other client gets the same vm area
 1.6) This client allocates new debug objects on the same
      vm area
 2) Free the debug objects corresponding to this vm area.

Here, we actually free 'other' client's debug objects.

Fix this by freeing the debug objects first and then
releasing the VM area.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
 mm/vmalloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ebff729..9ff21a1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1519,7 +1519,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			addr))
 		return;
 
-	area = remove_vm_area(addr);
+	area = find_vmap_area((unsigned long)addr)->vm;
 	if (unlikely(!area)) {
 		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
 				addr);
@@ -1529,6 +1529,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_locks_freed(addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(addr, get_vm_area_size(area));
 
+	remove_vm_area(addr);
 	if (deallocate_pages) {
 		int i;
 
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation
Center, Inc., is a member of Code Aurora Forum, a Linux Foundation
Collaborative Project
