Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E67286B0039
	for <linux-mm@kvack.org>; Mon, 19 May 2014 18:58:44 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so6461940pad.11
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:58:44 -0700 (PDT)
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
        by mx.google.com with ESMTPS id hi6si21407969pac.69.2014.05.19.15.58.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 15:58:44 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so6400352pab.36
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:58:43 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH 2/4] mm,fs: Add vm_ops->name as an alternative to arch_vma_name
Date: Mon, 19 May 2014 15:58:32 -0700
Message-Id: <2eee21791bb36a0a408c5c2bdb382a9e6a41ca4a.1400538962.git.luto@amacapital.net>
In-Reply-To: <cover.1400538962.git.luto@amacapital.net>
References: <cover.1400538962.git.luto@amacapital.net>
In-Reply-To: <cover.1400538962.git.luto@amacapital.net>
References: <cover.1400538962.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>

arch_vma_name sucks.  It's a silly hack, and it's annoying to
implement correctly.  In fact, AFAICS, even the straightforward x86
implementation is incorrect (I suspect that it breaks if the vdso
mapping is split or gets remapped).

This adds a new vm_ops->name operation that can replace it.  The
followup patches will remove all uses of arch_vma_name on x86,
fixing a couple of annoyances in the process.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 fs/binfmt_elf.c    | 8 ++++++++
 fs/proc/task_mmu.c | 6 ++++++
 include/linux/mm.h | 6 ++++++
 3 files changed, 20 insertions(+)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index aa3cb62..df9ea41 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1108,6 +1108,14 @@ static bool always_dump_vma(struct vm_area_struct *vma)
 	/* Any vsyscall mappings? */
 	if (vma == get_gate_vma(vma->vm_mm))
 		return true;
+
+	/*
+	 * Assume that all vmas with a .name op should always be dumped.
+	 * If this changes, a new vm_ops field can easily be added.
+	 */
+	if (vma->vm_ops && vma->vm_ops->name && vma->vm_ops->name(vma))
+		return true;
+
 	/*
 	 * arch_vma_name() returns non-NULL for special architecture mappings,
 	 * such as vDSO sections.
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 442177b..9b2f5d6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -300,6 +300,12 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 		goto done;
 	}
 
+	if (vma->vm_ops && vma->vm_ops->name) {
+		name = vma->vm_ops->name(vma);
+		if (name)
+			goto done;
+	}
+
 	name = arch_vma_name(vma);
 	if (!name) {
 		pid_t tid;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf9811e..63f8d4e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -239,6 +239,12 @@ struct vm_operations_struct {
 	 */
 	int (*access)(struct vm_area_struct *vma, unsigned long addr,
 		      void *buf, int len, int write);
+
+	/* Called by the /proc/PID/maps code to ask the vma whether it
+	 * has a special name.  Returning non-NULL will also cause this
+	 * vma to be dumped unconditionally. */
+	const char *(*name)(struct vm_area_struct *vma);
+
 #ifdef CONFIG_NUMA
 	/*
 	 * set_policy() op must add a reference to any non-NULL @new mempolicy
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
