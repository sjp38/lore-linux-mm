Message-ID: <3A144453.D0724CC1@cse.iitkgp.ernet.in>
Date: Thu, 16 Nov 2000 15:32:19 -0500
From: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
MIME-Version: 1.0
Subject: Re: Question about pte_alloc()
References: <3A12363A.3B5395AF@cse.iitkgp.ernet.in> <20001115105639.C3186@redhat.com> <3A132470.4F93CFF5@cse.iitkgp.ernet.in> <20001115154729.H3186@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> Hi,
>
> On Wed, Nov 15, 2000 at 07:04:00PM -0500, Shuvabrata Ganguly wrote:
>
> > "Stephen C. Tweedie" wrote:
> >
> > > On Wed, Nov 15, 2000 at 02:07:38AM -0500, Shuvabrata Ganguly wrote:
> > > > it appears from the code that pte_alloc() might block since it allocates
> > > > a page table with GFP_KERNEL if the page table doesnt already exist. i
> > > > need to call pte_alloc() at interrupt time.
> > >
> > > You cannot safely play pte games at interrupt time.  You _must_ do
> > > this in the foreground.
> >
> > why is that ?
>
> Because the locking mechanisms used to protect ptes on SMP machines
> are not interrupt-safe, and because even on uni-processors, we may
> perform non-atomic operations on the page tables (such as various
> read-modify-write cycles) which will break if an interrupt occurs in
> the middle of the cycle and modifies the pte.
>

point understood. i got that from the code.

>
> > > Why can't you just let the application know that the event has
> > > occurred and then let it mmap the data itself?
> >
> > Two reasons:-
> > i) since kernel memory is unswappable i dont want to allocate a big buffer
> > and transfer it to the user when the device has filled it with data. instead
> > i want to allocate a page, fill it with data and give it to the user process.
> >
> > ii) if i allocate in pages and let the user know that a page of data has
> > arrived, it will take a lot of context switches.
>
> I don't buy that.  The user process _has_ to wait if there's no data
> ready, surely?

well i did not mention earlier what i am trying to do. i are trying to implement a
zero-copy light-weight protocol for PVM. the PVM task can do computation instead
of waiting for data to arrive. when it needs data it calls read to get the data .
if the data has not arrived yet _then_ it would wait. it would really help if i
could tranfer pages of a msg buffer to the user without the process knowing
....then keep a pointer to that buffer in the rx_queue and pass this pointer to
the process when it calls read.


> It doesn't matter how you are passing the data around.
>
> > basically i want the kernel to allocate memory on behalf of a process, and
> > pass the virtual address of that buffer to the user when it does a read. this
> > is somewhat like the "fbuf" scheme.
>
> There are a number of ways you could do that without messiness in the
> VM.  You could allocate a small number of pages at once, mmap()
> them and use that as a ring buffer to the application.  Basically,
> establishing a new kernel buffer mapping from user space IS the mmap()
> operation --- why not use mmap for it? The corresponding munmap when the
> application has finished using the data lets the kernel know exactly when the
> page can be recycled.

i know that. but i dont want to wire the pages. i want the driver to allocate
pages, fill them up with data and then transfer them to the user, which would
enable the kernel to swap them  but then i cant touch page tables at interrupt
time.

> Cheers,
>  Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
