Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 833132802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 09:40:05 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so285149971wiw.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:40:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fr3si52175418wic.113.2015.07.06.06.40.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 06:40:02 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] x86, mm: Trace when an IPI is about to be sent
Date: Mon,  6 Jul 2015 14:39:53 +0100
Message-Id: <1436189996-7220-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1436189996-7220-1-git-send-email-mgorman@suse.de>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
index 0038ac7466fd..84ef58543e2b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -552,6 +552,7 @@ enum tlb_flush_reason {
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
