From: Neil Brown <neilb@suse.de>
Date: Tue, 29 May 2007 16:29:46 +1000
Message-ID: <18011.51290.257450.26100@notabene.brown>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH/RFC] Is it OK for 'read' to return nuls for a file
   that never had nuls in it?
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Peter Linich <plinich@cse.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

[resending with correct To address - please reply to this one]

It appears that there is a race when reading from a file that is
concurrently being truncated.  It is possible to read a number of
bytes that matches the size of the file before the truncate, but the
actual bytes are all nuls - values that had never been in the file.

Below is a simple C program to demonstrate this, and a patch that
might fix it (initial testing is positive, but it might just make the
window smaller).
To trial the program run two instances, naming the same file as the
only argument.  Every '!' indicates a read that found a nul.  I get
one every few minutes.
e.g.  cc -o race race.c ; ./race /tmp/testfile & ./race /tmp/tracefile

My exploration suggests the problem is in do_generic_mapping_read in
mm/filemap.c. 
This code:
   gets the size of the file
   triggers readahead
   gets the appropriate page
   If the page is up-to-date, return data.

If a truncate happens just before readahead is triggered, then
the size will be the pre-truncate size of the file, while the page
could have been read by the readahead and so will be up-to-date and
full of nuls.

Note that if do_generic_mapping_read calls readpage explicitly, it
samples the value of inode->i_size again after the read.  However if
the readpage is called by the readahead code, i_size is not
re-sampled.

I am not 100% confident of every aspect of this explanation (I haven't
traced all the way through the read-ahead code) but it seems to fit
the available data including the fact that if I disable read-ahead
(blockdev --setra 0) then the apparent problem goes away.

The patch below moves the code for re-sampling i_size from after the
readpage call to before the "actor" call.

Questions:
  - Is this a problem, and should it be fixed (I think "yes").
  - Is the patch appropriate, and does it have no negative
    consequences?.
    (Obviously some comments should be tidied up to reflect the new
    reality).

Thanks,
NeilBrown

------------------------------------------------------------
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	char buf1[4096];
	char buf2[4096];
	int i;

	for (i=0; i<4096; i++) buf1[i] = 'x';

	while(1) {
		int fd = open(argv[1], O_WRONLY|O_CREAT|O_TRUNC, 0600);
		int n;
		if (fd < 0) {
			perror("open-write");
			exit(1);
		}
		if (write(fd, buf1, 4096) != 4096) {
			perror("write1");
			exit(1);
		}
		close(fd);
		fd = open(argv[1], O_RDONLY, 0600);
		if (fd < 0) {
			perror("open-read");
			exit(1);
		}
		n = read(fd, buf2, 4096);
		if (n == 0) {
			// printf(".");
			fflush(stdout);
			close(fd);
			continue;
		}
		if (n != 4096) {
			perror("read1");
			exit(1);
		}
		if (buf2[0] == 0) {
			printf("!");
			fflush(stdout);
		}
		close(fd);
	}
}

---------------------------------------------------------
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./mm/filemap.c |   35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

diff .prev/mm/filemap.c ./mm/filemap.c
--- .prev/mm/filemap.c	2007-05-29 09:41:06.000000000 +1000
+++ ./mm/filemap.c	2007-05-29 12:06:03.000000000 +1000
@@ -930,6 +930,24 @@ find_page:
 			goto page_not_up_to_date;
 page_ok:
 
+		isize = i_size_read(inode);
+		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		if (unlikely(!isize || index > end_index)) {
+			page_cache_release(page);
+			goto out;
+		}
+
+		/* nr is the maximum number of bytes to copy from this page */
+		nr = PAGE_CACHE_SIZE;
+		if (index == end_index) {
+			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			if (nr <= offset) {
+				page_cache_release(page);
+				goto out;
+			}
+		}
+		nr = nr - offset;
+
 		/* If users can be writing to this page using arbitrary
 		 * virtual addresses, take care about potential aliasing
 		 * before reading the page on the kernel side.
@@ -1023,23 +1041,6 @@ readpage:
 		 * part of the page is not copied back to userspace (unless
 		 * another truncate extends the file - this is desired though).
 		 */
-		isize = i_size_read(inode);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
-		if (unlikely(!isize || index > end_index)) {
-			page_cache_release(page);
-			goto out;
-		}
-
-		/* nr is the maximum number of bytes to copy from this page */
-		nr = PAGE_CACHE_SIZE;
-		if (index == end_index) {
-			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
-			if (nr <= offset) {
-				page_cache_release(page);
-				goto out;
-			}
-		}
-		nr = nr - offset;
 		goto page_ok;
 
 readpage_error:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
