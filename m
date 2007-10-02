Date: Wed, 3 Oct 2007 00:57:06 +0200
From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: [PATCH] Handle errors in sync_sb_inodes()
Message-ID: <20071003005706.0fbacb94@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello,

Currently it is possible for some errors to be detected at write-back
time but not reported to the program as shown by the following script
using the included make_file.c.

---------8<---------8<---------8<---------8<---------8<---------8<---------

#!/bin/sh

# We binary search the size of a file in 40M filesystem that can cause
# the missed error.
MIN=5000000
MAX=50000000

rm fs.40M
dd if=/dev/zero of=fs.40M bs=40M count=0 seek=1 status=noxfer
mkfs.ext2 -F fs.40M
#mkfs.ext3 -F fs.40M
#mkfs.jfs -q fs.40M
#mkfs.reiserfs -fq fs.40M
#mkfs.xfs fs.40M

attempt()
{
	SIZE=$1
	RES=0
	./make_file valid_file $SIZE

	mount fs.40M /mnt -o loop
	if ! ./make_file /mnt/not_enough_space $SIZE; then
		# We could not create the file as the requested size
		# was clearly too big
		RES=1
	fi
	umount /mnt

	if [ $RES -eq 0 ]; then
		mount fs.40M /mnt -o loop
		if cmp valid_file /mnt/not_enough_space; then
			# The file was too small, it fitted in the filesystem
			RES=-1
		fi
		umount /mnt
	fi

	if [ $RES -eq 0 ]; then
		echo "Undetected ENOSPC with SIZE=$SIZE"
		exit
	fi

	return $RES
}

while [ $((MAX - MIN)) -gt 1 ]; do
	SIZE=$(((MIN + MAX) / 2))
	attempt $SIZE
	RES=$?
	if [ $RES -eq 1 ]; then
		MAX=$SIZE
	else
		MIN=$SIZE
	fi
done

echo "Could not reproduce the problem"

---------8<---------8<---------8<---------8<---------8<---------8<---------
/* make_file.c */

#include <unistd.h>
#include <sys/fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	int size, fd;
	char *mapping;

	if (argc != 3) {
		fprintf(stderr, "Usage: %s FILE SIZE\n", argv[0]);
		return 1;
	}

	size = atoi(argv[2]);

	fd = open(argv[1], O_RDWR | O_CREAT, 0600);
	if (fd < 0) {
		perror(argv[1]);
		return 1;
	}
	if (ftruncate(fd, size) < 0) {
		perror("ftruncate");
		return 1;
	}
	mapping = mmap(NULL, size, PROT_WRITE, MAP_SHARED, fd, 0);
	if (mapping == MAP_FAILED) {
		perror("mmap");
		return 1;
	}
	memset(mapping, 0xFF, size);

	sync();

	if (msync(mapping, size, MS_SYNC) < 0) {
		perror("msync");
		return 1;
	}

	if (close(fd) < 0) {
		perror("close");
		return 1;
	}
	printf("%s: successfully written %d bytes\n", argv[1], size);
	return 0;
}

---------8<---------8<---------8<---------8<---------8<---------8<---------

make_file.c mmaps a hole, performs some writeback (memset + sync) and
then expects to find some error code in msync(). The script mounts a
40M loopback filesystem and does a binary search to find the size of
a file big enough to provoke a ENOSPC, but small enough to show the
error not being detected at msync() time.

All mmap capable filesystems I tested are affected (ext2, ext3,
jfs, reiserfs, xfs). XFS is special in that it survives the test thanks
to the page_mkwrite() work, i.e. it SIGBUS during memset. Anyway, this
behavious solves ENOSPC but does nothing for EIO.

The offending code is in fs/fs-writeback.c:

sync_sb_inodes(...) ()
{
	...
	__writeback_single_inode(inode, wbc);
	...
}

__writeback_single_inode() gets the error from mapping->flags, clears it
and returns it. But sync_sb_inodes() ignores this return value. In -mm
there is sync_sb_inodes-propagate-errors.patch that propagates the
error from __writeback_single_inode upwards in the call stack. IMHO,
this propagation is useless because:

- the error is combined from the errors in all the synced inodes, so it
just tells that some inode in a specific fs got an error,
- nobody in the call stack is interested in this error: certainly not
pdflush, or 'void sync(2)'.

OTOH, msync() would be interested in finding this error in
mapping->flags, so the patch I proposed in
http://lkml.org/lkml/2006/12/29/136 did:

	ret = __writeback_single_inode(inode, wbc);
	mapping_set_error(mapping, ret);

But Andrew didn't like it, treating me as a conventional
programmer ;-), hence the detailed explanation to be sure my point
comes across.

With this patch, I think it's important to keep the return values of
sync_sb_inodes() and friends as void, to recall that the errors are
not to be found in the return value but in mapping->flags. That's why
I'd like to see sync_sb_inodes-propagate-errors.patch dropped. Removing
this patch causes some churn in -mm but I can prepare patches to fix
this up if needed.

Thanks for reading my moaning for such a ridiculous diffstat ;-)

Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>
---

 fs/fs-writeback.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 16296c7..c44c42f 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -441,6 +441,7 @@ void generic_sync_sb_inodes(struct super_block *sb,
 		struct address_space *mapping = inode->i_mapping;
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		long pages_skipped;
+		int err;
 
 		if (!bdi_cap_writeback_dirty(bdi)) {
 			redirty_tail(inode);
@@ -492,7 +493,8 @@ void generic_sync_sb_inodes(struct super_block *sb,
 		BUG_ON(inode->i_state & I_FREEING);
 		__iget(inode);
 		pages_skipped = wbc->pages_skipped;
-		__writeback_single_inode(inode, wbc);
+		err = __writeback_single_inode(inode, wbc);
+		mapping_set_error(mapping, ret);
 		if (wbc->sync_mode == WB_SYNC_HOLD) {
 			check_dirty_inode(inode);
 			inode->dirtied_when = jiffies;


-- 
Guillaume

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
