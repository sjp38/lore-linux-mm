Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 975E86B0006
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 22:54:28 -0400 (EDT)
Received: by mail-ia0-f182.google.com with SMTP id b35so2605135iac.41
        for <linux-mm@kvack.org>; Mon, 11 Mar 2013 19:54:28 -0700 (PDT)
Date: Mon, 11 Mar 2013 19:53:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Unexpected mremap + shared anon mapping behavior
In-Reply-To: <5139A10C.3060507@parallels.com>
Message-ID: <alpine.LNX.2.00.1303111928360.2460@eggly.anvils>
References: <5139A10C.3060507@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linux MM <linux-mm@kvack.org>

On Fri, 8 Mar 2013, Pavel Emelyanov wrote:

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
> Should it truncate the file to match the grown-up vma length?

I have mixed feelings.  Here's a link to the discussion around 2.6.7 -
when I had more to say than I do these days!

https://lkml.org/lkml/2004/6/16/155

I feel much the same as before; but tend more against since I developed
a dislike for the way object size and mapping size get muddled up in
hugetlbfs, which has been troublesome.  I'm probably over cautious;
but if it only poses a problem once in 9 years, maybe it's not worth
messing about with.

> If yes, should it also 
> truncate it if we mremap() the mapping to the smaller size?

No to that.  I'm amused to see Kirill lightheartedly proposing
an mtruncate(): I see I suggested the same in that thread above.

But nowadays I do sometimes think it would be useful to have an mopen():
give me a file descriptor for the file backing this area of memory (and
perhaps one day some interesting extension to anonymous memory); that
perhaps we could use to get around some of the awkwardness of SysV SHM.

> 
> I also have to note, that before the /proc/PID/map_files/ directory appeared in Linux it
> was impossible to fix this behavior from the application side. Now app can (yes, it's a 
> hack) open the respective shmem file via this dir and manually truncate one. It does help.

Wow, that's interesting: so you're well ahead of me.
Perverted, and a little worrying, but interesting - I applaud you!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
