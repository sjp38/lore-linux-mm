Date: Mon, 25 Sep 2000 12:34:56 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VMt
Message-ID: <20000925123456.A16612@hq.fsmlabs.com>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com> <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com> <20000925200454.A14728@pcep-jamie.cern.ch> <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000925192453.R2615@redhat.com>; from Stephen C. Tweedie on Mon, Sep 25, 2000 at 07:24:53PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: yodaiken@fsmlabs.com, Jamie Lokier <lk@tantalophile.demon.co.uk>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 07:24:53PM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Mon, Sep 25, 2000 at 12:13:15PM -0600, yodaiken@fsmlabs.com wrote:
> 
> > > Definitely not.  GFP_ATOMIC is reserved for things that really can't
> > > swap or schedule right now.  Use GFP_ATOMIC indiscriminately and you'll
> > > have to increase the number of atomic-allocatable pages.
> > 
> > Process 1,2 and 3 all start allocating 20 pages
> >       process 1 stalls after allocating 19
> >       some memory is freed and process 2 runs and stall after allocating 19
> >       some memory is free and process 3 runs and stalls after allocating 19
> >      
> >     now 57 pages are locked up in non-swapable kernel space and the system deadlocks OOM.
> 
> Or go the beancounter route: process 1 asks "can I pin 20 pages", gets
> told "yes", and goes allocating them, blocking as necessary until it

So you have a "pre-allocation allocator"?  Leads to interesting and hard to detect
bugs with old code that does not pre-allocate or with code that incorrectly pre-allocates
or that blocks on something unrelated

           preallocte 20 pages
           get first
           ask for an inode -- block waiting for an inode


or
           preallocate 20 pages
           if(checkuserpath())return -ENOWAY; /* stranding my pre-allocate */
           else get them pages


What's nice about these is they don't cause errors on test and seem more 
difficult to spot than looking for cases where allocated memory gets stranded.
Doesn't the alloc_vec method seem simpler to you?

> gets them.  Process 2 asks "can *I* pin 20 pages" and the answer is
> either "not right now", in which case it waits for process 1 to
> release its reservation, or "no, you've exceeded your user quota" in

Or for someone else to free more pages ... 

> which case it fails with ENOMEM.  (That latter case can protect us
> against a lot of DoS attacks from local users.)

I like ENOMEM anyways.

> 
> The same accounting really needs to be done for page tables, as that
> represents one of the biggest sources of unaccounted, unswappable
> pages which user processes can cause to be created right now.



-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
