Date: Mon, 2 Oct 2000 16:35:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [highmem bug report against -test5 and -test6] Re: [PATCH] Re: simple
 FS application that hangs 2.4-test5, mem mgmt problem or FS buffer cache
 mgmt problem? (fwd)
Message-ID: <Pine.LNX.4.21.0010021630500.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

as you can see below, the highmem bug was already there before
the new VM. However, it may be easier to trigger in the new VM
because we keep the buffer heads on active pages in memory...

(then again, we can't clear the buffer heads on dirty pages
anyway, so maybe the difference in how easy it is to trigger is
very small or nonexistant)


One possible explanation for the problem may be that we use
GFP_ATOMIC (and PF_MEMALLOC is set) in prepare_highmem_swapout().

That means we /could/ eat up the last free pages for creating
bounce buffers in low memory, after which we end up with a bunch
of unflushable, unfreeable pages in low memory (because we can't
allocate bufferheads or read indirect blocks from the swapfile).

Maybe we want to use GFP_SOFT (fail if we have less than pages_min
free pages in the low memory zone) for prepare_highmem_swapout(),
it appears that try_to_swap_out() and shm_swap_core() are already
quite capable of dealing with bounce buffer create failures.

I'd really like to see this bug properly fixed in 2.4...

regards,

Rik
---------- Forwarded message ----------
Date: Fri, 1 Sep 2000 09:27:58 -0700
From: Ying Chen/Almaden/IBM <ying@almaden.ibm.com>
To: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Re: simple FS application that hangs 2.4-test5,
     mem mgmt problem or FS buffer cache mgmt problem?


Hi, Rik,

I while back I reported some problems with buffer cache and probably memory
mgmt subsystem when I ran high IOPS with SPEC SFS.
I haven't got a chance to go back to the problem and dig out where the
problem is yet.
I recently tried the same thing, i.e., running large IOPS SPEC SFS, against
the test6 up kernel. I had no problem if I don't turn HIGHMEM
support on in the kernel. As soon as I turned HIGHMEM support on (I have
2GB memory in my system), I ran into the same problem, i.e., I'd get "Out
of memory" sort of thing from various subsystems, like SCSI or IP, and
eventually my kernel hangs. I don't know if this rings some bell to you or
not. I'll try to locate the problem more accurately in the next few days.
If you get have any suggestions on how I might pursu this, let me know.
Thanks a lot!


Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
