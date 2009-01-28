Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8A8096B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 05:28:56 -0500 (EST)
Received: by rv-out-0708.google.com with SMTP id f25so6509874rvb.26
        for <linux-mm@kvack.org>; Wed, 28 Jan 2009 02:28:55 -0800 (PST)
Date: Wed, 28 Jan 2009 19:28:41 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [BUG] mlocked page counter mismatch
Message-ID: <20090128102841.GA24924@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux mm <linux-mm@kvack.org>
Cc: linux kernel <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


After executing following program, 'cat /proc/meminfo' shows
following result. 

--
# cat /proc/meminfo 
..
Unevictable:           8 kB
Mlocked:               8 kB
..

-- test program --

#include <stdio.h>
#include <sys/mman.h>
int main()
{
        char buf[64] = {0,};
        char *ptr;
        int k;
        int i,j;
        int x,y;
        mlockall(MCL_CURRENT);
        sprintf(buf, "cat /proc/%d/maps", getpid());
        system(buf);
        return 0;
}

--

It seems mlocked page counter have a problem.
After I diged in source, I found that try_to_unmap_file called 
try_to_mlock_page about shared mapping pages 
since other vma had VM_LOCKED flag.
After all, try_to_mlock_page called mlock_vma_page. 
so, mlocked counter increased

But, After I called munlockall intentionally, the counter work well. 
In case of munlockall, we already had a mmap_sem about write. 
Such a case, try_to_mlock_page can't call mlock_vma_page.
so, mlocked counter didn't increased. 
As a result, the counter seems to be work well but I think 
it also have a problem.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
