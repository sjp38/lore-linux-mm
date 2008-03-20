Date: Thu, 20 Mar 2008 15:29:53 +0300
From: root <root@el5-64-build>
Subject: [PATCH] Fix data leak in nobh_write_end.
Message-ID: <20080320122953.GA19928@dmon-lap.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.
Current nobh_write_end() implementation ignore partial writes(copied < len)
case if page was fully mapped and simply mark page as Uptodate, which
is totally wrong because area [pos+copied, pos+len) wasn't updated explicitly
in previous write_begin call. It simply contains garbage from pagecache
and result in data leakage.
#TEST_CASE_BEGIN:
~~~~~~~~~~~~~~~~
In fact issue triggered by classical testcase
	open("/mnt/test", O_RDWR|O_CREAT|O_TRUNC, 0666) = 3
	ftruncate(3, 409600)                    = 0 
	writev(3, [{"a", 1}, {NULL, 4095}], 2)  = 1
##TESTCASE_SOURCE:
~~~~~~~~~~~~~~~~~
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/uio.h>
#include <sys/mman.h>
#include <errno.h>
int main(int argc, char **argv)
{
	int fd,  ret;
	void* p;
	struct iovec iov[2];
	fd = open(argv[1], O_RDWR|O_CREAT|O_TRUNC, 0666);
	ftruncate(fd, 409600);
	iov[0].iov_base="a";
	iov[0].iov_len=1;
	iov[1].iov_base=NULL;
	iov[1].iov_len=4096;
	ret = writev(fd, iov, sizeof(iov)/sizeof(struct iovec));
	printf("writev  = %d, err = %d\n", ret, errno);
	return 0;
}
##TESTCASE RESULT:
~~~~~~~~~~~~~~~~~~
[root@ts63 ~]# mount | grep mnt2
/dev/mapper/test on /mnt2 type ext2 (rw,nobh)
[root@ts63 ~]#  /tmp/writev /mnt2/test
writev  = 1, err = 0
[root@ts63 ~]# hexdump -C /mnt2/test

00000000  61 65 62 6f 6f 74 00 00  f0 b9 b4 59 3a 00 00 00  |aeboot.....Y:...|
00000010  20 00 00 00 00 00 00 00  21 00 00 00 00 00 00 00  | .......!.......|
00000020  df df df df df df df df  df df df df df df df df  |................|
00000030  3a 00 00 00 2a 00 00 00  21 00 00 00 00 00 00 00  |:...*...!.......|
00000040  60 c0 8c 00 00 00 00 00  40 4a 8d 00 00 00 00 00  |`.......@J......|
00000050  00 00 00 00 00 00 00 00  41 00 00 00 00 00 00 00  |........A.......|
00000060  74 69 6d 65 20 64 64 20  69 66 3d 2f 64 65 76 2f  |time dd if=/dev/|
00000070  6c 6f 6f 70 30 20 20 6f  66 3d 2f 64 65 76 2f 6e  |loop0  of=/dev/n|
skip..
00000f50  00 00 00 00 00 00 00 00  31 00 00 00 00 00 00 00  |........1.......|
00000f60  6d 6b 66 73 2e 65 78 74  33 20 2f 64 65 76 2f 76  |mkfs.ext3 /dev/v|
00000f70  7a 76 67 2f 74 65 73 74  20 2d 62 34 30 39 36 00  |zvg/test -b4096.|
00000f80  a0 fe 8c 00 00 00 00 00  21 00 00 00 00 00 00 00  |........!.......|
00000f90  23 31 32 30 35 39 35 30  34 30 34 00 3a 00 00 00  |#1205950404.:...|
00000fa0  20 00 8d 00 00 00 00 00  21 00 00 00 00 00 00 00  | .......!.......|
00000fb0  d0 cf 8c 00 00 00 00 00  10 d0 8c 00 00 00 00 00  |................|
00000fc0  00 00 00 00 00 00 00 00  41 00 00 00 00 00 00 00  |........A.......|
00000fd0  6d 6f 75 6e 74 20 2f 64  65 76 2f 76 7a 76 67 2f  |mount /dev/vzvg/|
00000fe0  74 65 73 74 20 20 2f 76  7a 20 2d 6f 20 64 61 74  |test  /vz -o dat|
00000ff0  61 3d 77 72 69 74 65 62  61 63 6b 00 00 00 00 00  |a=writeback.....|
00001000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

As you can see file's page contains garbage from pagecache instead of zeros.
#TEST_CASE_END

Attached patch:
- Add sanity check BUG_ON in order to prevent incorrect usage by caller,
  This is function invariant because page can has buffers and in no zero
  *fadata pointer at the same time.
- Always attach buffers to page is it is partial write case.
- Always switch back to generic_write_end if page has buffers.
  This is reasonable because if page already has buffer then generic_write_begin
  was called previously.

Signed-off-by: Dmitri Monakhov <dmonakhov@openvz.org>
---
 fs/buffer.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index f349f13..c234d79 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2570,14 +2570,13 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 	struct inode *inode = page->mapping->host;
 	struct buffer_head *head = fsdata;
 	struct buffer_head *bh;
+	BUG_ON(fsdata != NULL && page_has_buffers(page));
 
-	if (!PageMappedToDisk(page)) {
-		if (unlikely(copied < len) && !page_has_buffers(page))
-			attach_nobh_buffers(page, head);
-		if (page_has_buffers(page))
-			return generic_write_end(file, mapping, pos, len,
-						copied, page, fsdata);
-	}
+	if (unlikely(copied < len) && !page_has_buffers(page))
+		attach_nobh_buffers(page, head);
+	if (page_has_buffers(page))
+		return generic_write_end(file, mapping, pos, len,
+					copied, page, fsdata);
 
 	SetPageUptodate(page);
 	set_page_dirty(page);
-- 
1.5.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
