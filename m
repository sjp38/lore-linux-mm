Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4890B6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:24:15 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m54so34880014qtb.9
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 20:24:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d10si3804127qtg.184.2017.06.28.20.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 20:24:14 -0700 (PDT)
Date: Wed, 28 Jun 2017 23:24:10 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] mm: convert three more cases to kvmalloc
Message-ID: <alpine.LRH.2.02.1706282317480.11892@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi

I'm submitting this for the next merge window.

Mikulas



From: Mikulas Patocka <mpatocka@redhat.com>

The patch a7c3e901 ("mm: introduce kv[mz]alloc helpers") converted a lot 
of kernel code to kvmalloc. This patch converts three more forgotten 
cases.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 fs/file.c                 |   12 +-----------
 kernel/bpf/syscall.c      |   11 +----------
 kernel/cgroup/cgroup-v1.c |    7 +------
 3 files changed, 3 insertions(+), 27 deletions(-)

Index: linux-2.6/fs/file.c
===================================================================
--- linux-2.6.orig/fs/file.c
+++ linux-2.6/fs/file.c
@@ -32,17 +32,7 @@ unsigned int sysctl_nr_open_max =
 
 static void *alloc_fdmem(size_t size)
 {
-	/*
-	 * Very large allocations can stress page reclaim, so fall back to
-	 * vmalloc() if the allocation size will be considered "large" by the VM.
-	 */
-	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
-		void *data = kmalloc(size, GFP_KERNEL_ACCOUNT |
-				     __GFP_NOWARN | __GFP_NORETRY);
-		if (data != NULL)
-			return data;
-	}
-	return __vmalloc(size, GFP_KERNEL_ACCOUNT, PAGE_KERNEL);
+	return kvmalloc(size, GFP_KERNEL_ACCOUNT);
 }
 
 static void __free_fdtable(struct fdtable *fdt)
Index: linux-2.6/kernel/bpf/syscall.c
===================================================================
--- linux-2.6.orig/kernel/bpf/syscall.c
+++ linux-2.6/kernel/bpf/syscall.c
@@ -58,16 +58,7 @@ void *bpf_map_area_alloc(size_t size)
 	 * trigger under memory pressure as we really just want to
 	 * fail instead.
 	 */
-	const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
-	void *area;
-
-	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
-		area = kmalloc(size, GFP_USER | flags);
-		if (area != NULL)
-			return area;
-	}
-
-	return __vmalloc(size, GFP_KERNEL | flags, PAGE_KERNEL);
+	return kvmalloc(size, GFP_USER | __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO);
 }
 
 void bpf_map_area_free(void *area)
Index: linux-2.6/kernel/cgroup/cgroup-v1.c
===================================================================
--- linux-2.6.orig/kernel/cgroup/cgroup-v1.c
+++ linux-2.6/kernel/cgroup/cgroup-v1.c
@@ -184,15 +184,10 @@ struct cgroup_pidlist {
 /*
  * The following two functions "fix" the issue where there are more pids
  * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
- * TODO: replace with a kernel-wide solution to this problem
  */
-#define PIDLIST_TOO_LARGE(c) ((c) * sizeof(pid_t) > (PAGE_SIZE * 2))
 static void *pidlist_allocate(int count)
 {
-	if (PIDLIST_TOO_LARGE(count))
-		return vmalloc(count * sizeof(pid_t));
-	else
-		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
+	return kvmalloc(count * sizeof(pid_t), GFP_KERNEL);
 }
 
 static void pidlist_free(void *p)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
