Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1B38E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:12:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so10975839pgb.10
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:12:11 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f18si13139318pgl.457.2018.12.11.16.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 16:12:10 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 3/4] bpf: switch to new vmalloc vfree flags
Date: Tue, 11 Dec 2018 16:03:53 -0800
Message-Id: <20181212000354.31955-4-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, namit@vmware.com, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This switches to use the new vmalloc flags to control freeing memory with
special permissions.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/filter.h | 26 ++++++++++++--------------
 kernel/bpf/core.c      |  1 -
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 795ff0b869bb..2aeb93d3337d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -20,6 +20,7 @@
 #include <linux/set_memory.h>
 #include <linux/kallsyms.h>
 #include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
 
 #include <net/sch_generic.h>
 
@@ -487,7 +488,6 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				jit_requested:1,/* archs need to JIT the prog */
-				undo_set_mem:1,	/* Passed set_memory_ro() checkpoint */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -699,24 +699,23 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
-	fp->undo_set_mem = 1;
-	set_memory_ro((unsigned long)fp, fp->pages);
-}
+	struct vm_struct *vm = find_vm_area(fp);
 
-static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
-{
-	if (fp->undo_set_mem)
-		set_memory_rw((unsigned long)fp, fp->pages);
+	if (vm)
+		vm->flags |= VM_HAS_SPECIAL_PERMS;
+	set_memory_ro((unsigned long)fp, fp->pages);
 }
 
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
-	set_memory_ro((unsigned long)hdr, hdr->pages);
-}
+	struct vm_struct *vm = find_vm_area(hdr);
 
-static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
-{
-	set_memory_rw((unsigned long)hdr, hdr->pages);
+	if (vm) {
+		vm->flags |= VM_HAS_SPECIAL_PERMS;
+		vm->flags |= VM_IMMEDIATE_UNMAP;
+	}
+
+	set_memory_ro((unsigned long)hdr, hdr->pages);
 }
 
 static inline struct bpf_binary_header *
@@ -746,7 +745,6 @@ void __bpf_prog_free(struct bpf_prog *fp);
 
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
-	bpf_prog_unlock_ro(fp);
 	__bpf_prog_free(fp);
 }
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index b1a3545d0ec8..bd3efd7ce526 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -663,7 +663,6 @@ void __weak bpf_jit_free(struct bpf_prog *fp)
 	if (fp->jited) {
 		struct bpf_binary_header *hdr = bpf_jit_binary_hdr(fp);
 
-		bpf_jit_binary_unlock_ro(hdr);
 		bpf_jit_binary_free(hdr);
 
 		WARN_ON_ONCE(!bpf_prog_kallsyms_verify_off(fp));
-- 
2.17.1
