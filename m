From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003131828.KAA82343@google.engr.sgi.com>
Subject: Re: [PATCH] mincore for i386, against 2.3.51
Date: Mon, 13 Mar 2000 10:28:22 -0800 (PST)
In-Reply-To: <Pine.BSO.4.10.10003131309590.18890-100000@funky.monkey.org> from "Chuck Lever" at Mar 13, 2000 01:16:38 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> hi kanoj-
> 
> thanks for the good comments.
> 
> On Mon, 13 Mar 2000, Kanoj Sarcar wrote:
> > #1
> > >  static struct vm_operations_struct shm_vm_ops = {
> > >  	open:	shm_open,	/* callback for a new vm-area open */
> > >  	close:	shm_close,	/* callback for when the vm-area is released */
> > > +	incore:	shm_incore,
> > >  	nopage:	shm_nopage,
> > >  	swapout:shm_swapout,
> > >  };
> > 
> > shmzero_vm_ops should also probably have a incore function. /dev/zero is
> > quite similar to shm, except the locking protocol is a little different
> > (look at shmzero_nopage and shm_nopage), you should be able to seperate
> > out the shm incore() function into a basic routine/#define that both shm
> > and /dev/zero can use. Let me know if you need help with this.
> 
> i'll take a look at this.  although, it might be OK to assume that
> /dev/zero pages are always in core, which simplifies shmzero_incore.

/dev/zero pages might be out on swap too, similar to shm pages.

> 
> > #2. It wasn't very clear to me how MAP_ANON pages are being handled. Maybe
> > I did not read the patch closely enough.
> 
> i'm assuming anonymously mapped pages get a vm_ops struct that has a NULL
> for the incore function pointer.  i wasn't sure it is useful to ask the
> question "is this anonymous page in memory?".  if it turns out that
> applications need this, it is simple to add another function to do this.

Afaik, anon pages get a null vm_ops. Providing a default function for these
cases is probably not importatn right away.

> 
> > #3. If you have the time, it might make sense to pump out the #pages via
> > /proc/pid/maps too (although I don't know whether that will break some
> > apps that already know the output format).
> 
> i'm not exactly sure what you mean here.  what #pages value do you mean?

The vector that mincore() returns can also be reported via cat /proc/pid/maps,
right? Might be useful, but not neccesary ...

Kanoj
> 
> 	- Chuck Lever
> --
> corporate:	<chuckl@netscape.com>
> personal:	<chucklever@netscape.net> or <cel@monkey.org>
> 
> The Linux Scalability project:
> 	http://www.citi.umich.edu/projects/linux-scalability/
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
