Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A231C6B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 18:46:59 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w84so16951366qka.11
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:46:59 -0700 (PDT)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id t126si1638806qkc.287.2017.08.16.15.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 15:46:59 -0700 (PDT)
Received: by mail-qk0-f179.google.com with SMTP id o124so19766313qke.3
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:46:58 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv2 1/2] init: Move stack canary initialization after setup_arch
Date: Wed, 16 Aug 2017 15:46:49 -0700
Message-Id: <20170816224650.1089-2-labbott@redhat.com>
In-Reply-To: <20170816224650.1089-1-labbott@redhat.com>
References: <20170816224650.1089-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Micay <danielmicay@gmail.com>, Laura Abbott <labbott@redhat.com>

From: Laura Abbott <lauraa@codeaurora.org>

Stack canary intialization involves getting a random number.
Getting this random number may involve accessing caches or other
architectural specific features which are not available until
after the architecture is setup. Move the stack canary initialization
later to accomodate this.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v2: Also moved add_latent_entropy per suggestion of Kees.
---
 init/main.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/init/main.c b/init/main.c
index 052481fbe363..21d599eaad06 100644
--- a/init/main.c
+++ b/init/main.c
@@ -515,12 +515,6 @@ asmlinkage __visible void __init start_kernel(void)
 	smp_setup_processor_id();
 	debug_objects_early_init();
 
-	/*
-	 * Set up the initial canary ASAP:
-	 */
-	add_latent_entropy();
-	boot_init_stack_canary();
-
 	cgroup_init_early();
 
 	local_irq_disable();
@@ -534,6 +528,11 @@ asmlinkage __visible void __init start_kernel(void)
 	page_address_init();
 	pr_notice("%s", linux_banner);
 	setup_arch(&command_line);
+	/*
+	 * Set up the the initial canary and entropy after arch
+	 */
+	add_latent_entropy();
+	boot_init_stack_canary();
 	mm_init_cpumask(&init_mm);
 	setup_command_line(command_line);
 	setup_nr_cpu_ids();
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
