Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 06E9F6B0038
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 13:45:48 -0400 (EDT)
Received: by wizk4 with SMTP id k4so55775924wiz.1
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 10:45:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hv2si4866926wib.70.2015.04.25.10.45.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Apr 2015 10:45:45 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/3] x86, mm: Trace when an IPI is about to be sent
Date: Sat, 25 Apr 2015 18:45:40 +0100
Message-Id: <1429983942-4308-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1429983942-4308-1-git-send-email-mgorman@suse.de>
References: <1429983942-4308-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It is easy to trace when an IPI is received to flush a TLB but harder to
detect what event sent it. This patch makes it easy to identify the source
of IPIs being transmitted for TLB flushes on x86.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Dave Hansen <dave.hansen@intel.com>
---
 arch/x86/mm/tlb.c          | 1 +
 include/linux/mm_types.h   | 1 +
 include/trace/events/tlb.h | 3 ++-
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 3250f2371aea..2da824c1c140 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -140,6 +140,7 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 	info.flush_end = end;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
+	trace_tlb_flush(TLB_REMOTE_SEND_IPI, end - start);
 	if (is_uv_system()) {
 		unsigned int cpu;
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03aab8dc..856038aa166e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -532,6 +532,7 @@ enum tlb_flush_reason {
 	TLB_REMOTE_SHOOTDOWN,
 	TLB_LOCAL_SHOOTDOWN,
 	TLB_LOCAL_MM_SHOOTDOWN,
+	TLB_REMOTE_SEND_IPI,
 	NR_TLB_FLUSH_REASONS,
 };
 
diff --git a/include/trace/events/tlb.h b/include/trace/events/tlb.h
index 0e7635765153..0fc101472988 100644
--- a/include/trace/events/tlb.h
+++ b/include/trace/events/tlb.h
@@ -11,7 +11,8 @@
 	{ TLB_FLUSH_ON_TASK_SWITCH,	"flush on task switch" },	\
 	{ TLB_REMOTE_SHOOTDOWN,		"remote shootdown" },		\
 	{ TLB_LOCAL_SHOOTDOWN,		"local shootdown" },		\
-	{ TLB_LOCAL_MM_SHOOTDOWN,	"local mm shootdown" }
+	{ TLB_LOCAL_MM_SHOOTDOWN,	"local mm shootdown" },		\
+	{ TLB_REMOTE_SEND_IPI,		"remote ipi send" }
 
 TRACE_EVENT_CONDITION(tlb_flush,
 
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
