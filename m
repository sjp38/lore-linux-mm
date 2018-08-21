Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA1246B1FB2
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 12:49:06 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v21-v6so4114976wrc.2
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 09:49:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4-v6sor795240wmc.61.2018.08.21.09.49.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 09:49:05 -0700 (PDT)
Date: Tue, 21 Aug 2018 19:49:04 +0300
From: Alexander Pateenok <pateenoc@gmail.com>
Subject: [PATCH] percpu: cleanup PER_CPU_DEF_ATTRIBUTES macro
Message-ID: <20180821164904.qqhcduimjznods66@K55DR.localdomain>
Reply-To: 20180821155611.GN3978217@devbig004.ftw2.facebook.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Tejun Heo <tj@kernel.org>

The macro is not used:

  $ grep -r PER_CPU_DEF_ATTRIBUTES
  include/linux/percpu-defs.h:	__PCPU_ATTRS(sec) PER_CPU_DEF_ATTRIBUTES __weak		\
  include/linux/percpu-defs.h:	__PCPU_ATTRS(sec) PER_CPU_DEF_ATTRIBUTES		\
  include/asm-generic/percpu.h:#ifndef PER_CPU_DEF_ATTRIBUTES
  include/asm-generic/percpu.h:#define PER_CPU_DEF_ATTRIBUTES

It was added with b01e8dc34379 ("alpha: fix percpu build breakage") and
removed in 2009 with b01e8dc34379..6088464cf1ae.

Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Alexander Pateenok <pateenoc@gmail.com>
---
 include/asm-generic/percpu.h | 4 ----
 include/linux/percpu-defs.h  | 6 ++----
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/asm-generic/percpu.h b/include/asm-generic/percpu.h
index 1817a8415a5e..c2de013b2cf4 100644
--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -62,10 +62,6 @@ extern void setup_per_cpu_areas(void);
 #define PER_CPU_ATTRIBUTES
 #endif
 
-#ifndef PER_CPU_DEF_ATTRIBUTES
-#define PER_CPU_DEF_ATTRIBUTES
-#endif
-
 #define raw_cpu_generic_read(pcp)					\
 ({									\
 	*raw_cpu_ptr(&(pcp));						\
diff --git a/include/linux/percpu-defs.h b/include/linux/percpu-defs.h
index 2d2096ba1cfe..1ce8e264a269 100644
--- a/include/linux/percpu-defs.h
+++ b/include/linux/percpu-defs.h
@@ -91,8 +91,7 @@
 	extern __PCPU_DUMMY_ATTRS char __pcpu_unique_##name;		\
 	__PCPU_DUMMY_ATTRS char __pcpu_unique_##name;			\
 	extern __PCPU_ATTRS(sec) __typeof__(type) name;			\
-	__PCPU_ATTRS(sec) PER_CPU_DEF_ATTRIBUTES __weak			\
-	__typeof__(type) name
+	__PCPU_ATTRS(sec) __weak __typeof__(type) name
 #else
 /*
  * Normal declaration and definition macros.
@@ -101,8 +100,7 @@
 	extern __PCPU_ATTRS(sec) __typeof__(type) name
 
 #define DEFINE_PER_CPU_SECTION(type, name, sec)				\
-	__PCPU_ATTRS(sec) PER_CPU_DEF_ATTRIBUTES			\
-	__typeof__(type) name
+	__PCPU_ATTRS(sec) __typeof__(type) name
 #endif
 
 /*
-- 
2.17.1
