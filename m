From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004261743.KAA16088@google.engr.sgi.com>
Subject: Re: 2.3.x mem balancing
Date: Wed, 26 Apr 2000 10:43:30 -0700 (PDT)
In-Reply-To: <852568CD.0057D4FC.00@raylex-gh01.eo.ray.com> from "Mark_H_Johnson.RTS@raytheon.com" at Apr 26, 2000 11:03:58 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, riel@nl.linux.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> In the context of "memory balancing" - all processors and all memory is NOT
> equal in a NUMA system. To get the best performance from the hardware, you
> prefer to put "all" of the memory for each process into a single memory unit -
> then run that process from a processor "near" that memory unit. This seemingly
> simple principle has a lot of problems behind it. What about...
>  - shared read only memory (e.g., libraries) [to clone or not?]
>  - shared read/write memory [how to schedule work to be done when load >> "local
> capacity"]
>  - when memory is low, which pages should I remove?
>  - when I start a new job, even when there is lots of free memory, where should
> I load the job?

The problem is, every app has different requirements, and performs best under
different resource (cpu/memory) scheduling policies. IRIX provides a tool 
called "dplace", that will allow performance experts specify which threads
of a program should be run on cpus on which node, and how different sections
of the address space should have their pages allocated (that is, on which 
nodes; possible policies: firsttouch, ie, allocate the page on the node 
which has the processor that first accesses that page, roundrobin, ie, 
round robin the allocations across all nodes, etc etc). 

Linux is a little away from providing such flexible options, specially
since it is not even possible to pin a process to a cpu or node yet. 
The page allocation strategies are of course much more work to implement.

For global issues like "when memory is low, which pages should I remove"
the problem is a little more complex. Having a kswapd per node is an option,
although I think it is too early to decide that. I am hoping we can get
a multinode system up soon, and investigate these issues.

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
