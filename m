Date: Fri, 21 May 1999 12:02:07 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Assumed Failure rates in Various o.s's ?
In-Reply-To: <19990521165432.A13600@arbat.com>
Message-ID: <Pine.LNX.3.95.990521114528.18804A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Erik Corry <erik@arbat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, ak-uu@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 1999, Erik Corry wrote:

> Actually, isn't it just munmap that is problematic?
> 
> After the access_ok you can't map a read-only file into the
> path of an oncoming copy_to_user without first unmapping
> what was there before (this is assuming a version of
> access_ok that checks whether something was mapped).
> So mmaps can safely happen in parallel with copy_to_user.

Both mmap and munmap are safe -- the i386 bug is that writes to read-only
pages succeed while in the kernel.  Mmap needs to lock the vma during
initialization in case the driver has to sleep.  To avoid the bug, we just
need to protect against making any pages readonly in the vma after the vma
is in a safe state: fork, read mappings of non-present pages, swapout --
just about anything that can modify the page table can put a read only
page.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
