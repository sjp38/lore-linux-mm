Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB016B000C
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 22:41:09 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id n128so82305524pfn.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:09 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id w26si8284580pfi.80.2015.12.21.19.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 19:41:02 -0800 (PST)
Received: by mail-pa0-x233.google.com with SMTP id cy9so27687792pac.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:02 -0800 (PST)
From: Laura Abbott <laura@labbott.name>
Subject: [RFC][PATCH 6/7] mm: Add Kconfig option for slab sanitization
Date: Mon, 21 Dec 2015 19:40:40 -0800
Message-Id: <1450755641-7856-7-git-send-email-laura@labbott.name>
In-Reply-To: <1450755641-7856-1-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com


The SL[AOU]B allocators all behave differently w.r.t. to what happen
an object is freed. CONFIG_SLAB_SANITIZATION introduces a common
mechanism to control what happens on free. When this option is
enabled, objects may be poisoned according to a combination of
slab_sanitization command line option and whether SLAB_NO_SANITIZE
is set on a cache.

All credit for the original work should be given to Brad Spengler and
the PaX Team.

Signed-off-by: Laura Abbott <laura@labbott.name>
---
 init/Kconfig | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index 235c7a2..37857f3 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1755,6 +1755,42 @@ config SLUB_CPU_PARTIAL
 	  which requires the taking of locks that may cause latency spikes.
 	  Typically one would choose no for a realtime system.
 
+config SLAB_MEMORY_SANITIZE
+	bool "Sanitize all freed memory"
+	help
+	  By saying Y here the kernel will erase slab objects as soon as they
+	  are freed.  This in turn reduces the lifetime of data
+	  stored in them, making it less likely that sensitive information such
+	  as passwords, cryptographic secrets, etc stay in memory for too long.
+
+	  This is especially useful for programs whose runtime is short, long
+	  lived processes and the kernel itself benefit from this as long as
+	  they ensure timely freeing of memory that may hold sensitive
+	  information.
+
+	  A nice side effect of the sanitization of slab objects is the
+	  reduction of possible info leaks caused by padding bytes within the
+	  leaky structures.  Use-after-free bugs for structures containing
+	  pointers can also be detected as dereferencing the sanitized pointer
+	  will generate an access violation.
+
+	  The tradeoff is performance impact. The noticible impact can vary
+	  and you are advised to test this feature on your expected workload
+	  before deploying it
+
+	  The slab sanitization feature excludes a few slab caches per default
+	  for performance reasons. The level of sanitization can be adjusted
+	  with the sanitize_slab commandline option:
+		sanitize_slab=off: No sanitization will occur
+		santiize_slab=slow: Sanitization occurs only on the slow path
+		for all but the excluded slabs
+		(relevant for SLUB allocator only)
+		sanitize_slab=partial: Sanitization occurs on all path for all
+		but the excluded slabs
+		sanitize_slab=full: All slabs are sanitize
+
+	  If unsure, say Y here.
+
 config MMAP_ALLOW_UNINITIALIZED
 	bool "Allow mmapped anonymous memory to be uninitialized"
 	depends on EXPERT && !MMU
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
