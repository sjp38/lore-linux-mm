Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id CAE986B0253
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 15:55:19 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id j35so25775523qge.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 12:55:19 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com (prod-mail-xrelay05.akamai.com. [23.79.238.179])
        by mx.google.com with ESMTP id q196si25646966qha.43.2016.04.12.12.55.18
        for <linux-mm@kvack.org>;
        Tue, 12 Apr 2016 12:55:19 -0700 (PDT)
From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH 1/1] mm: update min_free_kbytes from khugepaged after core initialization
Date: Tue, 12 Apr 2016 15:54:37 -0400
Message-Id: <2bd05bd3f581116cee2d6396ea72613cf217a8c5.1460488349.git.jbaron@akamai.com>
In-Reply-To: <cover.1460488349.git.jbaron@akamai.com>
References: <cover.1460488349.git.jbaron@akamai.com>
In-Reply-To: <cover.1460488349.git.jbaron@akamai.com>
References: <cover.1460488349.git.jbaron@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com
Cc: rientjes@google.com, aarcange@redhat.com, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Khugepaged attempts to raise min_free_kbytes if its set too low. However,
on boot khugepaged sets min_free_kbytes first from subsys_initcall(), and
then the mm 'core' over-rides min_free_kbytes after from
init_per_zone_wmark_min(), via a module_init() call.

Khugepaged used to use a late_initcall() to set min_free_kbytes (such that
it occurred after the core initialization), however this was removed when
the initialization of min_free_kbytes was integrated into the starting of
the khugepaged thread.

The fix here is simply to invoke the core initialization using a
core_initcall() instead of module_init(), such that the previous
initialization ordering is restored. I didn't restore the late_initcall()
since start_stop_khugepaged() already sets min_free_kbytes via
set_recommended_min_free_kbytes().

This was noticed when we had a number of page allocation failures when
moving a workload to a kernel with this new initialization ordering. On an
8GB system this restores min_free_kbytes back to 67584 from 11365 when
CONFIG_TRANSPARENT_HUGEPAGE=y is set and either
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y or
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y.

Fixes: 79553da293d3 ("thp: cleanup khugepaged startup")
Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d5d3a3..c1069efcc4d7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6485,7 +6485,7 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_inactive_ratio();
 	return 0;
 }
-module_init(init_per_zone_wmark_min)
+core_initcall(init_per_zone_wmark_min)
 
 /*
  * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
