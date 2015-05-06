Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6A15A6B0073
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:51:03 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so130805437wic.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:51:02 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id bf4si3373930wib.67.2015.05.06.10.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:50 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:49 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id E313E2190069
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:50:29 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46HolS764421890
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:47 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46HokMv027694
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:47 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 07/15] drm/i915: use pagefault_disabled() to check for disabled pagefaults
Date: Wed,  6 May 2015 19:50:31 +0200
Message-Id: <1430934639-2131-8-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

Now that the pagefault disabled counter is in place, we can replace
the in_atomic() check by a pagefault_disabled() checks.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 drivers/gpu/drm/i915/i915_gem_execbuffer.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
index 7ab63d9..98dc211 100644
--- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
+++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
@@ -32,6 +32,7 @@
 #include "i915_trace.h"
 #include "intel_drv.h"
 #include <linux/dma_remapping.h>
+#include <linux/uaccess.h>
 
 #define  __EXEC_OBJECT_HAS_PIN (1<<31)
 #define  __EXEC_OBJECT_HAS_FENCE (1<<30)
@@ -458,7 +459,7 @@ i915_gem_execbuffer_relocate_entry(struct drm_i915_gem_object *obj,
 	}
 
 	/* We can't wait for rendering with pagefaults disabled */
-	if (obj->active && in_atomic())
+	if (obj->active && pagefault_disabled())
 		return -EFAULT;
 
 	if (use_cpu_reloc(obj))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
