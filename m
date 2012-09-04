Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9222D6B006E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:25:11 -0400 (EDT)
From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: [PATCH] mm: fix mmap overflow checking
Date: Tue, 4 Sep 2012 17:23:00 +0800
Message-Id: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Wanlong Gao <gaowanlong@cn.fujitsu.com>

POSIX said that if the file is a regular file and the value of "off"
plus "len" exceeds the offset maximum established in the open file
description associated with fildes, mmap should return EOVERFLOW.

The following test from LTP can reproduce this bug.

	char tmpfname[256];
	void *pa = NULL;
	void *addr = NULL;
	size_t len;
	int flag;
	int fd;
	off_t off = 0;
	int prot;

	long page_size = sysconf(_SC_PAGE_SIZE);

	snprintf(tmpfname, sizeof(tmpfname), "/tmp/mmap_test_%d", getpid());
	unlink(tmpfname);
	fd = open(tmpfname, O_CREAT | O_RDWR | O_EXCL, S_IRUSR | S_IWUSR);
	if (fd == -1) {
		printf(" Error at open(): %s\n", strerror(errno));
		return 1;
	}
	unlink(tmpfname);

	flag = MAP_SHARED;
	prot = PROT_READ | PROT_WRITE;

	/* len + off > maximum offset */

	len = ULONG_MAX;
	if (len % page_size) {
		/* Lower boundary */
		len &= ~(page_size - 1);
	}

	off = ULONG_MAX;
	if (off % page_size) {
		/* Lower boundary */
		off &= ~(page_size - 1);
	}

	printf("off: %lx, len: %lx\n", (unsigned long)off, (unsigned long)len);
	pa = mmap(addr, len, prot, flag, fd, off);
	if (pa == MAP_FAILED && errno == EOVERFLOW) {
		printf("Test Pass: Error at mmap: %s\n", strerror(errno));
		return 0;
	}

	if (pa == MAP_FAILED)
		perror("Test FAIL: expect EOVERFLOW but get other error");
	else
		printf("Test FAIL : Expect EOVERFLOW but got no error\n");

	close(fd);
	munmap(pa, len);
	return 1;

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
---
 mm/mmap.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index ae18a48..5380764 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -980,6 +980,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
 	vm_flags_t vm_flags;
+	off_t off = pgoff << PAGE_SHIFT;
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1003,8 +1004,8 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		return -ENOMEM;
 
 	/* offset overflow? */
-	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
-               return -EOVERFLOW;
+	if (off + len < off)
+		return -EOVERFLOW;
 
 	/* Too many mappings? */
 	if (mm->map_count > sysctl_max_map_count)
-- 
1.7.12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
