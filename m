Date: Mon, 11 Oct 1999 12:05:23 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <14338.1859.507452.652164@dukat.scot.redhat.com>
Message-ID: <Pine.GSO.4.10.9910111157310.18777-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 11 Oct 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Sun, 10 Oct 1999 15:03:45 -0400 (EDT), Alexander Viro
> <viro@math.psu.edu> said:
> 
> > Hold on. In swap_out_mm() you have to protect find_vma() (OK, it doesn't
> > block, but we'll have to take care of mm->mmap_cache) _and_ you'll have to
> > protect vma from destruction all way down to try_to_swap_out(). And to
> > vma->swapout(). Which can sleep, so spinlocks are out of question
> > here.
> 
> No, spinlocks would be ideal.  The vma swapout codes _have_ to be
> prepared for the vma to be destroyed as soon as we sleep.  In fact, the
> entire mm may disappear if the process happens to exit.  Once we know
> which page to write where, the swapout operation becomes a per-page
> operation, not per-vma.

Aha, so you propose to drop it in ->swapout(), right? (after get_file() in
filemap_write_page()... Ouch. Probably we'ld better lambda-expand the call
in filemap_swapout() - the thing is called from other places too)...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
