Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD386B025E
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:47:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so12954511wme.4
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:47:31 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id yo1si2896618wjc.240.2016.12.15.08.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 08:47:29 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id j10so10720449wjb.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:47:29 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
Date: Thu, 15 Dec 2016 17:47:21 +0100
Message-Id: <20161215164722.21586-2-mhocko@kernel.org>
In-Reply-To: <20161215164722.21586-1-mhocko@kernel.org>
References: <20161215164722.21586-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cristopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Alexei Starovoitov <ast@kernel.org>

From: Michal Hocko <mhocko@suse.com>

01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
overflow") has added checks for the maximum allocateable size. It
(ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
it is not very clean because we already have KMALLOC_MAX_SIZE for this
very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.

Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/bpf/arraymap.c | 2 +-
 kernel/bpf/hashtab.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index a2ac051c342f..229a5d5df977 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -56,7 +56,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	    attr->value_size == 0 || attr->map_flags)
 		return ERR_PTR(-EINVAL);
 
-	if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
+	if (attr->value_size > KMALLOC_MAX_SIZE)
 		/* if value_size is bigger, the user space won't be able to
 		 * access the elements.
 		 */
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index ad1bc67aff1b..c5ec7dc71c84 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -181,7 +181,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		 */
 		goto free_htab;
 
-	if (htab->map.value_size >= (1 << (KMALLOC_SHIFT_MAX - 1)) -
+	if (htab->map.value_size >= KMALLOC_MAX_SIZE -
 	    MAX_BPF_STACK - sizeof(struct htab_elem))
 		/* if value_size is bigger, the user space won't be able to
 		 * access the elements via bpf syscall. This check also makes
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
