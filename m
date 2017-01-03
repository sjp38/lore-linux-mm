Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD5056B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 16:48:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so81094802wmu.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 13:48:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si78764018wjr.104.2017.01.03.13.48.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 13:48:57 -0800 (PST)
Date: Tue, 3 Jan 2017 22:48:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20170103214854.GC18167@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <19b44b6e-037f-45fd-a13a-be5d87259e75@suse.cz>
 <20170103204745.GC13873@dhcp22.suse.cz>
 <20170103205244.GD13873@dhcp22.suse.cz>
 <20170103212411.GA17822@dhcp22.suse.cz>
 <cfc85361-5bd0-7614-e1d6-1a71e0421571@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cfc85361-5bd0-7614-e1d6-1a71e0421571@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 03-01-17 22:40:23, Vlastimil Babka wrote:
> On 01/03/2017 10:24 PM, Michal Hocko wrote:
[...]
> > > So the tool should be OK as long as it can find values for LRU_*
> > > constants. Is this what is the problem?
> 
> Exactly.

So this should make it work (it compiles it has to be correct, right?).
---
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index aa4caa6914a9..6172afa2fd82 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -240,6 +240,13 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
 				EMe(ZONE_MOVABLE,"Movable")
 
+#define LRU_NAMES		\
+		EM (LRU_INACTIVE_ANON, "inactive_anon") \
+		EM (LRU_ACTIVE_ANON, "active_anon") \
+		EM (LRU_INACTIVE_FILE, "inactive_file") \
+		EM (LRU_ACTIVE_FILE, "active_file") \
+		EMe(LRU_UNEVICTABLE, "unevictable")
+
 /*
  * First define the enums in the above macros to be exported to userspace
  * via TRACE_DEFINE_ENUM().
@@ -253,6 +260,7 @@ COMPACTION_STATUS
 COMPACTION_PRIORITY
 COMPACTION_FEEDBACK
 ZONE_TYPE
+LRU_NAMES
 
 /*
  * Now redefine the EM() and EMe() macros to map the enums to the strings
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 8e7c4c56499a..3c38d9315b43 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -36,14 +36,6 @@
 		(RECLAIM_WB_ASYNC) \
 	)
 
-#define show_lru_name(lru) \
-	__print_symbolic(lru, \
-			{LRU_INACTIVE_ANON, "inactive_anon"}, \
-			{LRU_ACTIVE_ANON, "active_anon"}, \
-			{LRU_INACTIVE_FILE, "inactive_file"}, \
-			{LRU_ACTIVE_FILE, "active_file"}, \
-			{LRU_UNEVICTABLE, "unevictable"})
-
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
 
 	TP_PROTO(int nid),
@@ -319,7 +311,7 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		__entry->nr_scanned,
 		__entry->nr_skipped,
 		__entry->nr_taken,
-		show_lru_name(__entry->lru))
+		__print_symbolic(__entry->lru, LRU_NAMES))
 );
 
 TRACE_EVENT(mm_vmscan_writepage,

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
