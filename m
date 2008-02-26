From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps (f.e. for XPmem)
Date: Tue, 26 Feb 2008 17:11:32 +1100
References: <20080215064859.384203497@sgi.com> <200802211520.03529.nickpiggin@yahoo.com.au> <20080221105838.GJ11391@sgi.com>
In-Reply-To: <20080221105838.GJ11391@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802261711.33213.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thursday 21 February 2008 21:58, Robin Holt wrote:
> On Thu, Feb 21, 2008 at 03:20:02PM +1100, Nick Piggin wrote:
> > > > So why can't you export a device from your xpmem driver, which
> > > > can be mmap()ed to give out "anonymous" memory pages to be used
> > > > for these communication buffers?
> > >
> > > Because we need to have heap and stack available as well.  MPT does
> > > not control all the communication buffer areas.  I haven't checked, but
> > > this is the same problem that IB will have.  I believe they are
> > > actually allowing any memory region be accessible, but I am not sure of
> > > that.
> >
> > Then you should create a driver that the user program can register
> > and unregister regions of their memory with. The driver can do a
> > get_user_pages to get the pages, and then you'd just need to set up
> > some kind of mapping so that userspace can unmap pages / won't leak
> > memory (and an exit_mm notifier I guess).
>
> OK.  You need to explain this better to me.  How would this driver
> supposedly work?  What we have is an MPI library.  It gets invoked at
> process load time to establish its rank-to-rank communication regions.
> It then turns control over to the processes main().  That is allowed to
> run until it hits the
> 	MPI_Init(&argc, &argv);
>
> The process is then totally under the users control until:
> 	MPI_Send(intmessage, m_size, MPI_INT, my_rank+half, tag, MPI_COMM_WORLD);
> 	MPI_Recv(intmessage, m_size, MPI_INT, my_rank+half,tag, MPI_COMM_WORLD,
> &status);
>
> That is it.  That is all our allowed interaction with the users process.

OK, when you said something along the lines of "the MPT library has
control of the comm buffer", then I assumed it was an area of virtual
memory which is set up as part of initialization, rather than during
runtime. I guess I jumped to conclusions.


> That doesn't seem too unreasonable, except when you compare it to how the
> driver currently works.  Remember, this is done from a library which has
> no insight into what the user has done to its own virtual address space.
> As a result, each MPI_Send() would result in a system call (or we would
> need to have a set of callouts for changes to a processes VMAs) which
> would be a significant increase in communication overhead.
>
> Maybe I am missing what you intend to do, but what we need is a means of
> tracking one processes virtual address space changes so other processes
> can do direct memory accesses without the need for a system call on each
> communication event.

Yeah it's tricky. BTW. what is the performance difference between
having a system call or no?


> > Because you don't need to swap, you don't need coherency, and you
> > are in control of the areas, then this seems like the best choice.
> > It would allow you to use heap, stack, file-backed, anything.
>
> You are missing one point here.  The MPI specifications that have
> been out there for decades do not require the process use a library
> for allocating the buffer.  I realize that is a horrible shortcoming,
> but that is the world we live in.  Even if we could change that spec,

Can you change the spec? Are you working on it?


> we would still need to support the existing specs.  As a result, the
> user can change their virtual address space as they need and still expect
> communications be cheap.

That's true. How has it been supported up to now? Are you using
these kind of notifiers in patched kernels?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
