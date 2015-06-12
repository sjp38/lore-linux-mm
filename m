Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 698DF6B0074
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:53:29 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so20154324pac.2
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:53:29 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e4si4693754pdn.47.2015.06.12.02.53.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 02:53:28 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v6 6/6] proc: export idle flag via kpageflags
Date: Fri, 12 Jun 2015 12:52:26 +0300
Message-ID: <eadeb8b428449b0f14b62c331ee2ac22a1982ccb.1434102076.git.vdavydov@parallels.com>
In-Reply-To: <cover.1434102076.git.vdavydov@parallels.com>
References: <cover.1434102076.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

As noted by Minchan, a benefit of reading idle flag from
/proc/kpageflags is that one can easily filter dirty and/or unevictable
pages while estimating the size of unused memory.

Note that idle flag read from /proc/kpageflags may be stale in case the
page was accessed via a PTE, because it would be too costly to iterate
over all page mappings on each /proc/kpageflags read to provide an
up-to-date value. To make sure the flag is up-to-date one has to read
/proc/kpageidle first.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 Documentation/vm/pagemap.txt           | 6 ++++++
 fs/proc/page.c                         | 3 +++
 include/uapi/linux/kernel-page-flags.h | 1 +
 3 files changed, 10 insertions(+)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index c9266340852c..5896b7d7fd74 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -64,6 +64,7 @@ There are five components to pagemap:
     22. THP
     23. BALLOON
     24. ZERO_PAGE
+    25. IDLE
 
  * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
    memory cgroup each page is charged to, indexed by PFN. Only available when
@@ -124,6 +125,11 @@ Short descriptions to the page flags:
 24. ZERO_PAGE
     zero page for pfn_zero or huge_zero page
 
+25. IDLE
+    page has not been accessed since it was marked idle (see /proc/kpageidle)
+    Note that this flag may be stale in case the page was accessed via a PTE.
+    To make sure the flag is up-to-date one has to read /proc/kpageidle first.
+
     [IO related page flags]
  1. ERROR     IO error occurred
  3. UPTODATE  page has up-to-date data
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 1e342270b9c0..ec6d1cd65698 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -148,6 +148,9 @@ u64 stable_page_flags(struct page *page)
 	if (PageBalloon(page))
 		u |= 1 << KPF_BALLOON;
 
+	if (page_is_idle(page))
+		u |= 1 << KPF_IDLE;
+
 	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
 
 	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index a6c4962e5d46..5da5f8751ce7 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -33,6 +33,7 @@
 #define KPF_THP			22
 #define KPF_BALLOON		23
 #define KPF_ZERO_PAGE		24
+#define KPF_IDLE		25
 
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
