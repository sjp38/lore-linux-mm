Date: Sun, 21 Jul 2002 23:17:32 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: pte_chain_mempool-2.5.27-1
Message-ID: <20020722061732.GD919@holomorphy.com>
References: <20020721035513.GD6899@holomorphy.com> <3D3BA131.34D2BD86@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D3BA131.34D2BD86@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, anton@samba.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2002 at 11:07:45PM -0700, Andrew Morton wrote:
> mempool?  Guess so.
> mempool is really designed for things like IO request structures.
> BIOs, etc.  Things which are guaranteed to have short lifecycles.
> Things which make the "wait for some objects to be freed" loop
> in mempool_alloc() reliable.

My usage of it was incorrect. Slab allocation alone will have to do.


On Sun, Jul 21, 2002 at 11:07:45PM -0700, Andrew Morton wrote:
> Be aware that mempool kmallocs a contiguous chunk of element
> pointers.  This statement is asking for a
> kmalloc(16384 * sizeof(void *)), which is 128k. It will work,
> but only just.
> How did you engineer the size of this pool, btw?  In the
> radix_tree code, we made the pool enormous.  It was effectively
> halved in size when the ratnodes went to 64 slots, but I still
> have the fun task of working out what the pool size should really
> be.  In retrospect it would have been smarter to make it really
> small and then increase it later in response to tester feedback.
> Suggest you do that here.

Any contiguous allocation that large is a bug. There was no engineering.
It was a "conservative guess", and hence even worse than the radix tree
node pool sizing early on. Removing mempool from it entirely is the best
option. pte_chains aren't transient enough to work with this, and my
misreading of mempool led me to believe it had the logic to deal with
the cases you described above.

OOM handling is on the way soon anyway, so mempool for "extra
reliability" will be a non-issue then.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
