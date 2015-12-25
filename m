Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 76E6C680DC6
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:10:18 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id iw8so202053704obc.1
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:10:18 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id rk7si39727344obc.95.2015.12.25.14.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:10:17 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 07/16] kexec: Set IORESOURCE_SYSTEM_RAM to System RAM
Date: Fri, 25 Dec 2015 15:09:16 -0700
Message-Id: <1451081365-15190-7-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Young <dyoung@redhat.com>, Toshi Kani <toshi.kani@hpe.com>

Set IORESOURCE_SYSTEM_RAM to 'flags' and IORES_DESC_CRASH_KERNEL
to 'desc' of "Crash kernel" resource ranges, which are child
nodes of System RAM.

Change crash_shrink_memory() to set IORESOURCE_SYSTEM_RAM for
a System RAM range.

Change kexec_add_buffer() to call walk_iomem_res() with
IORESOURCE_SYSTEM_RAM type for "Crash kernel".

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Young <dyoung@redhat.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 kernel/kexec_core.c |    8 +++++---
 kernel/kexec_file.c |    2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 11b64a6..80bff05 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -66,13 +66,15 @@ struct resource crashk_res = {
 	.name  = "Crash kernel",
 	.start = 0,
 	.end   = 0,
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
+	.desc  = IORES_DESC_CRASH_KERNEL
 };
 struct resource crashk_low_res = {
 	.name  = "Crash kernel",
 	.start = 0,
 	.end   = 0,
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
+	.desc  = IORES_DESC_CRASH_KERNEL
 };
 
 int kexec_should_crash(struct task_struct *p)
@@ -934,7 +936,7 @@ int crash_shrink_memory(unsigned long new_size)
 
 	ram_res->start = end;
 	ram_res->end = crashk_res.end;
-	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
+	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
 	ram_res->name = "System RAM";
 
 	crashk_res.end = end - 1;
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index b70ada0..c245085 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -523,7 +523,7 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
 	/* Walk the RAM ranges and allocate a suitable range for the buffer */
 	if (image->type == KEXEC_TYPE_CRASH)
 		ret = walk_iomem_res("Crash kernel",
-				     IORESOURCE_MEM | IORESOURCE_BUSY,
+				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
 				     crashk_res.start, crashk_res.end, kbuf,
 				     locate_mem_hole_callback);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
