Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC676B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 03:57:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x8-v6so1404699pln.9
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 00:57:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10-v6sor274508plo.143.2018.03.19.00.57.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 00:57:11 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] include/linux/mmdebug.h: make VM_WARN* non-rvals
Date: Mon, 19 Mar 2018 08:57:02 +0100
Message-Id: <20180319075702.25645-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>

At present the construct

	if (VM_WARN(...))

will compile OK with CONFIG_DEBUG_VM=y and will fail with
CONFIG_DEBUG_VM=n. The reason is that VM_{WARN,BUG}* have always been
special wrt. {WARN/BUG}* and never generate any code when DEBUG_VM is
disabled. So we cannot really use it in conditionals.

We considered changing things so that this construct works in both cases
but that might cause unwanted code generation with CONFIG_DEBUG_VM=n.  It
is safer and simpler to make the build fail in both cases.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
[akpm@linux-foundation.org: changelog]
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mmdebug.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 35d77b0dae3b..14baf1d9d65b 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -37,10 +37,10 @@ void dump_mm(const struct mm_struct *mm);
 			BUG();						\
 		}							\
 	} while (0)
-#define VM_WARN_ON(cond) WARN_ON(cond)
-#define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
-#define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
-#define VM_WARN(cond, format...) WARN(cond, format)
+#define VM_WARN_ON(cond) (void)WARN_ON(cond)
+#define VM_WARN_ON_ONCE(cond) (void)WARN_ON_ONCE(cond)
+#define VM_WARN_ONCE(cond, format...) (void)WARN_ONCE(cond, format)
+#define VM_WARN(cond, format...) (void)WARN(cond, format)
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
-- 
2.16.1
