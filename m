Date: Fri, 15 Sep 2000 12:35:50 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: Running out of memory in 1 easy step
In-Reply-To: <OF197FE829.51802B4B-ON8625695B.0048CCDB@hou.us.ray.com>
Message-ID: <Pine.LNX.4.10.10009151225420.25442-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: linux-mm@kvack.org, Wichert Akkerman <wichert@cistron.nl>
List-ID: <linux-mm.kvack.org>

> I hate to ask, but where is this behavior described?  I can't find any hint

I was wrong, probably remembering something from old HPUX/etc.
maybe even thinking of libefence.

> of this behavior in the man page. I'm concerned because we would not have
> taken the "guard pages" into account when sizing our application's memory
> usage. We have a real time application where we will also lock the pages

if Linux did guard pages, they would be irrelevant unless you were 
astonishingly naive about using mmap.  glibc, for instance, will mmap
large chunks, and for them, one virtual page is irrelevant.  you'd have
to be making individual O(pagesize) mmaps for this to matter...

> into memory - running out of physical memory in this case is "very bad".

in any case, such (hypothetical on Linux) guard pages would be virtual,
not backed by physical memory.

#include <stdio.h>
#include <sys/mman.h>

char *
mmalloc(unsigned size) {
    char *p = (char*) mmap(0, 
			   size, 
			   PROT_READ|PROT_WRITE, 
			   MAP_PRIVATE|MAP_ANONYMOUS, 
			   0, 
			   0);
    if (p == MAP_FAILED)
	return 0;
    return p;
}
int
main() {
    const unsigned size = 4096;
    char *p = mmalloc(size);
    for (unsigned i=0; i<20; i++) {
	char *n = mmalloc(size);
	printf("next at %p (del %d)\n",n,n-p);
	p = n;
    }
    return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
