Date: Fri, 13 Jun 2008 10:44:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix double unlock_page() in 2.6.26-rc5-mm3 kernel BUG at
 mm/filemap.c:575!
Message-Id: <20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080612202003.db871cac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<4850E1E5.90806@linux.vnet.ibm.com>
	<20080612015746.172c4b56.akpm@linux-foundation.org>
	<20080612202003.db871cac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>, "riel@redhat.com" <riel@redhat.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

This is reproducer of panic. "quick fix" is attached.
But I think putback_lru_page() should be re-designed.

==
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>

int main(int argc, char *argv[])
{
        int fd;
        char *filename = argv[1];
        char buffer[4096];
        char *addr;
        int len;

        fd = open(filename, O_CREAT | O_EXCL | O_RDWR, S_IRWXU);

        if (fd < 0) {
                perror("open");
                exit(1);
        }
        len = write(fd, buffer, sizeof(buffer));

        if (len < 0) {
                perror("write");
                exit(1);
        }

        addr = mmap(NULL, 4096, PROT_WRITE, MAP_SHARED|MAP_LOCKED, fd, 0);
        if (addr == MAP_FAILED) {
                perror("mmap");
                exit(1);
        }
        munmap(addr, 4096);
        close(fd);

        unlink(filename);
}
==
you'll see panic.

Fix is here
==

quick fix for double unlock_page();

Signed-off-by: KAMEZAWA Hiroyuki <kamewzawa.hiroyu@jp.fujitsu.com>
Index: linux-2.6.26-rc5-mm3/mm/truncate.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/mm/truncate.c
+++ linux-2.6.26-rc5-mm3/mm/truncate.c
@@ -104,8 +104,8 @@ truncate_complete_page(struct address_sp
 
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
-	remove_from_page_cache(page);
 	clear_page_mlock(page);
+	remove_from_page_cache(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
