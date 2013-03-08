Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 9F1B66B0035
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 03:28:02 -0500 (EST)
Message-ID: <5139A10C.3060507@parallels.com>
Date: Fri, 08 Mar 2013 12:27:56 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Unexpected mremap + shared anon mapping behavior
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

Hi!

I've recently noticed that the following user-space code

#define _GNU_SOURCE
#include <stdio.h>
#include <sys/mman.h>

#define PAGE_SIZE	(4096)

int main(void)
{
	char *mem = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANON, 0, 0);
	mem = mremap(mem, PAGE_SIZE, 2 * PAGE_SIZE, MREMAP_MAYMOVE);
	mem[0] = 'a';
	mem[PAGE_SIZE] = 'b';
	return 0;
}

generates SIGBUS on the 2nd page access. But if we change MAP_SHARED into MAP_PRIVATE
in the mmap() call, it starts working OK.

This happens because when doing a MAP_SHARED | MAP_ANON area, the kernel sets up a shmem
file for the mapping, but the subsequent mremap() doesn't grow it. Thus a page-fault into
the 2nd page happens to be beyond this file i_size, resulting in SIGBUS.

So, the question is -- what should the mremap() behavior be for shared anonymous mappings?
Should it truncate the file to match the grown-up vma length? If yes, should it also 
truncate it if we mremap() the mapping to the smaller size?


I also have to note, that before the /proc/PID/map_files/ directory appeared in Linux it
was impossible to fix this behavior from the application side. Now app can (yes, it's a 
hack) open the respective shmem file via this dir and manually truncate one. It does help.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
