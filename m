From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905211706.KAA50091@google.engr.sgi.com>
Subject: Re: Assumed Failure rates in Various o.s's ?
Date: Fri, 21 May 1999 10:06:47 -0700 (PDT)
In-Reply-To: <Pine.LNX.3.95.990521101041.17710A-100000@as200.spellcast.com> from "Benjamin C.R. LaHaise" at May 21, 99 10:25:42 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: erik@arbat.com, ak-uu@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Fri, 21 May 1999, Erik Corry wrote:
> 
> > According to Andi you already fixed this with a read lock that
> > prevents mmap and mmunmap from doing anything while the copy
> > is running.  This makes sense, since if you do it right with a
> > readers/writers lock you can keep out mmap without serialising
> > copy_to_user or copy_from_user.
> 
> I really like the cleanliness of this approach, but it's troublesome:
> memory allocations in other threads would then get blocked during large
> IOs -- very bad.  What if we instead move from the mm level semaphore to a
> per vma locking scheme?  The mmap semaphore could become a spinlock for
> fudging with list of vmas, and mmap/page faults/... could lock the
> specific vma.  Or would this be too heavy?
>

I am sorry I did not clear up this misconception in your original mail.
Though the uaccess procedures in my patch are called upage_rlock/upage_wlock,
they do not do any kind of locking. The code looks at the pte, decides
whether it is in a readable/writable state, and if so, fastpaths out,
returning a kernel virtual address for the user page, that kernel code can
use (without incurring faults). The reason this will work is because 
uaccess callers already have the kernel_lock, so no one can steal the
page (or munmap it). If the page is not in the proper state for the
access, then the procedure longpaths into grabbing the mmap_sem and 
doing a handle_mm_fault, which it keeps on doing until the page is in
the proper state. 

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
