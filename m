Date: Tue, 8 Feb 2000 10:04:06 -0500 (EST)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: maximum memory limit
In-Reply-To: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.10.10002080952000.24049-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Problem is that libc malloc() appears to use brk() only, so

modern libc's certainly use mmap for large mallocs.  but this can be a 
serious problem: I corresponded with someone who had a binary app that 
did many small mallocs, and he was pissed that his 4G box could only malloc
900M or so.  this happened because __PAGE_OFFSET and TASK_SIZE were 3G, 
but TASK_UNMAPPED_BASE, where mmap's start, is TASK_SIZE/3.

a hackish solution that worked was TASK_UNMAPPED_BASE=TASK_SIZE-0x20000000,
which just assumes that you won't need >512M of mmaped areas.

since the heap grows up and the stack is generally small and limited,
it would be nice to arrange for mmaped areas to grow down.
as far as I can tell, we could just sort vmlist in descending order.  

would there be some problem with doing this?

regards, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
