Date: Mon, 10 Dec 2001 15:51:00 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how has set_pgdir been replaced in 2.4.x
Message-ID: <20011210155100.D1919@redhat.com>
References: <20011210103855.A1919@redhat.com> <00c801c1817e$bc3b4d70$03fe13ac@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00c801c1817e$bc3b4d70$03fe13ac@scs.ch>; from frey@scs.ch on Mon, Dec 10, 2001 at 01:35:19PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Frey <frey@scs.ch>
Cc: "'Stephen C. Tweedie'" <sct@redhat.com>, 'Martin Maletinsky' <maletinsky@scs.ch>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Dec 10, 2001 at 01:35:19PM +0100, Martin Frey wrote:
 
> >They are now faulted on demand for vmalloc.  The cost of manually
> >updating all the pgds for every vmalloc is just too expensive if
> >you've got tens of thousands of threads in the system.
> 
> Is there an implication on drivers, e.g. not accessing vmalloc'd
> memory from within a page fault handler? A page fault from a
> page fault handler is quite ugly...

arch/i386/mm/fault.c is where the magic happens.  The vmalloc fault
path is really, really careful not to access any potentially volatile
data, so it is supposed to be safe for use even inside traps and
interrupts.

There _is_ one place where it can break down: if you have a driver
which walks page tables manually after a vmalloc, expecting to
translate virtual addresses into physical ones before the VA has been
faulted in.  Other than that, it should be safe.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
