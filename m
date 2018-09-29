Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 248A18E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 21:36:20 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id p18-v6so13585ybe.0
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 18:36:20 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k5-v6sor3628837ybd.71.2018.09.28.18.36.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 18:36:19 -0700 (PDT)
Date: Sat, 29 Sep 2018 03:36:11 +0200
Message-Id: <20180929013611.163130-1-jannh@google.com>
Mime-Version: 1.0
Subject: [PATCH] mm/vmstat: fix outdated vmstat_text
From: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jannh@google.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Kees Cook <keescook@chromium.org>

commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
removed the VMACACHE_FULL_FLUSHES statistics, but didn't remove the
corresponding entry in vmstat_text. This causes an out-of-bounds access in
vmstat_show().

Luckily this only affects kernels with CONFIG_DEBUG_VM_VMACACHE=y, which is
probably very rare.

Having two gigantic arrays that must be kept in sync isn't exactly robust.
To make it easier to catch such issues in the future, add a BUILD_BUG_ON().

Fixes: 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
Cc: stable@vger.kernel.org
Signed-off-by: Jann Horn <jannh@google.com>
---
 mm/vmstat.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8ba0870ecddd..db6379a3f8bf 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1283,7 +1283,6 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_DEBUG_VM_VMACACHE
 	"vmacache_find_calls",
 	"vmacache_find_hits",
-	"vmacache_full_flushes",
 #endif
 #ifdef CONFIG_SWAP
 	"swap_ra",
@@ -1661,6 +1660,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	stat_items_size += sizeof(struct vm_event_state);
 #endif
 
+	BUILD_BUG_ON(stat_items_size !=
+		     ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
 	v = kmalloc(stat_items_size, GFP_KERNEL);
 	m->private = v;
 	if (!v)
-- 
2.19.0.605.g01d371f741-goog
