Date: Wed, 15 Nov 2000 15:47:29 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Question about pte_alloc()
Message-ID: <20001115154729.H3186@redhat.com>
References: <3A12363A.3B5395AF@cse.iitkgp.ernet.in> <20001115105639.C3186@redhat.com> <3A132470.4F93CFF5@cse.iitkgp.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A132470.4F93CFF5@cse.iitkgp.ernet.in>; from sganguly@cse.iitkgp.ernet.in on Wed, Nov 15, 2000 at 07:04:00PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Nov 15, 2000 at 07:04:00PM -0500, Shuvabrata Ganguly wrote:

> "Stephen C. Tweedie" wrote:
> 
> > On Wed, Nov 15, 2000 at 02:07:38AM -0500, Shuvabrata Ganguly wrote:
> > > it appears from the code that pte_alloc() might block since it allocates
> > > a page table with GFP_KERNEL if the page table doesnt already exist. i
> > > need to call pte_alloc() at interrupt time.
> >
> > You cannot safely play pte games at interrupt time.  You _must_ do
> > this in the foreground.
> 
> why is that ? 

Because the locking mechanisms used to protect ptes on SMP machines
are not interrupt-safe, and because even on uni-processors, we may
perform non-atomic operations on the page tables (such as various
read-modify-write cycles) which will break if an interrupt occurs in
the middle of the cycle and modifies the pte.

> > Why can't you just let the application know that the event has
> > occurred and then let it mmap the data itself?
> 
> Two reasons:-
> i) since kernel memory is unswappable i dont want to allocate a big buffer
> and transfer it to the user when the device has filled it with data. instead
> i want to allocate a page, fill it with data and give it to the user process.
> 
> ii) if i allocate in pages and let the user know that a page of data has
> arrived, it will take a lot of context switches.

I don't buy that.  The user process _has_ to wait if there's no data
ready, surely?  It doesn't matter how you are passing the data around.

> basically i want the kernel to allocate memory on behalf of a process, and
> pass the virtual address of that buffer to the user when it does a read. this
> is somewhat like the "fbuf" scheme.

There are a number of ways you could do that without messiness in the
VM.  You could allocate a small number of pages at once, mmap()
them and use that as a ring buffer to the application.  Basically,
establishing a new kernel buffer mapping from user space IS the mmap()
operation --- why not use mmap for it?  The corresponding munmap when
the application has finished using the data lets the kernel know
exactly when the page can be recycled.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
