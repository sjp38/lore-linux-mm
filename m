Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C7B3C6B0081
	for <linux-mm@kvack.org>; Mon, 13 May 2013 22:04:07 -0400 (EDT)
From: "Zhang, Di" <di.zhang@intel.com>
Subject: [PATCH] x86/mm: move WARN after pgd synced in vmalloc_fault
Date: Tue, 14 May 2013 02:03:24 +0000
Message-ID: <460540DE12BFB64696D05F1149972ECD01568DF0@SHSMSX102.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Tu, Xiaobing" <xiaobing.tu@intel.com>

From: Zhang Di <di.zhang@intel.com>
Date: Tue, 14 May 2013 09:46:36 +0800
Subject: [PATCH] x86/mm: move WARN after pgd synced in vmalloc_fault

Kernel panic is seen after running "perf record -a -g".
The scenario is:
do_nmi->perf_event_nmi_handler->perf_callchain_kernel->dump_trace->
__kernel_text_address->__module_address->within_module_core
/*here page fault happened on mod->module_core since the module pgd
hasn't be synced to the thread's pgd*/
->do_page_fault->vmalloc_fault->WARN_ON_ONCE(in_nmi())
/*notice we are in nmi*/
->warn_slowpath_common->print_modules
/*here page fault happened again when accessing the modules*/
->do_page_fault->vmalloc_fault->WARN_ON_ONCE(in_nmi())
/*notice we are in nmi*/
->warn_slowpath_common->print_modules
/*here page fault happened again when accessing the modules*/
... ...

So it is trapped in this infinite loop until the kernel stack overflowed
and then panics.

The solution is moving WARN_ON_ONCE(in_nmi()) later after the pgd synced,
so there won't be this kind of dead loop.

Signed-off-by: Zhang Di <di.zhang@intel.com>
---
 arch/x86/mm/fault.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 654be4a..6864c3b 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -268,8 +268,6 @@ static noinline __kprobes int vmalloc_fault(unsigned lo=
ng address)
 	if (!(address >=3D VMALLOC_START && address < VMALLOC_END))
 		return -1;
=20
-	WARN_ON_ONCE(in_nmi());
-
 	/*
 	 * Synchronize this task's top level page-table
 	 * with the 'reference' page table.
@@ -279,6 +277,9 @@ static noinline __kprobes int vmalloc_fault(unsigned lo=
ng address)
 	 */
 	pgd_paddr =3D read_cr3();
 	pmd_k =3D vmalloc_sync_one(__va(pgd_paddr), address);
+
+	WARN_ON_ONCE(in_nmi());
+
 	if (!pmd_k)
 		return -1;
=20
--=20
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
