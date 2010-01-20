Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7DC3A6B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 03:26:15 -0500 (EST)
Date: Wed, 20 Jan 2010 16:26:10 +0800
From: anfei <anfei.zhou@gmail.com>
Subject: cache alias in mmap + write
Message-ID: <20100120082610.GA5155@desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux@arm.linux.org.uk, jamie@shareable.org
List-ID: <linux-mm.kvack.org>

Hello,

The below test case is easy to reproduce the cache alias problem on
omap2430 with the VIPT cache.  The steps as these:

$ dd if=/dev/zero of=abc bs=4k count=1
$ ./a.out               # this program
$ xxd abc | head -1     # check the result

I expect it's always 0x11111111 0x77777777 at the beginning of file
"abc",  but the result is not (run multiple times):

0x11111111 0x77777777
0x44444444 0x77777777
0x11111111 0x77777777
0x44444444 0x77777777
0x44444444 0x77777777

If I add munmap()/msync() before write(), I can see it's always as
expected (0x11111111 0x77777777).

Does Linux guarantee the coherence between write and the shared mappings
w/o the help of munmap/msync?  If not, what kind of the coherence are
ensured?  Can anyone give a clear definition?

And if I apply the below patch to write (only for the fs using this
generic function), the problem disappeared.  That's another question,
why do we only do flush for read (see flush_dcache_page in
do_generic_file_read), but not write too?

Thanks,
Anfei.

---
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(void)
{
        int fd;
        int *addr;
        int tmp;
        int val = 0x11111111;

        fd = open("abc", O_RDWR);
        addr = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
        *(addr+0) = 0x44444444;
        tmp = *(addr+0);
        *(addr+1) = 0x77777777;
        write(fd, &val, sizeof(int));
        close(fd);

        return 0;
}



diff --git a/mm/filemap.c b/mm/filemap.c
index 96ac6b0..07056fb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2196,6 +2196,9 @@ again:
 		if (unlikely(status))
 			break;
 
+		if (mapping_writably_mapped(mapping))
+			flush_dcache_page(page);
+
 		pagefault_disable();
 		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
 		pagefault_enable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
