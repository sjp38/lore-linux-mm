Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1976B0037
	for <linux-mm@kvack.org>; Tue, 13 May 2014 05:45:59 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so208309eek.20
        for <linux-mm@kvack.org>; Tue, 13 May 2014 02:45:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n46si12661741eeo.277.2014.05.13.02.45.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 02:45:58 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/19] jump_label: Expose the reference count
Date: Tue, 13 May 2014 10:45:34 +0100
Message-Id: <1399974350-11089-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-1-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

This patch exposes the jump_label reference count in preparation for the
next patch. cpusets cares about both the jump_label being enabled and how
many users of the cpusets there currently are.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/jump_label.h | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
index 5c1dfb2..784304b 100644
--- a/include/linux/jump_label.h
+++ b/include/linux/jump_label.h
@@ -69,6 +69,10 @@ struct static_key {
 
 # include <asm/jump_label.h>
 # define HAVE_JUMP_LABEL
+#else
+struct static_key {
+	atomic_t enabled;
+};
 #endif	/* CC_HAVE_ASM_GOTO && CONFIG_JUMP_LABEL */
 
 enum jump_label_type {
@@ -79,6 +83,12 @@ enum jump_label_type {
 struct module;
 
 #include <linux/atomic.h>
+
+static inline int static_key_count(struct static_key *key)
+{
+	return atomic_read(&key->enabled);
+}
+
 #ifdef HAVE_JUMP_LABEL
 
 #define JUMP_LABEL_TYPE_FALSE_BRANCH	0UL
@@ -134,10 +144,6 @@ extern void jump_label_apply_nops(struct module *mod);
 
 #else  /* !HAVE_JUMP_LABEL */
 
-struct static_key {
-	atomic_t enabled;
-};
-
 static __always_inline void jump_label_init(void)
 {
 	static_key_initialized = true;
@@ -145,14 +151,14 @@ static __always_inline void jump_label_init(void)
 
 static __always_inline bool static_key_false(struct static_key *key)
 {
-	if (unlikely(atomic_read(&key->enabled) > 0))
+	if (unlikely(static_key_count(key) > 0))
 		return true;
 	return false;
 }
 
 static __always_inline bool static_key_true(struct static_key *key)
 {
-	if (likely(atomic_read(&key->enabled) > 0))
+	if (likely(static_key_count(key) > 0))
 		return true;
 	return false;
 }
@@ -194,7 +200,7 @@ static inline int jump_label_apply_nops(struct module *mod)
 
 static inline bool static_key_enabled(struct static_key *key)
 {
-	return (atomic_read(&key->enabled) > 0);
+	return static_key_count(key) > 0;
 }
 
 #endif	/* _LINUX_JUMP_LABEL_H */
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
