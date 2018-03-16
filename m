Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E42A06B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:53:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x20so7255771qtm.15
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 11:53:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 188sor5242360qkm.111.2018.03.16.11.53.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 11:53:52 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:53:50 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v9 09/61] xarray: Replace exceptional entries
Message-ID: <20180316185349.c4ebbwuzlhihec5f@destiny>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-10-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313132639.17387-10-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, Mar 13, 2018 at 06:25:47AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Introduce xarray value entries to replace the radix tree exceptional
> entry code.  This is a slight change in encoding to allow the use of an
> extra bit (we can now store BITS_PER_LONG - 1 bits in a value entry).
> It is also a change in emphasis; exceptional entries are intimidating
> and different.  As the comment explains, you can choose to store values
> or pointers in the xarray and they are both first-class citizens.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h    |   4 +-
>  arch/powerpc/include/asm/nohash/64/pgtable.h    |   4 +-
>  drivers/gpu/drm/i915/i915_gem.c                 |  17 ++--
>  drivers/staging/lustre/lustre/mdc/mdc_request.c |   2 +-
>  fs/btrfs/compression.c                          |   2 +-
>  fs/dax.c                                        | 107 ++++++++++++------------
>  fs/proc/task_mmu.c                              |   2 +-
>  include/linux/radix-tree.h                      |  36 ++------
>  include/linux/swapops.h                         |  19 ++---
>  include/linux/xarray.h                          |  54 ++++++++++++
>  lib/idr.c                                       |  61 ++++++--------
>  lib/radix-tree.c                                |  21 ++---
>  mm/filemap.c                                    |  10 +--
>  mm/khugepaged.c                                 |   2 +-
>  mm/madvise.c                                    |   2 +-
>  mm/memcontrol.c                                 |   2 +-
>  mm/mincore.c                                    |   2 +-
>  mm/readahead.c                                  |   2 +-
>  mm/shmem.c                                      |  10 +--
>  mm/swap.c                                       |   2 +-
>  mm/truncate.c                                   |  12 +--
>  mm/workingset.c                                 |  12 ++-
>  tools/testing/radix-tree/idr-test.c             |   6 +-
>  tools/testing/radix-tree/linux/radix-tree.h     |   1 +
>  tools/testing/radix-tree/multiorder.c           |  47 +++++------
>  tools/testing/radix-tree/test.c                 |   2 +-
>  26 files changed, 223 insertions(+), 218 deletions(-)
> 

<snip>

>  
> @@ -453,18 +449,14 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
>  			new += bit;
>  			if (new < 0)
>  				return -ENOSPC;
> -			if (ebit < BITS_PER_LONG) {
> -				bitmap = (void *)((1UL << ebit) |
> -						RADIX_TREE_EXCEPTIONAL_ENTRY);
> -				radix_tree_iter_replace(root, &iter, slot,
> -						bitmap);
> -				*id = new;
> -				return 0;
> +			if (bit < BITS_PER_XA_VALUE) {
> +				bitmap = xa_mk_value(1UL << bit);
> +			} else {
> +				bitmap = this_cpu_xchg(ida_bitmap, NULL);
> +				if (!bitmap)
> +					return -EAGAIN;
> +				__set_bit(bit, bitmap->bitmap);
>  			}
> -			bitmap = this_cpu_xchg(ida_bitmap, NULL);
> -			if (!bitmap)
> -				return -EAGAIN;
> -			__set_bit(bit, bitmap->bitmap);
>  			radix_tree_iter_replace(root, &iter, slot, bitmap);
>  		}
>  

This threw me off a bit, but we do *id = new below.

> @@ -495,9 +487,9 @@ void ida_remove(struct ida *ida, int id)
>  		goto err;
>  
>  	bitmap = rcu_dereference_raw(*slot);
> -	if (radix_tree_exception(bitmap)) {
> +	if (xa_is_value(bitmap)) {
>  		btmp = (unsigned long *)slot;
> -		offset += RADIX_TREE_EXCEPTIONAL_SHIFT;
> +		offset += 1; /* Intimate knowledge of the xa_data encoding */
>  		if (offset >= BITS_PER_LONG)
>  			goto err;
>  	} else {

Ick.

<snip>

> @@ -393,11 +393,11 @@ void ida_check_conv(void)
>  	for (i = 0; i < 1000000; i++) {
>  		int err = ida_get_new(&ida, &id);
>  		if (err == -EAGAIN) {
> -			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 2));
> +			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 1));
>  			assert(ida_pre_get(&ida, GFP_KERNEL));
>  			err = ida_get_new(&ida, &id);
>  		} else {
> -			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 2));
> +			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 1));

Can we just use BITS_PER_XA_VALUE here?

Overall looks fine to me, I'm not married to changing any of the nits.

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef
