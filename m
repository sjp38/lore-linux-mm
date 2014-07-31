Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8186B0038
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:41:00 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3886054pad.27
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:41:00 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id im10si6326469pbc.229.2014.07.31.08.40.59
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 08:40:59 -0700 (PDT)
Subject: [PATCH 4/7] x86: mm: unify remote invlpg code
From: Dave Hansen <dave@sr71.net>
Date: Thu, 31 Jul 2014 08:40:58 -0700
References: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
In-Reply-To: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
Message-Id: <20140731154058.E0F90408@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, riel@redhat.com, mgorman@suse.de


From: Dave Hansen <dave.hansen@linux.intel.com>

There are currently three paths through the remote flush code:

1. full invalidation
2. single page invalidation using invlpg
3. ranged invalidation using invlpg

This takes 2 and 3 and combines them in to a single path by
making the single-page one just be the start and end be start
plus a single page.  This makes placement of our tracepoint easier.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---

 b/arch/x86/mm/tlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/x86/mm/tlb.c~x86-tlb-simplify-remote-flush-code arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~x86-tlb-simplify-remote-flush-code	2014-06-30 16:18:28.009559635 -0700
+++ b/arch/x86/mm/tlb.c	2014-06-30 16:18:28.013559817 -0700
@@ -102,13 +102,13 @@ static void flush_tlb_func(void *info)
 
 	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
 		return;
+	if (!f->flush_end)
+		f->flush_end = f->flush_start + PAGE_SIZE;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
 		if (f->flush_end == TLB_FLUSH_ALL)
 			local_flush_tlb();
-		else if (!f->flush_end)
-			__flush_tlb_single(f->flush_start);
 		else {
 			unsigned long addr;
 			addr = f->flush_start;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
