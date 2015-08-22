Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 550216B0256
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 06:45:37 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so10524390wid.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:37 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id hw4si20814303wjb.135.2015.08.22.03.45.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 03:45:33 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so33786908wid.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:32 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 3/3] mm/vmalloc: Cache the vmalloc memory info
Date: Sat, 22 Aug 2015 12:45:00 +0200
Message-Id: <1440240300-6206-4-git-send-email-mingo@kernel.org>
In-Reply-To: <1440240300-6206-1-git-send-email-mingo@kernel.org>
References: <1440240300-6206-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Hansen <dave@sr71.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Linus Torvalds <torvalds@linux-foundation.org>

Linus reported that glibc (rather stupidly) reads /proc/meminfo
for every sysinfo() call, which causes the Git build to use
a surprising amount of CPU time, mostly due to the overhead
of get_vmalloc_info() - which walks a long list to do its
statistics.

Modify Linus's jiffies based patch to use the newly introduced
vmap_info_changed flag instead: when we cache the vmalloc-info,
we clear the flag. If the flag gets re-set then we'll calculate
the information again.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/vmalloc.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d21febaa557a..ef48e557df5a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2702,7 +2702,7 @@ static int __init proc_vmalloc_init(void)
 }
 module_init(proc_vmalloc_init);
 
-void get_vmalloc_info(struct vmalloc_info *vmi)
+static void calc_vmalloc_info(struct vmalloc_info *vmi)
 {
 	struct vmap_area *va;
 	unsigned long free_area_size;
@@ -2749,5 +2749,23 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 out:
 	rcu_read_unlock();
 }
-#endif
 
+void get_vmalloc_info(struct vmalloc_info *vmi)
+{
+	static struct vmalloc_info cached_info;
+
+	if (!vmap_info_changed) {
+		*vmi = cached_info;
+		return;
+	}
+
+	WRITE_ONCE(vmap_info_changed, 0);
+	barrier();
+
+	calc_vmalloc_info(vmi);
+
+	barrier();
+	cached_info = *vmi;
+}
+
+#endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
