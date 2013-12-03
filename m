Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id A7DE76B0080
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:55 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so198361qcx.18
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:55 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id o8si20185440qey.43.2013.12.02.18.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:28:54 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 09/23] mm/init: Use memblock apis for early memory allocations
Date: Mon, 2 Dec 2013 21:27:24 -0500
Message-ID: <1386037658-3161-10-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 init/main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/init/main.c b/init/main.c
index febc511..934430d 100644
--- a/init/main.c
+++ b/init/main.c
@@ -355,9 +355,9 @@ static inline void smp_prepare_cpus(unsigned int maxcpus) { }
  */
 static void __init setup_command_line(char *command_line)
 {
-	saved_command_line = alloc_bootmem(strlen (boot_command_line)+1);
-	initcall_command_line = alloc_bootmem(strlen (boot_command_line)+1);
-	static_command_line = alloc_bootmem(strlen (command_line)+1);
+	saved_command_line = memblock_virt_alloc(strlen(boot_command_line)+1);
+	initcall_command_line = memblock_virt_alloc(strlen (boot_command_line)+1);
+	static_command_line = memblock_virt_alloc(strlen(command_line)+1);
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
