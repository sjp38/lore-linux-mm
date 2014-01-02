Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 896AE6B0044
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:46 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so15044847pbc.1
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:46 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id pt8si43677200pac.76.2014.01.02.13.53.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:44 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 11/11] fs/proc/kcore.c: Use for_each_potential_vmalloc_area
Date: Thu,  2 Jan 2014 13:53:29 -0800
Message-Id: <1388699609-18214-12-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>

With CONFIG_INTERMIX_VMALLOC, we can no longer assume all vmalloc
is contained between VMALLOC_START and VMALLOC_END. For code that
relies on operating on the vmalloc space, use
for_each_potential_vmalloc_area to track each area separately.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 fs/proc/kcore.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/proc/kcore.c b/fs/proc/kcore.c
index 5ed0e52..9be81a8 100644
--- a/fs/proc/kcore.c
+++ b/fs/proc/kcore.c
@@ -585,8 +585,6 @@ static struct notifier_block kcore_callback_nb __meminitdata = {
 	.priority = 0,
 };
 
-static struct kcore_list kcore_vmalloc;
-
 #ifdef CONFIG_ARCH_PROC_KCORE_TEXT
 static struct kcore_list kcore_text;
 /*
@@ -621,6 +619,11 @@ static void __init add_modules_range(void)
 
 static int __init proc_kcore_init(void)
 {
+	struct kcore_list *kcore_vmalloc;
+	unsigned long vstart;
+	unsigned long vend;
+	int i;
+
 	proc_root_kcore = proc_create("kcore", S_IRUSR, NULL,
 				      &proc_kcore_operations);
 	if (!proc_root_kcore) {
@@ -629,9 +632,16 @@ static int __init proc_kcore_init(void)
 	}
 	/* Store text area if it's special */
 	proc_kcore_text_init();
-	/* Store vmalloc area */
-	kclist_add(&kcore_vmalloc, (void *)VMALLOC_START,
-		VMALLOC_END - VMALLOC_START, KCORE_VMALLOC);
+	for_each_potential_vmalloc_area(&vstart, &vend, &i) {
+		kcore_vmalloc = kzalloc(sizeof(*kcore_vmalloc), GFP_KERNEL);
+		if (!kcore_vmalloc)
+			return 0;
+
+		/* Store vmalloc area */
+		kclist_add(kcore_vmalloc, (void *)vstart,
+				vend - vstart, KCORE_VMALLOC);
+	}
+
 	add_modules_range();
 	/* Store direct-map area from physical memory map */
 	kcore_update_ram();
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
