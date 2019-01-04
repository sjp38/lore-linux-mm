Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC7428E00FA
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:49:52 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f125so30907066pgc.20
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 09:49:52 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o32si17404229pld.407.2019.01.04.09.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 09:49:51 -0800 (PST)
From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: [PATCH 1/5] x86/mpx: remove MPX APIs
Date: Fri,  4 Jan 2019 09:49:39 -0800
Message-Id: <1546624183-26543-2-git-send-email-dave.hansen@linux.intel.com>
In-Reply-To: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
References: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

MPX is being removed from the kernel due to a lack of support
in the toolchain going forward (gcc).

The first thing we need to do is remove the userspace-visible
ABIs so that applications will stop using it.  The most visible
one are the enable/disable prctl()s.  Remove them first.

This is the most minimal and least invasive patch needed to
start removing MPX.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 include/uapi/linux/prctl.h |  2 +-
 kernel/sys.c               | 16 ++--------------
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index b4875a9..78fcee3 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -181,7 +181,7 @@ struct prctl_mm_map {
 #define PR_GET_THP_DISABLE	42
 
 /*
- * Tell the kernel to start/stop helping userspace manage bounds tables.
+ * No longer implemented, but left here to ensure the numbers stay reserved:
  */
 #define PR_MPX_ENABLE_MANAGEMENT  43
 #define PR_MPX_DISABLE_MANAGEMENT 44
diff --git a/kernel/sys.c b/kernel/sys.c
index a48cbf1..5fd7991 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -103,12 +103,6 @@
 #ifndef SET_TSC_CTL
 # define SET_TSC_CTL(a)		(-EINVAL)
 #endif
-#ifndef MPX_ENABLE_MANAGEMENT
-# define MPX_ENABLE_MANAGEMENT()	(-EINVAL)
-#endif
-#ifndef MPX_DISABLE_MANAGEMENT
-# define MPX_DISABLE_MANAGEMENT()	(-EINVAL)
-#endif
 #ifndef GET_FP_MODE
 # define GET_FP_MODE(a)		(-EINVAL)
 #endif
@@ -2448,15 +2442,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		up_write(&me->mm->mmap_sem);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
-		if (arg2 || arg3 || arg4 || arg5)
-			return -EINVAL;
-		error = MPX_ENABLE_MANAGEMENT();
-		break;
 	case PR_MPX_DISABLE_MANAGEMENT:
-		if (arg2 || arg3 || arg4 || arg5)
-			return -EINVAL;
-		error = MPX_DISABLE_MANAGEMENT();
-		break;
+		/* No longer implemented: */
+		return -EINVAL;
 	case PR_SET_FP_MODE:
 		error = SET_FP_MODE(me, arg2);
 		break;
-- 
2.7.4
