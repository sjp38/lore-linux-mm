Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5EDWl1K010833
	for <linux-mm@kvack.org>; Sat, 14 Jun 2008 19:02:47 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5EDW03m802888
	for <linux-mm@kvack.org>; Sat, 14 Jun 2008 19:02:01 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5EDWjBZ019833
	for <linux-mm@kvack.org>; Sat, 14 Jun 2008 19:02:46 +0530
Message-ID: <4853C87B.7050602@linux.vnet.ibm.com>
Date: Sat, 14 Jun 2008 19:02:43 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix double unlock_page() in 2.6.26-rc5-mm3 kernel BUG
 at mm/filemap.c:575!
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <4850E1E5.90806@linux.vnet.ibm.com> <20080612015746.172c4b56.akpm@linux-foundation.org> <20080612202003.db871cac.kamezawa.hiroyu@jp.fujitsu.com> <20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>, "riel@redhat.com" <riel@redhat.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This is reproducer of panic. "quick fix" is attached.
> But I think putback_lru_page() should be re-designed.
> 
> ==
> #include <stdio.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <sys/mman.h>
> #include <unistd.h>
> #include <errno.h>
> 
> int main(int argc, char *argv[])
> {
>         int fd;
>         char *filename = argv[1];
>         char buffer[4096];
>         char *addr;
>         int len;
> 
>         fd = open(filename, O_CREAT | O_EXCL | O_RDWR, S_IRWXU);
> 
>         if (fd < 0) {
>                 perror("open");
>                 exit(1);
>         }
>         len = write(fd, buffer, sizeof(buffer));
> 
>         if (len < 0) {
>                 perror("write");
>                 exit(1);
>         }
> 
>         addr = mmap(NULL, 4096, PROT_WRITE, MAP_SHARED|MAP_LOCKED, fd, 0);
>         if (addr == MAP_FAILED) {
>                 perror("mmap");
>                 exit(1);
>         }
>         munmap(addr, 4096);
>         close(fd);
> 
>         unlink(filename);
> }
> ==
> you'll see panic.
> 
> Fix is here
> ==
Hi Kame,

Thanks, The patch fixes the kernel panic.

Tested-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
> 
> quick fix for double unlock_page();
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamewzawa.hiroyu@jp.fujitsu.com>
> Index: linux-2.6.26-rc5-mm3/mm/truncate.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/mm/truncate.c
> +++ linux-2.6.26-rc5-mm3/mm/truncate.c
> @@ -104,8 +104,8 @@ truncate_complete_page(struct address_sp
> 
>  	cancel_dirty_page(page, PAGE_CACHE_SIZE);
> 
> -	remove_from_page_cache(page);
>  	clear_page_mlock(page);
> +	remove_from_page_cache(page);
>  	ClearPageUptodate(page);
>  	ClearPageMappedToDisk(page);
>  	page_cache_release(page);	/* pagecache ref */
> 


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
