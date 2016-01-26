Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 19FFD6B025B
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:46 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 123so104380097wmz.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y190si5277288wme.93.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 04/14] mm, tracing: unify mm flags handling in tracepoints and printk
Date: Tue, 26 Jan 2016 13:45:43 +0100
Message-Id: <1453812353-26744-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

In tracepoints, it's possible to print gfp flags in a human-friendly format
through a macro show_gfp_flags(), which defines a translation array and passes
is to __print_flags(). Since the following patch will introduce support for
gfp flags printing in printk(), it would be nice to reuse the array. This is
not straightforward, since __print_flags() can't simply reference an array
defined in a .c file such as mm/debug.c - it has to be a macro to allow the
macro magic to communicate the format to userspace tools such as trace-cmd.

The solution is to create a macro __def_gfpflag_names which is used both in
show_gfp_flags(), and to define the gfpflag_names[] array in mm/debug.c.

On the other hand, mm/debug.c also defines translation tables for page
flags and vma flags, and desire was expressed (but not implemented in this
series) to use these also from tracepoints. Thus, this patch also renames the
events/gfpflags.h file to events/mmflags.h and moves the table definitions
there, using the same macro approach as for gfpflags. This allows translating
all three kinds of mm-specific flags both in tracepoints and printk.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/gfp.h                |   2 +-
 include/trace/events/btrfs.h       |   2 +-
 include/trace/events/compaction.h  |   2 +-
 include/trace/events/gfpflags.h    |  52 ------------
 include/trace/events/huge_memory.h |   2 -
 include/trace/events/kmem.h        |   2 +-
 include/trace/events/mmflags.h     | 165 +++++++++++++++++++++++++++++++++++++
 include/trace/events/vmscan.h      |   2 +-
 mm/debug.c                         |  88 +++-----------------
 tools/perf/builtin-kmem.c          |   2 +-
 10 files changed, 182 insertions(+), 137 deletions(-)
 delete mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/mmflags.h

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 8dbface7ad59..2cc14ae1b342 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -11,7 +11,7 @@ struct vm_area_struct;
 
 /*
  * In case of changes, please don't forget to update
- * include/trace/events/gfpflags.h and tools/perf/builtin-kmem.c
+ * include/trace/events/mmflags.h and tools/perf/builtin-kmem.c
  */
 
 /* Plain integer GFP bitmasks. Do not use this directly. */
diff --git a/include/trace/events/btrfs.h b/include/trace/events/btrfs.h
index d866f21efbbf..677807f29a1c 100644
--- a/include/trace/events/btrfs.h
+++ b/include/trace/events/btrfs.h
@@ -6,7 +6,7 @@
 
 #include <linux/writeback.h>
 #include <linux/tracepoint.h>
-#include <trace/events/gfpflags.h>
+#include <trace/events/mmflags.h>
 
 struct btrfs_root;
 struct btrfs_fs_info;
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index c92d1e1cbad9..111e5666e5eb 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -7,7 +7,7 @@
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/tracepoint.h>
-#include <trace/events/gfpflags.h>
+#include <trace/events/mmflags.h>
 
 #define COMPACTION_STATUS					\
 	EM( COMPACT_DEFERRED,		"deferred")		\
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
deleted file mode 100644
index f53b216c9311..000000000000
--- a/include/trace/events/gfpflags.h
+++ /dev/null
@@ -1,52 +0,0 @@
-/*
- * The order of these masks is important. Matching masks will be seen
- * first and the left over flags will end up showing by themselves.
- *
- * For example, if we have GFP_KERNEL before GFP_USER we wil get:
- *
- *  GFP_KERNEL|GFP_HARDWALL
- *
- * Thus most bits set go first.
- */
-#define show_gfp_flags(flags)						\
-	(flags) ? __print_flags(flags, "|",				\
-	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	\
-	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"},\
-	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
-	{(unsigned long)GFP_USER,		"GFP_USER"},		\
-	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
-	{(unsigned long)GFP_KERNEL_ACCOUNT,	"GFP_KERNEL_ACCOUNT"},	\
-	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
-	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
-	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
-	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
-	{(unsigned long)GFP_NOWAIT,		"GFP_NOWAIT"},		\
-	{(unsigned long)GFP_DMA,		"GFP_DMA"},		\
-	{(unsigned long)__GFP_HIGHMEM,		"__GFP_HIGHMEM"},	\
-	{(unsigned long)GFP_DMA32,		"GFP_DMA32"},		\
-	{(unsigned long)__GFP_HIGH,		"__GFP_HIGH"},		\
-	{(unsigned long)__GFP_ATOMIC,		"__GFP_ATOMIC"},	\
-	{(unsigned long)__GFP_IO,		"__GFP_IO"},		\
-	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
-	{(unsigned long)__GFP_COLD,		"__GFP_COLD"},		\
-	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
-	{(unsigned long)__GFP_REPEAT,		"__GFP_REPEAT"},	\
-	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
-	{(unsigned long)__GFP_NORETRY,		"__GFP_NORETRY"},	\
-	{(unsigned long)__GFP_COMP,		"__GFP_COMP"},		\
-	{(unsigned long)__GFP_ZERO,		"__GFP_ZERO"},		\
-	{(unsigned long)__GFP_NOMEMALLOC,	"__GFP_NOMEMALLOC"},	\
-	{(unsigned long)__GFP_MEMALLOC,		"__GFP_MEMALLOC"},	\
-	{(unsigned long)__GFP_HARDWALL,		"__GFP_HARDWALL"},	\
-	{(unsigned long)__GFP_THISNODE,		"__GFP_THISNODE"},	\
-	{(unsigned long)__GFP_RECLAIMABLE,	"__GFP_RECLAIMABLE"},	\
-	{(unsigned long)__GFP_MOVABLE,		"__GFP_MOVABLE"},	\
-	{(unsigned long)__GFP_ACCOUNT,		"__GFP_ACCOUNT"},	\
-	{(unsigned long)__GFP_NOTRACK,		"__GFP_NOTRACK"},	\
-	{(unsigned long)__GFP_WRITE,		"__GFP_WRITE"},		\
-	{(unsigned long)__GFP_RECLAIM,		"__GFP_RECLAIM"},	\
-	{(unsigned long)__GFP_DIRECT_RECLAIM,	"__GFP_DIRECT_RECLAIM"},\
-	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"__GFP_KSWAPD_RECLAIM"},\
-	{(unsigned long)__GFP_OTHER_NODE,	"__GFP_OTHER_NODE"}	\
-	) : "none"
-
diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index 98e185799d64..bda21183eb05 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -6,8 +6,6 @@
 
 #include  <linux/tracepoint.h>
 
-#include <trace/events/gfpflags.h>
-
 #define SCAN_STATUS							\
 	EM( SCAN_FAIL,			"failed")			\
 	EM( SCAN_SUCCEED,		"succeeded")			\
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index f7554fd7fc62..ca7217389067 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -6,7 +6,7 @@
 
 #include <linux/types.h>
 #include <linux/tracepoint.h>
-#include <trace/events/gfpflags.h>
+#include <trace/events/mmflags.h>
 
 DECLARE_EVENT_CLASS(kmem_alloc,
 
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
new file mode 100644
index 000000000000..0837ef95880b
--- /dev/null
+++ b/include/trace/events/mmflags.h
@@ -0,0 +1,165 @@
+/*
+ * The order of these masks is important. Matching masks will be seen
+ * first and the left over flags will end up showing by themselves.
+ *
+ * For example, if we have GFP_KERNEL before GFP_USER we wil get:
+ *
+ *  GFP_KERNEL|GFP_HARDWALL
+ *
+ * Thus most bits set go first.
+ */
+
+#define __def_gfpflag_names						\
+	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	\
+	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"},\
+	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
+	{(unsigned long)GFP_USER,		"GFP_USER"},		\
+	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
+	{(unsigned long)GFP_KERNEL_ACCOUNT,	"GFP_KERNEL_ACCOUNT"},	\
+	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
+	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
+	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
+	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
+	{(unsigned long)GFP_NOWAIT,		"GFP_NOWAIT"},		\
+	{(unsigned long)GFP_DMA,		"GFP_DMA"},		\
+	{(unsigned long)__GFP_HIGHMEM,		"__GFP_HIGHMEM"},	\
+	{(unsigned long)GFP_DMA32,		"GFP_DMA32"},		\
+	{(unsigned long)__GFP_HIGH,		"__GFP_HIGH"},		\
+	{(unsigned long)__GFP_ATOMIC,		"__GFP_ATOMIC"},	\
+	{(unsigned long)__GFP_IO,		"__GFP_IO"},		\
+	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
+	{(unsigned long)__GFP_COLD,		"__GFP_COLD"},		\
+	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
+	{(unsigned long)__GFP_REPEAT,		"__GFP_REPEAT"},	\
+	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
+	{(unsigned long)__GFP_NORETRY,		"__GFP_NORETRY"},	\
+	{(unsigned long)__GFP_COMP,		"__GFP_COMP"},		\
+	{(unsigned long)__GFP_ZERO,		"__GFP_ZERO"},		\
+	{(unsigned long)__GFP_NOMEMALLOC,	"__GFP_NOMEMALLOC"},	\
+	{(unsigned long)__GFP_MEMALLOC,		"__GFP_MEMALLOC"},	\
+	{(unsigned long)__GFP_HARDWALL,		"__GFP_HARDWALL"},	\
+	{(unsigned long)__GFP_THISNODE,		"__GFP_THISNODE"},	\
+	{(unsigned long)__GFP_RECLAIMABLE,	"__GFP_RECLAIMABLE"},	\
+	{(unsigned long)__GFP_MOVABLE,		"__GFP_MOVABLE"},	\
+	{(unsigned long)__GFP_ACCOUNT,		"__GFP_ACCOUNT"},	\
+	{(unsigned long)__GFP_NOTRACK,		"__GFP_NOTRACK"},	\
+	{(unsigned long)__GFP_WRITE,		"__GFP_WRITE"},		\
+	{(unsigned long)__GFP_RECLAIM,		"__GFP_RECLAIM"},	\
+	{(unsigned long)__GFP_DIRECT_RECLAIM,	"__GFP_DIRECT_RECLAIM"},\
+	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"__GFP_KSWAPD_RECLAIM"},\
+	{(unsigned long)__GFP_OTHER_NODE,	"__GFP_OTHER_NODE"}	\
+
+#define show_gfp_flags(flags)						\
+	(flags) ? __print_flags(flags, "|",				\
+	__def_gfpflag_names						\
+	) : "none"
+
+#ifdef CONFIG_MMU
+#define IF_HAVE_PG_MLOCK(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_MLOCK(flag,string)
+#endif
+
+#ifdef CONFIG_ARCH_USES_PG_UNCACHED
+#define IF_HAVE_PG_UNCACHED(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_UNCACHED(flag,string)
+#endif
+
+#ifdef CONFIG_MEMORY_FAILURE
+#define IF_HAVE_PG_HWPOISON(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_HWPOISON(flag,string)
+#endif
+
+#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
+#define IF_HAVE_PG_IDLE(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_IDLE(flag,string)
+#endif
+
+#define __def_pageflag_names						\
+	{1UL << PG_locked,		"locked"	},		\
+	{1UL << PG_error,		"error"		},		\
+	{1UL << PG_referenced,		"referenced"	},		\
+	{1UL << PG_uptodate,		"uptodate"	},		\
+	{1UL << PG_dirty,		"dirty"		},		\
+	{1UL << PG_lru,			"lru"		},		\
+	{1UL << PG_active,		"active"	},		\
+	{1UL << PG_slab,		"slab"		},		\
+	{1UL << PG_owner_priv_1,	"owner_priv_1"	},		\
+	{1UL << PG_arch_1,		"arch_1"	},		\
+	{1UL << PG_reserved,		"reserved"	},		\
+	{1UL << PG_private,		"private"	},		\
+	{1UL << PG_private_2,		"private_2"	},		\
+	{1UL << PG_writeback,		"writeback"	},		\
+	{1UL << PG_head,		"head"		},		\
+	{1UL << PG_swapcache,		"swapcache"	},		\
+	{1UL << PG_mappedtodisk,	"mappedtodisk"	},		\
+	{1UL << PG_reclaim,		"reclaim"	},		\
+	{1UL << PG_swapbacked,		"swapbacked"	},		\
+	{1UL << PG_unevictable,		"unevictable"	}		\
+IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
+IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
+IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
+IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+
+#define show_page_flags(flags)						\
+	(flags) ? __print_flags(flags, "|",				\
+	__def_pageflag_names						\
+	) : "none"
+
+#if defined(CONFIG_X86)
+#define __VM_ARCH_SPECIFIC {VM_PAT,     "pat"           }
+#elif defined(CONFIG_PPC)
+#define __VM_ARCH_SPECIFIC {VM_SAO,     "sao"           }
+#elif defined(CONFIG_PARISC) || defined(CONFIG_METAG) || defined(CONFIG_IA64)
+#define __VM_ARCH_SPECIFIC {VM_GROWSUP,	"growsup"	}
+#elif !defined(CONFIG_MMU)
+#define __VM_ARCH_SPECIFIC {VM_MAPPED_COPY,"mappedcopy"	}
+#else
+#define __VM_ARCH_SPECIFIC {VM_ARCH_1,	"arch_1"	}
+#endif
+
+#ifdef CONFIG_MEM_SOFT_DIRTY
+#define IF_HAVE_VM_SOFTDIRTY(flag,name) {flag, name },
+#else
+#define IF_HAVE_VM_SOFTDIRTY(flag,name)
+#endif
+
+#define __def_vmaflag_names						\
+	{VM_READ,			"read"		},		\
+	{VM_WRITE,			"write"		},		\
+	{VM_EXEC,			"exec"		},		\
+	{VM_SHARED,			"shared"	},		\
+	{VM_MAYREAD,			"mayread"	},		\
+	{VM_MAYWRITE,			"maywrite"	},		\
+	{VM_MAYEXEC,			"mayexec"	},		\
+	{VM_MAYSHARE,			"mayshare"	},		\
+	{VM_GROWSDOWN,			"growsdown"	},		\
+	{VM_PFNMAP,			"pfnmap"	},		\
+	{VM_DENYWRITE,			"denywrite"	},		\
+	{VM_LOCKONFAULT,		"lockonfault"	},		\
+	{VM_LOCKED,			"locked"	},		\
+	{VM_IO,				"io"		},		\
+	{VM_SEQ_READ,			"seqread"	},		\
+	{VM_RAND_READ,			"randread"	},		\
+	{VM_DONTCOPY,			"dontcopy"	},		\
+	{VM_DONTEXPAND,			"dontexpand"	},		\
+	{VM_ACCOUNT,			"account"	},		\
+	{VM_NORESERVE,			"noreserve"	},		\
+	{VM_HUGETLB,			"hugetlb"	},		\
+	__VM_ARCH_SPECIFIC				,		\
+	{VM_DONTDUMP,			"dontdump"	},		\
+IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
+	{VM_MIXEDMAP,			"mixedmap"	},		\
+	{VM_HUGEPAGE,			"hugepage"	},		\
+	{VM_NOHUGEPAGE,			"nohugepage"	},		\
+	{VM_MERGEABLE,			"mergeable"	}		\
+
+#define show_vma_flags(flags)						\
+	(flags) ? __print_flags(flags, "|",				\
+	__def_vmaflag_names						\
+	) : "none"
+
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 31763dd8db1c..0101ef37f1ee 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -8,7 +8,7 @@
 #include <linux/tracepoint.h>
 #include <linux/mm.h>
 #include <linux/memcontrol.h>
-#include <trace/events/gfpflags.h>
+#include <trace/events/mmflags.h>
 
 #define RECLAIM_WB_ANON		0x0001u
 #define RECLAIM_WB_FILE		0x0002u
diff --git a/mm/debug.c b/mm/debug.c
index f05b2d5d6481..410af904a7d5 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -9,41 +9,14 @@
 #include <linux/mm.h>
 #include <linux/trace_events.h>
 #include <linux/memcontrol.h>
+#include <trace/events/mmflags.h>
 
 static const struct trace_print_flags pageflag_names[] = {
-	{1UL << PG_locked,		"locked"	},
-	{1UL << PG_error,		"error"		},
-	{1UL << PG_referenced,		"referenced"	},
-	{1UL << PG_uptodate,		"uptodate"	},
-	{1UL << PG_dirty,		"dirty"		},
-	{1UL << PG_lru,			"lru"		},
-	{1UL << PG_active,		"active"	},
-	{1UL << PG_slab,		"slab"		},
-	{1UL << PG_owner_priv_1,	"owner_priv_1"	},
-	{1UL << PG_arch_1,		"arch_1"	},
-	{1UL << PG_reserved,		"reserved"	},
-	{1UL << PG_private,		"private"	},
-	{1UL << PG_private_2,		"private_2"	},
-	{1UL << PG_writeback,		"writeback"	},
-	{1UL << PG_head,		"head"		},
-	{1UL << PG_swapcache,		"swapcache"	},
-	{1UL << PG_mappedtodisk,	"mappedtodisk"	},
-	{1UL << PG_reclaim,		"reclaim"	},
-	{1UL << PG_swapbacked,		"swapbacked"	},
-	{1UL << PG_unevictable,		"unevictable"	},
-#ifdef CONFIG_MMU
-	{1UL << PG_mlocked,		"mlocked"	},
-#endif
-#ifdef CONFIG_ARCH_USES_PG_UNCACHED
-	{1UL << PG_uncached,		"uncached"	},
-#endif
-#ifdef CONFIG_MEMORY_FAILURE
-	{1UL << PG_hwpoison,		"hwpoison"	},
-#endif
-#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
-	{1UL << PG_young,		"young"		},
-	{1UL << PG_idle,		"idle"		},
-#endif
+	__def_pageflag_names
+};
+
+static const struct trace_print_flags gfpflag_names[] = {
+	__def_gfpflag_names
 };
 
 static void dump_flags(unsigned long flags,
@@ -108,47 +81,8 @@ EXPORT_SYMBOL(dump_page);
 
 #ifdef CONFIG_DEBUG_VM
 
-static const struct trace_print_flags vmaflags_names[] = {
-	{VM_READ,			"read"		},
-	{VM_WRITE,			"write"		},
-	{VM_EXEC,			"exec"		},
-	{VM_SHARED,			"shared"	},
-	{VM_MAYREAD,			"mayread"	},
-	{VM_MAYWRITE,			"maywrite"	},
-	{VM_MAYEXEC,			"mayexec"	},
-	{VM_MAYSHARE,			"mayshare"	},
-	{VM_GROWSDOWN,			"growsdown"	},
-	{VM_PFNMAP,			"pfnmap"	},
-	{VM_DENYWRITE,			"denywrite"	},
-	{VM_LOCKONFAULT,		"lockonfault"	},
-	{VM_LOCKED,			"locked"	},
-	{VM_IO,				"io"		},
-	{VM_SEQ_READ,			"seqread"	},
-	{VM_RAND_READ,			"randread"	},
-	{VM_DONTCOPY,			"dontcopy"	},
-	{VM_DONTEXPAND,			"dontexpand"	},
-	{VM_ACCOUNT,			"account"	},
-	{VM_NORESERVE,			"noreserve"	},
-	{VM_HUGETLB,			"hugetlb"	},
-#if defined(CONFIG_X86)
-	{VM_PAT,			"pat"		},
-#elif defined(CONFIG_PPC)
-	{VM_SAO,			"sao"		},
-#elif defined(CONFIG_PARISC) || defined(CONFIG_METAG) || defined(CONFIG_IA64)
-	{VM_GROWSUP,			"growsup"	},
-#elif !defined(CONFIG_MMU)
-	{VM_MAPPED_COPY,		"mappedcopy"	},
-#else
-	{VM_ARCH_1,			"arch_1"	},
-#endif
-	{VM_DONTDUMP,			"dontdump"	},
-#ifdef CONFIG_MEM_SOFT_DIRTY
-	{VM_SOFTDIRTY,			"softdirty"	},
-#endif
-	{VM_MIXEDMAP,			"mixedmap"	},
-	{VM_HUGEPAGE,			"hugepage"	},
-	{VM_NOHUGEPAGE,			"nohugepage"	},
-	{VM_MERGEABLE,			"mergeable"	},
+static const struct trace_print_flags vmaflag_names[] = {
+	__def_vmaflag_names
 };
 
 void dump_vma(const struct vm_area_struct *vma)
@@ -162,7 +96,7 @@ void dump_vma(const struct vm_area_struct *vma)
 		(unsigned long)pgprot_val(vma->vm_page_prot),
 		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
 		vma->vm_file, vma->vm_private_data);
-	dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));
+	dump_flags(vma->vm_flags, vmaflag_names, ARRAY_SIZE(vmaflag_names));
 }
 EXPORT_SYMBOL(dump_vma);
 
@@ -233,8 +167,8 @@ void dump_mm(const struct mm_struct *mm)
 		""		/* This is here to not have a comma! */
 		);
 
-		dump_flags(mm->def_flags, vmaflags_names,
-				ARRAY_SIZE(vmaflags_names));
+		dump_flags(mm->def_flags, vmaflag_names,
+				ARRAY_SIZE(vmaflag_names));
 }
 
 #endif		/* CONFIG_DEBUG_VM */
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 778cdc02563a..5da5a9511cef 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -602,7 +602,7 @@ static int gfpcmp(const void *a, const void *b)
 	return fa->flags - fb->flags;
 }
 
-/* see include/trace/events/gfpflags.h */
+/* see include/trace/events/mmflags.h */
 static const struct {
 	const char *original;
 	const char *compact;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
