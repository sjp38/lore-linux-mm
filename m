Date: Wed, 16 Feb 2005 07:45:50 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050216074550.313b1300.pj@sgi.com>
In-Reply-To: <20050216113047.GA8388@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com>
	<20050215165106.61fd4954.pj@sgi.com>
	<20050216015622.GB28354@lnx-holt.americas.sgi.com>
	<20050215202214.4b833bf3.pj@sgi.com>
	<20050216092011.GA6616@lnx-holt.americas.sgi.com>
	<20050216022009.7afb2e6d.pj@sgi.com>
	<20050216113047.GA8388@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: raybry@sgi.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Robin wrote:
> Until then, there is no clear win over first
> touch for their type of application.

Huh?  So what was the point of this rant? <grin>

You seem to explain why first touch is used instead of the Linux 2.6
numa placement calls mbind/mempolicy, in some third party code that
runs on multiple operating systems.

But I thought this was the page migration thread, not the placement
policy thread.

Now I am as mystified with your latest comments as I was with Andi's
discussion of using these memory policy calls.

Regardless of what mechanisms we use to guide future allocations to
their proper nodes, how best can we provide a facility to migrate
already allocated physical memory pages to other nodes?  That's the
question, or so I thought, on this thread.

To repeat myself ...

> The next concern that rises to the top for me was best expressed by Andi:
> >
> > The main reasons for that is that I don't think external
> > processes should mess with virtual addresses of another process.
> > It just feels unclean and has many drawbacks (parsing /proc/*/maps
> > needs complicated user code, racy, locking difficult).  
> > 
> > In kernel space handling full VMs is much easier and safer due to better 
> > locking facilities.
> 
> I share Andi's concerns, but I don't see what to do about this. 

Perhaps a part of the answer is that we aren't messing with (as in
"changing") the virtual addresses of other processes.  The migration
call is only reading these addresses.  What it messes with is the
_physical_ addresses ;).

Though this proposed call still seems to have some of the same drawbacks.

One of my motivations for persuing the no-array version of this call
that you loved so much was that it (my latest variant, anyway) didn't
pass any virtual address ranges in, further simplifying what crossed the
user-kernel boundary and leaving details of parsing the virtual address
layout of tasks strictly to the kernel (no need to read /proc/*/maps).

But it seems that if we are going to achieve the fairly significant
optimizations you enumerated in your example a few hours ago, we at
least have to parse the /proc/*/maps files.

Hmmm ... wait just a minute ... isn't parsing the maps files in /proc
really scanning the virtual addresses of tasks.  In your example of a
few hours ago, which seemed to only require 3 system calls and one full
scan of any task address space, did you read all the /proc/*/maps files,
for all 256 of the tasks involved?  I would think you would have to have
done so, or else one of these tasks could be holding onto some private
memory of its own that we would need to migrate.  Are the stack pages
and any per-thread private data on pages visible to all the threads, or
are some of these pages private to each thread?  Does anything prevent a
thread from having additional private pages invisible to the other
threads?

Could you redo your example, including scans implied by reading maps
files, and including system calls needed to do those reads, and needed
to migrate any private pages they might have?  Perhaps your preferred
API doesn't have such an insane advantage after all.

I'm fixing soon to consider another variant of this call, that takes an
_array_ of pids, along with the old and new arrays of nodes, but takes
no virtual address range.  The kernel would scan each pid in the array,
migrating anything found on any old node to the corresponding new node,
all in one system call.  If my speculations above are right, this does
the minimum of scans, one per pid, and the minimum number of system
calls - one.  And does so without involving the user space code in racy
maps file reading to determine what to call (though the kernel code
would probably still have more than its share of races to fuss over).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
