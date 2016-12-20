Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 448A36B02FF
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:07:11 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so24914242wme.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:07:11 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id n128si18934931wmf.141.2016.12.20.05.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:07:10 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id m203so24188165wma.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:07:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] bpf: do not use KMALLOC_SHIFT_MAX
Date: Tue, 20 Dec 2016 14:06:59 +0100
Message-Id: <20161220130659.16461-3-mhocko@kernel.org>
In-Reply-To: <20161220130659.16461-1-mhocko@kernel.org>
References: <20161220130659.16461-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <cl@linux.com>, Alexei Starovoitov <ast@kernel.org>, Andrey Konovalov <andreyknvl@google.com>, netdev@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
overflow") has added checks for the maximum allocateable size. It
(ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
it is not very clean because we already have KMALLOC_MAX_SIZE for this
very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.

The original motivation for using KMALLOC_SHIFT_MAX was to work around
an incorrect KMALLOC_MAX_SIZE which could lead to allocation warnings
but it is no longer needed since "slab: make sure that KMALLOC_MAX_SIZE
will fit into MAX_ORDER".

Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Christoph Lameter <cl@linux.com>
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
