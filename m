Message-ID: <38008F28.76CD7B4D@colorfullife.com>
Date: Sun, 10 Oct 1999 15:05:44 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.LNX.4.10.9910091758380.5808-100000@alpha.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> Look the swapout path. Without the big kernel lock you'll free vmas under
> swap_out().

I checked to code in mm/*.c, and it seems that reading the vma-list is
protected by either lock_kernel() [eg: swapper] or down(&mm->mmap_sem)
[eg: do_mlock].

But this means that both locks are required if you modify the vma list.
Single reader, multiple writer synchronization. Unusual, but interesting
:-)

Unfortunately, it seems that this is often ignored, eg. 

sys_mlock()->do_mlock()->merge_segments().
sys_brk()
sys_munmap() <<<<<< fixed by your patch.

It that correct?
Should I write a patch or is someone working on these problems?
How should we fix it?

a) the swapper calls down(&mm->mmap_sem), but I guess that would
lock-up.

b) everyone who changes the vma list calls lock_kernel().
I think it would be a bad thing to call lock_kernel() immediately in the
sys_??() function, I think we should hide the lock_kernel() call
somewhere
inside the vma-list code [add functions which modify the vma list, and
they call lock_kernel()].

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
