Message-ID: <3800DE17.935ADF8D@colorfullife.com>
Date: Sun, 10 Oct 1999 20:42:31 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.GSO.4.10.9910101327010.16317-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> I'm not sure that it will work (we scan the thing in many places and
> quite a few may be blocking ;-/), unless you propose to protect individual
> steps of the scan, which will give you lots of overhead.

The overhead should be low, we could keep the "double synchronization",
ie
* either down(&mm->mmap_sem) or spin_lock(&mm->vma_list_lock) for read
* both locks for write.

I think that 3 to 5 spin_lock() calls are required.

> I suspect that
> swap_out_mm() needs fixing, not everything else... And it looks like we
> can't drop the sucker earlier in handle_mm_fault. Or can we?

That would be a good idea:
For multi-threaded applications, swap-in is currently single-threaded,
ie we do not overlap the io operations if 2 threads of the same process
cause page faults. Everything is fully serialized.

But I think this would be a huge change, eg do_munmap() in one thread
while another thread waits for page-in....

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
