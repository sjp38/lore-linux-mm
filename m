Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92D0B6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:39:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q126so175358267pga.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:39:19 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id e27si7176165pfk.373.2017.03.17.17.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:39:18 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id r137so6341129pfr.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:39:18 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: use BITS_PER_LONG to unify the definition in page->flags
Date: Sat, 18 Mar 2017 08:39:14 +0800
Message-Id: <20170318003914.24839-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

The field page->flags is defined as unsigned long and is divided into
several parts to store different information of the page, like section,
node, zone. Which means all parts must sit in the one "unsigned
long".

BITS_PER_LONG is used in several places to ensure this applies.

    #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > BITS_PER_LONG - NR_PAGEFLAGS
    #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
    #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS

While we use "sizeof(unsigned long) * 8" in the definition of
SECTIONS_PGOFF

    #define SECTIONS_PGOFF         ((sizeof(unsigned long)*8) - SECTIONS_WIDTH)

This may not be that obvious for audience to catch the point.

This patch replaces the "sizeof(unsigned long) * 8" with BITS_PER_LONG to
make all this consistent.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b84615b0f64c..a5d80de089ff 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -684,7 +684,7 @@ int finish_mkwrite_fault(struct vm_fault *vmf);
  */
 
 /* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_CPUPID] | ... | FLAGS | */
-#define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
+#define SECTIONS_PGOFF		(BITS_PER_LONG - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
 #define LAST_CPUPID_PGOFF	(ZONES_PGOFF - LAST_CPUPID_WIDTH)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
