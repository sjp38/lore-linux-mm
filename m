Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5F416B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 19:39:46 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so2002431pll.0
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:39:46 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i69si2727968pgd.71.2018.11.14.16.39.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 16:39:45 -0800 (PST)
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] userfaultfd: convert userfaultfd_ctx::refcount to refcount_t
Date: Wed, 14 Nov 2018 16:39:16 -0800
Message-Id: <20181115003916.63381-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Reference counters should use refcount_t rather than atomic_t, since the
refcount_t implementation can prevent overflows, reducing the
exploitability of reference leak bugs.  userfaultfd_ctx::refcount is a
reference counter with the usual semantics, so convert it to refcount_t.

Note: I replaced the BUG() on incrementing a 0 refcount with just
refcount_inc(), since part of the semantics of refcount_t is that that
incrementing a 0 refcount is not allowed; with CONFIG_REFCOUNT_FULL,
refcount_inc() already checks for it and warns.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/userfaultfd.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 356d2b8568c14..8375faac2790d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -53,7 +53,7 @@ struct userfaultfd_ctx {
 	/* a refile sequence protected by fault_pending_wqh lock */
 	struct seqcount refile_seq;
 	/* pseudo fd refcounting */
-	atomic_t refcount;
+	refcount_t refcount;
 	/* userfaultfd syscall flags */
 	unsigned int flags;
 	/* features requested from the userspace */
@@ -140,8 +140,7 @@ static int userfaultfd_wake_function(wait_queue_entry_t *wq, unsigned mode,
  */
 static void userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
 {
-	if (!atomic_inc_not_zero(&ctx->refcount))
-		BUG();
+	refcount_inc(&ctx->refcount);
 }
 
 /**
@@ -154,7 +153,7 @@ static void userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
  */
 static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 {
-	if (atomic_dec_and_test(&ctx->refcount)) {
+	if (refcount_dec_and_test(&ctx->refcount)) {
 		VM_BUG_ON(spin_is_locked(&ctx->fault_pending_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fault_pending_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fault_wqh.lock));
@@ -686,7 +685,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 			return -ENOMEM;
 		}
 
-		atomic_set(&ctx->refcount, 1);
+		refcount_set(&ctx->refcount, 1);
 		ctx->flags = octx->flags;
 		ctx->state = UFFD_STATE_RUNNING;
 		ctx->features = octx->features;
@@ -1911,7 +1910,7 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
 	if (!ctx)
 		return -ENOMEM;
 
-	atomic_set(&ctx->refcount, 1);
+	refcount_set(&ctx->refcount, 1);
 	ctx->flags = flags;
 	ctx->features = 0;
 	ctx->state = UFFD_STATE_WAIT_API;
-- 
2.19.1.930.g4563a0d9d0-goog
