Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0E70B6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:51:01 -0400 (EDT)
Received: by wgez8 with SMTP id z8so102465731wge.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:51:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si4941949wjx.191.2015.06.08.05.50.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:50:58 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/3] x86, mm: Trace when an IPI is about to be sent
Date: Mon,  8 Jun 2015 13:50:52 +0100
Message-Id: <1433767854-24408-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1433767854-24408-1-git-send-email-mgorman@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
index 8d37e26a1007..86ad9f902042 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -534,6 +534,7 @@ enum tlb_flush_reason {
 	TLB_REMOTE_SHOOTDOWN,
 	TLB_LOCAL_SHOOTDOWN,
 	TLB_LOCAL_MM_SHOOTDOWN,
+	TLB_REMOTE_SEND_IPI,
 	NR_TLB_FLUSH_REASONS,
 };
 
diff --git a/include/trace/events/tlb.h b/include/trace/events/tlb.h
index 4250f364a6ca..bc8815f45f3b 100644
--- a/include/trace/events/tlb.h
+++ b/include/trace/events/tlb.h
@@ -11,7 +11,8 @@
 	EM(  TLB_FLUSH_ON_TASK_SWITCH,	"flush on task switch" )	\
 	EM(  TLB_REMOTE_SHOOTDOWN,	"remote shootdown" )		\
 	EM(  TLB_LOCAL_SHOOTDOWN,	"local shootdown" )		\
-	EMe( TLB_LOCAL_MM_SHOOTDOWN,	"local mm shootdown" )
+	EM(  TLB_LOCAL_MM_SHOOTDOWN,	"local mm shootdown" )		\
+	EMe( TLB_REMOTE_SEND_IPI,	"remote ipi send" )
 
 /*
  * First define the enums in TLB_FLUSH_REASON to be exported to userspace
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
