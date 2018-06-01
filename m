Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C106C6B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 07:53:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e7-v6so14346564pfi.8
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 04:53:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9-v6sor3716809pgc.260.2018.06.01.04.53.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 04:53:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: kvmalloc does not fallback to vmalloc for incompatible gfp flags
Date: Fri,  1 Jun 2018 13:53:29 +0200
Message-Id: <20180601115329.27807-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tom Herbert <tom@quantonium.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

kvmalloc warned about incompatible gfp_mask to catch abusers (mostly
GFP_NOFS) with an intention that this will motivate authors of the code
to fix those. Linus argues that this just motivates people to do even
more hacks like
	if (gfp == GFP_KERNEL)
		kvmalloc
	else
		kmalloc

I haven't seen this happening much (Linus pointed to bucket_lock special
cases an atomic allocation but my git foo hasn't found much more) but
it is true that we can grow those in future. Therefore Linus suggested
to simply not fallback to vmalloc for incompatible gfp flags and rather
stick with the kmalloc path.

Requested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi Andrew,
for more context. Linus has pointed out [1] that our (well mine)
insisting on GFP_KERNEL compatible gfp flags for kvmalloc* can actually
lead to a worse code because people will work around the restriction.
So this patch allows kvmalloc to be more permissive and silently skip
vmalloc path for incompatible gfp flags. This will not help my original
plan to enforce people to think about GFP_NOFS usage more deeply but
I can live with that obviously...

alloc_bucket_spinlocks is the only place I could find which special
cases kvmalloc based on the gfp mask.

[1] http://lkml.kernel.org/r/CA+55aFxvNCEBQsxfr=yL3jgxiC8M8wY2MHwVBH+T8qSWyP-WPg@mail.gmail.com

 lib/bucket_locks.c | 5 +----
 mm/util.c          | 6 ++++--
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/lib/bucket_locks.c b/lib/bucket_locks.c
index 266a97c5708b..ade3ce6c4af6 100644
--- a/lib/bucket_locks.c
+++ b/lib/bucket_locks.c
@@ -30,10 +30,7 @@ int alloc_bucket_spinlocks(spinlock_t **locks, unsigned int *locks_mask,
 	}
 
 	if (sizeof(spinlock_t) != 0) {
-		if (gfpflags_allow_blocking(gfp))
-			tlocks = kvmalloc(size * sizeof(spinlock_t), gfp);
-		else
-			tlocks = kmalloc_array(size, sizeof(spinlock_t), gfp);
+		tlocks = kvmalloc_array(size, sizeof(spinlock_t), gfp);
 		if (!tlocks)
 			return -ENOMEM;
 		for (i = 0; i < size; i++)
diff --git a/mm/util.c b/mm/util.c
index 45fc3169e7b0..c6586c146995 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -391,7 +391,8 @@ EXPORT_SYMBOL(vm_mmap);
  * __GFP_RETRY_MAYFAIL is supported, and it should be used only if kmalloc is
  * preferable to the vmalloc fallback, due to visible performance drawbacks.
  *
- * Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
+ * Please note that any use of gfp flags outside of GFP_KERNEL is careful to not
+ * fall back to vmalloc.
  */
 void *kvmalloc_node(size_t size, gfp_t flags, int node)
 {
@@ -402,7 +403,8 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
 	 * so the given set of flags has to be compatible.
 	 */
-	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
+	if ((flags & GFP_KERNEL) != GFP_KERNEL)
+		return kmalloc_node(size, flags, node);
 
 	/*
 	 * We want to attempt a large physically contiguous block first because
-- 
2.17.0
