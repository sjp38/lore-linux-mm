Date: Mon, 25 Sep 2000 13:16:29 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VMt
In-Reply-To: <E13da01-00057k-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.21.0009251314350.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Alan Cox wrote:

> > > GFP_KERNEL has to be able to fail for 2.4. Otherwise you can get
> > > everything jammed in kernel space waiting on GFP_KERNEL and if the
> > > swapper cannot make space you die.
> > 
> > if one can get everything jammed waiting for GFP_KERNEL, and not being
> > able to deallocate anything, thats a VM or resource-limit bug. This
> > situation is just 1% RAM away from the 'root cannot log in', situation.
> 
> Unless Im missing something here think about this case
> 
> 2 active processes, no swap
> 
> #1					#2
> kmalloc 32K				kmalloc 16K
> OK					OK
> kmalloc 16K				kmalloc 32K
> block					block
> 
> so GFP_KERNEL has to be able to fail - it can wait for I/O in
> some cases with care, but when we have no pages left something
> has to give

The trick here is to:
1) keep some reserved pages around for PF_MEMALLOC tasks
   (we need this anyway)
2) set PF_MEMALLOC on the task you're killing for OOM,
   that way this task will either get the memory or
   fail (note that PF_MEMALLOC tasks don't wait)

This way the OOM-killed task will be able to exit quickly
and the rest of the system will not get killed as a side
effect.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
