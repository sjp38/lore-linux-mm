From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14340.23558.9537.706181@dukat.scot.redhat.com>
Date: Wed, 13 Oct 1999 11:16:38 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910111850370.18777-100000@weyl.math.psu.edu>
References: <14338.25394.766252.528741@dukat.scot.redhat.com>
	<Pine.GSO.4.10.9910111850370.18777-100000@weyl.math.psu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Oct 1999 19:01:12 -0400 (EDT), Alexander Viro
<viro@math.psu.edu> said:

>> Deadlock.  Process A tries to do an mmap on mm A, gets the exclusive
>> lock, tries to swap out from process B, and grabs mm B's shared lock.
>> Process B in the mean time is doing the same thing and has an exclusive
>> lock on mm B, and is trying to share-lock A.  Whoops.

> <looking at the places in question>
> insert_vm_struct doesn't allocate anything.
> Ditto for merge_segments
> In do_munmap() the area that should be protected (ripping the vmas from
> the list) doesn't allocate anything too.

No such luck.  We don't take the mm semaphore in any of those places: we
already hold it.  The mmap() operation itself takes the semaphore, and
it _certainly_ allocates memory.  You could allow take it shared and
promote it later once the memory has been allocated, but that will just
open up a new class of promotion deadlocks.  Or you could drop and
retake after the allocations, but then you lose the protection of the
semaphore and you have to back and revalidate your vma once you have got
the exclusive lock (which _is_ possible, especially with a generation
number in the vma, but it's hideously ugly).

That's exactly why taking the semaphore in the swapper is so dangerous.  

> In the swapper we are protected from recursion, aren't we?

Yes: the PF_MEMALLOC flag sees to that.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
