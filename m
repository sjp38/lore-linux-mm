Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f51.google.com (mail-qe0-f51.google.com [209.85.128.51])
	by kanga.kvack.org (Postfix) with ESMTP id 709B76B00FA
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:52:02 -0500 (EST)
Received: by mail-qe0-f51.google.com with SMTP id 1so3429748qee.10
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:52:02 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id hj7si9567627qeb.116.2013.12.09.13.52.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 13:52:01 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v3 09/23] mm/init: Use memblock apis for early memory allocations
Date: Mon, 9 Dec 2013 16:50:42 -0500
Message-ID: <1386625856-12942-10-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock.
And the archs which still uses bootmem, these new apis just fall
back to exiting bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 init/main.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/init/main.c b/init/main.c
index febc511..d3e3cff 100644
--- a/init/main.c
+++ b/init/main.c
@@ -355,9 +355,11 @@ static inline void smp_prepare_cpus(unsigned int maxcpus) { }
  */
 static void __init setup_command_line(char *command_line)
 {
-	saved_command_line = alloc_bootmem(strlen (boot_command_line)+1);
-	initcall_command_line = alloc_bootmem(strlen (boot_command_line)+1);
-	static_command_line = alloc_bootmem(strlen (command_line)+1);
+	saved_command_line =
+		memblock_virt_alloc(strlen(boot_command_line) + 1, 0);
+	initcall_command_line =
+		memblock_virt_alloc(strlen(boot_command_line) + 1, 0);
+	static_command_line = memblock_virt_alloc(strlen(command_line) + 1, 0);
 	strcpy (saved_command_line, boot_command_line);
 	strcpy (static_command_line, command_line);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
