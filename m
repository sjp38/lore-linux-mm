From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.1685.876705.370057@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 16:47:33 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <3800DE17.935ADF8D@colorfullife.com>
References: <Pine.GSO.4.10.9910101327010.16317-100000@weyl.math.psu.edu>
	<3800DE17.935ADF8D@colorfullife.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Alexander Viro <viro@math.psu.edu>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Oct 1999 20:42:31 +0200, Manfred Spraul
<manfreds@colorfullife.com> said:

>> I'm not sure that it will work (we scan the thing in many places and
>> quite a few may be blocking ;-/), unless you propose to protect individual
>> steps of the scan, which will give you lots of overhead.

> The overhead should be low, we could keep the "double synchronization",
> ie
> * either down(&mm->mmap_sem) or spin_lock(&mm->vma_list_lock) for read
> * both locks for write.

Looks good.

> That would be a good idea:
> For multi-threaded applications, swap-in is currently single-threaded,
> ie we do not overlap the io operations if 2 threads of the same process
> cause page faults. Everything is fully serialized.

That can be fixed another way --- it is relatively simple to drop the
semaphore while we read the page from disk and revalidate the page fault
context when we unblock again.  A sequence number against vma list
changes plus a double-check against the contents of the pte would be
sufficient here.  If the context has changed, we can just return: we'll
get another page fault from scratch, and the page will already be in
cache. 

We already have to do part of this work anyway because every time we
block while processing a write fault, we have to double-check to see if
the swapper removed the pte while we were asleep.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
