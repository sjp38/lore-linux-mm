Message-ID: <3802531C.2596D0D9@colorfullife.com>
Date: Mon, 11 Oct 1999 23:14:04 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.GSO.4.10.9910111157310.18777-100000@weyl.math.psu.edu>
		<38022640.3447ECA6@colorfullife.com> <14338.17769.942609.464811@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alexander Viro <viro@math.psu.edu>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> The swapout method will need to drop the spinlock.  We need to preserve
> the vma over the call into the swapout method, and the method will need
> to be able to block.

no spinlock, a rw-semaphore, ie a multiple-reader single-writer sync
object which calls schedule() when the resource is busy.

IIRC, the vma-list is only modified by
* insert_vma_struct(): never sleeps, doesn't allocate memory. No
problems with swap-out.
* merge_vm_area(): dito.
* do_munmap(): the area which modifies the vma-list makes no memory
allocations, should make no problems under low-memory.
--> everyone who needs an exclusive access is OOM safe.

Additionally, the swap-out should use a "starve writer"-policy, ie there
will be no dead-locks with multiple concurrent swap-outs in the same
"struct mm" [concurrent means overlapped io, still serialized by
lock_kernel()].
I think the result should be OOM safe without touching
vm_ops->swapout().


--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
