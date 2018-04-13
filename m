Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA9FA6B000E
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:16:53 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u8so5237643qkg.15
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:16:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 15si355396qkl.69.2018.04.13.06.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:16:52 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 2/8] mm: introduce PG_offline
Date: Fri, 13 Apr 2018 15:16:26 +0200
Message-Id: <20180413131632.1413-3-david@redhat.com>
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
References: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Hildenbrand <david@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

online_pages()/offline_pages() theoretically allows us to work on
sub-section sizes. This is especially relevant in the context of
virtualization. It e.g. allows us to add/remove memory to Linux in a VM in
4MB chunks.

While the whole section is marked as online/offline, we have to know
the state of each page. E.g. to not read memory that is not online
during kexec() or to properly mark a section as offline as soon as all
contained pages are offline.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/page-flags.h     | 10 ++++++++++
 include/trace/events/mmflags.h |  9 ++++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e34a27727b9a..8ebc4bad7824 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -49,6 +49,9 @@
  * PG_hwpoison indicates that a page got corrupted in hardware and contains
  * data with incorrect ECC bits that triggered a machine check. Accessing is
  * not safe since it may cause another machine check. Don't touch!
+ *
+ * PG_offline indicates that a page is offline and the backing storage
+ * might already have been removed (virtualization). Don't touch!
  */
 
 /*
@@ -100,6 +103,9 @@ enum pageflags {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	PG_young,
 	PG_idle,
+#endif
+#ifdef CONFIG_MEMORY_HOTPLUG
+	PG_offline,		/* Page is offline. Don't touch */
 #endif
 	__NR_PAGEFLAGS,
 
@@ -381,6 +387,10 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+PAGEFLAG(Offline, offline, PF_ANY)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a81cffb76d89..14c31209e34a 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -79,6 +79,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+#define IF_HAVE_PG_OFFLINE(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_OFFLINE(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_waiters,		"waiters"	},		\
@@ -104,7 +110,8 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_OFFLINE(PG_offline,		"offline"	)
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
-- 
2.14.3
