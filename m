Message-ID: <38026111.DB88AEA7@colorfullife.com>
Date: Tue, 12 Oct 1999 00:13:37 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.GSO.4.10.9910111733310.18777-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> What does it buy you over the simple semaphore here? Do you really see a
> contention scenario?

I think you are right, I see no case where a normal semaphore would
lock-up and the rw semaphore would not lock up.

we win something _if_ vm_ops->swapout() is extremely slow:
* with lock_kernel() [ie currently], multiple threads can sleep within
vm_ops->swapout() of the same "struct mm"
* an rw-semaphore would mimic that behaviour.
* a normal semaphore would prevent that.

I'm not sure if it is worth to implement a rw-semaphore, especially
since we win something in a very obscure case, but we loose cpu-cycles
for every down_rw()/up_rw() [there is no 2 asm-instruction rw-semaphore]

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
