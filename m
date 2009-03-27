Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 770066B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:32 -0400 (EDT)
Message-ID: <49CD37BD.1080102@goop.org>
Date: Fri, 27 Mar 2009 13:31:57 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH 2/2] xen: spin in xen_flush_tlb_others if a target cpu is
 in gup_fast()
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

get_user_pages_fast() relies on cross-cpu tlb flushes being a barrier
between clearing and setting a pte, and before freeing a pagetable page.

It normally implements this by disabling interrupts to suspend tlb flush
IPIs.  This doesn't work for us because we don't use kernel-visible
IPIs for tlb flushes, so just spin manually until none of our target
cpus are in gup_fast().

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index aa16ef4..b0523f8 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -50,6 +50,7 @@
 #include <asm/setup.h>
 #include <asm/paravirt.h>
 #include <asm/linkage.h>
+#include <asm/mmu.h>
 
 #include <asm/xen/hypercall.h>
 #include <asm/xen/hypervisor.h>
@@ -1334,6 +1335,14 @@ static void xen_flush_tlb_others(const struct cpumask *cpus,
 	MULTI_mmuext_op(mcs.mc, &args->op, 1, NULL, DOMID_SELF);
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
+
+	/*
+	 * If we're racing with a get_user_pages_fast(), wait here
+	 * until it has finishes so that it can use cross-cpu tlb
+	 * flush as a barrier.
+	 */
+	while (cpus_intersects(*in_gup_cpumask, *cpus))
+		cpu_relax();
 }
 
 static unsigned long xen_read_cr3(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
