Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4486B0281
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j3so2971015wrb.18
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x31si559568edx.227.2018.03.21.12.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:25:15 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIY7Z077494
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:14 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2guw9k0qeh-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:14 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:25:11 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 29/32] docs/vm: zsmalloc.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:45 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-30-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/zsmalloc.txt | 60 ++++++++++++++++++++++++++-----------------
 1 file changed, 36 insertions(+), 24 deletions(-)

diff --git a/Documentation/vm/zsmalloc.txt b/Documentation/vm/zsmalloc.txt
index 64ed63c..6e79893 100644
--- a/Documentation/vm/zsmalloc.txt
+++ b/Documentation/vm/zsmalloc.txt
@@ -1,5 +1,8 @@
+.. _zsmalloc:
+
+========
 zsmalloc
---------
+========
 
 This allocator is designed for use with zram. Thus, the allocator is
 supposed to work well under low memory conditions. In particular, it
@@ -31,40 +34,49 @@ be mapped using zs_map_object() to get a usable pointer and subsequently
 unmapped using zs_unmap_object().
 
 stat
-----
+====
 
 With CONFIG_ZSMALLOC_STAT, we could see zsmalloc internal information via
-/sys/kernel/debug/zsmalloc/<user name>. Here is a sample of stat output:
+``/sys/kernel/debug/zsmalloc/<user name>``. Here is a sample of stat output::
 
-# cat /sys/kernel/debug/zsmalloc/zram0/classes
+ # cat /sys/kernel/debug/zsmalloc/zram0/classes
 
  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage
-    ..
-    ..
+    ...
+    ...
      9   176           0            1           186        129          8                4
     10   192           1            0          2880       2872        135                3
     11   208           0            1           819        795         42                2
     12   224           0            1           219        159         12                4
-    ..
-    ..
+    ...
+    ...
+
 
+class
+	index
+size
+	object size zspage stores
+almost_empty
+	the number of ZS_ALMOST_EMPTY zspages(see below)
+almost_full
+	the number of ZS_ALMOST_FULL zspages(see below)
+obj_allocated
+	the number of objects allocated
+obj_used
+	the number of objects allocated to the user
+pages_used
+	the number of pages allocated for the class
+pages_per_zspage
+	the number of 0-order pages to make a zspage
 
-class: index
-size: object size zspage stores
-almost_empty: the number of ZS_ALMOST_EMPTY zspages(see below)
-almost_full: the number of ZS_ALMOST_FULL zspages(see below)
-obj_allocated: the number of objects allocated
-obj_used: the number of objects allocated to the user
-pages_used: the number of pages allocated for the class
-pages_per_zspage: the number of 0-order pages to make a zspage
+We assign a zspage to ZS_ALMOST_EMPTY fullness group when n <= N / f, where
 
-We assign a zspage to ZS_ALMOST_EMPTY fullness group when:
-      n <= N / f, where
-n = number of allocated objects
-N = total number of objects zspage can store
-f = fullness_threshold_frac(ie, 4 at the moment)
+* n = number of allocated objects
+* N = total number of objects zspage can store
+* f = fullness_threshold_frac(ie, 4 at the moment)
 
 Similarly, we assign zspage to:
-      ZS_ALMOST_FULL  when n > N / f
-      ZS_EMPTY        when n == 0
-      ZS_FULL         when n == N
+
+* ZS_ALMOST_FULL  when n > N / f
+* ZS_EMPTY        when n == 0
+* ZS_FULL         when n == N
-- 
2.7.4
