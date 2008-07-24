From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GRU driver feedback
Date: Thu, 24 Jul 2008 12:41:50 +1000
References: <20080723141229.GB13247@wotan.suse.de>
In-Reply-To: <20080723141229.GB13247@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807241241.50299.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jack Steiner <steiner@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thursday 24 July 2008 00:12, Nick Piggin wrote:

> Meanwhile, I hope that gives a bit to go on. I'm sorry it has come
> relatively late in the game, but I had a week off a while back then had
> (have) some important work work I'm starting to get a handle on...
>
> Thanks,
> Nick

Couple of other things I noticed today before I launch into the mmu
notifier and TLB invalidate code proper.

- gru_invalidate_range_end -- atomic_dec can filter into wake_up_all, past
  the spin_lock in __wake_up, and past the loading of the list of tasks. So
  you can lose a wakeup I believe (not on x86, but on ia64 with release
  ordering spinlocks it would be possible). atomic_dec_and_test should do
  the trick, and you might also want to consider memory ordering of the
  atomic_inc (haven't really looked, but it seems quite suspicious to allow
  it be reordered).

- you seem to be using cache flushes and memory barriers in different ways
  but each to push out things to the GRU device. For example start_instruction
  does a wmb() then a store, then a CPU cache flush.

  I'm lost as to how the mmio protocol actually works (not the low level
  protocol, but exactly what cache attributes are used, and how the CPU
  pushes things to the device and vice versa).

  For example, if you are using wmb(), this I think implies you are using
  UC or WC memory to map the device, in which case I don't see why you need
  the gru_flush_cache (which would suggest WB memory). Is this documented
  somewhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
