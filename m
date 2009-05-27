Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4336B6B009B
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:00 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 42/43] c/r: add CKPT_COPY() macro
Date: Wed, 27 May 2009 13:33:08 -0400
Message-Id: <1243445589-32388-43-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Dan Smith <danms@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

As suggested by Dave[1], this provides us a way to make the copy-in and
copy-out processes symmetric.  CKPT_COPY_ARRAY() provides us a way to do
the same thing but for arrays.  It's not critical, but it helps us unify
the checkpoint and restart paths for some things.

Changelog:
    Mar 04:
            . Removed semicolons
            . Added build-time check for __must_be_array in CKPT_COPY_ARRAY
    Feb 27:
            . Changed CKPT_COPY() to use assignment, eliminating the need
              for the CKPT_COPY_BIT() macro
            . Add CKPT_COPY_ARRAY() macro to help copying register arrays,
              etc
            . Move the macro definitions inside the CR #ifdef
    Feb 25:
            . Changed WARN_ON() to BUILD_BUG_ON()

Signed-off-by: Dan Smith <danms@us.ibm.com>
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>

1: https://lists.linux-foundation.org/pipermail/containers/2009-February/015821.html (all the way at the bottom)
---
 include/linux/checkpoint.h |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 064dd25..669e90c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -157,6 +157,34 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 
+/* useful macros to copy fields and buffers to/from ckpt_hdr_xxx structures */
+#define CKPT_CPT 1
+#define CKPT_RST 2
+
+#define CKPT_COPY(op, SAVE, LIVE)				        \
+	do {							\
+		if (op == CKPT_CPT)				\
+			SAVE = LIVE;				\
+		else						\
+			LIVE = SAVE;				\
+	} while (0)
+
+/*
+ * Copy @count items from @LIVE to @SAVE if op is CKPT_CPT (otherwise,
+ * copy in the reverse direction)
+ */
+#define CKPT_COPY_ARRAY(op, SAVE, LIVE, count)				\
+	do {								\
+		(void)__must_be_array(SAVE);				\
+		(void)__must_be_array(LIVE);				\
+		BUILD_BUG_ON(sizeof(*SAVE) != sizeof(*LIVE));		\
+		if (op == CKPT_CPT)					\
+			memcpy(SAVE, LIVE, count * sizeof(*SAVE));	\
+		else							\
+			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
+	} while (0)
+
+
 /* debugging flags */
 #define CKPT_DBASE	0x1		/* anything */
 #define CKPT_DSYS	0x2		/* generic (system) */
@@ -189,6 +217,7 @@ extern unsigned long ckpt_debug_level;
  * CKPT_DBASE is the base flags, doesn't change
  * CKPT_DFLAG is to be redfined in each source file
  */
+
 #define ckpt_debug(fmt, args...)  \
 	_ckpt_debug(CKPT_DBASE | CKPT_DFLAG, fmt, ## args)
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
