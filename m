Date: Mon, 2 Oct 2000 14:07:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] fix for VM test9-pre,
In-Reply-To: <OF28EE4EE0.DBB104BA-ON8825696C.005977FC@LocalDomain>
Message-ID: <Pine.LNX.4.21.0010021400420.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Chen/Almaden/IBM <ying@almaden.ibm.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Ying Chen/Almaden/IBM wrote:

> There are a couple strange behavior I saw with this vm patch on
> my box. I ran Linux test9-pre7 with the newest vmpatch in on a
> Dell PowerEdge with 2 GB memory.
> 
> This patch seems to make interactive applications run with very very long
> response times when memory is short space.

> Example 1: If I do mke2fs on a 90GB file system, after halfway
> through making the file system, the lower 1GB is filled up. mkfs
> takes practically for ever to finish. I checked the sysrq-m
> output, DMA has only 512K buffer, NORMAL has 1020K, HIGHMEM has
> 1 GB. When this happens, I basically cannot do anything, not
> even ls, df, top, etc. They all take for ever to run. If I kill
> mkfs, (closing the telnet sessions that mkfs was in) things
> starts to come back alive. It almost feels like something got
> stuck somewhere.

> Eample 2: I ran SPEC SFS tests to stress the Linux box. During
> the tests, the lower memory will be filled up with inode cache
> and dcache entries, while HIGHMEM is not quite used at all. Once
> this happens, again, any interactive commands would take forever
> to finish... Eventually, SPEC SFS would timeout and fail.
> Sometimes, if I managed to kill some processes, I can
> temporarilly get some other applications run. But most of the
> applications would get stuch somewhere very quickly later on.
> 
> I don't see such behavior in test6 though.
> Any ideas?

This is a balancing issue. Since you have 1GB of free memory,
the system tries to use that memory.

However, I have no idea why your buffers and pagecache pages
aren't bounced into the HIGHMEM zone ... They /should/ just
be moved to the HIGHMEM zone where they don't bother the rest
of the system, but for some reason it looks like that doesn't
work right on your system ...

Andrea, Ingo?  Do you have any idea what could be going wrong
here ?

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
