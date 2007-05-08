Subject: Re: [rfc] optimise unlock_page
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070508114003.GB19294@wotan.suse.de>
References: <20070508113709.GA19294@wotan.suse.de>
	 <20070508114003.GB19294@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 09 May 2007 07:30:27 +1000
Message-Id: <1178659827.14928.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-08 at 13:40 +0200, Nick Piggin wrote:
> This patch trades a page flag for a significant improvement in the unlock_page
> fastpath. Various problems in the previous version were spotted by Hugh and
> Ben (and fixed in this one).
> 
> Comments?
> 
> --
> 
> Speed up unlock_page by introducing a new page flag to signal that there are
> page waitqueue waiters for PG_locked. This means a memory barrier and a random
> waitqueue hash cacheline load can be avoided in the fastpath when there is no
> contention.

I'm not 100% familiar with the exclusive vs. non exclusive wait thingy
but wake_up_page() does __wake_up_bit() which calls __wake_up() with
nr_exclusive set to 1. Doesn't that mean that only one waiter will be
woken up ?

If that's the case, then we lose because we'll have clear PG_waiters but
only wake up one of them.

Waking them all would fix it but at the risk of causing other
problems... Maybe PG_waiters need to actually be a counter but if that
is the case, then it complicates things even more.

Any smart idea ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
