Message-ID: <48BE9AAB.9070303@kernel.org>
Date: Wed, 03 Sep 2008 16:09:47 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: [PATCH #2.6.27-rc5] mmap: fix petty bug in anonymous shared mmap
 offset handling
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Anonymous mappings should ignore offset but shared anonymous mapping
forgot to clear it and makes the following legit test program trigger
SIGBUS.

 #include <sys/mman.h>
 #include <stdio.h>
 #include <errno.h>

 #define PAGE_SIZE	4096

 int main(void)
 {
	 char *p;
	 int i;

	 p = mmap(NULL, 2 * PAGE_SIZE, PROT_READ|PROT_WRITE,
		  MAP_SHARED|MAP_ANONYMOUS, -1, PAGE_SIZE);
	 if (p == MAP_FAILED) {
		 perror("mmap");
		 return 1;
	 }

	 for (i = 0; i < 2; i++) {
		 printf("page %d\n", i);
		 p[i * 4096] = i;
	 }
	 return 0;
 }

Fix it.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 mm/mmap.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 339cf5c..e7a5a68 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1030,6 +1030,10 @@ unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
 	} else {
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:
+			/*
+			 * Ignore pgoff.
+			 */
+			pgoff = 0;
 			vm_flags |= VM_SHARED | VM_MAYSHARE;
 			break;
 		case MAP_PRIVATE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
