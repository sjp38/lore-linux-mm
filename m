Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 98D326B0033
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:25:07 -0400 (EDT)
Date: Fri, 19 Jul 2013 00:25:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/5] x86: finish fault error path with fatal signal
Message-ID: <20130719042502.GF17812@cmpxchg.org>
References: <20130710182506.F25DF461@pobox.sk>
 <20130711072507.GA21667@dhcp22.suse.cz>
 <20130714012641.C2DA4E05@pobox.sk>
 <20130714015112.FFCB7AF7@pobox.sk>
 <20130715154119.GA32435@dhcp22.suse.cz>
 <20130715160006.GB32435@dhcp22.suse.cz>
 <20130716153544.GX17812@cmpxchg.org>
 <20130716160905.GA20018@dhcp22.suse.cz>
 <20130716164830.GZ17812@cmpxchg.org>
 <20130719042124.GC17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719042124.GC17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

The x86 fault handler bails in the middle of error handling when the
task has been killed.  For the next patch this is a problem, because
it relies on pagefault_out_of_memory() being called even when the task
has been killed, to perform proper OOM state unwinding.

This is a rather minor optimization, just remove it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/mm/fault.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 1cebabe..90248c9 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -846,17 +846,6 @@ static noinline int
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	       unsigned long address, unsigned int fault)
 {
-	/*
-	 * Pagefault was interrupted by SIGKILL. We have no reason to
-	 * continue pagefault.
-	 */
-	if (fatal_signal_pending(current)) {
-		if (!(fault & VM_FAULT_RETRY))
-			up_read(&current->mm->mmap_sem);
-		if (!(error_code & PF_USER))
-			no_context(regs, error_code, address);
-		return 1;
-	}
 	if (!(fault & VM_FAULT_ERROR))
 		return 0;
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
