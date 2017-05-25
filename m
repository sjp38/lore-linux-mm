Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9E236B02F3
	for <linux-mm@kvack.org>; Thu, 25 May 2017 11:42:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a66so233867526pfl.6
        for <linux-mm@kvack.org>; Thu, 25 May 2017 08:42:28 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o123si28885743pfb.32.2017.05.25.08.42.27
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 08:42:28 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 1/3] mm: kmemleak: Slightly reduce the size of some structures on 64-bit architectures
Date: Thu, 25 May 2017 16:42:15 +0100
Message-Id: <1495726937-23557-2-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
References: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

This patch changes the kmemleak_object.flags type to unsigned int and
moves the early_log.min_count (int) near early_log.op_type (int) to
slightly reduce the size of these structures on 64-bit architectures.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 20036d4f9f13..964b12eba2c1 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -150,7 +150,7 @@ struct kmemleak_scan_area {
  */
 struct kmemleak_object {
 	spinlock_t lock;
-	unsigned long flags;		/* object status flags */
+	unsigned int flags;		/* object status flags */
 	struct list_head object_list;
 	struct list_head gray_list;
 	struct rb_node rb_node;
@@ -262,9 +262,9 @@ enum {
  */
 struct early_log {
 	int op_type;			/* kmemleak operation type */
+	int min_count;			/* minimum reference count */
 	const void *ptr;		/* allocated/freed memory block */
 	size_t size;			/* memory block size */
-	int min_count;			/* minimum reference count */
 	unsigned long trace[MAX_TRACE];	/* stack trace */
 	unsigned int trace_len;		/* stack trace length */
 };
@@ -393,7 +393,7 @@ static void dump_object_info(struct kmemleak_object *object)
 		  object->comm, object->pid, object->jiffies);
 	pr_notice("  min_count = %d\n", object->min_count);
 	pr_notice("  count = %d\n", object->count);
-	pr_notice("  flags = 0x%lx\n", object->flags);
+	pr_notice("  flags = 0x%x\n", object->flags);
 	pr_notice("  checksum = %u\n", object->checksum);
 	pr_notice("  backtrace:\n");
 	print_stack_trace(&trace, 4);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
