Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70B636B0277
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b85so10028707pfj.22
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u2si538048pls.461.2017.10.20.05.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:53 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 10/15] uprobes: convert uprobe.ref to refcount_t
Date: Fri, 20 Oct 2017 15:15:52 +0300
Message-Id: <1508501757-15784-11-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable uprobe.ref is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/events/uprobes.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 8d42d8f..3514b42 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -66,7 +66,7 @@ static struct percpu_rw_semaphore dup_mmap_sem;
 
 struct uprobe {
 	struct rb_node		rb_node;	/* node in the rb tree */
-	atomic_t		ref;
+	refcount_t		ref;
 	struct rw_semaphore	register_rwsem;
 	struct rw_semaphore	consumer_rwsem;
 	struct list_head	pending_list;
@@ -371,13 +371,13 @@ set_orig_insn(struct arch_uprobe *auprobe, struct mm_struct *mm, unsigned long v
 
 static struct uprobe *get_uprobe(struct uprobe *uprobe)
 {
-	atomic_inc(&uprobe->ref);
+	refcount_inc(&uprobe->ref);
 	return uprobe;
 }
 
 static void put_uprobe(struct uprobe *uprobe)
 {
-	if (atomic_dec_and_test(&uprobe->ref))
+	if (refcount_dec_and_test(&uprobe->ref))
 		kfree(uprobe);
 }
 
@@ -459,7 +459,7 @@ static struct uprobe *__insert_uprobe(struct uprobe *uprobe)
 	rb_link_node(&uprobe->rb_node, parent, p);
 	rb_insert_color(&uprobe->rb_node, &uprobes_tree);
 	/* get access + creation ref */
-	atomic_set(&uprobe->ref, 2);
+	refcount_set(&uprobe->ref, 2);
 
 	return u;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
