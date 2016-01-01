Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 70C076B0009
	for <linux-mm@kvack.org>; Thu, 31 Dec 2015 22:24:48 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id e65so110507542pfe.1
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 19:24:48 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id hs5si36322189pac.243.2015.12.31.19.24.47
        for <linux-mm@kvack.org>;
        Thu, 31 Dec 2015 19:24:47 -0800 (PST)
Subject: [-mm PATCH] list, perf: fix list_force_poison() build regression
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 31 Dec 2015 19:24:21 -0800
Message-ID: <20160101032348.26352.75121.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

    In file included from
    /home/sfr/next/next/tools/include/linux/list.h:5:0,
                     from arch/../util/map.h:6,
                     from arch/../util/event.h:8,
                     from arch/../util/debug.h:7,
                     from arch/common.c:4:
    include/linux/list.h: In function 'list_force_poison':
    include/linux/list.h:123:56: error: unused parameter 'entry' [-Werror=unused-parameter]
     static inline void list_force_poison(struct list_head *entry)

perf does not like the empty definition of list_force_poison.  For
simplicity just switch to list_del in the non-debug case.

Fixes "mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup" in
-next.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/list.h |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index d870ba3315f8..ebf5f358e8c3 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -120,9 +120,8 @@ extern void list_del(struct list_head *entry);
  */
 extern void list_force_poison(struct list_head *entry);
 #else
-static inline void list_force_poison(struct list_head *entry)
-{
-}
+/* fallback to the less strict LIST_POISON* definitions */
+#define list_force_poison list_del
 #endif
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
