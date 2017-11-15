Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA46C6B026A
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:08:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n89so20979240pfk.17
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:08:47 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e7si17931586plk.481.2017.11.15.06.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:08:46 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 11/16] uprobes: convert uprobe.ref to refcount_t
Date: Wed, 15 Nov 2017 16:03:35 +0200
Message-Id: <1510754620-27088-12-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
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

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the uprobe.ref it might make a difference
in following places:
 - put_uprobe(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

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
