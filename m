Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EC7296B012C
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 04:14:17 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so4257011pdj.1
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 01:14:16 -0700 (PDT)
Received: from psmtp.com ([74.125.245.165])
        by mx.google.com with SMTP id gj2si843062pac.51.2013.10.18.01.14.14
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 01:14:15 -0700 (PDT)
From: linx.z.chen@intel.com
Subject: [PATCH] mm/pagewalk.c: Fix walk_page_range access wrong PTEs
Date: Fri, 18 Oct 2013 16:15:17 +0800
Message-Id: <1382084117-25599-1-git-send-email-linx.z.chen@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, cpw@sgi.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, yanmin_zhang@linux.intel.com, shuox.liu@intel.com, linx.z.chen@intel.com

From: Chen LinX <linx.z.chen@intel.com>

When walk_page_range walk a memory map's page tables, it'll skip VM_PFNMAP area,
then variable 'next' will to assign to vma->vm_end, it maybe larger than 'end'.
In next loop, 'addr' will be larger than 'next'. Then in /proc/XXXX/pagemap file
reading procedure, the 'addr' will growing forever in pagemap_pte_range,
pte_to_pagemap_entry will access wrong pte.

[   93.387934] BUG: Bad page map in process procrank  pte:8437526f pmd:785de067
[   93.387936] addr:9108d000 vm_flags:00200073 anon_vma:f0d99020 mapping:  (null) index:9108d
[   93.387938] CPU: 1 PID: 4974 Comm: procrank Tainted: G    B   W  O 3.10.1+ #1
[   93.387942]  f0d983c8 f0d983c8 e8271e48 c281ef4b e8271e84 c20ee794 c2a3f150 9108d000
[   93.387946]  00200073 f0d99020 00000000 0009108d e8342d90 8437526f 0009108d 00000000
[   93.387950]  00000000 00084375 fffa4234 e8271e98 c20ef836 00000000 e8271f28 f0d983c8
[   93.387951] Call Trace:
[   93.387953]  [<c281ef4b>] dump_stack+0x16/0x18
[   93.387956]  [<c20ee794>] print_bad_pte+0x114/0x1b0
[   93.387959]  [<c20ef836>] vm_normal_page+0x56/0x60
[   93.387961]  [<c21594ba>] pagemap_pte_range+0x17a/0x1d0
[   93.387963]  [<c2159340>] ? m_next+0x70/0x70
[   93.387966]  [<c20fc60e>] walk_page_range+0x19e/0x2c0
[   93.387969]  [<c20432c4>] ? ptrace_may_access+0x24/0x40
[   93.387971]  [<c2159a4e>] pagemap_read+0x16e/0x200
[   93.387973]  [<c2159340>] ? m_next+0x70/0x70
[   93.387976]  [<c2158be0>] ? quota_send_warning+0x1f0/0x1f0
[   93.387979]  [<c2158c30>] ? pagemap_pte_hole+0x50/0x50
[   93.387981]  [<c21598e0>] ? clear_refs_pte_range+0xc0/0xc0
[   93.387984]  [<c210c534>] vfs_read+0x84/0x150
[   93.387986]  [<c21598e0>] ? clear_refs_pte_range+0xc0/0xc0
[   93.387988]  [<c210c77a>] SyS_read+0x4a/0x80
[   93.387991]  [<c28267c8>] syscall_call+0x7/0xb
[   93.387996]  [<c2820000>] ? e1000_regdump+0x6f/0x37c
[  102.866190]  [<c259fcd3>] ? cpuidle_idle_call+0x93/0x1b0
[  102.872124]  [<c28297fa>] ? atomic_notifier_call_chain+0x1a/0x20
[  102.878834]  [<c2008478>] ? arch_cpu_idle+0x8/0x20
[  102.884183]  [<c207950d>] ? cpu_startup_entry+0x4d/0x1b0
[  102.890116]  [<c280ecbd>] ? rest_init+0x5d/0x60
[  102.895174]  [<c2b989f8>] ? start_kernel+0x31b/0x321
[  102.900717]  [<c2b98512>] ? repair_env_string+0x51/0x51
[  102.906551]  [<c2b98356>] ? i386_start_kernel+0x12c/0x12f

Signed-off-by: Liu ShuoX <shuox.liu@intel.com>
Signed-off-by: Chen LinX <linx.z.chen@intel.com>
---
 mm/pagewalk.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 5da2cbc..2beeabf 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -242,7 +242,7 @@ int walk_page_range(unsigned long addr, unsigned long end,
 		if (err)
 			break;
 		pgd++;
-	} while (addr = next, addr != end);
+	} while (addr = next, addr < end);
 
 	return err;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
