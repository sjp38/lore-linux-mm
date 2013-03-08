Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 123206B0006
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 03:50:34 -0500 (EST)
Date: Fri, 8 Mar 2013 10:53:01 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Unexpected mremap + shared anon mapping behavior
Message-ID: <20130308085301.GB4411@shutemov.name>
References: <5139A10C.3060507@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5139A10C.3060507@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Fri, Mar 08, 2013 at 12:27:56PM +0400, Pavel Emelyanov wrote:
> Hi!
> 
> I've recently noticed that the following user-space code
> 
> #define _GNU_SOURCE
> #include <stdio.h>
> #include <sys/mman.h>
> 
> #define PAGE_SIZE	(4096)
> 
> int main(void)
> {
> 	char *mem = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANON, 0, 0);
> 	mem = mremap(mem, PAGE_SIZE, 2 * PAGE_SIZE, MREMAP_MAYMOVE);
> 	mem[0] = 'a';
> 	mem[PAGE_SIZE] = 'b';
> 	return 0;
> }
> 
> generates SIGBUS on the 2nd page access. But if we change MAP_SHARED into MAP_PRIVATE
> in the mmap() call, it starts working OK.
> 
> This happens because when doing a MAP_SHARED | MAP_ANON area, the kernel sets up a shmem
> file for the mapping, but the subsequent mremap() doesn't grow it. Thus a page-fault into
> the 2nd page happens to be beyond this file i_size, resulting in SIGBUS.
> 
> So, the question is -- what should the mremap() behavior be for shared anonymous mappings?
> Should it truncate the file to match the grown-up vma length? If yes, should it also 
> truncate it if we mremap() the mapping to the smaller size?

I think the answer is 'no' for both cases. It's ABI change.

Should we introduce mtruncate() syscall which will truncate backing fail
in both cases? ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
