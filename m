Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
From: Andi Kleen <ak@muc.de>
Date: Sat, 12 Feb 2005 12:17:25 +0100
In-Reply-To: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com> (Ray
 Bryant's message of "Fri, 11 Feb 2005 19:25:36 -0800 (PST)")
Message-ID: <m1vf8yf2nu.fsf@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Ray Bryant <raybry@sgi.com> writes:
> set of pages associated with a particular process need to be moved.
> The kernel interface that we are proposing is the following:
>
> page_migrate(pid, va_start, va_end, count, old_nodes, new_nodes);

[Only commenting on the interface, haven't read your patches at all]

This is basically mbind() with MPOL_F_STRICT, except that it has a pid 
argument. I assume that's for the benefit of your batch scheduler.

But it's not clear to me how and why the batch scheduler should know about
virtual addresses of different processes anyways. Walking
/proc/pid/maps? That's all inherently racy when the process is doing
mmap in parallel. The only way I can think of to do this would be to
check for changes in maps after a full move and loop, but then you risk
livelock.

And you cannot also just specify va_start=0, va_end=~0UL because that
would make the node arrays grow infinitely.

Also is there a good use case why the batch scheduler should only
move individual areas in a process around, not the full process?

I think the only sane way for an external process to move another 
around is to do it for the whole process. For that you wouldn't need
most of the arguments, but just a simple move_process_vm call,
or perhaps just a file in /proc where the new node can be written to.

There may be an argument to do this for individual 
tmpfs/hugetlbfs/sysv shm segments too, but mbind() already supports
that (just map them from a different process and change the policy there)

For process use you could just do it in mbind() or perhaps
part of the process policy (move page around when touched by process). 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
