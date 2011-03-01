Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 03B0D8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 11:25:04 -0500 (EST)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: [PATCH] procfs: fix /proc/<pid>/maps heap check
Date: Tue,  1 Mar 2011 18:26:53 +0200
Message-Id: <1298996813-8625-1-git-send-email-aaro.koskinen@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>, stable@kernel.org

The current check looks wrong and prints "[heap]" only if the mapping
matches exactly the heap. However, the heap may be merged with some
other mappings, and there may be also be multiple mappings.

Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: stable@kernel.org
---
 fs/proc/task_mmu.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 60b9148..f269ee6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -249,8 +249,8 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 		const char *name = arch_vma_name(vma);
 		if (!name) {
 			if (mm) {
-				if (vma->vm_start <= mm->start_brk &&
-						vma->vm_end >= mm->brk) {
+				if (vma->vm_start <= mm->brk &&
+						vma->vm_end >= mm->start_brk) {
 					name = "[heap]";
 				} else if (vma->vm_start <= mm->start_stack &&
 					   vma->vm_end >= mm->start_stack) {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
