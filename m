Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA19869
	for <Linux-MM@kvack.org>; Fri, 21 May 1999 13:24:38 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905211723.KAA67838@google.engr.sgi.com>
Subject: Re: Assumed Failure rates in Various o.s's ?
Date: Fri, 21 May 1999 10:23:06 -0700 (PDT)
In-Reply-To: <19990521120725.A581384@daimi.au.dk> from "Erik Corry" at May 21, 99 12:07:25 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Erik Corry <erik@arbat.com>
Cc: ak-uu@muc.de, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> > Now for a proposal: I don't see a down(mm->mmap_sem) being done
> > in the code path leading up to calls to __verify_write. Am I missing
> > it? If a down(mm->mmap_sem) were added around __verify_write, you could
> > quit worrying about simultaneous munmaps while an user access function 
> > was executing. 
> 
> I think this is the wrong place.  As far as I understand it,
> the verify_write runs before the actual copying takes place.
> So after verify_write has run, while the copy_to_user is
> taking place there can be a page fault (is that even necessary
> on SMP?).  While that is happening, the black hat user can do
> an mmap/munmap in another thread.  But I haven't really looked
> into it much, I am relying mostly on hearsay here.
>

Note that verify_write loops thru pages, making them go to the
proper state. While the pages in the first vma have been verified,  
the code might fault verifying pages in the second vma. It gives
up the kernel lock, letting another thread munmap the already 
verified vma, and replace it with a readonly vma. I didn't
see any checks to prevent this .. thus my proposal for the mmap_sem
in this path. On a differnt note, check out
http://humbolt.nl.linux.org/lists/linux-mm/1999-05/msg00022.html
about why the mmap_sem is needed anyways for correctness.

If this were done, say the copy_to_user faults (with the kernel_lock
held by caller of copy_to_user). Then, the fault handling code will
grab mmap_sem, before possibly going to sleep releasing the kernel_lock.
No munmaps can happen since mmap_sem is held.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
