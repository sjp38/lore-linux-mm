Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 344BA8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 08:25:40 -0500 (EST)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: [PATCHv2] procfs: fix /proc/<pid>/maps heap check
Date: Fri,  4 Mar 2011 15:23:14 +0200
Message-Id: <1299244994-5284-1-git-send-email-aaro.koskinen@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
Cc: stable@kernel.org, Aaro Koskinen <aaro.koskinen@nokia.com>

The current code fails to print the "[heap]" marking if the heap is
splitted into multiple mappings.

Fix the check so that the marking is displayed in all possible cases:
	1. vma matches exactly the heap
	2. the heap vma is merged e.g. with bss
	3. the heap vma is splitted e.g. due to locked pages

Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: stable@kernel.org
---

v2: Rewrote the changelog.

Test cases. In all cases, the process should have mapping(s) with
[heap] marking:

	(1) vma matches exactly the heap

	#include <stdio.h>
	#include <unistd.h>
	#include <sys/types.h>

	int main (void)
	{
		if (sbrk(4096) != (void *)-1) {
			printf("check /proc/%d/maps\n", (int)getpid());
			while (1)
				sleep(1);
		}
		return 0;
	}

	# ./test1 
	check /proc/553/maps
	[1] + Stopped                    ./test1
	# cat /proc/553/maps | head -4
	00008000-00009000 r-xp 00000000 01:00 3113640    /test1
	00010000-00011000 rw-p 00000000 01:00 3113640    /test1
	00011000-00012000 rw-p 00000000 00:00 0          [heap]
	4006f000-40070000 rw-p 00000000 00:00 0 

	(2) the heap vma is merged

	#include <stdio.h>
	#include <unistd.h>
	#include <sys/types.h>

	char foo[4096] = "foo";
	char bar[4096];
	
	int main (void)
	{
		if (sbrk(4096) != (void *)-1) {
			printf("check /proc/%d/maps\n", (int)getpid());
			while (1)
				sleep(1);
		}
		return 0;
	}

	# ./test2
	check /proc/556/maps
	[2] + Stopped                    ./test2
	# cat /proc/556/maps | head -4
	00008000-00009000 r-xp 00000000 01:00 3116312    /test2
	00010000-00012000 rw-p 00000000 01:00 3116312    /test2
	00012000-00014000 rw-p 00000000 00:00 0          [heap]
	4004a000-4004b000 rw-p 00000000 00:00 0 

	(3) the heap vma is splitted (this fails without the patch)

	#include <stdio.h>
	#include <unistd.h>
	#include <sys/mman.h>
	#include <sys/types.h>

	int main (void)
	{
		if ((sbrk(4096) != (void *)-1) && !mlockall(MCL_FUTURE) &&
		    (sbrk(4096) != (void *)-1)) {
			printf("check /proc/%d/maps\n", (int)getpid());
			while (1)
				sleep(1);
		}
		return 0;
	}

	# ./test3 
	check /proc/559/maps
	[1] + Stopped                    ./test3
	# cat /proc/559/maps|head -4 
	00008000-00009000 r-xp 00000000 01:00 3119108    /test3
	00010000-00011000 rw-p 00000000 01:00 3119108    /test3
	00011000-00012000 rw-p 00000000 00:00 0          [heap]
	00012000-00013000 rw-p 00000000 00:00 0          [heap]

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
