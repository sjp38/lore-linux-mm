Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 167BB6B0032
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 07:03:22 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id x18so1977594lbi.3
        for <linux-mm@kvack.org>; Fri, 13 Sep 2013 04:03:20 -0700 (PDT)
Subject: [PATCH] mm: catch memory commitment underflow
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 13 Sep 2013 15:03:17 +0400
Message-ID: <20130913110317.20994.25319.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This adds debug for vm_committed_as under CONFIG_DEBUG_VM=y

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/mmap.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 9d54851..2c7e6aa 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -131,6 +131,12 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	vm_acct_memory(pages);
 
+#ifdef CONFIG_DEBUG_VM
+	WARN_ONCE(percpu_counter_read(&vm_committed_as) <
+			-(s64)vm_committed_as_batch * num_online_cpus(),
+			"memory commitment underflow");
+#endif
+
 	/*
 	 * Sometimes we want to use more memory than we have
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
