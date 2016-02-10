Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 87EF26B0257
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 17:46:09 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id q63so19063455pfb.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 14:46:09 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oq6si7848124pab.84.2016.02.10.14.46.08
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 14:46:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, tracing: refresh __def_vmaflag_names
Date: Thu, 11 Feb 2016 01:45:02 +0300
Message-Id: <1455144302-59371-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Get list of VMA flags up-to-date and sort it to match VM_* definition
order.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/trace/events/mmflags.h | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 0837ef95880b..5219871aebf9 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -111,15 +111,21 @@ IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
 	) : "none"
 
 #if defined(CONFIG_X86)
-#define __VM_ARCH_SPECIFIC {VM_PAT,     "pat"           }
+#define __VM_ARCH_SPECIFIC_1 {VM_PAT,     "pat"           }
 #elif defined(CONFIG_PPC)
-#define __VM_ARCH_SPECIFIC {VM_SAO,     "sao"           }
+#define __VM_ARCH_SPECIFIC_1 {VM_SAO,     "sao"           }
 #elif defined(CONFIG_PARISC) || defined(CONFIG_METAG) || defined(CONFIG_IA64)
-#define __VM_ARCH_SPECIFIC {VM_GROWSUP,	"growsup"	}
+#define __VM_ARCH_SPECIFIC_1 {VM_GROWSUP,	"growsup"	}
 #elif !defined(CONFIG_MMU)
-#define __VM_ARCH_SPECIFIC {VM_MAPPED_COPY,"mappedcopy"	}
+#define __VM_ARCH_SPECIFIC_1 {VM_MAPPED_COPY,"mappedcopy"	}
 #else
-#define __VM_ARCH_SPECIFIC {VM_ARCH_1,	"arch_1"	}
+#define __VM_ARCH_SPECIFIC_1 {VM_ARCH_1,	"arch_1"	}
+#endif
+
+#if defined(CONFIG_X86)
+#define __VM_ARCH_SPECIFIC_2 {VM_MPX,		"mpx"		}
+#else
+#define __VM_ARCH_SPECIFIC_2 {VM_ARCH_2,	"arch_2"	}
 #endif
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
@@ -138,19 +144,22 @@ IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
 	{VM_MAYEXEC,			"mayexec"	},		\
 	{VM_MAYSHARE,			"mayshare"	},		\
 	{VM_GROWSDOWN,			"growsdown"	},		\
+	{VM_UFFD_MISSING,		"uffd_missing"	},		\
 	{VM_PFNMAP,			"pfnmap"	},		\
 	{VM_DENYWRITE,			"denywrite"	},		\
-	{VM_LOCKONFAULT,		"lockonfault"	},		\
+	{VM_UFFD_WP,			"uffd_wp"	},		\
 	{VM_LOCKED,			"locked"	},		\
 	{VM_IO,				"io"		},		\
 	{VM_SEQ_READ,			"seqread"	},		\
 	{VM_RAND_READ,			"randread"	},		\
 	{VM_DONTCOPY,			"dontcopy"	},		\
 	{VM_DONTEXPAND,			"dontexpand"	},		\
+	{VM_LOCKONFAULT,		"lockonfault"	},		\
 	{VM_ACCOUNT,			"account"	},		\
 	{VM_NORESERVE,			"noreserve"	},		\
 	{VM_HUGETLB,			"hugetlb"	},		\
-	__VM_ARCH_SPECIFIC				,		\
+	__VM_ARCH_SPECIFIC_1				,		\
+	__VM_ARCH_SPECIFIC_2				,		\
 	{VM_DONTDUMP,			"dontdump"	},		\
 IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	{VM_MIXEDMAP,			"mixedmap"	},		\
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
