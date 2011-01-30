Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E21E8D0039
	for <linux-mm@kvack.org>; Sun, 30 Jan 2011 02:15:56 -0500 (EST)
From: Tao Ma <tm@tao.ma>
Subject: [PATCH] mlock: revert the optimization for dirtying pages and triggering writeback.
Date: Sun, 30 Jan 2011 15:15:20 +0800
Message-Id: <1296371720-4176-1-git-send-email-tm@tao.ma>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Tao Ma <boyu.mt@taobao.com>

In 5ecfda0, we do some optimization in mlock, but it causes
a very basic test case(attached below) of mlock to fail. So
this patch revert it with some tiny modification so that it
apply successfully with the lastest 38-rc2 kernel.
The test program is attached below.

#include <sys/mman.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>

int main()
{
	char *buf, *testfile = "test_mmap";
	int fd, file_len = 40960, ret = -1;

	fd = open(testfile, O_RDWR);
	if (fd < 0) {
		perror("open");
		return -1;
	}

	if (ftruncate(fd, file_len) < 0) {
		perror("ftruncate");
		goto out;
	}

	buf = mmap(NULL, file_len, PROT_WRITE, MAP_SHARED, fd, 0);
	if (buf == MAP_FAILED) {
		perror("mmap");
		goto out;
	}

	if (mlock(buf, file_len) < 0) {
		perror("mlock");
		goto out;
	}

	munlock(buf, file_len);
	munmap(buf, file_len);
	ret = 0;
out:
	close(fd);
	return ret;
}

Cc: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Tao Ma <boyu.mt@taobao.com>
---
 mm/mlock.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 13e81ee..76e106c 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -170,12 +170,8 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
 	gup_flags = FOLL_TOUCH;
-	/*
-	 * We want to touch writable mappings with a write fault in order
-	 * to break COW, except for shared mappings because these don't COW
-	 * and we would not want to dirty them for nothing.
-	 */
-	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+
+	if (vma->vm_flags & VM_WRITE)
 		gup_flags |= FOLL_WRITE;
 
 	if (vma->vm_flags & VM_LOCKED)
-- 
1.6.3.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
