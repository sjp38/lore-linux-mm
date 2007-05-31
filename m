Date: Thu, 31 May 2007 14:04:12 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070531110412.GM4715@minantech.com>
References: <1180467234.5067.52.camel@localhost> <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com> <20070531064753.GA31143@minantech.com> <200705311243.20119.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705311243.20119.ak@suse.de>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2007 at 12:43:19PM +0200, Andi Kleen wrote:
> 
> > > The faulted page will use the memory policy of the task that faulted it 
> > > in. If that process has numa_set_localalloc() set then the page will be 
> > > located as closely as possible to the allocating thread.
> > 
> > Thanks. But I have to say this feels very unnatural.
> 
> What do you think is unnatural exactly? First one wins seems like a quite 
> natural policy to me.
No it is not (not always). I want to create shared memory for
interprocess communication. Process A will write into the memory and
process B will periodically poll it to see if there is a message there.
In NUMA system I want the physical memory for this VMA to be allocated
from node close to process B since it will use it much more frequently.
But I don't want to pre-fault all pages in process B to achieve this
because the region can be huge and because it doesn't guaranty much if
swapping is involved. So numa_set_localalloc() looks like it achieves
exactly this. Without this function I agree that the "first one wins" is
very sensible assumption, but when each process stated it's preferences
explicitly by calling the function it is not longer sensible to me as a
user of the API. When you start to thing about how memory policy may be
implemented in the kernel and understand that memory policy is a
property of an address space (is it?) and not a file then you start to
understand current behaviour, but this is implementation details.


> 
> > So to have 
> > desirable effect I have to create shared memory with shmget?
> 
> shmget behaves the same.
> 
Then I misinterpreted "Shared Policy" section from Lee's document.
It seems that he states that for memory region created with shmget the
policy is a property of a shared object and not of a process' address
space.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
